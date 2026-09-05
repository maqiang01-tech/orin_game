# Repository Backups

## Ownership

| Repository | Contents |
| --- | --- |
| git@github.com:maqiang01-tech/orin_game.git | Game source, configuration, planning, production/staging assets and UI captures |
| git@github.com:maqiang01-tech/spabcd-workflow.git | Workflow source, custom skills, candidate archives, tests, historical audits and project coordination snapshots |

The workflow checkout is `.workflow-repository/` under this game workspace.
It is an independent Git repository, not a submodule and not a runtime
dependency. Existing local workflow and installed Skill paths remain unchanged.

## Closeout Procedure

1. Inspect both repository statuses and remote history. Preserve concurrent work.
2. Run `tools/backup/export-workflow.ps1` with explicit project, skills and
   download roots. It copies and hashes evidence; it does not activate anything.
3. Scan the selected files with `tools/backup/scan_backup.py`, inspect staged
   changes, and run `tools/backup/verify_workflow_manifest.py` against the index.
   Commit and push the workflow repository without force. Recheck manifest
   hashes with `--revision HEAD` after commit.
4. Record the verified workflow commit in `WORKFLOW_VERSION.json`, then commit
   and push scoped game changes. Verify the remote branch SHA for each push.

The initial user-authorized backup includes existing uncommitted game work.
It is a recovery checkpoint, not a claim that those changes passed tests.

## Restore Boundaries

Clone the game repository and the workflow repository. Use the exact workflow
commit recorded in `WORKFLOW_VERSION.json`, not an unverified newer candidate.
`BACKUP_MANIFEST.json` maps workflow backup paths to their original locations
and SHA-256 values. `.gitattributes` in the workflow repository preserves source
bytes so historical evidence hashes remain valid.

Coordination JSON, approval records and task identifiers are historical
snapshots. Do not replay queues or adopt skills by cloning. Rebind machine paths
and perform the authorized recovery/review process through S before execution.
Uploaded candidate packages remain candidates, including failed audit versions.

Databases and their WAL/SHM files, credentials, Python/Godot caches and installed
third-party dependencies are excluded from loose-file snapshots. Historical
ZIP packages are preserved byte-for-byte and may contain their original test
fixtures; the scanner also checks archive members for credential indicators.
Rebuild databases through reviewed migrations; exact live database recovery is
not covered by this source-and-artifact backup.

The exporter never removes stale files from the backup checkout automatically.
It fails if a previously exported file disappears or changes during collection;
review any intended deletion as a separate Git change before continuing.
