local M = {}

---@class ReviewMessages
---@field new_note_title? string Float title when adding a note
---@field edit_note_title? string Float title when editing an existing note
---@field no_file? string Shown when there is no reviewable file under the cursor
---@field no_notes_in_buffer? string Shown by jump when the buffer has no notes
---@field copied? string Shown after yank
---@field exported? string Shown after export; `%d` is the note count
---@field cleared? string Shown after clear
---@field empty_export? string Markdown output when there are no notes
---@field export_heading? string Top heading of the markdown output

---@alias ReviewKeymap table<string, string|string[]|false> lhs -> mode(s), false disables

---@class ReviewKeys
---@field close_note? ReviewKeymap Note float keymaps that close (and save) it

---@class ReviewPluginConfig
---@field icon? string Prefix of the inline note marker
---@field keys? ReviewKeys
---@field messages? ReviewMessages

---@type ReviewPluginConfig
M.defaults = {
	icon = "💬",
	keys = {
		close_note = {
			["<C-s>"] = { "n", "i" },
			["<CR>"] = "n",
			["q"] = "n",
			["<esc><esc>"] = "n",
		},
	},
	messages = {
		new_note_title = " new note · q or <esc><esc> to save ",
		edit_note_title = " edit note · q or <esc><esc> to save ",
		no_file = "review: no file under cursor",
		no_notes_in_buffer = "review: no notes in this buffer",
		copied = "review: notes copied",
		exported = "review: exported %d note(s), copied to clipboard",
		cleared = "review: cleared",
		empty_export = "No review notes.",
		export_heading = "# Review notes",
	},
}

M.options = M.defaults

---Initialization of instance configuration options.
---@param opts? ReviewPluginConfig
function M.setup(opts)
	opts = opts or {}
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts)
	-- Shallow-merge each keymap, so a user's mode list replaces the default one
	-- instead of being merged into it index by index.
	local user_keys = opts.keys or {}
	for name, keymap in pairs(M.defaults.keys) do
		M.options.keys[name] = vim.tbl_extend("force", {}, keymap, user_keys[name] or {})
	end
end

return M
