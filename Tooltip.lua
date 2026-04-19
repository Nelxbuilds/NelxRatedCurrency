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
                    name         = record.name,
                    classFileName = record.classFileName,
                    amount       = currData.amount,
                    maxQuantity  = currData.maxQuantity or 0,
                }
            end
        end
    end

    if #rows == 0 then return end

    -- Sort A-Z by name
    table.sort(rows, function(a, b) return a.name < b.name end)

    -- Blank separator + header
    tooltip:AddLine(" ")
    tooltip:AddLine("NelxRatedCurrency", 1, 0.82, 0)

    for _, row in ipairs(rows) do
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[row.classFileName]
        local r, g, b = 1, 1, 1
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        end

        local amountText
        if currencyID == 1602 then
            -- Conquest: show amount / maxQuantity
            amountText = row.amount .. " / " .. row.maxQuantity
        else
            -- Honor: show amount only
            amountText = tostring(row.amount)
        end

        tooltip:AddDoubleLine(row.name, amountText, r, g, b, 1, 1, 1)
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
-- Hook 2: Bag items (OnTooltipSetItem)
-- ---------------------------------------------------------------------------
GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    if not ns.db then return end
    if ns.db.settings.disableTooltip then return end

    local _, link = tooltip:GetItem()
    if not link then return end

    -- Try to extract a currency container currency ID from the item link
    -- Currency containers use item links; we check via C_CurrencyInfo
    local itemID = GetItemInfoInstant and select(1, GetItemInfoInstant(link))
    if not itemID then return end

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
