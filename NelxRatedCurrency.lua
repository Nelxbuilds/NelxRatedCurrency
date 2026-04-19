local AddonName, ns = ...

-- Saved variables initialised on ADDON_LOADED
local defaults = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == AddonName then
        NelxRatedCurrencyDB = NelxRatedCurrencyDB or CopyTable(defaults)
        ns.db = NelxRatedCurrencyDB
    elseif event == "PLAYER_LOGIN" then
        -- Addon is fully loaded; other addons are available
    end
end)
