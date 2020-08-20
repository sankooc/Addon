print(_G.LibStub)
local major, minor = "mock", '1'
local mock = LibStub:NewLibrary (major, minor)

-- Rectangle.area = 0
-- Rectangle.length = 0
-- Rectangle.breadth = 0

-- -- 派生类的方法 new
-- function Rectangle:new (length,breadth)
--   local o = {}
--   setmetatable(o, { __index = self })
--   -- o.__index = self
--   self.length = length or 0
--   self.breadth = breadth or 0
--   self.area = length*breadth;
--   return o
-- end

-- -- 派生类的方法 printArea
-- function Rectangle:printArea ()
--   print("矩形面积为 ",self.area)
-- end