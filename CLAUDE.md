# Bounty Contracts Pack

Content pack for the bounty boards, shops and wallets. The family-wide rules apply here; this file adds only what is specific to this pack.

- `zc-commerce` owns the board, shop and wallet engines and its codecs are the schema. The MMO adds its reward kinds, the `mmoskilltree:skills` axis a generator's `ForEach` reads, and the `/mmobounty`, `/mmoshop` and `/mmocurrency` admin commands.
- A contract's `Rewards.Claim` is one inherited leaf: authoring it replaces the skeleton's whole list, and every contract pays under `Claim` because it parks at the board.
- Deliberate economy rule: Training-band contracts pay a small nominal token and Bihourly contracts pay XP only. The token faucet is the Daily/Weekly easy-normal-hard ladder, so never raise those to full token pay.
- A seasonal contract gates on its event's running switch, `{"Factor": "ziggfreedcommon:feature", "Param": "<Event>_Live", "Min": 1}`, at the top level of `Requires` (never `ziggfreedcommon:calendar_live`, which only locks, and never the MMO's `Bounties` feature, which reads the contracts back), and posts in the Daily board's `Seasonal` band, whose optional slot stays last so it never moves a regular posting.
- Offer purchase limits are stored per player under the offer id, so renaming an offer resets everyone's counts. The Essence Infusion keeps its old id `Shop_Convert_Mastery_Point` for that reason; it pays the Mastery Pack's `Mmo_Mastery_Element_Pair` table, so its top-level `hytale:mod_installed` condition on `Ziggfreed:MMOSkillMasteryPack` keeps it off a server without that pack.
- An offer on a fully slotted shelf needs a `Pool.Tier`; without one it only fits an unslotted draw.
- The Life Essence wallet ships in CommonLib (`Currencies/ZiggfreedCommon/Life_Essence.json`, the game's own item) and Mastery Point in the MMO jar: this pack reads them and never ships a copy (R880, M513; the MMO's `LifeEssenceWalletTest` fails on one). Bounty Token is this pack's only wallet.
- For an ore the mined block and the returned item share an id. Check a `Target` id against the installed `Assets.zip` (the assets rule's one-liner, items pattern; id = filename), never the reference tree, which can run ahead of the install, and let a lane boot (`tools\lane\lane.ps1 boot`, the `dev-server` skill) confirm it ships.
- Copy naming: the feature is "the shops"; "Token Shop" names only the General storefront, beside the per-skill "XP Exchange".
