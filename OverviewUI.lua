-- OverviewUI.lua — Overview panel (currency table)
local addonName, ns = ...

-- ---------------------------------------------------------------------------
-- Sort state
-- ---------------------------------------------------------------------------
local sortColumn    = "name"
local sortAscending = true

-- ---------------------------------------------------------------------------
-- Column definitions
-- ---------------------------------------------------------------------------
local COLUMNS = {
    { key = "name",  label = "Character",  xOffset = 8,   type = "name"     },
    { key = 1792,    label = "Honor",      xOffset = 150,  type = "currency" },
    { key = 1602,    label = "Conquest",   xOffset = 230,  type = "currency" },
    { key = 137642,  label = "Mark",       xOffset = 310,  type = "item"     },
    { key = 241334,  label = "Flask",      xOffset = 380,  type = "item"     },
    { key = 258622,  label = "Medal",      xOffset = 440,  type = "item"     },
}

local ROW_HEIGHT = 28
local ROW_GAP    = 2

-- ---------------------------------------------------------------------------
-- Build a sorted list of character rows for display
-- ---------------------------------------------------------------------------
local function BuildSortedRows()
    local rows = {}
    if not ns.db then return rows end
    for charKey, record in pairs(ns.db.characters) do
        if not ns.db.settings.hiddenCharacters[charKey] then
            rows[#rows + 1] = { key = charKey, record = record }
        end
    end

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
-- Row pool & header tracking
-- ---------------------------------------------------------------------------
local rowPool = {}
local headerButtons = {}
local scrollChild

-- ---------------------------------------------------------------------------
-- Refresh the table contents
-- ---------------------------------------------------------------------------
local function RefreshTable()
    for _, row in ipairs(rowPool) do
        row:Hide()
    end

    if not ns.db then return end

    local rows = BuildSortedRows()
    local yOff = 0

    for i, rowData in ipairs(rows) do
        local record = rowData.record

        if not rowPool[i] then
            local row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
            row:SetHeight(ROW_HEIGHT)
            row:SetBackdrop({
                bgFile   = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })

            row.cells = {}
            for j = 1, #COLUMNS do
                local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.cells[j] = fs
            end

            rowPool[i] = row
        end

        local row = rowPool[i]
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -yOff)
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

        -- Alternating row colors
        if i % 2 == 0 then
            row:SetBackdropColor(0.12, 0.12, 0.12, 0.5)
        else
            row:SetBackdropColor(0.08, 0.08, 0.08, 0.5)
        end
        row:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.3)

        for j, colDef in ipairs(COLUMNS) do
            local fs = row.cells[j]
            fs:ClearAllPoints()
            fs:SetPoint("LEFT", row, "LEFT", colDef.xOffset, 0)

            if colDef.type == "name" then
                local classColor = RAID_CLASS_COLORS and record.classFileName
                    and RAID_CLASS_COLORS[record.classFileName]
                if classColor then
                    fs:SetTextColor(classColor.r, classColor.g, classColor.b)
                else
                    fs:SetTextColor(0.8, 0.8, 0.8)
                end
                fs:SetText(record.name or "Unknown")
            elseif colDef.type == "currency" then
                fs:SetTextColor(1, 1, 1)
                local cd = record.currencies and record.currencies[colDef.key]
                fs:SetText(cd and tostring(cd.amount) or "\226\128\148")
            elseif colDef.type == "item" then
                fs:SetTextColor(1, 1, 1)
                local id = record.items and record.items[colDef.key]
                fs:SetText(id and tostring(id.count) or "\226\128\148")
            end

            fs:Show()
        end

        row:Show()
        yOff = yOff + ROW_HEIGHT + ROW_GAP
    end

    -- Hide excess rows
    for j = #rows + 1, #rowPool do
        rowPool[j]:Hide()
    end

    scrollChild:SetHeight(math.max(yOff, 1))

    -- Update header sort indicators
    for _, colDef in ipairs(COLUMNS) do
        local btn = headerButtons[colDef.key]
        if btn then
            btn.label:SetText(colDef.label)
            if sortColumn == colDef.key then
                if sortAscending then
                    btn.arrow:SetTexture("Interface\\Buttons\\Arrow-Up-Up")
                else
                    btn.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
                end
                btn.arrow:Show()
            else
                btn.arrow:Hide()
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Panel creation (called from MainFrame.lua)
-- ---------------------------------------------------------------------------
function ns.CreateOverviewPanel(parent)
    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 8, -8)
    title:SetText("Overview")
    title:SetTextColor(unpack(ns.COLORS.GOLD))

    -- Column headers
    local headerY = -36
    for _, colDef in ipairs(COLUMNS) do
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(70, 20)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", colDef.xOffset, headerY)

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.label:SetPoint("LEFT")
        btn.label:SetJustifyH("LEFT")
        btn.label:SetTextColor(1, 0.82, 0)
        btn.label:SetText(colDef.label)

        btn.arrow = btn:CreateTexture(nil, "OVERLAY")
        btn.arrow:SetSize(10, 10)
        btn.arrow:SetPoint("LEFT", btn.label, "RIGHT", 2, 0)
        btn.arrow:SetVertexColor(1, 0.82, 0)
        btn.arrow:Hide()

        headerButtons[colDef.key] = btn

        local colKey = colDef.key
        btn:SetScript("OnClick", function()
            if sortColumn == colKey then
                sortAscending = not sortAscending
            else
                sortColumn    = colKey
                sortAscending = true
            end
            RefreshTable()
        end)

        btn:SetScript("OnEnter", function() btn.label:SetTextColor(1, 1, 0.6) end)
        btn:SetScript("OnLeave", function() btn.label:SetTextColor(1, 0.82, 0) end)
    end

    -- Separator under headers
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(1, 0.82, 0, 0.5)
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, headerY - 20)
    sep:SetPoint("RIGHT", parent, "RIGHT", -4, 0)

    -- Scroll area
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetPoint("TOPLEFT", 0, headerY - 24)
    scroll:SetPoint("BOTTOMRIGHT", 0, 4)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(cur - delta * 40, max)))
    end)

    scrollChild = CreateFrame("Frame", nil, scroll)
    scroll:SetScrollChild(scrollChild)
    scrollChild:SetHeight(1)
    scroll:SetScript("OnSizeChanged", function(self, w)
        scrollChild:SetWidth(w)
    end)

    -- Refresh on show
    parent:SetScript("OnShow", function() RefreshTable() end)
end
