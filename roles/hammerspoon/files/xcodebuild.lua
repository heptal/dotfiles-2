-- initial setup
hyper = {'⌘', '⌥', '⌃'}
hs.window.animationDuration = 0
i = hs.inspect -- shortcut for inspecting tables
clear = hs.console.clearConsole

std = require "hs.stdlib"
table = std.table
require "utils"
require "window"
require "imgur"
require "pasteboard"
icons = require "asciicons"

require "test"

hs.hotkey.bind(hyper, "h", hs.toggleConsole) -- toggle hammerspoon console

hs.hotkey.bind(hyper, ",", function()
    hs.urlevent.openURLWithBundle("file://"..hs.configdir, "com.sublimetext.3")
  end)

configFileWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Xcode config loaded 👍")
