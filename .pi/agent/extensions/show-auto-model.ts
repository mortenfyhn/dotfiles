import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Append the actual model to the end of each assistant answer. */
export default function (pi: ExtensionAPI) {
	pi.on("message_end", async (event) => {
		const msg = event.message;
		if (msg.role !== "assistant") return;

		const model = msg.responseModel ?? msg.model;
		if (!model || msg.stopReason === "tool_use") return;

		// Append to the last text block, unless it's already labeled.
		let last = -1;
		msg.content.forEach((b, i) => {
			if (b.type === "text") last = i;
		});
		if (last === -1 || msg.content[last].text.endsWith(`(${model})`)) return;

		return {
			message: {
				...msg,
				content: msg.content.map((b, i) =>
					i === last ? { ...b, text: `${b.text.trimEnd()} (${model})` } : b,
				),
			},
		};
	});
}