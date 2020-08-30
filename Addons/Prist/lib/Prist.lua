local major, minor = 'Prist', 1
local Prist = LibStub:NewLibrary (major, minor)

local util  = LibStub('p_utls')
local poption = LibStub('prist_option')
local log = util.log
local view = util.view
local unpack = util.unpack

local _, namespace = ...


local username = UnitName('player');
local userrace = UnitRace('player')
local userclass = UnitClassBase('player')
local profile = poption.getProfile()

local WidgetFactory = namespace.Widget

local Queue = namespace.Queue

function parseStartSpell(...)
  local arg = {...}
  local sname = arg[13]
  local _, _, icon, castTime, _, _, sid = GetSpellInfo(sname);
  return icon, sid, sname, castTime
end

function setBorder(frame)
  frame:SetBackdrop({
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 1, right =1, top = 1, bottom = 1 },
  })
end
local cache = {}
function Prist:create (profile)
  local o = {}
  setmetatable(o, { __index = self })
  o.addon = CreateFrame('Frame',nil,UIParent)
  o.addon:SetSize(242, 50)
  o.profile = profile
  o.queue = Queue:create(o.addon)
  return o
end
function Prist:loadOne(name)
  if cache[name] then
    return cache[name]
  end
  cache[name] = WidgetFactory:create(self.addon, self.queue)
  return cache[name]
end
function Prist:startSpell(...)
  local ts, _, _, _, name = ...
  local icont, sid, sname, castTime = parseStartSpell(...)
  if not castTime then
    return
  end
  local ppp = self:loadOne(name)
  ppp:hide()
  ppp:init({ name=name, icon = icont, castTime = castTime})
  local weight = castTime / 1000 + ts
  self.queue:insert(name, weight, ppp)
end

function Prist:interruptSpell(...)
  local _, _, _, _, name = ...
  -- if name == profile.username then
  --   log('userdis')
  -- else
  --   log('partnerdis')
  -- end
  local ppp = self:loadOne(name)
  ppp:hide()
end

function Prist:finishSpell(...)
end

function Prist:heal(...)
  local ts, _, _, guid, caster, _, _, targetGuid, target, _, _, _, spellName, spellSchool, amount, overkill = ...
  local per = math.ceil((amount - overkill) * 10000 / amount) / 100
  -- log('heal', ts, caster, target, spellName, amount, overkill, per)
  local ppp = self:loadOne(caster)
  ppp:init({ per = per })
end

function Prist:init(...)
  local unit, uname, castGUID, spellID = ...
end

function Prist:CLGCEI(...)
  local ts, type = ...
  local that = self
  if type == 'SPELL_CAST_START' then
    local stat, err = pcall(function(...) self:startSpell(...) end, ...)
    if not stat then log(err) end
  elseif type == 'SPELL_CAST_SUCCESS' then
    self:finishSpell(...)
  elseif type == 'SPELL_CAST_FAILED' then
    self:interruptSpell(...)
  elseif type == 'SPELL_HEAL' then
    self:heal(...)
  end
  -- view({...})
end


function Prist:moving()
  local frame = self.addon
  local canMove = profile.canMove
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
function Prist:update()
  setBorder(self.addon)
  self:moving()
  if profile.visible then
    self.addon:ClearAllPoints()
    self.addon:SetPoint("BOTTOMRIGHT",-350,350)
    self.addon:Show()
  else
    self.addon:Hide()
  end
end