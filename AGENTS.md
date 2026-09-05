# Repository Backup Policy

The user requested Git backups at task closeout to prevent lost work.

- Game repository: git@github.com:maqiang01-tech/orin_game.git.
- Workflow/skill repository: git@github.com:maqiang01-tech/spabcd-workflow.git.
- Local workflow checkout: .workflow-repository/ (excluded from the game repo).
- Use tools/backup/export-workflow.ps1 to snapshot workflow sources, custom
  skills and review evidence without moving or changing installed sources.
- At future task closeout, commit and push scoped changes to the appropriate
  repository, after checking the staged diff and scanning for credentials.
  Do not include unrelated concurrent changes without authorization.
- Record the workflow commit in docs/backup/WORKFLOW_VERSION.json when the
  workflow snapshot changes. Report push failures; never claim an upload based
  only on a local commit. Never force-push or overwrite remote work.
- A backup commit is not a release, approval, installation or activation.
  Preserve S/C-WF/user gates, business pauses and Production restrictions.
- Do not upload credentials, dependency caches, live databases or database
  sidecars. Preserve excluded local files; do not delete them during backup.
- Read docs/backup/REPOSITORIES.md before changing the backup layout.
