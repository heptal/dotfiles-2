-- window management

-- shorthand for focused window
function fw()
  return hs.window.focusedWindow()
end

-- move and/or resize windows
local function rect(rect)
  return function()
    undo:push()
    local win = fw()
    if win then win:move(rect) end
  end
end

-- window grid configuration
local gridWidth, gridHeight = 6, 4
hs.grid.setGrid(gridWidth.."x"..gridHeight)
hs.grid.setMargins({0, 0})

-- show 3x3 grid modal
hs.hotkey.bind(hyper, '/', function()
    local gridSize = hs.grid.getGrid()
    hs.grid.setGrid("3x3")
    hs.grid.show(function() hs.grid.setGrid(gridSize) end)
  end)

-- center and enlarge current window; hold to maximize
hs.hotkey.bind(hyper, "space", rect({1/8, 1/8, 3/4, 3/4}), nil, rect({0, 0, 1, 1}))

-- define window movement/resize operation mappings
local dirs = {
  Up    = { half={ 0, 0, 1,.5}, movement={ 0,-20}, complement="Left",  resize="Shorter" },
  Down  = { half={ 0,.5, 1,.5}, movement={ 0, 20}, complement="Right", resize="Taller"  },
  Left  = { half={ 0, 0,.5, 1}, movement={-20, 0}, complement="Down",  resize="Thinner" },
  Right = { half={.5, 0,.5, 1}, movement={ 20, 0}, complement="Up",    resize="Wider"   },
}

-- compose screen quadrants from halves
local function quadrant(t1, t2)
  return {t1[1] + t2[1], t1[2] + t2[2], .5, .5}
end

-- arrow-based window movement/resize operations
hs.fnutils.each({"Left", "Right", "Up", "Down"}, function(dir)

    hs.hotkey.bind( -- move to screen halves; hold for quadrants
      hyper,
      dir,
      rect(dirs[dir].half),
      nil,
      rect(quadrant(dirs[dir].half, dirs[dirs[dir].complement].half))
    )

    hs.hotkey.bind( -- move windows incrementally
      {"ctrl", "cmd"},
      dir,
      rect(dirs[dir].movement),
      nil,
      rect(dirs[dir].movement)
    )

    hs.hotkey.bind( -- move windows by grid increments
      {"ctrl", "alt"},
      dir,
      function()
        undo:push()
        hs.grid['pushWindow'..dir](fw())
      end
    )

    hs.hotkey.bind( -- resize windows by grid increments
      {"ctrl", "alt", "shift"},
      dir,
      function()
        undo:push()
        hs.grid['resizeWindow'..dirs[dir].resize](fw())
      end
    )

  end)

-- undo for window operations
undo = {}

function undo:push()
  local win = fw()
  if not undo[win:id()] then
    self[win:id()] = win:frame()
  end
end

function undo:pop()
  local win = fw()
  if self[win:id()] then
    win:setFrame(self[win:id()])
    self[win:id()] = nil
  end
end

hs.hotkey.bind({"ctrl", "alt"}, "z", function() undo:pop() end)
