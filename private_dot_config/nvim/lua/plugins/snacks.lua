return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sU",
        function()
          local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
          if vim.v.shell_error ~= 0 then
            return vim.notify("not a git repo", vim.log.levels.WARN)
          end
          local files = vim.fn.systemlist(
            "cd " .. vim.fn.shellescape(root)
              .. " && { git diff --name-only --diff-filter=d HEAD; git ls-files --others --exclude-standard; } | sort -u"
          )
          if #files == 0 then
            return vim.notify("no uncommitted files", vim.log.levels.INFO)
          end
          Snacks.picker.grep({ cwd = root, dirs = files, title = "Grep (uncommitted)" })
        end,
        desc = "Grep (uncommitted files)",
      },
    },
    opts = {
      image = { enabled = true },
      dashboard = {
        preset = {
          header = [[
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                       
          ]],
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      picker = {
        formatters = {
          file = {
            filename_first = true,
            min_width = 80,
          },
        },
        sources = {
          explorer = { hidden = true, ignored = true },
          files = { hidden = true, ignored = true },
          grep = { hidden = true },
        },
      },
    },
  },
}
