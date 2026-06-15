-- Writing layer: toggle-able spelling and grammar for markdown.
-- Both layers are OFF by default — toggle on demand.
--
-- Toggles:
--   <leader>zs   Toggle spelling    (Harper + vim spell)
--   <leader>zg   Toggle grammar     (ltex-plus / LanguageTool)
--   <leader>zw   Toggle both
--   <leader>zd   Switch ltex language (en-US / da-DK)
--
-- Active keymaps (only when a layer is on, markdown buffers):
--   ,s           Suggestions (LSP code actions, falls back to z=)
--   ,g           Add word to dictionary (vim spellfile + LSP)
--   gj / gk      Jump to next/prev diagnostic (from lsp config)
--   zg           Add to vim spellfile (built-in)
--
-- Requires:  :MasonInstall harper-ls ltex-ls-plus

local state = { spelling = false, grammar = false, lang = "en-US" }

-- ltex-plus custom command handlers (dictionary, false positives, disabled rules)
local ltex_path = vim.fn.stdpath("data") .. "/ltex-plus"

local function load_json(filename)
  local f = io.open(ltex_path .. "/" .. filename, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  if content == "" then return {} end
  local ok, data = pcall(vim.json.decode, content)
  return ok and data or {}
end

local function save_json(filename, data)
  vim.fn.mkdir(ltex_path, "p")
  local f = io.open(ltex_path .. "/" .. filename, "w")
  if not f then return end
  f:write(vim.json.encode(data))
  f:close()
end

local function handle_ltex_command(setting_key, filename, entries, ctx)
  local stored = load_json(filename)
  for lang, items in pairs(entries) do
    stored[lang] = stored[lang] or {}
    for _, item in ipairs(items) do
      if not vim.tbl_contains(stored[lang], item) then
        table.insert(stored[lang], item)
      end
    end
  end
  save_json(filename, stored)

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      ltex = { [setting_key] = stored },
    })
    client.notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
end

vim.lsp.commands["_ltex.addToDictionary"] = function(command, ctx)
  handle_ltex_command("dictionary", "dictionary.json", command.arguments[1].words, ctx)
end

vim.lsp.commands["_ltex.hideFalsePositives"] = function(command, ctx)
  handle_ltex_command("hiddenFalsePositives", "false-positives.json", command.arguments[1].falsePositives, ctx)
end

vim.lsp.commands["_ltex.disableRules"] = function(command, ctx)
  handle_ltex_command("disabledRules", "disabled-rules.json", command.arguments[1].ruleIds, ctx)
end

local function apply_spell(enabled)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "markdown" then
      vim.wo[win].spell = enabled
      vim.bo[buf].spelllang = "en"
      vim.bo[buf].spellcapcheck = ""
    end
  end
end

local function set_writing_keymaps_on_buf(buf, enabled)
  if enabled then
    vim.keymap.set("n", "<localleader>s", vim.lsp.buf.code_action, {
      buffer = buf,
      desc = "Writing: suggestions",
    })
    vim.keymap.set("n", "<localleader>g", function()
      vim.cmd("normal! zg")
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.title:lower():match("dictionary")
        end,
        apply = true,
      })
    end, {
      buffer = buf,
      desc = "Writing: add to dictionary",
    })
  else
    pcall(vim.keymap.del, "n", "<localleader>s", { buffer = buf })
    pcall(vim.keymap.del, "n", "<localleader>g", { buffer = buf })
  end
end

local function set_writing_keymaps(enabled)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "markdown" and vim.api.nvim_buf_is_loaded(buf) then
      set_writing_keymaps_on_buf(buf, enabled)
    end
  end
end

local augroup = vim.api.nvim_create_augroup("writing-layer", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "ltex_plus" then return end

    local dict = load_json("dictionary.json")
    local fp = load_json("false-positives.json")
    local rules = load_json("disabled-rules.json")

    local updates = {}
    if next(dict) then updates.dictionary = dict end
    if next(fp) then updates.hiddenFalsePositives = fp end
    if next(rules) then updates.disabledRules = rules end

    if next(updates) then
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
        ltex = updates,
      })
      client.notify("workspace/didChangeConfiguration", { settings = client.settings })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function(ev)
    vim.schedule(function()
      apply_spell(state.spelling)
      if state.spelling or state.grammar then
        set_writing_keymaps_on_buf(ev.buf, true)
      end
    end)
  end,
})

vim.keymap.set("n", "<leader>zs", function()
  state.spelling = not state.spelling
  vim.lsp.enable("harper_ls", state.spelling)
  apply_spell(state.spelling)
  set_writing_keymaps(state.spelling or state.grammar)
  vim.notify(state.spelling and "Spelling ON" or "Spelling OFF")
end, { desc = "Toggle spelling (Harper)" })

vim.keymap.set("n", "<leader>zg", function()
  state.grammar = not state.grammar
  vim.lsp.enable("ltex_plus", state.grammar)
  set_writing_keymaps(state.spelling or state.grammar)
  vim.notify(state.grammar and "Grammar ON" or "Grammar OFF")
end, { desc = "Toggle grammar (LanguageTool)" })

vim.keymap.set("n", "<leader>zd", function()
  state.lang = state.lang == "en-US" and "da-DK" or "en-US"
  for _, client in ipairs(vim.lsp.get_clients({ name = "ltex_plus" })) do
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      ltex = { language = state.lang },
    })
    client.notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
  vim.notify("ltex: " .. state.lang)
end, { desc = "Toggle ltex language (en-US / da-DK)" })

vim.keymap.set("n", "<leader>zw", function()
  local target = not (state.spelling or state.grammar)
  state.spelling = target
  state.grammar = target
  vim.lsp.enable("harper_ls", target)
  vim.lsp.enable("ltex_plus", target)
  apply_spell(target)
  set_writing_keymaps(target)
  vim.notify(target and "Writing layer ON" or "Writing layer OFF")
end, { desc = "Toggle writing layer (all)" })
