-- initial setup
hs.shutdownCallback = function()  hs.settings.set('history', hs.console.getHistory()) end
hs.console.setHistory(hs.settings.get('history'))
hyper = {'⌘', '⌥', '⌃'}
hs.window.animationDuration = 0

-- your stuff and other module imports go here
require 'cycler'


-- open config dir for editing
hs.hotkey.bind(hyper, ",", function()
    hs.urlevent.openURLWithBundle("file://"..hs.configdir, "com.sublimetext.3")
  end)

-- auto reload config
configFileWatcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config loaded 👍")