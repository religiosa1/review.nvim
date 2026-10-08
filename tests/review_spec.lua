local review = require("review")
local config = require("review.config")

describe("review", function()
	before_each(function()
		config.setup()
		review.notes = {}
	end)

	it("renders notes grouped by file and sorted by line", function()
		review.notes = {
			{ file = "b.lua", line = 3, side = "new", text = "second\nmore" },
			{ file = "a.lua", line = 9, side = "old", text = "later" },
			{ file = "a.lua", line = 1, side = "new", text = "first" },
		}
		assert.equals(
			table.concat({
				"# Review notes\n",
				"\n## `a.lua`\n",
				"- **a.lua:1** (new): first",
				"- **a.lua:9** (old): later",
				"\n## `b.lua`\n",
				"- **b.lua:3** (new): second",
				"  more",
				"",
			}, "\n"),
			review.to_markdown()
		)
	end)

	it("sends notes to a new quickfix list", function()
		review.notes = {
			{ file = "b.lua", path = "/repo/b.lua", line = 3, side = "new", text = "second\nmore" },
			{ file = "a.lua", path = "/repo/a.lua", line = 9, side = "old", text = "later" },
		}
		review.quickfix()
		local qf = vim.fn.getqflist({ title = 0, items = 0 })
		assert.equals("Review notes", qf.title)
		assert.equals("/repo/a.lua", vim.api.nvim_buf_get_name(qf.items[1].bufnr))
		assert.equals(9, qf.items[1].lnum)
		assert.equals("[old] later", qf.items[1].text)
		assert.equals("second …", qf.items[2].text)
	end)

	it("jumps between note marks, wrapping around", function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "a", "b", "c", "d", "e", "f" })
		local ns = vim.api.nvim_get_namespaces().review_notes
		for _, row in ipairs({ 4, 1, 3 }) do
			vim.api.nvim_buf_set_extmark(0, ns, row, 0, {})
		end
		local function jump_from(line, dir)
			vim.api.nvim_win_set_cursor(0, { line, 0 })
			review.jump(dir)
			return vim.fn.line(".")
		end
		assert.equals(2, jump_from(1, 1))
		assert.equals(4, jump_from(2, 1))
		assert.equals(2, jump_from(5, 1))
		assert.equals(4, jump_from(5, -1))
		assert.equals(5, jump_from(1, -1))
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	end)

	it("uses configured messages", function()
		config.setup({ messages = { empty_export = "nothing" } })
		assert.equals("nothing\n", review.to_markdown())
		assert.equals("# Review notes", config.options.messages.export_heading)
	end)

	it("replaces key modes instead of merging lists", function()
		config.setup({ keys = { close_note = { ["<C-s>"] = "i", q = false } } })
		assert.equals("i", config.options.keys.close_note["<C-s>"])
		assert.is_false(config.options.keys.close_note.q)
		assert.equals("n", config.options.keys.close_note["<CR>"])
	end)
end)
