
-- local AceGUI = LibStub('AceGUI-3.0')
-- local frame = AceGUI:Create("Frame")
-- frame:SetTitle("test")
-- frame:SetWidth(400)
-- frame:SetHeight(400)
-- -- frame:SetAlpha(0.5)
-- frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
-- frame:SetLayout("List")

local function view(arg)
    for k,v in pairs(arg) do
        print(k, v)
    end
end
function setBorder(frame)
    frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	    -- bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	    edgeSize = 16,
		tile = true,
		tileSize = 16,
	    insets = { left = 1, right =1, top = 1, bottom = 1 },
    })
	frame:SetBackdropBorderColor(1, 1, 1)
	frame:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
    -- frame:SetBackdropColor(0, 0, 0, .4)
end

function moving(frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetScript("OnMouseDown", function(this)
        if not this.isMoving then
      this:StartMoving()
      this.isMoving = true
        end
    end)
    frame:SetScript("OnMouseUp", function(this)
        if this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = false
        end
    end)
end

local f = CreateFrame("Frame",nil,UIParent)
-- f:SetFrameStrata("WORLD")
moving(f)
f:SetWidth(238)
f:SetHeight(150)
setBorder(f)
function addItem(name, spellId, percent, second)
    -- local item = CreateFrame("Frame",nil, f)
    -- print(name..spellId)
    local item = f:CreateTexture(nil, "ARTWORK");
    item:SetWidth(240)
    item:SetHeight(25)

    local icon = f:CreateTexture(nil,"ARTWORK")
    icon:SetTexture(spellId)
    icon:SetWidth(25)
    icon:SetHeight(25)
    icon:SetPoint("TOPLEFT",item, 0, 0)
    
    
    local fs = f:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
    fs:SetText(name)
    fs:SetTextColor(1, 1, 1)
    fs:SetPoint("CENTER",item, 13, 0)


    local  prog = f:CreateTexture(nil, "ARTWORK");
    prog:SetColorTexture(0.09, 0.61, 0.55, .6)
    prog:SetWidth(10)
    prog:SetHeight(25)
    prog:SetPoint("TOPLEFT",item, 26, 0)

    
    local aag = prog:CreateAnimationGroup()
    local aa1 = aag:CreateAnimation("Scale")
    aa1:SetOrigin("LEFT",0,0)
    aa1:SetScale(20,1)
    aa1:SetDuration(second/ 1000)
    aa1:SetOrder(2)
    local function clear()
        icon:SetTexture(nil)
        icon:Hide()
        fs:Hide()
        prog:Hide()
        item:Hide()
    end
    aa1:SetScript("OnFinished", clear)
    aag:Play()

    item:SetPoint("TOPLEFT",f, 6, -5)
    return item
end

f:ClearAllPoints()
-- addItem('Nullpoiner', '135907', 0.2)

f:SetPoint("BOTTOMRIGHT",-350,350)
f:Show()

local MatchEvents = {
	["SPELL_CAST_START"] = true,
	-- ["SPELL_CAST_SUCCESS"] = true,
	["SPELL_CAST_FAILED"] = true,
}
local imx = {
    ['快速治疗'] = { icon = '135907', dur = 1500 },
    ['强效治疗术'] = { icon = '135913', dur = 2500 }
}
local userList = {}

function f:rev()
    -- view(userList)
    for k,v in pairs(userList) do
        if v then
            local _t = time()
            local exp = math.max((_t - v.start) * 1000, 0)
            local dur = v.dur
            if exp < dur then
                local icon = v.icon
                local per = exp / dur;
                print(k, icon, per, dur)
            end
        end
    end
end
-- view(imx['快速治疗'])
-- print(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellNam)
function f:Add_SKill(name, icon, dur)
    -- table.insert(userList, 'a')
    local size = table.getn(userList)
end
function f:Spellan(timestamp, eventtype, ...)
    -- local mth = MatchEvents[eventtype]
    -- print('acds'..eventtype)
    local tt = {...}
    if eventtype == 'SPELL_CAST_START' then
        -- view(tt)
        local _, srcGUID, srcName, spellId, spellName = ...
        local sname = tt[11]
        -- local _time = time()
        -- print(eventtype, srcGUID, srcName, spellId, sname)
        local cin = imx[sname]
        if not cin then
            return
        end
        -- print(srcName, timestamp, _time)
        local cls = UnitClass(srcName)
        userList[srcName] = {
            icon = cin.icon,
            dur = cin.dur,
            start = timestamp,
            cls = cls,
            name = srcName
        }
        -- print('')
        addItem(srcName, cin.icon, 1, cin.dur)
        -- f:rev()
        -- local name, rank, icon, castTime, _, _, sid = GetSpellInfo(sname);
        -- print(name, rank, icon, castTime, sid);
        -- 快速治疗 135907 1500
        -- 强效治疗术 135913 2500
        -- 次级治疗术 135929 2500
        -- 治疗术 135916 2500
        -- 治疗祷言 135943 3000
        -- print(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellNam)
    --   healstart(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
    elseif eventtype == 'SPELL_CAST_FAILED' then
        local _, srcGUID, srcName, spellId, spellName = ...
        local sname = tt[11]
        print(eventtype, srcGUID, srcName, spellId, sname)
        local cin = imx[sname]
        if not cin then
            return
        end
    end
    -- print(eventtype)
    -- table.insert(EGM, {timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...}) 
    -- print('---')
  end
function f:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
    print(unitID, spellID)
    local name, rank, icon, castTime, _, _, sid = GetSpellInfo(spellID);
    print(name, rank, icon, castTime, sid);
end

function f:COMBAT_LOG_EVENT_UNFILTERED()
    self:Spellan(CombatLogGetCurrentEventInfo());
end

function f:Update()
    f:rev()
    -- print('now')
end

-- f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
f:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end
)

-- local function f_Update(self, elapsed)
--     f:Update(elapsed)
-- end
-- f:SetScript("OnUpdate", f_Update)

print('ui show')

-- local pg = {}

-- table.insert(pg, 'a')
-- table.insert(pg, 'b')
-- table.insert(pg, 'c')
-- table.insert(pg, 'd')
-- print(table.getn(pg))
-- table.remove(pg, 2)
-- print(table.getn(pg))
-- view(pg)