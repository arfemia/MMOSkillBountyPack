# MMO Skill Bounty Pack

A free content pack for [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree). It adds a rotating **Bounty Board**: daily and weekly contracts you pick up in the world, complete anywhere, and cash in for Bounty Tokens plus skill XP.

Requires the MMO Skill Tree mod. The pack supplies the content; the mod supplies the board engine, so install both.

## What it adds

- **Daily Bounty Board** - a handful of kill, gather, and train-a-skill contracts that refresh every day.
- **Weekly Bounty Board** - tougher, higher-paying contracts that refresh every week.
- **Delivery contracts** - some contracts ask you to hand in gathered materials (like Life Essence or ore) at the board instead of killing or mining.
- **Bounty Tokens** - the reward currency, earned from contracts, spent at the shops, and used to reroll contracts and featured offers.
- **Shops** - a placeable Token Trader block (or NPC) opens the shop: spend Bounty Tokens across two storefronts, the general **Token Shop** (XP boosts, item caches, currency conversions, and a rotating Featured shelf you can reroll) and a per-skill **XP Exchange**.
- **Placeable blocks** - craft a Daily Bounty Board, a Weekly Bounty Board, and a Token Trader, mount them on a wall anywhere, and each opens its own menu.
- **Works from spawn with no setup** - the mod places its **Adventurer's Guide** NPC at your world spawn automatically; with this pack installed its hub lists every board and the shops, so players can reach bounties out of the box without anyone placing a block. Walk up, press the interact key, and pick a board or a shop.
- **Bounty achievements** - completing contracts unlocks achievement chains, including per-board Daily and Weekly ladders.
- **Fully translated** - every contract name, board and shop description, offer, block, and NPC name ships in 9 languages (English, German, Spanish, French, Hungarian, Italian, Brazilian Portuguese, Russian, Turkish); anything a translation misses falls back to English.

## How it works

- Every player sees the same board each rotation, so the day's (and week's) contracts are shared across the server.
- Craft and place a Bounty Board block (or have an admin give you one), interact with it, and a clean menu lists each contract's task, difficulty, and reward. Accept the ones you want; they auto-claim the moment you finish.
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
2. Drop `MMOSkillBountyPack-1.0.0.zip` into your server's `Mods/` folder, alongside the mod.
3. Start the server. Bounties are on by default; a server owner can turn the whole feature on or off from the in-game admin menu.

## Make your own contracts and boards

Bounties and boards are plain pack files: add a contract by dropping in one small file, add a whole new board by dropping in another. No coding required. The pack's repository has a short authoring guide, including how to give a new board its own placeable block.

## Versions

| Pack  | Plugin | Notes |
| ----- | ------ | ----- |
| 1.0.0 | 1.3.0+ | First release. Daily and Weekly Bounty Boards, Bounty Tokens, delivery (turn-in) contracts, per-contract rerolls with a daily cap, two shop storefronts (the Token Shop and a per-skill XP Exchange) behind a Token Trader block/NPC, per-difficulty combat-level gating on harder contracts, bounty achievement chains (including per-board Daily and Weekly ladders), full 9-language translations, and spawn integration with the mod's Adventurer's Guide NPC (opt out in `spawn-hub.json` or remove it once in-game). |
