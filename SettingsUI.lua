-- SettingsUI.lua — Settings panel
local addonName, ns = ...

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

        local classColor = RAID_CLASS_COLORS and record.classFileName
            and RAID_CLASS_COLORS[record.classFileName]
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
-- Panel creation (called from MainFrame.lua)
-- ---------------------------------------------------------------------------
function ns.CreateSettingsPanel(parent)
    local CONTENT_W = 480

    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -8)
    title:SetTextColor(unpack(ns.COLORS.GOLD))
    title:SetText("Settings")

    local titleSep = parent:CreateTexture(nil, "ARTWORK")
    titleSep:SetColorTexture(1, 0.82, 0, 1)
    titleSep:SetHeight(1)
    titleSep:SetPoint("TOPLEFT", 4, -30)
    titleSep:SetPoint("RIGHT", parent, "RIGHT", -4, 0)

    -- -----------------------------------------------------------------------
    -- About section
    -- -----------------------------------------------------------------------
    local aboutHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aboutHeader:SetPoint("TOPLEFT", 8, -40)
    aboutHeader:SetTextColor(unpack(ns.COLORS.GOLD))
    aboutHeader:SetText("About")

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"
    local aboutLines = {
        "NelxRatedCurrency  v" .. version,
        "Author: Nelxbuilds",
        "Track PvP currencies across characters.",
    }

    for i, line in ipairs(aboutLines) do
        local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", 8, -40 - i * 16)
        fs:SetTextColor(0.6, 0.6, 0.6)
        fs:SetText(line)
    end

    local sepY1 = -40 - #aboutLines * 16 - 8

    local sep1 = parent:CreateTexture(nil, "ARTWORK")
    sep1:SetColorTexture(1, 0.82, 0, 0.35)
    sep1:SetHeight(1)
    sep1:SetPoint("TOPLEFT", 4, sepY1)
    sep1:SetPoint("RIGHT", parent, "RIGHT", -4, 0)

    -- -----------------------------------------------------------------------
    -- Characters section
    -- -----------------------------------------------------------------------
    local charSectionY = sepY1 - 14

    local charHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    charHeader:SetPoint("TOPLEFT", 8, charSectionY)
    charHeader:SetTextColor(unpack(ns.COLORS.GOLD))
    charHeader:SetText("Characters")

    local CHAR_LIST_H = 8 * 24

    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    scrollFrame:SetHeight(CHAR_LIST_H)
    scrollFrame:SetPoint("TOPLEFT", 8, charSectionY - 18)
    scrollFrame:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(cur - delta * 40, max)))
    end)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetHeight(1)
    scrollFrame:SetScript("OnSizeChanged", function(self, w)
        scrollChild:SetWidth(w)
    end)

    local sepY2 = charSectionY - 18 - CHAR_LIST_H - 8

    local sep2 = parent:CreateTexture(nil, "ARTWORK")
    sep2:SetColorTexture(1, 0.82, 0, 0.35)
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", 4, sepY2)
    sep2:SetPoint("RIGHT", parent, "RIGHT", -4, 0)

    -- -----------------------------------------------------------------------
    -- Options section
    -- -----------------------------------------------------------------------
    local optionsSectionY = sepY2 - 14

    local optionsHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionsHeader:SetPoint("TOPLEFT", 8, optionsSectionY)
    optionsHeader:SetTextColor(unpack(ns.COLORS.GOLD))
    optionsHeader:SetText("Options")

    local tooltipCB = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    tooltipCB:SetSize(20, 20)
    tooltipCB:SetPoint("TOPLEFT", 8, optionsSectionY - 18)

    local tooltipLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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
    parent:SetScript("OnShow", function()
        RefreshCharacterList(scrollChild)
        if ns.db then
            tooltipCB:SetChecked(ns.db.settings.disableTooltip == true)
        end
    end)
end
