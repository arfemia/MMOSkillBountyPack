# MMO Skill Bounty Pack

A free content pack for [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree). It adds a rotating **Bounty Board**: daily and weekly contracts you pick up in the world, complete anywhere, and cash in for Bounty Tokens plus skill XP.

Requires the MMO Skill Tree mod. The pack supplies the content; the mod supplies the board engine, so install both.

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/5NFdZsUxHZ) [![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ziggfreed) [![Documentation](https://img.shields.io/badge/Docs-Read%20More-0ea5e9?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com)

---

[![Host your own Hytale server with Kinetic Hosting](https://i.imgur.com/UHn3FzW.png)](https://billing.kinetichosting.com/aff.php?aff=1262)

---

## What it adds

- **Daily Bounty Board** - a rotating mix of kill, gather, mine-and-deliver, and train-a-skill contracts that refresh every day, sending you after creatures from desert scorpions and cave raptors to swamp crocodiles, sabertooths, and ghouls.
- **Weekly Bounty Board** - tougher, higher-paying contracts that refresh every week, including marquee boss hunts (the Goblin Duke, the Shadow Knight, the Scarak Broodmother, and an aberrant horror) that pay out bigger than a regular hard contract.
- **Delivery and mine-and-deliver contracts** - some contracts ask you to hand in gathered materials (like Life Essence or ore) at the board, and many mining contracts now end by delivering a share of what you dug, not just breaking blocks.
- **Bounty Tokens** - the reward currency, earned from contracts, spent at the shops, and used to reroll contracts and featured offers.
- **Shops** - a placeable Token Trader block (or NPC) opens the shop: spend Bounty Tokens across two storefronts, the general **Token Shop** (XP boosts, item caches, currency conversions, and a rotating Featured shelf you can reroll) and a per-skill **XP Exchange**.
- **Placeable blocks** - spawn a Daily Bounty Board, a Weekly Bounty Board, and a Token Trader, mount them on a wall anywhere, and each opens its own menu.
- **Works from spawn with no setup** - the mod places its **Adventurer's Guide** NPC at your world spawn automatically; with this pack installed its hub lists every board and the shops, so players can reach bounties out of the box without anyone placing a block. Walk up, press the interact key, and pick a board or a shop.
- **Bounty achievements** - completing contracts unlocks achievement chains, including per-board Daily and Weekly ladders.
- **Fully translated** - every contract name, board and shop description, offer, block, and NPC name ships in 9 languages (English, German, Spanish, French, Hungarian, Italian, Brazilian Portuguese, Russian, Turkish); anything a translation misses falls back to English.

## How it works

- Every player sees the same board each rotation, so the day's (and week's) contracts are shared across the server.
- Spawn and place a Bounty Board block (or have an admin give you one), interact with it, and a clean menu lists each contract's task, difficulty, and reward. Accept the ones you want; they auto-claim the moment you finish.
- Running a bigger world? Stand up several boards: put the daily board in the town square and the weekly board at the guild hall. Each block opens the board it belongs to.
- Don't like a contract? Reroll just that one - it swaps for a fresh contract while the rest of the board stays - up to a daily cap (rerolls cost Bounty Tokens).
- Tougher contracts ask for a minimum combat level before you can accept them, so hard work stays aspirational; contracts above your level show as locked until you train up.
- The mod's **Adventurer's Guide** is placed at your world spawn the first time someone joins, so bounties just work with no setup. It appears once per world and never duplicates on restart. Prefer to place things yourself? You can also stand up dedicated NPCs anywhere with `/mmonpc spawn` (a hub, a single board, or the Token Trader).

## Don't want the spawn NPC?

It's easy to opt out, and you only have to do it once:

- **Before anyone joins:** set `"enabled": false` in `mods/mmoskilltree/spawn-hub.json` and it will never spawn.
- **Already in your world?** Remove it once and it won't come back: run `/mmonpc list` to find its id, then `/mmonpc remove <id>`. (Changed your mind later? `/mmonpc reset` lets it spawn again on the next join.)
- **Or use the in-game editor:** with creative/builder access, the native `EditorTool_Entity` tool deletes the NPC in the world like any other entity. It won't respawn (it only spawns once per world).

Either way, the placeable Bounty Board and Token Trader blocks keep working exactly the same, so you lose nothing by removing the NPC.

## Install

1. Install the MMO Skill Tree mod.
2. Drop `MMOSkillBountyPack-1.1.0.zip` into your server's `Mods/` folder, alongside the mod.
3. Start the server. Bounties are on by default; a server owner can turn the whole feature on or off from the in-game admin menu.

## Make your own contracts and boards

Bounties and boards are plain pack files: add a contract by dropping in one small file, add a whole new board by dropping in another. No coding required. The pack's repository has a short authoring guide, including how to give a new board its own placeable block.

## Versions

| Pack  | Plugin | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ----- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.1.0 | 1.4.0+ | Adds an all-at-once **Daily Contracts** board and a fast-rotating **Quick Contracts** board carrying the everyday contracts that moved out of the mod, plus place / fish / harvest / spend contract types and a Market Patron "spend at the shop" contract. These boards are XP-focused (minimal to no Bounty Tokens), so the Daily and Weekly boards stay the token source. Requires MMO Skill Tree 1.4.0.                                                                                                                                                                      |
| 1.0.0 | 1.3.0+ | First release. Daily and Weekly Bounty Boards with a wide bestiary and marquee boss hunts, Bounty Tokens, mine-and-deliver and turn-in contracts, per-contract rerolls with a daily cap, two shop storefronts (the Token Shop and a per-skill XP Exchange) behind a Token Trader block/NPC, per-difficulty combat-level gating on harder contracts, bounty achievement chains (including per-board Daily and Weekly ladders), full 9-language translations, and spawn integration with the mod's Adventurer's Guide NPC (opt out in `spawn-hub.json` or remove it once in-game). |

---

## Links & Support

[![MMO Skill Tree](https://img.shields.io/badge/CurseForge-MMO%20Skill%20Tree-F16436?style=for-the-badge&logo=curseforge&logoColor=white)](https://www.curseforge.com/hytale/mods/mmo-skill-tree) [![Get Pro Edition](https://img.shields.io/badge/Get%20Pro%20Edition-F59E0B?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com/commercial)

Questions or suggestions? Join the [Discord](https://discord.gg/5NFdZsUxHZ) or leave a comment!

**Support Development:** [Ko-fi](https://ko-fi.com/ziggfreed) | [Buy Me a Coffee](https://buymeacoffee.com/wintergreensolutions)

_MMO Skill Tree is not affiliated with Hypixel Studios or Hytale._
