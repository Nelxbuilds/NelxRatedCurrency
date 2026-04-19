-- Tooltip.lua — Tooltip Extension (Epic 2)
local addonName, ns = ...

-- ---------------------------------------------------------------------------
-- Internal: append currency rows to the active GameTooltip
-- ---------------------------------------------------------------------------
local function AppendCurrencyRows(tooltip, currencyID)
    if not ns.db then return end
    if ns.db.settings.disableTooltip then return end

    local chars = ns.db.characters
    if not chars then return end

    -- Build sorted list of visible characters that have a non-zero amount
    local rows = {}
    for charKey, record in pairs(chars) do
        if not ns.db.settings.hiddenCharacters[charKey] then
            local currData = record.currencies and record.currencies[currencyID]
            if currData and currData.amount and currData.amount > 0 then
                rows[#rows + 1] = {
                    name          = record.name,
                    classFileName = record.classFileName,
                    amount        = currData.amount,
                }
            end
        end
    end

    if #rows == 0 then return end

    table.sort(rows, function(a, b) return a.name < b.name end)

    tooltip:AddLine(" ")
    tooltip:AddLine("NelxRatedCurrency", 1, 0.82, 0)

    for _, row in ipairs(rows) do
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[row.classFileName]
        local r, g, b = 1, 1, 1
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        end
        tooltip:AddDoubleLine(row.name, tostring(row.amount), r, g, b, 1, 1, 1)
    end
end

-- ---------------------------------------------------------------------------
-- Internal: append item count rows to the active GameTooltip
-- ---------------------------------------------------------------------------
local function AppendItemRows(tooltip, itemID)
    if not ns.db then return end
    if ns.db.settings.disableTooltip then return end

    local chars = ns.db.characters
    if not chars then return end

    local rows = {}
    for charKey, record in pairs(chars) do
        if not ns.db.settings.hiddenCharacters[charKey] then
            local itemData = record.items and record.items[itemID]
            if itemData and itemData.count and itemData.count > 0 then
                rows[#rows + 1] = {
                    name          = record.name,
                    classFileName = record.classFileName,
                    count         = itemData.count,
                }
            end
        end
    end

    if #rows == 0 then return end

    table.sort(rows, function(a, b) return a.name < b.name end)

    tooltip:AddLine(" ")
    tooltip:AddLine("NelxRatedCurrency", 1, 0.82, 0)

    for _, row in ipairs(rows) do
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[row.classFileName]
        local r, g, b = 1, 1, 1
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        end
        tooltip:AddDoubleLine(row.name, tostring(row.count), r, g, b, 1, 1, 1)
    end
end

-- ---------------------------------------------------------------------------
-- Hook 1: Currency tab icons (TooltipDataProcessor)
-- ---------------------------------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
    if not data or not data.id then return end
    for _, currencyDef in ipairs(ns.TRACKED_CURRENCIES) do
        if data.id == currencyDef.id then
            AppendCurrencyRows(tooltip, currencyDef.id)
            return
        end
    end
end)

-- ---------------------------------------------------------------------------
-- Hook 2: Bag items (TooltipDataProcessor — Item type)
-- ---------------------------------------------------------------------------
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if not ns.db then return end
    if ns.db.settings.disableTooltip then return end

    local itemID = data and data.id
    if not itemID then return end

    -- Check if this is a tracked item
    for _, itemDef in ipairs(ns.TRACKED_ITEMS) do
        if itemID == itemDef.id then
            AppendItemRows(tooltip, itemDef.id)
            return
        end
    end

    -- Check if this item is a currency container for any tracked currency
    local currencyID = C_CurrencyInfo.GetCurrencyContainerCurrencyID and
                       C_CurrencyInfo.GetCurrencyContainerCurrencyID(itemID)
    if not currencyID then return end

    for _, currencyDef in ipairs(ns.TRACKED_CURRENCIES) do
        if currencyID == currencyDef.id then
            AppendCurrencyRows(tooltip, currencyDef.id)
            return
        end
    end
end)
