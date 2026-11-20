# Reverse-Engineering Checklist

Use this checklist internally when turning uploaded reference images into a replication prompt. The final prompt must surface these as short labeled clauses inside fixed sections, not as hidden analysis. Do not output the checklist unless the user asks.

## Reference Role Separation

- Classify every current image before analysis. Keep an internal source map with: image/source name, role, purpose, allowed visual fields, prompt token, and upload rule. Assign roles from the user's words and established workflow, never from appearance, filename, or upload order.
- **目标模板**：the image the user wants recreated or compared. It supplies the complete visible target scene—composition, pose, clothing, background, props, lighting, color, material, camera, crop, and atmosphere. Analyze and compare it in chat, then convert observations into direct prompt text. Do not include it as an image token or upload it to prompt-validation generation. The only upload exception is its explicitly requested use as the source for the two staged analysis-asset generations.
- **生成引用图**：an image explicitly assigned by the user for attachment to an image-generation request, with a current `@图N` token and a defined scope. Include the token and upload the image only in branches allowed by the current workflow. Under the established two-image workflow, the current selfie is `@图1` and follows the fixed face/hair-only preamble. In staged validation, the generated background image may be `@图2` only for merged validation when authorized and only for background facts. Do not invent tokens or expand an image's assigned scope.
- **文字分析素材**：an image the user wants inspected for selected facts, such as pose, clothing, lighting, material, or composition, without asking to attach it during generation. Convert only those observed facts into direct prompt text. Do not place its image token in the prompt and do not upload it to PixVerse. “参考这张图的姿势/穿搭/灯光” defaults to this text-only role; “把这张作为@图N” or “生成时上传/引用这张图” explicitly requests a generation reference, subject to the workflow's allowed mappings.
- **候选图**：an output being compared against the target. It supplies mismatch evidence only and never becomes a generation reference by itself.
- Default assignment without interrupting the user: the image identified by “复刻/还原/目标模板” is the target template; the separately supplied current selfie is `@图1` under the established workflow; every other unmapped image is text-only analysis material. Never promote an image to a generation reference merely because it is called “参考图,” appears to contain a useful feature, or was uploaded second.
- Keep the target template distinct from `@图1`, even when it contains a face. Under the established two-image workflow, the current selfie controls only the face identity and hairstyle attributes defined by the fixed preamble. The target supplies all other visible scene facts. Unmapped extra images stay text-only analysis material; do not stop for routine role clarification.

- When `@图1` is authorized, copy the complete fixed `@图1` preamble from the parent Skill verbatim before all target specifications. Do not replace it with a shorter identity sentence.

## Source, State, And Delivery Separation

- Keep internal labels for `目标模板`, `生成引用图`, `文字分析素材`, `候选图`, and current `文字约束`. A candidate never becomes a reference source; a text-only analysis image never becomes a generation reference without an explicit role assignment.
- In the standard two-image ChatGPT-to-PixVerse workflow, keep `场景解析源` in ChatGPT and upload only the current selfie as `身份生成源`/`@图1` for person-prompt validation. Never upload the target photo to a prompt-validation generation. The sole exception is the explicitly requested pair of PixVerse CLI Nano Banana 2 standard-model calls that generate a person-plus-solid-color-matte analysis image and an unoccupied-background analysis image from the target; these calls are not prompt validation. No transparency, alpha channel, local segmentation, or manual cutout is required. Standalone background-prompt validation uploads no image references.
- In the opt-in staged workflow, the person-plus-solid-color image is an analysis/comparison source, not a prompt-validation reference. The generated unoccupied-background image is also analysis-only for standalone validation; it may be assigned as `@图2` only in merged validation to address demonstrated selfie-background leakage and only within its background scope.
- Keep the final scene description identity-agnostic: use `主角`/`人物` and do not hard-code gender, age, body type, ethnicity, pronouns, or beauty descriptors from `@图1`. Preserve scene facts from the target, while the current `@图1` supplies only the face identity and hairstyle identity defined by the fixed preamble. Never borrow makeup, skin tone, skin texture, expression, or any non-identity scene fact from `@图1`.
- Record the target image's original ratio only for crop and subject-scale analysis. The final prompt and every PixVerse generation must be fixed at vertical `9:16`.
- For every visually important or fragile object, record apparent size as a percentage or simple ratio against a named in-frame anchor, with numerator, denominator, and dimension explicit. Compare like dimensions and treat the value as projected image proportion, not real-world size; use practical 5% increments or a narrow range, and mark uncertainty when perspective, occlusion, or unclear edges prevent a reliable estimate.
- For fragile props, record object-to-object and object-to-hand ratios plus relevant frame occupancy: for example, plate diameter as a percentage of cake-base diameter, cake diameter as a percentage of palm width, and exposed rim width as a percentage of plate diameter. Preserve edge morphology, thickness, curvature, material response, and support contact. A generic category such as `浅盘` is insufficient when paper, ceramic, glass, metal, or tray form changes the image.
- When comparing a candidate, record the target ratio and candidate ratio, calculate relative deviation `(candidate ratio ÷ target ratio − 1) × 100%`, and route a size mismatch to props. Do not use an unanchored percentage or pretend an estimate is physically exact.
- For every revision, record what is kept, replaced, removed, and added. Apply only the latest delta and carry forward unaffected accepted constraints.
- If a new image is assigned only to pose, replace pose anatomy and contact relations only; preserve clothing, environment, props, lighting, crop, and style.
- If an object or brand is removed, scrub its names, synonyms, materials, reflections, logos, and contact actions from affirmative fields before adding a compact negative control.
- The paste-ready prompt must be platform-independent. Convert the analyzed scene into direct visual text and keep chat-only source descriptions outside the prompt body.

