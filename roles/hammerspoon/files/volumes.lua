-- manage removable volumes

local module = {}

local humanSize = function(bytes)
  local units = {'bytes', 'kb', 'MB', 'GB', 'TB', 'PB'}
  local power = math.floor(math.log(bytes)/math.log(1000))
  return string.format("%.3f "..units[power + 1], bytes/(1000^power))
end

local volMenuMaker = function(eventType, info)
  local entries = {{title = "Disk Utility", fn = function() hs.application.launchOrFocus("Disk Utility") end}, {title = "-"}}
  local removableVolumes = hs.fnutils.filter(hs.fs.volume.allVolumes(), function(v) return v.NSURLVolumeIsRemovableKey end)
  if #keys(removableVolumes) > 0 then module.menu:returnToMenuBar() else module.menu:removeFromMenuBar() return end

  hs.fnutils.each(keys(removableVolumes), function(path)
      local name = path:match("^/Volumes/(.*)")
      local size = humanSize(removableVolumes[path].NSURLVolumeTotalCapacityKey)
      table.insert(entries, {title = fmt("%s (%s)", name, size), fn = function() hs.execute(fmt("open %q",path)) end})
      table.insert(entries, {title = "⏏ Eject", indent = 1, fn = function() hs.fs.volume.eject(path) end})
    end)

  return entries
end

local diskIcon = hs.image.imageFromPath("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarRemovableDisk.icns")
module.menu = hs.menubar.new():setMenu(volMenuMaker):setIcon(diskIcon:setSize({w=16,h=16}))
module.watcher = hs.fs.volume.new(volMenuMaker):start()
volMenuMaker()

return module
