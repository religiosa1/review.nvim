# Review

Lightweight review surface for Neovim: drop line comments while reviewing a
diff in [diffview.nvim](https://github.com/sindrets/diffview.nvim) (or any
plain file buffer), then export them all as markdown to hand to a coding agent.

- Add/edit a note on the current line in a floating editor
- Notes are shown inline as virtual text
- Jump between notes in the current buffer
- Yank all notes as markdown, or export them to a scratch split
- Send all notes to the quickfix list (works with
  [trouble.nvim](https://github.com/folke/trouble.nvim) too)

Notes are kept in memory for the session only.



https://github.com/user-attachments/assets/855e4cbc-f1c8-4262-9554-f628c9b2e366



Slop disclosure: this is completely AI-generated. I haven't even read the code.
Works good enough for me though.

## How it works?

In a diffview, the note is anchored to the repo-relative path and the diff side
(`old` for the left window, `new` otherwise). Outside of diffview, the
cwd-relative path of the current buffer is used, side is always `new`.

The note float saves on close, no matter how it's closed (configured keys,
`:q`, focusing another window). To discard changes, undo them before closing.
Emptying a note deletes it.

Exported markdown looks like this:

```markdown
# Review notes

## `lua/foo.lua`

- **lua/foo.lua:12** (new): this should be a local
- **lua/foo.lua:40** (old): why was this removed?
  multi-line notes are indented
```

`quickfix()` pushes all notes as a new quickfix list titled "Review notes",
without opening it. It's a snapshot: re-run it after adding or removing notes.
Open the list however you like: `:copen`, or `:Trouble qflist` with
trouble.nvim. Notes on the `old` diff side are prefixed with `[old]` and point
at the working-tree file, so their line may not match.

As notes are supposed to be short-lived, they're only tied by the line number.
After file edit, they would drift.

## Installation

### Lazy:

```lua
{
  "religiosa1/review.nvim",
  opts = {},
  keys = {
    { "<leader>rr", function() require("review").add() end, desc = "Add review note on line" },
    { "<leader>ry", function() require("review").yank() end, desc = "Yank review notes" },
    { "<leader>rw", function() require("review").export() end, desc = "Export review notes to a split" },
    { "<leader>rx", function() require("review").clear() end, desc = "Clear review notes" },
    {
      "<leader>rq",
      function()
        require("review").quickfix()
        vim.cmd.copen() -- or vim.cmd("Trouble qflist")
      end,
      desc = "Review notes to quickfix",
    },
    { "]r", function() require("review").jump(1) end, desc = "Next review note" },
    { "[r", function() require("review").jump(-1) end, desc = "Prev review note" },
  },
}
```

### nvim.pack:

```lua
vim.pack.add { "https://github.com/religiosa1/review.nvim" }
local review = require("review")
review.setup {
  -- your config opts here
}
vim.keymap.set("n", "<leader>rr", review.add, { desc = "Add review note on line" })
vim.keymap.set("n", "<leader>ry", review.yank, { desc = "Yank review notes" })
vim.keymap.set("n", "<leader>rw", review.export, { desc = "Export review notes to a split" })
vim.keymap.set("n", "<leader>rx", review.clear, { desc = "Clear review notes" })
vim.keymap.set("n", "<leader>rq", function()
  review.quickfix()
  vim.cmd.copen() -- or vim.cmd("Trouble qflist")
end, { desc = "Review notes to quickfix" })
vim.keymap.set("n", "]r", function() review.jump(1) end, { desc = "Next review note" })
vim.keymap.set("n", "[r", function() review.jump(-1) end, { desc = "Prev review note" })
```

## Configuration

All configuration values are optional and provided here only for the reference

```lua
{
	-- prefix of the inline note marker
	icon = "💬",
	-- keymaps, as lhs -> mode(s). Set one to false to disable a default one.
	keys = {
		-- in the note float, closing (and saving) it
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
		no_notes = "review: no notes",
		copied = "review: notes copied",
		exported = "review: exported %d note(s), copied to clipboard",
		cleared = "review: cleared",
		empty_export = "No review notes.",
		export_heading = "# Review notes",
		quickfix_title = "Review notes",
	},
}
```

## License

review.nvim is MIT licensed.
