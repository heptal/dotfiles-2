-- stuff to always load/set first
hs.window.animationDuration = 0

-- auto reload config
configFileWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

-- perhist console history across launches
hs.shutdownCallback = function() hs.settings.set('history', hs.console.getHistory()) end
hs.console.setHistory(hs.settings.get('history'))

-- helpful aliases
i = hs.inspect
fw = hs.window.focusedWindow
fmt = string.format
bind = hs.hotkey.bind
clear = hs.console.clearConsole
std = hs.stdlib and require("hs.stdlib")

-- useful keybindings
hyper = {'⌘', '⌥', '⌃'}
bind(hyper, "h", hs.toggleConsole)
bind(hyper, '.', hs.hints.windowHints)
bind(hyper, ",", function() hs.urlevent.openURLWithBundle("file://"..hs.configdir, hs.settings.get("editorBundleID")) end)

-- core user modules
require "utils"
icons = require "asciicons"
amphetamine = require "amphetamine"
require "window"
require "imgur"
