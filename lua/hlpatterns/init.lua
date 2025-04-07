local M = {}

local min_color = 50
local max_color = 200

M.default_opts = {
	-- color handling,
	min_color = min_color,
	max_color = max_color,
	highlight_priority = 100,
	fgcolor = "FFFFFF",
	min_red_color = min_color,
	max_red_color = max_color,
	min_green_color = min_color,
	max_green_color = max_color,
	min_blue_color = min_color,
	max_blue_color = max_color,

	group_name = "custom",

	highlight_pattern_keymap = nil,
	delete_all_highlight_keymap = nil,
	highlight_selected_keymap = nil,
}

local function merge_settings(user_opts)
	-- Start with a copy of default options
	local merged = vim.deepcopy(M.default_opts)

	-- Override with user-provided options
	for key, value in pairs(user_opts) do
		merged[key] = value
	end
	return merged
end

function M.setup(opts)
	M.merged_opts = merge_settings(opts)

	-- check for min_color or max_color changes
	if M.merged_opts.max_color ~= max_color then
		M.merged_opts.max_red_color = M.merged_opts.max_color
		M.merged_opts.max_green_color = M.merged_opts.max_color
		M.merged_opts.max_blue_color = M.merged_opts.max_color
	end
	if M.merged_opts.min_color ~= min_color then
		M.merged_opts.min_red_color = M.merged_opts.min_color
		M.merged_opts.min_green_color = M.merged_opts.min_color
		M.merged_opts.min_blue_color = M.merged_opts.min_color
	end

	require('hlpatterns.highlight_manager').setup(M.merged_opts)
end

return M
