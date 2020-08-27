_G.strmatch = _G.string.match

require('./LibStub')
require('./lib/util')
-- require('./test/mock')
-- require('./test/scene')

function unpack (t, i)
  i = i or 1
  if t[i] ~= nil then
    return t[i], unpack(t, i + 1)
  end
end

local name = 'name1'
local age = 12
local pando = 'pando2'
local r1 = function()
  return { name, age, pando }
end

local a, b , c = unpack(r1())

print(a)
print(b)
print(c)