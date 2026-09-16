import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Append the actual (routed) model and a rough cost estimate to each assistant
 * answer. pi can't price `openrouter/auto` (it has no fixed rate), so we price
 * the resolved `responseModel` against a small per-token table and accumulate a
 * running total per session. Rates are approximate; treat as ±50%.
 */

/** [model-id substring, $/1M input, $/1M output]. Ordered specific-first. */
const RATES: readonly (readonly [string, number, number])[] = [
	["openai/gpt-5.1-nano", 0.3, 1], ["openai/gpt-5-nano", 0.3, 1],
	["openai/gpt-4.1-nano", 0.1, 0.4], ["openai/gpt-4.1-mini", 0.4, 1.6], ["openai/gpt-4.1", 2, 8],
	["openai/gpt-4o-mini", 0.15, 0.6], ["openai/gpt-4o", 2.5, 10],
	["openai/o1-pro", 20, 80], ["openai/o1", 15, 60], ["openai/o3-mini", 1.1, 4.4],
	["openai/o3", 2, 8], ["openai/o4-mini", 1.1, 8],
	["openai/", 5, 20], // other gpt-5 / gpt-4.x family
	["anthropic/claude-opus", 15, 75],
	["anthropic/claude-sonnet", 3, 15],
	["anthropic/claude-haiku", 0.8, 4],
	["google/gemini-2.5-pro", 1.25, 10], ["google/gemini-pro", 1.25, 10],
	["google/gemini-3-flash", 0.5, 3.5], ["google/gemini-2.5-flash", 0.3, 2.5],
	["google/gemini-flash", 0.1, 0.4], ["google/", 1.25, 10],
	["moonshotai/kimi-k2", 0.9, 2.8], ["moonshotai/", 0.9, 2.8],
	["deepseek/deepseek-reasoner", 0.55, 2.19], ["deepseek/deepseek-chat", 0.27, 1.1],
	["deepseek/", 0.55, 2.19],
	["mistralai/mistral-large", 2, 6], ["mistralai/mistral-small", 1, 3], ["mistralai/", 2, 6],
	["meta-llama/llama-3.3-70b", 0.4, 0.4], ["meta-llama/llama-3.1-8b", 0.05, 0.05],
	["meta-llama/", 0.35, 0.4],
	["qwen/qwen2.5-72b", 0.4, 0.6], ["qwen/qwen", 0.2, 0.3],
];

/** Cache read billed ~as input, cache write slightly above input. */
const CACHE_READ_FRAC = 0.25;
const CACHE_WRITE_FRAC = 1.25;
/** Fallback for unbiased models: a mid-range "average" OpenRouter model. */
const FALLBACK = { input: 1.5, output: 3 } as const;

function ratesFor(model: string): { input: number; output: number } {
	const id = model.toLowerCase();
	for (const [sub, input, output] of RATES) if (id.includes(sub)) return { input, output };
	return FALLBACK;
}

function estimateCost(usage: {
	input: number; output: number; cacheRead: number; cacheWrite: number;
}, model: string): number {
	const { input, output } = ratesFor(model);
	const inCost = (usage.input + usage.cacheWrite * CACHE_WRITE_FRAC + usage.cacheRead * CACHE_READ_FRAC) * input;
	const outCost = usage.output * output;
	return (inCost + outCost) / 1e6; // $/M -> dollars
}

function fmtUsd(cost: number): string {
	return `\u2248$${cost.toFixed(2)}`; // nearest cent
}

/** Running cost ($) per session; accumulates across turns. */
const running = new Map<string, number>();

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		running.set(ctx.sessionManager.getSessionId(), 0);
	});

	pi.on("message_end", async (event, ctx) => {
		const msg = event.message;
		if (msg.role !== "assistant") return;

		const model = msg.responseModel ?? msg.model;
		if (!model) return;

		const key = ctx.sessionManager.getSessionId();
		const total = (running.get(key) ?? 0) + estimateCost(msg.usage, model);
		running.set(key, total);

		// Intermediate tool-call turns cost tokens too, but carry no user-facing answer.
		if (msg.stopReason === "tool_use") return;

		let last = -1;
		msg.content.forEach((b, i) => {
			if (b.type === "text") last = i;
		});
		if (last === -1) return;
		if (msg.content[last].text.endsWith(`(${model})`)) return;

		const trailing = `(${model}\u00b7 ${fmtUsd(total)})`;
		return {
			message: {
				...msg,
				content: msg.content.map((b, i) =>
					i === last ? { ...b, text: `${b.text.trimEnd()}\u00a0\u00a0\u00a0${trailing}` } : b,
				),
			},
		};
	});
}