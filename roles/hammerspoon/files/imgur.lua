-- imgur upload from pasteboard

hs.hotkey.bind(hyper, "u", function()
    local image = hs.pasteboard.readImage()

    if image then
      image:saveToFile("/tmp/tmp.png")
      local b64 = hs.execute("base64 -i /tmp/tmp.png")
      b64 = hs.http.encodeForQuery(string.gsub(b64, "\n", ""))

      local url = "https://api.imgur.com/3/upload.json"
      local headers = {["Authorization"] = "Client-ID d0a36d57e01999e"}
      local payload = "type='base64'&image="..b64

      hs.http.asyncPost(url, payload, headers, function(status, body, headers)
          print(status)
          print(body)
          if status == 200 then
            local response = hs.json.decode(body)
            local imageURL = response.data.link
            hs.pasteboard.setContents(imageURL)
            hs.urlevent.openURLWithBundle(imageURL, "com.apple.Safari")
          end
        end)
    end
  end)
