-- OverviewUI.lua — Overview Panel (Epic 3)
local addonName, ns = ...

-- ---------------------------------------------------------------------------
-- Sort state
-- ---------------------------------------------------------------------------
local sortColumn    = "name"   -- "name" | currency id (number) | item id (number)
local sortAscending = true

-- ---------------------------------------------------------------------------
-- Column definitions
-- ---------------------------------------------------------------------------
local COLUMNS = {
    { key = "name",  label = "Character",  xOffset = 10,  type = "name"     },
    { key = 1792,    label = "Honor",      xOffset = 170, type = "currency"  },
    { key = 1602,    label = "Conquest",   xOffset = 255, type = "currency"  },
    { key = 137642,  label = "Mark",       xOffset = 340, type = "item"      },
    { key = 241334,  label = "Flask",      xOffset = 425, type = "item"      },
    { key = 258622,  label = "Medal",      xOffset = 510, type = "item"      },
}

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

    -- Find the type of the current sort column
    local sortType = "name"
    for _, col in ipairs(COLUMNS) do
        if col.key == sortColumn then
            sortType = col.type
            break
        end
    end

    table.sort(rows, function(a, b)
        local ra, rb = a.record, b.record
        local valA, valB

        if sortType == "name" then
            valA = ra.name or ""
            valB = rb.name or ""
            if sortAscending then return valA < valB else return valA > valB end
        elseif sortType == "currency" then
            local cdA = ra.currencies and ra.currencies[sortColumn]
            local cdB = rb.currencies and rb.currencies[sortColumn]
            valA = cdA and cdA.amount or nil
            valB = cdB and cdB.amount or nil
        elseif sortType == "item" then
            local idA = ra.items and ra.items[sortColumn]
            local idB = rb.items and rb.items[sortColumn]
            valA = idA and idA.count or nil
            valB = idB and idB.count or nil
        end

        if valA == nil and valB == nil then return false end
        if valA == nil then return false end
        if valB == nil then return true end
        if sortAscending then return valA < valB else return valA > valB end
    end)

    return rows
end

-- ---------------------------------------------------------------------------
-- Row pool (reusable font strings)
-- ---------------------------------------------------------------------------
local rowPool = {}
local headerButtons = {}

-- ---------------------------------------------------------------------------
-- Refresh the table contents
-- ---------------------------------------------------------------------------
local function RefreshTable(frame)
    for _, rowFrames in ipairs(rowPool) do
        for _, fs in ipairs(rowFrames) do
            fs:Hide()
        end
    end

    if not ns.db then return end

    local rows = BuildSortedRows()
    local rowHeight = 20
    local startY = -50

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

        for j, colDef in ipairs(COLUMNS) do
            local fs = rowPool[i][j]
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", frame, "TOPLEFT", colDef.xOffset, y)

            if colDef.type == "name" then
                local classColor = RAID_CLASS_COLORS and record.classFileName and RAID_CLASS_COLORS[record.classFileName]
                if classColor then
                    fs:SetTextColor(classColor.r, classColor.g, classColor.b)
                else
                    fs:SetTextColor(1, 1, 1)
                end
                fs:SetText(record.name or "Unknown")
            elseif colDef.type == "currency" then
                fs:SetTextColor(1, 1, 1)
                local cd = record.currencies and record.currencies[colDef.key]
                fs:SetText(cd and tostring(cd.amount) or "—")
            elseif colDef.type == "item" then
                fs:SetTextColor(1, 1, 1)
                local id = record.items and record.items[colDef.key]
                fs:SetText(id and tostring(id.count) or "—")
            end

            fs:Show()
        end
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
    frame:SetSize(650, 350)
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

        btn:SetScript("OnEnter", function() label:SetTextColor(1, 1, 0.6) end)
        btn:SetScript("OnLeave", function() label:SetTextColor(1, 0.9, 0.4) end)
    end

    -- Separator line under headers
    local sep = frame:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(1, 0.82, 0, 1)
    sep:SetSize(620, 1)
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
