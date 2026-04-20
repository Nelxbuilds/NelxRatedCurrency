# NelxRatedCurrency

WoW addon. Interface: 120001 (Midnight Season 1). Author: Nelxbuilds.

## Purpose

Track all PvP currencies (honor, conquest, marks, etc.) per character.

- Tooltip on hover over PvP currency items/icons
- Full overview panel via `/nrc` or minimap button
- Settings: hide/show tracked chars, disable tooltip extension

## Files

- `NelxRatedCurrency.toc` — manifest, lib load order, SavedVariables declaration
- `NelxRatedCurrency.lua` — bootstrap, SavedVariables init, `ns.TRACKED_CURRENCIES`, `ns.TRACKED_ITEMS`, `ns.GetCharKey()`, currency + item capture
- `Tooltip.lua` — tooltip hooks + per-char currency rows
- `MainFrame.lua` — single main frame with sidebar navigation, color palette (`ns.COLORS`), shared backdrop (`ns.NRC_BACKDROP`), tab switching, public API (`ns.ToggleOverview()`, `ns.ShowOverview()`, `ns.ToggleSettings()`, `ns.ShowSettings()`)
- `OverviewUI.lua` — overview tab panel creator (`ns.CreateOverviewPanel(parent)`), sortable currency table with alternating row colors
- `SettingsUI.lua` — settings tab panel creator (`ns.CreateSettingsPanel(parent)`), About / Characters / Options sections
- `MinimapButton.lua` — LibDBIcon registration, minimap button behavior
- `libs/` — embedded: LibStub, CallbackHandler-1.0, LibDataBroker-1.1, LibDBIcon-1.0

## SavedVariables

`NelxRatedCurrencyDB` — persisted per account. Init on `ADDON_LOADED`.

## Architecture Notes

- `ns` (namespace table) passed via `...` — use for all module-level shared state
- `ns.db` → `NelxRatedCurrencyDB` after `ADDON_LOADED`
- `ns.TRACKED_CURRENCIES = { {id, name}, ... }` — source of truth for currency list; add new currencies here only
- `ns.TRACKED_ITEMS = { {id, name}, ... }` — source of truth for tracked bag items (Mark of Honor, Flask of Honor, Medal of Conquest); add new items here only
- `ns.GetCharKey()` — returns `"Name-Realm"` key for current char
- Single main frame (`NelxRatedCurrencyMainFrame`) with sidebar + 2 tab panels (Overview, Settings)
- `MainFrame.lua` defines public API: `ns.ToggleOverview()`, `ns.ShowOverview()`, `ns.ToggleSettings()`, `ns.ShowSettings()`
- `OverviewUI.lua` and `SettingsUI.lua` export panel creator functions, not standalone frames
- Main frame lazy-created on first open, in `UISpecialFrames` (ESC closes)
- MinimapButton registers on `PLAYER_LOGIN` to guarantee `ns.db` ready
- Architecture mirrors NelxRated's MainFrame.lua pattern (sidebar nav + tabbed content)

## WoW API Patterns

- Currency data: `C_CurrencyInfo.GetCurrencyInfo(currencyID)` → `info.quantity`, `info.maxQuantity`
- Tooltip (currency tab): `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, fn)`
- Tooltip (bag items): `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, fn)` — use `data.id` for itemID; supersedes `GameTooltip:HookScript("OnTooltipSetItem")` approach
- Minimap: LibDBIcon-1.0 in `libs/`; position saved in `ns.db.settings.minimapPosition`
- Multi-char key: `UnitName("player").."-"..GetRealmName()`
- SlashCmd: `SLASH_NELXRATEDCURRENCY1 = "/nrc"`
- Addon version: `C_AddOns.GetAddOnMetadata(addonName, "Version")`
- Class colors: `RAID_CLASS_COLORS[classFileName]` → `.r`, `.g`, `.b`

## UI Color Theme

Gold theme on neutral gray backgrounds. Mirrors NelxRated's visual style (crimson → gold).

Color palette defined in `MainFrame.lua` as `ns.COLORS`:

| Role | Constant | R | G | B | A |
|------|----------|---|---|---|---|
| Background (base) | BG_BASE | 0.06 | 0.06 | 0.06 | 0.95 |
| Background (raised) | BG_RAISED | 0.10 | 0.10 | 0.10 | 0.95 |
| Accent (bright) | GOLD_BRIGHT | 1.0 | 0.82 | 0.0 | — |
| Accent (mid) | GOLD_MID | 0.7 | 0.57 | 0.0 | — |
| Frame border | GOLD_DIM | 0.35 | 0.28 | 0.0 | — |
| Title / header text | GOLD | 1.0 | 0.82 | 0.0 | — |
| Highlight / hover | — | 1.0 | 1.0 | 0.6 | — |

Backdrop: `Interface\Buttons\WHITE8x8`, edgeSize 2. Rows: alternating (0.08/0.12 gray, 0.5 alpha).

## SavedVariables Schema

```
NelxRatedCurrencyDB = {
  schemaVersion = 1,
  characters = {
    ["Name-Realm"] = {
      name, realm, classFileName, classDisplayName,
      currencies = { [currencyID] = { amount, maxQuantity } },
      items = { [itemID] = { count } }
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
- Add bag items: edit `ns.TRACKED_ITEMS` in `NelxRatedCurrency.lua` only; also add column def to `COLUMNS` in `OverviewUI.lua`
- Main frame size: 660x440, sidebar 140px wide
- `COLUMNS` in `OverviewUI.lua` drives both header render and row render — type field: `"name"` | `"currency"` | `"item"`
- Item counts captured via `GetItemCount(itemID, true)` (includes bank)
