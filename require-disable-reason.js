// An oxlint JS plugin with one option-free rule: every lint-disable directive
// must carry a reason after ` -- `, for example
// `// oxlint-disable-next-line <rule> -- <reason>`.
const directive =
  /^\s*(?:oxlint|eslint)-disable(?:-next-line|-line)?(?![\w-])(.*)$/s;
const reason = /\s--\s+\S/;

export default {
  meta: { name: "ts-standard" },
  rules: {
    "require-disable-reason": {
      createOnce(context) {
        return {
          Program() {
            for (const comment of context.sourceCode.getAllComments()) {
              const match = directive.exec(comment.value);
              if (match === null || reason.test(match[1] ?? "")) continue;
              context.report({ messageId: "missingReason", node: comment });
            }
          },
        };
      },
      meta: {
        type: "problem",
        docs: {
          description:
            "Require a reason (`-- <reason>`) on every lint-disable directive.",
        },
        messages: {
          missingReason:
            "Add a reason to this lint-disable directive: `-- <reason>`.",
        },
        schema: [],
      },
    },
  },
};
