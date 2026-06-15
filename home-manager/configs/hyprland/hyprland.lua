-- Hyprland config — Lua (0.55+)
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-6", mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-7", mode = "preferred", position = "3840x0", scale = 1 })
hl.monitor({ output = "DP-5", mode = "preferred", position = "5760x-420", scale = 1, transform = 1 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "nnn"
local menu = "launch"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("eww daemon")
	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprctl setcursor Bibata 24")
	hl.exec_cmd("watch-dev-sets")
	hl.exec_cmd("[workspace 1 silent] firefox")
	hl.exec_cmd("[workspace 4 silent] firefox --no-remote -P chatgpt https://chatgpt.com")
	hl.exec_cmd("[workspace 8 silent] firefox-devedition https://dashboard.rg-supervision.local --devtools")
	hl.exec_cmd("[workspace 10 silent] " .. terminal .. " btop")
	hl.exec_cmd("[workspace 3 silent] slack")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 0,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 0.8,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},

	ecosystem = {
		no_update_news = true,
	},
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "fr",
		kb_options = "",
		kb_variant = "",
		kb_model = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Neovide / project workflow
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("openvide new"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("update-with-notifications"))

-- Basic
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code /home/monzey/bonsly"))

-- Move focus (azerty-friendly: J=left M=right L=up K=down)
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + M", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces
hl.bind(mainMod .. " + CTRL + J", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + N", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + CTRL + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/debug-focus.sh"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.focus({ workspace = 10 }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "up" }))

-- Move active window to workspace
for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness (repeating + locked)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Custom
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))
hl.bind(mainMod .. " + CTRL + O", hl.dsp.exec_cmd("openvide switch"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Workspace rules
hl.workspace_rule({ workspace = "1", default_name = "web", monitor = "DP-7" })
hl.workspace_rule({ workspace = "3", default_name = "slack", monitor = "DP-5" })
hl.workspace_rule({ workspace = "4", default_name = "ia", monitor = "DP-5" })
hl.workspace_rule({ workspace = "7", default_name = "debugger", monitor = "DP-7" })
hl.workspace_rule({ workspace = "8", default_name = "test", monitor = "DP-7" })
hl.workspace_rule({ workspace = "9", default_name = "conf", monitor = "DP-7" })
hl.workspace_rule({ workspace = "10", default_name = "monitor", monitor = "DP-6" })

-- Window rules
hl.window_rule({
	match = { title = "fzf-float" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { class = "firefox-devedition", title = "Developer Tools" },
	workspace = "7 silent",
})

hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})
