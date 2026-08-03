local function insert_timestamp_comment()
	local commentstring = vim.bo.commentstring
	if commentstring == "" then
		commentstring = "%s"
	end

	local timestamp = os.date("%Y-%m-%d %H:%M:%S")

	local comment_text = string.format(commentstring, " " .. timestamp)

	-- vim.api.nvim_put({ comment_text }, "c", true, true)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(0, row, row, false, { comment_text })
end

vim.keymap.set("n", "<leader>tc", insert_timestamp_comment, { desc = "insert timestrap" })
