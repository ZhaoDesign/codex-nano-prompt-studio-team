# PixVerse Closed-Loop Execution

Use this reference only when the user asks `nano-prompt-studio` to generate through PixVerse, compare a result, or iterate toward a closer reconstruction.

## Capability boundary

The official PixVerse CLI supports image creation and image editing. Use standard Nano Banana 2 with the model identifier `gemini-3.1-flash` for every image generation and repair. Never use Nano Banana 2 Lite (`gemini-3.1-flash-lite`), including as a fallback. The CLI is a programmatic interface, not proof that every image-generation route is exposed as a documented public REST endpoint. Do not invent an undocumented API URL or claim that an API-key request succeeded without an observed response.

Before a live run:

1. Check for the executable with `command -v pixverse` and check authentication with `pixverse auth status`.
2. If the executable is missing, tell the user that the official CLI must be installed, or continue with prompt-only output if they did not authorize installation.
3. If authentication or subscription/credits are missing, stop before generation and report the prerequisite. Do not retry blindly.
4. Confirm the iteration budget. For a request to generate one image, default to one initial candidate plus at most two targeted repair candidates. When the user asks to compare alternatives or select the best, use an initial batch of four candidates with the same prompt if the installed CLI supports batch count; then allow at most two targeted repair candidates by default. This caps the default at six candidates. More generations require explicit authorization.

The official CLI setup, authentication, JSON mode, and creation commands are documented in the PixVerse CLI repository. Use the installed CLI help as the final authority for flags because the service can change.

## Generation contract

The director first writes and lints the complete platform-independent Nano Banana prompt. Do not send role reports, hidden analysis, or a partial delta to PixVerse. Use a command shaped like:

```bash
pixverse create image --model gemini-3.1-flash --quality 1080p --aspect-ratio 9:16 --prompt "/absolute/path/generation-prompt.txt" --json
```

Before the first call, complete the fragile-feature preflight in `SKILL.md`. Save the complete segmented Chinese prompt as plain text and pass that exact text to the CLI `--prompt` using a local `.txt` file or stdin. Preserve section headings and wording; do not convert it to JSON, flatten it into an unstructured paragraph, or include analysis or role reports. When generating a candidate batch, keep this exact text prompt and the authorized reference input identical across the batch. Compare every candidate against the target using the same field ledger; rank target fidelity first and use the user's stated aesthetic preference as a tie-breaker. A batch helps select a stronger candidate; do not merge incompatible details from different candidates into one prompt.

In the standard two-image ChatGPT-to-PixVerse workflow, never pass the target photo to a prompt-validation generation; keep it in ChatGPT as the analysis and comparison baseline. The only exception is the user's explicitly requested pair of Nano Banana 2 standard-model analysis-asset generations: use the target as the source image in one call to generate the person plus attached props against a uniform solid-color background, and in another call to generate the unoccupied background. These calls create analysis assets and are not prompt validation. Do not require transparency or an alpha channel, and do not perform local/manual cutout or color-key removal. When a separate current-task user selfie is supplied, person-prompt validation uploads only that selfie as `@图1`; standalone background-prompt validation is text-only and uploads no reference images; merged validation uploads only the selfie by default. If no selfie is present, omit it and identity tokens. Never reuse a selfie from an earlier task. The selfie controls only the face identity and hairstyle identity attributes defined by the fixed preamble. Makeup, expression, skin tone, skin texture, pose, clothing, accessories, camera/view/crop, lighting, color grade, background, environment, visual style, and target emotion must be supplied by the complete prompt and target-scene analysis, never inferred from the selfie.

Capture the structured task or asset identifier from the command output. Wait for completion with the CLI's task command, then download the generated image into a new iteration directory. Never overwrite the target image or a previous candidate. Keep the exact command parameters, default `1080p` quality, fixed `9:16` aspect ratio, prompt version, task/result ID, and candidate path in the internal iteration ledger, not in the final prompt text. Never inherit the target image's original ratio.

## Opt-in staged layer decomposition and validation

Use this path only when the user explicitly asks to split a target into subject/background layers and validate each prompt separately. It supplements, but does not replace, the normal prompt-only or single-image closed loop.

### Source and asset roles

