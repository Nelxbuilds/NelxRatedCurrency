# Epic 3 — Overview Panel

Provide a toggleable panel that displays all tracked characters and their PvP currency amounts in a sortable table, accessible via slash command.

---

## Story 3-1 — Panel Frame

**Goal**: Create the main overview panel frame with correct size, styling, and toggle behavior wired to the `/nrc` slash command.

**Acceptance Criteria**:

- [ ] The frame is created lazily (on first open, not at addon load time) via `CreateFrame("Frame", "NelxRatedCurrencyFrame", UIParent, "BasicFrameTemplateWithInset")`
- [ ] Frame size is 500×350 pixels
- [ ] The frame is centered on screen the first time it is shown
- [ ] The frame is draggable by its title bar
- [ ] The frame title text reads `"NelxRatedCurrency"`
- [ ] Border/accent color is set to R=1, G=0.82, B=0
- [ ] Background is a solid dark fill with R=0.05, G=0.04, B=0 at alpha 0.85
- [ ] `SLASH_NELXRATEDCURRENCY1 = "/nrc"` is registered and toggles the panel (show if hidden, hide if shown)
- [ ] The panel can be closed via the frame's built-in close button provided by `BasicFrameTemplateWithInset`
- [ ] The frame is added to `UISpecialFrames` so pressing ESC closes it

---

## Story 3-2 — Currency Table

**Goal**: Populate the overview panel with a table showing each tracked character's PvP currency amounts, one character per row.

**Acceptance Criteria**:

- [ ] The table has a header row with columns: `"Character"`, `"Honor"`, `"Conquest"`
- [ ] Header text is rendered in gold color (R=1, G=0.9, B=0.4)
- [ ] Each data row corresponds to one character in `ns.db.characters`
- [ ] Characters whose key is present in `ns.db.settings.hiddenCharacters` are not rendered
- [ ] Character name in each row is rendered in the WoW class color sourced from `RAID_CLASS_COLORS[classFileName]`
- [ ] Honor amount is displayed as a plain number (white text)
- [ ] Conquest amount is displayed as `"amount / maxQuantity"` (white text)
- [ ] Characters with no data for a given currency display `"—"` in that cell
- [ ] Default sort order is character name A-Z
- [ ] The table refreshes its contents each time the panel is shown

---

## Story 3-3 — Column Sorting

**Goal**: Allow the player to click any column header to re-sort the character table by that column.

**Acceptance Criteria**:

- [ ] Clicking a column header sorts the table by that column ascending
- [ ] Clicking the same column header a second time reverses the sort to descending
- [ ] Clicking a different column header resets to ascending for the new column
- [ ] The active sort column header displays a `▲` suffix when ascending, `▼` suffix when descending
- [ ] Inactive column headers show no sort indicator
- [ ] The `"Character"` column sorts alphabetically (A-Z ascending, Z-A descending) by character name
- [ ] Currency columns sort numerically by `amount` (low-to-high ascending, high-to-low descending)
- [ ] Characters with no data for a sorted currency column are ranked last regardless of sort direction
