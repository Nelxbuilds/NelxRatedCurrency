# NelxRatedCurrency

WoW addon. Interface: 120001 (Midnight Season 1). Author: Nelxbuilds.

## Purpose

Track all PvP currencies (honor, conquest, marks, etc.) per character.

- Tooltip on hover over PvP currency items/icons
- Full overview panel via `/` command or minimap button
- Settings: hide/show tracked characters to reduce noise

## Files

- `NelxRatedCurrency.toc` — manifest, interface version, SavedVariables declaration
- `NelxRatedCurrency.lua` — main logic (currently scaffold)

## SavedVariables

`NelxRatedCurrencyDB` — persisted per account. Initialized on `ADDON_LOADED`.

## Architecture Notes

- `ns` (namespace table) passed via `...` — use for all module-level shared state
- `ns.db` points to `NelxRatedCurrencyDB` after load
- Register new events on the existing `frame` or create sub-frames per feature

## WoW API Patterns

- Currency data: `C_CurrencyInfo.GetCurrencyInfo(currencyID)`
- Tooltip hooks: `GameTooltip:HookScript("OnTooltipSetItem", ...)` or `TooltipDataProcessor`
- Minimap button: use LibDBIcon or manual `CreateFrame("Button", nil, Minimap)`
- Multi-char data: key `NelxRatedCurrencyDB` by `UnitName("player").."-"..GetRealmName()`
- SlashCmd: `SLASH_NELXRATEDCURRENCY1 = "/nrc"`

## UI Color Theme

Gold theme. Use consistently across all frames, borders, text accents.

| Role | R | G | B | Hex | WoW SetRGB |
|------|---|---|---|-----|------------|
| Border / accent | 1.0 | 0.82 | 0.0 | `#FFD100` | `1, 0.82, 0` |
| Header text | 1.0 | 0.90 | 0.4 | `#FFE666` | `1, 0.9, 0.4` |
| Background (dark) | 0.05 | 0.04 | 0.0 | `#0D0A00` | `0.05, 0.04, 0` |
| Subtext / dim | 0.75 | 0.65 | 0.3 | `#BFA64D` | `0.75, 0.65, 0.3` |
| Highlight / hover | 1.0 | 1.0 | 0.6 | `#FFFF99` | `1, 1, 0.6` |

Border thickness: 1px. Corner style: square. Background alpha: 0.85.

## Dev Notes

- Test in-game: copy addon folder to `WoW/_retail_/Interface/AddOns/NelxRatedCurrency`
- Reload UI after changes: `/reload`
- Print debug: `DEFAULT_CHAT_FRAME:AddMessage("...")`
