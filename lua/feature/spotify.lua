-- File: lua/custom_status.lua
-- (e.g., ~/.config/nvim/lua/custom_status.lua)

local M = {}

-- Default status texts
local spotify_status_text = "Spotify: N/A"
local uname = vim.trim(vim.fn.system('uname'));

-- Default configuration
local config = {
    -- This command should output the current playing song (e.g., "Artist Name - Song Title")
    -- OR a string indicating Spotify is paused/not running (e.g., "Paused", "Not Playing", "Spotify Not Running").
    -- Example (placeholder - does nothing useful): "echo 'Spotify: Paused'"
    spotify_check_command = {
      Darwin = {
        'osascript',
        '-e',
        [[tell application "Spotify"
          if it is running then
            if player state is playing then
              "Playing: " & artist of current track & " - " & name of current track
            else
              "Paused: " & artist of current track & " - " & name of current track
            end if
          else
            "Not Running"
          end if
        end tell]]
      }
    },

    spotify_refresh_interval = 1000, -- milliseconds (e.g., 30000 for 30 seconds)
    spotify_icons = {
      spotify = "󰓇",
      playing = "", -- nf-fa-play
      paused = "", -- nf-fa-pause
    },
    notify_on_new_mail = true, -- Set to false to disable vim.notify for new mail
}

-- Function to update Spotify status
local function check_spotify()
    vim.system(config.spotify_check_command[uname], { text = true, shell = true }, vim.schedule_wrap(function(obj)
        if obj.code == 0 and obj.stdout then
            local track_info = vim.trim(obj.stdout)
            if track_info == "" or
               track_info:lower():find("not playing") or
               track_info:lower():find("not running") or
               track_info:lower():find("no player") then
                spotify_status_text = string.format("%s Paused/Off", config.spotify_icons.spotify)
            else
                -- Truncate if too long
                local max_len = 40
                track_info = track_info:gsub("Playing:", config.spotify_icons.playing)
                track_info = track_info:gsub("Paused:", config.spotify_icons.paused)
                if #track_info > max_len then
                    track_info = track_info:sub(1, max_len - 3) .. "..."
                end
                spotify_status_text = string.format("%s %s", config.spotify_icons.spotify, track_info)
            end
        else
            spotify_status_text = string.format("%s Err/Off", config.spotify_icons.spotify)
            if obj.stderr and obj.stderr ~= "" then
                -- Don't spam notifications if spotify is just off, but log error if command fails
                -- vim.notify("Spotify check error: " .. vim.trim(obj.stderr), vim.log.levels.WARN, { title = "Spotify Status" })
                print("Spotify check error: " .. vim.trim(obj.stderr))
            -- else
                -- vim.notify("Spotify check command failed or Spotify not running. Code: " .. obj.code, vim.log.levels.WARN, { title = "Spotify Status" })
            end
        end
        --vim.cmd("redrawstatus!") -- Request statusline redraw
    end))
end

-- Main setup function
function M.setup(user_config)
    if user_config then
        config = vim.tbl_deep_extend("force", config, user_config)
    end

    -- Ensure shell is available for vim.system if commands need it
    if vim.fn.executable("bash") == 1 then
        -- Potentially set vim.o.shell if needed, though vim.system with shell=true should handle it
    elseif vim.fn.executable("sh") == 1 then
        -- fallback
    else
        vim.notify("No suitable shell found for status commands.", vim.log.levels.ERROR, {title = "Status Setup"})
        -- return -- Or handle this more gracefully
    end


    if config.spotify_check_command[uname] then
      -- Spotify checker timer
      local spotify_timer = vim.uv.new_timer()
      if spotify_timer then
          spotify_timer:start(3000, config.spotify_refresh_interval, vim.schedule_wrap(check_spotify)) -- Start after 3s, then repeat
      else
          vim.notify("Failed to create Spotify timer.", vim.log.levels.ERROR, {title = "Status Setup"})
      end


      -- Stop timers on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
          pattern = "*",
          callback = function()
              if spotify_timer and not spotify_timer:is_closed() then
                  spotify_timer:stop()
                  spotify_timer:close()
              end
          end,
      })
    end

    vim.notify("Custom status integrations loaded.", vim.log.levels.INFO, {title = "Status Setup"})
end

-- Function to get Spotify status for statusline
function M.get_spotify_status()
    return spotify_status_text
end

return M

