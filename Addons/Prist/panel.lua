local addon = CreateFrame('Frame',nil,UIParent)
local visible = true
local canMove = true

function moving(frame)
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:SetScript('OnMouseDown', function(this)
      if not canMove then return end
      if not this.isMoving then
        this:StartMoving()
        this.isMoving = true
      end
  end)
  frame:SetScript("OnMouseUp", function(this)
      if not canMove then return end
      if this.isMoving then
          this:StopMovingOrSizing()
          this.isMoving = false
      end
  end)
end



moving(addon)

function addon:update(v)
  visible = v
  if visible then
    addon.Show()
  else
    addon.Hide()
  end
end

function addon:setMove(v)
  canMove = v
end