---@diagnostic disable
local xplr = xplr -- The globally exposed configuration to be overridden.
---@diagnostic enable

-- This is the built-in configuration file that gets loaded and sets the
-- default values when xplr loads, before loading any other custom
-- configuration file.
--
-- You can use this file as a reference to create a your custom config file.
--
-- To create a custom configuration file, you need to define the script version
-- for compatibility checks.
--
-- See https://xplr.dev/en/upgrade-guide
--
version = "0.17.3"


xplr.config.general.default_ui.prefix = " "
xplr.config.general.default_ui.suffix = ""

xplr.config.general.focus_ui.prefix = "▸"
xplr.config.general.focus_ui.suffix = ""
xplr.config.general.focus_ui.style.fg = { Rgb = { 192, 202, 245 } }
xplr.config.general.focus_ui.style.bg = { Rgb = { 51, 70, 124} }
xplr.config.general.focus_ui.style.add_modifiers = { "Bold" }

xplr.config.general.selection_ui.prefix = " "
xplr.config.general.selection_ui.suffix = ""
xplr.config.general.selection_ui.style.fg = { Rgb = { 70, 70, 70} }
xplr.config.general.selection_ui.style.add_modifiers = { "Bold", "CrossedOut" }

xplr.config.general.focus_selection_ui.prefix = "▸"
xplr.config.general.focus_selection_ui.suffix = ""
xplr.config.general.focus_selection_ui.style.fg = { Rgb = { 192, 202, 245 } }
xplr.config.general.focus_selection_ui.style.bg = { Rgb = { 51, 70, 124 } }
xplr.config.general.focus_selection_ui.style.add_modifiers = { "Bold", "CrossedOut" }

xplr.config.general.sort_and_filter_ui.separator.format = " » "
xplr.config.general.sort_and_filter_ui.separator.style.add_modifiers = { "Bold", "Reversed" }

xplr.config.general.panel_ui.default.title.style.bg = { Rgb = {187, 154, 247} }
xplr.config.general.panel_ui.default.title.style.fg = { Rgb = {40, 40, 40} }
xplr.config.general.panel_ui.default.title.style.add_modifiers = { "Bold" }
xplr.config.general.panel_ui.default.style.fg = { Rgb = { 192, 202, 245 } }
xplr.config.general.panel_ui.default.style.bg = { Rgb = { 26, 27, 38 } }
xplr.config.general.panel_ui.default.borders = {}
xplr.config.general.panel_ui.table.style.bg = { Rgb = { 21, 22, 30 } }

local home = os.getenv("HOME")

package.path = home
.. "/.config/xplr/plugins/?/init.lua;"
.. home
.. "/.config/xplr/plugins/?.lua;"
.. package.path
package.path = os.getenv("HOME") .. '/.config/xplr/plugins/?/src/init.lua'

require"icons".setup()
