-- adapted from various hammerspoon configs including cmsj, asmagill, trishume, zzamboni, etc.

-- initial setup
hyper = {'⌘', '⌥', '⌃'}
hs.window.animationDuration = 0
hs.hotkey.setLogLevel("warning") --suppress excessive keybind printing in console

require "utils"
require "window"
require "amphetamine"
require "imgur"
require "pasteboard"
require "redshift"
-- spaces = require("hs._asm.undocumented.spaces")

hsi = hs.inspect -- shortcut for inspecting tables
hs.hotkey.bind(hyper, "h", hs.toggleConsole) -- toggle hammerspoon console
hs.hotkey.bind(hyper, '.', hs.hints.windowHints) -- show window hints
hs.ipc.cliInstall()

-- for playing with ASCIImage, etc
function imagePreview(image)
  local pos = hs.mouse.getAbsolutePosition()
  local imageRect = hs.drawing.image(hs.geometry(pos, {w = 100, h = 100}), image):show()
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

-- open config dir for editing
hs.hotkey.bind(hyper, ",", function()
    hs.execute(os.getenv("HOME").."/bin/subl "..hs.configdir)
  end)

-- auto reload config
configFileWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config loaded 👍")
