# Figma and screenshot intake

Load the supplied Figma link when available. Record the exact URL, file key,
node ID, node title, version or retrieval timestamp, and validation status in
`context/intake/figma-reference.md`.

Do not claim that a Figma screen was validated from a URL, node ID, or `Ready`
label alone. Visual validation requires authenticated access to the node or a
user-provided screenshot/export. If access is unavailable, accept an uploaded
screenshot/export and record its source, timestamp, and interpretation under
the active change intake directory. Keep the change blocked until the visual
source can be compared with the Jira acceptance criteria.

Before implementation tasks are generated, produce a field/component diff
limited to the Jira-approved scope. Any scope mismatch between Jira, Figma,
and user clarification must become an approval blocker.

## Required visual-evidence phase

The agent must perform this phase automatically during proposal validation;
it is not a user-run prerequisite:

1. Open the exact recorded source with the configured design connector. If no
   connector is available, use an authenticated browser session.
2. Capture the selected screen/node as a PNG or export under the active
   change's `context/evidence/` directory. If authenticated access is not
   possible, use a user-uploaded screenshot/export instead.
3. Record `validation_status`, `screenshot_path`, and
   `acceptance_review_path` in `context/intake/figma-reference.md`.
4. Compare every normalized Jira acceptance criterion against the screenshot
   and write a separate criterion-by-criterion review at the declared review
   path. Include the observed design evidence, result, and any mismatch.
5. Leave the change blocked when any criterion is unresolved or the design
   source cannot be inspected.

The shell validator checks that this evidence exists and has no unresolved
criteria; the agent is responsible for the visual and semantic comparison.
