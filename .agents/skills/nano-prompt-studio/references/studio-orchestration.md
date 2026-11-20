# Nano Prompt Studio Orchestration

Use this file when `nano-prompt-studio` handles a complex reference photo, several visible objects, fragile body geometry, multiple reference images, or a supplied candidate result. It defines the internal studio workflow. Do not expose the role reports unless the user asks for an analysis report.

When a multi-image upload lacks an explicit per-image role map, pause to ask before analysis or upload; missing required identity selfies must be requested before identity-bound generation. Before each PixVerse image call, verify login and the exact Gemini Nano Banana 2.1 capability response.

For the actual multi-Agent execution contract, read [agent-delegation.md](agent-delegation.md). The role references below describe domain behavior; `agent-delegation.md` defines the required spawn, wait, audit, and synthesis stages.

## Operating principle

The user invokes one Skill: `nano-prompt-studio`. Internally, the Skill behaves like a small photo-production team. Specialist roles analyze facts independently, a continuity supervisor normalizes and reconciles them, and a director writes the one final prompt. The specialist roles never produce competing prompts.

## Path selection

Choose the lightest path that can preserve the target:

- **Fast path**: only when the user explicitly asks for a quick analysis. Use scene/composition, camera, pose, styling, and the existing checklist.
- **Deep path**: the default for a normal full image reverse-engineering request. Spawn scene, camera, lighting, pose, styling, props, and finish workers in parallel, then run continuity.
- **Repair path**: when a candidate result is supplied, compare the complete visible frame against the target and inventory every material, controllable mismatch, not only the user's latest complaint. By default, repair all high-confidence material mismatches using the minimal union of their owner roles, then run continuity and final validation. If the user explicitly limits the round, repair only that scope and keep other visible mismatches marked `deferred`, never silently accepted. A candidate does not authorize a full seven-role rerun.
- **Staged layer path**: only when the user explicitly requests subject/background decomposition and separate PixVerse validation. Follow the gates and upload roles in [pixverse-closed-loop.md](pixverse-closed-loop.md): generate a person-plus-solid-color-matte image and an unoccupied-background image from the target with PixVerse Gemini Nano Banana 2.1; no transparency or local cutout is required, and these asset generations are distinct from prompt validation. Person validation uses only the current selfie, background validation has no image references, and merged validation adds a background `@图2` only for demonstrated selfie-background leakage when authorized.

## Internal role specifications

The `role-*.md` files below are domain specifications and report guidance, not execution. Reading one never counts as running that role. In the default deep path, attach the matching standalone Skill path to `multi_agent_v1__spawn_agent` and wait for that Agent's completed status.

- [role-scene.md](role-scene.md): visual director, composition, spatial layers, and background.
- [role-camera.md](role-camera.md): camera, lens, perspective, crop, and depth of field.
- [role-lighting.md](role-lighting.md): light sources, direction, hardness, exposure, and color spill.
- [role-pose.md](role-pose.md): anatomy, asymmetry, contact, weight, and expression.
- [role-styling-identity.md](role-styling-identity.md): identity-source isolation, clothing, grooming, and accessories.
- [role-props.md](role-props.md): foreground objects, hand-held props, environment objects, text, and reflections.
- [role-finish.md](role-finish.md): color, material, grain, sharpness, and photographic finish.
- [role-continuity.md](role-continuity.md): authority, conflict resolution, delta merging, and final audit.

The scene, camera, lighting, pose, styling, props, and finish roles are always the default deep-path set. The continuity auditor runs after all seven reports. A role may return `无明显` for an absent dimension, but it must not be silently skipped. Only an explicit quick-analysis request may use fewer roles.

## Standalone role Skills

For direct testing, the same role contracts are also installed as explicit-only Skills. The user normally does not need to call them; `nano-prompt-studio` remains the single entry point. Their automatic invocation is disabled so they do not compete with the director:

- `$nano-scene-analyzer`
- `$nano-camera-analyzer`
- `$nano-lighting-analyzer`
- `$nano-pose-analyzer`
- `$nano-styling-analyzer`
- `$nano-props-analyzer`
- `$nano-finish-analyzer`
- `$nano-continuity-auditor`

The bundled role references are the stable orchestration contract. Standalone Skills exist for isolated testing, debugging, and future refinement of one department. Do not make the final prompt from a standalone role report; return its facts to the director stage.

## Shared role-report contract

Every role report is an internal fact ledger, not prose for the user. Record each important fact with:

```text
字段：一个可控制的视觉属性
结论：短、可执行的视觉事实
来源：场景解析源 / 身份生成源 / 候选结果 / 文字约束
权限：该来源允许控制的属性
置信度：高 / 中 / 低
证据：画面中的位置、边缘、接触点、阴影或反射
禁止推断：不能从该画面补写的内容
冲突：与其他角色或用户约束的冲突，若无则写无
```

Do not use a vague mood word as the only conclusion. For fragile details, use a spatial relation, material cue, or measurable visual comparison.

## Authority matrix

Apply this mapping before merging role reports:

| Source | May control | Must not silently control |
|---|---|---|
| Chat-uploaded target scene | composition, pose, clothing, makeup, environment, props, camera, lighting, color, material, crop, atmosphere | identity token status |
| Explicit `@图1` identity source | face identity and hairstyle identity attributes defined by the fixed preamble | makeup, skin tone, expression, skin texture, head/body pose, body shape, clothing, accessories, scene, props, camera/view/crop, lighting, color grade, composition, background, visual style, target emotion |
| Explicit staged background `@图2` | background-only structure, surfaces, decorations, and their visible illumination/color, and only in merged validation | person, identity, pose, clothing, foreground/held props, subject lighting, camera, and all non-background content |
| Candidate result | mismatch evidence only | any new reference role |
| Latest user text | keep, replace, remove, add, and priority decisions | nothing may override it silently |

