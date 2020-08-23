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

local TexPoolResetter = function(pool,tex)
  log('texture reset')
  tex:Hide()
  tex:ClearAllPoints()
end
local function StringResetter(pool,tex)
  log('string reset')
  tex:Hide()
  tex:ClearAllPoints()
end 
local TextPool = CreateTexturePool(UIParent ,"ARTWORK",TexPoolResetter)
local StringPool = CreateFontStringPool(UIParent , 'OVERLAY', StringResetter)

local addon = prist.addon
local main = {}

local creator = Pool:create(addon)

-- event define
function main:ADDON_LOADED(add_name)
  if add_name == 'Prist' then
    print('addon loaded')
    loaded = true
  end
end
local icon

function main:UNIT_SPELLCAST_SENT(...)
  local unit, uname, castGUID, spellID = ...
  -- if icon then
    -- TextPool:Release(icon)
    -- util.log('relase')
    -- local numChildren = TextPool:GetNumChildren()
    -- local numRegions = TextPool:GetNumRegions()
    -- print('d:'..numChildren..'/'..numRegions)
  -- end
  prist:init(...)
  -- icon = TextPool:Acquire()
  
  -- icon:SetTexture(spellID)
  -- icon:SetSize(20, 20)
  -- icon:SetPoint("TOPLEFT",addon, 5, -5)
  -- icon:Show()
  -- util.log('icon shouw')
  -- TextPool:Release(icon)
  -- creator:addTarget(uname, spellID)
  -- local framePool = CreateFramePool("Statusbar", UIParent, "SmallCastingBarFrameTemplate", ResetterFunc)
  -- framePool:SetPoint("BOTTOMRIGHT",-150,350)
  -- framePool:Show()
  -- local f = PoolManager:AcquireFrame()
  -- PoolManager:InitializeNewFrame(f)
  -- util.log('init')
end

function main:UNIT_SPELLCAST_INTERRUPTED()
end
function main:COMBAT_LOG_EVENT_UNFILTERED()
  prist:CLGCEI(CombatLogGetCurrentEventInfo())
end
-- view(main)



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


-- addon:Hide()

addon:SetWidth(238)
addon:SetHeight(400)

prist:update(true)