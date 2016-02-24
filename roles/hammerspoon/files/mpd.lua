local mpd = {}

mpd.logger = hs.logger.new("mpd")
mpd.setLogLevel = mpd.logger.setLogLevel
local logger = mpd.logger

local fmt = string.format
local icon = require "asciicons"

local queue = function(t, i) table.insert(t, i) end
local dequeue = function(t) return table.remove(t, 1) end

local FIRSTLINE = 0
local DEBUG = -2

local function mpdMenuDisplay()
  mpdMenuPlayPause:setIcon(mpd.status.state == "play" and icons.pause or icons.play)

  local currentTooltip = (mpd.track.current.Artist and mpd.track.current.Artist.." - " or "")..(mpd.track.current.Title or "-")
  mpdMenuPlayPause:setTooltip(currentTooltip)
  mpdMenuNext:setTooltip(mpd.track.next and mpd.track.next.Title or "")

  if mpd.status.state == "play" and not mpd.track.current.Title then
    hs.timer.doAfter(0.2, mpd.updateStatus)
  end
end

tableMerge(mpd, {
  host ="localhost",
  port = 6600,
  delimiter = "OK\n",
  currentTags = {},
  mpdError = nil,
  buffer = nil,
  parsed = nil,
  status = {},
  track = {},
  albums = {},
  socket = hs.socket.new(),

  connect = function() 
    logger.i("connecting...")
    mpd.socket:setCallback(mpd.readCallback):connect(mpd.host, mpd.port)
    mpd.read(mpd.tag("CONNECT"))
  end,

  disconnect = function()
    logger.i("disconnecting...")
    mpd.socket:disconnect() 
  end,

  send = function(cmd)
    if not mpd.socket:connected() then mpd.connect() end
    logger.i("sending command: ", cmd)
    mpd.socket:write(cmd.."\n")
  end,

  read = function(tag)
    tag = tag or mpd.tag("OK") 
    logger.i("reading with tag", tag)
    mpd.buffer = {}
    queue(mpd.currentTags, tag)
    mpd.socket:read("\n", FIRSTLINE)
  end,

  sendrecv = function(cmd, tag)
    mpd.send(cmd)
    mpd.read(tag)
  end,

  checkError = function(data)
    if data:find("^ACK") then
      mpd.mpdError = data
      hs.alert("MPD Error:\n\n"..data)
      local tag = dequeue(mpd.currentTags)
      logger.e("tag failed: ", mpd.tags[tag])
      return true
    end
    return false
  end,

  readCallback = function(data, tag)
    logger.i("tag", tag, mpd.tags[tag])
    logger.i("queued tags: ", hs.inspect(hs.fnutils.mapCat(mpd.currentTags, function(t) return {mpd.tags[t]} end)))

    if mpd.checkError(data) then return end
    if tag == DEBUG then print("DEBUG:\n", data); return end

    if tag == FIRSTLINE then
      local t = dequeue(mpd.currentTags)
      if t == mpd.tag("CONNECT") then
        mpd.tagReaders[mpd.tags[t]].fn(data)
      elseif data == mpd.delimiter then
        mpd.tagReaders[mpd.tags[t]].fn(data)
      else
        mpd.firstLine = data
        mpd.socket:read(mpd.delimiter, t)
      end
      return
    end

    data = mpd.firstLine..data
    if not data:find("\nOK\n$") then
      mpd.firstLine = data
      mpd.socket:read(mpd.delimiter, tag)
    end

    local t = mpd.tags[tag]
    local tagReader = mpd.tagReaders[t]

    local _, _, output = data:find("(.*)"..mpd.delimiter.."$")
    output = output:sub(1, #output - 1)

    local buffer = hs.fnutils.split(output, "\n") or nil
    mpd.buffer = buffer
    local parsed = mpd.parseBuffer(tagReader.form, mpd.buffer)
    mpd.parsed = parsed
    tagReader.fn(parsed)
  end,

  parseBuffer = function(rform, buf)
    if rform == "table" or rform == "list" then
      local t = {}
      for _,line in ipairs(buf) do
        local k, v = line:match("(.-): (.*)")
        if k and v then
          if rform == "table" then t[k] = v else t[#t+1] = v end
        end
      end
      res = t
    elseif rform == "table-list" then
      local ts, t = {}, {}
      for _,line in ipairs(buf) do
        local k, v = line:match("(.-): (.*)")
        if k and v then
          if t[k] then ts[#ts+1] = t; t = {} end
          t[k] = v
        end
      end
      ts[#ts+1] = t
      res = ts
    elseif rform == "line" then
      res = table.concat(buf, "\n")
    else
      return false, ("match failed: " .. rform)
    end
    return res
  end,
})

mpd.tagReaders = {
  CONNECT = { form = "line", fn = function(data) logger.i("CONNECTED: "..data) end },
  OK = { form = "line", fn = function(data) logger.i(data) end },
  PLAYID = { form = "table", fn = function(data)
    logger.i("playing id: ", data)
    mpd.playid(data.Id)
    end 
  },
  STATUS = { form = "table", fn = function(data)
    mpd.status = data
    mpd.currentsong()
    mpd.nextsong()
    end
  },
  CURRENTSONG = { form = "table", fn = function(data)
    if type(mpd.track.current) == "table" and type(data) == "table" and not tableCompare(data, mpd.track.current) then
      hs.notify.show(data.Title or "", "", data.Artist and data.Artist or data.Name and data.Name or "", "")
    end
    mpd.track.current = data
    end
  },
  NEXTSONG = { form = "table", fn = function(data)
    mpd.track.next = data
    end
  },
  SEARCH = { form = "table-list", fn = function(data)
    searchChooser:choices(makeChoicesFromTracks(data))
    end
  },
  PLAYLISTSEARCH = { form = "table-list", fn = function(data)
    searchChooser:choices(makeChoicesFromTracks(data))
    end
  },
  PLAYLISTINFO = { form = "table-list", fn = function(data)
    searchChooser:choices(makeChoicesFromTracks(data))
    end
  },
  LISTALBUMARTIST = { form = "table-list", fn = function(data)
    albumChooser:choices(makeChoicesFromAlbums(data))
    end
  },
}

mpd.tags = tableKeys(mpd.tagReaders)
mpd.tag = function(tag) return hs.fnutils.indexOf(mpd.tags, tag) end
local tag = mpd.tag

hs.fnutils.each({
  "play",
  "pause",
  "next",
  "previous",
  "stop",
  "clear",
  "shuffle",
  "ping",
 }, function(item)
  mpd[item] = function() mpd.sendrecv(item) end
end)

mpd.command = function(cmd, tag) mpd.sendrecv(cmd, tag) end
mpd.debug = function(cmd) mpd.send(cmd); mpd.socket:read("\n", DEBUG) end

mpd.currentsong = function()
  mpd.sendrecv("currentsong", tag("CURRENTSONG"))
end

mpd.getstatus = function()
  mpd.sendrecv("status", tag("STATUS"))
end

mpd.playlistinfo = function(starting, ending)
  mpd.sendrecv("playlistinfo", tag("PLAYLISTINFO"))
end

mpd.search = function(str, kind)
  kind = kind or "any"
  mpd.sendrecv(fmt("search %q %q", kind, str), tag("SEARCH"))
end

mpd.playlistsearch = function(str)
  kind = kind or "any"
  mpd.sendrecv(fmt("playlistsearch %q %q", kind, str), tag("PLAYLISTSEARCH"))
end

mpd.findadd = function(str, kind)
  kind = kind or "any"
  mpd.sendrecv(fmt("findadd %q %q", kind, str))
end

mpd.listalbumartist = function()
  mpd.sendrecv("list album group artist", tag("LISTALBUMARTIST"))
end

mpd.addid = function(file)
  mpd.sendrecv(fmt("addid %q", file))
end

mpd.addplayid = function(file)
  mpd.sendrecv(fmt("addid %q", file), tag("PLAYID"))
end

mpd.nextsong = function()
  if not mpd.status.nextsong then mpd.track.next = nil; return end
  mpd.sendrecv("playlistinfo "..mpd.status.nextsong, tag("NEXTSONG"))
end

mpd.playid = function(id)
  mpd.sendrecv(fmt("playid %d", id))
  mpd.updateStatus()
end

mpd.updateStatus = function()
  mpd.getstatus()
  hs.timer.doAfter(0.2, mpdMenuDisplay)
end


function makeChoicesFromTracks(tracks)
  return hs.fnutils.imap(tracks, function(track) 
    return {
      text = track.Title or track.Name,
      subText = (track.Artist and track.Artist or "")..(track.Album and " - "..track.Album or ""),
      image = track.file and hs.image.iconForFile((track.file and "~/Music/"..track.file) or "") or nil,
      file = (track.file and track.file or ""),
      Id = track.Id or nil
    }
  end)
end

function makeChoicesFromAlbums(albums)
  return hs.fnutils.imap(albums, function(album) 
    return {
      text = album.Album,
      subText = album.Artist,
      -- image = hs.image.iconForFile((track.file and "~/Music/"..track.file) or ""),
      -- file = (track.file and track.file or ""),
      -- Id = track.Id or nil
      album = album.Album,

    }
  end)
end

local function playChoice(choice)
  if choice.Id then 
    mpd.playid(choice.Id) 
  elseif choice.file then
    mpd.addplayid(choice.file)
  elseif choice.album then
    mpd.findadd(choice.album, "album")
  end
end

searchChooser=hs.chooser.new(playChoice):width(30):searchSubText(true):queryChangedCallback(function(query)
    if #query >= 2 and query:sub(1,2) == "!p" then
      local _, _, q = query:find("^!p(.*)")
      mpd.playlistsearch(q) 
      return
    end
    if #query > 2 then mpd.search(query) end
  end)
hs.hotkey.bind(hyper, "p", function() searchChooser:show() end)

albumChooser=hs.chooser.new(function(choice) mpd.findadd(choice.album, "album") end):width(30):searchSubText(true)
hs.hotkey.bind(hyper, "a", function() albumChooser:show() end)

-- menubars
mpdMenuNext = hs.menubar.new():setIcon(icons.next):setClickCallback(function()
    mpd.next()
    mpd.updateStatus()
  end)
mpdMenuPlayPause = hs.menubar.new():setClickCallback(function()
    if mpd.status.state == "stop" then mpd.play() else mpd.pause() end
    mpd.updateStatus()
  end)
mpdMenuPrev = hs.menubar.new():setIcon(icons.prev):setClickCallback(function()
    mpd.previous()
    mpd.updateStatus()
  end)

mpdMenu = hs.menubar.new():setTitle("🎵"):setMenu({
  { title = "Music Player Daemon", fn = function() print("you clicked my menu item!") end },
  { title = "-" },
  { title = "play", fn = mpd.play },
  { title = "shuffle", fn = mpd.shuffle },
  { title = "stop", fn = mpd.stop },
  { title = "clear", fn = mpd.clear },
  { title = "-" },
  { title = "SomaFM" },
  { title = "beatblender", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/beatblender-128-mp3") end },
  { title = "bootliquor", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/bootliquor-128-mp3") end },
  { title = "brfm", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/brfm-128-mp3") end },
  { title = "cliqhop", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/cliqhop-128-mp3") end },
  { title = "covers", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/covers-128-mp3") end },
  { title = "digitalis", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/digitalis-128-mp3") end },
  { title = "doomed", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/doomed-128-mp3") end },
  { title = "dronezone", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/dronezone-128-mp3") end },
  { title = "dubstep", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/dubstep-128-mp3") end },
  { title = "groovesalad", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/groovesalad-128-mp3") end },
  { title = "illstreet", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/illstreet-128-mp3") end },
  { title = "indiepop", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/indiepop-128-mp3") end },
  { title = "lush", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/lush-128-mp3") end },
  { title = "missioncontrol", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/missioncontrol-128-mp3") end },
  { title = "poptron", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/poptron-128-mp3") end },
  { title = "secretagent", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/secretagent-128-mp3") end },
  { title = "sf1033", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/sf1033-128-mp3") end },
  { title = "sonicuniverse", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/sonicuniverse-128-mp3") end },
  { title = "spacestation", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/spacestation-128-mp3") end },
  { title = "suburbsofgoa", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/suburbsofgoa-128-mp3") end },
  { title = "thetrip", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/thetrip-128-mp3") end },
  { title = "u80s", indent = 1, fn = function() mpd.addplayid("http://ice1.somafm.com/u80s-128-mp3") end },
})

hs.timer.doAfter(1, mpd.updateStatus)
hs.timer.doAfter(2, mpd.listalbumartist)

statusTimer = hs.timer.doEvery(10, mpd.updateStatus)

return mpd
