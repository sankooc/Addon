-- local util  = LibStub('p_utls')
-- local log = util.log
-- local view = util.view
-- local unpack = util.unpack

local major, minor = 'prist_option', 1
local option = LibStub:NewLibrary (major, minor)
local defaultOption = {
    visible = true,
    canMove = true,
    h_padding = 2,
    v_padding = 2,
    ht = 27,
    s_padding = 2,
    progress_width = 200,
    b_height = 2,
    rate = 20,
    width = 242,
}
function option.getProfile()
    return defaultOption
end