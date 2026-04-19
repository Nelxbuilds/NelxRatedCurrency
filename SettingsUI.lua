-- SettingsUI.lua
local addonName, ns = ...

local settingsFrame
local charCheckboxes = {}

-- ---------------------------------------------------------------------------
-- Character list refresh
-- ---------------------------------------------------------------------------
local function RefreshCharacterList(scrollChild)
    for _, cb in ipairs(charCheckboxes) do
        cb:Hide()
        if cb.label then cb.label:Hide() end
    end
    charCheckboxes = {}

    if not ns.db then return end

    local chars = {}
    for charKey, record in pairs(ns.db.characters) do
        chars[#chars + 1] = { key = charKey, record = record }
    end
    table.sort(chars, function(a, b)
        return (a.record.name or "") < (b.record.name or "")
    end)

    local rowHeight   = 24
    local totalHeight = math.max(#chars * rowHeight, 1)
    scrollChild:SetHeight(totalHeight)

    for i, charData in ipairs(chars) do
        local record = charData.record
        local charKey = charData.key
        local y = -(i - 1) * rowHeight

        local cb = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
        cb:SetChecked(not ns.db.settings.hiddenCharacters[charKey])

        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                ns.db.settings.hiddenCharacters[charKey] = nil
            else
                ns.db.settings.hiddenCharacters[charKey] = true
            end
        end)

        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)

        local classColor = RAID_CLASS_COLORS and record.classFileName and RAID_CLASS_COLORS[record.classFileName]
        if classColor then
            label:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            label:SetTextColor(1, 1, 1)
        end
        label:SetText(record.name or charKey)
        label:Show()

        cb:Show()
        cb.label = label
        charCheckboxes[#charCheckboxes + 1] = cb
    end
end

-- ---------------------------------------------------------------------------
-- Lazy frame creation
-- ---------------------------------------------------------------------------
local function CreateSettingsFrame()
    local SIDEBAR_W = 128
    local FRAME_W   = 420
    local FRAME_H   = 460

    local frame = CreateFrame("Frame", "NelxRatedCurrencySettingsFrame", UIParent)
    frame:SetSize(FRAME_W, FRAME_H)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("MEDIUM")

    Mixin(frame, BackdropTemplateMixin)
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.05, 0.04, 0, 0.92)
    frame:SetBackdropBorderColor(1, 0.82, 0, 1)

    -- -----------------------------------------------------------------------
    -- Sidebar
    -- -----------------------------------------------------------------------
    local sidebarBg = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    sidebarBg:SetColorTexture(0.03, 0.025, 0, 1)
    sidebarBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    sidebarBg:SetSize(SIDEBAR_W - 1, FRAME_H - 2)

    local sidebarDivider = frame:CreateTexture(nil, "ARTWORK")
    sidebarDivider:SetColorTexture(1, 0.82, 0, 1)
    sidebarDivider:SetSize(1, FRAME_H - 2)
    sidebarDivider:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_W, -1)

    -- Sidebar title
    local sideTitle1 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sideTitle1:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -12)
    sideTitle1:SetTextColor(1, 0.82, 0)
    sideTitle1:SetText("NelxRated")

    local sideTitle2 = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sideTitle2:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    sideTitle2:SetTextColor(1, 0.82, 0)
    sideTitle2:SetText("Currency")

    local sideTitleSep = frame:CreateTexture(nil, "ARTWORK")
    sideTitleSep:SetColorTexture(1, 0.82, 0, 0.35)
    sideTitleSep:SetSize(SIDEBAR_W - 20, 1)
    sideTitleSep:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -46)

    -- "Overview" nav item — clickable
    local overviewNavBtn = CreateFrame("Button", nil, frame)
    overviewNavBtn:SetSize(SIDEBAR_W - 2, 22)
    overviewNavBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -54)

    local overviewNavLabel = overviewNavBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    overviewNavLabel:SetPoint("LEFT", overviewNavBtn, "LEFT", 11, 0)
    overviewNavLabel:SetTextColor(0.75, 0.65, 0.3)
    overviewNavLabel:SetText("Overview")

    overviewNavBtn:SetScript("OnEnter", function() overviewNavLabel:SetTextColor(1, 1, 0.6) end)
    overviewNavBtn:SetScript("OnLeave", function() overviewNavLabel:SetTextColor(0.75, 0.65, 0.3) end)
    overviewNavBtn:SetScript("OnClick", function()
        frame:Hide()
        ns.ShowOverview()
    end)

    -- "Settings" nav item — active / highlighted
    local settingsHighlight = frame:CreateTexture(nil, "BACKGROUND")
    settingsHighlight:SetColorTexture(1, 0.82, 0, 0.12)
    settingsHighlight:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -78)
    settingsHighlight:SetSize(SIDEBAR_W - 1, 22)

    local settingsNavText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsNavText:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -82)
    settingsNavText:SetTextColor(1, 0.9, 0.4)
    settingsNavText:SetText("Settings")

    -- -----------------------------------------------------------------------
    -- Close button
    -- -----------------------------------------------------------------------
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

    local closeTex = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeTex:SetAllPoints()
    closeTex:SetJustifyH("CENTER")
    closeTex:SetJustifyV("MIDDLE")
    closeTex:SetText("X")
    closeTex:SetTextColor(0.75, 0.2, 0.2)

    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    closeBtn:SetScript("OnEnter", function() closeTex:SetTextColor(1, 0.1, 0.1) end)
    closeBtn:SetScript("OnLeave", function() closeTex:SetTextColor(0.75, 0.2, 0.2) end)

    -- -----------------------------------------------------------------------
    -- Main content area
    -- -----------------------------------------------------------------------
    local CONTENT_X = SIDEBAR_W + 10
    local CONTENT_W = FRAME_W - SIDEBAR_W - 18

    local mainTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, -12)
    mainTitle:SetTextColor(1, 0.9, 0.4)
    mainTitle:SetText("Settings")

    local mainTitleSep = frame:CreateTexture(nil, "ARTWORK")
    mainTitleSep:SetColorTexture(1, 0.82, 0, 1)
    mainTitleSep:SetSize(CONTENT_W, 1)
    mainTitleSep:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_W + 8, -33)

    -- -----------------------------------------------------------------------
    -- About section
    -- -----------------------------------------------------------------------
    local aboutHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aboutHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, -42)
    aboutHeader:SetTextColor(1, 0.9, 0.4)
    aboutHeader:SetText("About")

    local version    = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"
    local aboutLines = {
        "NelxRatedCurrency  v" .. version,
        "Author: Nelxbuilds",
        "Track PvP currencies across characters.",
    }

    for i, line in ipairs(aboutLines) do
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, -42 - i * 16)
        fs:SetTextColor(0.75, 0.65, 0.3)
        fs:SetText(line)
    end

    local sepY1 = -42 - #aboutLines * 16 - 8

    local sep1 = frame:CreateTexture(nil, "ARTWORK")
    sep1:SetColorTexture(1, 0.82, 0, 0.35)
    sep1:SetSize(CONTENT_W, 1)
    sep1:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_W + 8, sepY1)

    -- -----------------------------------------------------------------------
    -- Characters section
    -- -----------------------------------------------------------------------
    local charSectionY = sepY1 - 14

    local charHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    charHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, charSectionY)
    charHeader:SetTextColor(1, 0.9, 0.4)
    charHeader:SetText("Characters")

    local CHAR_LIST_H  = 8 * 24
    local scrollFrame  = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(CONTENT_W - 20, CHAR_LIST_H)
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, charSectionY - 18)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(CONTENT_W - 40, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local sepY2 = charSectionY - 18 - CHAR_LIST_H - 8

    local sep2 = frame:CreateTexture(nil, "ARTWORK")
    sep2:SetColorTexture(1, 0.82, 0, 0.35)
    sep2:SetSize(CONTENT_W, 1)
    sep2:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_W + 8, sepY2)

    -- -----------------------------------------------------------------------
    -- Settings section
    -- -----------------------------------------------------------------------
    local settingsSectionY = sepY2 - 14

    local settingsHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, settingsSectionY)
    settingsHeader:SetTextColor(1, 0.9, 0.4)
    settingsHeader:SetText("Options")

    local tooltipCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    tooltipCB:SetSize(20, 20)
    tooltipCB:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_X, settingsSectionY - 18)

    local tooltipLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tooltipLabel:SetPoint("LEFT", tooltipCB, "RIGHT", 4, 0)
    tooltipLabel:SetTextColor(0.88, 0.88, 0.88)
    tooltipLabel:SetText("Disable tooltip extension")

    tooltipCB:SetScript("OnClick", function(self)
        if ns.db then
            ns.db.settings.disableTooltip = self:GetChecked() and true or false
        end
    end)

    -- -----------------------------------------------------------------------
    -- OnShow: sync dynamic content
    -- -----------------------------------------------------------------------
    frame:SetScript("OnShow", function(self)
        RefreshCharacterList(scrollChild)
        if ns.db then
            tooltipCB:SetChecked(ns.db.settings.disableTooltip == true)
        end
    end)

    -- ESC closes
    tinsert(UISpecialFrames, "NelxRatedCurrencySettingsFrame")

    return frame
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------
function ns.ToggleSettings()
    if not settingsFrame then
        settingsFrame = CreateSettingsFrame()
    end
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
    end
end

function ns.ShowSettings()
    if not settingsFrame then
        settingsFrame = CreateSettingsFrame()
    end
    settingsFrame:Show()
end
