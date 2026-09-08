# Multi-repository routing

Resolve every task through its workset `repository_id`, `module_id`, branch,
and generated worktree. Start the agent with the target worktree as its working
directory. If resolution or permissions fail, block the task and never write
into another repository.
