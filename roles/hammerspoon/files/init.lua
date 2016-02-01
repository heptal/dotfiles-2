-- adapted from various hammerspoon configs including cmsj, asmagill, trishume, zzamboni, etc.

-- define mod keys
hyper = {'ctrl', 'alt', 'cmd'}
hypershift = {'ctrl', 'alt', 'cmd', 'shift'}
cc = {'ctrl', 'cmd'}
ccs = {'ctrl', 'cmd', 'shift'}

require "utils"
require "hs.hotkey".setLogLevel("warning")
require "window"
require "asciicons"
require "amphetamine"
require "imgur"
require "pasteboard"
require "redshift"

-- disable animation
hs.window.animationDuration = 0

hsi = hs.inspect

-- define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_monitor = "VX2703 SERIES"

-- Window grid configuration
local gw = 6 --GRIDWIDTH
local gh = 4 --GRIDHEIGHT
hs.grid.setMargins({0, 0})
hs.grid.setGrid(gw.."x"..gh)

local goleft = {x = 0, y = 0, w = gw/2, h = gh}
local goright = {x = gw/2, y = 0, w = gw/2, h = gh}
local gotop = {x = 0, y = 0, w = gw, h = gh/2}
local gobottom = {x = 0, y = gh/2, w = gw, h = gh/2}

local gotopleft = {x = 0, y = 0, w = gw/2, h = gh/2}
local gotopright = {x = gw/2, y = 0, w = gw/2, h = gh/2}
local gobottomleft = {x = 0, y = gh/2, w = gw/2, h = gh/2}
local gobottomright = {x = gw/2, y = gh/2, w = gw/2, h = gh/2}

-- move and resize windows to screen halves, hold for corners
hs.hotkey.bind(hyper, "left", gridset(goleft), nil, gridset(gobottomleft))
hs.hotkey.bind(hyper, "right", gridset(goright), nil, gridset(gotopright))
hs.hotkey.bind(hyper, "up", gridset(gotop), nil, gridset(gotopleft))
hs.hotkey.bind(hyper, "down", gridset(gobottom), nil, gridset(gobottomright))

-- move and resize windows on grid
hs.hotkey.bind(cc, "left", function() hs.grid.pushWindowLeft(fw()) end)
hs.hotkey.bind(cc, "right", function() hs.grid.pushWindowRight(fw()) end)
hs.hotkey.bind(cc, "up", function() hs.grid.pushWindowUp(fw()) end)
hs.hotkey.bind(cc, "down", function() hs.grid.pushWindowDown(fw()) end)

hs.hotkey.bind(ccs, "left", function() hs.grid.resizeWindowThinner(fw()) end)
hs.hotkey.bind(ccs, "right", function() hs.grid.resizeWindowWider(fw()) end)
hs.hotkey.bind(ccs, "up", function() hs.grid.resizeWindowShorter(fw()) end)
hs.hotkey.bind(ccs, "down", function() hs.grid.resizeWindowTaller(fw()) end)

-- move windows incrementally
hs.hotkey.bind(hypershift, "left", function() move(-20,0) end, nil, function() move(-20,0) end)
hs.hotkey.bind(hypershift, "right", function() move(20, 0) end, nil, function() move(20, 0) end)
hs.hotkey.bind(hypershift, "up", function() move(0,-20) end, nil, function() move(0,-20) end)
hs.hotkey.bind(hypershift, "down", function() move(0, 20) end, nil, function() move(0, 20) end)

hs.hotkey.bind(hyper, '.', hs.hints.windowHints) -- show window hints
hs.hotkey.bind(hyper, '/', hs.grid.show) -- show grid
hs.hotkey.bind(hyper, "Space", function() push(1/8, 1/8, 3/4, 3/4) end) -- center and enlarge current window
hs.hotkey.bind(hypershift, "Space", hs.grid.maximizeWindow) -- maximize current window

-- bind application hotkeys
hs.fnutils.each({
    { key = "t", app = "iTerm" },
    { key = "i", app = "iTunes" },
    { key = "s", app = "Sublime Text" },
    { key = "c", app = "Google Chrome" },
    { key = "m", app = "Messages" }
  }, function(object)

    local appActivation = function()
      hs.application.launchOrFocus(object.app)

      local app = hs.appfinder.appFromName(object.app)
      if app then
        app:activate()
        app:unhide()
      end
    end

    hs.hotkey.bind(hyper, object.key, appActivation)
  end)

-- open hammerspoon console
hs.hotkey.bind(hyper, "h", hs.openConsole)

-- open config dir for editing
hs.hotkey.bind(hyper, ",", function()
    hs.execute("/Applications/Sublime\\ Text.app/Contents/SharedSupport/bin/subl ~/.hammerspoon")
  end)

-- for playing with ASCIImage, etc
function imagePreview(image)
  local mousepoint = hs.mouse.getAbsolutePosition()
  local imageRect = hs.drawing.image(hs.geometry.rect(mousepoint.x+20, mousepoint.y, 100, 100), image):show()
  imageRectTimer = hs.timer.doAfter(3, function() imageRect:delete() end)
end

-- auto reload config
configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
hs.alert.show("Config loaded")