- `目标模板` remains the in-chat analysis and comparison baseline. Only for explicit staged layer generation, pass it as the source image to two separate PixVerse CLI Nano Banana 2 standard-model calls. This is the sole target-upload exception; never pass the full target template to any prompt-validation generation. Check the installed CLI help for the supported source-image argument and confirm the returned model is `gemini-3.1-flash`.
- `人物＋纯色底分析图` contains the target subject and props directly held, worn, or contacted by them (for example, a held cake) against a perfectly uniform, single-color matte background. Preserve the visible pose, silhouette, clothing, crop, and contact relationships. Use no gradients, texture, set pieces, or extra objects in the matte. Choose a solid color that contrasts clearly with the subject's hair, clothing, and edges. The background is intentionally opaque; transparency and an alpha channel are not required. Use this output to inspect pose, clothing, identity-independent appearance, object contact, and crop. Do not automatically upload it for prompt validation.
- `无人背景分析图` contains the scene/background with the person and foreground subject props removed. Reconstruct newly exposed areas conservatively from visible context; mark areas that were fully occluded and cannot be established from evidence as uncertain rather than treating generated reconstruction as ground truth. Use it to inspect background geometry and for offline comparison; do not upload it for standalone background-prompt validation.
- Visually verify both outputs for completeness and unwanted additions. Do not run local segmentation, manual cutout, alpha extraction, or color-key removal. Compare each image directly with the corresponding target regions, aligned by frame and crop; side-by-side comparison is sufficient. An overlay is optional and must not depend on removing the solid matte.
- Save the source, both generated analysis assets, their PixVerse task IDs, and validation candidates separately. Never overwrite the target or a prior asset. If the CLI cannot accept the source image or the generated layers materially alter the visible pose/background, report that limitation; do not silently substitute a local cutout or an unrelated workflow.

### Independent prompt branches

1. Analyze the person layer and background layer as separate evidence tracks. Build a complete subject prompt and a complete background prompt; keep subject, pose, clothing, attached props, camera/framing, background, and lighting facts in their correct owner fields. Do not let the model identity image become a source for target pose, clothing, or environment.
2. Validate the subject prompt using only the current user selfie as `@图1`, when one is provided. Do not upload the full target template, person-plus-solid-color analysis image, or unoccupied-background analysis image. If no selfie is supplied, validate without image references.
3. Validate the background prompt as text-only: upload no reference image at all—neither the model selfie, full target, nor generated unoccupied-background image. The background analysis image remains available only for analysis and comparison.
4. After each candidate, compare the generated result against the corresponding target-derived analysis image and visible target regions. Align frame and crop for diagnosis; direct side-by-side comparison is the default, and overlays are optional only when they do not require cutting out the solid matte. Treat any overlay as diagnostic evidence, not a standalone numerical fidelity score. For background candidates, compare exposed/unoccluded background and the generated unoccupied-background image; for subject candidates, compare pose, clothing, attached props, and crop.
5. Maintain separate accepted-field ledgers and mismatch ledgers for subject and background branches. Preserve accepted fields, repair all high-confidence mismatches by the narrowest role set, and rerun only the affected branch. Do not combine the branches until each has no material high-confidence mismatch under the user's acceptance threshold, or the user explicitly chooses to proceed with known differences.

### Merged validation

1. The director reconciles the two accepted prompts into one complete prompt. Do not concatenate them blindly: resolve duplicate or conflicting camera, framing, subject placement, lighting, depth, color, and occlusion clauses, and preserve the original interaction between subject and environment.
2. For the default merged validation, upload only the current selfie as `@图1`; do not upload the full target, person-plus-solid-color analysis image, or unoccupied-background analysis image. If comparison shows the selfie’s original background materially pulling the result away from the approved target background, and the user has authorized this staged workflow, the generated unoccupied-background image may additionally be supplied as `@图2`. Bind `@图2` exclusively to background structure/surfaces/decor and explicitly forbid it from controlling the person, identity, pose, clothing, or attached props. Use the installed CLI help to verify multi-image syntax and token order; never guess the mapping.
3. Compare the merged candidate against the full target with aligned overlays and the full-frame mismatch ledger. Preserve approved person/background fields; invoke only the owner roles for material mismatches. If the optional `@图2` causes person/background conflicts, remove it and return to prompt-only background constraints or ask the user before changing the approved reference plan.

