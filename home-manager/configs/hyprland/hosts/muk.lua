-- Development layout
local monzeyCodex = 'kitty --class monzey-codex --directory "$HOME/monzey" --hold codex'
local hostBindings = {
	agent = 'kitty --directory "$HOME/rg" --hold claude',
	ia = function()
		hl.dispatch(hl.dsp.focus({ workspace = "name:chatgpt" }))
		if #hl.get_workspace_windows("name:chatgpt") == 0 then
			hl.exec_cmd("chatgpt", { workspace = "name:chatgpt" })
		end
		hl.dispatch(hl.dsp.focus({ workspace = 4 }))
		if #hl.get_workspace_windows(4) == 0 then
			hl.exec_cmd(monzeyCodex, { workspace = "4" })
		end
	end,
	conf = hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/gh-dash-set.sh focus"),
	code = hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/gh-dash-set.sh claude"),
}

hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-6", mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-7", mode = "preferred", position = "3840x0", scale = 1 })
hl.monitor({ output = "DP-5", mode = "preferred", position = "5760x-420", scale = 1, transform = 1 })

hl.workspace_rule({ workspace = "1", default_name = "web", monitor = "DP-7" })
hl.workspace_rule({ workspace = "3", default_name = "slack", monitor = "DP-5" })
hl.workspace_rule({ workspace = "4", default_name = "ia", monitor = "DP-5" })
hl.workspace_rule({ workspace = "name:chatgpt", monitor = "DP-7" })
hl.workspace_rule({ workspace = "7", default_name = "debugger", monitor = "DP-6" })
hl.workspace_rule({ workspace = "8", default_name = "test", monitor = "DP-7" })
hl.workspace_rule({ workspace = "9", default_name = "conf", monitor = "DP-7" })
hl.workspace_rule({ workspace = "name:rg-claude", monitor = "DP-5" })
hl.workspace_rule({ workspace = "10", default_name = "monitor", monitor = "DP-6" })
hl.workspace_rule({ workspace = "name:agent", monitor = "DP-7" })

hl.window_rule({
	name = "muk-chatgpt-workspace",
	match = { class = "chatgpt" },
	workspace = "name:chatgpt silent",
})

hl.window_rule({
	name = "rg-claude-shortcuts",
	match = { class = "rg-claude" },
	no_shortcuts_inhibit = true,
})

hl.on("hyprland.start", function()
	hl.exec_cmd("[workspace 3 silent] slack")
	hl.exec_cmd("[workspace 4 silent] " .. monzeyCodex)
	hl.exec_cmd("[workspace name:chatgpt silent] chatgpt")
	hl.exec_cmd("[workspace 9 silent] kitty --class gh-dash -e gh dash")
end)
