-- imgur upload from pasteboard

hs.hotkey.bind(hyper, "u", function()
    local image = hs.pasteboard.readImage()

    if image then
      local tempfile = "/tmp/tmp.png"
      image:saveToFile(tempfile)
      local b64 = hs.execute("base64 -i "..tempfile)
      b64 = hs.http.encodeForQuery(string.gsub(b64, "\n", ""))

      local url = "https://api.imgur.com/3/upload.json"
      local headers = {Authorization = "Client-ID "..hs.settings.get("imgurKey")}
      local payload = "type='base64'&image="..b64

      hs.http.asyncPost(url, payload, headers, function(status, body, headers)
          print(status, headers, body)
          if status == 200 then
            local response = hs.json.decode(body)
            local imageURL = response.data.link
            hs.urlevent.openURLWithBundle(imageURL, hs.urlevent.getDefaultHandler("http"))
          end
        end)
    end
  end)
