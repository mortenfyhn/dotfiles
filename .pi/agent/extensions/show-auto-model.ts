import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Append the actual (routed) model to each assistant answer. pi can't show the
 * resolved model for `openrouter/auto`, so we surface `responseModel`.
 */
export default function (pi: ExtensionAPI) {
	pi.on("message_end", (event) => {
		const { message } = event;
		if (message.role !== "assistant") return;
		if (message.stopReason === "toolUse") return; // no user-facing answer

		const model = message.responseModel ?? message.model;
		if (!model) return;
		const marker = `(${model})`;

		// Last text block (may be preceded by thinking / tool-call blocks).
		const last = message.content.findLastIndex((b) => b.type === "text");
		if (last === -1) return;
		const block = message.content[last];
		if (block.type !== "text") return;

		// Collapse any markers left by earlier runs, then add exactly one.
		// message_end can fire more than once per message; this keeps it idempotent.
		let text = block.text.trimEnd();
		while (text.endsWith(marker)) text = text.slice(0, -marker.length).trimEnd();

		return {
			message: {
				...message,
				content: message.content.map((b, i) =>
					i === last && b.type === "text"
						? { ...b, text: `${text}\u00a0\u00a0\u00a0${marker}` }
						: b,
				),
			},
		};
	});
}