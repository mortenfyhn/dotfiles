import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Used only after OpenRouter/auto reports an upstream model failure.
const FALLBACK_PROVIDER = "openrouter";
const FALLBACK_MODEL = "deepseek/deepseek-v4-flash-0731";

const FAILURE = /(temporarily rate-limited|rate limit|too many requests|unavailable|overloaded|provider error|model .*not found|no available)/i;

type SessionState = {
	lastPrompt?: string;
	failure?: string;
	fallbackStarted: boolean;
};

const states = new Map<string, SessionState>();

function sessionState(ctx: { sessionManager: { getSessionId(): string } }): SessionState {
	const id = ctx.sessionManager.getSessionId();
	let state = states.get(id);
	if (!state) {
		state = { fallbackStarted: false };
		states.set(id, state);
	}
	return state;
}

function isAutoModel(model: { provider: string; id: string }): boolean {
	return model.provider === "openrouter" && model.id === "auto";
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		states.set(ctx.sessionManager.getSessionId(), { fallbackStarted: false });
	});

	// Keep the exact prompt so the failed turn can be replayed after changing models.
	pi.on("input", (event, ctx) => {
		if (event.source !== "extension" && event.text.trim()) {
			const state = sessionState(ctx);
			state.lastPrompt = event.text;
			state.failure = undefined;
			state.fallbackStarted = false;
		}
	});

	pi.on("message_end", (event, ctx) => {
		const message = event.message;
		if (message.role !== "assistant" || message.stopReason !== "error") return;

		const error = message.errorMessage ?? "";
		// `model` is the selected model; `responseModel` is the model OpenRouter
		// actually routed to. Check the former so manually selected Luna is untouched.
		if (FAILURE.test(error) && isAutoModel({ provider: message.provider, id: message.model })) {
			sessionState(ctx).failure = error;
		}
	});

	pi.on("agent_settled", async (_event, ctx) => {
		const state = sessionState(ctx);
		if (!state.failure || state.fallbackStarted || !state.lastPrompt) return;

		state.fallbackStarted = true;
		state.failure = undefined;

		const model = ctx.modelRegistry.find(FALLBACK_PROVIDER, FALLBACK_MODEL);
		if (!model) {
			ctx.ui.notify(`Fallback model not found: ${FALLBACK_PROVIDER}/${FALLBACK_MODEL}`, "error");
			return;
		}

		if (!(await pi.setModel(model))) {
			ctx.ui.notify(`Fallback model is not authenticated: ${FALLBACK_PROVIDER}/${FALLBACK_MODEL}`, "error");
			return;
		}

		ctx.ui.notify(`OpenRouter/auto model unavailable. Retrying with ${FALLBACK_MODEL}.`, "warning");
		await pi.sendUserMessage(state.lastPrompt);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		states.delete(ctx.sessionManager.getSessionId());
	});
}
