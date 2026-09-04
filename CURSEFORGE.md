# MMO Skill Bounty Pack

A free content pack for [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree). It adds a rotating **Bounty Board**: daily and weekly contracts you pick up in the world, complete anywhere, and cash in for Bounty Tokens plus skill XP.

Requires the MMO Skill Tree mod and its ZiggfreedCommon library. The pack supplies the content; the board and shop engines ship with the mod and its library, so install all three.

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/5NFdZsUxHZ) [![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ziggfreed) [![Documentation](https://img.shields.io/badge/Docs-Read%20More-0ea5e9?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com)

---

[![Host your own Hytale server with Kinetic Hosting](https://i.imgur.com/UHn3FzW.png)](https://billing.kinetichosting.com/aff.php?aff=1262)

---

## What it adds

- **78 contracts across three boards.** The Daily board posts a fresh mix every day: kill, gather, mine-and-deliver, hand-in and train-a-skill work, sending you after desert scorpions, cave raptors, swamp crocodiles, sabertooths and ghouls.
- The Weekly board is the heavy end. Tougher targets, much bigger payouts, and marquee boss hunts: the Goblin Duke, the Shadow Knight, the Scarak Broodmother, an aberrant horror. Beside them sits an open warrant on any boss fight: whichever scripted boss your server stands up, bringing it down settles the contract for everyone who fought it, whoever landed the last blow. The Daily board carries a muster-roll contract for standing in a boss fight to the end, win or lose.
- A third board turns over every two hours with one quick contract on it. Small, fast jobs that pay skill XP.
- Some contracts want the goods back. You hand in ore or Life Essence at the board; mining contracts usually end with you delivering a share of what you dug.
- **Bounty Tokens** are the reward currency. Contracts pay them, the shops take them, and rerolls cost them.
- Two storefronts behind a placeable Token Trader block or an NPC: the Token Shop (XP boosts, item crates, a rotating Featured shelf you can reroll) and a per-skill XP Exchange that puts one packet of each size on sale a day.
- Placeable blocks for all three boards and the trader. Mount them on a wall anywhere and each opens its own menu.
- Nothing to set up. The mod puts its Adventurer's Guide at world spawn, and with this pack installed its hub lists every board and both shops, so players reach bounties without anyone placing a block.
- Achievement chains for completing contracts, including per-board Daily, Weekly and Quick ladders and a Snapdragon hunter chain.
- Every contract name, board and shop description, offer, block and NPC name ships in 9 languages (English, German, Spanish, French, Hungarian, Italian, Brazilian Portuguese, Russian, Turkish). Anything a translation misses falls back to English.

## How it works

- Every player sees the same board each rotation, so the day's (and week's) contracts are shared across the server.
- Place a Bounty Board block (or have an admin give you one) and interact with it. A clean menu lists each contract's task, difficulty and reward. Accept the ones you want.
- Finished contracts wait for you at the board. They never pay out in the field, so a full inventory or the board rotating can't cost you a reward: walk back, make room if you need to, press Claim.
- Running a bigger world? Stand up several boards: put the daily board in the town square and the weekly board at the guild hall. Each block opens the board it belongs to.
- Don't like a contract? Reroll just that one - it swaps for a fresh contract while the rest of the board stays - up to a daily cap (rerolls cost Bounty Tokens).
- Tougher contracts ask for a minimum combat level before you can accept them. You still see them, marked locked, so you know what to train towards.
- The mod's **Adventurer's Guide** is placed at your world spawn the first time someone joins, so bounties just work with no setup. It appears once per world and never duplicates on restart.

## Don't want the spawn NPC?

It's easy to opt out, and you only have to do it once:

- **Before anyone joins:** set `"enabled": false` for `mmo_hub` in `mods/ziggfreedcommon/npc-placements.json` and it will never spawn.
- **Already in your world?** Run `/mmonpc list` to confirm its id, then `/mmonpc disable --arg1=mmo_hub` - it despawns right away and stays gone. Changed your mind? `/mmonpc enable --arg1=mmo_hub` brings it back.

Either way, the placeable Bounty Board and Token Trader blocks keep working exactly the same, so you lose nothing by removing the NPC.

## Install

1. Install the MMO Skill Tree mod and the ZiggfreedCommon library it loads first.
2. Drop `MMOSkillBountyPack-1.2.1.zip` into your server's `Mods/` folder, alongside them.
3. Start the server. Bounties are on by default; a server owner can turn the whole feature on or off from the in-game admin menu.

## Make your own contracts and boards

Contracts, boards, shops and offers are plain pack files: add a contract by dropping in one small file, add a whole new board by dropping in another. No coding required. Retuning what ships here is the same move: drop in a file with the same name and change the one number you care about, and everything you left out stays as it was. The pack's repository has a short authoring guide, including how to give a new board its own placeable block.

## Versions

| Pack  | Plugin | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ----- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.2.1 | 1.6.1+ | Adds two boss-fight contracts on the game's encounter scripts: an **Open Warrant** on the Weekly board (bring down any scripted boss, credited to everyone who fought it, whoever landed the last blow) and **The Muster Roll** on the Daily board (stand in a boss fight to the end, win or lose). Both work with whichever boss your server stands up, from a companion pack or from anyone else's. Fixes the six broker NPCs' environmental immunity and the hub screen's doubled title line. Requires ZiggfreedCommon 2.1.0 beside MMO Skill Tree 1.6.1. |
| 1.2.0 | 1.6.0+ | Internal rewrite with the same contracts on the boards: the whole catalogue (76 contracts, three boards, both shops, their shelves and offers, both wallets, and the achievement ladders) moves onto the shared engine that ships with ZiggfreedCommon 2.0.0+. Authoring gets simpler with it: one file per thing, the file name is its id, and overriding anything shipped here means dropping in a file with the same name. Also in this release: the Featured Fisher's Haul cache costs 24 Fire Essence alongside its 160 Bounty Tokens, the shops and the daily board show every wallet they deal in (Bounty Tokens beside Life Essence), and the Token Shop lists its categories in a chosen order rather than alphabetically. |
| 1.1.2 | 1.4.3+ | Adds five new contracts and replaces the Risen daily contract with a marquee **Snapdragon** hunt: Burnt Skeletons and a wild Boar hunt on the Daily board, Sandswept Skeletons and a frost-bound skeleton host on the Weekly board, and a fast zombie cull on the Quick board. Adds two achievement chains: **Snapdragon Slayer / Bane** for completing the Snapdragon contract, and a **Quick Contractor** ladder for the Quick board. Fully translated in all 9 languages. Requires MMO Skill Tree 1.4.3.                                                                                                                                                                                     |
| 1.1.1 | 1.4.3+ | Contracts are always claimed at the Bounty Board now, never granted out in the field, so a finished contract's reward can no longer be lost to a full inventory or to the contract rotating off the board. Requires MMO Skill Tree 1.4.3.                                                                                                                                                                                                                                                                                                                              |
| 1.1.0 | 1.4.0+ | Adds an all-at-once **Daily Contracts** board and a fast-rotating **Quick Contracts** board carrying the everyday contracts that moved out of the mod, plus place / fish / harvest / spend contract types and a Market Patron "spend at the shop" contract. These boards are XP-focused (minimal to no Bounty Tokens), so the Daily and Weekly boards stay the token source. Requires MMO Skill Tree 1.4.0.                                                                                                                                                                      |
| 1.0.0 | 1.3.0+ | First release. Daily and Weekly Bounty Boards with a wide bestiary and marquee boss hunts, Bounty Tokens, mine-and-deliver and turn-in contracts, per-contract rerolls with a daily cap, two shop storefronts (the Token Shop and a per-skill XP Exchange) behind a Token Trader block/NPC, per-difficulty combat-level gating on harder contracts, bounty achievement chains (including per-board Daily and Weekly ladders), full 9-language translations, and spawn integration with the mod's Adventurer's Guide NPC (opt out in `spawn-hub.json` or remove it once in-game). |

---

## Links & Support

[![MMO Skill Tree](https://img.shields.io/badge/CurseForge-MMO%20Skill%20Tree-F16436?style=for-the-badge&logo=curseforge&logoColor=white)](https://www.curseforge.com/hytale/mods/mmo-skill-tree) [![Get Pro Edition](https://img.shields.io/badge/Get%20Pro%20Edition-F59E0B?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com/commercial)

Questions or suggestions? Join the [Discord](https://discord.gg/5NFdZsUxHZ) or leave a comment!

**Support Development:** [Ko-fi](https://ko-fi.com/ziggfreed) | [Buy Me a Coffee](https://buymeacoffee.com/wintergreensolutions)

_MMO Skill Tree is not affiliated with Hypixel Studios or Hytale._
