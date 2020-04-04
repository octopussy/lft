--local name = UnitName("unit")
--print("Hello: " .. )

--SendChatMessage("sssss" .. name, )

local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

local LFT = LibStub("AceAddon-3.0"):NewAddon("LFT","AceConsole-3.0","AceEvent-3.0")
LFT.HBD = LibStub("HereBeDragons-2.0")

LFTDB = {}

Rows = {}

local trackerFrame
local actionFrame

local wayframe = CreateFrame("Button", "CrazyArrow", UIParent)
wayframe:SetHeight(42)
wayframe:SetWidth(56)
wayframe:EnableMouse(true)
wayframe:SetMovable(true)
wayframe:SetClampedToScreen(true)
wayframe:Show()

--wayframe:SetScript("OnDragStart", OnDragStart)
--wayframe:SetScript("OnDragStop", OnDragStop)
wayframe:RegisterForDrag("LeftButton")
wayframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
wayframe:RegisterEvent("ZONE_CHANGED")
wayframe:RegisterEvent("PLAYER_ENTERING_WORLD")
wayframe:SetScript("OnEvent", OnEvent)

wayframe.arrow = wayframe:CreateTexture(nil, "OVERLAY")
wayframe.arrow:SetTexture("Interface\\Addons\\TomTom\\Images\\Arrow")
wayframe.arrow:SetAllPoints()
wayframe.arrow:Show()

local function GetNearestItem()
    local nearestPoint = nil
    local nearestDist = 999999999.0
    for c, time in pairs(LFTDB) do
        if tonumber(c) ~= nil then
           -- print(c)
            local _, px, py = LFT:GetCurrentPlayerPosition()
            local x, y = LFT:DecodeLoc(c)
            local dist = math.sqrt((x - px) * (x - px) + (y - py) * (y - py))
            if dist < nearestDist then
                nearestDist = dist
                nearestPoint = c
            end
        end
    end

    return nearestPoint, nearestDist
end

local function OnUpdate_ActionFrame(self, elapsed)
    local nearestPoint, nearestDist = GetNearestItem()

    if nearestPoint then
        if nearestDist <= 0.0025 then
            local x, y = LFT:DecodeLoc(nearestPoint) 
            actionFrame.DebugText:SetFormattedText("%f, %f - %f", x, y, nearestDist)
            actionFrame.btnGather:SetEnabled(true)
        else
            actionFrame.DebugText:SetText("n/a")
            actionFrame.btnGather:SetEnabled(false)
        end
    end
end

local function SetRowData(pos)
    
end

