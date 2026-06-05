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
    │   └── RootInteractions/
    │       ├── MMO_BountyBoard_Open.json           object form: {"Type":"mmo_bounty_board_open","Board":"daily"}
    │       └── MMO_BountyBoard_Weekly_Open.json    object form: {"Type":"mmo_bounty_board_open","Board":"weekly"}
    ├── Languages/en-US/items.lang                  block item names + descriptions + interaction hints
    └── MMOSkillTree/
        ├── Control/MMOSkillBountyPack.json         add-mode per MMOSkillTree content type
        ├── QuestTemplates/Bounty_Kill_Standard.json   reusable KILL_ENTITY bounty skeleton
        ├── QuestTemplates/Bounty_Gather_Standard.json reusable BREAK_BLOCK bounty skeleton
        ├── Quests/Bounty_*.json                        the bounty pool (daily + weekly, kill + gather)
        ├── Currencies/Bounty_Token.json               counter-backed reward currency
        └── BountyBoards/Daily.json, Weekly.json        board schedules (rotation/selection/slots)
```

`Server/Item/**` and `Server/Languages/**` load via Hytale's native asset pack mechanism (gated by `"IncludesAssetPack": true`), independent of the MMOSkillTree `Control` map (which only governs `Server/MMOSkillTree/**`). So adding the block + lang needs no Control-file change.

## How it fits together

- **A bounty is a repeatable quest** tagged into a board pool: `["bounty", "board:<id>", "diff:<x>", "weight:<n>"]`. `npcViewId: "bounty_board"` keeps bounties out of the normal quest log until accepted; `visibility.hidden` + `autoClaimRewards` complete the shape. All of this lives in the two `QuestTemplates`, so each bounty file is ~10 lines (extends + params + amount override + rewards). The `{{boards}}` param becomes the single `board:<id>` tag, so a bounty belongs to exactly one board; author separate files for separate boards.
- **A board** (`BountyBoards/<Id>.json`) declares rotation cadence, selection algorithm, and slots; `BountyService` deterministically picks one bounty per slot per period (seeded by the epoch-period), so every player sees the same board with zero persisted state. Optional fields: `titleKey`, `descriptionKey` (page subtitle), `order` (sort + default-board pick), `enabled` (per-board on/off), `rerollCost`, `requiresFeatures`.
- **Several boards per world, one block each.** Each board has its own placeable block. The block's `BlockType.Interactions.Use` names a `RootInteraction` whose single entry is the **object form** `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`. The mod's `BountyBoardOpenInteraction` reads that `Board` field and opens that board; the bare-string form `["mmo_bounty_board_open"]` falls back to the default board. This is why N boards in a world is N blocks + N RootInteractions, but still one Java interaction type.
- **Reward currency** is `bounty_token` (counter-backed). Reroll costs tokens (per board, e.g. 50 daily / 100 weekly).

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

## Build & deploy

```powershell
& 'D:\dev\business\hyMMO\bounty-contracts-pack\build.ps1'
```

`build.ps1` zips with forward-slash entries AND an explicit directory entry for every ancestor path (Java's `ZipFileSystem.isDirectory()` returns false without them, so Hytale's `I18nModule.loadMessagesFromPack` would skip `items.lang`). Never use `Compress-Archive` (it writes backslash separators Hytale drops). The script copies the zip into `D:\Games\Hytale\UserData\Mods`.

Start the server with both the mod jar and this zip in `Mods/`. Confirm in the log: `[AssetPacks] Bounty-board pack layer applied (2 entries, mode=add)` plus the Quests/QuestTemplates/Currencies layers and the `Bounty validation: ...` summary, and no `Asset validation FAILED`. In-game: craft + place a board block and interact, or `/mmobountyui <you> daily`.

## Conventions (shared with the mastery pack)

Filenames PascalCase (the asset key). `Name` is a human echo consumed by a no-op setter. `Payload` is a nested JSON object (not an escaped string). Quest/board ids come from the inner `Payload.id` / the filename respectively. Item + RootInteraction JSON keys start upper-case (Hytale codec requirement). See `skill-mastery-pack/CLAUDE.md` for the full template-DSL reference.
