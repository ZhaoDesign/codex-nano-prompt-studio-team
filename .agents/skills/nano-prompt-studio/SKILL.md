---
name: nano-prompt-studio
description: "Orchestrate specialized scene, camera, lighting, pose, styling, prop, finish, and continuity analysis to produce a concise Chinese Nano Banana replication prompt, and optionally run a bounded PixVerse image-generation, comparison, and prompt-repair loop from the same single entry point."
---

# Image Replication Prompt

## 简短调用方式

- 首次反推：`请用 $nano-prompt-studio 反推这张照片，按旧版分段文本输出完整中文提示词，重点把穿搭和姿势写具体；如需验证，再用 PixVerse Gemini Nano Banana 2.1生成。`
- 后续修正：`请用 $nano-prompt-studio 对比目标照片和最新候选，保留已确认内容，修正画面中明确可见的差异，并输出合并后的完整分段中文提示词；如需验证，再用 PixVerse Gemini Nano Banana 2.1生成。`
- 分层验证（仅在用户明确要求时）：`请用 $nano-prompt-studio 通过 PixVerse CLI 的 Nano Banana 2 标准版，从目标模板生成“人物＋纯色底”和“无人背景”两张分析图；分别反推、验证、对照后再合并验证。无需透明背景或本地抠图，按 Skill 的分层参考图规则执行。`

这些短指令会调用完整工作流。无需在用户提示词中重复角色分工、分析细则或模型参数。只要提示词时，删去 PixVerse 验证要求即可。

## Single-entry studio orchestration

This test Skill is the only user-facing entry point for the workflow. Do not ask the user to invoke separate scene, camera, lighting, pose, styling, prop, or validation Skills. Before analyzing an image, read [references/studio-orchestration.md](references/studio-orchestration.md) and [references/agent-delegation.md](references/agent-delegation.md). When a target image is available, the initial deep path must actually spawn all seven role Agents through `multi_agent_v1__spawn_agent`, attach the corresponding standalone Skill to each Agent, wait for their completed reports with `multi_agent_v1__wait_agent`, run the continuity auditor, and only then write the final prompt. Reading a role file alone does not count as calling that role Skill.

## Per-round specialist routing (hard constraint)

The first full reverse-engineering pass uses all seven roles. Every later PixVerse comparison or repair round must use the newest candidate to build a field-level mismatch ledger, classify each mismatch, and invoke only the narrowest role that owns the mismatched field, followed by `nano-continuity-auditor`. Do not restart all seven roles for a localized repair.

Use this routing map:

- `环境、背景、门、墙面、空间层次、前景留白、背景结构` → `nano-scene-analyzer`
- `画幅、裁切、主体比例、机位、透视、镜头距离` → `nano-camera-analyzer`
- `光源形状、光源方向、软硬度、光比、阴影、曝光、色偏、环境反光` → `nano-lighting-analyzer`
- `躯干轴线、肩胯关系、关节链、头部角度、手势、支撑与接触、重心、表情` → `nano-pose-analyzer`
- `五官身份、发型身份、逐件服装结构、版型、面料、颜色、配饰及衣物褶皱` → `nano-styling-analyzer`
- `物品数量、形体、材质、相对尺寸、摆放、握持、遮挡、反射、文字` → `nano-props-analyzer`
- `颗粒、锐度、景深、饱和度、对比、质感、摄影完成度` → `nano-finish-analyzer`

Every candidate comparison must inventory all materially visible, controllable differences across the whole target frame, not only the latest user-mentioned issue. By default, repair all high-confidence, material mismatches together by invoking the union of their narrow owner roles. If the user explicitly limits this round to named fields or domains, obey that narrower scope and mark other visible mismatches `deferred`; do not silently treat them as accepted. Truly unclear differences remain `unresolved` and must not be guessed. An unresolved field does not block independent, evidence-supported repairs; pause only if no safe authorized repair can proceed or the unresolved issue makes the proposed prompt internally inconsistent.

For each mismatch, invoke its narrow owner role. If several mismatches cross domains, invoke the smallest union of roles that covers them, then let continuity resolve overlap. For example, a wrong background structure uses scene; a wrong background light pattern uses lighting; a wrong subject scale uses camera; a wrong object scale uses props. “环境不还原” must not be routed to a generic full-team restart. “灯光不还原” must go to lighting. If the mismatch is not visually classifiable, mark it unresolved and do not invent a repair.

Each repair role receives: the last accepted field ledger, the complete candidate-versus-target mismatch ledger with each item marked `repair_now`, `deferred`, or `unresolved`, the exact fields it may change, and the fields it must preserve. The role may report facts only for its assigned domain. After continuity merges the repair, the director must output a complete prompt assembled from the last accepted baseline plus only the approved delta. Deferred and accepted fields remain unchanged, but deferred fields must stay visibly tracked as unresolved work rather than being relabeled accepted. If an accepted field regresses, restore the last accepted value before the next generation.

Each role Agent returns compact visual facts, source scope, confidence, unresolved points, and direct exclusions; no role writes a competing full prompt. The final prompt is written once by the director stage after authority mapping, conflict resolution, prohibited-entity scrubbing, and the existing output checks. Use the deep path by default, the fast path only when explicitly requested, and the repair path when a supplied candidate exposes a localized mismatch. Never claim a role was executed without observing its completed Agent status. If a required role or the continuity auditor fails, do not output a normal final prompt unless the user explicitly authorizes a provisional result.

## Core Rule

Keep the analysis record separate from the generator payload. By default, return the complete prompt as one standalone fenced `text` block, divided into the prescribed Chinese sections. The block contains only direct visual instructions for the image model—no analysis summary, role reports, or generation/comparison records. When an authorized `@图1` is present, the exact fixed `@图1` preamble is a mandatory exception and must appear verbatim at the beginning of the block. Do not use JSON for the prompt unless the user explicitly requests JSON. If a PixVerse run occurred, place concise status and comparison results outside the prompt block.

Treat `@图片复刻`, `@复刻提示词`, `@反推提示词`, `@图像复刻`, and `@参考图复刻` as explicit user intent to use this skill when they appear in a prompt. In Codex, these are natural-language aliases; the formal skill invocation is `$nano-prompt-studio`.

