-- OverviewUI.lua — Overview Panel (Epic 3)
local addonName, ns = ...

-- ---------------------------------------------------------------------------
-- Sort state
-- ---------------------------------------------------------------------------
local sortColumn    = "name"   -- "name" | currency id (number)
local sortAscending = true

-- ---------------------------------------------------------------------------
-- Build a sorted list of character rows for display
-- ---------------------------------------------------------------------------
local function BuildSortedRows()
    local rows = {}
    for charKey, record in pairs(ns.db.characters) do
        if not ns.db.settings.hiddenCharacters[charKey] then
            rows[#rows + 1] = { key = charKey, record = record }
        end
    end

    table.sort(rows, function(a, b)
        local ra, rb = a.record, b.record
        local valA, valB

        if sortColumn == "name" then
            valA = ra.name or ""
            valB = rb.name or ""
            if sortAscending then
                return valA < valB
            else
                return valA > valB
            end
        else
            -- currency column: sort by amount, missing data ranks last
            local cdA = ra.currencies and ra.currencies[sortColumn]
            local cdB = rb.currencies and rb.currencies[sortColumn]
            valA = cdA and cdA.amount or nil
            valB = cdB and cdB.amount or nil

            if valA == nil and valB == nil then return false end
            if valA == nil then return false end
            if valB == nil then return true end

            if sortAscending then
                return valA < valB
            else
                return valA > valB
            end
        end
    end)

    return rows
end

-- ---------------------------------------------------------------------------
-- Column header labels with sort indicators
-- ---------------------------------------------------------------------------
local COLUMNS = {
    { key = "name", label = "Character", xOffset = 10 },
    { key = 1792,   label = "Honor",     xOffset = 230 },
    { key = 1602,   label = "Conquest",  xOffset = 340 },
}

-- ---------------------------------------------------------------------------
-- Row pool (reusable font strings)
-- ---------------------------------------------------------------------------
local rowPool = {}
local headerButtons = {}

-- ---------------------------------------------------------------------------
-- Refresh the table contents
-- ---------------------------------------------------------------------------
local function RefreshTable(frame)
    -- Hide all pooled rows
    for _, rowFrames in ipairs(rowPool) do
        for _, fs in ipairs(rowFrames) do
            fs:Hide()
        end
    end

    if not ns.db then return end

    local rows = BuildSortedRows()
    local rowHeight = 20
    local startY = -50  -- below header row

    for i, rowData in ipairs(rows) do
        local record = rowData.record
        if not rowPool[i] then
            rowPool[i] = {}
            for j = 1, #COLUMNS do
                local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                rowPool[i][j] = fs
            end
        end

        local y = startY - (i - 1) * rowHeight

        -- Character name column (class color)
        local nameFS = rowPool[i][1]
        local classColor = RAID_CLASS_COLORS and record.classFileName and RAID_CLASS_COLORS[record.classFileName]
        if classColor then
            nameFS:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            nameFS:SetTextColor(1, 1, 1)
        end
        nameFS:ClearAllPoints()
        nameFS:SetPoint("TOPLEFT", frame, "TOPLEFT", COLUMNS[1].xOffset, y)
        nameFS:SetText(record.name or "Unknown")
        nameFS:Show()

        -- Honor column
        local honorFS = rowPool[i][2]
        honorFS:SetTextColor(1, 1, 1)
        honorFS:ClearAllPoints()
        honorFS:SetPoint("TOPLEFT", frame, "TOPLEFT", COLUMNS[2].xOffset, y)
        local honorData = record.currencies and record.currencies[1792]
        if honorData then
            honorFS:SetText(tostring(honorData.amount))
        else
            honorFS:SetText("—")
        end
        honorFS:Show()

        -- Conquest column
        local conquestFS = rowPool[i][3]
        conquestFS:SetTextColor(1, 1, 1)
        conquestFS:ClearAllPoints()
        conquestFS:SetPoint("TOPLEFT", frame, "TOPLEFT", COLUMNS[3].xOffset, y)
        local conquestData = record.currencies and record.currencies[1602]
        if conquestData then
            conquestFS:SetText(conquestData.amount .. " / " .. conquestData.maxQuantity)
        else
            conquestFS:SetText("—")
        end
        conquestFS:Show()
    end

    -- Update column header labels with sort indicators
    for _, colDef in ipairs(COLUMNS) do
        local btn = headerButtons[colDef.key]
        if btn then
            local indicator = ""
            if sortColumn == colDef.key then
                indicator = sortAscending and " ▲" or " ▼"
            end
            btn:SetText(colDef.label .. indicator)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Lazy frame creation
-- ---------------------------------------------------------------------------
local overviewFrame

local function CreateOverviewFrame()
    local frame = CreateFrame("Frame", "NelxRatedCurrencyFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 350)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Title
    frame.TitleText:SetText("NelxRatedCurrency")
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
    tinsert(UISpecialFrames, "NelxRatedCurrencyFrame")

    -- Column headers (clickable buttons for sorting)
    for _, colDef in ipairs(COLUMNS) do
        local btn = CreateFrame("Button", nil, frame)
        btn:SetSize(110, 20)
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", colDef.xOffset, -28)

        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetAllPoints()
        label:SetJustifyH("LEFT")
        label:SetTextColor(1, 0.9, 0.4)
        btn.SetText = function(self, text) label:SetText(text) end
        btn:SetText(colDef.label)

        headerButtons[colDef.key] = btn

        local colKey = colDef.key
        btn:SetScript("OnClick", function()
            if sortColumn == colKey then
                sortAscending = not sortAscending
            else
                sortColumn    = colKey
                sortAscending = true
            end
            RefreshTable(frame)
        end)

        -- Highlight on hover
        btn:SetScript("OnEnter", function() label:SetTextColor(1, 1, 0.6) end)
        btn:SetScript("OnLeave", function() label:SetTextColor(1, 0.9, 0.4) end)
    end

    -- Separator line under headers
    local sep = frame:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(1, 0.82, 0, 1)
    sep:SetSize(470, 1)
    sep:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -48)

    frame:SetScript("OnShow", function(self)
        RefreshTable(self)
    end)

    return frame
end

-- ---------------------------------------------------------------------------
-- Public: toggle overview
-- ---------------------------------------------------------------------------
function ns.ToggleOverview()
    if not overviewFrame then
        overviewFrame = CreateOverviewFrame()
    end

    if overviewFrame:IsShown() then
        overviewFrame:Hide()
    else
        RefreshTable(overviewFrame)
        overviewFrame:Show()
    end
end

-- ---------------------------------------------------------------------------
-- Public: open overview (used by minimap button)
-- ---------------------------------------------------------------------------
function ns.ShowOverview()
    if not overviewFrame then
        overviewFrame = CreateOverviewFrame()
    end
    RefreshTable(overviewFrame)
    overviewFrame:Show()
end
