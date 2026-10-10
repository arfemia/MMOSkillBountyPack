# Bounty Contracts Pack

Content pack for the bounty boards, shops and wallets. The family-wide rules apply here; this file adds only what is specific to this pack.

- `zc-commerce` owns the board, shop and wallet engines and its codecs are the schema. The MMO only adds reward kinds and the `/mmobounty` and `/mmoshop` aliases.
- A contract's `Rewards.Claim` is one inherited leaf: authoring it replaces the skeleton's whole list, and every contract pays under `Claim` because it parks at the board.
- Deliberate economy rule: Training-band contracts pay a small nominal token and Bihourly contracts pay XP only. The token faucet is the Daily/Weekly easy-normal-hard ladder, so never raise those to full token pay.
- A seasonal contract gates on its event's running switch, `{"Factor": "ziggfreedcommon:feature", "Param": "<Event>_Live", "Min": 1}`, at the top level of `Requires` (never `ziggfreedcommon:calendar_live`, which only locks, and never the MMO's `Bounties` feature, which reads the contracts back), and posts in the Daily board's `Seasonal` band, whose optional slot stays last so it never moves a regular posting.
- Offer purchase limits are stored per player under the offer id, so renaming an offer resets everyone's counts.
- An offer on a fully slotted shelf needs a `Pool.Tier`; without one it only fits an unslotted draw.
- `Life_Essence.json` ships identically here and in the mastery pack so each works alone; change both together.
- For an ore the mined block and the returned item share an id. Verify a `Target` against `reference/shared-source/release/HytaleAssets/Server/Item/Items` (id = filename) and let `dev-server.ps1 -Check` confirm it ships.
- Copy naming: the feature is "the shops"; "Token Shop" names only the General storefront, beside the per-skill "XP Exchange".
