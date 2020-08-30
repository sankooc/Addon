local _, namespace = ...

local poption = LibStub('prist_option')

local username = UnitName('player');
local userrace = UnitRace('player')
local userclass = UnitClassBase('player')
local profile = poption.getProfile()


local function compare(a, b)
  return a.weight < b.weight
end

local function indexIs(list, name)
  for k,v in pairs(list) do
      if name == v.name then
          return k
      end
  end
  return 0
end

local Queue = {}
function Queue:create(addon)
  local o = {}
  setmetatable(o, { __index = self })
  o.data = {}
  o.map = {}
  o.addon = addon
  return o
end
function Queue:redraw()
  table.sort(self.data, compare)
  local size = table.getn(self.data)
  for i, item in ipairs(self.data) do
    item.widget:pos(i)
  end
  local heigth = profile.ht * size + profile.v_padding * 2 + 6
  self.addon:SetSize(profile.width, heigth)
end
function Queue:insert(name, weight, widget)
  local size = table.getn(self.data)
  if not self.map[name] then
    local ite = { name=name, weight=weight, widget=widget }
    table.insert(self.data, ite);
    self.map[name] = ite
    widget:show()
  end
  self:redraw()
end

function Queue:del(name)
  local inx = indexIs(self.data, name)
  if inx > 0 then
    table.remove(self.data, inx)
  end
  if self.map[name] then
    self.map[name] = nil
  end
  self:redraw()
end

namespace.Queue = Queue
