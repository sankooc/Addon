local major, minor = 'Prist', 1
local Prist = LibStub:NewLibrary (major, minor)

local util  = LibStub('p_utls')
local log = util.log
local view = util.view
local unpack = util.unpack

local profile = {
  visible = true,
  canMove = true,
  h_padding = 2,
  v_padding = 2,
  ht = 27,
  s_padding = 2,
  progress_width = 200,
  b_height = 2,
  rate = 20,
  username = UnitName('player'),
  userrace = UnitRace('player'),
  userclass = UnitClassBase('player')
}

-- view(profile)

local ctable = RAID_CLASS_COLORS[profile.userclass]


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
function WidgetFactory:create (addon, queue)
  local o = {}
  setmetatable(o, { __index = self })
  o.store = {
    per = 0,
    icon = 135907
  }

  local item = addon:CreateTexture(nil, "ARTWORK")
  local icon = addon:CreateTexture(nil,"ARTWORK")
  local prog = addon:CreateTexture(nil, "ARTWORK")
  o.textures = { item, icon, prog }

  local fs = addon:CreateFontString(nil, "OVERLAY", 'CombatLogFont')
  local ss = addon:CreateFontString(nil, "OVERLAY", 'GameFontWhiteTiny')
  local ps = addon:CreateFontString(nil, "OVERLAY", 'GameFontHighlightSmall')
  o.texts = { fs, ss, ps }

  local aag = prog:CreateAnimationGroup()
  local aa1 = aag:CreateAnimation("Scale")
  o.animations = { aag, aa1 }
  o.addon = addon
  o.queue = queue
  return o
end
function WidgetFactory:init(obj)
  for key, value in pairs(obj) do 
    rawset( self.store, key, value )
  end
end
function WidgetFactory:hide ()
    for i, tex in ipairs(self.textures) do
      tex:SetTexture(nil)
      tex:Hide()
    end
    for i, tex in ipairs(self.texts) do
      tex:Hide()
    end
    local aag, aa1 = unpack(self.animations)
    aag:Stop()
    aag:Finish()
    aa1:SetScript("OnFinished", nil)
end

local function barStyle(name)
  if name == username then
    return 0.1, 0.7, 0.6, .7
  else
    return 0.09, 0.61, 0.55, .6
  end
end

local function perStyle(per)
  if per > 75 then
    return 154/255, 205/255, 50/255, 15
  elseif per > 40 then
    return 218/255, 165/255, 32/255, 15
  else
    return 1, 0, 0, 15
  end
end

function WidgetFactory:show(index)
  local ht = profile.ht;
  local h_padding = profile.h_padding
  local s_padding = profile.s_padding;
  local progress_width = profile.progress_width
  local rate = profile.rate
  local b_height = profile.b_height

  local name = self.store.name

  local item, icon, prog = unpack(self.textures)
  item:SetSize(ht + s_padding + progress_width + h_padding * 2 , ht)
  item:Show()
  icon:SetTexture(self.store.icon)
  icon:SetSize(ht, ht)
  icon:SetPoint("TOPLEFT", item, 0, 0)
  icon:Show()
  
  local r, g, b, a = barStyle(self.store.name)
  prog:SetColorTexture(r, g, b, a)
  prog:SetSize(progress_width / rate, ht - b_height)
  prog:SetPoint("TOPLEFT", item, ht + s_padding, 0)
  prog:Show()
  
  -- view(self.texts)
  local fs, ss, ps = unpack(self.texts)
  -- log(fs)
  fs:SetText(name)
  fs:SetTextColor(ctable.r, ctable.g, ctable.b)
  fs:SetPoint("CENTER", item, ht/2 + 7, 2)
  fs:Show()
  do
    ps:SetText(self.store.per..'%')
    local r,g,b = perStyle(self.store.per)
    ps:SetTextColor(r, g, b)
    ps:SetPoint("TOPLEFT", item, ht * 1.2 + s_padding, 0)
    ps:Show()
  end

  ss:SetText((self.store.castTime/1000)..'s')
  ss:SetTextColor(.9, .9, .9)
  ss:SetPoint("BOTTOMLEFT",item, ht * 1.2 + s_padding, 2)
  ss:Show()


  
  local aag, aa1 = unpack(self.animations)
  aa1:SetOrigin("LEFT",0,0)
  aa1:SetScale(rate,1)
  aa1:SetDuration(self.store.castTime/ 1000)
  aa1:SetOrder(2)
  aa1:SetScript("OnFinished", function()
    -- prog:SetSize(progress_width, ht - b_height)
    local stat, err = pcall(function()
      self:hide()
      self.queue.del(name)
    end)
    if not stat then log(err) end
  end)
  aag:Restart()
