# CLAUDE.md - MMOSkillBountyPack

A standalone Hytale content pack for the [MMOSkillTree mod](https://www.curseforge.com/hytale/mmoskilltree) (1.2.1+). Ships the entire **Bounty Board** feature's content: the bounty pool, reusable templates, the Bounty Token currency, the board schedules, AND the in-world board blocks (item + interaction + textures-via-vanilla + item names). The mod jar ships only the Bounty Board *engine* (`BountyService`, `BountyBoardConfig`, `BountyBoardPage` + its `.ui`, the registered `mmo_bounty_board_open` interaction type, `/mmobounty*` commands) and no content, so this pack is what makes bounties appear. It is a **hard dependency** on the mod (the board block's interaction needs the jar-registered Java type), declared in `manifest.json`.

## Layout

```
bounty-contracts-pack/
├── manifest.json                                  Hytale plugin manifest (hard-deps Ziggfreed:MMOSkillTree)
├── build.ps1                                       zips with forward-slash + directory entries, copies to Mods
└── Server/
    ├── Item/
    │   ├── Items/MMO_Bounty_Board.json             daily board block (Use -> MMO_BountyBoard_Open)
    │   ├── Items/MMO_Bounty_Board_Weekly.json      weekly board block (Use -> MMO_BountyBoard_Weekly_Open)
    │   ├── Items/MMO_Token_Trader.json             token-shop block (Use -> MMO_TokenTrader_Open)
    │   └── RootInteractions/
    │       ├── MMO_BountyBoard_Open.json           object form: {"Type":"mmo_bounty_board_open","Board":"daily"}
    │       ├── MMO_BountyBoard_Weekly_Open.json    object form: {"Type":"mmo_bounty_board_open","Board":"weekly"}
    │       └── MMO_TokenTrader_Open.json           {"Type":"mmo_token_shop_open"} (single shop in v1)
    ├── Languages/en-US/items.lang                  block item names + descriptions + interaction hints
    └── MMOSkillTree/
        ├── Control/MMOSkillBountyPack.json         add-mode per MMOSkillTree content type
        ├── QuestTemplates/Bounty_*_Standard.json   reusable bounty skeletons (Kill / Gather / Xp / TurnIn)
        ├── Quests/Bounty_*.json                        the bounty pool (daily + weekly; kill / gather / train-skill / deliver)
        ├── Currencies/Bounty_Token.json               counter-backed reward currency
        ├── BountyBoards/Daily.json, Weekly.json        board schedules (rotation/selection/slots/combat gate)
        ├── TokenShop/*.json                            token-shop offers (boosts / items / conversion)
        ├── AchievementTemplates/Bounty_Board_Counter.json  reusable per-board "complete N bounties" achievement skeleton
        └── Achievements/Bounty_Daily_T*.json, Bounty_Weekly_T*.json  per-board achievement chains (Daily Contractor / Weekly Warrant)
```

`Server/Item/**` and `Server/Languages/**` load via Hytale's native asset pack mechanism (gated by `"IncludesAssetPack": true`), independent of the MMOSkillTree `Control` map (which only governs `Server/MMOSkillTree/**`). So adding the block + lang needs no Control-file change.

## How it fits together

- **A bounty is a repeatable quest** tagged into a board pool: `["bounty", "board:<id>", "diff:<x>", "weight:<n>"]`. `npcViewId: "bounty_board"` keeps bounties out of the normal quest log until accepted; `visibility.hidden` + `autoClaimRewards` complete the shape. All of this lives in the two `QuestTemplates`, so each bounty file is ~10 lines (extends + params + amount override + rewards). The `{{boards}}` param becomes the single `board:<id>` tag, so a bounty belongs to exactly one board; author separate files for separate boards.
- **A board** (`BountyBoards/<Id>.json`) declares rotation cadence, selection algorithm, and slots; `BountyService` deterministically picks one bounty per slot per period (seeded by the epoch-period), so every player sees the same board with zero persisted state. Optional fields: `titleKey`, `descriptionKey` (page subtitle), `order` (sort + default-board pick), `enabled` (per-board on/off), `rerollCost`, `requiresFeatures`, and **`combatLevelRequirements`** (difficulty -> min combat level, e.g. `{ "normal": 25, "hard": 60 }`; opt-in, a difficulty you omit is ungated). The combat gate uses the highest level across the whole COMBAT skill category and is checked at ACCEPT only (selection is untouched, so everyone still sees the same board); below-threshold contracts render Locked.
- **Several boards per world, one block each.** Each board has its own placeable block. The block's `BlockType.Interactions.Use` names a `RootInteraction` whose single entry is the **object form** `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`. The mod's `BountyBoardOpenInteraction` reads that `Board` field and opens that board; the bare-string form `["mmo_bounty_board_open"]` falls back to the default board. This is why N boards in a world is N blocks + N RootInteractions, but still one Java interaction type.
- **Reward currency** is `bounty_token` (counter-backed). Reroll costs tokens (per board, e.g. 50 daily / 100 weekly). Tokens are spent at the **Token Shop** (below).
- **Turn-in (deliver) bounties** use the `bounty_turnin_standard` template (objective type `TURN_IN`, `matchMode: EXACT`, item-id `{{target}}`); the player delivers the items via a **Turn In** button on the board. Their rewards MUST be CURRENCY + XP only (never `/give` items): a board bounty has no claim button, so one parked in `COMPLETED_UNCLAIMED` for lack of inventory space would be unclaimable. Targets must be concrete item ids (e.g. `Ingredient_Life_Essence`), not the CONTAINS tokens the gather template uses.
- **The Token Shop** (`TokenShop/*.json`) is the token sink: each file is one offer the player buys with `bounty_token`. The shop opens from the `MMO_Token_Trader` block (its `RootInteraction` runs `mmo_token_shop_open`) or `/mmoshopui <player>`. The engine is in the mod jar; this pack ships the catalog + the trader block.

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

No `displayText` on the objective: the mod's `ObjectiveTextRenderer` infers a localized "Defeat 12 Zombie" in every supported language. `params` substitute the string tags + target; the numeric `amount` is set via `objectiveOverrides` (the template DSL substitutes string values only); `rewards` overlays the template wholesale. Drop the file in `Quests/`, rebuild, and the bounty self-enrolls in its board pool by tag, no schedule edit.

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

One file per offer in `TokenShop/`. The id comes from the inner `Payload.id` (fallback: the filename, lowercased). Rewards reuse the quest reward shapes (`XP`, `BOOST_TOKEN`, `COMMAND` `/give`, `CURRENCY`), so an offer can grant XP, a boost, items, or convert tokens into another currency.

```json
{ "Name": "Boost_Mining",
  "Payload": {
    "id": "shop_boost_mining", "displayName": "Mining Rush (3x, 20m)",
    "description": "Triples Mining XP for 20 minutes.",
    "currencyId": "bounty_token", "cost": 150,
    "category": "boosts", "order": 20, "limitPerDay": 3,
    "requirements": { "minCombatLevel": 0, "skill": {}, "requiresFeatures": [] },
    "rewards": [ { "type": "BOOST_TOKEN", "skill": "MINING", "multiplier": 3.0, "durationMinutes": 20, "displayName": "Mining XP x3 for 20 minutes" } ] } }
```

- **`category`**: `boosts` | `items` | `conversion` (groups + sorts the catalog; unknown categories warn in the audit).
- **`cost`** is in `currencyId` (default `bounty_token`).
- **`requirements`**: `minCombatLevel` (any one COMBAT skill at/above the level), per-skill `skill` map, and `requiresFeatures` (hides the offer unless every feature is on; use `["mastery"]` for a mastery-point conversion, which needs the mastery pack's `mastery_point` currency).
- **`limitPerDay`** / **`limitTotal`**: 0 = unlimited. Per-player counts persist server-side.
- **Items via `/give`** are inventory-space-checked before tokens are spent, so they can't be lost. Set a reward `displayName` so non-icon rewards (XP / boost / currency) read nicely in the detail panel.
- **Validate:** `/mmoshop validate` reports a missing/disabled cost currency, a non-positive cost, an unknown reward currency, or an empty rewards list.
- **In-world block:** the `MMO_Token_Trader` block + `MMO_TokenTrader_Open` RootInteraction ship here already; a single shop in v1, so the RootInteraction is the bare `{ "Type": "mmo_token_shop_open" }` (no per-block param). Without the block, the shop is still reachable via `/mmoshopui <player>` (NPC-wired).

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
