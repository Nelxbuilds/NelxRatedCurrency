# Epic 4 — Minimap Button

Embed the LibDBIcon library stack and register a draggable minimap button that gives quick access to the overview and settings panels.

---

## Story 4-1 — Embed LibDBIcon

**Goal**: Bundle all required library files directly in the addon folder so no external dependencies are needed by the user.

**Acceptance Criteria**:

- [ ] The following libraries are present under `libs/` inside the addon folder: LibStub, CallbackHandler-1.0, LibDataBroker-1.1, LibDBIcon-1.0
- [ ] `NelxRatedCurrency.toc` lists each library's main Lua file in load order before `NelxRatedCurrency.lua`
- [ ] The addon loads and initializes without error when none of these libraries are loaded by any other addon
- [ ] The addon does not break if another addon has already loaded the same library versions (LibStub handles deduplication automatically)

---

## Story 4-2 — Minimap Button Behavior

**Goal**: Register a draggable minimap button that toggles the overview panel on left-click and opens the settings panel on right-click, with position persisted across sessions.

**Acceptance Criteria**:

- [ ] A LibDataBroker data object is registered with `type = "launcher"` and `icon = "Interface\\Icons\\INV_Misc_Coin_01"`
- [ ] The data object is registered with LibDBIcon, passing `ns.db.settings.minimapPosition` as the saved position table
- [ ] `ns.db.settings.minimapPosition` is initialized to `{}` if nil so LibDBIcon can write into it
- [ ] Left-clicking the minimap button toggles the overview panel (same behavior as `/nrc`)
- [ ] Right-clicking the minimap button opens the settings panel (`NelxRatedCurrencySettingsFrame`)
- [ ] The button is draggable around the minimap edge
- [ ] On hover, the minimap button shows a tooltip: `"NelxRatedCurrency"` as title, `"Left-click: Toggle overview"` and `"Right-click: Settings"` as hint lines
- [ ] The button's position around the minimap edge persists across sessions via `ns.db.settings.minimapPosition`
