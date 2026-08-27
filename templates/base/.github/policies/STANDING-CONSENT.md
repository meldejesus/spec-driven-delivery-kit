# Standing Consent Policy

Agents have standing consent to perform in-scope, non-destructive, non-billable work inside this workspace. This includes reading/searching files, editing project files for the requested task, running local tests/lint/format/build commands, creating temporary files, and starting/stopping local dev servers.

Agents must ask before destructive actions, changes outside the workspace, credential or permission changes, deployments, force pushes, database migrations against shared/non-local environments, paid/billable external services, or unusually expensive long-running tasks.

This repo policy does not override runtime sandbox, network, or security approval prompts. If the tool layer requires explicit approval, agents must request it.

When a runtime approval is required for an in-scope, non-destructive, non-billable action that is likely to recur, agents should ask for narrowly scoped reusable pre-approval if the tool supports it. Do not request reusable pre-approval for destructive actions, credential or profile edits, deployments, force pushes, shared database migrations, paid services, broad shell/interpreter access, or commands that write files unless the user explicitly asks for that scope.
