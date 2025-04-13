
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

-- @function Highlight pattern
-- @param pattern : Pattern to highlight
-- bgcolor : background color value as a string
-- fg : frontground color value as a string
-- isFixed : Boolean value that can be set if the color shall not be disabled (todo)
function HighlightManager.highlight(pattern, bgcolor, fgcolor, isFixed)
	local group = HighlightManager.opts.fgcolor .. HighlightManager.nbhighlight
	local pattern_id = vim.fn.matchadd(group, '\\<' .. pattern .. '\\>', HighlightManager.opts.highlight_priority)

	if pattern == "" then
		print("No word found under the cursor.")
		return
	end

	if pattern_id == 0 then
		print("Failed to add match for pattern: " .. pattern)
		return
	end

	vim.cmd('highlight ' .. group .. ' guibg=#' .. bgcolor .. ' guifg=#' .. fgcolor)

	local value = { id = pattern_id, value = pattern }
	table.insert(HighlightManager.highlight_ids, value)
	HighlightManager.nbhighlight = HighlightManager.nbhighlight + 1
end

-- @function Highlight custom pattern
-- @param pattern: string pattern to highlight
function HighlightManager.highlight_pattern(pattern)
	pattern = pattern or vim.fn.expand("<cword>")
	local bgcolor = HighlightManager.generate_random_color()
	local fgcolor = HighlightManager.opts.fgcolor

	HighlightManager.highlight(pattern, bgcolor, fgcolor, false)
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

-- @function Delete highlighted on pattern
-- @param list of patterns to delete
function HighlightManager.delete(pattern_index)
	-- reverse index list to remove from big indexes to small indexes and avoid table indexes update issues
	table.sort(pattern_index, function(a, b) return a > b end) 

	for _, index in ipairs(pattern_index) do 
		local pattern = HighlightManager.highlight_ids[index]
		if pattern ~= nil then 
			print("pattern is " ..vim.inspect(pattern))
			pcall(vim.fn.matchdelete, pattern.id)
			table.remove(HighlightManager.highlight_ids, index)
		end
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

return HighlightManager

