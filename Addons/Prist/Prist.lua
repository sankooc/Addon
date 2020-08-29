local prist = LibStub('Prist')
local util  = LibStub('p_utls')
local Pool  = LibStub('panelPool')

local view = util.view
local log = util.log
-- check

local CreateTexturePool = CreateTexturePool
local CreateFontStringPool = CreateFontStringPool


--


local loaded = false

local function view(arg)
  for k,v in pairs(arg) do
      print(k, v)
  end
end

local main = {}

-- local creator = Pool:create(addon)

local f = prist:create()
local addon = f.addon
-- event define
function main:ADDON_LOADED(add_name)
  if add_name == 'Prist' then
    print('addon loaded')
    loaded = true
  end
end

function main:UNIT_SPELLCAST_SENT(...)
  local unit, uname, castGUID, spellID = ...
  f:init(...)
end

function main:UNIT_SPELLCAST_INTERRUPTED(...)
  -- local unit, uname, castGUID, spellID = ...
  -- print('dd', unit, castGUID, spellID)
end
function main:COMBAT_LOG_EVENT_UNFILTERED()
  f:CLGCEI(CombatLogGetCurrentEventInfo())
end
-- view(main)



-- local addon = prist.addon
--  bind events
for k,v in pairs(main) do
  addon:RegisterEvent(k)
end

local function hand(self, event, ...)
  if main[event] then
      main[event](self, ...)
  end
end

addon:SetScript("OnEvent", hand)


-- -- addon:Hide()

-- local profile = {} -- ui setting profile
f:update(true)