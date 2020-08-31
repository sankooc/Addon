local prist = LibStub('Prist')
local util  = LibStub('p_utls')
local option = LibStub('prist_option')

local view = util.view
local log = util.log

local _, namespace = ...

log('inner')
log(_G.Pdata)
-- _G.Pdata = {}

local profile = option.getProfile()
local loaded = false

local function view(arg)
  for k,v in pairs(arg) do
      print(k, v)
  end
end

local main = {}

local f = prist:create()
local addon = f.addon
-- event define

local function hand(self, event, ...)
  if main[event] then
      main[event](self, ...)
  end
end

function main:ADDON_LOADED(add_name)
  if add_name == 'Prist' then
    print('addon loaded')
    loaded = true
    -- _G.Pdata.profile = profile
    f:update()
  end
end
function main:VARIABLES_LOADED()
  log('VARIABLES_LOADED')
end

function main:UNIT_SPELLCAST_SENT(...)
  local unit, uname, castGUID, spellID = ...
  -- f:init(...)
end

function main:UNIT_SPELLCAST_INTERRUPTED(...)
  -- local unit, uname, castGUID, spellID = ...
  -- print('dd', unit, castGUID, spellID)
end
function main:COMBAT_LOG_EVENT_UNFILTERED()
  if profile.visible then
    f:CLGCEI(CombatLogGetCurrentEventInfo())
  end
end


SLASH_PRIST1 = "/prist"
SlashCmdList["PRIST"] = function(msg)
  if msg == 'show' then
    profile.visible = true
    addon:Show()
  elseif msg == 'hide' then
    profile.visible = false
    addon:Hide()
  end
end


for k,v in pairs(main) do
  addon:RegisterEvent(k)
end
addon:SetScript("OnEvent", hand)