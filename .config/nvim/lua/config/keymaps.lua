-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Function to extract first IP from text
local function extract_ip(text)
  local ip = text:match("^%s*([%d%.]+)")
  if ip and ip:match("^%d+%.%d+%.%d+%.%d+$") then
    return ip
  end
  return nil
end

-- Function to lookup IP location
local function lookup_ip_location()
  -- Get the text under cursor
  local line = vim.fn.getline(".")
  print("Found line: " .. line)

  local ip = extract_ip(line)
  if not ip then
    print("No IP address found under cursor")
    return
  end

  print("Looking up IP: " .. ip)

  -- Create temporary buffer for results
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 60,
    height = 10,
    row = 5,
    col = 10,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Loading location for " .. ip .. "..." })

  local response_chunks = {}
  local cmd = string.format('curl --max-time 5 -H "User-Agent: curl/7.64.1" -s http://ip-api.com/json/%s', ip)

  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data and #data > 0 then
        -- Collect all chunks
        for _, chunk in ipairs(data) do
          if chunk and chunk ~= "" then
            table.insert(response_chunks, chunk)
          end
        end
      end
    end,
    on_exit = function(_, _)
      -- Process complete response after all chunks received
      if #response_chunks > 0 then
        local json_str = table.concat(response_chunks)
        local ok, decoded = pcall(vim.fn.json_decode, json_str)

        if ok and decoded and decoded.status == "success" then
          local lines = {
            "IP: " .. ip,
            "Country: " .. (decoded.countryCode or "N/A"),
            "Region: " .. (decoded.regionName or "N/A"),
            "City: " .. (decoded.city or "N/A"),
            "ISP: " .. (decoded.isp or "N/A"),
            "Organization: " .. (decoded.org or "N/A"),
            "",
            "Press 'q' to close",
          }
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

          -- Highlight if not from Australia
          if decoded.countryCode ~= "AU" then
            vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 1, 8, -1)
          end
        else
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error: Invalid response from API" })
        end
      else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error: No response from API" })
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error: " .. table.concat(data) })
      end
    end,
  })

  -- Set up mappings for the floating window
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q", ":q<CR>", opts)
end

-- Add keybinding for IP lookup
vim.keymap.set("n", "<leader>ip", lookup_ip_location, {
  desc = "Lookup IP location under cursor",
})
