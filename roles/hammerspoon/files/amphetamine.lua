-- caffeine replacement

local amphetamine = {}
local icon = require "asciicons"

amphetamine.menu = hs.menubar.new()

local function setIcon(state)
  amphetamine.menu:setIcon(state and icon.ampOn or icon.ampOff)
end

if amphetamine.menu then
  amphetamine.menu:setClickCallback(function() setIcon(hs.caffeinate.toggle("displayIdle")) end)
  setIcon(hs.caffeinate.get("displayIdle"))
end

return amphetamine
