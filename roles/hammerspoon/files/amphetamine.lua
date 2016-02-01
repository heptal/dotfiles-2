-- caffeine replacement

local icon = require "asciicons"
caffeine = hs.menubar.new()

local function setCaffeineDisplay(state)
  caffeine:setIcon(state and icon.ampOn or icon.ampOff)
end

local function caffeineClicked()
  setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
  caffeine:setClickCallback(caffeineClicked)
  setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end
