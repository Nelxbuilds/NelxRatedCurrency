-- SettingsUI.lua — Settings panel
local addonName, ns = ...

local ROW_HEIGHT = 28
local ROW_GAP    = 2
local charRows   = {}

-- ---------------------------------------------------------------------------
-- Character list refresh
-- ---------------------------------------------------------------------------
local function RefreshCharacterList(scrollChild)
    for _, row in ipairs(charRows) do
        row:Hide()
    end
    charRows = {}

    if not ns.db then return end

    local chars = {}
    for charKey, record in pairs(ns.db.characters) do
        chars[#chars + 1] = { key = charKey, record = record }
    end
    table.sort(chars, function(a, b)
        return (a.record.name or "") < (b.record.name or "")
    end)

    local totalHeight = math.max(#chars * (ROW_HEIGHT + ROW_GAP) - ROW_GAP, 1)
    scrollChild:SetHeight(totalHeight)

    for i, charData in ipairs(chars) do
        local record = charData.record
        local charKey = charData.key
        local y = -(i - 1) * (ROW_HEIGHT + ROW_GAP)

        local row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        if i % 2 == 0 then
            row:SetBackdropColor(0.12, 0.12, 0.12, 0.5)
        else
            row:SetBackdropColor(0.08, 0.08, 0.08, 0.5)
        end
        row:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.3)

        local nameStr = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameStr:SetPoint("LEFT", 8, 0)
        local classColor = RAID_CLASS_COLORS and record.classFileName
            and RAID_CLASS_COLORS[record.classFileName]
        if classColor then
            nameStr:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            nameStr:SetTextColor(1, 1, 1)
        end
        nameStr:SetText(charKey)

        local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        removeBtn:SetSize(60, 20)
        removeBtn:SetPoint("RIGHT", -6, 0)
        removeBtn:SetText("Remove")
        removeBtn:SetScript("OnClick", function()
            ns.db.characters[charKey] = nil
            ns.db.settings.hiddenCharacters[charKey] = nil
            RefreshCharacterList(scrollChild)
        end)

        row:Show()
        charRows[#charRows + 1] = row
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

    local sepY1 = -40 - #aboutLines * 16 - 14

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
