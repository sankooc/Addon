local major, minor = "p_utls", 1
local util = LibStub:NewLibrary(major, minor)

local debug = true


function util.unpack (t, i)
  i = i or 1
  if t[i] ~= nil then
    return t[i], unpack(t, i + 1)
  end
end

function util.view(arg)
  for k, v in pairs(arg) do
    print(k, v)
  end
end

function util.log(...)
  print(...)
end
