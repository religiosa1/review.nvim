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
