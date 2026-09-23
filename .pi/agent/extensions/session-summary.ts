import { uuidv7 } from "@earendil-works/pi-ai";
import { convertToLlm, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATE_TYPE = "session-summary-state";
const MAX_TRANSCRIPT_CHARS = 24000;
const HEAD_TRANSCRIPT_CHARS = 8000;
const MAX_MESSAGE_CHARS = 2000;
const MAX_TITLE_CHARS = 220;

const TITLE_INSTRUCTION = [
	"Write a title for the conversation below to show in the session browser.",
	"It should answer what the session is about in one short sentence of about 4-12 words.",
	"Describe the overall topic, not just the last exchange.",
	"Reply with only the title, no quotes, prefix, or trailing punctuation.",
].join("\n");

function contentText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.filter((p: any) => p?.type === "text" && typeof p.text === "string")
		.map((p: any) => p.text)
		.join("");
}

function toolNames(content: unknown): string[] {
	if (!Array.isArray(content)) return [];
	return content.filter((p: any) => p?.type === "toolCall" && typeof p.name === "string").map((p: any) => p.name);
}

function buildTranscript(messages: any[]): string {
	const parts: string[] = [];
	for (const m of messages) {
		if (m.role === "user") {
			const t = contentText(m.content).trim();
			if (t) parts.push(`User: ${t.slice(0, MAX_MESSAGE_CHARS)}`);
		} else if (m.role === "assistant") {
			const t = contentText(m.content).trim();
			if (t) parts.push(`Assistant: ${t.slice(0, MAX_MESSAGE_CHARS)}`);
			const names = toolNames(m.content);
			if (names.length) parts.push(`(Assistant used tools: ${names.join(", ")})`);
		}
	}
	const joined = parts.join("\n\n");
	if (joined.length <= MAX_TRANSCRIPT_CHARS) return joined;
	const head = joined.slice(0, HEAD_TRANSCRIPT_CHARS);
	const tail = joined.slice(-(MAX_TRANSCRIPT_CHARS - HEAD_TRANSCRIPT_CHARS));
	return `${head}\n\n[... omitted ...]\n\n${tail}`;
}

export default function (pi: ExtensionAPI) {
	let autoTitled = false;
	let lastAutoName: string | undefined;
	let running = false;

	pi.on("session_start", (_event, ctx) => {
		autoTitled = false;
		lastAutoName = undefined;
		for (const e of ctx.sessionManager.getEntries() as any[]) {
			if (e.type === "custom" && e.customType === STATE_TYPE) {
				autoTitled = true;
				lastAutoName = e.data?.autoName;
			}
		}
	});

	async function retitle(ctx: ExtensionContext, force: boolean) {
		const notify = (msg: string) => {
			if (ctx.hasUI) ctx.ui.notify(msg, "info");
		};
		const fail = (msg: string) => {
			if (force && ctx.hasUI) ctx.ui.notify(msg, "warning");
		};

		if (running) {
			if (force) notify("Title generation already in progress");
			return;
		}
		if (!ctx.sessionManager.isPersisted()) {
			fail("Session is not persisted");
			return;
		}
		// Auto-titling only once, and never over a name the user set by hand.
		const current = pi.getSessionName();
		if (!force && autoTitled) return;
		if (!force && current && current !== lastAutoName) return;

		const model = ctx.model;
		if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) {
			fail("Active model is not available");
			return;
		}

		running = true;
		try {
			const messages = convertToLlm(ctx.sessionManager.buildSessionContext().messages);
			if (!messages.some((m) => m.role === "user") || !messages.some((m) => m.role === "assistant")) return;
			const transcript = buildTranscript(messages);

			if (force) notify("Generating session title...");
			const response = await ctx.modelRegistry.complete(
				model,
				{
					messages: [
						{
							role: "user",
							content: [{ type: "text", text: `${TITLE_INSTRUCTION}\n\nSession:\n${transcript}` }],
							timestamp: Date.now(),
						},
					],
				},
				{ cacheRetention: "none", sessionId: uuidv7() },
			);
			if (response.stopReason !== "stop") {
				fail(`Title generation failed (${response.stopReason})`);
				return;
			}
			const title = response.content
				.filter((p: any) => p.type === "text")
				.map((p: any) => p.text ?? "")
				.join(" ")
				.replace(/^["'`]+|["'`]+$/g, "")
				.replace(/\s+/g, " ")
				.trim();
			if (!title || title.length > MAX_TITLE_CHARS) {
				fail("Title generation returned no usable title");
				return;
			}

			autoTitled = true;
			lastAutoName = title;
			pi.setSessionName(title);
			pi.appendEntry(STATE_TYPE, { autoName: title });
			notify(`Title: ${title}`);
		} catch {
			fail("Title generation failed");
		} finally {
			running = false;
		}
	}

	pi.on("agent_settled", async (_event, ctx) => {
		await retitle(ctx, false);
	});

	pi.registerCommand("summarize", {
		description: "Regenerate the session title from the full context",
		handler: async (_args, ctx) => {
			await retitle(ctx, true);
		},
	});
}
