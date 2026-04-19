# Epic 1 — Core & Data Layer

Initialize the addon, establish the namespace, set up SavedVariables with a safe default structure, and capture per-character PvP currency data on login and currency updates.

---

## Story 1-1 — Addon Bootstrap & SavedVariables

**Goal**: Establish the addon entry point, wire up the namespace table (`ns`), and initialize `NelxRatedCurrencyDB` with a safe default structure so all other modules have a reliable data foundation.

**Acceptance Criteria**:

- [ ] `NelxRatedCurrency.toc` declares `SavedVariables: NelxRatedCurrencyDB` and lists `NelxRatedCurrency.lua`
- [ ] `NelxRatedCurrency.lua` receives the addon namespace via `local addonName, ns = ...`
- [ ] On `ADDON_LOADED` (filtered to this addon's name), `NelxRatedCurrencyDB` is initialized with: `characters = {}`, `settings = {}`, `schemaVersion = 1`
- [ ] `ns.db` is assigned to point at `NelxRatedCurrencyDB` immediately after initialization
- [ ] `NelxRatedCurrencyDB` is not read at file-load time — only inside or after the `ADDON_LOADED` handler
- [ ] Settings sub-table defaults: `disableTooltip = false`, `hiddenCharacters = {}`

**Technical Hints**:

- Guard with `NelxRatedCurrencyDB = NelxRatedCurrencyDB or {}`, then init each sub-table with `subtable = subtable or {}`
- The `ADDON_LOADED` event fires for every addon; filter by comparing the first arg to `addonName`

---

## Story 1-2 — Character Currency Capture

**Goal**: On login and whenever currency values change, capture PvP currency amounts for the current character and persist them into `ns.db.characters` keyed by character identity.

**Acceptance Criteria**:

- [ ] `ns.GetCharKey()` is a function that returns `UnitName("player").."-"..GetRealmName()`
- [ ] The addon registers for both `PLAYER_ENTERING_WORLD` and `CURRENCY_DISPLAY_UPDATE` events
- [ ] On either event, currency data is captured for the current character using `ns.GetCharKey()`
- [ ] Each character record stored at `ns.db.characters[charKey]` contains: `name` (string), `realm` (string), `classFileName` (e.g. `"WARRIOR"`), `classDisplayName` (e.g. `"Warrior"`), `currencies` (table)
- [ ] `name` and `realm` are sourced from `UnitName("player")` and `GetRealmName()`
- [ ] `classFileName` and `classDisplayName` are sourced from `UnitClass("player")`
- [ ] Currency IDs tracked in v1 (fixed list): Honor = `1792`, Conquest = `1602`
- [ ] For each tracked currency ID, `C_CurrencyInfo.GetCurrencyInfo(currencyID)` is called and the result stored at `ns.db.characters[charKey].currencies[currencyID]` with fields: `amount` (number), `maxQuantity` (number)
- [ ] If `C_CurrencyInfo.GetCurrencyInfo` returns nil for a given currency ID, that currency is skipped silently — no error is raised
- [ ] If a character record already exists, all fields are updated in-place; no data is lost on re-capture

**Technical Hints**:

- `C_CurrencyInfo.GetCurrencyInfo` returns a `CurrencyInfo` table; `maxQuantity` holds the season cap and is relevant for Conquest (1602); Honor (1792) will typically have `maxQuantity = 0`
- `CURRENCY_DISPLAY_UPDATE` fires without arguments — always re-capture all tracked currency IDs when it fires
