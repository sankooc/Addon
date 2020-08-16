local username = UnitName('player')
local userrace = UnitRace('player')
local userclass = UnitClass('player')
-- print(username..userclass)

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

local ht = 22
local f = CreateFrame("Frame",nil,UIParent)
-- f:SetFrameStrata("WORLD")
moving(f)
f:SetWidth(238)
f:SetHeight(20)
setBorder(f)
local widgetCache = {}
function f:aqual (name)
    local sst = widgetCache[name]
    if sst then
        print('cache')
        return sst.item, sst.icon, sst.fs, sst.ss, sst.prog, sst.clear, sst.aag, sst.aa1
    else
        print('create panel')
        local item = f:CreateTexture(nil, "ARTWORK");
        local icon = f:CreateTexture(nil,"ARTWORK")
        local fs = f:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
        local ss = f:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
        local prog = f:CreateTexture(nil, "ARTWORK");
        local aag = prog:CreateAnimationGroup()
        local aa1 = aag:CreateAnimation("Scale")
        local function clear()
            aag:Stop()
            aag:Finish()
            icon:SetTexture(nil)
            icon:Hide()
            fs:Hide()
            ss:Hide()
            prog:Hide()
            -- print('prog')
            item:Hide()
            local numChildren = f:GetNumChildren()
            local numRegions = f:GetNumRegions()
            print('d:'..numChildren..'/'..numRegions)
            -- print('item')
        end
        aa1:SetScript("OnFinished", function()
            f:clearSkill(name)
        end)
        widgetCache[name] = {item = item, icon = icon, fs=fs, ss=ss, prog = prog, clear = clear, aag = aag, aa1=aa1}
        return item, icon, fs, ss, prog, clear, aag, aa1
    end
end
function addItem(size, name, spellId, second)
    -- print('add_item', size, name, spellId)
    local item, icon, fs, ss, prog, clear,aag, aa1 = f:aqual(name)
    -- local item = f:CreateTexture(nil, "ARTWORK");
    item:SetWidth(240)
    item:SetHeight(ht)
    item:Show()

    -- local icon = f:CreateTexture(nil,"ARTWORK")
    icon:SetTexture(spellId)
    icon:SetWidth(ht)
    icon:SetHeight(ht)
    icon:SetPoint("TOPLEFT",item, 0, 0)
    icon:Show()
    
    
    -- local fs = f:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
    fs:SetText(name)
    fs:SetTextColor(1, 1, 1)
    fs:SetPoint("CENTER",item, 13, 0)
    fs:Show()

    
    -- local ss = f:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
    ss:SetText((second/1000)..'s')
    -- ss:SetText('1.2s')
    ss:SetTextHeight(12)
    ss:SetTextColor(.7, .7, .7)
    ss:SetPoint("BOTTOMRIGHT",item, -13, 5)
    ss:Show()

    -- local  prog = f:CreateTexture(nil, "ARTWORK");
    prog:SetColorTexture(0.09, 0.61, 0.55, .6)
    prog:SetWidth(10)
    prog:SetHeight(ht)
    prog:SetPoint("TOPLEFT",item, 26, 0)
    prog:Show()

    
    -- local aag = prog:CreateAnimationGroup()
    -- local aa1 = aag:CreateAnimation("Scale")
    aa1:SetOrigin("LEFT",0,0)
    aa1:SetScale(20,1)
    aa1:SetDuration(second/ 1000)
    aa1:SetOrder(2)
    -- local function clear()
    --     aag:Stop()
    --     -- print('----stop')
    --     icon:SetTexture(nil)
    --     icon:Hide()
    --     -- print('icon')
    --     fs:Hide()
    --     ss:Hide()
    --     -- print('fs')
    --     prog:Hide()
    --     -- print('prog')
    --     item:Hide()
    --     local numChildren = f:GetNumChildren()
    --     local numRegions = f:GetNumRegions()
    --     print('d:'..numChildren..'/'..numRegions)
    --     -- print('item')
    -- end
    -- aa1:SetScript("OnFinished", function()
    --     f:clearSkill(name)
    -- end)
    aag:Restart()

    item:SetPoint("TOPLEFT",f, 6, -5 - size * (ht + 2))
    return item, clear
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
    ['强效治疗术'] = { icon = '135913', dur = 2500 },
    ['次级治疗术'] = { icon = '135929', dur = 2500 },
    ['治疗术'] = { icon = '135916', dur = 2500 },
    ['治疗祷言'] = { icon = '135943', dur = 3000 },
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
                -- print(k, icon, per, dur)
            end
        end
    end
end
-- view(imx['快速治疗'])
-- print(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellNam)
function f:recompute()
    local size = table.getn(userList)
    f:SetWidth(238)
    local h = math.max(20, 10 + size * (ht + 2))
    f:SetHeight(h)
end
function f:Add_SKill(name, icon, dur)
    -- table.insert(userList, 'a')
    f:clearSkill(name)
    local size = table.getn(userList)
    local item, clear = addItem(size, name, icon, dur)
    table.insert(userList, { name=name, clear=clear, item=item });
    f:recompute();
end
function f:indexIs(name)
    for k,v in pairs(userList) do
        if name == v.name then
            return k
        end
    end
    return 0
end
function f:updateAll()
    -- print('update_all')
    local inx = 0
    for k,v in pairs(userList) do
        local item = v.item
        item:SetPoint("TOPLEFT",f, 6, -5 - inx * (ht + 2))
        inx = inx + 1
    end
    -- print('resize')
    f:recompute()
end
function f:clearSkill(name)
    local inx = f:indexIs(name);
    -- print(inx)
    if inx > 0 then
        userList[inx].clear()
        -- print('clearing')
        table.remove(userList, inx)
        f:updateAll()
    end
end

function f:ch(uname, sname)
    local cls = UnitClass(uname)
    if userclass == cls then
        local name, rank, icon, castTime, _, _, sid = GetSpellInfo(sname);
        if not icon then
            return nil
        end
        if castTime > 0 then
            return uname, icon, castTime
        end
    elseif cls == '牧师' then
        local cin = imx[sname]
        if not cin then
            return nil
        end
        return uname,  cin.icon, cin.dur
    end
    return nil
end
function f:Spellan(timestamp, eventtype, ...)
    local tt = {...}
    if eventtype == 'SPELL_CAST_START' then
        -- view(tt)
        local _, srcGUID, srcName, spellId, spellName = ...
        local sname = tt[11]
        local name, icon, dur = f:ch(srcName, sname)
        if name then
            f:Add_SKill(name, icon, dur)
        end
    --   healstart(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
    elseif eventtype == 'SPELL_CAST_FAILED' then
        local _, srcGUID, srcName, spellId, spellName = ...
        local sname = tt[11]
        local aa = f:ch(srcName, sname)
        if aa then
            f:clearSkill(srcName);
        end
    end
    -- print(eventtype)
    -- table.insert(EGM, {timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...}) 
    -- print('---')
  end
function f:UNIT_SPELLCAST_SUCCEEDED(unitID, _, spellID)
    -- print(unitID, spellID)
    local name, rank, icon, castTime, _, _, sid = GetSpellInfo(spellID);
    -- print(name, rank, icon, castTime, sid);
end

function f:COMBAT_LOG_EVENT_UNFILTERED()
    self:Spellan(CombatLogGetCurrentEventInfo());
end

-- function f:Update()
--     f:rev()
--     -- print('now')
-- end

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