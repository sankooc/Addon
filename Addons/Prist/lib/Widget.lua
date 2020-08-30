
local _, namespace = ...

local poption = LibStub('prist_option')

local username = UnitName('player');
local userrace = UnitRace('player')
local userclass = UnitClassBase('player')
local profile = poption.getProfile()

local ctable = RAID_CLASS_COLORS[userclass]


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
    self.queue:del(self.store.name)
end

local function barStyle(name)
  if name == username then
    return 102/255, 153/255, 153/255, .7
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
    end)
    if not stat then log(err) end
  end)
  aag:Restart()
end

function WidgetFactory:pos(index)
  local item = unpack(self.textures)
  item:SetPoint("TOP", self.addon, 0, -5 - (index - 1) * (profile.ht + 2))
end

namespace.Widget = WidgetFactory