The chat-uploaded target photo is the scene to analyze and compare, never an identity source or a prompt-validation reference. Only when the user explicitly requests staged layer generation may it be sent to PixVerse CLI as the source image for two separate Gemini Nano Banana 2.1 calls: one to generate the person and attached props on a uniform solid-color background, and one to generate the unoccupied background. These analysis-asset calls are not prompt validation and do not permit uploading the full target to any prompt-validation generation. No transparent output, alpha channel, local segmentation, or manual cutout is required. In the user's established two-image workflow, a separate current-task selfie identified as the user's identity image is assigned `@图1` and is the only image uploaded for person-prompt validation. When present, `@图1` is the sole source for the generated person's face identity and hairstyle identity as defined by the fixed preamble; the target photo and the user's explicit text control makeup, expression, pose, clothing, environment, camera, composition, lighting, visual style, and target emotion. Do not transfer any other visual information from `@图1`. If no separate selfie is present, do not create an identity binding or upload the target photo except for the two explicitly requested layer-generation calls.

Keep source-role explanations in the analysis or prose outside the copy-ready prompt. The prompt itself must describe only concrete visible scene facts and authorized identity binding; never mention an inaccessible target image or how reference uploads are handled.

When a separate current-task selfie is provided as the identity image under the user's established two-image workflow, assign it `@图1` and prepend the exact fixed preamble in `Fixed @图1 preamble` below. Copy that preamble verbatim, without paraphrase, translation, reordering, shortening, or replacement. It authorizes only face identity and hairstyle identity. Makeup, expression, pose, clothing, environment, camera, composition, lighting, visual style, and target emotion must be appended as target-scene specifications. If no selfie is present or its role is unclear, do not invent an identity binding; ask one concise question only if the role is required to proceed.

## Fixed @图1 preamble

When an explicitly assigned `@图1` is present, place this entire block at the beginning of the copy-ready prompt and preserve it exactly as written. No other prompt text may appear before this block. After the final line, append the complete target-specification sections. When `@图1` is absent, omit this block completely.

```text
上传的@图1仅作为角色身份参考。

请仅提取并保留以下属性：

1. **面部身份**：面部结构、脸型、眼睛、眉毛、鼻子、嘴唇以及独特的面部特征。
2. **发型**：头发长度、发色、发质、发际线以及整体发型轮廓。

请勿将@图1作为目标构图的来源。

请完全忽略@图1中的所有其他视觉信息，包括：

- 原始身体姿势与姿态
- 头部朝向与身体方向
- 手势与四肢位置
- 服装、配饰与造型
- 原始拍摄角度、透视与构图
- 背景、建筑与周围物体
- 原始光线、阴影、色彩分级与氛围
- 原始主体位置与空间构成

以上元素均不应被迁移、复现或对新图像产生视觉影响。

请根据以下目标规格生成一张全新的图像：

**优先级 1**：保留身份参考中的面部身份和发型。
**优先级 2**：遵循新指定的姿势、身体方向、服装、环境和构图。
**优先级 3**：遵循新指定的目标情绪与氛围，并通过人物状态、镜头关系、光影、色彩、空间和影像质感共同实现。
**优先级 4**：确保生成的图像在物理上自然、视觉上连贯。
参考图片不得决定最终图像的姿势、构图、环境或视觉布局。
最终结果必须是一个全新构建的场景，而不是原始参考照片的修改或变体。
```

When this preamble is active, the target-specification append must explicitly cover `妆容`, `表情`, `姿势`, `服装`, `环境`, `拍摄角度`, `构图`, `光线`, `视觉风格`, and `目标情绪与氛围`. These fields must come from target-scene analysis and current user instructions, never from the excluded visual information in `@图1`.

Keep the complete Chinese prompt under 4000 characters. When the image has many details, compress repeated adjectives rather than dropping high-impact scene facts, pose joints and contacts, per-garment construction, camera, lighting, key props, text accuracy, identity scope, or negative constraints.

## Object-size ratios and percentage anchors

For every visually important or error-prone object, quantify its apparent size against a visible in-frame anchor. State the numerator, denominator, and dimension being compared; use a percentage or simple ratio, such as `纸盘直径约为蛋糕底座直径的115%–125%` or `蛋糕直径约为掌宽的75%–85%`. Use same-type comparisons (width to width, diameter to diameter, height to height). If overall frame occupancy matters, state the object's approximate percentage of frame width or height separately.

Treat these as projected image proportions, not inferred real-world measurements. Estimate from visible boundaries and round to practical 5% increments or a narrow range; do not imply pixel-level precision. Account for tilt, occlusion, and perspective, and mark a ratio low-confidence or unresolved when the boundaries or anchor are unclear. Never invent a percentage merely to fill the prompt.

For a fragile object, include at least one explicit ratio to a clear anchor; include a second relation when it defines recognition, such as plate-to-cake and cake-to-palm. Preserve related geometry such as exposed margin/rim, thickness, orientation, and contact. In a generated-result comparison, record both target and candidate ratios and the relative deviation: `(candidate ratio ÷ target ratio − 1) × 100%`. Use that deviation to describe whether the object appears too large or too small, then route the correction to `nano-props-analyzer`. Keep only the decisive ratios in the final prompt so quantification improves control without bloating it.

## Clothing and pose fidelity pass

