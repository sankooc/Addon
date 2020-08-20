local mock = LibStub('mock')

local function view(arg)
  for k,v in pairs(arg) do
      print(k, v)
  end
end

local r1 = mock:new(10,20)
print(r1)
r1:printArea()

local r2 = mock:new(20,20)
r2:printArea()
r1.coun1 = function(self)
  print(self)
end
view(r1)

r1.coun1()