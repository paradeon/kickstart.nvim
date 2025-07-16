-- ########################################
-- Basic IME auto-switch for macOS + im-select
-- ########################################
--
local M = {}

local imselect_cmd = 'macism' -- for MacOSX
-- local imselect_cmd = 'im-select.exe' -- for Windows
local english_ime = 'com.apple.keylayout.USExtended' -- <- change me
-- local japanese_ime = "com.apple.inputmethod.Kotoeri.Hiragana" -- <- change me
-- local japanese_ime = "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese"
-- local cangjie_ime = "com.apple.inputmethod.TYIM.Cangjie"

-- helper: run im-select
local function im_select(id)
  vim.fn.system { imselect_cmd, id }
end

-- cache the IME that was active *before* Neovim gained focus
local prev_app_ime = nil

function M.setup()
  -- ---------- focus events ----------
  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      if 'n' == vim.api.nvim_get_mode().mode then
        -- when Neovim gains focus, remember current IME (whatever other app used)
        prev_app_ime = vim.fn.systemlist(imselect_cmd)[1]
        -- and force English for Normal mode
        im_select(english_ime)
      end
    end,
  })

  vim.api.nvim_create_autocmd('FocusLost', {
    callback = function()
      if 'n' == vim.api.nvim_get_mode().mode then
        -- when Neovim loses focus, restore whatever IME the *other* app had
        if prev_app_ime then
          im_select(prev_app_ime)
        end
      end
    end,
  })

  -- ---------- mode switches ----------
  -- enter Insert / Cmd-line / Terminal etc. → switch to Japanese
  vim.api.nvim_create_autocmd({
    'InsertEnter',
    -- 'CmdlineEnter',
    -- 'TermEnter',
  }, {
    callback = function()
      if prev_app_ime then
        im_select(prev_app_ime)
        -- im_select(japanese_ime)
      end
    end,
  })

  -- leave those modes → back to English (still inside Neovim)
  vim.api.nvim_create_autocmd({
    'InsertLeave',
    -- 'CmdlineLeave',
    -- 'TermLeave',
  }, {
    callback = function()
      prev_app_ime = vim.fn.systemlist(imselect_cmd)[1]
      im_select(english_ime)
    end,
  })
end

return M
