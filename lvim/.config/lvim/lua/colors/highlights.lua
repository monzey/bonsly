local cmd = vim.cmd

-- Highlights functions

-- Define bg color
-- @param group Group
-- @param color Color

local bg = function(group, col)
   cmd("hi " .. group .. " guibg=" .. col)
end

-- Define fg color
-- @param group Group
-- @param color Color
local fg = function(group, col)
   cmd("hi " .. group .. " guifg=" .. col)
end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
local fg_bg = function(group, fgcol, bgcol)
   cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

local colors = {
   white = "#D9E0EE",
   darker_black = "#191828",
   black = "#1E1D2D", --  nvim bg
   black2 = "#252434",
   one_bg = "#282737", -- real bg of onedark
   one_bg2 = "#313040",
   one_bg3 = "#393848",
   grey = "#424151",
   grey_fg = "#494858",
   grey_fg2 = "#504f5f",
   light_grey = "#585767",
   red = "#F28FAD",
   baby_pink = "#ffa5c3",
   pink = "#F5C2E7",
   line = "#2a2e36", -- for lines like vertsplit
   green = "#ABE9B3",
   vibrant_green = "#b6f4be",
   nord_blue = "#8bc2f0",
   blue = "#96CDFB",
   yellow = "#FAE3B0",
   sun = "#ffe9b6",
   purple = "#DDB6F2",
   dark_purple = "#d5aeea",
   teal = "#B5E8E0",
   orange = "#F8BD96",
   cyan = "#89DCEB",
   statusline_bg = "#232232",
   lightbg = "#2f2e3e",
   lightbg2 = "#282737",
   pmenu_bg = "#ABE9B3",
   folder_bg = "#96CDFB",
}

-- local cmd = vim.cmd

-- local override = require("core.utils").load_config().ui.hl_override
-- local colors = require("colors").get()
-- local ui = require("core.utils").load_config().ui

-- functions for setting highlights
-- local fg = require("core.utils").fg
-- local fg_bg = require("core.utils").fg_bg
-- local bg = require("core.utils").bg

-- Telescope
local hiTel = function ()
  fg_bg("TelescopeBorder", colors.darker_black, colors.darker_black)
  fg_bg("TelescopePromptBorder", colors.black2, colors.black2)

  fg_bg("TelescopePromptNormal", colors.white, colors.black2)
  fg_bg("TelescopePromptPrefix", colors.red, colors.black2)

  bg("TelescopeNormal", colors.darker_black)

  fg_bg("TelescopePreviewTitle", colors.black, colors.green)
  fg_bg("TelescopePromptTitle", colors.black, colors.red)
  fg_bg("TelescopeResultsTitle", colors.darker_black, colors.darker_black)

  bg("TelescopeSelection", colors.black2)
end

return hiTel
