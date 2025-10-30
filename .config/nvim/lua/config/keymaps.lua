-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Function to extract IPs from text (single IP or range)
local function extract_ips(text)
  -- Match an IP range (format: IP1-IP2)
  local ip1, ip2 = text:match("([%d%.]+)%-([%d%.]+)")

  if ip1 and ip2 and ip1:match("^%d+%.%d+%.%d+%.%d+$") and ip2:match("^%d+%.%d+%.%d+%.%d+$") then
    return { ip1, ip2 }
  end

  -- If not a range, try to match a single IP
  local ip = text:match("([%d%.]+)")
  if ip and ip:match("^%d+%.%d+%.%d+%.%d+$") then
    return { ip }
  end

  return nil
end

-- Function to lookup IP location
local function lookup_ip_location()
  -- Get the text under cursor
  local line = vim.fn.getline(".")
  print("Found line: " .. line)

  local ips = extract_ips(line)
  if not ips then
    print("No IP address found under cursor")
    return
  end

  -- Debug: show which IPs were found
  print("Found IPs:", vim.inspect(ips))

  -- Create temporary buffer for results
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 60,
    height = #ips > 1 and 20 or 10,
    row = 5,
    col = 10,
    style = "minimal",
    border = "rounded",
  })

  local loading_msg = #ips > 1 and ("Loading location for " .. ips[1] .. " and " .. ips[2] .. "...")
    or ("Loading location for " .. ips[1] .. "...")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { loading_msg })

  -- Function to lookup a single IP and return results
  local function lookup_single_ip(ip, callback)
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
            }
            callback({
              lines = lines,
              is_au = decoded.countryCode == "AU",
              valid = true,
            })
          else
            callback({
              lines = { "Error: Invalid response from API for " .. ip },
              valid = false,
            })
          end
        else
          callback({
            lines = { "Error: No response from API for " .. ip },
            valid = false,
          })
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          callback({
            lines = { "Error: " .. table.concat(data) .. " for " .. ip },
            valid = false,
          })
        end
      end,
    })
  end

  -- Process IPs sequentially
  local all_lines = {}
  local highlight_lines = {}
  local current_index = 1

  local function process_next_ip()
    if current_index > #ips then
      -- All IPs processed, finalize the output
      table.insert(all_lines, "")
      table.insert(all_lines, "Press 'q' to close")

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)

      -- Apply highlights for non-AU IPs
      for _, hl in ipairs(highlight_lines) do
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", hl.line, 8, -1)
      end
      return
    end

    local ip = ips[current_index]
    current_index = current_index + 1

    -- Add a separator if this isn't the first IP
    if #all_lines > 0 then
      table.insert(all_lines, "")
      table.insert(all_lines, "----------------")
      table.insert(all_lines, "")
    end

    -- Update buffer with loading message for current IP
    table.insert(all_lines, "Loading data for " .. ip .. "...")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)

    -- Remove the loading message when we get results
    all_lines[#all_lines] = nil

    lookup_single_ip(ip, function(result)
      -- Process result for this IP
      local start_line = #all_lines + 1

      for _, line in ipairs(result.lines) do
        table.insert(all_lines, line)
      end

      if result.valid and not result.is_au then
        table.insert(highlight_lines, { line = start_line })
      end

      -- Update buffer with current results
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)

      -- Highlight any non-AU countries
      for _, hl in ipairs(highlight_lines) do
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", hl.line, 8, -1)
      end

      -- Process next IP and add delay between requests
      vim.defer_fn(process_next_ip, 300)
    end)
  end

  -- Start processing the first IP
  process_next_ip()

  -- Set up mappings for the floating window
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q", ":q<CR>", opts)
end

-- Add keybinding for realpath current file
vim.keymap.set("n", "<leader>rp", function()
  print(vim.fn.expand("%:p"))
end, { desc = "Show realpath of current file" })

-- Add keybinding for IP lookup
vim.keymap.set("n", "<leader>ip", lookup_ip_location, {
  desc = "Lookup IP location under cursor",
})
