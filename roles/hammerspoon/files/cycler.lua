screenWindows = {}
screenCycler = nil

-- cycle windows on currently focused screen
hs.hotkey.bind(hyper, "]", function()
  local win = hs.window.focusedWindow()

  if hs.fnutils.contains(screenWindows, win) then
    screenCycler():focus()
    return
  end

  local screen = win:screen()
  local app = win:application()
  local appWindows = hs.fnutils.filter(app:allWindows(), function(window) return window:title() ~= "" end)

  screenWindows = hs.fnutils.filter(appWindows, function(window) return window:screen() == screen end)
  screenCycler = hs.fnutils.cycle(screenWindows)
  screenCycler():focus()
end)