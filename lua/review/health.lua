local M = {}

function M.check()
	vim.health.start("review")

	if vim.fn.has("nvim-0.10.0") == 1 then
		vim.health.ok("Neovim version is compatible")
	else
		vim.health.error("Neovim 0.10.0+ is required", { "Upgrade Neovim" })
	end

	if pcall(require, "diffview.lib") then
		vim.health.ok("diffview.nvim found")
	else
		vim.health.warn(
			"diffview.nvim not found",
			{ "Notes still work in plain buffers, but without diff sides or repo-relative paths" }
		)
	end
end

return M
