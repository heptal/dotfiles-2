-- manage docker stuff

local docker = {}
local fmt = string.format
local keys = std.table.keys
local pbcopy = hs.pasteboard.setContents
local openURL = function(addr) hs.urlevent.openURLWithBundle(addr, hs.urlevent.getDefaultHandler("http")) end
local env = "PATH=/usr/local/bin/:$PATH; eval $(docker-machine env default);"
local dockerExec = function(arg) return hs.execute(env.."docker "..arg) end

dockerMenuMaker = function()
  local ipDocker, status = hs.execute(env.."docker-machine ip")
  if not status then docker.menu:delete(); return end

  ipDocker = ipDocker:gsub("%s+", "")
  local entries = {{title = "Docker", fn = function() hs.application.launchOrFocus("Kitematic (Beta)") end}}
  table.insert(entries, {title = ipDocker, fn = function() pbcopy(ipDocker) end})

  local json, status = dockerExec("ps -aq | xargs docker inspect")
  print(json)

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
        table.insert(entries, {title = startStop, indent = 1, fn = function() dockerExec(startStop.." "..name) end})
        if not running then
          table.insert(entries, {title = "Remove", indent = 1, fn = function() dockerExec("rm "..name) end})
        else
          table.insert(entries, {title = ip, indent = 1, fn = function() pbcopy(ip) end})
          if port then table.insert(entries, {title = addr, indent = 1, fn = function() openURL(addr) end}) end
        end
      end)
  end

  return entries
end

local dockerIcon = hs.image.imageFromPath("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariCloud.icns")
docker.menu = hs.menubar.new():setMenu(dockerMenuMaker):setIcon(dockerIcon:setSize({w=22,h=22}))

return docker