local function UpdateBars()
    local visitedItems = {}
    for c, time in pairs(LFTDB) do
        if time > 0 then
            table.insert(visitedItems, {
                id = c,
                time = time
            })
            --visitedItems[c] = time
        end
    end

    table.sort(visitedItems, function(a, b)
        return a.time < b.time
    end)

    local rowIndex = 1
    for c, e in pairs(visitedItems) do

        local x, y = LFT:DecodeLoc(e.id)
        local coords = RoundCoords(x, y, 2)

       -- print(e.id .. ": " .. e.time)
        if rowIndex > #Rows then
            local rowHeight = 16
            local row = CreateFrame("Button", "LFT_Bar"..rowIndex, trackerFrame)
            row:SetPoint("TOPLEFT", trackerFrame, "TOPLEFT", 2, -32 - (rowHeight) * (rowIndex - 1))
	        row:SetHeight(rowHeight)
            row:SetWidth(trackerFrame:GetWidth() - 4)
            row.StatusBar = CreateFrame("StatusBar", nil, row)
            row.StatusBar:SetAllPoints(row)
            
            local BarTexture = SM:Fetch("statusbar", "BantoBar")
            row.StatusBar:SetStatusBarTexture(BarTexture)
            row.StatusBar:GetStatusBarTexture():SetHorizTile(false)
            row.StatusBar:GetStatusBarTexture():SetVertTile(false)
            row.StatusBar:SetStatusBarColor(5, .5, .5, 1)
            row.StatusBar:SetMinMaxValues(0, 100)
            row.StatusBar:SetValue(100)
            row.StatusBar:Show()

            row.LeftText = row.StatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.LeftText:SetPoint("LEFT", row.StatusBar, "LEFT", 2, 0)
            row.LeftText:SetJustifyH("LEFT")
            row.LeftText:SetText("Test")
            row.LeftText:SetTextColor(1, 1, 1, 1)
            row.LeftText:SetWordWrap(false)

            row.RightText = row.StatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.RightText:SetPoint("RIGHT", row.StatusBar, "RIGHT", -2, 0)
            row.RightText:SetJustifyH("RIGHT")
            row.RightText:SetText("0")
            row.RightText:SetTextColor(1, 1, 1, 1)

            row:EnableMouse(true)
            row:RegisterForClicks("LeftButtonDown")
            row:SetScript("OnClick", function(self, button)
                local editbox=ChatEdit_ChooseBoxForSend(DEFAULT_CHAT_FRAME);--  Get an editbox
                ChatEdit_ActivateChat(editbox);--   Show the editbox
                editbox:SetText("/way " .. coords);-- Command goes here
                ChatEdit_OnEnterPressed(editbox);-- Process command and hide (runs ChatEdit_SendText() and ChatEdit_DeactivateChat() respectively)
            end)
            
            table.insert(Rows, row)
        end

        local row = Rows[rowIndex]

        if not row:IsShown() then
            row:Show()
        end


        --print(#Rows)
        --print(row.StatusBar)
        --print(row.LeftText)

        --print(e.id)
        --print(e.time)

        local now = GetServerTime()
        local elapsed = now - e.time

        row.LeftText:SetText(coords)
        row.RightText:SetFormattedText("%d s", elapsed)

        rowIndex = rowIndex + 1
    end

    for i=rowIndex, #Rows do
        Rows[i]:Hide()
    end
end

local function OnGatherClicked()
    local item = GetNearestItem()
    if not item then
        return
    end

    local now = GetServerTime()
    LFTDB[item] = now
    print("Gathered: " .. item .. " at " .. now)
end

local function OnUpdate(self, elapsed)
    local m,x,y = LFT:GetCurrentPlayerPosition()
    local mapName = LFT.HBD:GetLocalizedMap(m)
    local str = string.format("%s - %d (%f, %f)", mapName, m, x, y)
    --print(str)
    --trackerFrame.DebugText:SetText(str)

    --LFTDB.Data = str

    UpdateBars()
end

local function initData(resetTimers)
    for i, v in pairs(Herbs) do
        if v == Peacebloom and (not LFTDB[i] or resetTimers) then
            LFTDB[i] = 0
           -- print(i .. ": " .. LFTDB[i])
        end

    end
end

local function createActionFrame()
    actionFrame = CreateFrame("Frame",  "LFT_ActionFrame", UIParent)   
    actionFrame.DebugText = actionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")  
    actionFrame.DebugText:ClearAllPoints()
    actionFrame.DebugText:SetPoint("CENTER", 0, 0)

    actionFrame.DebugText:Show()
    --frame:CreateTexture(nil, "BACKGROUND")
    --local fs = frame:CreateFontString(nil, "BACKGROUND")
    actionFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 300, -200)
    actionFrame:SetSize(200, 200)
    actionFrame:EnableMouse(true)
    actionFrame:SetToplevel(true)
    actionFrame:SetMovable(1)
    actionFrame:RegisterForDrag("LeftButton")
    actionFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    actionFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        --ValidateFramePosition(self)
        --local point, _, _, x, y = self:GetPoint(1)
        --DBM.Options.RangeFrameRadarX = x
        --DBM.Options.RangeFrameRadarY = y
        --DBM.Options.RangeFrameRadarPoint = point
    end)
    actionFrame:SetScript("OnMouseDown", function(self, button)
        --if button == "RightButton" then
        --    UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown)
        --    ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
        --end
    end)
    actionFrame:SetScript("OnUpdate", OnUpdate_ActionFrame)
    actionFrame:SetFrameStrata("DIALOG")

    local bg = actionFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(actionFrame)
    bg:SetBlendMode("BLEND")
    bg:SetColorTexture(0, 0, 0, 0.4)
    actionFrame.background = bg

    local btnGather = CreateFrame("Button", "Btn_Gather", actionFrame, "UIPanelButtonTemplate")
    btnGather:SetPoint("TOPLEFT", actionFrame, "TOPLEFT", 0, 0)
    btnGather:SetWidth(100)
    btnGather:SetHeight(20)
    btnGather:SetScript("OnClick", OnGatherClicked)
    btnGather:Show()
    actionFrame.btnGather = btnGather

    local btnReset = CreateFrame("Button", "Btn_Reset", actionFrame, "UIPanelButtonTemplate")
    btnReset:SetPoint("TOPLEFT", actionFrame, "TOPLEFT", 0, -40)
    btnReset:SetWidth(100)
    btnReset:SetHeight(20)
    btnReset:SetScript("OnClick", function()
        initData(true)
    end)
    btnReset:Show()
    actionFrame.btnReset = btnReset
