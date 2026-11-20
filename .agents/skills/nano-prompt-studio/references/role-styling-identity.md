# Role: Styling and Identity

Keep two ledgers separate: identity-source facts and target-scene styling facts.

## Identity ledger

Only an explicitly assigned current-task `@图1` may control the face identity and hairstyle identity attributes defined by the fixed preamble: facial structure, face shape, eyes, eyebrows, nose, lips, distinctive facial features, hair length, hair color, hair texture, hairline, and overall hairstyle contour. It must not supply makeup, skin tone, expression, skin texture, head pose, body shape/pose, clothing, accessories, camera/view/crop, lighting, color grade, background, environment, visual style, or target emotion. Makeup and all other target-scene styling facts come from the target-scene analysis and current user text. Keep identity-source facts separate from target-scene styling facts. Do not invent a fixed hairstyle profile from the scene image, prior prompts, or candidate results. Keep the fixed preamble and its exact-copy rule in the parent Skill.

## Styling ledger

Analyze clothing in three connected layers. Do not write a final prompt; return source-tagged visual facts compactly enough for the director to merge them.

### 1. Whole-outfit relation

Summarize only visible or strongly supported facts:

- overall silhouette (for example, fitted upper with flared lower half, oversized outer layer over narrow trousers);
- dominant, secondary, and accent colors and where each appears;
- styling character/formality only when supported by several visible cues; omit uncertain occasion or season;
- visual pairing such as short-over-long, fitted-over-wide, light/dark, matte/gloss, or structured/soft;
- garment count and layer order from inner to outer, followed by lower-body items, footwear, and accessories.

### 2. Each garment and accessory

Inventory every visible item separately. Inspect the applicable features below; note important visible distinctions without listing absent or hidden features.

**Common garment fields:** category and specific style; silhouette/fit; color and color placement; pattern type, size, and distribution; length anchored to visible anatomy; shoulder construction; neckline/collar; sleeve shape and endpoint; waist placement/contouring; hem shape; seams, panels, darts, pleats, topstitching, openings, and closure; pockets; visible decoration or text; material appearance; wear state; confidence and occlusion.

**Type-specific checks when visible:**

- **Shirt, top, knitwear:** collar/neckline and depth; placket and button arrangement; shoulder line; body ease; sleeve/cuff and whether rolled; hem endpoint and tuck state; chest pocket, print, or trim.
- **Outerwear:** jacket/coat type; shoulder and overall volume; length; lapel/collar; open/closed/fastened state; buttons/zipper/tie belt; exposed inner layers; cuffs, pockets, vents/slits, and belt.
- **Trousers:** rise; leg silhouette and width transition from thigh through knee to hem; length relative to ankle/shoe; waistband, belt loops, fly, pleats, and pockets; cuff, distressing, fading, or side stripe.
- **Skirt:** waistline and length; silhouette (A-line, straight, fitted, pleated, flared, etc. only when supported); pleats, slit, layers, asymmetry, hem width, and drape.
- **Dress or jumpsuit:** bodice versus skirt/trouser construction; waist seam/shape; neckline, straps, sleeves, and back only if visible; hem length, volume, slit, and pleats.
- **Footwear and accessories:** shoe shape, color, material appearance, heel/sole, trim/fastening; socks and relation to shoe/trouser hem; bag type/relative size/carry position/strap; belt width/buckle/tension; visible jewelry, eyewear, hat, scarf, gloves, and hair accessories.

### Garment-part vocabulary for image analysis

Use garment-construction terms to turn a broad label into observable geometry. The user's garment glossary is a terminology aid, not a visual encyclopedia or authoritative construction spec; it contains production vocabulary, inconsistent translations, and terms that cannot be verified from a photo. Prefer a short Chinese shape/location description when an English-derived label is ambiguous.

