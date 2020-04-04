--local name = UnitName("unit")
--print("Hello: " .. )

--SendChatMessage("sssss" .. name, )

local LFT = LibStub("AceAddon-3.0"):NewAddon("LFT","AceConsole-3.0","AceEvent-3.0")
LFT.HBD = LibStub("HereBeDragons-2.0")

local trackerFrame

local function OnUpdate(self, elapsed)
    local m,x,y = LFT:GetCurrentPlayerPosition()
    local mapName = LFT.HBD:GetLocalizedMap(m)
    local str = string.format("%s - %d (%f, %f)", mapName, m, x, y)
    --print(str)
    trackerFrame.DebugText:SetText(str)

    LFTDB.Data = str
end

trackerFrame = CreateFrame("Frame",  "LFT_TrackerFrame", UIParent)   
trackerFrame.DebugText = trackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")  
trackerFrame.DebugText:ClearAllPoints()
trackerFrame.DebugText:SetPoint("CENTER", 0, 0)

trackerFrame.DebugText:Show()
--frame:CreateTexture(nil, "BACKGROUND")
--local fs = frame:CreateFontString(nil, "BACKGROUND")
trackerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100)
trackerFrame:SetSize(200, 200)
trackerFrame:EnableMouse(true)
trackerFrame:SetToplevel(true)
trackerFrame:SetMovable(1)
trackerFrame:RegisterForDrag("LeftButton")
trackerFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

trackerFrame:SetScript("OnUpdate", OnUpdate)

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
trackerFrame:SetFrameStrata("DIALOG")

local bg = trackerFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(trackerFrame)
bg:SetBlendMode("BLEND")
bg:SetColorTexture(0, 0, 0, 0.4)
trackerFrame.background = bg

local function showFrame()
    trackerFrame:Show()
end

function LFT:DumpZones()
    for v,zone in pairs(LFT.HBD:GetAllMapIDs()) do
        print("Zone ".. zone .. ": " .. v)
    end
end

function LFT:OnInitialize()    
    SLASH_LFT1 = '/lft'
    function SlashCmdList.LFT() -- 4.
        showFrame()
        --self:DumpZones()
        --fs:SetText("123123123")
    end

    self.defaults = {
        global = {
            ololo = "123"
        },

        profile = {
            ["*"] = {}
        }
    }

    --self.db = LibStub("AceDB-3.0"):New("LFTDB", self.defaults)

    LFTDB = {
        ololol = "123123123"
    }

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
    showFrame()

    local encoded = 4950594000
    local coords = LFT:DecodeLoc(encoded)
    print(coords)
    --print(RoundCoords(coords))
end

