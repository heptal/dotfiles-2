-- manage docker stuff

local module = {}
local pbcopy = hs.pasteboard.setContents
local openURL = function(addr) hs.urlevent.openURLWithBundle(addr, hs.urlevent.getDefaultHandler("http")) end
local path, env = "PATH=/usr/local/bin/:$PATH;", "eval $(docker-machine env default);"
local dockerMachineExec = function(arg) return hs.execute(path.."docker-machine "..arg) end
local docker = function(arg) return hs.execute(path..env.."docker "..arg) end
local tempfile = "/tmp/script"

local dmTask = function(action)
  if not action then return module.task and module.task:isRunning() or false end
  io.open(tempfile,"w"):write("#!/bin/bash\n"..path.."docker-machine "..action.." default"):close()
  hs.execute("chmod +x "..tempfile)
  module.task = hs.task.new(tempfile, function() hs.alert(action.." docker-machine complete"); module.task = nil end):start()
end

local dockerMenuMaker = function()
  local entries = {{title = "Docker", fn = function() hs.application.launchOrFocus("Kitematic (Beta)") end}}
  if dockerMachineExec("status") == "Stopped\n" or dmTask() then
    table.insert(entries, {title = "Start", fn = function() dmTask("start") end, disabled = dmTask()})
    return entries
  end

  local ipDocker = dockerMachineExec("ip"):gsub("%s+", "")
  table.insert(entries, {title = ipDocker, fn = function() pbcopy(ipDocker) end})

  local json, status = docker("ps -aq | xargs docker inspect")
  if status and json ~= "" then
    table.insert(entries, {title = "-"})
    local containers = hs.json.decode(json)

    hs.fnutils.each(containers, function(c)
        local name = c.Name:match("/(.*)")
        local running = c.State.Running
        local startStop = running and "Stop" or "Start"
        local ip = c.NetworkSettings.IPAddress
        local port = c.NetworkSettings.Ports and keys(c.NetworkSettings.Ports)[1]
        local addr = port and "http://"..ipDocker..":"..port:match("(%d*)")

        table.insert(entries, {title = name})
        table.insert(entries, {title = startStop, indent = 1, fn = function() docker(startStop.." "..name) end})
        if not running then
          table.insert(entries, {title = "Remove", indent = 1, fn = function() docker("rm "..name) end})
        else
          table.insert(entries, {title = ip, indent = 1, fn = function() pbcopy(ip) end})
          if port then table.insert(entries, {title = addr, indent = 1, fn = function() openURL(addr) end}) end
        end
      end)
  end

  table.insert(entries, {title = "-"})
  table.insert(entries, {title = "Stop", fn = function() dmTask("stop") end, disabled = dmTask()})

  return entries
end

local dockerIcon = hs.image.imageFromPath("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariCloud.icns")
module.menu = hs.menubar.new():setMenu(dockerMenuMaker):setIcon(dockerIcon:setSize({w=22,h=22}))

return module
