-- Development layout
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-6", mode = "preferred", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-7", mode = "preferred", position = "3840x0", scale = 1 })
hl.monitor({ output = "DP-5", mode = "preferred", position = "5760x-420", scale = 1, transform = 1 })

hl.workspace_rule({ workspace = "1", default_name = "web", monitor = "DP-7" })
hl.workspace_rule({ workspace = "3", default_name = "slack", monitor = "DP-5" })
hl.workspace_rule({ workspace = "4", default_name = "ia", monitor = "DP-5" })
hl.workspace_rule({ workspace = "7", default_name = "debugger", monitor = "DP-6" })
hl.workspace_rule({ workspace = "8", default_name = "test", monitor = "DP-7" })
hl.workspace_rule({ workspace = "9", default_name = "conf", monitor = "DP-7" })
hl.workspace_rule({ workspace = "10", default_name = "monitor", monitor = "DP-6" })