## First-generation Fragile-Feature Preflight

Before the first generation, check every applicable high-risk feature against the role reports and prompt: object count and silhouette; object-to-object and object-to-hand ratios with named anchors; clothing construction; hand count and contact; light pattern versus a physical fixture; cast-shadow shape; background boundaries; and crop/subject scale. Confirm the prompt names measurable geometry/material/placement and excludes the likely wrong interpretation where it matters. Resolve missing facts only from visible evidence or explicit user text. Keep uncertain ratios approximate or unresolved; never invent precision.

## Composition And Camera

- Ratio and orientation: 4:3, 16:9, 3:2, 1:1, 9:16, vertical or horizontal.
- Shot size and crop: close-up, bust, waist, thigh, full body, wide, extreme wide.
- Camera angle and distance: eye level, low angle, high angle, top-down, near/far.
- Perspective: wide-angle distortion, normal lens, telephoto compression, visible perspective deformation.
- Subject placement: centered, thirds, diagonal, gaze direction, body direction.
- Foreground/background: occlusion, depth layers, background clarity, object placement.

## Lighting System

- Direction: frontal, side, side-back, backlight, top light, bottom light; state where shadows fall.
- Hardness: hard light with sharp shadow edges, or soft light with gradual transitions.
- Light count: key, fill, rim, ambient; visible highlights and shadow groups.
- Light ratio: high contrast, low contrast, bright/gray/dark overall key.
- Time and source: dawn, golden hour, noon, dusk, night interior, window, neon, flash, practical lamp.
- Color of light and environment light: warm, cool, neutral, colored bounce, reflected tint.
- Treat lighting as a top replication priority; pose alone is not enough.

## Human Pose Anatomy

