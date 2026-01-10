-- quality-cycle.lua
-- Cycles video quality and reloads the stream
-- Keys: 'q' to cycle

local utils = require 'mp.utils'
local msg = require 'mp.msg'

local QUALITY_FILE = "/tmp/yt-bg-quality"
local qualities = {
    "1080p",
    "720p",
    "480p",
    "best"
}

-- Map quality names to ytdl-format strings
local formats = {
    ["best"] = "bestvideo+bestaudio/best",
    ["1080p"] = "bestvideo[height<=1080]+bestaudio/best[height<=1080]",
    ["720p"] = "bestvideo[height<=720]+bestaudio/best[height<=720]",
    ["480p"] = "bestvideo[height<=480]+bestaudio/best[height<=480]"
}

-- Get current quality from file or default
local function get_current_quality()
    local f = io.open(QUALITY_FILE, "r")
    if f then
        local content = f:read("*all")
        f:close()
        -- Trim whitespace
        content = content:gsub("%s+", "")
        for _, q in ipairs(qualities) do
            if q == content then return q end
        end
    end
    return "1080p" -- Default
end

-- Save quality to file
local function save_quality(q)
    local f = io.open(QUALITY_FILE, "w")
    if f then
        f:write(q)
        f:close()
    end
end

-- Cycle to next quality
local function cycle_quality()
    local current = get_current_quality()
    local next_q = "1080p"

    -- Find current index
    for i, q in ipairs(qualities) do
        if q == current then
            local next_index = (i % #qualities) + 1
            next_q = qualities[next_index]
            break
        end
    end

    msg.info("Switching quality to " .. next_q)
    mp.osd_message("Switching to " .. next_q, 2)

    -- Save preference
    save_quality(next_q)

    -- Apply format
    local fmt = formats[next_q]
    if fmt then
        mp.set_property("ytdl-format", fmt)

        -- Reload stream at current position
        local pos = mp.get_property_number("time-pos")
        local url = mp.get_property("path")

        if url then
            -- We use loadfile with start position
            -- mp.commandv("loadfile", url, "replace", "start=" .. tostring(pos))
            -- Note: reloading might be slightly abrupt, but it's necessary to change the stream
            mp.command("seek " .. tostring(pos) .. " absolute")
            mp.commandv("loadfile", url, "replace", "start=" .. tostring(pos))
        end
    end
end

-- Bind 'Alt+Shift+Q' key
mp.add_key_binding("Alt+Shift+Q", "cycle-quality", cycle_quality)