### Staged iteration budget and completion

The existing default applies separately to each requested validation branch: one initial candidate plus at most two targeted repair candidates for subject, background, and merged validation. This is a maximum of nine prompt-validation generations, plus the two requested analysis-asset generations; do not exceed it without explicit user authorization. Track each phase's spend and stop on user acceptance, the stated visual threshold, exhausted budget, repeated lack of improvement, or a verified model/reference limitation. Never promise literal pixel identity. Report each phase separately and distinguish an analysis asset from a validated prompt or an actually completed validation generation.

## Comparison and repair

After each fresh candidate is available, compare the ChatGPT-held target scene and the candidate in this order:

1. canvas ratio, crop, subject scale, camera distance, and perspective;
2. torso axis, shoulder/pelvis planes, joint chains, head/gaze direction, support, hand shape, contact points, and expression;
3. each garment's construction, layering, fit, length against body landmarks, material/color/pattern, folds, and accessories; then object count, placement, and text;
4. key-light direction, shadow geometry, exposure, color cast, and environmental reflections;
5. background structure, depth layers, sharpness, grain, saturation, and other finish cues.

Classify each difference as `missing`, `wrong`, `extra`, `shifted`, `too strong`, `too weak`, or `unresolved`. Route it to the narrowest owner role using the existing repair map. Then:

- preserve every accepted field that is not implicated by the mismatch;
- for object-size mismatches, compare the same projected dimensions in target and candidate against the same anchor, record both ratios and their relative deviation, and state which object appears too large or too small;
- record the last accepted baseline, the mismatch ledger, the exact `change_allowed` fields, and the frozen fields before dispatch;
- spawn only the affected specialist role(s) and then the continuity auditor; never restart all seven roles for a localized repair;
- route environment/background structure to scene, physical light/shadow/exposure to lighting, framing/scale/perspective to camera, and object geometry/material/relative size/contact to props;
- require each selected role to analyze only its assigned mismatch and reject any proposed change outside `change_allowed`;
- reject any continuity merge that changes a frozen field, restoring that field from the last accepted baseline;
- merge the repair as a complete new prompt, not a patch fragment;
- rerun the final reference-token, portability, prohibited-entity, and zero-`或` checks;
- generate the next candidate only if the revised prompt is materially different and the iteration budget remains.

Do not start a new generation round without a completed mismatch ledger and completed selected-role reports. If the visual difference is unresolved, preserve the last accepted prompt and stop unless the user explicitly authorizes a provisional repair.

The candidate is evidence of error, never a reference source. Do not copy a candidate's accidental face, clothing, object, color, or composition into the next prompt unless it is independently supported by the target or explicit user text.

## Stopping and reporting

Stop when one of these is true:

- the user accepts the candidate;
- the candidate is visually close enough under the user's stated threshold;
- the authorized iteration budget is exhausted;
- two consecutive iterations show no meaningful improvement;
- PixVerse fails, lacks credits, or the local result cannot be retrieved;
- a remaining mismatch is caused by model/reference limitations rather than prompt wording.

Keep the actual evidence level in the internal iteration ledger:

- `提示词已生成，未验证` when no candidate was rendered;
- `已生成并完成一次视觉对比` when one candidate was inspected;
- `已完成 N 轮迭代，仍有以下差异` when the budget or model limit stops further work;
- `用户确认接近目标` only after the user explicitly accepts the result.

Return the latest complete merged prompt in a standalone fenced `text` block; never emit only a partial prompt patch or wrap it in JSON. Do not put summaries or generation records inside the prompt. In the standard workflow, the CLI receives only this exact segmented text and the authorized current selfie, when present; the target remains in chat. The opt-in staged workflow uses the separate upload rules above, including text-only background validation and the conditional `@图2` merged-validation exception. When generation or comparison ran, report the actual model, returned dimensions, result status, and only the most important remaining differences in a clearly separated concise prose section after the code block. Never merge that report into the prompt block. Do not narrate corrected draft errors unless the user asks why.

Do not say `百分百还原` or `一模一样` based only on a prompt, a similarity score, or a successful CLI status. The loop optimizes visual convergence; it cannot guarantee pixel identity from a stochastic generative model.

