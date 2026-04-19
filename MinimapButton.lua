-- MinimapButton.lua — Minimap Button (Epic 4)
local addonName, ns = ...

-- Register with LibDataBroker + LibDBIcon after PLAYER_LOGIN so ns.db is ready
local minimapFrame = CreateFrame("Frame")
minimapFrame:RegisterEvent("PLAYER_LOGIN")
minimapFrame:SetScript("OnEvent", function(self, event)
    if event ~= "PLAYER_LOGIN" then return end
    self:UnregisterEvent("PLAYER_LOGIN")

    if not ns.db then return end

    -- Ensure minimapPosition table exists (LibDBIcon writes into it)
    ns.db.settings.minimapPosition = ns.db.settings.minimapPosition or {}

    local LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
    local LDBIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)

    if not LDB or not LDBIcon then return end

    local dataObject = LDB:NewDataObject("NelxRatedCurrency", {
        type  = "launcher",
        icon  = "Interface\\Icons\\INV_Misc_Coin_01",
        label = "NelxRatedCurrency",

        OnClick = function(_, button)
            if button == "LeftButton" then
                ns.ToggleOverview()
            elseif button == "RightButton" then
                ns.ShowSettings()
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:SetText("NelxRatedCurrency", 1, 0.82, 0)
            tooltip:AddLine("Left-click: Toggle overview", 1, 1, 1)
            tooltip:AddLine("Right-click: Settings", 1, 1, 1)
            tooltip:Show()
        end,
    })

    LDBIcon:Register("NelxRatedCurrency", dataObject, ns.db.settings.minimapPosition)
end)
