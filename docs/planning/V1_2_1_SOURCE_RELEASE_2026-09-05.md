# V1.2.1 Source-Based Candidate Release

Date: 2026-09-05
Status: built and verified; not installed or activated.

## Source

The user clarified that the supplied V1.2 ZIP is the source of truth after the
typed source directory could not be found. The original archive was verified:

- Input: D:/Users/Administrator/Downloads/spabcd_p_game_design_ui_experience_skill_v1_2.zip
- Input SHA-256: 36c4ff5617270339c64bf42c47626c75bc9e43a590190eecc6b9cc1750ddabd3
- Working source: D:/GameDev/YiShiChenHuan/.spabcd/src/spabcd_p_game_design_ui_experience_skill_v1_2/

The previously reviewed repair was applied to a fresh extraction using patches.
Verification was rerun from this source directory; earlier reports were not
used as evidence of this release passing.

## Scope

1. Automatic SQLite Verified/Stable retrieval with strict compatibility and source-lineage filtering.
2. Off/shadow/active injection; default shadow when using a database.
3. Hashed Retrieval Result and Injection Record; applied usage requires bound worker feedback.
4. Executable C-WF review and strongly bound approval, plus adoption-time re-audit.
5. Clean success, caveated success and harmful outcome handling.
6. Unresolved caveats prevent stable promotion; independent-task quality/counts resist retry inflation.
7. Refinement candidates stored in SQLite with a validated export artifact and new-identity requirement.
8. Revised Real Canary Gate A / Gate B plan; three tasks do not guarantee stable promotion.
9. Additive and repeatable migration 008, tested on temporary databases only.
10. Negative tests for identity collisions, unsafe evidence, compatibility, state, path/risk and binding failures.

This pass also made the clean-success threshold settings effective in both
promotion and C-WF. Stricter settings apply; legacy aliases cannot weaken the
required minimums. The old Canary plan was replaced, not merely supplemented.

## Verification

- package_check before and after full tests: PASS.
- Original 16 regression groups: PASS.
- Hardening unittest cases: 29 passed.
- Runtime: bundled Python 3.12, isolated PyYAML/jsonschema dependencies.
- ZIP CRC and per-file SHA-256 readback: PASS, 202 files.
- CHANGE_LIST.json records 17 additions and 36 modifications relative to V1.2;
  its own file and the generated manifest are excluded to avoid recursive hashes.

## Deliverables

- Candidate: D:/GameDev/YiShiChenHuan/.spabcd/candidates/spabcd_p_game_design_ui_experience_skill_v1_2_1_source_release.zip
- Candidate SHA-256: 517424d6b3643cdf24904e3e5efee82bb7ae7b4ef31a619e2a82d464946ad152
- Receipt: same directory, spabcd_p_game_design_ui_experience_skill_v1_2_1_source_release.receipt.json
- Source reports: HARDENING_TEST_REPORT.json and CHANGE_LIST.json.
- Package contents include RELEASE_MANIFEST.json, manifest.sha256, migration 008 and both Canary/hardening guides.

## Boundaries

Installed active skills, active current.json, Production and formal project
databases were not modified. Test databases and simulated pointers were temporary.
The engineering candidate remains SHADOW_READY/A3 with production_enabled=false.
No real Canary, adoption decision, worker activation or business-task resumption
is implied. Hash integrity does not authenticate a human decision; S and the
authorized C-WF/user approval process remain required.

The older isolated archive is retained as historical evidence; this document
identifies the new source-based candidate. Further execution requires explicit
user instruction through S.
