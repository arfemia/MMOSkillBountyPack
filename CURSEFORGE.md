# MMO Skill Bounty Pack

A free content pack for [MMO Skill Tree](https://www.curseforge.com/hytale/mmoskilltree). It adds a rotating **Bounty Board**: daily and weekly contracts you pick up in the world, complete anywhere, and cash in for Bounty Tokens plus skill XP.

Requires the MMO Skill Tree mod. The pack supplies the content; the mod supplies the board engine, so install both.

## What it adds

- **Daily Bounty Board** - a handful of kill, gather, and train-a-skill contracts that refresh every day.
- **Weekly Bounty Board** - tougher, higher-paying contracts that refresh every week.
- **Delivery contracts** - some contracts ask you to hand in gathered materials (like Life Essence or ore) at the board instead of killing or mining.
- **Bounty Tokens** - the reward currency, earned from contracts, spent at the Token Shop, and used to reroll a board for a fresh set.
- **Token Shop** - a placeable Token Trader block that opens a shop where you spend Bounty Tokens on XP boosts and ore caches.
- **Placeable blocks** - craft a Daily Bounty Board, a Weekly Bounty Board, and a Token Trader, mount them on a wall anywhere, and each opens its own menu.
- **Bounty achievements** - completing contracts unlocks achievement chains, including per-board Daily and Weekly ladders.

## How it works

- Every player sees the same board each rotation, so the day's (and week's) contracts are shared across the server.
- Craft and place a Bounty Board block (or have an admin give you one), interact with it, and a clean menu lists each contract's task, difficulty, and reward. Accept the ones you want; they auto-claim the moment you finish.
- Running a bigger world? Stand up several boards: put the daily board in the town square and the weekly board at the guild hall. Each block opens the board it belongs to.
- Out of options on a board? Reroll it for a new set of contracts (costs Bounty Tokens).
- Tougher contracts ask for a minimum combat level before you can accept them, so hard work stays aspirational; contracts above your level show as locked until you train up.

## Install

1. Install the MMO Skill Tree mod.
2. Drop `MMOSkillBountyPack-1.0.0.zip` into your server's `Mods/` folder, alongside the mod.
3. Start the server. Bounties are on by default; a server owner can turn the whole feature on or off from the in-game admin menu.

## Make your own contracts and boards

Bounties and boards are plain pack files: add a contract by dropping in one small file, add a whole new board by dropping in another. No coding required. The pack's repository has a short authoring guide, including how to give a new board its own placeable block.

## Versions

| Pack  | Plugin | Notes |
| ----- | ------ | ----- |
| 1.0.0 | 1.2.1+ | First release. Daily and Weekly Bounty Boards, Bounty Tokens, delivery (turn-in) contracts, a Token Shop with a Token Trader block, per-difficulty combat-level gating on harder contracts, and bounty achievement chains (including per-board Daily and Weekly ladders). |
