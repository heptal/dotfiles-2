-- caffeine replacement

local module = {}

local function setIcon(state)
  module.menu:setIcon(state and icons.ampOn or icons.ampOff)
end

module.menu = hs.menubar.new()
module.menu:setClickCallback(function() setIcon(hs.caffeinate.toggle("displayIdle")) end)
setIcon(hs.caffeinate.get("displayIdle"))

return module
