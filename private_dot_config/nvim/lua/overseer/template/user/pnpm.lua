--
-- Unified JS task provider: wraps the built-in npm provider and extends it
-- with pnpm workspace package scripts when a pnpm monorepo is detected.
--
-- Picker ordering:
--   1. Root package.json scripts   (from npm provider — always)
--   2. apps/* package scripts      (pnpm workspaces only, in file order)
--   3. packages/* package scripts  (pnpm workspaces only, in file order)
--
-- Required in your overseer setup — disables the built-in npm provider so
-- this one is the sole source of JS tasks:
--
--   require("overseer").setup({
--     disable_template_modules = { "overseer.template.npm" },
--   })
--
-- ┌─ pnpm workspace filename note ────────────────────────────────────────────┐
-- │ pnpm's canonical name is pnpm-workspace.yaml (singular).                 │
-- │ The plural pnpm-workspaces.yaml is non-standard but supported here.      │
-- └───────────────────────────────────────────────────────────────────────────┘

---@type overseer.TemplateFileProvider

-- ─── Load the built-in npm provider ──────────────────────────────────────────
--
-- Because disable_template_modules removes it from Overseer's discovery, we
-- require it directly so we can call its generator ourselves.
-- pcall guards against a future rename — npm tasks are silently skipped
-- rather than hard-erroring if the module no longer exists.

---@type overseer.TemplateFileProvider?
local npm_provider
local ok
ok, npm_provider = pcall(require, "overseer.template.npm")
if not ok then
  npm_provider = nil
end

-- ─── pnpm workspace helpers ───────────────────────────────────────────────────

local WORKSPACE_FILENAMES = {
  "pnpm-workspace.yaml",
  "pnpm-workspace.yml",
  "pnpm-workspaces.yaml",
  "pnpm-workspaces.yml",
}

---@param dir string
---@return string|nil path, string filename
local function find_workspace_file(dir)
  for _, name in ipairs(WORKSPACE_FILENAMES) do
    local hits = vim.fs.find(name, { upward = true, type = "file", path = dir })
    if hits[1] then
      return hits[1], name
    end
  end
  return nil, ""
end

---@param content string
---@return string[]
local function parse_workspace_globs(content)
  local globs = {}
  local in_packages = false

  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    local trimmed = line:gsub("%s+$", "")

    if trimmed:match("^packages%s*:") then
      in_packages = true
    elseif in_packages then
      local glob = trimmed:match("^%s+%-%s+'(.-)'%s*$")
        or trimmed:match('^%s+%-%s+"(.-)"')
        or trimmed:match("^%s+%-%s+([^#%s].-)%s*$")
      if glob and glob ~= "" then
        table.insert(globs, glob)
      elseif trimmed ~= "" and not trimmed:match("^%s") and not trimmed:match("^#") then
        in_packages = false
      end
    end
  end

  return globs
end

---@param root string
---@param glob string
---@return string[]
local function expand_glob(root, glob)
  if glob:find("%*%*") then
    vim.notify(
      string.format(
        "[overseer/pnpm_workspace] Glob %q uses '**' which is not fully supported — "
          .. "only direct children will match.",
        glob
      ),
      vim.log.levels.WARN
    )
  end
  local dirs = {}
  for _, path in ipairs(vim.fn.glob(root .. "/" .. glob .. "/package.json", false, true)) do
    table.insert(dirs, vim.fn.fnamemodify(path, ":h"))
  end
  return dirs
end

---@param pkg_dir string
---@return table|nil
local function read_package_json(pkg_dir)
  local fh = io.open(pkg_dir .. "/package.json", "r")
  if not fh then
    return nil
  end
  local raw = fh:read("*a")
  fh:close()
  local ok, decoded = pcall(vim.json.decode, raw, { luanil = { object = true } })
  return ok and decoded or nil
end

--- Build sorted Overseer task definitions for all workspace packages.
---@param ws_root string
---@param globs   string[]
---@return table[]
local function build_workspace_tasks(ws_root, globs)
  local tasks = {}

  for glob_index, glob in ipairs(globs) do
    for _, pkg_dir in ipairs(expand_glob(ws_root, glob)) do
      local pkg = read_package_json(pkg_dir)
      if pkg then
        local pkg_name = (pkg.name and pkg.name ~= "") and pkg.name or vim.fn.fnamemodify(pkg_dir, ":t")

        for script_name, script_cmd in pairs(pkg.scripts or {}) do
          local c_name = pkg_name
          local c_script = script_name
          local c_dir = pkg_dir
          local c_cmd = script_cmd
          local task_name = c_name .. ": " .. c_script

          table.insert(tasks, {
            name = task_name,
            desc = c_cmd or "",
            tags = { "pnpm" },
            _sort_key = { glob_index, c_name, c_script },

            builder = function(_params)
              return {
                name = task_name,
                cmd = { "pnpm", "run", c_script },
                cwd = c_dir,
                components = { "default" },
              }
            end,
          })
        end
      end
    end
  end

  table.sort(tasks, function(a, b)
    local ka, kb = a._sort_key, b._sort_key
    for i = 1, #ka do
      if ka[i] ~= kb[i] then
        return ka[i] < kb[i]
      end
    end
    return false
  end)

  return tasks
end

--- Invoke a generator handling both sync (return value) and async (cb) forms.
--- on_done is always called exactly once with a table (possibly empty).
---@param provider table
---@param opts     table
---@param on_done  fun(tasks: table[])
local function call_generator(provider, opts, on_done)
  local cb_called = false

  local ret = provider.generator(opts, function(result)
    cb_called = true
    on_done(type(result) == "table" and result or {})
  end)

  if not cb_called then
    on_done(type(ret) == "table" and ret or {})
  end
end

-- ─── Provider ─────────────────────────────────────────────────────────────────

return {
  generator = function(opts, cb)
    -- ── Step 1: always run npm provider first ────────────────────────────────
    -- Gives us root package.json scripts regardless of package manager.
    -- Falls back to an empty list if npm provider is unavailable.

    local function on_npm_done(npm_tasks)
      -- ── Step 2: check for pnpm workspace ──────────────────────────────────
      local ws_file, _ = find_workspace_file(opts.dir)

      if not ws_file then
        -- Plain npm/yarn/bun repo — npm tasks are all we need.
        return cb(npm_tasks)
      end

      local ws_root = vim.fn.fnamemodify(ws_file, ":h")

      -- ── Step 3: reject if packageManager disagrees ────────────────────────
      local root_pkg = read_package_json(ws_root)
      if root_pkg then
        local pm = root_pkg.packageManager or ""
        if pm ~= "" and not pm:match("^pnpm") then
          -- Not a pnpm repo despite a workspace file — return npm tasks only.
          return cb(npm_tasks)
        end
      end

      -- ── Step 4: parse workspace globs ─────────────────────────────────────
      local fh = io.open(ws_file, "r")
      if not fh then
        return cb(npm_tasks)
      end
      local content = fh:read("*a")
      fh:close()

      local globs = parse_workspace_globs(content)
      if vim.tbl_isempty(globs) then
        return cb(npm_tasks)
      end

      -- ── Step 5: build workspace tasks and combine ──────────────────────────
      local workspace_tasks = build_workspace_tasks(ws_root, globs)

      local all = {}
      vim.list_extend(all, npm_tasks) -- root scripts first
      vim.list_extend(all, workspace_tasks) -- then apps/*, packages/*
      cb(all)
    end

    if npm_provider then
      call_generator(npm_provider, opts, on_npm_done)
    else
      on_npm_done({})
    end
  end,

  cache_key = function(opts)
    -- Watch the workspace file; root package.json is covered by npm provider's
    -- own cache_key which Overseer still honours even when the module is
    -- loaded manually rather than discovered.
    return (find_workspace_file(opts.dir))
  end,
}
