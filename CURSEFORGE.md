# MMO Skill Bounty Pack

A free content pack for [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree). It adds a rotating **Bounty Board**: daily and weekly contracts you pick up in the world, complete anywhere, and cash in for Bounty Tokens plus skill XP or a Skill Lamp.

Requires a Hytale Update 7 server, MMO Skill Tree 1.7.1 or newer and Ziggfreed's CommonLib 2.3.0 or newer. The pack supplies the content; the board and shop engines ship with the mod and its library, so install all three.

[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/5NFdZsUxHZ) [![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ziggfreed) [![Documentation](https://img.shields.io/badge/Docs-Read%20More-0ea5e9?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com)

---

[![Host your own Hytale server with Kinetic Hosting](https://i.imgur.com/UHn3FzW.png)](https://billing.kinetichosting.com/aff.php?aff=1262)

---

## What it adds

- **80 contracts across three boards.** The Daily board posts a fresh mix every day: kill, gather, mine-and-deliver, hand-in and train-a-skill work, sending you after desert scorpions, cave raptors, swamp crocodiles and sabertooths.
- The Weekly board is the heavy end. Tougher targets, much bigger payouts, two marquee boss hunts, the Voidtaken Grizzly and the Scarak Broodmother, and a warrant on the Feastmaster, the boss of the goblin Deepworks. To reach it, craft the Deepworks fragment at the Goblin Tinkerer's Workbench in the goblin lab beyond the Forgotten Temple, then place it in an Ancient Gateway and step through. Beside them sits an open warrant on any boss fight: whichever scripted boss your server stands up, bringing it down settles the contract for everyone who fought it, whoever landed the last blow. The Daily board carries a muster-roll contract for standing in a boss fight to the end, win or lose.
- A third board turns over every two hours with one quick contract on it. Small, fast jobs that pay skill XP or a Skill Lamp.
- **Haunt contracts for Hallow's Eve.** Install the Seasons of Orbis pack, whose first yearly event is Hallow's Eve, and the Daily board posts one more contract each day while the event runs, sending you after Hollow Ghouls, Jack Skeletons and Lost Souls for Bounty Tokens and a Skill Lamp, plus a few Hallow Sweets. It sits in a Seasonal slot at the end of the board, so the regular contracts stay as they are, and outside the event the slot is empty.
- Some contracts want the goods back. You hand in ore or Essence of Life at the board; mining contracts usually end with you delivering a share of what you dug.
- **Bounty Tokens** are the reward currency. Contracts pay them, the shops take them, and rerolls cost them.
- Hunting contracts also hand you a Skill Lamp. Rub it and choose the combat skill that gets the XP, so it goes to the weapon you fight with.
- Two storefronts behind a placeable Token Trader block or an NPC: the Token Shop (XP boosts, item crates, a rotating Featured shelf you can reroll) and a per-skill XP Exchange that puts one packet of each size on sale a day.
- Placeable blocks for all three boards and the trader. Mount them on a wall anywhere and each opens its own menu.
- Nothing to set up. The mod puts its Adventurer's Guide at world spawn, and with this pack installed its hub lists every board and both shops, so players reach bounties without anyone placing a block.
- Achievement chains for completing contracts, including per-board Daily, Weekly and Quick ladders and a Snapdragon hunter chain.
- Every contract name, board and shop description, offer, block and NPC name ships in 9 languages (English, German, Spanish, French, Hungarian, Italian, Brazilian Portuguese, Russian, Turkish). Anything a translation misses falls back to English.

## How it works

- Every player sees the same board each rotation, so the day's (and week's) contracts are shared across the server.
- Place a Bounty Board block (or have an admin give you one) and interact with it. A clean menu lists each contract's task, difficulty and reward. Accept the ones you want.
- Finished contracts wait for you at the board. They never pay out in the field, so a full inventory or the board rotating can't cost you a reward: walk back, make room if you need to, press Collect.
- Running a bigger world? Stand up several boards: put the daily board in the town square and the weekly board at the guild hall. Each block opens the board it belongs to.
- Don't like a contract? Reroll just that one - it swaps for a fresh contract while the rest of the board stays - up to a daily cap (rerolls cost Bounty Tokens).
- Tougher contracts ask for a level before you can accept them. Most want a combat level, but the mining contracts want a Mining level: 25 for the normal ones and 60 for the hard ones. Hide Haul and Essence Consignment ask for combat level 25, and the train-a-skill contracts are open to anyone. A contract you can't take yet still shows, marked locked, so you know what to train towards.
- The mod's **Adventurer's Guide** is placed at your world spawn the first time someone joins, so bounties just work with no setup. It appears once per world and never duplicates on restart.

## Don't want the spawn NPC?

It's easy to opt out, and you only have to do it once:

- **Before anyone joins:** set `"enabled": false` for `mmo_hub` in `mods/ziggfreedcommon/npc-placements.json` and it will never spawn.
- **Already in your world?** Run `/mmonpc list` to confirm its id, then `/mmonpc disable --arg1=mmo_hub` - it despawns right away and stays gone. Changed your mind? `/mmonpc enable --arg1=mmo_hub` brings it back.

Either way, the placeable Bounty Board and Token Trader blocks keep working exactly the same, so you lose nothing by removing the NPC.

## Install

1. Install MMO Skill Tree (1.7.1 or newer) and Ziggfreed's CommonLib (2.3.0 or newer), which it loads first.
2. Drop `MMOSkillBountyPack-1.3.1.zip` into your server's `Mods/` folder, alongside them.
3. Start the server. Bounties are on by default; a server owner can turn the whole feature on or off from the in-game admin menu.

## Make your own contracts and boards

Contracts, boards, shops and offers are plain pack files: add a contract by dropping in one small file, add a whole new board by dropping in another. No coding required. Retuning what ships here is the same move: drop in a file with the same name and change the one number you care about, and everything you left out stays as it was. The pack's repository has a short authoring guide, including how to give a new board its own placeable block.

---

## Links & Support

[![MMO Skill Tree](https://img.shields.io/badge/CurseForge-MMO%20Skill%20Tree-F16436?style=for-the-badge&logo=curseforge&logoColor=white)](https://www.curseforge.com/hytale/mods/mmo-skill-tree) [![Get Pro Edition](https://img.shields.io/badge/Get%20Pro%20Edition-F59E0B?style=for-the-badge)](https://mmo-skill-tree-docs.ziggfreed.com/commercial)

Questions or suggestions? Join the [Discord](https://discord.gg/5NFdZsUxHZ) or leave a comment!

Patch notes for every version are on [GitHub](https://github.com/arfemia/MMOSkillBountyPack/tree/main/patch-notes).

**Support Development:** [Ko-fi](https://ko-fi.com/ziggfreed)

_MMO Skill Tree is not affiliated with Hypixel Studios or Hytale._