Use clothing taxonomies and pose datasets as coverage aids, not as exhaustive dictionaries or as permission to label details that are not visible. [Fashionpedia](https://fashionpedia.github.io/home/index.html) and [DeepFashion](https://openaccess.thecvf.com/content_cvpr_2016/html/Liu_DeepFashion_Powering_Robust_CVPR_2016_paper.html) organize clothing by item, parts, landmarks, and attributes; [MPII](https://www.mpi-inf.mpg.de/departments/computer-vision-and-machine-learning/software-and-datasets/mpii-human-pose-dataset) and [COCO-WholeBody](https://github.com/jin-s13/COCO-WholeBody) provide pose/activity or dense body-part landmarks. [Motion-X](https://motion-x-dataset.github.io/) is temporal 3D motion data, so use it only as a conceptual reminder that a still image shows a pose snapshot, not a recoverable action sequence.

For clothing, use three layers of analysis: (1) whole-outfit silhouette, palette, visible style/formality cues, and focal contrast; (2) every visible garment individually, including type, shape, color/pattern, construction, fit, material appearance, and length; (3) how each item is worn, layered, tucked, fastened, draped, folded, stretched, occluded, or touching the body/props. Follow the detailed item checklist and garment-part vocabulary in [references/role-styling-identity.md](references/role-styling-identity.md). Inspect only applicable visible features; do not force empty garment categories into the prompt. Anchor lengths to body landmarks such as waist, hip, wrist, thigh, knee, ankle, and shoe edge. State only what the image supports; infer neither exact fiber composition nor hidden construction. Separate garment color from lighting and environmental color cast. Describe style through visible construction and styling cues rather than a broad label alone. If a distinction is fragile, add one concise exclusion for the likely misread (for example, a knit insert must not become bare skin or a separate shirt).

For pose, trace the visible joint chain from trunk through arms and legs to hands and feet. Record screen-relative left/right, body-facing direction, torso axis and twist, shoulder/pelvis planes, head direction separately from eye gaze, each limb's segment direction and bend, palm/wrist/finger orientation, support points, and exact contacts/occlusions with props or surroundings. Use visible landmarks and spatial relations; avoid unsupported exact joint angles or hidden 3D anatomy. A still photo supports one pose state, not motion history. If clothing folds help explain a bend, pose owns the joint/contact fact while styling owns the garment shape/material and the visible deformation; invoke both only when both fields are mismatched.

On first analysis, cover these checks in the corresponding specialist reports. On repair, compare target and candidate at the outfit level, per garment, and worn-state/layering level; compare poses joint-by-joint. Name the exact changed field, and route clothing construction/material/color/fit to styling and body geometry/contact/support to pose. Do not settle for labels such as `衣服不对` or `姿势不自然`.

## First-generation fragile-feature preflight

Before the first PixVerse generation, review the merged role ledger for high-risk features that are small, ambiguous, easy for the model to reinterpret, or important to recognition. For each such feature, confirm that the prompt states the visible shape/topology, material, position, scale relationship, contact/occlusion, lighting cue when relevant, and a concise exclusion for the likely wrong interpretation. Use only applicable fields; do not add unsupported facts to complete a checklist.

Check the applicable items among: object count and silhouette; object-to-object/object-to-hand size ratios; whole-outfit layer order, per-garment construction, fit and worn state; fragile insert/layer distinctions; hand count and contact; light pattern versus a physical light fixture; cast-shadow shape and placement; background boundaries and spatial layers; crop and subject scale. The owner role supplies visual facts and the continuity auditor checks that prompt clauses do not conflict. If a critical high-risk item is missing, revise the prompt before generation. If the source does not support a reliable detail, label it unresolved and avoid inventing precision.

## Copy-ready payload and consistency gate

Before returning or sending a PixVerse-ready prompt, run these checks silently and correct detectable issues before delivery:

- The copy block contains only the complete segmented prompt. Keep analysis, source-role notes, and execution/comparison records outside it. When the user asks only for a copy-ready prompt, do not add an error list, self-review narrative, or explanation around the block unless requested.
- Resolve cross-field contradictions. Keep facial and hair identity dynamically bound to the authorized current selfie; do not describe the identity as unspecified. The binding defines source authority, not a guarantee of pixel-identical output. Omit hard-coded age, gender, body-shape, ethnicity, natural-complexion-as-identity, and beauty labels.
- State composition as absolute visible outcomes: subject position, frame occupancy, crop, camera view, and object placement. Do not leave instructions such as “move the camera back 25%” or “shrink the subject 20%” without an available baseline; translate them into final subject scale and framing.
- Every percentage range must describe one dimension against one named anchor of the same dimension. Never combine width and height in one lower/upper range. Split different size classes or measured dimensions into separate object records, and use only estimates supported by visible evidence.
- Reconcile aspect-ratio changes with the final crop and priority elements. Do not simultaneously demand an unchanged wider crop and a narrower fixed output without specifying the final framing.
- Remove duplicate or low-value prohibitions after keeping the few exclusions that protect fragile visual facts.
- Validate section coverage, authorized reference tokens, source-independent prompt wording, the 4000-character limit, and zero occurrences of `或` in the complete prompt text.

Correct detectable draft errors silently rather than presenting the user with a list of mistakes. If a genuinely blocking ambiguity remains, ask one concise question; otherwise make the safest evidence-based choice.

## Optional PixVerse closed loop

When the user asks to generate, compare, iterate, or connect PixVerse, switch from prompt-only delivery to the closed-loop mode described in [references/pixverse-closed-loop.md](references/pixverse-closed-loop.md). If the user specifically requests person/background decomposition, use that reference's opt-in staged workflow. The parent Skill remains the sole coordinator: specialist roles analyze each authorized layer and repair dimensions, the director writes the complete prompt, PixVerse generates candidates, and the parent compares each fresh result against the corresponding target layer before applying a delta. Do not ask the user to invoke a separate PixVerse or analyzer Skill.

Use the official PixVerse CLI as the execution backend when it is installed and authenticated. For this workflow, use the PixVerse image model identifier `gemini-nano-banana-2.1` for every analysis-asset, validation, and repair generation. Before each call, query `pixverse capabilities create image --model gemini-nano-banana-2.1 --json` and verify the returned query model and capability entry exactly match. Never silently substitute another model. Do not substitute another model or a guessed REST endpoint. If the CLI is unavailable, tell the user to install it and pause the requested PixVerse generation; do not silently downgrade an authorized generation request to prompt-only delivery or claim that a generation happened. Live generation consumes PixVerse credits, so run it only when the user has clearly requested generation or iteration, and use a bounded iteration budget unless the user explicitly authorizes more.

In the standard two-image ChatGPT-to-PixVerse workflow, the target photo stays in ChatGPT for analysis and comparison and is never uploaded to a prompt-validation generation. A narrowly scoped exception applies only when the user explicitly requests the two target-derived Gemini Nano Banana 2.1 analysis-asset generations described in [references/pixverse-closed-loop.md](references/pixverse-closed-loop.md): person plus solid-color background, and unoccupied background. These source-image calls are not prompt validation. For person-prompt validation, upload only the separate current-task selfie as `@图1`; for background-prompt validation, upload no reference images; for merged validation, upload only the selfie by default. Never reuse a selfie from an earlier task. A generated candidate is comparison evidence only and must never become a reference. Keep an iteration ledger containing the target, derived layer assets, prompt version, PixVerse task/result identifier, candidate path, reference-role mapping, field-level mismatches, changed fields, and stopping reason.

Never promise pixel-identical output. Stop on user approval, a clearly improving candidate within the authorized iteration budget, no meaningful improvement, a failed prerequisite, or a safety/credit boundary. A visual comparison is required before claiming improvement; text validation alone is not evidence of fidelity.

The generator payload must contain only directly actionable visual facts and applicable generation controls. Do not add a generic opening such as `按目标图复刻` or `按以下文字完整复刻目标画面`; do not mention the target image, target scene image, original image, or scene reference, and do not tell the generator to inspect or follow an unavailable image. Translate all analyzed content into concrete constraints for the subject, pose, composition, lighting, material, environment, props, text, and negative controls. An explicitly authorized `@图1` identity binding is allowed under the reference-role rules.

## Fixed aspect-ratio rule (hard constraint)

Every generated image must use the vertical `9:16` aspect ratio. Write `画幅比例：固定9:16，不可改为其他比例` in the prompt, pass `--aspect-ratio 9:16` to PixVerse, and preserve `9:16` on every repair iteration. Analyze the target image's original ratio only to adapt crop, subject scale, camera distance, and empty space; never copy its ratio into the output and never switch to another aspect ratio unless the user explicitly changes this rule.

## Default output quality rule

Use `1080p` as the default PixVerse output quality for the initial generation and every repair iteration. Do not select `2160p`, `4K`, or a higher quality setting unless the user explicitly requests it. The fixed default combination is `1080p + 9:16`.

Default reference rule: the chat-uploaded target photo controls the scene and is never relabeled as `@图1`. In the established two-image workflow, a separately supplied current-task user selfie is `@图1` and controls only the face identity and hairstyle identity defined by the fixed preamble. It must not control makeup, expression, skin tone, skin texture, head pose, body shape or pose, clothing, accessories, background, props, text, lighting, color grade, composition, camera, crop, visual style, or target emotion. Those fields must come from target-scene analysis and the user's explicit text. Only allow clothing to reference the selfie when the user explicitly says so. With no current selfie, do not add identity binding or upload any image.

## Identity-agnostic prompt rule (hard constraint)

The generated prompt must be reusable with any user's identity image: do not hard-code gender, age, sex presentation, body shape, ethnicity, natural complexion as a personal identity label, beauty descriptors, pronouns, or a target-scene person's identity details. Use neutral terms such as `主角` and `人物`. Preserve the target scene's visible pose, clothing, objects, composition, lighting, and camera without turning the scene subject into a fixed person profile. If the target scene visibly suggests a gender or age, translate it into neutral visual facts instead of writing `男性`, `女性`, a numeric age, `男孩`, `女孩`, `老人`, `年轻人`, or equivalent identity labels. The only identity-specific appearance authority is the current `@图1`, and its face and hair must be preserved dynamically from the supplied image rather than described as a fixed person.

## Dynamic identity rule (hard constraint)

Treat every explicitly assigned `@图1` as the user's current identity image, never as a reusable person profile. Re-inspect it for each task and use it only for the face identity and hairstyle identity attributes defined by the fixed preamble: facial structure, face shape, eyes, eyebrows, nose, lips, distinctive facial features, hair length, hair color, hair texture, hairline, and overall hairstyle contour. Do not let it supply makeup, skin tone, expression, skin texture, head pose, body shape or pose, clothing, accessories, camera angle, lens distance or crop, lighting, color grade, background, environment, visual style, target emotion, gender, or age. Those attributes must come from direct prompt instructions and target-scene analysis, not be inferred from the selfie. Do not copy, preserve, infer, or autocomplete concrete identity details from prior prompts, previous turns, examples, memory, the chat-uploaded scene reference, or another task.

Never write concrete hairstyle, hair-color, hair-length, or hair-endpoint labels such as `长发`, `短发`, `长黑发`, `金色大波浪`, `黑色直发`, `深棕色`, `黑色`, `金色`, `棕色`, `红色`, `白色`, `卷发`, `刘海`, 马尾, 编发, `及肩`, `及胸`, `及腰`, `垂落至胸口`, `垂落至腰侧`, or similar morphology, color, length, or endpoint descriptions. Hair color and length must never be described anywhere in the generated prompt. Always write `发型严格还原当前@图1` or `发型与发色按当前@图1完整还原` instead. Hair condition and motion effects are allowed when visible in the current image or explicitly requested in the current request, such as `湿润发丝`, `发丝漂浮`, `被风吹动`, `水面上的发丝`, `发丝高光` or `轻微散落的发丝`; these describe the current visual effect, not a fixed hairstyle identity, length, color, or endpoint. If the effect is not visible or requested, omit it rather than guessing.

The identity-binding clause states the authorized source scope; it is not a guarantee of pixel-identical output. The `发型配饰` field must use the neutral wording `发型严格还原当前@图1` and may add only currently visible or explicitly requested hair-condition effects. Do not describe hair color, hair length, hair endpoints, hair placement by body landmarks, or a concrete hairstyle shape. Before returning, remove every concrete hair-shape, hair-length, hair-color, and hair-endpoint label.

## Forbidden wording (hard constraint)

The final generated prompt must contain zero occurrences of the Chinese character `或`. Do not use `或` in any section, field value, negative constraint, priority note, or reference-binding sentence. Before returning, scan the complete prompt and replace it with deterministic wording such as `以及`, `并且`, `同时`, `均`, `；`, or separate sentences. This restriction applies to the output prompt only; it does not require rewriting this skill's internal instructions.

## Target-scene reference default (highest priority)

The image the user asks to recreate is the `目标模板` and the scene-analysis/comparison baseline for the first prompt and every later iteration, revision, correction, and prompt rewrite, even if the user calls it a reference image. Never convert it into `@图1` merely because it is the only uploaded image or contains a face. In the user's established two-image workflow, assign a separate current-task selfie to `@图1`; do not require the user to repeat this standing mapping. Do not carry a selfie or identity token forward from an earlier task.

Before analysis, classify every current image using the user's wording and the role rules in [references/reverse-checklist.md](references/reverse-checklist.md): `目标模板`, `生成引用图`, `文字分析素材`, or `候选图`. Record each image's purpose, allowed visual fields, prompt token if any, and PixVerse upload rule. When more than one image is uploaded and the user has not explicitly mapped every image to a role, list the visible attachment labels and ask which are target templates, generation references, text-analysis materials, and candidates; for every selfie, ask which target person it maps to. Pause analysis conclusions and PixVerse uploads until the mapping is clear. Never infer roles from appearance, filenames, or upload order.

Do not require clarification when the user already maps every image clearly. A single image explicitly described as the image to recreate is the `目标模板`; the established current-task selfie mapping remains `@图1` when it is unambiguous. For multiple attachments with any unmapped role, ask before treating extras as text-analysis material. A phrase such as “参考这张图的姿势/穿搭/灯光” assigns `文字分析素材` unless the user explicitly authorizes generation upload. Text-analysis materials contribute visible facts only; they receive no `@图N` token and are never uploaded. Only explicitly assigned images can be `生成引用图`, within the authorized branch and scope. Never promote a target template or text-analysis material into a validation reference. Keep tokens current to the task and never reuse stale images.

## Reference-image whitelist (hard constraint)

Before writing, build separate mappings for the target scene, any target-derived layer-generation assets, the identity source, and candidates; the identity-token whitelist starts empty. Under the user's established two-image workflow, add the current separately supplied user selfie as the sole `@图1` identity source. Otherwise add `@图1` only when the user explicitly assigns a current image to that role. In the opt-in staged workflow, a target-derived background-only asset may become `@图2` only for the merged validation when the user authorizes it to correct demonstrated background leakage. The final prompt may contain only authorized tokens.

Use the user's explicit per-image labels. The target photo remains in ChatGPT except for the two explicitly requested PixVerse CLI analysis-asset generations; a separately supplied and clearly mapped current-task selfie becomes `@图1` under the established workflow. In staged merged validation, only the target-derived background-only asset may additionally become `@图2` for the authorized exception. Do not assign another identity image to `@图2`. If multiple identities need simultaneous binding and the verified CLI mapping cannot preserve the @图2 background reservation, ask the user for a safe mapping plan before upload. Never silently treat unmapped images as text-only material when the user has not clarified their roles. The target photo may control all visible scene facts without becoming a validation reference. Do not carry a stale image or token from another task.

The target template and text-only analysis materials are converted into direct visual facts in the prompt, without image tokens or PixVerse uploads for prompt validation. A generation reference receives a token and upload only when the current user explicitly assigned that role and the relevant generation branch permits it. Keep the standing `@图1` face/hair-only scope and the staged-workflow `@图2` background-only exception; do not invent additional tokens or widen a reference's scope.

Before returning, scan the paste-ready prompt body for every `@图N` token. Remove any token that is not authorized for the current task, including tokens introduced in examples, priority notes, negative constraints, or reference-binding explanations. If a current selfie is assigned under the established workflow, `@图1` is authorized; `@图2` is authorized only for the staged merged-validation exception above. Otherwise the prompt body must contain no unauthorized reference token.

## Reusable reference state

Maintain this internal state for the current task and every revision:

- `目标模板` / `场景解析源`：the image the user asks to recreate or compare. It supplies target-scene facts and is not automatically uploaded to the generation platform.
- `文字分析素材`：a secondary image the user wants analyzed for selected visual facts. Convert only those facts into direct text; do not add an image token or upload it for prompt validation unless the user explicitly reassigns it as a generation reference.
- `身份生成源`：the separately supplied current-task selfie assigned `@图1` under the established workflow, if present. It supplies only the face identity and hairstyle identity attributes defined by the fixed preamble. Exclude its makeup, skin tone, expression, skin texture, pose, body, clothes, accessories, camera, lighting, color grade, background, environment, visual style, and target emotion.
- `人物＋纯色底分析图`：only in the opt-in staged workflow, a PixVerse-generated target-derived image containing the subject and directly held/contacting props against an opaque, uniform, contrasting solid-color background. It guides analysis and comparison; no alpha channel or manual cutout is expected, and it is not automatically uploaded for prompt validation.
- `无人背景分析图`：only in the opt-in staged workflow, a PixVerse-generated target-derived image containing the background/environment with the subject and foreground subject props removed. It guides analysis and comparison; it is not uploaded for standalone background-prompt validation. It may be uploaded as `@图2` only for merged validation when explicitly authorized to counter demonstrated selfie-background leakage.
- `候选结果`：a generated image supplied for comparison. It is evidence of mismatch, never a new reference source.
- `文字约束`：the user's explicit keep, replace, remove, and add instructions. These have priority over visual inference and stale prompt text.
- `已确认字段`：the last accepted field-level baseline. It is immutable during a repair unless the mismatch ledger explicitly names that field; a field is not accepted merely because it was left unchanged.
- `本轮差异`：the complete current candidate-versus-target mismatch inventory, including differences not mentioned by the user, with type, evidence, owner role, confidence, and status: `repair_now`, `deferred`, or `unresolved`.
- `本轮范围`：`comprehensive` by default, covering all materially visible, high-confidence, controllable mismatches; use `user-limited` only when the user explicitly narrows the round.
- `本轮角色集`：the minimal union of specialist roles owning `repair_now` mismatches. Record it before spawning repair Agents; do not restart all seven unless the evidence implicates all seven domains.

Never let a candidate result, a newly uploaded pose image, or a previously used scene image silently change another role.

## Iteration and delta-update rules

Treat every follow-up as a patch to the last accepted state:

- If the user says a new image is only for pose, replace only torso direction, shoulder and pelvis planes, lean, head angle, hand contact, finger direction, weight, and expression fields. Carry forward confirmed clothing, scene, props, lighting, crop, and style.
- If the user says to keep the previous scene, preserve every unaffected field and change only the named fields.
- If the user says to remove an object, brand, accessory, or visual element, delete its positive mentions and dependent cues from clothing, props, material, reflections, lighting, hand contact, background, and composition. Keep at most one compact negative-control clause for that prohibition.
- When a new reference role is explicitly assigned, use the latest assignment and remove superseded tokens and bindings from the complete prompt body.
- Do not regenerate a generic prompt from scratch when the user requests a localized correction; return the complete merged prompt after the patch.

## Prohibited-entity scrub

For every user prohibition, build a small internal prohibited-entity set containing the named item and its direct synonyms, material descriptions, logos, derivative patterns, contact actions, and reflection cues. Search every positive and neutral field before returning. A forbidden entity must not survive in an affirmative clause merely because it was moved into the negative list. Use one compact negative clause for the final prohibition and keep unrelated constraints unchanged.

## Platform-independent delivery

The paste-ready prompt body must stand on its own outside this chat. Do not write `聊天参考图`, `场景参考图`, `上传的参考图`, `当前图片`, or any other inaccessible source description inside the prompt body. Convert the analyzed scene into direct visual constraints. Keep the work note outside the prompt body and explicitly mark it as not for copying. The only image token in the prompt body may be an explicitly authorized generation reference such as `@图1`.

## Workflow

1. Run the intake gate first. Clarify every multi-image role and each selfie-to-person mapping; if a required model selfie is missing, remind the user to upload it and pause that target's identity-bound generation. Before any PixVerse call, check that the CLI exists and that `pixverse auth status --json` confirms login. If the CLI is missing, remind the user to install it; if explicitly logged out, remind them to run `pixverse auth login`; if auth status fails with a network/service error, report that verification failed and pause. For every create call, query `pixverse capabilities create image --model gemini-nano-banana-2.1 --json` and verify the returned `query.model` and capability entry before generating. Only then inspect the target photo as scene evidence. In the explicitly requested staged workflow, pass each target to two separate PixVerse CLI Gemini Nano Banana 2.1 calls that generate (a) the person and attached props against a uniform solid-color background and (b) the unoccupied background. These analysis-asset calls are not prompt validation. Do not require transparency, an alpha channel, local/manual cutout, or color keying, and never pass the target to prompt-validation generations. If a separate current selfie is supplied and mapped, inspect it only within its authorized identity role. If a generated candidate is supplied, label it as comparison evidence.
2. Establish the reference state and reset the identity-token whitelist for every iteration. Keep the chat-uploaded image as an analysis source, keep `@图1` optional and identity-only, and preserve the last accepted text state.
3. Select the fast, deep, or repair path using [references/studio-orchestration.md](references/studio-orchestration.md). For the default deep path, follow [references/agent-delegation.md](references/agent-delegation.md): spawn the role Agents in parallel, wait for every selected report, spawn the continuity auditor, and wait for its merged ledger before drafting.
4. On every repair round, compare the newest candidate against the target across the full frame, classify every material visible difference, and assign each `repair_now`, `deferred`, or `unresolved` status. Use comprehensive scope unless the user explicitly limits the round. Spawn the minimal union of roles for `repair_now` items; preserve but do not relabel deferred differences as accepted. A repair round without a complete mismatch ledger is invalid.
5. Apply the latest user delta before writing. Keep unchanged fields, replace only named fields, and scrub every explicitly removed entity from the merged prompt.
6. Isolate each reference role:
   - the chat-uploaded target-scene image controls the complete visible scene, including canvas ratio, crop, camera distance, angle, subject placement, pose, prop placement, text placement, foreground/background relationship, material, lighting, color, texture, atmosphere, and lens/quality feel.
   - the current-task selfie assigned as `@图1` controls only the face identity and hairstyle identity attributes defined by the fixed preamble. It must not transfer makeup, expression, skin tone, skin texture, head pose, body shape/pose, clothing, accessories, camera angle, distance/crop, lighting, color grade, background, environment, visual style, or target emotion. Makeup and all other target-specification fields come from target-scene analysis and the user's explicit text.
   - all other visual attributes come from target-scene analysis and the user's explicit text. Do not use the selfie to fill gaps in those attributes; do not encode hard-coded age or gender from it.
   - `@图1` must not control clothes unless the user explicitly requests clothing reference.
   - line art, blank faces, silhouettes, placeholders, sketches, or black outlines are structure guides only; the final result must not retain drawn, comic, or placeholder artifacts.
7. Reverse-engineer the chat-uploaded target scene using the completed selected-role reports, the continuity ledger, and the checklist in `references/reverse-checklist.md`. If a role is blocked, preserve that dimension as unresolved rather than inventing a result.
8. Resolve role conflicts using source authority, explicit user deltas, confidence, and visual evidence before writing. Do not concatenate contradictory facts.
9. Before the first generation only, run the fragile-feature preflight above. Resolve missing controllable facts from existing evidence; do not manufacture measurements.
10. Write the complete platform-independent prompt in the segmented format below. Include all applicable high-impact dimensions; omit headings that truly do not apply rather than filling them with JSON placeholders. Mark uncertain or occluded details as unknown in internal analysis, and do not guess.
11. Include a negative-control sentence or compact negative list inside the same prompt.
12. End with a compact priority order only if the user needs multi-reference control or the image is fragile.
13. If PixVerse closed-loop mode is active, execute the bounded generation/comparison/repair cycle in [references/pixverse-closed-loop.md](references/pixverse-closed-loop.md) after the complete segmented prompt is linted. If the user explicitly requests staged decomposition, follow that reference's separate person, background, and merged validation gates and reference-upload rules. Return the latest complete merged prompt. Keep candidate IDs, paths, generation status, dimensions, and comparison summaries out of the prompt block; when useful, report them in a clearly separate concise prose note.

## 分段提示词格式

默认以中文分段文本输出，不把提示词序列化为 JSON。将完整、可直接交给图像模型的提示词单独放进一个 ```text 代码块；代码块中只放生成指令，不放摘要、分析结论、参考图上传说明、模型/任务记录或对比报告。首次反推和每轮修正均使用同一组分段标题与顺序；修正时输出合并后的完整提示词，不只给局部补丁。

按画面内容填写以下分段，保持字段清晰、语句具体。没有可见依据或确实不适用的分段可省略；不要用空白占位符凑结构。

```text
【参考绑定】
当前请求明确提供身份自拍并指定`@图1`时，先原文复制本 Skill 的完整固定`@图1`前置模板，不得改写、删减、翻译或替换；随后追加以下全部目标规格。没有身份自拍时省略固定前置模板和身份绑定。

【核心主体】
写明主体类别、数量、可见特征和画面位置。只写场景支持且不固化身份的事实。

【拍摄角度与镜头】
写明拍摄角度、相机高度、画面方向、相机距离、透视、镜头关系和视线方向。

【构图】
写明9:16画幅、景别、裁切、主体在画面中的位置与占比、前后景关系、空间留白和主要物体布局。

【人物姿势、动作与表情】
按躯干轴线、肩胯关系、身体倾斜与重心、头颈角度、左右侧肢体关节链、手腕/手掌/手指方向、腿脚形状、支撑点、接触与遮挡、表情的顺序描述。左右以人物自身或画面方向明确标注；姿势以可见锚点描述，不臆造隐藏关节角度或动作历史。

【妆容】
写明底妆/肤质、眉妆与眼妆、睫毛/眼下、腮红/修容/高光、唇妆和整体妆容完成度。妆容来自目标场景分析和用户文字，不从`@图1`补全。

【穿搭、发型与配饰】
先写整体搭配关系，再逐件写可见衣物，最后说明上身状态。逐件描述适用的款式、剪裁结构、颜色/图案、版型、长度锚点、领口、肩袖、腰部、下摆、开合、口袋、装饰、材质观感、表面质感和关键褶皱；写清叠穿、塞衣、松紧、垂坠、遮挡及衣物与身体/道具的接触关系。鞋袜、包和配饰按可见内容补充。长度落到腰、臀、大腿、膝、踝、鞋口等身体位置。材质写视觉观感，不推断真实成分或被遮挡结构。遵循身份参考权限，不从目标场景推断固定五官和发型。

【道具与物品】
逐件写数量、形态结构、材质与固有颜色、表面质感、画面位置、摆放/握持、接触、遮挡和文字标记。重要物品写清同维度比例与可见锚点，例如直径对直径、宽度对宽度，并给出有证据支持的近似百分比范围。

【环境与背景】
写明场景、背景结构、材质与颜色、空间层次、前景元素及景深关系。

【光线与色彩】
写明光源方向、柔和度、光源数量、明暗反差、时间感、环境反射、阴影形状，以及整体色彩分布。

【视觉风格、纹理与画质】
写明媒介与摄影风格、白平衡与色温、高光/阴影色彩、饱和度与对比、景深、颗粒噪点、锐度、暗角、镜头效果和曝光。

【目标情绪与氛围】
写明目标情绪、目标氛围，并通过人物状态、镜头关系、光影、色彩、空间和影像质感共同实现；不得只堆叠抽象情绪词。

【文字与图形约束】
逐字写出可辨认文字、Logo和图形的位置、排版、材质、可读性及必须保留/禁止改动的内容；看不清的字不猜。

【负向约束】
只列容易发生且会破坏相似度的误读和用户明确禁止项，使用直接、简洁的排除语句。

【最终画面约束】
仅在需要时写少量优先级规则，明确最重要的比例、姿态、接触、服装结构或裁切；避免重复上文。

```

When `@图1` is authorized, the fixed preamble must be followed by explicit target-specification content for `妆容`, `表情`, `姿势`, `服装`, `环境`, `拍摄角度`, `构图`, `光线`, `视觉风格`, and `目标情绪与氛围`. These sections are populated from target-scene analysis and the user's current instructions, never from excluded visual information in `@图1`.

分段内容应写成图像模型能直接执行的具体画面事实，而不是描述分析过程。服装遵循“整套关系→逐件单品→穿着状态”；姿势遵循“躯干→关节链→手脚→支撑/接触/遮挡”。角色报告和事实账本可以使用内部结构化格式，但不得把 JSON schema 暴露给用户，也不得将分析字段混进可复制提示词。

PixVerse CLI 的 `--prompt` 必须接收与代码块内完全相同的完整分段文本，可保存为普通 `.txt` 文件后原样传入；不要转成 JSON，也不要附加角色报告或目标图片说明。若需完整反推分析，放在代码块外简洁说明；只有用户明确要求 JSON 时才另行提供 JSON 分析。

## Writing Rules

- Prefer exact visual constraints over vague style words.
- Preserve identity only from an explicitly assigned `@图1`; never borrow identity from the chat-uploaded target-scene image as an implicit `@图1`. Do not spell out a concrete hairstyle, hair length, or hair color. Treat previous prompts and prior generated outputs as stale unless the user explicitly confirms a current hair-condition or motion effect.
- For pose, trace the visible joint chain from trunk to hands and feet. Use screen-relative left/right, torso axis, shoulder and pelvis planes, head direction separately from gaze, limb-segment direction and bend, wrist/palm/finger direction, visible support, exact contacts, and occlusion. Treat a still as one pose snapshot; do not invent hidden anatomy, exact angles, or motion history. Pair fragile relations with a direct exclusion.
- For clothing, use the three-layer pass (whole-outfit relation → each visible item → worn state) in [references/role-styling-identity.md](references/role-styling-identity.md). Record applicable visible features, anchor lengths to body landmarks, and describe material by visual evidence rather than assumed fiber composition. Use the dedicated clothing section in the segmented prompt; do not compress away important garment construction. Add a compact exclusion when a small detail is easily misread.
- For light, state direction and softness before mood.
- For objects and environments, include material, inherent color, reflectivity, placement, scale, and foreground/background depth.
- For key object sizes in the `道具与物品` section, give a percentage or ratio with an explicit same-frame anchor and dimension; treat the value as an approximate projected proportion, not a physical measurement.
- For typography, include exact text, line breaks, position, material, readability, and prohibited mutations.
- For "reference but do not copy", explicitly say which attributes are borrowed and which are forbidden.
- If a conflict exists between reference images, resolve it in the final mapping and mention the precedence.
- Treat the user's latest explicit keep, replace, remove, and add instruction as a delta patch. Do not rewrite unaffected fields or reintroduce superseded details.
- When comparing a supplied generated result with a target, identify the mismatch in source-versus-result terms and edit only the affected fields. The generated result is never a reference source.
- In a PixVerse repair round, first inventory all material visible mismatches across the full frame and classify each as `missing`, `wrong`, `extra`, `shifted`, `too strong`, `too weak`, or `unresolved`, plus a scope status of `repair_now`, `deferred`, or `unresolved`. By default, repair all high-confidence material mismatches using the minimal union of owner roles. Honor an explicit user-limited scope, but retain out-of-scope differences as deferred. The presence of a candidate never authorizes a full seven-role rerun.
- A complete prompt is required after every repair, but it must be a merged prompt: last accepted baseline plus the continuity-approved delta. Never rebuild the prompt from the candidate, from a role report, or from scratch.
- If a role report proposes changes outside its assigned domain, discard those changes. If a repair causes a previously accepted field to regress, roll back that field to the last accepted ledger value and record the regression.
- When the user prohibits an object or brand, scrub its synonyms, material cues, reflections, contact actions, and logos from positive fields before adding one compact negative control.
- Do not introduce `@图1`, `@图2`, `@图3`, or other reference tokens unless the user explicitly supplies and assigns them; uploaded images alone do not authorize a token. The chat-uploaded target-scene image remains usable as the complete scene source without being renamed as a token.
- If the user uploads several images but gives no extra mapping, treat them as scene references for the requested image only, and do not assign any of them to identity or a numbered token.
- Do not mention an unrequested reference token anywhere in the prompt, including examples, priority order, negative constraints, or statements describing what a reference does not control.
- When a reference role changes, use the latest explicit user assignment and remove superseded reference tokens from the final prompt.
- Keep the segmented layout even when the prompt is short; omit genuinely inapplicable sections, but do not collapse the prompt into one unstructured paragraph.

## Verification boundary

- A complete prompt proves only that the written constraints were delivered. It does not prove visual fidelity.
- If a generated result is supplied, compare it against the target scene field by field: crop, torso axis, shoulder asymmetry, head angle, hand contact, expression, prop placement, lighting, clothing, and prohibited details.
- Report a prompt-only result as unverified. Do not claim “百分百还原” without a fresh visual comparison.

## Output Contract

For a copy-ready prompt or PixVerse handoff, return the complete prompt in one standalone fenced `text` block using the sectioned format above. Do not place a JSON object, outer analysis, role reports, task IDs, output dimensions, candidate paths, or comparison notes inside the copy block. When an authorized `@图1` is present, the exact fixed `@图1` preamble must remain inside the copy block as the first prompt content and is the explicit exception to the reference-role-note exclusion. If PixVerse generation or comparison ran, place a concise evidence-based status and the most important remaining differences after the block. Do not narrate corrected draft errors unless the user asks why.

Final reference check: the chat-uploaded target photo must never be relabeled as `@图1` or uploaded to a prompt-validation generation. It may be passed to PixVerse CLI only for the two explicitly requested Gemini Nano Banana 2.1 analysis-asset generations: person plus solid-color background, and unoccupied background. No alpha channel or manual cutout is required. The prompt may contain `@图1` only when a separate current-task selfie is supplied under the established workflow, or the user explicitly assigns a current identity image. `@图2` is allowed only for the explicitly authorized, target-derived background-only asset in staged merged validation. Remove every other unauthorized reference token, including tokens inherited from earlier iterations, examples, explanations, priority notes, or negative constraints.

Final portability check: the prompt must not contain `聊天参考图`, `场景参考图`, `上传的参考图`, `目标图片`, `目标图`, `目标画面`, `原图`, `当前图片`, `按目标图复刻`, or any other source description or instruction that refers to an image the generation platform cannot access. Convert all analyzed scene information into direct visual constraints before returning. Start with actual visual content, not a meta-instruction about reproducing a source.

Final identity check: when an authorized current-task `@图1` exists, the prompt must not invent concrete hairstyle, hair-length, or hair-color traits; bind those features neutrally to the selfie. This includes every concrete hair color word such as `深棕色`, `黑色`, `金色`, `棕色`, `红色`, `白色`; every concrete hairstyle label such as `金色大波浪`, `长发`, `短发`, `直发`, `卷发`, or `刘海`; and every endpoint phrase such as `及肩`, `及胸`, `及腰`, `垂落至胸口`, or `垂落至腰侧`. Use a neutral identity binding to current `@图1`; hair-condition or motion effects such as `湿润发丝` are allowed only when visible in the identity image or explicitly stated in the current request, and must never be carried over from an earlier task. When no authorized `@图1` exists, remove all identity-binding language instead of inventing it.

Final hair-color check: when an authorized current-task `@图1` exists, search the complete generated prompt for concrete hair-color words. Do not name a specific hair color; use only a neutral binding to current `@图1`. When no authorized `@图1` exists, do not write any identity color binding.

Final hair-length check: when an authorized current-task `@图1` exists, search the complete generated prompt for hair-length, hair-endpoint, or body-landmark phrases describing hair placement. Do not specify hair length or an endpoint; use only the neutral reference binding and permitted hair-condition or motion effects. When no authorized `@图1` exists, do not write identity hair binding.

Final identity-generality check: when an authorized current-task `@图1` exists, the prompt must remain reusable for any gender and age. Remove hard-coded gender, age, sex-presentation, body-shape, ethnicity, natural-complexion-as-identity, pronoun, and beauty-identity labels. Preserve only scene-visible, identity-independent attributes such as pose, garment geometry, prop contact, lighting, composition, and camera.

Final reference-isolation check: when `@图1` is authorized, verify that it is used only for the face identity and hairstyle identity attributes named in the fixed preamble. Explicitly reject transfer of makeup, skin tone, skin texture, expression, head/body pose, body shape, clothing, accessories, camera/view/crop, lighting, color grade, background, environment, visual style, and target emotion. Makeup and every other target-specification field must be supported by target-scene analysis or current user text. Resolve any sentence that says a non-identity attribute is `like @图1`; rewrite it as a direct target-scene visual fact or an explicit user-requested styling condition. If a visual fact is unavailable, do not fill it from the selfie.

Final wording check: count the Chinese character `或` in the complete prompt text. The count must be `0` before returning.

If information is missing but not blocking, make the most stable reasonable choice. Ask one concise question only when a required reference-role assignment is genuinely blocking; do not add an intent-conflict rule based on a particular object or example.

