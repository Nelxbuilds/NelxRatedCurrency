-- SettingsUI.lua — Settings Panel (Epic 5)
local addonName, ns = ...

local settingsFrame

-- ---------------------------------------------------------------------------
-- Separator line helper
-- ---------------------------------------------------------------------------
local function AddSeparator(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 0.82, 0, 1)
    line:SetSize(340, 1)
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    return line
end

-- ---------------------------------------------------------------------------
-- Section header helper
-- ---------------------------------------------------------------------------
local function AddSectionHeader(parent, text, yOffset)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    fs:SetTextColor(1, 0.9, 0.4)
    fs:SetText(text)
    return fs
end

-- ---------------------------------------------------------------------------
-- Lazy frame creation
-- ---------------------------------------------------------------------------
local charCheckboxes = {}

local function RefreshCharacterList(scrollChild, contentFrame)
    -- Hide existing checkboxes
    for _, cb in ipairs(charCheckboxes) do
        cb:Hide()
        if cb.label then cb.label:Hide() end
    end
    charCheckboxes = {}

    if not ns.db then return end

    -- Build sorted list of characters
    local chars = {}
    for charKey, record in pairs(ns.db.characters) do
        chars[#chars + 1] = { key = charKey, record = record }
    end
    table.sort(chars, function(a, b)
        return (a.record.name or "") < (b.record.name or "")
    end)

    local rowHeight = 24
    local totalHeight = math.max(#chars * rowHeight, 1)
    scrollChild:SetHeight(totalHeight)

    for i, charData in ipairs(chars) do
        local record = charData.record
        local charKey = charData.key
        local y = -(i - 1) * rowHeight

        local cb = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)

        -- Checked = visible (not hidden); unchecked = hidden
        cb:SetChecked(not ns.db.settings.hiddenCharacters[charKey])

        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                ns.db.settings.hiddenCharacters[charKey] = nil
            else
                ns.db.settings.hiddenCharacters[charKey] = true
            end
        end)

        -- Character name label with class color
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

local function CreateSettingsFrame()
    local frame = CreateFrame("Frame", "NelxRatedCurrencySettingsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(380, 460)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Title
    frame.TitleText:SetText("NelxRatedCurrency — Settings")
    frame.TitleText:SetTextColor(1, 0.9, 0.4)

    -- Background
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.05, 0.04, 0, 0.85)
    frame:SetBackdropBorderColor(1, 0.82, 0, 1)

    -- ESC closes
    tinsert(UISpecialFrames, "NelxRatedCurrencySettingsFrame")

    -- -----------------------------------------------------------------------
    -- ABOUT section
    -- -----------------------------------------------------------------------
    AddSectionHeader(frame, "About", -30)

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

    local aboutLines = {
        "NelxRatedCurrency",
        "Version: " .. version,
        "Author: Nelxbuilds",
        "Track PvP currencies per character.",
    }
    for i, line in ipairs(aboutLines) do
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -30 - i * 16)
        fs:SetTextColor(0.75, 0.65, 0.3)
        fs:SetText(line)
    end

    -- separator after About
    local sepY1 = -30 - (#aboutLines * 16) - 8
    AddSeparator(frame, sepY1)

    -- -----------------------------------------------------------------------
    -- CHARACTERS section
    -- -----------------------------------------------------------------------
    local charSectionY = sepY1 - 14
    AddSectionHeader(frame, "Characters", charSectionY)

    -- Scroll frame for character list (scrollable if >8 chars)
    local scrollFrameHeight = 8 * 24  -- 8 rows visible
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(330, scrollFrameHeight)
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, charSectionY - 18)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(310, 1)  -- height set dynamically
    scrollFrame:SetScrollChild(scrollChild)

    -- separator after Characters section
    local sepY2 = charSectionY - 18 - scrollFrameHeight - 8
    AddSeparator(frame, sepY2)

    -- -----------------------------------------------------------------------
    -- SETTINGS section
    -- -----------------------------------------------------------------------
    local settingsSectionY = sepY2 - 14
    AddSectionHeader(frame, "Settings", settingsSectionY)

    local tooltipCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    tooltipCB:SetSize(20, 20)
    tooltipCB:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, settingsSectionY - 18)

    local tooltipLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tooltipLabel:SetPoint("LEFT", tooltipCB, "RIGHT", 4, 0)
    tooltipLabel:SetTextColor(1, 1, 1)
    tooltipLabel:SetText("Disable tooltip extension")

    tooltipCB:SetScript("OnClick", function(self)
        if ns.db then
            ns.db.settings.disableTooltip = self:GetChecked() and true or false
        end
    end)

    -- -----------------------------------------------------------------------
    -- OnShow: refresh dynamic content
    -- -----------------------------------------------------------------------
    frame:SetScript("OnShow", function(self)
        -- Refresh character list
        RefreshCharacterList(scrollFrame, scrollChild)

        -- Sync tooltip checkbox
        if ns.db then
            tooltipCB:SetChecked(ns.db.settings.disableTooltip == true)
        end
    end)

    return frame
end

-- ---------------------------------------------------------------------------
-- Public: toggle settings frame
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

-- ---------------------------------------------------------------------------
-- Public: open settings frame
-- ---------------------------------------------------------------------------
function ns.ShowSettings()
    if not settingsFrame then
        settingsFrame = CreateSettingsFrame()
    end
    settingsFrame:Show()
end