If an image is assigned to only one role, it contributes facts only to that role. Never let a role import unrelated attributes from another source.

For the reusable two-image workflow, normalize the scene subject to neutral `主角`/`人物` wording. Do not carry the target scene's apparent gender, age, body type, ethnicity, pronouns, or beauty identity into the final prompt. The explicitly assigned `@图1` supplies only the current user's facial and hair identity dynamically; it must remain compatible with any user. Add a direct prompt clause rejecting transfer of all non-identity attributes from the selfie, and never use it to fill missing scene details.

## Phase gates

Run the following gates in order:

1. **Intake gate**: list current scene sources, any user-authorized isolation assets, identity source, candidate evidence, and text deltas. Record whether an image is only an edit source, an analysis asset, or an allowed generation reference. Reset unauthorized reference tokens.
2. **Coverage gate**: normal full reverse-engineering runs all seven role Skills. Only an explicit quick-analysis request may select fewer roles.
3. **Fact gate**: collect short role reports. Mark low-confidence observations instead of converting them into firm details.
4. **Continuity gate**: normalize screen-relative left/right, subject-facing direction, depth layers, contact points, and source permissions. Resolve conflicts before drafting.
5. **Compression gate**: keep high-impact geometry, light, object relationships, and user prohibitions. Remove duplicated adjectives and low-confidence decoration.
6. **Prompt gate**: write the complete segmented Chinese prompt once, using the section headings and stable order defined in `SKILL.md`; keep separate sections for each visual dimension and under 4000 Chinese characters.
7. **Lint gate**: run the existing reference-token, platform-portability, hair-binding, prohibited-entity, and zero-`或` checks against the complete prompt text; return it inside a standalone fenced `text` copy block. Keep any PixVerse verification note outside the block.
8. **First-generation preflight**: before the initial PixVerse call, inspect the merged prompt for applicable high-risk features: object silhouette/count and measurable size anchors, clothing construction, hand/contact geometry, light-versus-fixture interpretation, cast shadows, background boundaries, and crop/subject scale. Confirm each critical feature has an evidence-backed positive clause and a direct exclusion for a likely wrong reading. Resolve omissions from existing role reports; keep unsupported details unresolved.
9. **Evidence gate**: if no fresh candidate exists, report the result as prompt-only and unverified. If a candidate exists, compare fields and use only the repair path for the next iteration.

## Conflict resolution order

When reports disagree, use this order:

1. Explicit latest user instruction.
2. Reference authority matrix.
3. Direct visual evidence over interpretation.
4. High-confidence observation over low-confidence observation.
5. Geometry and contact relations over mood adjectives.
6. Preserve the last accepted field when the new evidence does not clearly change it.

Never resolve conflict by blending incompatible alternatives into one sentence. Choose one deterministic description, or omit the uncertain detail.

## Repair routing

Map a candidate mismatch to the narrowest role:

- crop, subject scale, perspective: scene or camera;
- torso axis, shoulder/pelvis asymmetry, joint-chain geometry, support/contact, hand placement, expression: pose;
- face or hair identity: styling-identity;
- itemized garment construction/cut/fit/color/material/folds, accessory: styling-identity;
- object count, grip, placement, reflection, text: props;
- shadow direction, color cast, exposure: lighting;
- grain, sharpness, saturation, finish: finish.

Use `scene` for environment and background structure, `lighting` for the physical light pattern on that environment, and `camera` for framing, scale, and perspective. Use `props` for an object's geometry, material, relative size, contact, and placement. If one visible error has multiple plausible owners, select the smallest set and include the evidence that justifies each owner.

Before dispatching a repair role, create this internal record:

```text
repair_round: <round number>
baseline: <last accepted prompt/field ledger>
scope: comprehensive | user-limited
mismatches:
- field: <one controllable field>
  type: missing | wrong | extra | shifted | too strong | too weak | unresolved
  status: repair_now | deferred | unresolved
  target_fact: <what the target shows>
  candidate_fact: <what the candidate shows>
  evidence: <location, edge, contact, shadow, reflection>
  owner: <one or more narrow roles>
  reason_if_deferred_or_unresolved: <explicit user limit or evidence gap>
accepted_fields: <fields already accepted as matching or intentionally retained>
change_allowed: <exact fields the roles may edit>
frozen_fields: <accepted fields plus deferred fields outside change_allowed; preserve their values without implying deferred fields are correct>
```

Inventory the full frame first. `repair_now` is the default for materially visible, high-confidence differences; use `deferred` only when the user explicitly narrowed scope, and `unresolved` only when evidence is insufficient. A genuinely unresolved field does not block independent supported repairs. Dispatch the union of owners for all `repair_now` items, in parallel where possible. Pass `baseline`, the complete `mismatches` inventory, `change_allowed`, `accepted_fields`, and `frozen_fields` to each role. After reports return, continuity must verify that every mismatch remains represented with the correct status, that no frozen value changed, and that deferred fields were not mislabeled accepted. Then the director writes the complete merged prompt. If no supported repair is authorized, do not generate another candidate.

