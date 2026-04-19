-- NelxRatedCurrency.lua — Core & Data Layer (Epic 1)
local addonName, ns = ...

-- ---------------------------------------------------------------------------
-- Tracked currencies — defined once, referenced everywhere (Epic 1, Story 1-2)
-- ---------------------------------------------------------------------------
ns.TRACKED_CURRENCIES = {
    { id = 1792, name = "Honor" },
    { id = 1602, name = "Conquest" },
}

-- ---------------------------------------------------------------------------
-- Helper: build character key
-- ---------------------------------------------------------------------------
function ns.GetCharKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

-- ---------------------------------------------------------------------------
-- Currency capture
-- ---------------------------------------------------------------------------
local function CaptureCurrencies()
    if not ns.db then return end

    local charKey = ns.GetCharKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    local classDisplayName, classFileName = UnitClass("player")

    local record = ns.db.characters[charKey] or {}
    record.name            = name
    record.realm           = realm
    record.classFileName   = classFileName
    record.classDisplayName = classDisplayName
    record.currencies      = record.currencies or {}
    ns.db.characters[charKey] = record

    for _, currencyDef in ipairs(ns.TRACKED_CURRENCIES) do
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyDef.id)
        if info then
            record.currencies[currencyDef.id] = {
                amount      = info.quantity,
                maxQuantity = info.maxQuantity,
            }
        end
    end
end

-- ---------------------------------------------------------------------------
-- Event frame
-- ---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end

        -- Initialize SavedVariables with safe defaults
        NelxRatedCurrencyDB = NelxRatedCurrencyDB or {}
        local db = NelxRatedCurrencyDB
        db.characters    = db.characters    or {}
        db.settings      = db.settings      or {}
        db.schemaVersion = db.schemaVersion or 1

        -- Settings sub-table defaults
        db.settings.disableTooltip      = db.settings.disableTooltip      ~= nil and db.settings.disableTooltip or false
        db.settings.hiddenCharacters    = db.settings.hiddenCharacters    or {}
        db.settings.minimapPosition     = db.settings.minimapPosition     or {}

        ns.db = db

    elseif event == "PLAYER_ENTERING_WORLD" then
        CaptureCurrencies()

    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        CaptureCurrencies()
    end
end)

-- ---------------------------------------------------------------------------
-- Slash command — toggles overview panel (lazy-creates it on first use)
-- ---------------------------------------------------------------------------
SLASH_NELXRATEDCURRENCY1 = "/nrc"
SlashCmdList["NELXRATEDCURRENCY"] = function()
    ns.ToggleOverview()
end
