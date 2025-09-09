-- rotate-and-save.lua
-- Rota la imagen con r / R y guarda automáticamente la copia rotada

local utils = require "mp.utils"

-- función para guardar con la rotación indicada
function save_rotated(path, rotate)
    local dir, filename = utils.split_path(path)
    local outfile = utils.join_path(dir, filename)

    local vf = ""
    if rotate == 90 then
        vf = "transpose=1"
    elseif rotate == -90 or rotate == 270 then
        vf = "transpose=2"
    elseif rotate == 180 or rotate == -180 then
        vf = "transpose=2,transpose=2"
    end

    if vf ~= "" then
        local args = {
            "ffmpeg", "-y", "-i", path,
            "-vf", vf,
            outfile
        }
        utils.subprocess({ args = args })
        mp.osd_message("Saved rotation!")
    else
        mp.osd_message("No rotation applied, nothing to save.")
    end
end

-- rotar + guardar
function rotate_and_save(delta)
    local path = mp.get_property("path")
    local current = mp.get_property_number("video-rotate", 0)
    local new = (current + delta) % 360
    mp.set_property_number("video-rotate", new)
    save_rotated(path, new)
end

-- atajos de teclado
mp.add_key_binding("r", "rotate-clockwise", function() rotate_and_save(90) end)
mp.add_key_binding("R", "rotate-counter",  function() rotate_and_save(-90) end)

