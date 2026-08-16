# CLAUDE.md - MMOSkillBountyPack

A standalone Hytale content pack for the [MMOSkillTree mod](https://www.curseforge.com/hytale/mods/mmo-skill-tree) (`^1.6.0`) and ZiggfreedCommon (`>=1.4.0`). It ships the entire **bounty board + shop** CONTENT: the contract pool, the reusable contract skeletons, the Bounty Token currency, the board schedules, the two storefronts with their shelves and offers, AND the in-world blocks (item + interaction + textures-via-vanilla + item names). The engines live in ZiggfreedCommon's `zc-commerce` module and the MMO jar registers what only it knows (its reward kinds, its stat channels, the `/mmobounty*` + `/mmoshop*` commands), so this pack is what makes bounties and shops appear. It is a **hard dependency** on both, declared in `manifest.json`.

## Release notes (patch-notes paradigm)

Per-version public release notes live in `patch-notes/<version>.md`, same paradigm as the main mod repo: YAML frontmatter (`version`, `title`, `type: patch-note`, `status: held|released`), a one-line summary, then user-facing `- **New/Fixed: ...**` bullets. No em-dashes. `patch-notes/_INDEX.md` lists them newest-first. `CURSEFORGE.md` is the public listing copy; keep its Versions table in sync with each release. Naming: the SHOP feature is generic ("the shops"); "Token Shop" names only the general storefront (`shop.general.title`), beside the per-skill "XP Exchange". (No docs-site publishing for packs yet.)

## Layout

```
bounty-contracts-pack/
├── manifest.json                                  Hytale plugin manifest (hard-deps MMOSkillTree + ZiggfreedCommon)
├── build.ps1                                       zips with forward-slash + directory entries, copies to Mods
└── Server/
    ├── Item/
    │   ├── Items/MMO_Bounty_Board.json             daily board block (wall poster; Use -> MMO_BountyBoard_Open)
    │   ├── Items/MMO_Bounty_Board_Weekly.json      weekly board block
    │   ├── Items/MMO_Bounty_Board_Bihourly.json    fast board block
    │   ├── Items/MMO_Token_Trader.json             shop block (wall poster; Use -> MMO_TokenTrader_Open)
    │   └── RootInteractions/                       object form: {"Type":"mmo_bounty_board_open","Board":"daily"}
    ├── Languages/<bcp47>/
    │   ├── items.lang                              block item names + descriptions + interaction hints
    │   ├── mmoskilltree.lang                       contract + offer + currency text (9 locales)
    │   └── npcs.lang                               NPC display names + F-hints
    ├── NPC/Roles/Passive/                          per-board / per-shop NPC roles (look + name only; ship no placements)
    ├── MMOSkillTree/
    │   └── Control/MMOSkillBountyPack.json         names only the stores the MOD itself owns (currently none)
    └── ZiggfreedCommon/                            the framework stores, all merged by id
        ├── Boards/MMOSkillTree/Daily.json, Weekly.json, Bihourly.json      board schedules
        ├── Bounties/MMOSkillTree/Bounty_*.json                             9 Abstract skeletons + 76 contracts
        ├── Currencies/MMOSkillTree/Bounty_Token.json, Life_Essence.json    the two wallets
        ├── Shops/MMOSkillTree/General.json, XpExchange.json                the two storefronts
        ├── ShopPools/MMOSkillTree/Featured.json, XpExchange.json           the rotating shelves
        ├── ShopEntries/MMOSkillTree/*.json                                 21 offers + 1 Abstract base + the all-skills premium
        ├── ShopEntryGenerators/MMOSkillTree/Xp_Packets.json                writes the whole per-skill packet family
        └── Achievements/MMOSkillTree/Bounty/*.json                         per-board + creature achievement chains
```

`Server/Item/**`, `Server/NPC/**` and `Server/Languages/**` load via Hytale's native asset pack mechanism (gated by `"IncludesAssetPack": true`). `Server/ZiggfreedCommon/**` are the shared framework stores: they merge **by id** on their own, with no `Control` entry. **The FILE NAME is the id** in every one of them, and the folder under a type root (`MMOSkillTree/`) is plain organization. The `Control` file governs only `Server/MMOSkillTree/**`, the stores the mod itself owns, and this pack ships none of those.

Override anything shipped by anybody, including this pack, by dropping in a file of the SAME id: leaf by leaf, what you write wins and what you leave out is inherited. Take one out entirely with `"Enabled": false`.

## How it fits together

- **A contract IS a quest.** `Bounties/` files carry the quest schema's own groups (`Text`, `Listing`, `Objectives`, `Rewards`, `Requires`, `Meta`) plus the one group only a contract has: `Boards`, a LIST of memberships. Everything you know about writing a quest applies here.
- **The TYPE stamps the policy, so it cannot be mis-authored.** Four behaviours are not authorable and no file may set them: a contract never auto-claims (it parks until collected, so a reward survives the board turning over), it stays out of the open quest log until taken, its repeat is governed by whatever posted it and clocked from FINISHING, and it is handed in at the board that posted it. This is why a contract file is four to six lines with no lifecycle block.
- **A board is a rotating VIEW over the contract pool.** `Boards/<Id>.json` declares its cadence, its selection strategy and its slots; the engine draws one contract per slot per period from a seed made of the wall clock, so every player sees the same board with zero persisted state and a restart changes nothing.
- **Membership is typed, not packed into a string.** A contract names `{"Board": "Daily", "Difficulty": "Hard", "Weight": 1}` and can name several boards at once. `Difficulty` is a free word the content invents; it is matched against a board slot's own `Difficulty` and is also the band key the board gates through `AcceptRequires`.
- **Every requirement is a factor bound.** `Requires` is the same shared block a quest carries: `Factors` (numeric bounds on the shared factor vocabulary), `Permission`, `Quests`, `Custom`, and `AllOf`/`AnyOf` for combinations. The MMO answers `hytale:stat` for its own channels, so `MMO_Level_MINING` and `MMO_CombatLevel` are just parameters, and a pack can mint its own requirement word with a `Server/ZiggfreedCommon/Factors/<Id>.json` file and no code at all.
- **One price vocabulary.** A `Cost` is `{"Currencies": {...}, "Items": [...], "Combine": "All|Any"}`, and it is the same object whether it prices an offer or a reroll. `All` (the default) charges every part; `Any` charges the first the player can afford.
- **Two wallets ship here.** `Bounty_Token` is counter-backed (a number the server keeps). `Life_Essence` authors `Backing.Item`, so its balance IS how many `Ingredient_Life_Essence` the player carries, and its name and icon come from that item. Nothing that spends a wallet branches on which kind it is. The pack ships both so it works standalone, even without the mastery pack.
- **Several boards per world, one block each.** Each board has its own placeable block (a wall poster based on the vanilla `Lobby_Wall_Poster01` model/texture/icon, tinted per block via `TextureComputedColor`, `Support: North`). The block's `BlockType.Interactions.Use` names a `RootInteraction` whose single entry is the object form `{"Type": "mmo_bounty_board_open", "Board": "<id>"}`; the bare-string form falls back to the default board. N boards in a world is N blocks and N RootInteractions, still one interaction type.
- **Deliberate economy rule: the `Training` band and the whole Bihourly board pay minimal to no tokens.** Training contracts pay a small nominal token plus flat experience; Bihourly contracts pay pure experience and no token at all. They are experience-grind content, not a token source. The token faucet is the Daily and Weekly easy/normal/hard ladder alone. Do NOT "fix" them back to full token payouts: the Bihourly board turns over several times a day and the Daily board posts two training contracts daily, so it would flood the economy. The Bihourly reroll still costs tokens, which keeps a small sink on free-experience contracts.

## Authoring a contract

One file in `Bounties/MMOSkillTree/`. The file name is the id.

```json
{ "Parent": "Bounty_Kill",
  "Text": { "TitleKey": "quest.bounty_slay_zombies.title",
            "FlavorKey": "quest.bounty_slay_zombies.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 2 } ],
  "Objectives": { "main": { "Target": "Zombie", "Amount": 12 } },
  "Rewards": [ { "Kind": "Currency", "Params": { "Currency": "bounty_token", "Amount": "150" } },
               { "Kind": "Mmo_Xp", "Params": { "Skill": "SWORDS", "Amount": "1200" } } ] }
```

- **`Parent`** names one of the nine Abstract skeletons, which supply the step kind, the match mode and the shape of the pay. The `Objectives` map merges per key, so naming `main` retunes that one step and keeps the rest.
- **`Rewards` is a single leaf**: writing it REPLACES the skeleton's list rather than adding to it. Give every contract a `Currency` reward and an `Mmo_Xp` reward, except on the Bihourly board and the `Training` band (see the economy rule above).
- **No step wording is needed.** The renderer builds a localized, pluralized "Defeat 12 Zombies" from the step itself, in every language. Author `TextKey` on a step only when the generated line would read badly.
- **`Weight`** biases the draw against rivals for the same slot; unauthored means 1, and 2 is twice as likely as a 1.
- **Item payouts are safe on a contract**, because it always parks until collected: the player can clear inventory space before pressing Claim. `Bounty_Cache_Copper` and `Bounty_Cache_Repairs` are the worked examples. A `Command` reward always uses the named form `/give {player} <item> --quantity=N`; Hytale's give command ignores a positional quantity and the audit flags it as `POSITIONAL_GIVE_QUANTITY`.
- **Title and flavor** are localization keys the player's own client resolves. Add `quest.<id>.title` and `quest.<id>.flavor` to `Server/Languages/en-US/mmoskilltree.lang` and the same keys to the other eight locales.

### The nine skeletons

Each is an ordinary `Abstract` contract; a child of one is a real contract, because `Abstract` is the one field that never inherits.

| Skeleton | Step | Match | A child names |
|---|---|---|---|
| `Bounty_Kill` | `KILL_ENTITY` | CONTAINS | the creature id, the count |
| `Bounty_Gather` | `BREAK_BLOCK` | CONTAINS | the block family, the count |
| `Bounty_GatherDeliver` | `BREAK_BLOCK` + `TURN_IN` | CONTAINS / EXACT | the mined block, the returned item, both counts |
| `Bounty_TurnIn` | `TURN_IN` | EXACT | the exact item id, the count |
| `Bounty_Fish` | `CATCH_FISH` | CONTAINS | a species, or nothing for "any catch" |
| `Bounty_Pickup` | `PICKUP_ITEM` | CONTAINS | what to collect (a stem works), the count |
| `Bounty_Place` | `PLACE_BLOCK` | CONTAINS | a material, or nothing for "anything placed" |
| `Bounty_Spend` | `SPEND_CURRENCY` | EXACT | a WALLET id, the amount |
| `Bounty_Xp` | `GAIN_XP` | EXACT | a skill id, an experience total |

An unauthored `Target` means "any", so `Bounty_Daily_Monster_Cull` counts every kill and `Bounty_Quick_Catch` counts every fish.

A gather-and-deliver contract retunes both steps by name and keeps the delivered count well under the gathered one, so the player keeps most of the haul:

```json
{ "Parent": "Bounty_GatherDeliver",
  "Text": { "TitleKey": "quest.bounty_mine_iron.title", "FlavorKey": "quest.bounty_mine_iron.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 2 } ],
  "Objectives": { "gather": { "Target": "Ore_Iron", "Amount": 25 },
                  "deliver": { "Target": "Ore_Iron", "Amount": 10 } },
  "Rewards": [ { "Kind": "Currency", "Params": { "Currency": "bounty_token", "Amount": "170" } },
               { "Kind": "Mmo_Xp", "Params": { "Skill": "MINING", "Amount": "1400" } } ] }
```

For an ore the mined block and the returned item share an id; verify any `Target` against `hytale-resources/items-index.json`. A mining contract whose block has no clean single turn-in item (Stone, Wood) stays on `Bounty_Gather`.

A training contract pairs its step with a bound on the same skill, so it is never posted to somebody who cannot work on it:

```json
{ "Parent": "Bounty_Xp",
  "Text": { "TitleKey": "quest.bounty_train_mining.title", "FlavorKey": "quest.bounty_train_mining.flavor" },
  "Boards": [ { "Board": "Daily", "Difficulty": "Normal", "Weight": 1 } ],
  "Requires": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_Level_MINING", "Min": 1 } ] },
  "Objectives": { "main": { "Target": "MINING", "Amount": 3000 } },
  "Rewards": [ ... ] }
```

## Authoring a board (and its block)

1. **Schedule:** drop `Boards/MMOSkillTree/<Id>.json`. The file name is the board id and the word contracts name in `Boards[].Board`.

```json
{ "Text": { "TitleKey": "ui.bounty.board.daily", "FlavorKey": "ui.bounty.board.daily.desc" },
  "Order": 0,
  "Rotation": { "Period": "Daily" },
  "Selection": { "Type": "Weighted_Random" },
  "Slots": [ { "Difficulty": "Training", "Count": 2 },
             { "Difficulty": "Skirmish" },
             { "Difficulty": "Normal", "Count": 2 },
             { "Difficulty": "Hard", "Optional": true } ],
  "Currencies": [ "Bounty_Token", "Life_Essence" ],
  "Reroll": { "Cost": { "Currencies": { "Bounty_Token": 25 } }, "MaxPerPeriod": 3 },
  "Grades": { "Skirmish": { "TitleKey": "board.grade.skirmish" } },
  "AcceptRequires": {
    "Normal": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_CombatLevel", "Min": 25 } ] },
    "Hard":   { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_CombatLevel", "Min": 60 } ] } } }
```

- **`Rotation` is `Period` OR `Every`, never both** (authoring both is a validator error, not a silent precedence rule). `Period` is a calendar cadence, `Daily` or `Weekly`, counted from a fixed UTC boundary so everybody's board turns over at the same instant; `Weekly` starts on Monday unless a `Weekday` says otherwise. `Every` is a plain repeating span in whole units that add up: `{"Hours": 2}` is the Bihourly board. `OffsetMinutes` moves the rollover past the boundary; 240 puts a daily at 04:00 UTC.
- **`Selection.Type`** names a registered strategy: `Weighted_Random` draws seeded picks honouring each contract's weight, `All` posts everything eligible. A word nothing registered is reported rather than quietly replaced.
- **`Slots`** shape the posting: each is a `Difficulty` plus an optional `Count` (how many of that band) and `Optional` (a slot that may come up empty rather than reading as broken). A required slot with nothing eligible is an `UNFILLABLE_SLOT` finding.
- **The board's own optional `Grades` map is what a band READS as** on a contract's badge and in its detail panel, keyed by the band's own word: `"Grades": { "Skirmish": { "TitleKey": "board.grade.skirmish" } }`. The five bands this pack uses (`training` / `easy` / `normal` / `hard` / `elite`) already read in all nine languages with nothing authored, so leave it out for those; author a `Grades` entry for a band you invent, and point `TitleKey` at a line in your own `.lang` file. A band named nowhere reads as its own word, never as a key. Declaring a band (a `Slots[]` entry naming its `Difficulty`) and naming it (a `Grades` entry) are two separate authored facts, so an unslotted board can name bands too. On a board that DOES carry slots, a `Grades` entry for a band none of them posts is a `NAME_FOR_UNPOSTED_BAND` finding, which is how a misspelled band turns up at boot instead of shipping as a word nothing reads.
- **`Currencies`** is the balance strip in the page header: list every wallet a player earns or spends at this board. An unlisted wallet simply does not appear.
- **`Reroll.Cost` is a full `Cost`**, so a reroll can be priced in several wallets or in items. `MaxPerPeriod` caps paid rerolls per period.
- **`AcceptRequires` is a map of ordinary `Requires` blocks keyed by BAND.** It is checked at ACCEPT only: a contract a player is not ready for is still posted and still shown, locked, so they can see what to work towards. Omit a band and it is ungated (which is what `Training` is). It merges per band under `Parent`, so a child board can raise one band and keep the rest.
- Optional: `Requires` gates the whole board, `Where` limits it to some worlds (absent means everywhere), `Enabled` turns it off, `Icon` and `Order` decide how it presents in a list.

2. **In-world block (optional but recommended):** add `Server/Item/Items/MMO_Bounty_Board_<Name>.json` (copy an existing block, point `BlockType.Interactions.Use` at your RootInteraction) plus `Server/Item/RootInteractions/MMO_BountyBoard_<Name>_Open.json` = `{"Cooldown": {...}, "Interactions": [ {"Type": "mmo_bounty_board_open", "Board": "<id>"} ]}` and item-name keys in `items.lang`. Without a block the board is still reachable through `/mmobountyui <player> <id>` and through an NPC.

3. **Validate:** `/mmobounty validate` (console/admin). Confirm no `EMPTY_POOL`, `UNFILLABLE_SLOT`, `UNKNOWN_BOARD`, `ORPHANED_BOUNTY` or `MISSING_REROLL_CURRENCY` findings for the new board.

## Authoring a storefront, a shelf, and an offer

A **storefront** (`Shops/MMOSkillTree/<Id>.json`) is the page: its name, its icon, the wallets in its header strip, and the order its shelves appear in.

```json
{ "Text": { "TitleKey": "shop.general.title", "FlavorKey": "shop.general.desc" },
  "Icon": "Ore_Iron", "Order": 0,
  "Currencies": [ "Bounty_Token", "Life_Essence" ],
  "CategoryOrder": [ "items", "boosts", "conversion", "featured" ] }
```

`CategoryOrder` fixes the shelf order; leave it out and shelves sort alphabetically, which puts "rare" ahead of "uncommon". A category not named there follows the listed ones alphabetically, and an offer's own `Listing.SortOrder` still arranges offers WITHIN one shelf. `Requires` and `Where` gate the storefront itself.

`Categories` is what each shelf is CALLED, keyed by the category's own word: `"Categories": { "relics": { "TitleKey": "shop.category.relics" } }`. It is separate from `CategoryOrder` on purpose - one decides what a shelf says, the other where it sits. The four shelves this pack uses (`items` / `boosts` / `conversion` / `featured`) already read in all nine languages with nothing authored; author an entry for a category you invent and point `TitleKey` at a line in your own `.lang` file. It lives on the storefront rather than on each offer, so a dozen offers in one category cannot name that shelf a dozen ways.

A **shelf** (`ShopPools/MMOSkillTree/<Id>.json`) is a rotating subset of the offers that name it, on top of the always-available static catalogue. It uses the SAME `Rotation` / `Selection` / `Slots` / `Reroll` groups a board does, so the two can never disagree about what "daily" means. Its slots filter on `Tier` rather than `Difficulty`. With no `Slots` the draw is unshaped and any member can fill any place. Give a shelf MORE members than it draws, or rotation and reroll mean nothing.

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

- **`Shop`** names the storefront; **`Listing.Category`** names the shelf inside it (`items` / `boosts` / `conversion` / `featured` here; an unknown one warns in the audit).
- **`Pool`** is the rotating-shelf membership, `{"Id": "Featured", "Tier": "<x>", "Weight": 2}`. Omit it and the offer is static, always listed. An offer with no `Tier` fits an unslotted draw but no filtered slot, so an offer on a fully slotted shelf needs one.
- **`Limits`** is `{"Daily": N, "Total": N}`, two independent knobs; omit one for no such cap. Counts are per player and persist server-side, filed under the offer's ID, so renaming an offer starts its counts over.
- **`Cost`** can name items as well as wallets: `Featured_Cache_Lobster` charges tokens plus a stack of fire essence out of the pack. Because `Life_Essence` is item-backed, a price in it means the player must physically be carrying that many.
- **Rewards** use the shared kinds: `Item`, `Command`, `Currency`, `Mmo_Xp`, `Mmo_Boost_Token`. Item payouts are inventory-space-checked before anything is charged, so they cannot be lost.
- **Icons come free where the payout implies one**: an `Mmo_Xp` reward for a concrete skill resolves to that skill's registry icon, so the generated packets ship no `Icon` of their own.
- **Validate:** `/mmoshop validate` reports a missing or disabled cost currency, a non-positive cost, an unknown reward currency, an empty rewards list, a malformed icon id, an unknown `Pool.Id`, and (for shelves) empty pools, unfillable slots and oversubscribed pools.

### Lang values are data-free flavor (HARD RULE)

Never bake an amount, a duration, a multiplier, a quantity or a currency's name into a `.lang` value. A balance pass must never require a localization edit (the all-skills boost once shipped titled "(2x, 30m)" in eight languages after the JSON moved to 45m). The UI renders localized reward and cost lines with their own numbers, so a title or blurb describes flavor only: "Mining Rush", not "Mining Rush (3x, 20m)"; "a featured batch of bottled life", not "64 Life Essence". Only `currency.<id>.name` may carry a currency's name, and an item-backed wallet needs none at all because its name comes from the backing item's own translated key.

## The per-skill experience packets, written by one generator

`ShopEntryGenerators/MMOSkillTree/Xp_Packets.json` writes one packet per skill at each of three sizes from a single file, on the same machinery a quest generator uses.

```json
{ "Base": "Xp_Packet",
  "IdPattern": "shop_xp_{tier}_{skill}",
  "ForEach": [
    { "Token": "skill", "Source": "mmoskilltree:skills" },
    { "Token": "tier", "Values": [
      { "tier": "lesser",  "tokens": 75,  "essence": 30,  "xp": 1500,  "minLevel": 1,  "order": 40, "daily": 3 },
      { "tier": "greater", "tokens": 165, "essence": 65,  "xp": 7500,  "minLevel": 30, "order": 42, "daily": 3 },
      { "tier": "master",  "tokens": 330, "essence": 100, "xp": 40000, "minLevel": 60, "order": 44, "daily": 2 } ] } ],
  "Child": {
    "Text": { "TitleKey": "shop.xp_packet.{tier}.title", "TextArgs": { "Title": [ "{skill}" ] } },
    "Cost": { "Currencies": { "bounty_token": "{tokens}", "life_essence": "{essence}" } },
    "Limits": { "Daily": "{daily}" },
    "Pool": { "Id": "XpExchange", "Tier": "{tier}" },
    "Requires": { "Factors": [ { "Factor": "hytale:stat", "Param": "MMO_Level_{skill}", "Min": "{minLevel}" } ] },
    "Rewards": [ { "Kind": "Mmo_Xp", "Params": { "Skill": "{skill}", "Amount": "{xp}" } } ] } }
```

- **`Base`** is an ordinary `Abstract` offer (`Xp_Packet`) carrying what every packet shares: the storefront, the shelf, the icon. It ships no numbers, because every number differs per skill and per size.
- **`ForEach`** is a list of axes. `Source` reads a list some mod enumerates (`mmoskilltree:skills` is every active skill), so a skill added later gets its packets with no edit here. `Values` binds several tokens on ONE row, which keeps "the greater packet costs 165 and wants level 30" stated once instead of reconstructed from parallel lists.
- **Substitution covers every string value, every object KEY, and `IdPattern`.** Substituting a key is load-bearing rather than a nicety: it is how each packet's requirement names its own level channel, `MMO_Level_{skill}`. A value that is exactly one token keeps that token's type, so `"Min": "{minLevel}"` lands as a number.
- **A token nothing binds is an error** and that one offer is skipped, naming the file.
- **`Text.TextArgs`** is how one written line serves the whole family: `shop.xp_packet.{tier}.title` is translated once per size and the skill fills `{0}`.
- **Override one generated packet** by authoring an explicit `ShopEntries` file with that generated id, or by overriding the id in the owner layer.

The three sizes are drawn one each per day by the `XpExchange` shelf's three tier slots, so a given skill and size surfaces roughly every few weeks. The deal is the reward and scarcity is the balance lever: the reroll is deliberately not cheap enough to chase one specific skill. Beside them, `Xp_Packet_All_Skills` stays a STATIC premium (every skill at once, once a day), so the page always has a reliable sink no matter what rotates in.

## Wallets

`Currencies/MMOSkillTree/<Id>.json`. The file name is the wallet id.

```json
{ "Icon": "Ingredient_Bar_Gold", "Color": "#ffcc44", "Cap": 0,
  "Meta": { "mmoskilltree": { "ShowOnSidebar": true, "ShowOnMasteryPage": false,
                              "XpConversionPercent": 0 } } }
```

- **`Backing.Item`** is the one real choice: author it and the balance IS an inventory count, carried and tradable; leave it out and the balance is a number the server keeps. Every other leaf reads the same either way, and an item-backed wallet needs no `Icon` and no name key because both come from the backing item.
- **`Cap`, `OnDeath` and `Decay` are three independent knobs**, each unauthored meaning "no such rule". A share leaf is a FRACTION from 0 to 1: `OnDeath.LossPercent: 0.1` takes a tenth.
- **`Meta` carries knobs only one mod understands**, under that mod's namespace. Nothing in the framework interprets them, which is what lets one wallet file load on a server running only one of the two mods that authored it.
- Owner overrides live in `mods/ziggfreedcommon/currencies.json`, with `shops.json` and `boards.json` beside it for the other two.

## Bounty achievements

The mod ships **board-agnostic** bounty achievements in its own jar (a count ladder, hard and elite difficulty chains, a server-first, a daily streak), driven by the `COMPLETE_BOUNTY` / `BOUNTY_STREAK` moments fired on every completion, so they work with any board including a server's own. This pack adds **per-board** chains (`Daily Contractor`, `Weekly Warrant`, `Quick Contractor`) plus the Snapdragon creature chain, since those board ids only exist when this pack is installed. They live at `Server/ZiggfreedCommon/Achievements/MMOSkillTree/Bounty/<Name>.json`, where the FILE NAME is the achievement id: `Criteria: [{"Kind": "COMPLETE_BOUNTY", "Target": "<board>", "MatchMode": "EXACT", "Amount": N}]`, the ladder on `Listing.Chains: [{"Id": "bounty_board_daily", "Tier": 2}]`, and the shared description line's number from `Text.TextArgs.Flavor: ["@amount"]` so all three rungs translate once. The completion moment carries `target = board id` and `qualifier = difficulty`, so an achievement can match by board, by difficulty, or both. A new board's chain is a copy with the board id and the amounts changed.

## Spawn NPCs (press F to open a page)

`Server/NPC/Roles/Passive/*.json` are native Hytale NPC roles, auto-loaded under `IncludesAssetPack: true` with no `Control` entry. Each is a stationary `Generic` role modeled on the vanilla `Kweebec_Merchant` (it only ever issues `BodyMotion: Nothing`, so it stays put) whose `InteractionInstruction` runs `{"Type": "ZigPlacementInteract"}` on its `HasInteracted` branch. **A role decides the look, the nameplate and the press-F prompt, and nothing else.** `ZigPlacementInteract` reads the PLACEMENT the NPC was spawned from and opens whatever that placement authored, which is what lets one role stand in as many spots as you like, each opening a different board or storefront.

**This pack ships no placements, so none of these characters stands anywhere until a server owner puts one there.** That is deliberate: where a broker belongs is a property of your world, not of the contract pool. A placement is a file of your own at `Server/ZiggfreedCommon/NpcPlacements/<YourId>.json` naming a role and a destination:

```json
{ "Name": "My_Daily_Broker", "Enabled": true,
  "Identity": { "Role": "MMO_Bounty_Daily" },
  "Where": { "Match": [ "default" ] },
  "Anchor": { "WorldSpawn": { "Offset": { "X": 4.0 }, "Yaw": 180.0 } },
  "Lifecycle": { "KeepAlive": true, "Respawn": true, "Fortify": true },
  "Interact": { "Open": { "Type": "Mmo_Board", "Board": "Daily" } } }
```

`Interact.Open` takes `{"Type": "Mmo_Board", "Board": "<id>"}` for a board and `{"Type": "Mmo_Shop", "Shop": "<id>"}` for a storefront (bare `"Mmo_Shop"` opens the default one), and the same vocabulary reaches every other MMO screen. Each role file's own `$Comment` carries this recipe with its own id already filled in. `/mmonpc list` shows what targets each world and what each one opens; `/mmonpc enable|disable <id>` switches one without editing files. Owner overrides live in `mods/ziggfreedcommon/npc-placements.json`.

The **hub** role `MMO_Hub` ships in the mod jar with a placement beside it, which is why the guide appears at world spawn on a fresh server and these six do not. To add a broker for a new board id `<x>`, copy `MMO_Bounty_Daily.json` to `MMO_Bounty_<X>.json`, change the name key and the `$Comment`'s example `Board`, and add the name to `npcs.lang`. `Appearance` reuses a builtin model id (`Kweebec_Rootling` / `Kweebec_Sapling_Orange`) so no model files ship.

## Build and deploy

```powershell
.\build.ps1                  # build the zip, and install it if a Mods folder is known
.\build.ps1 -Install:$false  # build only, no copy
.\build.ps1 -ModsDir <path>  # build + install into an explicit folder
```

`build.ps1` is self-locating (`$PSScriptRoot`) and cross-platform (Windows PowerShell, or `pwsh ./build.ps1` on macOS/Linux). It zips with forward-slash entries AND an explicit directory entry for every ancestor path (Java's `ZipFileSystem.isDirectory()` returns false without them, so Hytale's `I18nModule.loadMessagesFromPack` would skip `items.lang`). Never use `Compress-Archive`; it writes backslash separators Hytale drops. To auto-install on build, set `HYTALE_MODS_DIR` once to your Hytale `UserData/Mods` folder.

Start the server with the mod jar, the ZiggfreedCommon jar and this zip in `Mods/`. Confirm in the log that the Bounties, Boards, Currencies, Shops, ShopPools, ShopEntries and ShopEntryGenerators layers loaded, plus the validation summaries, and no `Asset validation FAILED`. In-game: craft and place a board block and interact, or `/mmobountyui <you> daily`.

## Conventions

File names are PascalCase and ARE the id, matched case-insensitively (so `Bounty_Hunt_Trork.json` is the contract `bounty_hunt_trork` a saved quest, an achievement criterion or a conversation already refers to). Codec keys start upper-case, which Hytale's asset codecs require. A `$Comment` in any shipped file is a TIP for the server owner or pack author reading it: what the file does, what each number means in game, how to tune it. There is no template DSL and no `Payload` wrapper anywhere: inheritance is native `Parent`, and a family of near-identical files is a generator.
