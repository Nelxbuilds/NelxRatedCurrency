# Epic 1 — Core & Data Layer

Initialize the addon, establish the namespace, set up SavedVariables with a safe default structure, and capture per-character PvP currency data on login and currency updates.

---

## Story 1-1 — Addon Bootstrap & SavedVariables

**Goal**: Establish the addon entry point, wire up the namespace table (`ns`), and initialize `NelxRatedCurrencyDB` with a safe default structure so all other modules have a reliable data foundation.

**Acceptance Criteria**:

- [x] `NelxRatedCurrency.toc` declares `SavedVariables: NelxRatedCurrencyDB` and lists `NelxRatedCurrency.lua`
- [x] `NelxRatedCurrency.lua` receives the addon namespace via `local addonName, ns = ...`
- [x] On `ADDON_LOADED` (filtered to this addon's name), `NelxRatedCurrencyDB` is initialized with: `characters = {}`, `settings = {}`, `schemaVersion = 1`
- [x] `ns.db` is assigned to point at `NelxRatedCurrencyDB` immediately after initialization
- [x] `NelxRatedCurrencyDB` is not read at file-load time — only inside or after the `ADDON_LOADED` handler
- [x] Settings sub-table defaults: `disableTooltip = false`, `hiddenCharacters = {}`, `minimapPosition = {}`

**Technical Hints**:

- Guard with `NelxRatedCurrencyDB = NelxRatedCurrencyDB or {}`, then init each sub-table with `subtable = subtable or {}`
- The `ADDON_LOADED` event fires for every addon; filter by comparing the first arg to `addonName`

---

## Story 1-2 — Character Currency Capture

**Goal**: On login and whenever currency values change, capture PvP currency amounts for the current character and persist them into `ns.db.characters` keyed by character identity.

**Acceptance Criteria**:

- [x] `ns.GetCharKey()` is a function that returns `UnitName("player").."-"..GetRealmName()`
- [x] The addon registers for both `PLAYER_ENTERING_WORLD` and `CURRENCY_DISPLAY_UPDATE` events
- [x] On either event, currency data is captured for the current character using `ns.GetCharKey()`
- [x] Each character record stored at `ns.db.characters[charKey]` contains: `name` (string), `realm` (string), `classFileName` (e.g. `"WARRIOR"`), `classDisplayName` (e.g. `"Warrior"`), `currencies` (table)
- [x] `name` and `realm` are sourced from `UnitName("player")` and `GetRealmName()`
- [x] `classFileName` and `classDisplayName` are sourced from `UnitClass("player")`
- [x] A shared constant table `ns.TRACKED_CURRENCIES` is defined: `{ { id = 1792, name = "Honor" }, { id = 1602, name = "Conquest" } }` — all other epics reference this table instead of hardcoding IDs
- [x] Currency IDs tracked in v1 (fixed list): Honor = `1792`, Conquest = `1602`
- [x] For each tracked currency ID, `C_CurrencyInfo.GetCurrencyInfo(currencyID)` is called and the result stored at `ns.db.characters[charKey].currencies[currencyID]` with fields: `amount` (number), `maxQuantity` (number)
- [x] If `C_CurrencyInfo.GetCurrencyInfo` returns nil for a given currency ID, that currency is skipped silently — no error is raised
- [x] If a character record already exists, all fields are updated in-place; no data is lost on re-capture
- [x] Currency capture is guarded — does not run before `ns.db` is initialized (i.e. before `ADDON_LOADED`)

**Technical Hints**:

- `C_CurrencyInfo.GetCurrencyInfo` returns a `CurrencyInfo` table; `maxQuantity` holds the season cap and is relevant for Conquest (1602); Honor (1792) will typically have `maxQuantity = 0`
- `CURRENCY_DISPLAY_UPDATE` fires without arguments — always re-capture all tracked currency IDs when it fires