- **Neck and collar:** distinguish the neckline opening from a collar; when visible, describe collar band/stand, collar fall, points, notch, lapel, hood, tie/scarf-like extension, and neckline contour (round, V, square, boat, scoop, asymmetric, draped/cowl, halter, or strap-based). State width, depth, edge shape, overlap, and relation to the neck/chest; do not infer hidden interfacing or collar layers.
- **Shoulder and sleeve:** check shoulder seam position, yoke, armhole, sleeve crown/volume, underarm seam, sleeve length, cuff shape, cuff opening/vent, and whether a cuff is folded, buttoned, or stacked. Compare both sides for intentional asymmetry versus a visible mismatch.
- **Front opening and closure:** identify placket/button stand, center-front opening, fly/false fly, zipper, buttons, snaps, hooks, ties, or concealed closure only when the visible edges/supporting details establish them. Record opening direction and whether the garment is open, closed, or partly fastened.
- **Body construction:** inspect center-front/back and side panels, princess seams, darts, pleats (including box/inverted), gathers, tucks, smocking, topstitching, and panel transitions. Describe their visible path, direction, spacing, and effect on silhouette; do not label a fold as a sewn dart or pleat unless its construction is visually supported.
- **Pockets and lower edges:** distinguish patch, flap, welt/jetted, slanted, curved, bellows, or coin-pocket appearance by outline, opening, and placement. Check waistband/waistband extension, belt loops, belt, hem/sweep, cuffed hem, slit/vent, binding, piping, and facing when visible. Avoid naming hidden pocket bags or internal facings.
- **Fabric and surface:** distinguish visible knit from woven structure when evidence supports it; inspect ribbing, jersey-like smoothness, interlock/double-knit thickness, pile/fleece, terry loops, denim/twill diagonals, corduroy ribs, velvet-like nap, satin-like sheen, lace/openwork, jacquard pattern, tweed-like irregularity, and seersucker puckering. These are appearance cues, not proof of fiber content or manufacturing method. Describe thickness, stiffness/drape, surface relief, sheen, transparency, grain, and fold character separately.
- **Color and pattern:** use a stable base hue plus lightness, saturation, warmth/coolness, and where it appears. For stripes and checks, record orientation, scale, spacing, dominant colors, and whether they align across seams. Do not rely on the PDF's color-name translations as exact standards or confuse lighting/reflection with the garment's base color.
- **Visible condition and fit cues:** when actually present, note uneven hem/sleeve lengths, twisted legs or seams, puckering, pulled areas, loose/broken stitching, fabric shading, mismatched checks/stripes, bubbling, or an edge flipping outward. First decide whether the feature is a deliberate design, pose-caused fold, wear texture, or genuine irregularity; do not “correct” intentional asymmetry or natural wrinkles as defects.

Run this part-level scan after identifying each garment category and before compressing into the final prompt. Select only the few construction details that distinguish the target and are visible at the image resolution. For high-risk details, state both the positive geometry and the most likely false reading to exclude.

For material, report visible evidence: knit/weave/rib structure, thickness, stiffness or drape, softness, sheen, transparency, texture, grain, and fold character. Use `looks like` or `-like appearance` for uncertain material classes; never assert actual fiber content, fabric weight, lining, or construction hidden from view. Separate base garment color from illumination and reflected color. Do not identify a brand or logo unless clearly legible and allowed.

### 3. Worn state and relationships

Record how the garments sit on the person in this pose:

- snug versus ease/oversized areas; shoulder seam relative to shoulder; sleeve stacking or hanging;
- waist cinching, belt tension, full/partial/no tuck, and pulled or rolled sections;
- open/closed outerwear and exactly which inner edges show at collar, cuffs, placket, and hem;
- layering order, edge reveal, length contrast, and which garment overlaps or occludes another;
- hem against hip/thigh/knee/ankle/shoe; trouser or skirt relation to footwear;
- folds, compression, stretch, bunching, movement, asymmetry, and contact with body, hands, bag, or prop;
- areas clearly visible, shadowed, occluded, or outside the crop.

Use the person's own left/right only when the view makes it unambiguous; otherwise state `画面左/画面右`. Do not mistake a light region for a garment insert, exposed skin, or background unless edges and occlusion support that reading. If uncertain, mark it unresolved.

Clothing does not transfer from `@图1` unless the user explicitly requests it. Use category/part/attribute taxonomies as a completeness checklist, not as an exhaustive fashion encyclopedia: [Fashionpedia](https://fashionpedia.github.io/home/index.html) describes garment classes, parts, and attributes; [DeepFashion](https://openaccess.thecvf.com/content_cvpr_2016/html/Liu_DeepFashion_Powering_Robust_CVPR_2016_paper.html) includes clothing landmarks and attributes. Neither source authorizes hidden details or exact fiber labels that the image does not show.

Describe style through specific cut, layering, texture, color, and accessories rather than relying on a broad label such as “elegant” or “vintage”. For lengths and proportions, use visible body landmarks and approximate projected relations only when crop and perspective support them.

When comparing a candidate, repeat the outfit-level, per-item, and worn-state passes in the same order. Report exact target-versus-candidate differences (missing layer, neckline/closure, sleeve endpoint, hem-to-body landmark, tuck state, inner-edge visibility, fabric sheen, or pattern scale). Name the likely false reading and one concise exclusion if a small detail is fragile. Styling owns garment shape, fit, material, color, pattern, and visible folds; pose owns body joints, support, and contact. If a fold mismatch could be caused by both, request both roles. Preserve accepted garment fields during unrelated repairs.

## Output discipline

Return a compact but complete inventory in the role-report schema: one outfit-level summary, one record per visible garment/accessory with applicable features, outfit layering/wearing relations, and a short unresolved/occluded list. Mark every fact with its source and permission. Do not repeat empty checklist items or fill them with guesses. The director writes the facts into the dedicated clothing and accessories sections of the segmented prompt; preserve visible construction detail without dumping this checklist verbatim. Do not promise 100% reconstruction; maximize fidelity to visible evidence and keep unobservable facts explicitly unknown. When a prohibited accessory or brand is removed, report dependent material, logo, reflection, contact, and styling cues that must also be scrubbed.

