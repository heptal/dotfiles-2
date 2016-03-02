-- adapted from various hammerspoon configs including cmsj, asmagill, trishume, zzamboni, etc.

-- initial setup
hyper = {'⌘', '⌥', '⌃'}
hs.window.animationDuration = 0
hs.luaSkinLog.setLogLevel("warning")
hs.hotkey.setLogLevel("warning") --suppress excessive keybind printing in console
hs.window.filter.setLogLevel("error")
i = hs.inspect -- shortcut for inspecting tables
clear = hs.console.clearConsole

_ = require "std"
table = _.table
require "utils"
require "window"
require "imgur"
require "pasteboard"
require "redshift"
icons = require "asciicons"
amphetamine = require "amphetamine"
volumes = require "volumes"
if hs.socket and hs.image.imageFromMediaFile then mpd = require "mpd" end

hs.hotkey.bind(hyper, "h", hs.toggleConsole) -- toggle hammerspoon console
hs.hotkey.bind(hyper, '.', hs.hints.windowHints) -- show window hints
hs.ipc.cliInstall()

-- for playing with ASCIImage, etc
function imagePreview(image, size)
  size = size or 100
  local pos = hs.mouse.getAbsolutePosition()
  local imageRect = hs.drawing.image(hs.geometry(pos, {w = size, h = size}), image):show()
  imageRectTimer = hs.timer.doAfter(3, function() imageRect:delete() end)
end

ip = imagePreview

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

-- open config dir for editing
hs.hotkey.bind(hyper, ",", function()
    hs.execute(os.getenv("HOME").."/bin/subl "..hs.configdir)
  end)

-- auto reload config
configFileWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config loaded 👍")
