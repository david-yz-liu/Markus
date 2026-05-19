---
description: Defines an agentic workflow to use when creating new features.
---

## Instructions

When prompted to add a new feature to MarkUs, follow these steps:

1. First, ensure you are on the git `master` branch and that it is up to date with `origin/master`. Then create a new feature branch named `feature/<short-description>`.
2. Spawn a planning subagent to research the codebase and output an implementation plan. As part of the research, the planning subagent should search for related pull requests on GitHub. Also ask the human questions if a part of the prompt is unclear.

    The subagent does not have Write permission and so it is your responsibility to write the output plan to `PLAN.md`.
3. Create a **plan-reviewer** subagent to review the plan. The subagent should be provided the original user prompt and be directed to read `PLAN.md`, writing comments and questions in `PLAN-COMMENTS.md`.
4. Create a planning subagent to read `PLAN-COMMENTS.md`, revise `PLAN.md` to address the comments, and output a response. The subagent does not have Write permission and so it is your responsibility to append this response to an "AI Review Response" section at the end of `PLAN.md`.
5. Provide a brief summary of the plan to the human, highlighting any elements that may require special attention. Then ask the human if they want to review the plan before implementation begins.
    - If so, ask the human to review `PLAN.md` and `PLAN-COMMENTS.md`. Incorporate any human feedback directly into `PLAN.md`, and summarize the human feedback and changes in "Human Review Response". Repeat this step until the human approves the plan, and then proceed to Step 6.
    - Otherwise, proceed directly to Step 6.
6. A new **general-purpose** subagent should implement the changes described in `PLAN.md`. It should execute the new tests it added and if any fail, fix them, repeating this process until all tests pass. It should report any manual testing that should be done by the human.
7. After the implementation is complete, obtain the diff of all changed files (`git diff HEAD`) and pass it to a new **general-purpose** subagent along with the original user prompt and `PLAN.md`. The subagent should write any review comments and questions to `IMPLEMENTATION-COMMENTS.md`.
8. A new **general-purpose** subagent should review the feedback in `IMPLEMENTATION-COMMENTS.md` and make any changes as needed, writing a response in `IMPLEMENTATION-RESPONSE.md`.
9. Write a `REPORT.md` file that includes an executive summary of the changes and that concatenates the contents of `PLAN.md`, `PLAN-COMMENTS.md`, `IMPLEMENTATION-COMMENTS.md`, and `IMPLEMENTATION-RESPONSE.md`. Use Bash to do this concatenation; no need to read these files into your context. Delete these files, leaving only `REPORT.md`.
10. Commit all changes, excluding the `REPORT.md`. Base the commit message on the executive summary. NOTE: pre-commit hooks will run linters. If the hooks auto-fixed files, re-stage and retry; if they reported unfixable errors, investigate and fix manually.
11. Finally, output the executive summary, highlight manual review steps, and refer the human to `REPORT.md` for further reading.
