
local major, minor = 'panelPool', 1
local Pool = LibStub:NewLibrary (major, minor)

local util  = LibStub('p_utls')

function Pool:create(frame)
  local instance = {}
  setmetatable(instance, { __index = self })
  self.frame = frame
  return instance
end

function Pool:addTarget(uname, spellId, ftime)
  util.log('ac', 'ad')
  -- self:clearSkill(name)
  -- local size = table.getn(userList)
  -- local item, clear = addItem(size, name, icon, dur)
  -- table.insert(userList, { name=name, clear=clear, item=item });
  -- f:recompute();
end