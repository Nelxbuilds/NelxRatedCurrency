# NelxRatedCurrency

A World of Warcraft addon for **Midnight Season 1** (Interface 120001) that tracks PvP currencies across all your characters — Honor, Conquest, and more — with tooltip integration and a full multi-character overview panel.

## Features

- **Multi-Character Tracking** — automatically captures Honor, Conquest, and other PvP currencies for every character on login and currency updates
- **Tooltip Extension** — hover any PvP currency icon or bag item to instantly see amounts across all your characters, colored by class
- **Overview Panel** — `/nrc` opens a sortable table showing all characters × currencies at a glance
- **Column Sorting** — click any column header to sort by character name or currency amount
- **Minimap Button** — left-click to toggle the overview panel, right-click for settings; draggable with saved position
- **Settings Panel** — hide individual characters from tooltips and the overview, or disable tooltip extension entirely
- **Gold UI Theme** — clean, consistent gold accent theme throughout all frames

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
