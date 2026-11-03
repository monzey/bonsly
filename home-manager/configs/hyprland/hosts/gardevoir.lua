-- Home layout: DP-2 on the left, DP-1 on the right.
hl.monitor({ output = "DP-1", mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })

hl.workspace_rule({ workspace = "1", default_name = "web", monitor = "DP-2" })
hl.workspace_rule({ workspace = "3", default_name = "vesktop", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", default_name = "ia", monitor = "DP-1" })
hl.workspace_rule({ workspace = "7", default_name = "debugger", monitor = "DP-1" })
hl.workspace_rule({ workspace = "8", default_name = "test", monitor = "DP-2" })
hl.workspace_rule({ workspace = "9", default_name = "conf", monitor = "DP-2" })
hl.workspace_rule({ workspace = "10", default_name = "monitor", monitor = "DP-1" })

-- Steam starts its UI in a child process; keep its windows on the IA workspace.
hl.window_rule({
	name = "gardevoir-steam",
	match = { class = "(steam|Steam)" },
	workspace = "4 silent",
})

hl.on("hyprland.start", function()
	hl.exec_cmd("[workspace 3 silent] vesktop")
	hl.exec_cmd("[workspace 4 silent] steam")
	hl.exec_cmd("[workspace 9 silent] chatgpt")
end)
