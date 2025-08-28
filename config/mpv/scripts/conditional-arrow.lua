-- Description: Left/Right arrow keys seek in video, but go to previous/next item in playlist if at start/end of video or if it's an image.
function on_left()
    local time_pos = mp.get_property_number("time-pos", 0)
    local duration = mp.get_property_number("duration", 0)

    -- no duration → it's an image
    if duration == 0 then
        mp.command("playlist-prev")
        return
    end

    -- if at the start of a video, go previous
    if time_pos <= 1 then
        mp.command("playlist-prev")
    else
        mp.command("seek -5")
    end
end

function on_right()
    local duration = mp.get_property_number("duration", 0)

    -- no duration → it's an image
    if duration == 0 then
        mp.command("playlist-next")
        return
    end

    mp.command("seek 5")
end

mp.add_key_binding("LEFT", "conditional-left", on_left)
mp.add_key_binding("RIGHT", "conditional-right", on_right)

