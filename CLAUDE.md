# CLAUDE.md - MMOSkillBountyPack

A standalone Hytale content pack for the [MMOSkillTree mod](https://www.curseforge.com/hytale/mmoskilltree) (1.3.0+). Ships the entire **Bounty Board** feature's content: the bounty pool, reusable templates, the Bounty Token currency, the board schedules, AND the in-world board blocks (item + interaction + textures-via-vanilla + item names). The mod jar ships only the Bounty Board *engine* (`BountyService`, `BountyBoardConfig`, `BountyBoardPage` + its `.ui`, the registered `mmo_bounty_board_open` interaction type, `/mmobounty*` commands) and no content, so this pack is what makes bounties appear. It is a **hard dependency** on the mod (the board block's interaction needs the jar-registered Java type), declared in `manifest.json`.

## Release notes (patch-notes paradigm)

Per-version public release notes live in `patch-notes/<version>.md`, same paradigm as the main mod repo: YAML frontmatter (`version`, `title`, `type: patch-note`, `status: held|released`), a one-line summary, then user-facing `- **New/Fixed: ...**` bullets. No em-dashes. `patch-notes/_INDEX.md` lists them newest-first. `CURSEFORGE.md` is the public listing copy; keep its Versions table in sync with each release. Naming: the SHOP feature is generic ("the shops"); "Token Shop" names only the general storefront (`shop.general.title`), beside the per-skill "XP Exchange". (No docs-site publishing for packs yet.)

## Layout

```
bounty-contracts-pack/
├── manifest.json                                  Hytale plugin manifest (hard-deps Ziggfreed:MMOSkillTree)
├── build.ps1                                       zips with forward-slash + directory entries, copies to Mods
└── Server/
    ├── Item/
    │   ├── Items/MMO_Bounty_Board.json             daily board block (wall poster; Use -> MMO_BountyBoard_Open)
    │   ├── Items/MMO_Bounty_Board_Weekly.json      weekly board block (wall poster; Use -> MMO_BountyBoard_Weekly_Open)
    │   ├── Items/MMO_Token_Trader.json             token-shop block (wall poster; Use -> MMO_TokenTrader_Open)
    │   └── RootInteractions/
    │       ├── MMO_BountyBoard_Open.json           object form: {"Type":"mmo_bounty_board_open","Board":"daily"}
    │       ├── MMO_BountyBoard_Weekly_Open.json    object form: {"Type":"mmo_bounty_board_open","Board":"weekly"}
    │       └── MMO_TokenTrader_Open.json           {"Type":"mmo_token_shop_open"} (Pool optional; default pool in v1)
    ├── Languages/en-US/
    │   ├── items.lang                              block item names + descriptions + interaction hints
    │   ├── mmoskilltree.lang                       bounty titles + flavor (quest.<id>.title / .flavor)
    │   └── npcs.lang                               spawn-NPC display names + F-hints (npcs.<key>)
    ├── NPC/Roles/Passive/                          (the hub role MMO_Hub now ships in the mod jar, not here)
    │   ├── MMO_Bounty_Daily.json                   manual per-board NPC (OpenMmoUi Target=daily)
    │   ├── MMO_Bounty_Weekly.json                  manual per-board NPC (OpenMmoUi Target=weekly)
    │   └── MMO_Token_Trader_NPC.json               manual shop NPC (OpenMmoUi Target=shop)
    └── MMOSkillTree/
        ├── Control/MMOSkillBountyPack.json         add-mode per MMOSkillTree content type (incl. ShopPools)
        ├── QuestTemplates/Bounty_*_Standard.json   reusable bounty skeletons (Kill / Gather / Xp / TurnIn)
        ├── Quests/Bounty_*.json                        the bounty pool (daily + weekly; kill / gather / train-skill / deliver)
        ├── Currencies/Bounty_Token.json               counter-backed reward currency
        ├── BountyBoards/Daily.json, Weekly.json        board schedules (rotation/selection/slots/combat gate)
        ├── ShopEntries/*.json                          token-shop offers (static + Featured_* pooled)
        ├── ShopTemplates/Xp_Packet_Base.json           reusable shop-offer skeleton (extends + params)
        ├── ShopPools/Featured.json                     rotating token-shop pool (rotation/selection/reroll)
        ├── AchievementTemplates/Bounty_Board_Counter.json  reusable per-board "complete N bounties" achievement skeleton
        └── Achievements/Bounty_Daily_T*.json, Bounty_Weekly_T*.json  per-board achievement chains (Daily Contractor / Weekly Warrant)
```

`Server/Item/**` and `Server/Languages/**` load via Hytale's native asset pack mechanism (gated by `"IncludesAssetPack": true`), independent of the MMOSkillTree `Control` map (which only governs `Server/MMOSkillTree/**`). So adding the block + lang needs no Control-file change.

## How it fits together

- **A bounty is a repeatable quest** tagged into a board pool: `["bounty", "board:<id>", "diff:<x>", "weight:<n>"]`. `npcViewId: "bounty_board"` keeps bounties out of the normal quest log until accepted; `visibility.hidden` + `autoClaimRewards` complete the shape. All of this lives in the two `QuestTemplates`, so each bounty file is ~10 lines (extends + params + amount override + rewards). The `{{boards}}` param becomes the single `board:<id>` tag, so a bounty belongs to exactly one board; author separate files for separate boards.
- **A board** (`BountyBoards/<Id>.json`) declares rotation cadence, selection algorithm, and slots; `BountyService` deterministically picks one bounty per slot per period (seeded by the epoch-period), so every player sees the same board with zero persisted state. Optional fields: `titleKey`, `descriptionKey` (page subtitle), `order` (sort + default-board pick), `enabled` (per-board on/off), `rerollCost`, a unified `requirements` block (`features` / `skills` / `minCombatLevel`; gates who can use the board at all), and **`combatLevelRequirements`** (difficulty -> min combat level, e.g. `{ "normal": 25, "hard": 60 }`; opt-in, a difficulty you omit is ungated). The combat gate uses the highest level across the whole COMBAT skill category and is checked at ACCEPT only (selection is untouched, so everyone still sees the same board); below-threshold contracts render Locked.
- **Several boards per world, one block each.** Each board has its own placeable block (a **wall poster** based on the vanilla `Lobby_Wall_Poster01` model/texture/icon, tinted per block via `TextureComputedColor`, `Support: North`). The block's `BlockType.Interactions.Use` names a `RootInteraction` whose single entry is the **object form** `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`. The mod's `BountyBoardOpenInteraction` reads that `Board` field and opens that board; the bare-string form `["mmo_bounty_board_open"]` falls back to the default board. This is why N boards in a world is N blocks + N RootInteractions, but still one Java interaction type.
- **Bounty titles + flavor are localized.** A bounty shows a localized title + a short markdown flavor blurb on the board, resolved **by convention** from `quest.<id>.title` / `quest.<id>.flavor` in `Server/Languages/en-US/mmoskilltree.lang` (no per-bounty JSON edit; the mod's `BountyBoardPage` looks them up automatically, falling back to the inferred objective sentence). Translate by shipping `Server/Languages/<bcp47>/mmoskilltree.lang` with the same keys (missing keys fall back to English per key). Objective text also pluralizes the count automatically ("Defeat 12 Zombies"), and every reward (including the flat XP) renders with its amount, so **every bounty should award `bounty_token` + an `XP` reward**.
- **Reward currency** is `bounty_token` (counter-backed). Reroll is **per-contract** (the player swaps one contract from the board's detail panel, keeping the rest), costing tokens (per board, e.g. 25 daily / 100 weekly) with a `rerollCost.maxPerPeriod` total-per-period cap (the pack ships 3/day on `daily`, 2/week on `weekly`). Tokens are spent at the **Token Shop** (below).
- **`/give` item rewards on bounties are safe.** A bounty whose reward set includes a `/give` COMMAND can grant items now: if it auto-completes while the inventory is full it parks in `COMPLETED_UNCLAIMED`, and the board's detail panel shows a **Claim** button for that state (the player frees space, then claims), so an item reward is never silently lost. (`Bounty_Cache_Copper` / `Bounty_Cache_Repairs` are the worked examples.) Still give every bounty `bounty_token` + an `XP` reward too, so the board's reward list always shows the token/XP payout. ALWAYS use the named `/give {player} <item> --quantity=N` form: Hytale's give command does not accept a positional quantity (the item would arrive as a single unit); the content audit flags the positional form as `POSITIONAL_GIVE_QUANTITY`.
- **Turn-in (deliver) bounties** use the `bounty_turnin_standard` template (objective type `TURN_IN`, `matchMode: EXACT`, item-id `{{target}}`); the player delivers the items via a **Turn In** button on the board. Keep their rewards CURRENCY + XP (a `/give` item is awkward right after the player just emptied that inventory space to turn in). Targets must be concrete item ids (e.g. `Ingredient_Life_Essence`), not the CONTAINS tokens the gather template uses.
- **The Token Shop** (`ShopEntries/*.json`) is the token sink: each file is one offer the player buys with `bounty_token`. Offers are **static** (always listed) by default; tag one into a **rotating pool** with `"pool": "<id>"` (+ optional `tier` / `weight`) and it surfaces only when that pool's rotation draws it. Pools (`ShopPools/<Id>.json`) declare the same `rotation` / `selection` / `slots` / `rerollCost` shape as a bounty board. The shop opens from the `MMO_Token_Trader` block (its `RootInteraction` runs `mmo_token_shop_open`, optional `"Pool":"<id>"` to focus one pool) or `/mmoshopui <player>`. The engine is in the mod jar; this pack ships the catalog, the `Featured` pool, and the trader block.
- **Spawn NPCs (press F → MMO UI).** This pack ships the **per-board / shop** NPC roles only (`Server/NPC/Roles/Passive/*.json`); the **hub** role `MMO_Hub` now ships in the **mod jar**, since the hub auto-spawns by default even without this pack. Each role is a **native Hytale NPC role** (auto-loaded under `IncludesAssetPack: true` — no `Control`-map entry, like the blocks/lang): a stationary `Generic` role modeled on the vanilla `Kweebec_Merchant` (only ever issues `BodyMotion: Nothing`, so it stays put) with an `InteractionInstruction` whose `HasInteracted` branch runs `{ "Type": "OpenMmoUi", "Target": "<shop|boardId>" }` — the mod's custom NPC action (registered in the jar's `setup()`; the role JSON can reference it because the pack hard-deps the jar). `OpenMmoUi` hands the `Target` verbatim to the mod's `MmoUiRouter`, which opens the hub / a specific board / the shop / any core feature page. The jar's hub NPC (`Target: hub`) is a **feature-aware launcher** listing every accessible board + the Token Shop + core feature links (skills/quests/abilities/...); a player's first talk shows a one-time feature-aware overview. The mod **auto-spawns the hub (`MMO_Hub`) at world spawn** once per world (gated by `spawn-hub.json` only — it spawns by default as the general guide, no bounty/shop content required); `MMO_Bounty_Daily`/`Weekly`/`MMO_Token_Trader_NPC` are placed by hand via `/mmonpc spawn`. To add a board NPC for a new board id `<x>`, copy `MMO_Bounty_Daily.json` → `MMO_Bounty_<X>.json`, change `Target` to `<x>` + the name key, and add the name to `npcs.lang` (`/mmonpc spawn board <x>` resolves role `MMO_Bounty_<X>` by convention). `Appearance` reuses a builtin model id (`Kweebec_Rootling` / `Kweebec_Sapling_Orange`) so no model files ship; **`OpenMmoUi`'s `Target` is baked per-role** (an NPC's `Use` is engine-locked to `*UseNPC`, so the per-NPC param lives in the role asset, not a `RootInteraction`).

## Authoring a new bounty

```json
{ "Name": "Bounty_Slay_Zombies",
  "Payload": {
    "extends": "bounty_kill_standard",
    "id": "bounty_slay_zombies",
    "params": { "boards": "daily", "difficulty": "normal", "weight": "2", "target": "Zombie" },
    "objectiveOverrides": { "main": { "amount": 12 } },
    "rewards": [ { "type": "CURRENCY", "currencyId": "bounty_token", "amount": 150 },
                 { "type": "XP", "skill": "SWORDS", "amount": 1200 } ] } }
```

No `displayText` on the objective: the mod's `ObjectiveTextRenderer` infers a localized, **pluralized** "Defeat 12 Zombies" in every supported language. `params` substitute the string tags + target; the numeric `amount` is set via `objectiveOverrides` (the template DSL substitutes string values only); `rewards` overlays the template wholesale. **Always give every bounty a `CURRENCY` (`bounty_token`) reward AND an `XP` reward** — both now show on the board, and bounties are meant to pay tokens + flat XP. Drop the file in `Quests/`, rebuild, and the bounty self-enrolls in its board pool by tag, no schedule edit.

**Title + flavor:** add `quest.<id>.title = ...` and `quest.<id>.flavor = ...` to `Server/Languages/en-US/mmoskilltree.lang` (the `<id>` is the bounty's `Payload.id`). The board shows the title in the list + detail header and renders the flavor as markdown; both fall back to the inferred objective sentence if absent. Translate by adding the same keys under `Server/Languages/<bcp47>/mmoskilltree.lang`.

## Authoring a new board (and its block)

1. **Board schedule:** drop `BountyBoards/<Id>.json` (the filename, lowercased, is the board id and the `board:<id>` tag bounties target). Give it slots whose `difficulty` filters match the difficulties of the bounties you tagged onto it, or required slots will read as unfillable in the content audit.
2. **In-world block (optional but recommended):** add `Server/Item/Items/MMO_Bounty_Board_<Name>.json` (copy an existing block; point `BlockType.Interactions.Use` at your RootInteraction) + `Server/Item/RootInteractions/MMO_BountyBoard_<Name>_Open.json` = `{ "Cooldown": {...}, "Interactions": [ { "Type": "mmo_bounty_board_open", "Board": "<id>" } ] }` + item-name keys in `Server/Languages/en-US/items.lang`. Without a block, the board is still reachable through `/mmobountyui <player> <id>` (NPC-wired).
3. **Validate:** after `/mmobounty validate` (console/admin), confirm no `EMPTY_POOL` / `UNFILLABLE_SLOT` / `MISSING_REROLL_CURRENCY` findings for the new board.

## Authoring a turn-in (deliver) bounty

Extend `bounty_turnin_standard` and set the `{{target}}` param to a concrete item id. Set an explicit `displayText` for polish (the inferred text would read the raw asset id). Rewards: `bounty_token` + XP only.

```json
{ "Name": "Bounty_Deliver_Essence",
  "Payload": {
    "extends": "bounty_turnin_standard",
    "id": "bounty_deliver_essence",
    "params": { "boards": "daily", "difficulty": "normal", "weight": "2", "target": "Ingredient_Life_Essence" },
    "objectiveOverrides": { "main": { "amount": 250, "displayText": "Turn in 250 Life Essence" } },
    "rewards": [ { "type": "CURRENCY", "currencyId": "bounty_token", "amount": 200 },
                 { "type": "XP", "skill": "MINING", "amount": 1500 } ] } }
```

## Authoring a Token Shop offer

One file per offer in `ShopEntries/`. The id comes from the inner `Payload.id` (fallback: the filename, lowercased). Rewards reuse the unified reward shapes (`XP`, `BOOST_TOKEN`, `COMMAND` `/give`, `CURRENCY`), so an offer can grant XP, a boost, items, or convert tokens into another currency.

```json
{ "Name": "Boost_Mining",
  "Payload": {
    "id": "shop_boost_mining",
    "titleKey": "shop.boost_mining.title",
    "descriptionKey": "shop.boost_mining.desc",
    "cost": { "currencies": { "bounty_token": 150 } },
    "category": "boosts", "order": 20, "limitPerDay": 3,
    "requirements": { "skills": { "MINING": 1 } },
    "rewards": [ { "type": "BOOST_TOKEN", "skill": "MINING", "multiplier": 3.0, "durationMinutes": 20 } ] } }
```

- **`titleKey`** / **`descriptionKey`**: localization keys for the offer name + blurb (parity with `ShopBoard`/`ShopPool` and the bounty pattern), resolved per-player from `Server/Languages/<locale>/mmoskilltree.lang`. Add `shop.<name>.title = ...` and `shop.<name>.desc = ...` there (e.g. `shop.boost_mining.title = Mining Rush (3x, 20m)`). The mod's `LocalizedText` resolver tries the explicit key, then the by-convention `shop.<id>.title` / `.desc`, then a legacy raw `displayName`/`description` (deprecated, kept only as a fallback). The fanned per-skill XP packets keep a templated `displayName` (`{{SKILL_NAME}} {{TIER_NAME}}` in the base template) since one static key can't cover every skill.
- **`category`**: `boosts` | `items` | `conversion` | `featured` (groups + sorts the catalog; unknown categories warn in the audit).
- **`cost`** is a cost OBJECT: `{ "currencies": { "<id>": N, ... }, "items": [ ... ], "combine": "all|any" }` (`all` is the default for multi-currency). There is no scalar form.
- **`requirements`** is the unified gate block: `features` (hides the offer unless every feature is on; use `["mastery"]` for a mastery-point conversion, which needs the mastery pack's `mastery_point` currency), per-skill `skills` map, and `minCombatLevel` (any one COMBAT skill at/above the level). The flat `requiresFeatures`/`requiresSkills` spellings parse as aliases.
- **`limitPerDay`** / **`limitTotal`**: 0 = unlimited. Per-player counts persist server-side.
- **`pool`** / **`tier`** / **`weight`** (optional): omit `pool` for a **static** offer (always listed). Set `"pool": "<id>"` to enroll it in a rotating pool (`tier` matches a pool slot's tier; `weight` biases selection, default 1).
- **Items via `/give`** are inventory-space-checked before tokens are spent, so they can't be lost. Always the named `--quantity=N` form (Hytale's give command ignores a positional quantity; the audit flags it). XP / boost / currency / parseable `/give` rewards auto-render localized lines with their amount, so they need NO display fields; only an opaque (non-`/give`) COMMAND reward must carry a `nameKey` (a raw `displayName` is a deprecated fallback that overrides localization - avoid it).
- **Validate:** `/mmoshop validate` reports a missing/disabled cost currency, a non-positive cost, an unknown reward currency, an empty rewards list, a malformed icon id, and (for pools) empty pools / unfillable slots / orphaned pooled entries.
- **In-world block:** the `MMO_Token_Trader` block + `MMO_TokenTrader_Open` RootInteraction ship here already. The RootInteraction is the bare `{ "Type": "mmo_token_shop_open" }` (opens the default pool + static catalog); add `"Pool": "<id>"` in object form to focus a specific pool. Without the block, the shop is still reachable via `/mmoshopui <player>` (NPC-wired).

## Authoring a Token Shop pool

A rotating pool surfaces a changing subset of the offers tagged into it (`"pool": "<id>"`), with an optional paid reroll, on top of the always-available static catalog. Drop `ShopPools/<Id>.json` (the filename, lowercased, is the pool id):

```json
{ "Name": "Featured",
  "Payload": {
    "titleKey": "ui.shop.category.featured",
    "order": 0,
    "rotation": { "type": "interval", "period": "daily", "anchor": "utc", "offsetMinutes": 0 },
    "selection": { "type": "weighted_random", "seed": "period" },
    "rerollCost": { "currency": "bounty_token", "amount": 40, "maxPerPeriod": 2 } } }
```

- Same `rotation` / `selection` / `slots` / `rerollCost` shape as a `BountyBoards/<Id>.json` board (shared engine). With no `slots`, the pool draws a default of 4 offers per period; add `slots` (each `{ "filter": { "tier": "<x>" }, "count": N, "optional": true|false }`) to control the tier mix.
- `rerollCost.maxPerPeriod` caps paid rerolls per period (0/omit = unlimited).
- Enroll offers by adding `"pool": "<id>"` to their `ShopEntries/*.json` (give the pool **more** offers than it draws so rotation + reroll are meaningful). The pack's `Featured.json` + the twelve `Featured_*` offers are the worked example. A pool may also carry its own `requirements` block to gate the whole pool.
- Needs the `ShopPools` entry in `Control/MMOSkillBountyPack.json` (already present).

## Per-skill XP exchange (auto-generated, `forEachSkill`)

The pack ships **a few** XP-exchange tier definitions that the mod fans out to **every active skill** at load, instead of one file per skill per tier (the Token Shop analogue of CommandRewards' `{{ALL_SKILLS}}` sentinel). The shared shape lives once in `ShopTemplates/Xp_Packet_Base.json` (`"forEachSkill": true`, the `{{SKILL}}` / `{{SKILL_NAME}}` fan-out tokens, the dual-currency cost and XP reward as `{{TOKENS}}`/`{{ESSENCE}}`/`{{XP}}` params); each tier file is a thin `extends` + `params` + per-tier fields (`id` pattern, `order`, `requireSelfLevel`, `limitPerDay`). Template resolution runs FIRST, then `TokenShopConfig` clones the resolved JSON once per `SkillRegistry.isSkillAvailable(...)` skill, substituting the skill id (`{{SKILL}}`, e.g. `MINING`) and its display name (`{{SKILL_NAME}}`, e.g. `Mining`) - the two passes compose because unknown `{{...}}` tokens survive pass 1, which is also why `params` must never define `SKILL`/`SKILL_NAME`. The generated id comes from the consumer's `id` **pattern**, so distinct tiers don't collide. Templates need the `ShopTemplates` entry in `Control/MMOSkillBountyPack.json` (present).

**Three static tiers** (always listed, no `pool`), gated by the fanned skill's own level and tuned to the shipped XP curve so a packet stays a sensible nudge at any level (the top caps at 40k XP, ~10% of a level at L90):

| File | id pattern | `requireSelfLevel` | XP | cost (token + essence) | `limitPerDay` |
|---|---|---:|---:|---|---:|
| `XP_Packet_Lesser.json`  | `shop_xp_{{SKILL}}`         | none | 1,500  | 90 + 40   | 3 |
| `XP_Packet_Greater.json` | `shop_xp_greater_{{SKILL}}` | 30   | 7,500  | 200 + 80  | 2 |
| `XP_Packet_Master.json`  | `shop_xp_master_{{SKILL}}`  | 60   | 40,000 | 400 + 120 | 1 |

```json
{ "Name": "XP_Packet_Greater",
  "Payload": {
    "extends": "xp_packet_base",
    "params": { "TIER_NAME": "Training", "TOKENS": "200", "ESSENCE": "80", "XP": "7500" },
    "id": "shop_xp_greater_{{SKILL}}",
    "order": 42,
    "requireSelfLevel": 30,
    "limitPerDay": 2 } }
```

- **Static, not rotating.** All three tiers are always listed (no `pool`); the level gate is the progression, so a player is never RNG-locked out of training the skill they care about. The reroll/rotation token-sink lives in the General shop's `Featured` pool, not here. The **all-skills bundle** (`XP_Packet_AllSkills.json`) is a separate static premium (`skill: "ALL"`, `+2,500` to every skill, 1/day).
- **`requireSelfLevel`** (scalar) gates the offer behind the *fanned* skill's own level: the fan-out injects `requirements.requiresSkills[<skill>] = N` in Java (you can't template a `requiresSkills` *key*, only string values). Omit it for an ungated tier.
- **Unique per-skill icons** come free: an `XP` reward for a concrete skill resolves to that skill's registry icon (`ShopEntryIconResolver` → `SkillDisplayUtils.resolveSkillIconItemId`), so the tiers ship **no** `icon`. Only the all-skills bundle (`skill: "ALL"`) sets an explicit `icon`.
- **Dual currency.** Every XP exchange costs `bounty_token` AND `life_essence` (`combine: ALL` is the default for a multi-currency `cost`). **`life_essence` is item-backed** (it lives in the inventory as `Ingredient_Life_Essence`), so the player must physically hold that many Life Essence items to afford an exchange — `CostService` removes the items on purchase.
- **Override one skill's tier.** Author an explicit `ShopEntries/*.json` with the generated `id` (e.g. `id: "shop_xp_mining"` for the Lesser tier, `shop_xp_master_mining` for Master) (or an owner override of that id) and the fan-out skips that skill+tier (explicit wins, mirroring `{{ALL_SKILLS}}`).
- `{{paramName}}` substitution replaces string **values** only (not object keys) — that's exactly why `requireSelfLevel` exists rather than a templated `requiresSkills` key.

## Bounty achievements

The mod ships **board-agnostic** bounty achievements in its own jar (a Bounty Hunter count ladder, hard/elite-difficulty chains, a server-first, and a daily streak), driven by the `COMPLETE_BOUNTY` / `BOUNTY_STREAK` objective types the jar fires on every bounty completion — these work with any board, including server-defined ones. This pack adds **per-board** chains (`Daily Contractor`, `Weekly Warrant`) that key on the board id, since `daily` / `weekly` only exist when this pack is installed. They extend `AchievementTemplates/Bounty_Board_Counter.json` (`triggerType: COMPLETE_BOUNTY`, `target: {{board}}`), so a new board's chain is a few-line file: `extends` the template, pass `params.board`, and set `requiredAmount` / `displayName` / `tier` / `manualClaimRewards`. The `COMPLETE_BOUNTY` event carries `target = board id` and `qualifier = difficulty`, so achievements can match by board, by difficulty, or both. Achievements need the `Achievements` + `AchievementTemplates` entries in `Control/MMOSkillBountyPack.json`.

## Build & deploy

```powershell
.\build.ps1                  # build the zip, and install it if a Mods folder is known
.\build.ps1 -Install:$false  # build only, no copy
.\build.ps1 -ModsDir <path>  # build + install into an explicit folder
```

`build.ps1` is self-locating (`$PSScriptRoot`) and cross-platform (Windows PowerShell, or `pwsh ./build.ps1` on macOS/Linux). It zips with forward-slash entries AND an explicit directory entry for every ancestor path (Java's `ZipFileSystem.isDirectory()` returns false without them, so Hytale's `I18nModule.loadMessagesFromPack` would skip `items.lang`). Never use `Compress-Archive` (it writes backslash separators Hytale drops). To auto-install on build, set `HYTALE_MODS_DIR` once to your Hytale `UserData/Mods` folder (or pass `-ModsDir`); without it the script just builds the zip.

Start the server with both the mod jar and this zip in `Mods/`. Confirm in the log: `[AssetPacks] Bounty-board pack layer applied (2 entries, mode=add)` plus the Quests/QuestTemplates/Currencies layers and the `Bounty validation: ...` summary, and no `Asset validation FAILED`. In-game: craft + place a board block and interact, or `/mmobountyui <you> daily`.

## Conventions (shared with the mastery pack)

Filenames PascalCase (the asset key). `Name` is a human echo consumed by a no-op setter. `Payload` is a nested JSON object (not an escaped string). Quest/board ids come from the inner `Payload.id` / the filename respectively. Item + RootInteraction JSON keys start upper-case (Hytale codec requirement). See `skill-mastery-pack/CLAUDE.md` for the full template-DSL reference.
