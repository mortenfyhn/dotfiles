import { uuidv7 } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const FIRST_REVIEW_AT = 4;
const REVIEW_EVERY = 8;
const MAX_TRANSCRIPT_CHARS = 7000;
const STATE_TYPE = "session-summary-state";

function text(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content.filter((p: any) => p?.type === "text" && typeof p.text === "string").map((p) => p.text).join("\n");
}

function transcript(branch: any[]): string {
	const parts: string[] = [];
	for (const e of branch) {
		if (e.type !== "message") continue;
		const role = e.message?.role;
		if (role !== "user" && role !== "assistant") continue;
		const t = text(e.message?.content).trim();
		if (!t) continue;
		parts.push(`${role === "user" ? "U" : "A"}: ${t.slice(0, 700)}`);
	}
	const joined = parts.join("\n\n");
	return joined.length <= MAX_TRANSCRIPT_CHARS ? joined : joined.slice(-MAX_TRANSCRIPT_CHARS);
}

export default function (pi: ExtensionAPI) {
	let lastAutoName: string | undefined;
	let lastReviewedCount = 0;
	let reviewing = false;

	pi.on("session_start", (_event, ctx) => {
		lastAutoName = undefined;
		lastReviewedCount = 0;
		for (const e of ctx.sessionManager.getEntries() as any[]) {
			if (e.type === "custom" && e.customType === STATE_TYPE) {
				lastReviewedCount = e.data?.lastReviewedUserCount ?? 0;
				lastAutoName = e.data?.autoName;
			}
		}
	});

	async function doReview(ctx: ExtensionContext, force = false) {
		if (reviewing) {
			if (force && ctx.hasUI) ctx.ui.notify("Already reviewing title", "info");
			return;
		}
		if (!ctx.sessionManager.isPersisted()) {
			if (force && ctx.hasUI) ctx.ui.notify("Not a persisted session", "warning");
			return;
		}
		// If the session has a name not set by us, it was manual — leave it alone.
		if (!force && pi.getSessionName() && pi.getSessionName() !== lastAutoName) return;

		const branch = ctx.sessionManager.getBranch() as any[];
		const userCount = branch.filter((e) => e.type === "message" && e.message?.role === "user").length;
		if (!force && userCount < FIRST_REVIEW_AT) return;
		if (!force && userCount - lastReviewedCount < REVIEW_EVERY) return;

		reviewing = true;
		try {
			const model = ctx.modelRegistry.find("openrouter", "openai/gpt-4.1-nano") ??
				ctx.modelRegistry.find("openrouter", "openai/gpt-4o-mini") ??
				ctx.model;
			if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) return;

			const current = pi.getSessionName() ?? "(first prompt)";
			const prompt = [
				"Review the session below and decide whether its title (shown in a session browser) should change.",
				"The title must be a short label (2-6 words), not a full sentence.",
				"Reply KEEP if the current title is still accurate, or UPDATE: followed by the new short title.",
				"Example: UPDATE: Refactor auth module",
				"",
				`Current title: ${current}`,
				"Session:",
				transcript(branch),
			].join("\n");

			const response = await ctx.modelRegistry.complete(
				model,
				{ messages: [{ role: "user", content: [{ type: "text", text: prompt }], timestamp: Date.now() }] },
				{ reasoningEffort: "low", cacheRetention: "none", sessionId: uuidv7() },
			);
			const result = response.content
				.filter((p: any) => p.type === "text")
				.map((p: any) => p.text ?? "")
				.join(" ")
				.trim();

			if (/^UPDATE:/i.test(result)) {
				const name = result.replace(/^UPDATE:\s*/i, "").replace(/[\r\n]+/g, " ").trim();
				if (name && name.length <= 220) {
					lastAutoName = name;
					lastReviewedCount = userCount;
					pi.setSessionName(name);
					pi.appendEntry(STATE_TYPE, { lastReviewedUserCount: userCount, autoName: name });
					if (ctx.hasUI) ctx.ui.notify(`Title: ${name}`, "info");
				}
			} else if (result.toUpperCase() === "KEEP") {
				lastReviewedCount = userCount;
				pi.appendEntry(STATE_TYPE, { lastReviewedUserCount: userCount, autoName: lastAutoName });
				if (force && ctx.hasUI) ctx.ui.notify("Title unchanged", "info");
			}
		} catch {
			// best effort
		} finally {
			reviewing = false;
		}
	}

	pi.on("agent_settled", async (_event, ctx) => {
		await doReview(ctx);
	});

	pi.registerCommand("summarize", {
		description: "Update session browsing title",
		handler: async (_args, ctx) => {
			await doReview(ctx, true);
		},
	});
}