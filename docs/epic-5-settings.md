# Epic 5 — Settings UI

Provide a standalone settings panel where the player can read addon metadata, hide/show individual tracked characters, and toggle global addon options.

---

## Story 5-1 — Settings Frame

**Goal**: Create the settings panel frame with correct sizing, gold styling, and three clearly separated sections.

**Acceptance Criteria**:

- [ ] The frame is created lazily (on first open, not at addon load time) via `CreateFrame("Frame", "NelxRatedCurrencySettingsFrame", UIParent, "BasicFrameTemplateWithInset")`
- [ ] Frame size is 380×460 pixels
- [ ] The frame is centered on screen when first shown
- [ ] The frame is draggable by its title bar
- [ ] The frame title text reads `"NelxRatedCurrency — Settings"`
- [ ] Border/accent color is R=1, G=0.82, B=0; background fill is R=0.05, G=0.04, B=0 at alpha 0.85 (matching the overview panel)
- [ ] The frame body contains three sections in top-to-bottom order: **About**, **Characters**, **Settings**
- [ ] Each section is separated from the next by a thin horizontal line rendered in gold color (R=1, G=0.82, B=0)
- [ ] The **About** section displays static text: addon name, version (from `C_AddOns.GetAddOnMetadata(addonName, "Version")`), author (`"Nelxbuilds"`), and a one-line description
- [ ] The panel can be closed via the frame's built-in close button
- [ ] The frame is added to `UISpecialFrames` so pressing ESC closes it

---

## Story 5-2 — Characters Section

**Goal**: Show all characters that have been seen by the addon and let the player hide or show each one individually, affecting both tooltip and overview panel.

**Acceptance Criteria**:

- [ ] The Characters section lists every key present in `ns.db.characters`, one row per character
- [ ] Each row displays the character name in the WoW class color sourced from `RAID_CLASS_COLORS[classFileName]`
- [ ] Each row has a checkbox on the right side
- [ ] A checked checkbox means the character is visible (default for any character not in `hiddenCharacters`)
- [ ] An unchecked checkbox means the character is hidden
- [ ] Toggling the checkbox immediately sets or clears `ns.db.settings.hiddenCharacters[charKey] = true` — no Apply button required
- [ ] A character hidden via this panel is excluded from both tooltip rows (Epic 2) and the overview table (Epic 3) immediately after toggle
- [ ] If more than 8 characters are present, the list becomes scrollable via a standard WoW scroll frame
- [ ] Characters are listed in alphabetical A-Z order by character name

---

## Story 5-3 — Settings Section

**Goal**: Expose the global tooltip toggle as a checkbox the player can flip without reloading the UI.

**Acceptance Criteria**:

- [ ] The Settings section contains one checkbox labeled `"Disable tooltip extension"`
- [ ] The checkbox is created via `CreateFrame("CheckButton", nil, parentFrame, "UICheckButtonTemplate")`
- [ ] The label text is rendered in white
- [ ] When checked, `ns.db.settings.disableTooltip` is set to `true` immediately
- [ ] When unchecked, `ns.db.settings.disableTooltip` is set to `false` immediately
- [ ] When the settings panel is opened, the checkbox reflects the current value of `ns.db.settings.disableTooltip`
- [ ] The change takes effect for all subsequent tooltip renders without requiring a UI reload
