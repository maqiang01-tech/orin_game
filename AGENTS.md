# Repository Backup Policy

The user requested Git backups at task closeout to prevent lost work.

## Workflow Facts Before Work

- Before workflow/Skill work or dispatch, read
  `.codex/coordination/system-version-state.json` and its bound evidence.
- This is a derived, read-only view, not another source of authority. Compare
  its `source.sha256` with the current `S_CONTROL_STATE.json` bytes. If missing
  or stale, ask S to regenerate it; do not infer approval from an old snapshot.
- Keep source version, audit result, repair status, installation and approval
  scope separate. P V1.2.1 is a candidate; historical M7 completion does not
  authorize real model calls or M8/M9. Only S writes authoritative task state.

## Git Closeout

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
