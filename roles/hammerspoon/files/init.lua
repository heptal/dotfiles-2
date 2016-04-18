-- adapted from various hammerspoon configs including cmsj, asmagill, trishume, zzamboni, etc.

-- load base settings
require "preload"

-- load a more minimal config if running from xcode
if hs.processInfo.bundlePath:match("/Users/michael/Library/Developer/Xcode/DerivedData/") then
  require "xcodebuild"
  return
end

-- suppress warnings
hs.luaSkinLog.setLogLevel("warning")
hs.hotkey.setLogLevel("warning")
hs.window.filter.setLogLevel("error")

-- ensure CLI installed
hs.ipc.cliInstall()

-- imports 
require "pasteboard"
require "windowcycler"
-- require "redshift"
prompter = require "prompter"
volumes = require "volumes"
docker = require "docker"
mpd = require "mpd" -- ; mpd.setLogLevel'info'

-- image preview - for playing with ASCIImage, etc
function ip(image, size)
  size = size or 100
  local pos = hs.mouse.getAbsolutePosition()
  local imageRect = hs.drawing.image(hs.geometry(pos, {w = size, h = size}), image):show()
  imageRectTimer = hs.timer.doAfter(3, function() imageRect:delete() end)
end

-- bind application hotkeys
hs.fnutils.each({
    { key = "t", app = "iTerm" },
    { key = "i", app = "iTunes" },
    { key = "s", app = "Safari" },
    { key = "e", app = "Sublime Text" },
    { key = "c", app = "Google Chrome" },
    { key = "m", app = "Messages" },
  }, function(item)

    local appActivation = function()
      hs.application.launchOrFocus(item.app)

      local app = hs.appfinder.appFromName(item.app)
      if app then
        app:activate()
        app:unhide()
      end
    end

    hs.hotkey.bind(hyper, item.key, appActivation)
  end)

hs.alert.show("Config loaded 👍")
