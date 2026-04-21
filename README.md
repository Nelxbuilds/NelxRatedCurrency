# NelxRatedCurrency

A World of Warcraft addon for **Midnight Season 1** (Interface 120001) that tracks PvP currencies across all your characters — Honor, Conquest, Mark of Honor, Flask of Honor, and Medal of Conquest — with tooltip integration and a full multi-character overview panel.

## Features

- **Multi-Character Tracking** — automatically captures PvP currencies and bag items for every character on login and currency updates
- **Tooltip Extension** — hover any PvP currency icon or tracked bag item to see amounts across all characters, colored by class
- **Overview Panel** — sortable table showing all characters × currencies at a glance, with alternating row colors and scroll support
- **Column Sorting** — click any column header to sort ascending/descending by name or amount
- **Sidebar Navigation** — unified main frame with Overview and Settings tabs, matching the NelxRated UI style
- **Minimap Button** — left-click to toggle the overview, right-click for settings; draggable with saved position
- **Settings Panel** — hide individual characters from tooltips and the overview, or disable tooltip extension entirely
- **Gold UI Theme** — gold accents on neutral dark backgrounds, consistent across all panels

## Usage

| Action | How |
|--------|-----|
| Open overview | `/nrc` or left-click minimap button |
| Open settings | Right-click minimap button |
| Hide a character | Settings → Characters → uncheck |
| Disable tooltip | Settings → Settings → Disable tooltip extension |

## Installation

1. Download and extract the addon.
2. Copy the `NelxRatedCurrency` folder to:

```
WoW/_retail_/Interface/AddOns/NelxRatedCurrency
```

3. Reload your UI: `/reload`

Currency data is saved per account and persists across sessions automatically.

## Compatibility

- **Game Version:** Midnight Season 1 (Interface 120001)
- **Retail WoW** only

## Author

**Nelxbuilds**

## Built With

This addon was developed with the assistance of [Claude Code](https://claude.ai/code) by Anthropic — from architecture and implementation to release automation.
