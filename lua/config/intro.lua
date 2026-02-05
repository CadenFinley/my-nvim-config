local function version_line()
	local v = vim.version()
	local version = ("NVIM v%d.%d.%d"):format(v.major, v.minor, v.patch)
	if type(v.prerelease) == "string" and v.prerelease ~= "" then
		version = version .. "-" .. v.prerelease
	end
	return version
end

local function build_intro_lines()
	local v = vim.version()
	local text = {
		version_line(),
		"",
		"Nvim is open source and freely distributable",
		"https://neovim.io/#chat",
		"",
		"type  :help nvim<Enter>       if you are new! ",
		"type  :checkhealth<Enter>     to optimize Nvim",
		"type  :q<Enter>               to exit         ",
		"type  :help<Enter>            for help        ",
		"",
		("type  :help news<Enter> to see changes in v%d.%d  "):format(v.major, v.minor),
		"",
		"Help poor children in Uganda!",
		"type  :help Kuwasha<Enter>    for information ",
	}

	local text_width = 0
	for _, line in ipairs(text) do
		local width = vim.fn.strdisplaywidth(line)
		if width > text_width then
			text_width = width
		end
	end

	for i, line in ipairs(text) do
		if line ~= "" then
			local width = vim.fn.strdisplaywidth(line)
			local pad = 0
			if text_width > width then
				pad = math.floor((text_width - width) / 2)
			end
			text[i] = string.rep(" ", pad) .. line
		end
	end

	local art = {
		"     .          .",
		"   ';;,.        ::'",
		" ,:::;,,        :ccc,",
		",::c::,,,,.     :cccc,",
		",cccc:;;;;;.    cllll,",
		",cccc;.;;;;;,   cllll;",
		":cccc; .;;;;;;. coooo;",
		";llll;   ,:::::'loooo;",
		";llll:    ':::::loooo:",
		":oooo:     .::::llodd:",
		".;ooo:       ;cclooo:.",
		"  .;oc        'coo;.",
		"    .'         .,. ",
		"",
	}

	local width = 0
	for _, line in ipairs(art) do
		if #line > width then
			width = #line
		end
	end

	local total = math.max(#art, #text)
	local combined = {}
	for i = 1, total do
		local left = art[i] or ""
		local right = text[i] or ""
		if right ~= "" then
			combined[i] = string.format("%-" .. width .. "s  %s", left, right)
		else
			combined[i] = left
		end
	end

	return combined, width, #art
end

local function should_show_intro(buf)
	if vim.fn.argc() > 0 then
		return false
	end
	if vim.api.nvim_buf_get_name(buf) ~= "" then
		return false
	end
	if vim.bo[buf].buftype ~= "" then
		return false
	end
	if vim.api.nvim_buf_line_count(buf) > 1 then
		return false
	end
	if vim.api.nvim_get_current_line() ~= "" then
		return false
	end
	return true
end

local function center_lines(lines)
	local cols = vim.o.columns
	local rows = vim.o.lines
	local max_width = 0
	for _, line in ipairs(lines) do
		local width = vim.fn.strdisplaywidth(line)
		if width > max_width then
			max_width = width
		end
	end

	local left_pad = 0
	if cols > max_width then
		left_pad = math.floor((cols - max_width) / 2)
	end

	local centered = {}
	for i, line in ipairs(lines) do
		centered[i] = string.rep(" ", left_pad) .. line
	end

	local top_pad = 0
	if rows > #centered then
		top_pad = math.floor((rows - #centered) / 2)
	end

	if top_pad > 0 then
		local padded = {}
		for _ = 1, top_pad do
			padded[#padded + 1] = ""
		end
		for _, line in ipairs(centered) do
			padded[#padded + 1] = line
		end
		return padded, left_pad, top_pad
	end

	return centered, left_pad, 0
end

local logo_ns = vim.api.nvim_create_namespace("NvimIntroLogo")

local function apply_intro(buf)
	vim.bo[buf].modifiable = true
	local lines, art_width, art_height = build_intro_lines()
	local centered, left_pad, top_pad = center_lines(lines)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, centered)
	vim.bo[buf].modifiable = false
	vim.bo[buf].readonly = true
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buflisted = false
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "nvim-intro"

	vim.wo.number = vim.o.number
	vim.wo.relativenumber = vim.o.relativenumber
	vim.wo.cursorline = false
	vim.wo.list = false
	vim.wo.signcolumn = "no"

	vim.api.nvim_buf_clear_namespace(buf, logo_ns, 0, -1)
	for i = 0, art_height - 1 do
		vim.api.nvim_buf_add_highlight(buf, logo_ns, "NvimIntroLogo", top_pad + i, left_pad, left_pad + art_width)
	end
end

local group = vim.api.nvim_create_augroup("NvimIntro", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if should_show_intro(buf) then
			apply_intro(buf)
		end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if vim.bo[buf].filetype == "nvim-intro" then
			apply_intro(buf)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "nvim-intro",
	callback = function()
		vim.cmd("syntax match NvimIntroEnter /<Enter>/")
		vim.cmd("highlight default link NvimIntroEnter Comment")
		vim.cmd("highlight default link NvimIntroLogo NvimIntroEnter")
	end,
})
