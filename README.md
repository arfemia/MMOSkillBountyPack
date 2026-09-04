# MMO Skill Bounty Pack

A standalone Hytale content pack for the [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree) mod (1.6.1+) and ZiggfreedCommon (2.1.0+). It ships the entire **bounty board** and **shop** content: three boards (Daily, Weekly, and a fast-rotating Bihourly), the contract pool with localized titles and flavor, the reusable contract skeletons, the Bounty Token and Life Essence wallets, two storefronts with their rotating shelves and offers, and the in-world blocks (all wall posters).

The mod jar and ZiggfreedCommon ship the *engines* (the commerce module, the pages, the registered interaction types, the commands). They ship no content, so this pack is what makes bounties and shops appear. It is a **hard dependency** on both, declared in `manifest.json`.

## What is inside

| Path | What it is |
|------|------------|
| `Server/Item/Items/MMO_Bounty_Board*.json`, `MMO_Token_Trader.json` | The placeable board + trader blocks (wall posters) |
| `Server/Item/RootInteractions/*.json` | Each block's interaction, carrying the board id it opens |
| `Server/Languages/<bcp47>/items.lang` | Block names, descriptions, and interaction hints |
| `Server/Languages/<bcp47>/mmoskilltree.lang` | Contract, offer and wallet text, in 9 locales |
| `Server/Languages/<bcp47>/npcs.lang` | NPC display names + interact hints |
| `Server/NPC/Roles/Passive/*.json` | The press-F "open a page" NPC roles, per board and per shop |
| `Server/MMOSkillTree/Control/*.json` | Names the stores the MOD itself owns; this pack ships none |
| `Server/ZiggfreedCommon/Boards/MMOSkillTree/*.json` | The board schedules (cadence, selection, slots, per-band gates) |
| `Server/ZiggfreedCommon/Bounties/MMOSkillTree/*.json` | Ten Abstract contract skeletons plus the 78 contracts |
| `Server/ZiggfreedCommon/Currencies/MMOSkillTree/*.json` | The two wallets |
| `Server/ZiggfreedCommon/Shops/MMOSkillTree/*.json` | The two storefronts |
| `Server/ZiggfreedCommon/ShopPools/MMOSkillTree/*.json` | The rotating shelves (schedule + reroll) |
| `Server/ZiggfreedCommon/ShopEntries/MMOSkillTree/*.json` | The offers, static and pooled, plus one Abstract skeleton |
| `Server/ZiggfreedCommon/ShopEntryGenerators/MMOSkillTree/*.json` | One file that writes the whole per-skill experience-packet family |
| `Server/ZiggfreedCommon/Achievements/MMOSkillTree/Bounty/*.json` | The per-board and creature achievement chains |

Everything under `Server/ZiggfreedCommon/` merges **by id**, and the FILE NAME is the id. Override anything shipped by anybody by dropping in a file of the same id; take one out with `"Enabled": false`.

## Build

```powershell
.\build.ps1                  # build the zip, and install it if a Mods folder is known
.\build.ps1 -Install:$false  # build only, no copy
```

Produces `MMOSkillBountyPack.zip` (forward-slash entries plus explicit directory entries, which the bundled `.lang` files need). The script is cross-platform (`pwsh ./build.ps1` works on macOS/Linux). To have it also copy the zip into your Hytale `Mods/` folder, set `HYTALE_MODS_DIR` once to that folder (or pass `-ModsDir <path>`). Start a server with the mod jar, the ZiggfreedCommon jar and this zip in `Mods/`, then craft and place a board block, or use `/mmobountyui <player> daily` (console/admin).

## Multiple boards in one world

Each board has its own placeable block. The block's interaction reads the board id from its `RootInteraction` (object form `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`), so one interaction type backs any number of boards with no extra code. Ship one block plus one board per location.

## Author your own

- **A contract** is a file under `Bounties/MMOSkillTree/` naming one of the ten skeletons as its `Parent`, its board memberships as `Boards`, and its steps and pay. Give it a `quest.<id>.title` and `quest.<id>.flavor` in `mmoskilltree.lang`, and reward both a `Currency` and an `Mmo_Xp` payout. A boss contract (`Bounty_Encounter`) names an encounter script id, or no target at all for any boss, and pays everyone the fight credited.
- **A board** is a schedule file under `Boards/MMOSkillTree/`; its file name is the board id contracts name.
- **An offer** is a file under `ShopEntries/MMOSkillTree/` (static by default; add a `Pool` group to rotate it). **A shelf** is a schedule file under `ShopPools/MMOSkillTree/` with the same cadence, selection and reroll shape a board uses. **A family of near-identical offers** is one file under `ShopEntryGenerators/MMOSkillTree/`.
- **A broker NPC** is a native Hytale role under `Server/NPC/Roles/Passive/`, and it decides only the look, the nameplate and the press-F prompt. Which screen opens comes from the **placement** that stands the character up, so this pack ships the six roles and no placements: none of them appears until you author one at `Server/ZiggfreedCommon/NpcPlacements/<YourId>.json` naming a role plus `"Interact": {"Open": {"Type": "Mmo_Board", "Board": "Daily"}}` (or `"Mmo_Shop"` with a `Shop`). Each role file's `$Comment` carries the full recipe with its own id filled in. Manage what is standing with `/mmonpc list|enable|disable`.
- Run `/mmobounty validate` and `/mmoshop validate` (console/admin) to catch empty pools, unfillable slots, orphaned contracts or offers, malformed icons, and missing currencies before you ship.

See [CLAUDE.md](CLAUDE.md) for the full authoring guide and JSON examples.

## Requires

MMO Skill Tree 1.6.1 or newer, and ZiggfreedCommon 2.1.0 or newer.