end

local function createTrackerFrame()
    trackerFrame = CreateFrame("Frame",  "LFT_TrackerFrame", UIParent)   
    trackerFrame.DebugText = trackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")  
    trackerFrame.DebugText:ClearAllPoints()
    trackerFrame.DebugText:SetPoint("CENTER", 0, 0)

    trackerFrame.DebugText:Show()
    --frame:CreateTexture(nil, "BACKGROUND")
    --local fs = frame:CreateFontString(nil, "BACKGROUND")
    trackerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -200)
    trackerFrame:SetSize(200, 500)
    trackerFrame:EnableMouse(true)
    trackerFrame:SetToplevel(true)
    trackerFrame:SetMovable(1)
    trackerFrame:RegisterForDrag("LeftButton")
    trackerFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    trackerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        --ValidateFramePosition(self)
        --local point, _, _, x, y = self:GetPoint(1)
        --DBM.Options.RangeFrameRadarX = x
        --DBM.Options.RangeFrameRadarY = y
        --DBM.Options.RangeFrameRadarPoint = point
    end)
    trackerFrame:SetScript("OnMouseDown", function(self, button)
        --if button == "RightButton" then
        --    UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown)
        --    ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
        --end
    end)
    trackerFrame:SetScript("OnUpdate", OnUpdate)
    trackerFrame:SetFrameStrata("DIALOG")

    local bg = trackerFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(trackerFrame)
    bg:SetBlendMode("BLEND")
    bg:SetColorTexture(0, 0, 0, 0.4)
    trackerFrame.background = bg
end

local function showTrackerFrame()
    trackerFrame:Show()
end

local function showActionFrame()
    actionFrame:Show()
end 

function LFT:DumpZones()
    for v,zone in pairs(LFT.HBD:GetAllMapIDs()) do
        print("Zone ".. zone .. ": " .. v)
    end
end

function LFT:OnInitialize()    
    SLASH_LFT1 = '/lft'
    function SlashCmdList.LFT() -- 4.
        showTrackerFrame()
        --self:DumpZones()
        --fs:SetText("123123123")
    end

    initData(false)

	--me:SetFontSize(row.LeftText, math_max(rowHeight * 0.75, rowHeight - 3))
	--Recount:AddFontString(row.LeftText)

    print("LFT initialized")
end

function LFT:GetCurrentPlayerPosition()
    local x, y, mapID = self.HBD:GetPlayerZonePosition()
    return mapID, x, y
end

function LFT:EncodeLoc(x, y)
	if x > 0.9999 then
		x = 0.9999
	end
	if y > 0.9999 then
		y = 0.9999
	end
	return floor( x * 10000 + 0.5 ) * 1000000 + floor( y * 10000  + 0.5 ) * 100
end

function LFT:DecodeLoc(id)
	return floor(id/1000000)/10000, floor(id % 1000000 / 100)/10000
end

local coord_fmt = "%%.%df, %%.%df"
function RoundCoords(x,y,prec)
    local fmt = coord_fmt:format(prec, prec)
    if not x or not y then
        return "---"
    end
    return fmt:format(x*100, y*100)
end

do
    createActionFrame()
    createTrackerFrame()

    showActionFrame()
    showTrackerFrame()

    local encoded = 4950594000
    local coords = LFT:DecodeLoc(encoded)
    print(coords)
    --print(RoundCoords(coords))
end

