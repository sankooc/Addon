local major, minor = 'Prist', 1
local Prist = LibStub:NewLibrary (major, minor)

local util  = LibStub('p_utls')
local log = util.log
local view = util.view
local addon = CreateFrame('Frame',nil,UIParent)
local visible = true
local canMove = true

local h_padding = 2
local v_padding = 2
local ht = 27
local s_padding = 2
local progress_width = 200
local b_height = 2
local rate = 20

local username = UnitName('player')
local userrace = UnitRace('player')
local userclass = UnitClassBase('player')

local ctable = RAID_CLASS_COLORS[userclass]

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

local WidgetFactory = {}
function WidgetFactory:create ()
  local o = {}
  setmetatable(o, { __index = self })
  
  self.item = addon:CreateTexture(nil, "ARTWORK")
  self.lef = addon:CreateTexture(nil, "ARTWORK")
  self.icon = addon:CreateTexture(nil,"ARTWORK")
  self.fs = addon:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
  self.ss = addon:CreateFontString(nil, "OVERLAY", 'GameTooltipText')
  self.prog = addon:CreateTexture(nil, "ARTWORK")
  self.aag = self.prog:CreateAnimationGroup()
  self.aa1 = self.aag:CreateAnimation("Scale")
  return o
end
function WidgetFactory:hide ()
    self.aag:Stop()
    self.aag:Finish()
    self.lef:Hide()
    self.icon:SetTexture(nil)
    self.icon:Hide()
    self.fs:Hide()
    self.ss:Hide()
    self.prog:Hide()
    self.item:Hide()
    self.aa1:SetScript("OnFinished", nil)
end

local function barStyle(name)
  if name == username then
    return 0.1, 0.7, 0.6, .7
  else
    return 0.09, 0.61, 0.55, .6
  end
end

function WidgetFactory:show(name, spellId, second)
  self.item:SetSize(240, ht)
  self.item:Show()

  self.icon:SetTexture(spellId)
  self.icon:SetSize(ht, ht)
  self.icon:SetPoint("TOPLEFT", self.item, 0, 0)
  self.icon:Show()
  
  self.fs:SetText(name)
  self.fs:SetTextColor(ctable.r, ctable.g, ctable.b)
  -- self.fs:SetTextColor(.8, .8, .8)
  -- log('lineh', self.fs:GetLineHeight())
  -- local ptt = (ht - self.fs:GetLineHeight())/2
  self.fs:SetPoint("CENTER",self.item, ht/2, 2)
  self.fs:Show()

  self.ss:SetText((second/1000)..'s')
  self.ss:SetTextHeight(12)
  self.ss:SetTextColor(.8, .8, .8)
  self.ss:SetPoint("BOTTOMRIGHT",self.item, -ht/2, 4)
  self.ss:Show()
  local r, g, b, a = barStyle(name)
  self.prog:SetColorTexture(r, g, b, a)
  self.prog:SetSize(progress_width / rate, ht - b_height)
  self.prog:SetPoint("TOPLEFT",self.item, ht + s_padding, 0)
  self.prog:Show()
  
  -- self.lef:SetSize(progress_width + ht + s_padding, b_height)
  -- self.lef:SetColorTexture(ctable.r, ctable.g, ctable.b)
  -- self.lef:SetColorTexture(0.1, 0.1, 0.1, .9)
  -- self.lef:SetPoint("BOTTOMLEFT", self.item, 0, 0)
  -- self.lef:Show()

  self.aa1:SetOrigin("LEFT",0,0)
  self.aa1:SetScale(20,1)
  self.aa1:SetDuration(second/ 1000)
  self.aa1:SetOrder(2)
  local that = self
  self.aa1:SetScript("OnFinished", function()
    -- that:hide()
  end)
  self.aag:Restart()
  return self.item
  -- item:SetPoint("TOPLEFT",f, 6, -5 - size * (ht + 2))
end

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
local cache = {}

local Queue = {}
Queue.data = {}
Queue.map = {}
local function compare(a, b)
  return (a.start + a.castTime) > (b.start + b.castTime)
end
function Queue.insert(name, start, castTime, widget)
  -- delay display
  if not Queue.map[name] then
    local ite = { name=name, start=start, castTime=castTime, widget=widget }
    table.insert(Queue.data, ite);
    Queue.map[name] = ite
  end
  table.sort(Queue.data, compare)
end
function Queue.del(name)
  table.remove()
  Queue.map[name] = nil
end

local function loadOne(name)
  if cache[name] then
    return cache[name]
  end
  cache[name] = WidgetFactory:create()
  return cache[name]
end
function Prist:startSpell(...)
  local ts, _, _, _, name = ...
  local icont, sid, sname, castTime = parseStartSpell(...)
  print(icont, sid, sname, castTime, name, ts)
  if not castTime then
    return
  end
  local ppp = loadOne(name)
  ppp:show(name, icont, castTime)
  ppp.item:SetPoint("TOPLEFT", addon, 6, -5 - 0 * (ht + 2))



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
    local stat, err = pcall(function(...) Prist:startSpell(...) end, ...)
    if not stat then log(err) end
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