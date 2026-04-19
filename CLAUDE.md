# NelxRatedCurrency

WoW addon. Interface: 120001 (Midnight Season 1). Author: Nelxbuilds.

## Purpose

Track all PvP currencies (honor, conquest, marks, etc.) per character.

- Tooltip on hover over PvP currency items/icons
- Full overview panel via `/nrc` or minimap button
- Settings: hide/show tracked chars, disable tooltip extension

## Files

- `NelxRatedCurrency.toc` — manifest, lib load order, SavedVariables declaration
- `NelxRatedCurrency.lua` — bootstrap, SavedVariables init, `ns.TRACKED_CURRENCIES`, `ns.GetCharKey()`, currency capture
- `Tooltip.lua` — tooltip hooks + per-char currency rows
- `OverviewUI.lua` — overview panel, sortable table, `ns.ToggleOverview()`
- `SettingsUI.lua` — settings frame (About / Characters / Settings), `ns.ShowSettings()`
- `MinimapButton.lua` — LibDBIcon registration, minimap button behavior
- `libs/` — embedded: LibStub, CallbackHandler-1.0, LibDataBroker-1.1, LibDBIcon-1.0

## SavedVariables

`NelxRatedCurrencyDB` — persisted per account. Init on `ADDON_LOADED`.

## Architecture Notes

- `ns` (namespace table) passed via `...` — use for all module-level shared state
- `ns.db` → `NelxRatedCurrencyDB` after `ADDON_LOADED`
- `ns.TRACKED_CURRENCIES = { {id, name}, ... }` — source of truth for currency list; add new currencies here only
- `ns.GetCharKey()` — returns `"Name-Realm"` key for current char
- `ns.ToggleOverview()` / `ns.ShowOverview()` — overview panel public API
- `ns.ShowSettings()` / `ns.ToggleSettings()` — settings panel public API
- Both UI frames lazy (created on first open, not at load)
- Both frames in `UISpecialFrames` (ESC closes)
- MinimapButton registers on `PLAYER_LOGIN` to guarantee `ns.db` ready

## WoW API Patterns

- Currency data: `C_CurrencyInfo.GetCurrencyInfo(currencyID)` → `info.quantity`, `info.maxQuantity`
- Tooltip (currency tab): `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, fn)`
- Tooltip (bag items): `GameTooltip:HookScript("OnTooltipSetItem", fn)` + `C_CurrencyInfo.GetCurrencyContainerCurrencyID` (nil-guard — may not exist in 12.x)
- Minimap: LibDBIcon-1.0 in `libs/`; position saved in `ns.db.settings.minimapPosition`
- Multi-char key: `UnitName("player").."-"..GetRealmName()`
- SlashCmd: `SLASH_NELXRATEDCURRENCY1 = "/nrc"`
- Addon version: `C_AddOns.GetAddOnMetadata(addonName, "Version")`
- Class colors: `RAID_CLASS_COLORS[classFileName]` → `.r`, `.g`, `.b`

## UI Color Theme

Gold theme. Use across all frames, borders, text accents.

| Role | R | G | B | Hex | WoW SetRGB |
|------|---|---|---|-----|------------|
| Border / accent | 1.0 | 0.82 | 0.0 | `#FFD100` | `1, 0.82, 0` |
| Header text | 1.0 | 0.90 | 0.4 | `#FFE666` | `1, 0.9, 0.4` |
| Background (dark) | 0.05 | 0.04 | 0.0 | `#0D0A00` | `0.05, 0.04, 0` |
| Subtext / dim | 0.75 | 0.65 | 0.3 | `#BFA64D` | `0.75, 0.65, 0.3` |
| Highlight / hover | 1.0 | 1.0 | 0.6 | `#FFFF99` | `1, 1, 0.6` |

Border: 1px. Corners: square. Background alpha: 0.85.

## SavedVariables Schema

```
NelxRatedCurrencyDB = {
  schemaVersion = 1,
  characters = {
    ["Name-Realm"] = {
      name, realm, classFileName, classDisplayName,
      currencies = { [currencyID] = { amount, maxQuantity } }
    }
  },
  settings = {
    disableTooltip = false,
    hiddenCharacters = { ["Name-Realm"] = true },
    minimapPosition = { ... },  -- managed by LibDBIcon
  }
}
```

## Dev Notes

- Test: copy addon folder → `WoW/_retail_/Interface/AddOns/NelxRatedCurrency`
- Reload: `/reload`
- Debug print: `DEFAULT_CHAT_FRAME:AddMessage("...")`
- Add currencies: edit `ns.TRACKED_CURRENCIES` in `NelxRatedCurrency.lua` only