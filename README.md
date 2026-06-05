# MMO Skill Bounty Pack

A standalone Hytale content pack for the [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree) mod (1.2.1+). It ships the entire **Bounty Board** feature's content: a daily and a weekly board, the bounty pool, reusable templates, the Bounty Token currency, and the in-world board blocks.

The mod jar ships only the Bounty Board *engine* (the service, config, page UI, and the registered interaction type). It ships no bounty content, so this pack is what makes bounties appear. It is a **hard dependency** on the mod, declared in `manifest.json`.

## What is inside

| Path | What it is |
|------|------------|
| `Server/Item/Items/MMO_Bounty_Board*.json` | The placeable Daily and Weekly board blocks |
| `Server/Item/RootInteractions/*.json` | Each block's interaction, carrying the board id it opens |
| `Server/Languages/en-US/items.lang` | Block names, descriptions, and interaction hints |
| `Server/MMOSkillTree/BountyBoards/*.json` | The board schedules (rotation, selection, slots) |
| `Server/MMOSkillTree/Quests/Bounty_*.json` | The bounty pool (daily + weekly, kill + gather) |
| `Server/MMOSkillTree/QuestTemplates/*.json` | Reusable contract skeletons so each bounty is a few lines |
| `Server/MMOSkillTree/Currencies/Bounty_Token.json` | The reward currency |

## Build

```powershell
& .\build.ps1
```

Produces `MMOSkillBountyPack.zip` (forward-slash entries plus explicit directory entries, which the bundled `.lang` file needs) and copies it into the local Hytale `Mods/` folder. Start a server with both the mod jar and this zip in `Mods/`, then craft and place a board block in the world, or use `/mmobountyui <player> daily` (console/admin).

## Multiple boards in one world

Each board has its own placeable block. The block's interaction reads the board id from its `RootInteraction` (object form `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`), so a single interaction type backs any number of boards with no extra code. Ship one block plus one board per location.

## Author your own

- **A bounty** is a repeatable quest that extends one of the templates and self-enrolls in a board pool by tag (`board:<id>`, `diff:<x>`, `weight:<n>`).
- **A board** is a schedule file under `BountyBoards/`; its filename (lowercased) is the board id.
- Run `/mmobounty validate` (console/admin) to catch empty pools, unfillable slots, or missing currencies before you ship.

See [CLAUDE.md](CLAUDE.md) for the full authoring guide and JSON examples.

## Requires

MMO Skill Tree 1.2.1 or newer.