Use pose datasets as a coverage reminder rather than a closed catalogue: [MPII](https://www.mpi-inf.mpg.de/departments/computer-vision-and-machine-learning/software-and-datasets/mpii-human-pose-dataset) annotates body joints across everyday activities; [COCO-WholeBody](https://github.com/jin-s13/COCO-WholeBody) covers dense visible landmarks for body, feet, face, and hands; [Motion-X](https://motion-x-dataset.github.io/) represents temporal 3D motion. A single photo establishes only visible projected pose facts, not hidden anatomy or motion history.

Analyze the body in this order:

1. Torso and weight
   - spine direction; front-facing, three-quarter, side-facing, or twisted.
   - shoulder plane and pelvis plane: parallel, rotated, tilted, one high/low.
   - body lean: left/right, forward/backward.
   - weight-bearing foot or seated support point. If weight is wrong, the pose looks false.

2. Head and neck
   - neck forward/back, side tilt, tension.
   - head turn left/right, head pitch up/down, chin raised/tucked.
   - eye gaze direction separately from face direction.

3. Upper limbs
   - shoulder height, forward roll, open/back position.
   - upper arm direction: forward, side, backward, raised/lowered.
   - elbow angle: acute, right angle, obtuse, nearly straight.
   - forearm rotation and palm direction: up, inward, outward, down.
   - wrist bend and finger curvature/spacing.

4. Lower limbs
   - standing: pelvis tilt, thigh spread, knee direction, weight leg, relaxed leg, calf and foot angle.
   - seated: hip position, thigh-ground angle, knee separation, lower-leg fold, foot placement.

5. Compression and stretch
   - bends create skin/fabric compression; twists compress one side and stretch the other.
   - use garment wrinkles to validate joint rotation.

6. Expression
   - brow height, brow tension, eyelid openness, eye shape, mouth opening, lip tension, mouth-corner direction.

Trace the visible joint chain from torso to each hand and foot. Use screen-relative left/right consistently, visible landmarks, and explicit spatial relations for fragile poses: torso axis, shoulder and pelvis planes, head turn, chin pitch, each limb segment and bend, palm/wrist/finger direction, exact contact point, support, and occlusion. Separate face direction from eye gaze. Distinguish firm support from a light touch; if the weight-bearing point is hidden, mark it unresolved. Estimate joint angles only when evidence supports it. Note garment compression as a clue, but do not let pose analysis change garment construction/material owned by styling. Pair fragile positive relations with direct exclusions.

## Clothing Construction And Material

Use [Fashionpedia](https://fashionpedia.github.io/home/index.html) and [DeepFashion](https://openaccess.thecvf.com/content_cvpr_2016/html/Liu_DeepFashion_Powering_Robust_CVPR_2016_paper.html) as classification/attribute coverage frameworks, not exhaustive lists of every style or permission to guess hidden details.

Analyze the outfit in three layers; use the detailed role checklist in `role-styling-identity.md` for the complete pass:

1. **Whole outfit:** overall silhouette; dominant/secondary/accent colors and placement; visible style/formality cues; fitted/loose and long/short contrasts; layer order from inner to outer, bottoms, shoes, and accessories. Do not infer season/occasion or rely on a style label without visible supporting details.
2. **Each garment/item:** inventory all visible tops, inner layers, outerwear, bottoms, dresses/jumpsuits, footwear, socks, bags, belts, jewelry, eyewear, and other accessories. For each applicable item check category, silhouette/fit, color blocking, pattern type/scale/placement, length, neckline/collar contour and visible collar parts, shoulder seam/yoke/armhole, sleeve/cuff/vent, waist/waistband, closure/placket/fly, seams/panels/darts/pleats/gathers, pocket outline/opening, hem/sweep/vent, visible trims/text, material surface, and wear state. Apply specialized checks: shirt placket/buttons and tuck; outerwear lapel/fastening and exposed inner layer; trouser rise and thigh-to-hem width; skirt waist/length/pleats/slit/drape; dress bodice/waist/lower construction; shoe heel/sole/fastening and relation to hems. Use the detailed visual vocabulary and visibility limits in `role-styling-identity.md`; do not infer hidden sewing construction from terminology alone.
3. **Worn state and coordination:** snug/ease areas; shoulder-seam placement; sleeve stacking; waist/belt/tuck state; outerwear open/closed state; exact edges of inner layers that show; overlap/occlusion; hems against waist/hip/thigh/knee/ankle/shoe; pose-caused folds/stretch/bunching; asymmetry; contacts with body/props; visible versus cropped/shadowed/hidden regions.

For material, state visual evidence (knit/weave, ribbing, thickness, stiffness/drape, sheen, transparency, texture, pattern scale, and fold character), not assumed fiber composition, fabric weight, lining, or hidden construction. Separate base garment color from lighting/reflected tint. Use anatomy landmarks to estimate length only when crop and perspective support it. Use the person's own left/right only when clear; otherwise say screen-left/screen-right.

Do not infer exact fiber content, hidden closures, unseen garment edges, or a complete style era from a generic appearance. Do not treat a light patch as an insert, bare skin, or background unless edges/occlusion resolve it; otherwise mark unresolved. Contrast target and candidate by exact garment field rather than saying only “clothes differ”; preserve unaffected fields and add a short exclusion for a likely confusion when it materially affects the image. Maximize fidelity to visible outfit evidence, but never promise 100% reconstruction from a photo or prompt.

## Subject, Clothing, Props

- Pose, expression, hair, three-layer clothing analysis (whole outfit, each item, worn state), and accessories.
- Props: exact placement, orientation, grip, contact points, quantity, and apparent size ratios in percentages against named visual anchors.
- Environment objects: furniture, walls, surfaces, tabletop items, relative distance, occlusion.

## Materials And Environment Reflection

- Inherent color versus photographed color: warm light on a white wall does not make the wall inherently yellow.
- Reflective materials: metal, glass, mirror, polished wood; highlight shape and reflected source matter.
- Matte materials: fabric, matte wall, paper, plaster; soft highlights, weak reflections.
- Translucent materials: curtains, gauze, thin cloth, frosted glass; describe transmitted light.
- Rough materials: cement, old wood, woven fabric; texture affects shadow transition.
- Environment color spill: red wall warms skin, green sofa tints shadows, blue floor bounces into chin/neck.
- Object layout: relative positions, scale, density, blank space, front/back layers, object state.
- Background: material, color, texture, stains, scratches, wear, brightness relative to subject.
- Foreground: leaves, glass, curtain, railing; may cause blur, haze, color cast, refraction.

## Color, Exposure, Quality

- White balance and temperature: warm yellow, cool blue, neutral white.
- Hue shifts: shadow tint and highlight tint.
- Saturation: vivid, muted, faded.
- Contrast and tonal range: highlights, midtones, shadow openness or crushed blacks.
- Exposure: overexposed highlights, dead blacks, bright key, dark key, middle key.
- Depth of field: what is sharp and what is blurred.
- Grain/noise: clean digital, fine grain, coarse film grain.
- Sharpness: crisp, soft, glow, diffusion.
- Lens effects: vignette, flare, chromatic aberration, light leak, filter, motion blur.

## Mood

After the hard facts, capture the feeling: cold, retro, melancholic, bright, distant, intimate, luxurious, commercial, documentary, cinematic, airy, humid, dusty, quiet, tense.

## Mandatory Prompt Labels

The final prompt must include these fixed section headings and labels, each with a concise value or `无明显` / `不适用`:

### 【参考绑定】

- 当前任务提供自拍并采用双图流程时，先原文复制父 Skill 的完整固定`@图1`前置模板，不得改写、删减、翻译或替换；随后追加所有目标规格
- 没有当前自拍时，不追加身份绑定或参考标记

### 【构图与画面结构】

- 画幅比例
- 竖横版
- 景别
- 裁切位置
- 机位角度
- 镜头距离
- 透视
- 主体位置
- 视线方向
- 前景/背景

### 【光线系统】

- 光源方向
- 软硬光
- 光源数量
- 光比
- 环境光与时间
- 光源色彩/环境反光

### 【人物姿态与表情】

- 躯干
- 肩线/胯线
- 身体倾斜
- 重心
- 头颈
- 脸部朝向
- 俯仰/下巴
- 眼神
- 肩膀
- 大臂
- 肘关节
- 小臂/掌心
- 手腕/手指
- 下肢/脚
- 身体挤压拉伸
- 表情

### 【妆容】

- 底妆/肤质
- 眉妆与眼妆
- 睫毛/眼下
- 腮红/修容/高光
- 唇妆
- 妆容完成度

### 【主体造型与道具】

- 服装造型
- 发型配饰
- 道具
- 环境物体

### 【环境、材质与空间关系】

- 道具固有色/材质
- 材质反光
- 环境色彩互反射
- 道具摆放关系
- 背景材质与色调
- 前景元素

### 【色彩、曝光与画质】

- 白平衡/色温
- 高光/阴影色相
- 饱和度
- 对比
- 景深
- 颗粒/噪点
- 锐度
- 暗角
- 镜头特效
- 曝光层次

### 【视觉风格】

- 媒介/摄影类型
- 影调与黑位
- 纹理与表面质感
- 清晰度与光晕
- 风格锚点

### 【目标情绪与氛围及负向约束】

- 目标情绪
- 目标氛围
- 情绪实现关系：通过人物状态、镜头关系、光影、色彩、空间和影像质感共同实现
- 负向约束

## Common Failure Shields

- Do not mix identity, pose, clothing, background, and style across unrelated references.
- Do not preserve sketch lines, blank faces, white placeholder bodies, or black outlines from control images.
- Do not copy a reference that was explicitly only a style guide.
- Do not ignore light direction, material reflectivity, environment color spill, foreground blur, or object scale.
- Do not put `聊天参考图`, `场景参考图`, `上传的参考图`, `当前图片`, or another inaccessible source description in the paste-ready prompt body.
- Do not treat a generated candidate as a reference, and do not claim visual fidelity from text validation alone.
- Do not exceed 4000 characters in the final prompt.
