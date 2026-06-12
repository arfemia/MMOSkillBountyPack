# MMO Skill Bounty Pack

A standalone Hytale content pack for the [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree) mod (1.3.0+). It ships the entire **Bounty Board** and **Token Shop** content: a daily and a weekly board, the bounty pool (with localized titles + flavor), reusable templates, the Bounty Token currency, a token-shop catalog plus a rotating **Featured** pool, and the in-world blocks (all wall posters).

The mod jar ships only the *engine* (services, configs, page UIs, and the registered interaction types). It ships no content, so this pack is what makes bounties and the shop appear. It is a **hard dependency** on the mod, declared in `manifest.json`.

## What is inside

| Path | What it is |
|------|------------|
| `Server/Item/Items/MMO_Bounty_Board*.json`, `MMO_Token_Trader.json` | The placeable board + trader blocks (wall posters) |
| `Server/Item/RootInteractions/*.json` | Each block's interaction, carrying the board / pool id it opens |
| `Server/Languages/en-US/items.lang` | Block names, descriptions, and interaction hints |
| `Server/Languages/en-US/mmoskilltree.lang` | Bounty titles + flavor (`quest.<id>.title` / `.flavor`) |
| `Server/MMOSkillTree/BountyBoards/*.json` | The board schedules (rotation, selection, slots) |
| `Server/MMOSkillTree/Quests/Bounty_*.json` | The bounty pool (daily + weekly; kill / gather / train / deliver) |
| `Server/MMOSkillTree/QuestTemplates/*.json` | Reusable contract skeletons so each bounty is a few lines |
| `Server/MMOSkillTree/Currencies/Bounty_Token.json` | The reward currency |
| `Server/MMOSkillTree/ShopEntries/*.json` | Token-shop offers (static catalog + `Featured_*` pooled) |
| `Server/MMOSkillTree/ShopTemplates/*.json` | Reusable shop-offer skeletons (`extends` + `params`) |
| `Server/MMOSkillTree/ShopPools/Featured.json` | The rotating "Featured" token-shop pool (schedule + reroll) |
| `Server/NPC/Roles/Passive/MMO_Bounty_Master.json` (+ `MMO_Bounty_Daily`/`Weekly`, `MMO_Token_Trader_NPC`) | The press-F "open MMO UI" NPC roles: a hub auto-spawned at world spawn, plus per-board + shop NPCs you hand-place |
| `Server/Languages/en-US/npcs.lang` | NPC display names + interact hints |

## Build

```powershell
.\build.ps1                  # build the zip, and install it if a Mods folder is known
.\build.ps1 -Install:$false  # build only, no copy
```

Produces `MMOSkillBountyPack.zip` (forward-slash entries plus explicit directory entries, which the bundled `.lang` file needs). The script is cross-platform (`pwsh ./build.ps1` works on macOS/Linux). To have it also copy the zip into your Hytale `Mods/` folder, set `HYTALE_MODS_DIR` once to that folder (or pass `-ModsDir <path>`); without it the script just builds the zip. Start a server with both the mod jar and this zip in `Mods/`, then craft and place a board block in the world, or use `/mmobountyui <player> daily` (console/admin).

## Multiple boards in one world

Each board has its own placeable block. The block's interaction reads the board id from its `RootInteraction` (object form `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`), so a single interaction type backs any number of boards with no extra code. Ship one block plus one board per location.

## Author your own

- **A bounty** is a repeatable quest that extends one of the templates and self-enrolls in a board pool by tag (`board:<id>`, `diff:<x>`, `weight:<n>`). Give it a `quest.<id>.title` + `quest.<id>.flavor` in `mmoskilltree.lang`, and reward both `bounty_token` + `XP`.
- **A board** is a schedule file under `BountyBoards/`; its filename (lowercased) is the board id.
- **A shop offer** is a file under `ShopEntries/` (static by default; add `"pool": "<id>"` to rotate it). **A shop pool** is a schedule file under `ShopPools/` with the same rotation/selection/reroll shape as a board.
- **A spawn NPC** is a native Hytale role under `Server/NPC/Roles/Passive/` whose `InteractionInstruction` runs the mod's `{ "Type": "OpenMmoUi", "Target": "<hub|shop|boardId>" }` action on press-F. The hub (`MMO_Bounty_Master`) auto-spawns at world spawn (toggle in `mods/mmoskilltree/spawn-hub.json`; an owner can remove it once via `/mmonpc remove <id>`, the native `EditorTool_Entity` creative tool, or by disabling it before first join). Add a board NPC by copying `MMO_Bounty_Daily.json` → `MMO_Bounty_<X>.json`, setting `Target` to the board id, and adding the name to `npcs.lang` (`/mmonpc spawn board <x>` resolves role `MMO_Bounty_<X>` by convention).
- Run `/mmobounty validate` and `/mmoshop validate` (console/admin) to catch empty pools, unfillable slots, orphaned offers, malformed icons, or missing currencies before you ship.

See [CLAUDE.md](CLAUDE.md) for the full authoring guide and JSON examples.

## Requires

MMO Skill Tree 1.3.0 or newer.
