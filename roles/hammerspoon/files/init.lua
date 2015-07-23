require "window"
require "asciiart"


-- disable animation
hs.window.animationDuration = 0

-- define keys
hyper = {'ctrl', 'alt', 'cmd'}
hypershift = {'ctrl', 'alt', 'cmd', 'shift'}

-- Define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_monitor = "ASUS VH242H"



-- Window Hints
hs.hotkey.bind(hyper, '.', hs.hints.windowHints)

--hello world
hs.hotkey.bind(hyper, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send():release()
end)


hs.hotkey.bind(hyper, "left",  function() push(0.0,0.0,0.5,1.0) end, nil, function() push(0.0,0.5,0.5,0.5) end) -- left side
hs.hotkey.bind(hyper, "right", function() push(0.5,0.0,0.5,1.0) end, nil, function() push(0.5,0.0,0.5,0.5) end) -- right side
hs.hotkey.bind(hyper, "up",    function() push(0.0,0.0,1.0,0.5) end, nil, function() push(0.0,0.0,0.5,0.5) end) -- top half
hs.hotkey.bind(hyper, "down",  function() push(0.0,0.5,1.0,0.5) end, nil, function() push(0.5,0.5,0.5,0.5) end) -- bottom half


hs.hotkey.bind(hyper, "h", function() move(-20,0) end, nil, function() move(-20,0) end)
hs.hotkey.bind(hyper, "j", function() move(0, 20) end, nil, function() move(0, 20) end)
hs.hotkey.bind(hyper, "k", function() move(0,-20) end, nil, function() move(0,-20) end)
hs.hotkey.bind(hyper, "l", function() move(20, 0) end, nil, function() move(20, 0) end)




hs.hotkey.bind(hyper, "Space", function() undo:pop() end)




-- defeat paste blockers
hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)









local mouseCircle = nil
local mouseCircleTimer = nil

function imagePreview(image2)
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.get()
    -- Prepare a big red circle around the mouse pointer
    image = hs.image.imageFromASCII(chevron)
    mouseCircle = hs.drawing.image(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80), image)
    -- mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    -- mouseCircle:setFill(false)
    -- mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
end
hs.hotkey.bind(hyper, "D", function() imagePreview(VPNIcon) end)












local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setIcon(ampicon)
    else
        caffeine:setIcon(noampicon)
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-- auto reload config
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")