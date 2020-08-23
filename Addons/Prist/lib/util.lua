local major, minor = "p_utls", 1
local util = LibStub:NewLibrary(major, minor)

local debug = true

function util.view(arg)
  for k, v in pairs(arg) do
    print(k, v)
  end
end

function util.log(...)
  print(...)
end
