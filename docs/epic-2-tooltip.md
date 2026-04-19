# Epic 2 — Tooltip Extension

Hook into the WoW tooltip system to append per-character PvP currency data when the player hovers over a tracked PvP currency icon or item.

---

## Story 2-1 — Tooltip Hook

**Goal**: Intercept tooltip rendering for tracked PvP currency icons and items so that currency data rows can be appended.

**Acceptance Criteria**:

- [x] The addon hooks `GameTooltip` to detect when a tracked currency (ID 1792 or 1602) is being displayed
- [x] The hook fires for currency icons in the Currency tab of the default UI
- [x] The hook fires for PvP currency items in the player's bag
- [x] When the hovered currency/item matches a tracked currency ID and `ns.db.settings.disableTooltip == false`, the tooltip append logic runs
- [x] When `ns.db.settings.disableTooltip == true`, no rows are appended and the tooltip is not modified
- [x] The hook does not error when `ns.db` is not yet initialized

**Technical Hints**:

- Use `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, fn)` for currency tab icons; use `GameTooltip:HookScript("OnTooltipSetItem", fn)` for bag items
- For bag items, verify the correct API to retrieve currency ID from an item link in-game before implementing (`C_CurrencyInfo.GetCurrencyContainerCurrencyID` may apply)

---

## Story 2-2 — Tooltip Content

**Goal**: Render a clearly formatted, per-character currency breakdown inside the tooltip whenever a tracked currency is hovered.

**Acceptance Criteria**:

- [x] A blank separator line is added first, followed by a header line reading `"NelxRatedCurrency"` rendered in gold color (R=1, G=0.82, B=0)
- [x] For each character in `ns.db.characters`, a row is added only if: the character has a non-zero `amount` for the hovered currency ID, AND the character key is NOT present in `ns.db.settings.hiddenCharacters`
- [x] Each row displays the character name in the WoW class color sourced from `RAID_CLASS_COLORS[classFileName]`, followed by the currency amount in white text
- [x] Conquest (ID 1602) rows display amount and season cap formatted as `"amount / maxQuantity"` (e.g. `"1200 / 2000"`)
- [x] Honor (ID 1792) rows display amount only (e.g. `"4500"`)
- [x] Character rows are sorted alphabetically A-Z by character name before rendering
- [x] If no characters have a non-zero amount for the hovered currency, nothing is appended (header included — tooltip is left untouched)
