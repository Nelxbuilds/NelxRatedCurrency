-- MainFrame.lua — Single main frame with sidebar navigation
local addonName, ns = ...

-- ============================================================================
-- Color palette & shared backdrop
-- ============================================================================

ns.COLORS = {
    BG_BASE     = { 0.06, 0.06, 0.06, 0.95 },
    BG_RAISED   = { 0.10, 0.10, 0.10, 0.95 },
    GOLD_BRIGHT = { 1.0, 0.82, 0.0 },
    GOLD_MID    = { 0.7, 0.57, 0.0 },
    GOLD_DIM    = { 0.35, 0.28, 0.0 },
    GOLD        = { 1.0, 0.82, 0.0 },
}

ns.NRC_BACKDROP = {
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 2,
}

-- ============================================================================
-- Main Frame & Sidebar Navigation
-- ============================================================================

local SIDEBAR_WIDTH = 140
local FRAME_W, FRAME_H = 660, 440

local mainFrame
local contentArea
local navButtons = {}
local tabPanels  = {}
local activeTab  = nil

local TAB_ORDER = { "Overview", "Settings" }

local function SelectTab(tabName)
    if activeTab == tabName then return end
    activeTab = tabName

    for name, btn in pairs(navButtons) do
        if name == tabName then
            btn:SetBackdropColor(0.15, 0.12, 0.0, 0.6)
            btn:SetBackdropBorderColor(0, 0, 0, 0)
            btn.label:SetTextColor(1, 1, 1)
            btn.nxrActive = true
            btn.accent:Show()
        else
            btn:SetBackdropColor(0, 0, 0, 0)
            btn:SetBackdropBorderColor(0, 0, 0, 0)
            btn.label:SetTextColor(0.6, 0.6, 0.6)
            btn.nxrActive = false
            btn.accent:Hide()
        end
    end

    for name, panel in pairs(tabPanels) do
        if name == tabName then
            panel:Show()
        else
            panel:Hide()
        end
    end
end

local function CreateSidebar(parent)
    local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", 2, -2)
    sidebar:SetPoint("BOTTOMLEFT", 2, 2)
    sidebar:SetBackdrop(ns.NRC_BACKDROP)
    sidebar:SetBackdropColor(unpack(ns.COLORS.BG_RAISED))
    sidebar:SetBackdropBorderColor(0, 0, 0, 0)

    -- Right edge separator
    local sep = sidebar:CreateTexture(nil, "BORDER")
    sep:SetWidth(1)
    sep:SetPoint("TOPRIGHT", 0, 0)
    sep:SetPoint("BOTTOMRIGHT", 0, 0)
    sep:SetColorTexture(unpack(ns.COLORS.GOLD_DIM))

    -- Title
    local title = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 14, -16)
    title:SetText("NelxRated")
    title:SetTextColor(unpack(ns.COLORS.GOLD))

    local subtitle = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 14, -34)
    subtitle:SetText("Currency")
    subtitle:SetTextColor(unpack(ns.COLORS.GOLD))

    -- Separator below title
    local titleSep = sidebar:CreateTexture(nil, "ARTWORK")
    titleSep:SetColorTexture(1, 0.82, 0, 0.35)
    titleSep:SetSize(SIDEBAR_WIDTH - 28, 1)
    titleSep:SetPoint("TOPLEFT", 14, -50)

    -- Nav buttons
    local TAB_HEIGHT = 44
    local TAB_GAP = 4
    local yOff = -60
    for _, tabName in ipairs(TAB_ORDER) do
        local btn = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        btn:SetHeight(TAB_HEIGHT)
        btn:SetPoint("TOPLEFT", 0, yOff)
        btn:SetPoint("RIGHT", sidebar, "RIGHT", -1, 0)
        btn:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 0,
        })
        btn:SetBackdropColor(0, 0, 0, 0)
        btn:SetBackdropBorderColor(0, 0, 0, 0)

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.label:SetPoint("LEFT", 14, 0)
        btn.label:SetText(tabName)
        btn.label:SetTextColor(0.6, 0.6, 0.6)

        -- Gold left accent bar
        btn.accent = btn:CreateTexture(nil, "OVERLAY")
        btn.accent:SetWidth(3)
        btn.accent:SetPoint("TOPLEFT", 0, 0)
        btn.accent:SetPoint("BOTTOMLEFT", 0, 0)
        btn.accent:SetColorTexture(unpack(ns.COLORS.GOLD_BRIGHT))
        btn.accent:Hide()

        btn:SetScript("OnEnter", function(self)
            if not self.nxrActive then
                self:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
                self.label:SetTextColor(0.85, 0.85, 0.85)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.nxrActive then
                self:SetBackdropColor(0, 0, 0, 0)
                self.label:SetTextColor(0.6, 0.6, 0.6)
            end
        end)

        btn:SetScript("OnClick", function() SelectTab(tabName) end)

        navButtons[tabName] = btn
        yOff = yOff - TAB_HEIGHT - TAB_GAP
    end

    return sidebar
end

local function CreateMainFrame()
    local f = CreateFrame("Frame", "NelxRatedCurrencyMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetBackdrop(ns.NRC_BACKDROP)
    f:SetBackdropColor(unpack(ns.COLORS.BG_BASE))
    f:SetBackdropBorderColor(unpack(ns.COLORS.GOLD_DIM))
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    tinsert(UISpecialFrames, "NelxRatedCurrencyMainFrame")

    -- Close button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    -- Sidebar
    CreateSidebar(f)

    -- Content area (right of sidebar)
    contentArea = CreateFrame("Frame", nil, f)
    contentArea:SetPoint("TOPLEFT", SIDEBAR_WIDTH + 16, -8)
    contentArea:SetPoint("BOTTOMRIGHT", -8, 8)

    -- Create tab panels
    for _, tabName in ipairs(TAB_ORDER) do
        local panel = CreateFrame("Frame", nil, contentArea)
        panel:SetAllPoints()
        panel:Hide()
        tabPanels[tabName] = panel
    end

    -- Embed panels
    if ns.CreateOverviewPanel then
        ns.CreateOverviewPanel(tabPanels["Overview"])
    end
    if ns.CreateSettingsPanel then
        ns.CreateSettingsPanel(tabPanels["Settings"])
    end

    -- Default to Overview tab
    SelectTab("Overview")

    mainFrame = f
end

-- ============================================================================
-- Public API
-- ============================================================================

function ns.ToggleOverview()
    if not mainFrame then
        CreateMainFrame()
        SelectTab("Overview")
        return
    end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        SelectTab("Overview")
        mainFrame:Show()
    end
end

function ns.ShowOverview()
    if not mainFrame then
        CreateMainFrame()
        SelectTab("Overview")
        return
    end
    SelectTab("Overview")
    mainFrame:Show()
end

function ns.ToggleSettings()
    if not mainFrame then
        CreateMainFrame()
        SelectTab("Settings")
        return
    end
    if mainFrame:IsShown() and activeTab == "Settings" then
        mainFrame:Hide()
    else
        SelectTab("Settings")
        mainFrame:Show()
    end
end

function ns.ShowSettings()
    if not mainFrame then
        CreateMainFrame()
        SelectTab("Settings")
        return
    end
    SelectTab("Settings")
    mainFrame:Show()
end
