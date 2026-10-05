# MMO Skill Bounty Pack

A standalone Hytale content pack for the [MMO Skill Tree](https://www.curseforge.com/hytale/mods/mmo-skill-tree) mod (1.6.1+) and ZiggfreedCommon (2.2.0+). It ships the entire **bounty board** and **shop** content: three boards (Daily, Weekly, and a fast-rotating Bihourly), the contract pool with localized titles and flavor, the reusable contract skeletons, the Bounty Token and Life Essence wallets, two storefronts with their rotating shelves and offers, and the in-world blocks (all wall posters).

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
| `Server/ZiggfreedCommon/Bounties/MMOSkillTree/**/*.json` | Ten Abstract contract skeletons plus the 81 contracts (the three seasonal haunt contracts in Haunt/) |
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

Produces `MMOSkillBountyPack-<version>.zip`, named from the manifest's `Version` (forward-slash entries plus explicit directory entries, which the bundled `.lang` files need). The script is cross-platform (`pwsh ./build.ps1` works on macOS/Linux). To have it also copy the zip into your Hytale `Mods/` folder, set `HYTALE_MODS_DIR` once to that folder (or pass `-ModsDir <path>`). Start a server with the mod jar, the ZiggfreedCommon jar and this zip in `Mods/`, then craft and place a board block, or use `/mmobountyui <player> --board=daily` (console/admin; the board is a named option, so a bare `daily` after the player name is rejected).

## Multiple boards in one world

Each board has its own placeable block. The block's interaction reads the board id from its `RootInteraction` (object form `{ "Type": "mmo_bounty_board_open", "Board": "<id>" }`), so one interaction type backs any number of boards with no extra code. Ship one block plus one board per location.

## Author your own

- **A contract** is a file under `Bounties/MMOSkillTree/` naming one of the ten skeletons as its `Parent`, its board memberships as `Boards`, and its steps and pay. Give it a `quest.<id>.title` and `quest.<id>.flavor` in `mmoskilltree.lang`, and reward both a `Currency` and an `Mmo_Xp` payout. A boss contract (`Bounty_Encounter`) names an encounter script id, or no target at all for any boss, and pays everyone the fight credited.
- **A board** is a schedule file under `Boards/MMOSkillTree/`; its file name is the board id contracts name.
- **An offer** is a file under `ShopEntries/MMOSkillTree/` (static by default; add a `Pool` group to rotate it). **A shelf** is a schedule file under `ShopPools/MMOSkillTree/` with the same cadence, selection and reroll shape a board uses. **A family of near-identical offers** is one file under `ShopEntryGenerators/MMOSkillTree/`.
- **A broker NPC** is a native Hytale role under `Server/NPC/Roles/Passive/`, and it decides only the look, the nameplate and the press-F prompt. Which screen opens comes from the **placement** that stands the character up, so this pack ships the six roles and no placements: none of them appears until you author one at `Server/ZiggfreedCommon/NpcPlacements/<YourId>.json` naming a role plus `"Interact": {"Open": {"Type": "Mmo_Board", "Board": "Daily"}}` (or `"Mmo_Shop"` with a `Shop`). Each role file's `$Comment` carries the full recipe with its own id filled in. Manage what is standing with `/mmonpc list|enable|disable`.
- Run `/mmobounty validate` and `/mmoshop validate` (console/admin) to catch empty pools, unfillable slots, orphaned contracts or offers, malformed icons, and missing currencies before you ship.

See the [Authoring guide](#authoring-guide) below for the full schema and JSON examples.

## Authoring guide

Everything below is data. You write JSON files and `.lang` lines; no code is involved. Field names are PascalCase, and a file name is its id (matched without regard to case, so `Bounty_Hunt_Trork.json` is the contract `bounty_hunt_trork`). Override a shipped file of the same id and only the leaves you write change; the rest is inherited. A `$Comment` in any shipped file is a tip for whoever reads it, and you can leave them out of your own.

### How contracts and boards fit together

- **A contract is a quest.** A file under `Bounties/` carries the usual quest groups (`Text`, `Listing`, `Objectives`, `Rewards`, `Requires`) plus one of its own, `Boards`, a list of the boards that may post it.
- **The type decides the lifecycle.** A contract is never handed out on its own, never takes a slot in the quest log, repeats on whatever its board's schedule says, and is handed in at the board that posted it. None of that is authorable, which is why a contract file is only a few lines long. The one payout choice you make is `Auto` or `Claim`; every contract here parks its pay under `Claim`, so the reward survives the board turning over.
- **A board is a rotating view over the contract pool.** It declares a cadence, a selection rule and some slots, and draws one contract per slot each period. The draw is seeded from the clock, so every player sees the same board and a restart changes nothing.
- **Membership is typed.** A contract lists `{"Board": "Daily", "Difficulty": "Hard", "Weight": 1}` for each board that can post it. `Difficulty` is a free word you invent; it is matched against a board slot's own `Difficulty`, and it is also the band a board gates through `AcceptRequires`.
- **A requirement is a bound on a factor.** `Requires` holds `Factors` (numeric bounds), `Permission`, `Quests`, and `AllOf` / `AnyOf` / `Not` groups to combine them. MMO Skill Tree answers `hytale:stat` for its own numbers, so `MMO_Level_MINING` and `MMO_CombatLevel` are just parameters.
- **A price is a `Cost`:** `{"Currencies": {...}, "Items": [...], "Combine": "All"}`. The same object prices an offer or a reroll. `All` (the default) charges every part; `Any` charges the first one the player can afford.

### A contract

One file in `Bounties/MMOSkillTree/`:

```json
{ "Parent": "Bounty_Kill",
  "Text": { "TitleKey": "quest.bounty_slay_zombies.title",
            "FlavorKey": "quest.bounty_slay_zombies.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 2 } ],
  "Objectives": { "main": { "Target": "Zombie", "Amount": 12 } },
  "Rewards": { "Claim": [ { "Kind": "Currency", "Params": { "Currency": "bounty_token", "Amount": 150 } },
                          { "Kind": "Mmo_Xp", "Params": { "Skill": "SWORDS", "Amount": 1200 } } ] } }
```

- **`Parent`** names one of the ten skeletons below. A skeleton supplies the step kind, the match mode and the shape of the pay. `Objectives` merges per step name, so naming `main` retunes that one step and keeps the rest.
- **`Rewards.Claim`** is one leaf, so writing it replaces the skeleton's list instead of adding to it. Give a contract a `Currency` reward and an `Mmo_Xp` reward, except on the Bihourly board and the `Training` band (see the pay note below).
- **Step wording is generated.** The game builds a localized "Defeat 12 Zombie" from the step itself in every language. Author `TextKey` on a step only when the generated line would read badly.
- **`Weight`** biases the draw against other contracts competing for the same slot. Unwritten means 1, and 2 is twice as likely.
- **Item payouts are safe here**, because a contract always waits at the board until the player presses Claim, so they can clear inventory space first. `Bounty_Cache_Copper` is the worked example. A `Command` reward must use the named form `/give {player} <item> --quantity=N`; Hytale's give command ignores a positional quantity.
- **Title and flavor** are lang keys. Add `quest.<id>.title` and `quest.<id>.flavor` to `Server/Languages/en-US/mmoskilltree.lang`, and the same keys to the other eight locales.

#### The ten skeletons

Each is an ordinary `Abstract` contract. A child of one is a real contract, because `Abstract` is the one field that is never inherited.

| Skeleton | Step kind | Match | A child names |
|---|---|---|---|
| `Bounty_Kill` | `KILL_ENTITY` | CONTAINS | the creature id, the count |
| `Bounty_Gather` | `BREAK_BLOCK` | CONTAINS | the block family, the count |
| `Bounty_GatherDeliver` | `BREAK_BLOCK` (`gather`) + `TURN_IN` (`deliver`) | CONTAINS / EXACT | the mined block, the returned item, both counts |
| `Bounty_TurnIn` | `TURN_IN` | EXACT | the exact item id, the count |
| `Bounty_Fish` | `CATCH_FISH` | CONTAINS | a species, or nothing for any catch |
| `Bounty_Pickup` | `PICKUP_ITEM` | CONTAINS | what to collect (a stem works), the count |
| `Bounty_Place` | `PLACE_BLOCK` | CONTAINS | a material, or nothing for anything placed |
| `Bounty_Spend` | `SPEND_CURRENCY` | EXACT | a wallet id, the amount |
| `Bounty_Xp` | `GAIN_XP` | EXACT | a skill id, an experience total |
| `Bounty_Encounter` | `ENCOUNTER_DEFEATED` | EXACT | an encounter script id, or nothing for any boss |

A step with no `Target` means "any", so `Bounty_Daily_Monster_Cull` counts every kill and `Bounty_Quick_Catch` counts every fish.

A gather-and-deliver contract retunes both steps by name. Keep the delivered count well under the gathered one so the player keeps most of the haul:

```json
{ "Parent": "Bounty_GatherDeliver",
  "Text": { "TitleKey": "quest.bounty_mine_iron.title", "FlavorKey": "quest.bounty_mine_iron.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 2 } ],
  "Objectives": { "gather": { "Target": "Ore_Iron", "Amount": 25 },
                  "deliver": { "Target": "Ore_Iron", "Amount": 10 } },
  "Rewards": { "Claim": [ { "Kind": "Currency", "Params": { "Currency": "bounty_token", "Amount": 170 } },
                          { "Kind": "Mmo_Xp", "Params": { "Skill": "MINING", "Amount": 1400 } } ] } }
```

For an ore, the mined block and the returned item share an id. Check any `Target` against the item ids in the game's own assets. A mining contract whose block has no clean single item to hand in (stone, wood) stays on `Bounty_Gather`.

A training contract pairs its step with a bound on the same skill, so it is never posted to somebody who cannot work on it:

```json
{ "Parent": "Bounty_Xp",
  "Text": { "TitleKey": "quest.bounty_train_mining.title", "FlavorKey": "quest.bounty_train_mining.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 1 } ],
  "Requires": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_Level_MINING", "Min": 1 } ] },
  "Objectives": { "main": { "Target": "MINING", "Amount": 3000 } },
  "Rewards": { "Claim": [ ... ] } }
```

A boss contract names the fight by its encounter script id (the file under `Server/EncounterManager/`), not the creature, because a fight that swaps roles between phases has no single creature id. Leave `Target` out and any boss on the server counts, which is how the shipped pair is written, so it works with whichever boss a server stands up. Everyone the fight credited completes it, whoever landed the last blow. A single fight reads badly through the shared step sentence, so the shipped contracts give their step a `TextKey` of their own:

```json
{ "Parent": "Bounty_Encounter",
  "Text": { "TitleKey": "quest.bounty_weekly_open_warrant.title", "FlavorKey": "quest.bounty_weekly_open_warrant.flavor" },
  "Boards": [ { "Board": "Weekly", "Difficulty": "Hard", "Weight": 1 } ],
  "Objectives": { "main": { "Amount": 1, "TextKey": "objective.text.bounty.open_warrant" } },
  "Rewards": { "Claim": [ ... ] } }
```

`Bounty_Muster_Roll` is the same skeleton with `"Kind": "ENCOUNTER_ATTEMPT"` on its step. It is credited when a fight ends either way, win or wipe, so "stand in it to the end" is a different contract from "bring it down". On a server where no boss stands anywhere, both are dead warrants; take them off with `"Enabled": false`.

A seasonal contract is posted only while a calendar event runs. Put the event's running switch at the top level of `Requires`, and give the contract a band that only a seasonal slot posts:

```json
{ "Parent": "Bounty_Kill",
  "Text": { "TitleKey": "quest.bounty_haunt_ghouls.title", "FlavorKey": "quest.bounty_haunt_ghouls.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Seasonal", "Weight": 1 } ],
  "Requires": { "Factors": [ { "Factor": "ziggfreedcommon:feature", "Param": "Hallows_Eve_Live", "Min": 1 } ] },
  "Objectives": { "main": { "Target": "Hallows_Eve_Hollow_Ghoul", "Amount": 6 } },
  "Rewards": { "Claim": [ ... ] } }
```

ZiggfreedCommon answers `<Event>_Live` for every calendar event a pack ships: on while the event is switched on and between its dates, off otherwise, and off on a server that does not have the event at all. While it reads off, the contract is never posted; a player who took it before the event ended still finds it on the board's Mine tab. Keep the condition at the top level: inside `AllOf`, `AnyOf` or `Not` it becomes an ordinary lock, and the contract sits on the board all year, locked. The three in `Haunt/` are this pack's own, written for the Hallow's Eve pack's creatures.

**A note on pay.** The `Training` band and the whole Bihourly board pay little or no tokens on purpose. Training contracts pay a small token amount plus flat experience, and Bihourly contracts pay experience only. The Bihourly board turns over several times a day, so full token payouts there would flood the economy. The token income is the Daily and Weekly easy, normal and hard ladder. The Bihourly reroll still costs tokens, which gives free-experience contracts a small sink.

### A board

1. **The schedule.** Drop `Boards/MMOSkillTree/<Id>.json`. The file name is the board id, and the word contracts name in `Boards[].Board`.

```json
{ "Text": { "TitleKey": "ui.bounty.board.daily", "FlavorKey": "ui.bounty.board.daily.desc" },
  "Order": 0,
  "Rotation": { "Period": "Daily" },
  "Selection": { "Type": "Weighted_Random" },
  "Slots": [ { "Difficulty": "Training", "Count": 2 },
             { "Difficulty": "Easy" },
             { "Difficulty": "Normal", "Count": 2 },
             { "Difficulty": "Hard", "Optional": true } ],
  "Currencies": [ "Bounty_Token", "Life_Essence" ],
  "Reroll": { "Cost": { "Currencies": { "Bounty_Token": 25 } }, "MaxPerPeriod": 3 },
  "AcceptRequires": {
    "Normal": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_CombatLevel", "Min": 25 } ] },
    "Hard":   { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_CombatLevel", "Min": 60 } ] } } }
```

- **`Rotation` is `Period` or `Every`, never both.** Authoring both is a validator error. `Period` is a calendar cadence, `Daily` or `Weekly`, counted from a fixed UTC boundary so everybody's board turns over at the same moment. `Weekly` starts on Monday unless a `Weekday` says otherwise. `Every` is a plain repeating span in whole units that add up: `{"Hours": 2}` is the Bihourly board. `OffsetMinutes` moves the rollover past the boundary; 240 puts a daily at 04:00 UTC.
- **`Selection.Type`** is `Weighted_Random` (a seeded draw that honours each contract's weight) or `All` (post everything eligible). Any other word is reported instead of quietly replaced.
- **`Slots`** shape the posting. Each slot has a `Difficulty`, an optional `Count` (how many of that band) and an optional `Optional` (the slot may come up empty without the board reading as broken). A slot whose band no enabled contract on the board carries is an `UNFILLABLE_SLOT` finding: a required one leaves a gap, an optional one is skipped every rotation. The shipped Daily board ends with an optional Seasonal slot that only seasonal contracts fill. Keep a slot like that last: the draw fills the slots in order, so a trailing slot never changes an earlier posting.
- **`Grades`** is an optional map that says what a band is called on a contract's badge and detail panel, keyed by the band's own word: `"Grades": { "Skirmish": { "TitleKey": "board.grade.skirmish" } }`. The five bands the framework already names (`training`, `easy`, `normal`, `hard`, `elite`) read in all nine languages with nothing authored, so skip it for those. Write a `Grades` entry for a band you invent, and point `TitleKey` at a line in your own `.lang` file. A band named nowhere reads as its own word. On a board that has slots, a `Grades` entry for a band no slot posts is a `NAME_FOR_UNPOSTED_BAND` finding, which is how a misspelled band shows up at boot.
- **`Currencies`** is the balance strip in the page header. List every wallet a player earns or spends at this board; an unlisted wallet does not appear.
- **`Reroll.Cost`** is a full `Cost`, so a reroll can be priced in several wallets or in items. `MaxPerPeriod` caps paid rerolls per period.
- **`AcceptRequires`** is a map of ordinary `Requires` blocks keyed by band. It is checked only when a player accepts: a contract they are not ready for is still posted and shown, locked, so they can see what to work towards. Leave a band out and it is ungated (which is what `Training` and `Easy` are here). It merges per band under a `Parent`, so a child board can raise one band and keep the rest.
- **Optional extras:** `Requires` gates the whole board, `Where` limits it to some worlds (absent means everywhere), `Enabled` turns it off, `Icon` and `Order` decide how it shows in a list.

2. **The in-world block (optional, recommended).** Add `Server/Item/Items/MMO_Bounty_Board_<Name>.json` (copy an existing block and point `BlockType.Interactions.Use` at your interaction), plus `Server/Item/RootInteractions/MMO_BountyBoard_<Name>_Open.json`:

```json
{ "Cooldown": { "Id": "BlockInteraction", "Cooldown": 0.278, "ClickBypass": true },
  "Interactions": [ { "Type": "mmo_bounty_board_open", "Board": "<id>" } ] }
```

   Add the item's name and hint keys to `items.lang`. Without a block, the board is still reachable with `/mmobountyui <player> --board=<id>` and through an NPC.

3. **Validate.** Run `/mmobounty validate` (console or admin) and confirm there are no `EMPTY_BOARD`, `UNFILLABLE_SLOT`, `UNKNOWN_BOARD`, `ORPHANED_BOUNTY` or `MISSING_REROLL_CURRENCY` findings for the new board.

### A storefront, a shelf and an offer

A **storefront** (`Shops/MMOSkillTree/<Id>.json`) is the page: its name, its icon, the wallets in its header strip and the order of its shelves.

```json
{ "Text": { "TitleKey": "shop.general.title", "FlavorKey": "shop.general.desc" },
  "Icon": "Ore_Iron", "Order": 0,
  "Currencies": [ "Bounty_Token", "Life_Essence" ],
  "CategoryOrder": [ "items", "boosts", "conversion", "featured" ] }
```

`CategoryOrder` fixes the shelf order. Leave it out and shelves sort alphabetically, which puts "rare" ahead of "uncommon". A category not named there follows the listed ones alphabetically, and an offer's own `Listing.SortOrder` still arranges offers within one shelf. `Requires` and `Where` gate the whole storefront.

`Categories` says what each shelf is called, keyed by the category's own word: `"Categories": { "relics": { "TitleKey": "shop.category.relics" } }`. It is separate from `CategoryOrder` on purpose, because one decides what a shelf says and the other decides where it sits. The four shelves this pack uses (`items`, `boosts`, `conversion`, `featured`) already read in all nine languages. For a category you invent, write an entry and point `TitleKey` at a line in your own `.lang` file.

A **shelf** (`ShopPools/MMOSkillTree/<Id>.json`) is a rotating subset of the offers that name it, sitting on top of the always-available static catalogue. It uses the same `Rotation`, `Selection`, `Slots` and `Reroll` groups a board does, so the two can never disagree about what "daily" means. Its slots filter on `Tier` instead of `Difficulty`. With no `Slots`, the draw is unshaped and any member can fill any place. Give a shelf more members than it draws, or rotation and reroll mean nothing.

An **offer** (`ShopEntries/MMOSkillTree/<Id>.json`) is one thing on sale:

```json
{ "Text": { "TitleKey": "shop.boost_mining.title", "FlavorKey": "shop.boost_mining.desc" },
  "Icon": "Tool_Pickaxe_Crude",
  "Shop": "General",
  "Listing": { "Category": "boosts", "SortOrder": 20 },
  "Cost": { "Currencies": { "Bounty_Token": 150 } },
  "Limits": { "Daily": 3 },
  "Requires": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_Level_MINING", "Min": 1 } ] },
  "Rewards": [ { "Kind": "Mmo_Boost_Token",
                 "Params": { "Skill": "MINING", "Multiplier": "3.0", "DurationMinutes": "20" } } ] }
```

- **`Shop`** names the storefront and **`Listing.Category`** names the shelf inside it. An unknown category gets a warning in the audit.
- **`Pool`** puts an offer on a rotating shelf: `{"Id": "Featured", "Tier": "<x>", "Weight": 2}`. Leave it out and the offer is static and always listed. An offer with no `Tier` fits an unslotted draw but no filtered slot, so an offer on a fully slotted shelf needs one.
- **`Limits`** is `{"Daily": N, "Total": N}`, two independent caps; leave one out for no such cap. Counts are kept per player on the server under the offer's id, so renaming an offer starts its counts over.
- **`Cost`** can name items as well as wallets. `Life_Essence` is item-backed, so a price in it means the player must be carrying that many.
- **`Rewards`** use the shared kinds: `Item`, `Command`, `Currency`, `Mmo_Xp` and `Mmo_Boost_Token`. Item payouts are checked against inventory space before anything is charged, so they cannot be lost.
- **Icons come free where the payout implies one.** With no `Icon`, an offer takes its art from its first reward: a `Currency` reward shows the wallet's icon, a `Command` `/give` shows the given item, and an `Mmo_Xp` reward for a concrete skill shows that skill's icon. An `Icon` you write always wins, and it inherits: `Xp_Packet` sets the purple crystal, so every generated packet wears it. Drop the `Icon` from the base if you would rather each packet show its own skill.
- **Validate** with `/mmoshop validate`. It reports a missing or disabled cost currency, a non-positive cost, an unknown reward kind, an empty rewards list, an offer that names no storefront, an unknown `Pool.Id`, and, for shelves, empty pools, unfillable slots and oversubscribed pools.

**Keep numbers out of lang values.** Never put an amount, a duration, a multiplier, a quantity or a currency's name into a `.lang` value. A balance change should never need a translation edit. The page shows localized reward and cost lines with their own numbers, so a title or blurb only describes flavor: "Mining Rush", not "Mining Rush (3x, 20m)"; "a featured batch of bottled life", not "64 Life Essence". Only `currency.<id>.name` may carry a currency's name, and an item-backed wallet needs none because its name comes from the backing item.

### Generating a family of offers

`ShopEntryGenerators/MMOSkillTree/Xp_Packets.json` writes one experience packet per skill at each of three sizes from a single file:

```json
{ "Base": "Xp_Packet",
  "IdPattern": "shop_xp_{tier}_{skill}",
  "ForEach": [
    { "Token": "skill", "Source": "mmoskilltree:skills" },
    { "Token": "tier", "Values": [
      { "tier": "lesser",  "tokens": 75,  "essence": 30,  "xp": "1500",  "minLevel": 1,  "order": 40, "daily": 3 },
      { "tier": "greater", "tokens": 165, "essence": 65,  "xp": "7500",  "minLevel": 30, "order": 42, "daily": 3 },
      { "tier": "master",  "tokens": 330, "essence": 100, "xp": "40000", "minLevel": 60, "order": 44, "daily": 2 } ] } ],
  "Child": {
    "Text": { "TitleKey": "shop.xp_packet.{tier}.title", "TextArgs": { "Title": [ "{skill}" ] } },
    "Cost": { "Currencies": { "bounty_token": "{tokens}", "life_essence": "{essence}" } },
    "Limits": { "Daily": "{daily}" },
    "Pool": { "Id": "XpExchange", "Tier": "{tier}" },
    "Requires": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_Level_{skill}", "Min": "{minLevel}" } ] },
    "Rewards": [ { "Kind": "Mmo_Xp", "Params": { "Skill": "{skill}", "Amount": "{xp}" } } ] } }
```

(The shipped file also sets `Listing` on the child; it is trimmed here for length.)

- **`Base`** is an ordinary `Abstract` offer (`Xp_Packet`) that carries what every packet shares: the storefront, the shelf and the icon. It has no numbers, because every number differs per skill and per size.
- **`ForEach`** is a list of axes. `Source` reads a list some mod supplies (`mmoskilltree:skills` is every active skill), so a skill added later gets its packets with no edit here. `Values` binds several tokens on one row, so "the greater packet costs 165 and wants level 30" is stated once.
- **Substitution covers every string value, every object key, and `IdPattern`.** Substituting a key is how each packet's requirement names its own level channel, `MMO_Level_{skill}`. A value that is exactly one token keeps that token's type.
- **A token nothing binds is an error**, and that one offer is skipped with the file named.
- **`Text.TextArgs`** lets one written line serve the whole family: `shop.xp_packet.{tier}.title` is translated once per size and the skill fills `{0}`.
- **To override one generated packet,** write an explicit `ShopEntries` file with that generated id. An authored file beats a generated offer of the same id, and the load reports the collision, so a too-coarse `IdPattern` is never mistaken for a deliberate special case.

The three sizes are drawn one each per day by the `XpExchange` shelf's three tier slots, so a given skill and size turns up every few weeks. Beside them, `Xp_Packet_All_Skills` stays a static premium offer (every skill at once, once a day), so the page always has a dependable sink whatever rotates in.

### A wallet

`Currencies/MMOSkillTree/<Id>.json`. The file name is the wallet id.

```json
{ "Icon": "Ingredient_Bar_Gold", "Color": "#ffcc44", "Cap": 0,
  "Meta": { "mmoskilltree": { "ShowOnSidebar": true, "ShowOnMasteryPage": false,
                              "XpConversionPercent": 0 } } }
```

- **`Backing.Item`** is the one real choice. Author it and the balance is an inventory count, carried and tradable like any item. Leave it out and the balance is a number the server keeps. Everything else reads the same either way, and an item-backed wallet needs no `Icon` and no name key because both come from the backing item.
- **`Cap`, `OnDeath` and `Decay`** are three independent knobs; leaving one out means no such rule. A share value is a fraction from 0 to 1: `OnDeath.LossPercent: 0.1` takes a tenth.
- **`Meta`** holds knobs that only one mod understands, under that mod's name. Nothing else reads them, which is what lets one wallet file load on a server running only one of the mods that authored it.
- Server owners can override wallets in `mods/ziggfreedcommon/currencies.json`, with `shops.json`, `shop-pools.json` and `boards.json` beside it for storefronts, shelves and boards.

### Bounty achievements

MMO Skill Tree ships board-agnostic bounty achievements in its own jar (a count ladder, a hard-difficulty chain, a server-first and a daily streak), so they work with any board, including yours. This pack adds per-board chains (Daily Contractor, Weekly Warrant, Quick Contractor) and the Snapdragon creature chain, because those board ids only exist when this pack is installed. They live at `Server/ZiggfreedCommon/Achievements/MMOSkillTree/Bounty/<Name>.json`, where the file name is the achievement id:

- **`Criteria`** is keyed by criterion id, which is also what progress is saved under: `{"complete-bounty-daily": {"Kind": "COMPLETE_BOUNTY", "Target": "<board>", "MatchMode": "EXACT", "Amount": N}}`. A completion carries the board id as `target` and the difficulty as `qualifier`, so an achievement can match by board, by difficulty, or both.
- **`Rewards`** is `{"Claim": [...]}`. `Auto` pays the moment it is earned, and `Claim` waits on the achievements page.
- **`Listing.Chains`** places it on a ladder: `[{"Id": "bounty_board_daily", "Tier": 2}]`.
- **`Text.TextArgs.Flavor: ["@amount"]`** fills the shared description line with the criterion's number, so all the rungs translate once.

A chain for a new board is a copy with the board id and the amounts changed.

### Broker NPCs (press F to open a page)

`Server/NPC/Roles/Passive/*.json` are native Hytale NPC roles. Each is a stationary `Generic` role modeled on the vanilla `Kweebec_Merchant`, whose `InteractionInstruction` runs `{"Type": "ZigPlacementInteract"}` when a player presses F. **A role decides the look, the nameplate and the press-F prompt, and nothing else.** `ZigPlacementInteract` reads the placement the NPC was spawned from and opens whatever that placement says, so one role can stand in as many spots as you like, each opening a different board or storefront.

**This pack ships no placements, so none of these characters stands anywhere until a server owner places one.** Where a broker belongs is a property of your world. A placement is a file of your own at `Server/ZiggfreedCommon/NpcPlacements/<YourId>.json`:

```json
{ "Name": "My_Daily_Broker", "Enabled": true,
  "Identity": { "Role": "MMO_Bounty_Daily" },
  "Where": { "Match": [ "default" ] },
  "Anchor": { "WorldSpawn": { "Offset": { "X": 4.0 }, "Yaw": 180.0 } },
  "Lifecycle": { "KeepAlive": true, "Respawn": true, "Fortify": true },
  "Interact": { "Open": { "Type": "Mmo_Board", "Board": "Daily" } } }
```

`Interact.Open` takes `{"Type": "Mmo_Board", "Board": "<id>"}` for a board and `{"Type": "Mmo_Shop", "Shop": "<id>"}` for a storefront (a bare `"Mmo_Shop"` opens the default one). Each role file's `$Comment` has this recipe with its own id filled in. `/mmonpc list` shows what stands in each world and what each one opens, and `/mmonpc enable|disable <id>` switches one without editing files. Server owners can override placements in `mods/ziggfreedcommon/npc-placements.json`.

To add a broker for a new board `<x>`, copy `MMO_Bounty_Daily.json` to `MMO_Bounty_<X>.json`, change the name key and the `Board` in the `$Comment` example, and add the name to `npcs.lang`. `Appearance` reuses a built-in model id, so no model files ship.

## Requires

MMO Skill Tree 1.6.1 or newer, and ZiggfreedCommon 2.2.0 or newer.
