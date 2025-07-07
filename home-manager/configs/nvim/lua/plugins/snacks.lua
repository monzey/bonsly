return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("force", opts, {
        dashboard = {
          preset = {
            header = [[gg ez]],
          },
        },
        previewers = {
          diff = {
            builtin = false,
            cmd = { "delta" },
          },
        },
        picker = {
          sources = {
            files = {
              hidden = true,
            },
            explorer = {
              hidden = true,
              ignored = true,
              follow = false,
              supports_live = true,
              win = {
                layout = "right",
                list = {
                  keys = {
                    ["/"] = "toggle_focus",
                    ["<2-leftmouse>"] = "confirm",
                    ["<cr>"] = "confirm",
                    ["<down>"] = "list_down",
                    ["<esc>"] = "cancel",
                    ["<s-cr>"] = { { "pick_win", "jump" } },
                    ["<s-tab>"] = { "select_and_prev", mode = { "n", "x" } },
                    ["<tab>"] = { "select_and_next", mode = { "n", "x" } },
                    ["<Up>"] = "list_up",
                    ["<a-d>"] = "inspect",
                    ["<a-f>"] = "toggle_follow",
                    ["<a-h>"] = "toggle_hidden",
                    ["<a-i>"] = "toggle_ignored",
                    ["<a-m>"] = false,
                    ["<a-p>"] = "toggle_preview",
                    ["<a-w>"] = "cycle_win",
                    ["<c-a>"] = "select_all",
                    ["<c-b>"] = "preview_scroll_up",
                    ["<c-d>"] = "list_scroll_down",
                    ["<c-f>"] = "preview_scroll_down",
                    ["<c-j>"] = "list_down",
                    ["<c-k>"] = "list_up",
                    ["<c-n>"] = "list_down",
                    ["<c-p>"] = "list_up",
                    ["<c-q>"] = "qflist",
                    ["<c-s>"] = "edit_split",
                    ["<c-t>"] = "tab",
                    ["<c-u>"] = "list_scroll_up",
                    ["<c-v>"] = "edit_vsplit",
                    ["<c-w>H"] = "layout_left",
                    ["<c-w>J"] = "layout_bottom",
                    ["<c-w>K"] = "layout_top",
                    ["<c-w>L"] = "layout_right",
                    ["?"] = "toggle_help_list",
                    ["G"] = "list_bottom",
                    ["gg"] = "list_top",
                    ["i"] = "focus_input",
                    ["j"] = "list_down",
                    ["k"] = "list_up",
                    ["q"] = "close",
                    ["zb"] = "list_scroll_bottom",
                    ["zt"] = "list_scroll_top",
                    ["zz"] = "list_scroll_center",
                  },
                },
              },
            },
          },
        },
      })
      return opts
    end,
  },
}
