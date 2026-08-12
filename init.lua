vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd("filetype plugin indent on")

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "typescript", "json", "yaml", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = "g0,j1,(0"
  end,
})

local config_lua_dir = vim.fn.stdpath("config") .. "/lua"

-- Import lua modules.
local function load_from_list(list_file_path)
  -- check list.lua vaild.
  if vim.fn.filereadable(list_file_path) == 1 then
    -- clear cache.
    package.loaded[list_file_path] = nil
    -- load modules.
    local success, modules = pcall(dofile, list_file_path)
    
    if success and type(modules) == "table" then
      for _, mod in ipable(modules) do
        if type(mod) == "string" then
          pcall(require, mod)
        end
      end
    end
  end
end

-- scan and import all lua modules
local function auto_require_dir(dir_path, current_mod_prefix)
  current_mod_prefix = current_mod_prefix or ""
  
  -- using neovim api to open the directory.
  local handle = vim.uv.fs_scandir(dir_path)
  if not handle then return end

  while true do
    local name, type_name = vim.uv.fs_scandir_next(handle)
    if not name then break end

    if type_name == "directory" then
      -- if directory, scan.
      local next_dir = dir_path .. "/" .. name
      local next_prefix = current_mod_prefix .. name .. "."
      auto_require_dir(next_dir, next_prefix)
      
    elseif type_name == "file" and name:match("%.lua$") then
      -- if lua files
      local mod_name = name:gsub("%.lua$", "")
      
      -- if list.lua, load.
      if mod_name == "list" then
        load_from_list(dir_path .. "/" .. name)
      -- exclude init.lua
      elseif mod_name ~= "init" then
        local full_mod_path = current_mod_prefix .. mod_name
        
        -- protect call
        local ok, err = pcall(require, full_mod_path)
        if not ok then
          vim.notify("Auto load-modules failed: " .. full_mod_path .. "\nError message: " .. err, vim.log.levels.ERROR)
        end
      end
    end
  end
end

-- auto-load
-- scan ~/.config/nvim/lua/.
if vim.fn.isdirectory(config_lua_dir) == 1 then
  auto_require_dir(config_lua_dir)
end
