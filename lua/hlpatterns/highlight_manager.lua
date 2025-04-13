
local HighlightManager = {}
HighlightManager.nbhighlight = 0

-- @Function Generate a random color (but not too bright)
-- @return a string containing the rgb value generated
function HighlightManager.generate_random_color()
	local r = math.random(HighlightManager.opts.min_red_color, HighlightManager.opts.max_red_color)
	local g = math.random(HighlightManager.opts.min_green_color, HighlightManager.opts.max_green_color)
	local b = math.random(HighlightManager.opts.min_blue_color, HighlightManager.opts.max_blue_color)
	return string.format("%02X%02X%02X", r, g, b)
end

-- @function Highlight custom pattern
-- @param pattern: string pattern to highlight
function HighlightManager.highlight_pattern(pattern)
	pattern = pattern or vim.fn.expand("<cword>")
	if pattern == "" then
		print("No word found under the cursor.")
		return
	end

	HighlightManager.nbhighlight = HighlightManager.nbhighlight + 1
	local group = HighlightManager.opts.fgcolor .. HighlightManager.nbhighlight
	local bgcolor = HighlightManager.generate_random_color()

	local id = vim.fn.matchadd(group, '\\<' .. pattern .. '\\>', HighlightManager.opts.highlight_priority)
	if id ~= 0 then
		vim.cmd('highlight ' .. group .. ' guibg=#' .. bgcolor .. ' guifg=#' .. HighlightManager.opts.fgcolor)

		local value = { id = id, value = pattern }
		table.insert(HighlightManager.highlight_ids, value)
	else
		print("Failed to add match for pattern: " .. pattern)
	end
end

-- @function Get the selected text in visual mode
-- @return the selected text
local function get_visual_selection()
	vim.cmd.normal { vim.fn.mode(), bang = true }
	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	return table.concat(vim.fn.getregion(vstart, vend), "\n")
end

-- @function List highlight patterns
function HighlightManager.list()
	print("Highlight list:")
	for idx, pattern in ipairs(HighlightManager.highlight_ids) do
		print("\t-".. idx .. " pattern: '" .. pattern.value .. "' with ID:" .. pattern.id)
	end
end

-- @function Delete all highlighted pattern
function HighlightManager.delete_all_highlights()
	for _, pattern in ipairs(HighlightManager.highlight_ids) do
		pcall(vim.fn.matchdelete, pattern.id)
	end
	HighlightManager.highlight_ids = {}
	HighlightManager.nbhighlight = 0
end

-- @function Init and configure keymaps
function HighlightManager.setup(opts)
	if opts == nil then
		error("Missing configuration options. Please provide a table with configuration options.")
	end

	HighlightManager.highlight_ids = {}
	HighlightManager.opts = opts

	if HighlightManager.opts.highlight_pattern_keymap ~= nil then
		vim.keymap.set({ 'n' }, HighlightManager.opts.highlight_pattern_keymap, function() HighlightManager.highlight_pattern() end, { desc = 'Highlight word' , noremap = true, silent = true })
	end

	if HighlightManager.opts.delete_all_highlight_keymap ~= nil then
		vim.keymap.set({ 'n' }, HighlightManager.opts.delete_all_highlight_keymap, function() HighlightManager.delete_all_highlights() end, { desc = 'Delete all highlights' })
	end
	if HighlightManager.opts.highlight_selected_keymap ~= nil then
		vim.keymap.set({ 'v' }, HighlightManager.opts.highlight_selected_keymap, function()
			-- Get the selected text in visual mode
			local selected_text = get_visual_selection()
			-- Call the highlight_pattern function with the selected text
			HighlightManager.highlight_pattern(selected_text)
		end, { desc = 'Highlight selected text' })
	end
end

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


return HighlightManager

