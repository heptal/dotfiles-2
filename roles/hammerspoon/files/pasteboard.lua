-- make verbatim google search easier
hs.hotkey.bind({"cmd", "shift"}, "'", function()
    local oldText = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "c")
    hs.timer.usleep(100000)
    local text = hs.pasteboard.getContents()
    hs.pasteboard.setContents(oldText)
    hs.eventtap.keyStrokes('"""'..text..'"""')
  end)

-- defeat paste blockers
hs.hotkey.bind({"cmd", "shift"}, "v", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- remove's Safari 'enhanced' pasteboard hyperlink garbage in Messages
local function cleanPasteboard()
  local ct = hs.pasteboard.contentTypes()
  if tableContains(ct, "com.apple.webarchive") and tableContains(ct, "public.rtf") then
    hs.pasteboard.setContents(hs.pasteboard.getContents())
  end
end

local messages = hs.window.filter.new(false):setAppFilter('Messages')
messages:subscribe(hs.window.filter.windowFocused, cleanPasteboard)
