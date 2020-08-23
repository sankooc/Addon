local major, minor = 'Prist', 1
local Prist = LibStub:NewLibrary (major, minor)

local util  = LibStub('p_utls')
local log = util.log
local view = util.view
local addon = CreateFrame('Frame',nil,UIParent)
local visible = true
local canMove = true

local userclass = UnitClassBase('player')

function moving(frame)
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:SetScript('OnMouseDown', function(this)
      if not canMove then return end
      if not this.isMoving then
        this:StartMoving()
        this.isMoving = true
      end
  end)
  frame:SetScript("OnMouseUp", function(this)
      if not canMove then return end
      if this.isMoving then
          this:StopMovingOrSizing()
          this.isMoving = false
      end
  end)
end

function setBorder(frame)
  frame:SetBackdrop({
  -- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    -- bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
  -- tile = true,
  -- tileSize = 16,
    insets = { left = 1, right =1, top = 1, bottom = 1 },
  })
-- frame:SetBackdropBorderColor(1, 1, 1)
-- frame:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
  -- frame:SetBackdropColor(0, 0, 0, .4)
end

local TexPoolResetter = function(pool, tex)
  log('texture reset')
  tex:Hide()
  -- tex:un
  tex:ClearAllPoints()
end

local function StringResetter(pool,tex)
  log('string reset')
  tex:Hide()
  tex:ClearAllPoints()
end 

-- local pool = CreateObjectPool(
--   function() return CreateFrame("Frame") end,
--   function(__, frame) frame:Hide() end
-- )
-- local frame = pool:Acquire()
local TextPool = CreateTexturePool(UIParent ,"ARTWORK",TexPoolResetter)
local StringPool = CreateFontStringPool(UIParent , 'OVERLAY', StringResetter)


moving(addon)
setBorder(addon)

function Prist:update(v)
  visible = v
  if visible then
    addon:ClearAllPoints()
    addon:SetPoint("BOTTOMRIGHT",-350,350)
    addon:Show()
  else
    addon:Hide()
  end
end

function Prist:setMove(v)
  canMove = v
end

local ht =27


function parseStartSpell(...)
  local arg = {...}
  local sname = arg[13]
  local _, _, icon, castTime, _, _, sid = GetSpellInfo(sname);
  return icon, sid, sname, castTime
end

function progresStyle (uname)
  -- local ctable = RAID_CLASS_COLORS[userclass]
  -- prog:SetColorTexture(ctable.r, ctable.g, ctable.b)
  return 0.09, 0.61, 0.55, 1
end
function nameplateStyle(uname)
  return uname, .8, .8, .8, .9;
end
function Prist:startSpell(...)
  -- log('start')
  local ts, _, _, _, name = ...
  local icont, sid, sname, castTime = parseStartSpell(...)
  print(icont, sid, sname, castTime, name, ts)
  if not castTime then
    return
  end
  -- log('', ts, name)
  -- local sname = arg[13]
  -- log('start:',name, sname)
  -- local _, rank, icon, castTime, _, _, sid = GetSpellInfo(sname);
  -- log('start:', name, sname, icon, castTime)
  -- log(name, spellId, second)
  -- view({...})
  local item = TextPool:Acquire()
  local icon = TextPool:Acquire()
  local fs = StringPool:Acquire()
  local ss = StringPool:Acquire()
  local prog = TextPool:Acquire()
  local aag = prog:CreateAnimationGroup()
  local aa1 = aag:CreateAnimation("Scale")
  local function _release()
    TextPool:Release(item)
    TextPool:Release(icon)
    TextPool:Release(prog)
    TextPool:Release(item)
    StringPool:Release(fs)
    StringPool:Release(ss)
  end
  -- log('----0')
  
  item:SetWidth(240)
  item:SetHeight(ht)
  item:Show()

  icon:SetTexture(icont)
  icon:SetWidth(ht)
  icon:SetHeight(ht)
  icon:SetPoint("TOPLEFT",item, 0, 0)
  icon:Show()
  

  do
    local ffname, r, g, b, a = nameplateStyle(name)
    fs:SetFontObject('GameTooltipText')
    fs:SetText(ffname)
    fs:SetTextColor(r, g, b, a)
    fs:SetPoint("CENTER",item, 13, 0)
    fs:Show()
  end
  -- ss:SetText((castTime/1000)..'s')
  -- ss:SetText('1.2s')
  ss:SetTextHeight(12)
  ss:SetTextColor(.8, .8, .8)
  ss:SetPoint("BOTTOMRIGHT",item, -13, 5)
  ss:Show()
  -- log('----2')
  -- local ctable = RAID_CLASS_COLORS[userclass]
  -- prog:SetColorTexture(ctable.r, ctable.g, ctable.b)
  -- prog:SetColorTexture(0.09, 0.61, 0.55, .6)
  do
    local g, r, b, a = progresStyle(name)
    prog:SetColorTexture(g, r, b, a)
    prog:SetWidth(10)
    -- prog:SetScale(0.05) 
    prog:SetHeight(ht)
    prog:SetPoint("TOPLEFT",item, 26, 0)
    prog:Show()
    

    aa1:SetScript("OnFinished", function()
      prog:SetWidth(200)
      -- prog:SetWidth(200)
      _release()
      log('rela')
        -- f:clearSkill(name)
    end)
  end
  aa1:SetOrigin("LEFT",0,0)
  aa1:SetScale(20,1)
  aa1:SetDuration(castTime/ 1000)
  aa1:SetOrder(2)
  aag:Restart()

  item:SetPoint("TOPLEFT", addon, 6, -5 - 0 * (ht + 2))



  -- widgetCache[name] = {item = item, icon = icon, fs=fs, ss=ss, prog = prog, clear = clear, aag = aag, aa1=aa1}
  -- return item, icon, fs, ss, prog, clear, aag, aa1
end

function Prist:interruptSpell()
end

function Prist:finishSpell()
end

function Prist:heal(...)
  log(...)
end

function Prist:init(...)
  local unit, uname, castGUID, spellID = ...
  -- log('init spell')
  -- view({...})
end

function Prist:CLGCEI(...)
  local ts, type = ...
  -- print(ts, type)
  if type == 'SPELL_CAST_START' then
    Prist:startSpell(...)
  elseif type == 'SPELL_CAST_SUCCESS' then
    Prist:finishSpell(...)
  elseif type == 'SPELL_CAST_FAILED' then
    Prist:interruptSpell(...)
  elseif type == 'SPELL_HEAL' then
    Prist:heal(...)
  end
  -- view({...})
end

Prist.addon = addon