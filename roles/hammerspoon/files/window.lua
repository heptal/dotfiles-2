-- Window Management

-- Resize window for chunk of screen.
-- For x and y: use 0 to expand fully in that dimension, 0.5 to expand halfway
-- For w and h: use 1 for full, 0.5 for half
function push(x, y, w, h)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  undo:push()

  f.x = max.x + (max.w*x)
  f.y = max.y + (max.h*y)
  f.w = max.w*w
  f.h = max.h*h
  win:setFrame(f)
end





function move(x, y)
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x + x
  f.y = f.y + y
  win:setFrame(f)
end


--undo for toggling windows
undo = {}

function undo:push()
  local win = hs.window.focusedWindow()
  if not undo[win:id()] then
    self[win:id()] = win:frame()
  end
end

function undo:pop()
  local win = hs.window.focusedWindow()
  if self[win:id()] then
    win:setFrame(self[win:id()])
    self[win:id()] = nil
  end
end