end

function WidgetFactory:pos(index)
  local item = unpack(self.textures)
  item:SetPoint("TOP", self.addon, 0, -5 - (index - 1) * (profile.ht + 2))
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

local Queue = {}
Queue.data = {}
Queue.map = {}
local function compare(a, b)
  return (a.start + a.castTime) < (b.start + b.castTime)
end
function Queue.insert(name, start, castTime, widget)
  -- delay display
  local size = table.getn(Queue.data)
  log('size:', size)
  if not Queue.map[name] then
    local ite = { name=name, start=start, castTime=castTime, widget=widget }
    table.insert(Queue.data, ite);
    Queue.map[name] = ite
    log('insert_toqueque')
    widget:show()
  end
  table.sort(Queue.data, compare)
  log('---start')
  for i, item in ipairs(Queue.data) do
    item.widget:pos(i)
    log('is'..item.name)
  end
  log('---end')
end

local function indexIs(list, name)
  for k,v in pairs(list) do
      if name == v.name then
          return k
      end
  end
  return 0
end

function Queue.del(name)
  local inx = indexIs(Queue.data, name)
  if inx > 0 then
    table.remove(Queue.data, inx)
    log('remove-queue:', name)
  end
  Queue.map[name] = nil
  table.sort(Queue.data, compare)
  for i, item in ipairs(Queue.data) do
    item.widget:pos(i)
  end
end

local cache = {}
function Prist:create ()
  local o = {}
  setmetatable(o, { __index = self })
  o.addon = CreateFrame('Frame',nil,UIParent)
  o.addon:SetSize(242, 400)
  return o
end
function Prist:loadOne(name)
  if cache[name] then
    return cache[name]
  end
  cache[name] = WidgetFactory:create(self.addon, Queue)
  return cache[name]
end
function Prist:startSpell(...)
  local ts, _, _, _, name = ...
  local icont, sid, sname, castTime = parseStartSpell(...)
  -- print(icont, sid, sname, castTime, name, ts)
  if not castTime then
    return
  end
  print(icont, sid, sname, castTime, name, ts)
  -- local finishTime = castTime / 1000 + ts
  -- print(finishTime)
  log('start', name)
  local ppp = self:loadOne(name)
  ppp:init({ name=name, icon = icont, castTime = castTime})
  -- ppp:show(1)
  Queue.insert(name, ts, castTime, ppp)
end

function Prist:interruptSpell(...)
  local _, _, _, _, name = ...
  if name == profile.username then
    log('userdis')
  else
    log('partnerdis')
  end
  -- view({...})
end

function Prist:finishSpell(...)
  -- view({...})
end

function Prist:heal(...)
  local ts, _, _, guid, caster, _, _, targetGuid, target, _, _, _, spellName, spellSchool, amount, overkill = ...
  local per = math.ceil((amount - overkill) * 10000 / amount) / 100
  log('heal', ts, caster, target, spellName, amount, overkill, per)
  local ppp = self:loadOne(caster)
  ppp:init({ per = per })
end

function Prist:init(...)
  local unit, uname, castGUID, spellID = ...
end

function Prist:CLGCEI(...)
  local ts, type = ...
  -- print(ts, type)
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