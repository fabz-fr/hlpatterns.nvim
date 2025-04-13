-- @user command to delete all patterns 
-- @param opts : string pattern to highlight
vim.api.nvim_create_user_command(
	'HlpatternsDeleteAll',
	function()
		HighlightManager.delete_all_highlights()
	end,
	{ nargs = 0, desc = 'Delete all highlights' }
)

-- @user command to add highlight on a user defined pattern
-- @param opts : string pattern to highlight
vim.api.nvim_create_user_command(
	'HlpatternsAdd',
	function(opts)
		HighlightManager.highlight_pattern(opts.args)
	end,
	{ nargs = 1, desc = 'Highlight a custom pattern' }
)

-- @user command to list all highlight patterns enable
-- @param opts : string pattern to highlight
vim.api.nvim_create_user_command(
	'HlpatternsList',
	function(opts)
		HighlightManager.list()
	end,
	{ nargs = 0, desc = 'List highlighted patterns' }
)

