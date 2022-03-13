--[[
             _      ____      _   _          _
            / \    / ___|    | | | |   ___  | |  _ __     ___   _ __
           / _ \   \___ \    | |_| |  / _ \ | | | '_ \   / _ \ | '__|
          / ___ \   ___) |   |  _  | |  __/ | | | |_) | |  __/ | |
         /_/   \_\ |____/    |_| |_|  \___| |_| | .__/   \___| |_|
                                                |_|

	[стили imgui]
		1-ый imgui стиль (переделан под лад mimgui): https://www.blast.hk/threads/25442/post-310168
		2-ой imgui стиль (переделан под лад mimgui): https://www.blast.hk/threads/25442/post-262906
		4-ый imgui стиль (переделан под лад mimgui): https://www.blast.hk/threads/25442/post-555626

	[библиотеки]
		mimgui: https://www.blast.hk/threads/66959/
		SAMP.lua: https://www.blast.hk/threads/14624/
		lfs: https://github.com/keplerproject/luafilesystem
		MoonMonet: https://www.blast.hk/threads/105945/

	[гайды]
		Картинки и шрифт в base85: https://www.blast.hk/threads/28761/ | https://www.blast.hk/threads/28761/post-289682
		Обновление скрипта: https://www.blast.hk/threads/30501/

	[функции]
		string.separate: https://www.blast.hk/threads/13380/post-220949
		imgui.BoolButton: https://www.blast.hk/threads/59761/
		imgui.Hint: https://www.blast.hk/threads/13380/post-778921
		imgui.AnimButton (слегка изменён): https://www.blast.hk/threads/13380/post-793501
		getTimeAfter: bank helper
]]

script_name('AS Helper')
script_description('Удобный помощник для Автошколы.')
script_author('JustMini')
script_version('3.1')
script_dependencies('mimgui; samp events; lfs; MoonMonet')

require 'moonloader'
local dlstatus					= require 'moonloader'.download_status
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local bit 						= require 'bit'
local ffi 						= require 'ffi'

local encodingcheck, encoding	= pcall(require, 'encoding')
local imguicheck, imgui			= pcall(require, 'mimgui')
local monetluacheck, monetlua 	= pcall(require, 'MoonMonet')
local lfscheck, lfs 			= pcall(require, 'lfs')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')

if not imguicheck or not sampevcheck or not encodingcheck or not lfscheck or not monetluacheck or not doesFileExist('moonloader/AS Helper/Images/ASH_Images.png') then
	function main()
		if not isSampLoaded() or not isSampfuncsLoaded() then return end
		while not isSampAvailable() do wait(1000) end

		local ASHfont = renderCreateFont('trebucbd', 11, 9)
		local progressfont = renderCreateFont('trebucbd', 9, 9)
		local downloadingfont = renderCreateFont('trebucbd', 7, 9)

		local progressbar = {
			max = 0,
			downloaded = 0,
			downloadedvisual = 0,
			downloadedclock = 0,
			downloadinglibname = '',
			downloadingtheme = '',
		}

		function bringFloatTo(from, to, start_time, duration)
			local timer = os.clock() - start_time
			if timer >= 0.00 and timer <= duration then
				local count = timer / (duration / 100)
				return from + (count * (to - from) / 100), true
			end
			return (timer > duration) and to or from, false
		end

		function DownloadFiles(table)
			progressbar.max = #table
			progressbar.downloadingtheme = table.theme
			for k = 1, #table do
				progressbar.downloadinglibname = table[k].name
				downloadUrlToFile(table[k].url,table[k].file,function(id,status)
					if status == dlstatus.STATUSEX_ENDDOWNLOAD then
						progressbar.downloaded = k
						progressbar.downloadedclock = os.clock()
						if table[k+1] then
							progressbar.downloadinglibname = table[k+1].name
						end
					end
				end)
				while progressbar.downloaded ~= k do
					wait(500)
				end
			end
			progressbar.max = nil
			progressbar.downloaded = 1
		end
		
		lua_thread.create(function()
			local x = select(1,getScreenResolution()) * 0.5 - 100
			local y = select(2, getScreenResolution()) - 70
			while true do
				if progressbar and progressbar.max ~= nil and progressbar.downloadinglibname and progressbar.downloaded and progressbar.downloadingtheme then
					local jj = (200-10)/progressbar.max
					local downloaded = progressbar.downloadedvisual * jj
					renderDrawBoxWithBorder(x, y-39, 200, 20, 0xFFFF6633, 1, 0xFF808080)
					renderFontDrawText(ASHfont, 'AS Helper', x+ 5, y - 37, 0xFFFFFFFF)
					renderDrawBoxWithBorder(x, y-20, 200, 70, 0xFF1C1C1C, 1, 0xFF808080)
					renderFontDrawText(progressfont, string.format('Скачивание: %s', progressbar.downloadingtheme), x + 5, y - 15, 0xFFFFFFFF)
					renderDrawBox(x + 5, y + 5, downloaded, 20, 0xFF00FF00)
					renderFontDrawText(progressfont, string.format('Progress: %s%%', math.ceil(progressbar.downloadedvisual / progressbar.max * 100), progressbar.max), x + 100 - renderGetFontDrawTextLength(progressfont, string.format('Progress: %s%%', progressbar.downloaded, progressbar.max)) * 0.5, y + 7, 0xFFFFFFFF)
					renderFontDrawText(downloadingfont, string.format('Downloading: \'%s\'', progressbar.downloadinglibname), x + 5, y + 32, 0xFFFFFFFF)
				end
				progressbar.downloadedvisual = bringFloatTo(progressbar.downloaded-1, progressbar.downloaded, progressbar.downloadedclock, 0.2)
				wait(0)
			end
		end)

		sampAddChatMessage(('[ASHelper]{EBEBEB} Началось скачивание необходимых файлов. Если скачивание не удастся, то обратитесь к {ff6633}vk.com/justmini{ebebeb}.'),0xff6633)

		if not imguicheck then -- Нашел только релизную версию в архиве, так что пришлось залить файлы сюда, при обновлении буду обновлять и у себя
			print('{FFFF00}Скачивание: mimgui')
			createDirectory('moonloader/lib/mimgui')
			DownloadFiles({theme = 'mimgui',
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/init.lua', file = 'moonloader/lib/mimgui/init.lua', name = 'init.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/imgui.lua', file = 'moonloader/lib/mimgui/imgui.lua', name = 'imgui.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/dx9.lua', file = 'moonloader/lib/mimgui/dx9.lua', name = 'dx9.lua'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/cimguidx9.dll', file = 'moonloader/lib/mimgui/cimguidx9.dll', name = 'cimguidx9.dll'},
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/mimgui/cdefs.lua', file = 'moonloader/lib/mimgui/cdefs.lua', name = 'cdefs.lua'},
			})
			print('{00FF00}mimgui успешно скачан')
		end

		if not monetluacheck then
			print('{FFFF00}Скачивание: MoonMonet')
			createDirectory('moonloader/lib/MoonMonet')
			DownloadFiles({theme = 'MoonMonet',
				{url = 'https://github.com/Northn/MoonMonet/releases/download/0.1.0/init.lua', file = 'moonloader/lib/MoonMonet/init.lua', name = 'init.lua'},
				{url = 'https://github.com/Northn/MoonMonet/releases/download/0.1.0/moonmonet_rs.dll', file = 'moonloader/lib/MoonMonet/moonmonet_rs.dll', name = 'moonmonet_rs.dll'},
			})
			print('{00FF00}MoonMonet успешно скачан')
		end

		if not sampevcheck then -- C оффициального источника
			print('{FFFF00}Скачивание: sampev')
			createDirectory('moonloader/lib/samp')
			createDirectory('moonloader/lib/samp/events')
			DownloadFiles({theme = 'samp events',
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events.lua', file = 'moonloader/lib/samp/events.lua', name = 'events.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/raknet.lua', file = 'moonloader/lib/samp/raknet.lua', name = 'raknet.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/synchronization.lua', file = 'moonloader/lib/samp/synchronization.lua', name = 'synchronization.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua', file = 'moonloader/lib/samp/events/bitstream_io.lua', name = 'bitstream_io.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/core.lua', file = 'moonloader/lib/samp/events/core.lua', name = 'core.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/extra_types.lua', file = 'moonloader/lib/samp/events/extra_types.lua', name = 'extra_types.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/handlers.lua', file = 'moonloader/lib/samp/events/handlers.lua', name = 'handlers.lua'},
				{url = 'https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/utils.lua', file = 'moonloader/lib/samp/events/utils.lua', name = 'utils.lua'}
			})
			print('{00FF00}sampev успешно скачан')
		end

		if not encodingcheck then -- Обновлений быть не должно
			print('{FFFF00}Скачивание: encoding')
			DownloadFiles({ theme = 'encoding.lua',
				{url = 'https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', file = 'moonloader/lib/encoding.lua', name = 'encoding.lua'}
			})
			print('{00FF00}encoding успешно скачан')
		end

		if not lfscheck then -- Обновлений быть не должно
			print('{FFFF00}Скачивание: lfs')
			DownloadFiles({theme = 'lfs.dll',
				{url = 'https://github.com/Just-Mini/biblioteki/raw/main/lfs.dll', file = 'moonloader/lib/lfs.dll', name = 'lfs.dll'}
			})
			print('{00FF00}lfs успешно скачан')
		end

		if not doesFileExist('moonloader/AS Helper/Images/ASH_Images.png') then
			print('{FFFF00}Скачивание: PNG Файлы')
			createDirectory('moonloader/AS Helper')
			createDirectory('moonloader/AS Helper/Images')
			DownloadFiles({theme = 'PNG Файлы',
				{url = 'https://raw.githubusercontent.com/Just-Mini/biblioteki/main/Images/ASH_Images.png', file = 'moonloader/AS Helper/Images/ASH_Images.png', name = 'ASH_Images.png'},
			})
			print('{00FF00}PNG Файлы успешно скачаны')
		end

		print('{FFFF00}Файлы были успешно скачаны, скрипт перезагружен.')
		thisScript():reload()
	end
	return
end

local print, clock, sin, cos, floor, ceil, abs, format, gsub, gmatch, find, char, len, upper, lower, sub, u8, new, str, sizeof = print, os.clock, math.sin, math.cos, math.floor, math.ceil, math.abs, string.format, string.gsub, string.gmatch, string.find, string.char, string.len, string.upper, string.lower, string.sub, encoding.UTF8, imgui.new, ffi.string, ffi.sizeof

encoding.default = 'CP1251'

local configuration = inicfg.load({
	main_settings = {
		myrankint = 1,
		gender = 0,
		style = 0,
		rule_align = 1,
		lection_delay = 10,
		lection_type = 1,
		fmtype = 0,
		playcd = 2000,
		fmstyle = nil,
		myname = '',
		myaccent = '',
		astag = 'Автошкола',
		expelreason = 'Н.П.А.',
		usefastmenucmd = 'ashfm',
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		replaceash = false,
		dofastscreen = true,
		dofastexpel = true,
		noscrollbar = true,
		playdubinka = true,
		changelog = true,
		autoupdate = true,
		getbetaupd = false,
		statsvisible = false,
		checkmcongun = true,
		checkmconhunt = false,
		bodyrank = false,
		chatrank = false,
		usefastmenu = 'E',
		fastscreen = 'F4',
		fastexpel = 'G',
		avtoprice = 5000,
		motoprice = 10000,
		ribaprice = 30000,
		lodkaprice = 30000,
		gunaprice = 50000,
		huntprice = 100000,
		kladprice = 200000,
		taxiprice = 250000,
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = 4281558783,
		monetstyle = -16729410,
		monetstyle_chroma = 1.0,
	},

	imgui_pos = {
		posX = 100,
		posY = 300
	},

	my_stats = {
		avto = 0,
		moto = 0,
		riba = 0,
		lodka = 0,
		guns = 0,
		hunt = 0,
		klad = 0,
		taxi = 0
	},

	RankNames = {
		'Стажёр',
		'Консультант',
		'Лицензёр',
		'Мл.Инструктор',
		'Инструктор',
		'Менеджер',
		'Ст. Менеджер',
		'Помощник директора',
		'Директор',
		'Управляющий',
	},

	Checker = {
    	state = true,
    	delay = 10,
    	afk_max_l = 300,
    	afk_max_h = 600,
    	posX = 200,
    	posY = 400,

    	col_title = 0xFFFF6633,
    	col_default = 0xFFFFFFFF,
    	col_no_work = 0xFFAA3333,
    	col_afk_max = 0xFFFF0000,
    	col_note = 0xFF909090,

		font_name = 'Arial',
    	font_size = 9,
    	font_flag = 5,
    	font_offset = 14,
    	font_alpha = 255,

    	show_id = true,
    	show_rank = true,
    	show_afk = true,
    	show_warn = false,
    	show_mute = false,
    	show_uniform = true,
    	show_near = false,

		[1] = true, [6] = true,
    	[2] = true, [7] = true,
    	[3] = true, [8] = true,
    	[4] = true, [9] = true,
    	[5] = true, [10] = true,
	},
	Checker_Notes = {},
	
	sobes_settings = {
		pass = true,
		medcard = true,
		wbook = false,
		licenses = false,
	},

	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, 'AS Helper')

-- icon fonts
	local fa = {
		['ICON_FA_FILE_ALT'] = '\xee\x80\x80',
		['ICON_FA_PALETTE'] = '\xee\x80\x81',
		['ICON_FA_TIMES'] = '\xee\x80\x82',
		['ICON_FA_QUESTION_CIRCLE'] = '\xee\x80\x83',
		['ICON_FA_BOOK_OPEN'] = '\xee\x80\x84',
		['ICON_FA_INFO_CIRCLE'] = '\xee\x80\x85',
		['ICON_FA_SEARCH'] = '\xee\x80\x86',
		['ICON_FA_ALIGN_LEFT'] = '\xee\x80\x87',
		['ICON_FA_ALIGN_CENTER'] = '\xee\x80\x88',
		['ICON_FA_ALIGN_RIGHT'] = '\xee\x80\x89',
		['ICON_FA_TRASH'] = '\xee\x80\x8a',
		['ICON_FA_REDO_ALT'] = '\xee\x80\x8b',
		['ICON_FA_HAND_PAPER'] = '\xee\x80\x8c',
		['ICON_FA_FILE_SIGNATURE'] = '\xee\x80\x8d',
		['ICON_FA_REPLY'] = '\xee\x80\x8e',
		['ICON_FA_USER_PLUS'] = '\xee\x80\x8f',
		['ICON_FA_USER_MINUS'] = '\xee\x80\x90',
		['ICON_FA_EXCHANGE_ALT'] = '\xee\x80\x91',
		['ICON_FA_USER_SLASH'] = '\xee\x80\x92',
		['ICON_FA_USER'] = '\xee\x80\x93',
		['ICON_FA_FROWN'] = '\xee\x80\x94',
		['ICON_FA_SMILE'] = '\xee\x80\x95',
		['ICON_FA_VOLUME_MUTE'] = '\xee\x80\x96',
		['ICON_FA_VOLUME_UP'] = '\xee\x80\x97',
		['ICON_FA_STAMP'] = '\xee\x80\x98',
		['ICON_FA_ELLIPSIS_V'] = '\xee\x80\x99',
		['ICON_FA_ARROW_UP'] = '\xee\x80\x9a',
		['ICON_FA_ARROW_DOWN'] = '\xee\x80\x9b',
		['ICON_FA_ARROW_RIGHT'] = '\xee\x80\x9c',
		['ICON_FA_CODE'] = '\xee\x80\x9d',
		['ICON_FA_ARROW_ALT_CIRCLE_DOWN'] = '\xee\x80\x9e',
		['ICON_FA_LINK'] = '\xee\x80\x9f',
		['ICON_FA_CAR'] = '\xee\x80\xa0',
		['ICON_FA_MOTORCYCLE'] = '\xee\x80\xa1',
		['ICON_FA_FISH'] = '\xee\x80\xa2',
		['ICON_FA_SHIP'] = '\xee\x80\xa3',
		['ICON_FA_CROSSHAIRS'] = '\xee\x80\xa4',
		['ICON_FA_SKULL_CROSSBONES'] = '\xee\x80\xa5',
		['ICON_FA_DIGGING'] = '\xee\x80\xa6',
		['ICON_FA_PLUS_CIRCLE'] = '\xee\x80\xa7',
		['ICON_FA_PAUSE'] = '\xee\x80\xa8',
		['ICON_FA_PEN'] = '\xee\x80\xa9',
		['ICON_FA_MINUS_SQUARE'] = '\xee\x80\xaa',
		['ICON_FA_CLOCK'] = '\xee\x80\xab',
		['ICON_FA_COG'] = '\xee\x80\xac',
		['ICON_FA_TAXI'] = '\xee\x80\xad',
		['ICON_FA_FOLDER'] = '\xee\x80\xae',
		['ICON_FA_CHEVRON_LEFT'] = '\xee\x80\xaf',
		['ICON_FA_CHEVRON_RIGHT'] = '\xee\x80\xb0',
		['ICON_FA_CHECK_CIRCLE'] = '\xee\x80\xb1',
		['ICON_FA_EXCLAMATION_CIRCLE'] = '\xee\x80\xb2',
		['ICON_FA_AT'] = '\xee\x80\xb3',
		['ICON_FA_HEADING'] = '\xee\x80\xb4',
		['ICON_FA_WINDOW_RESTORE'] = '\xee\x80\xb5',
		['ICON_FA_TOOLS'] = '\xee\x80\xb6',
		['ICON_FA_GEM'] = '\xee\x80\xb7',
		['ICON_FA_ARROWS_ALT'] = '\xee\x80\xb8',
		['ICON_FA_QUOTE_RIGHT'] = '\xee\x80\xb9',
		['ICON_FA_CHECK'] = '\xee\x80\xba',
		['ICON_FA_LIGHT_COG'] = '\xee\x80\xbb',
		['ICON_FA_LIGHT_INFO_CIRCLE'] = '\xee\x80\xbc',
		['ICON_FA_DESKTOP'] = '\xee\x80\xbd',
		['ICON_FA_TIMES_CIRCLE'] = '\xee\x80\xbe',
	}

	setmetatable(fa, {
		__call = function(t, v)
			if (type(v) == 'string') then
				return t['ICON_' .. upper(v)] or '?'
			elseif (type(v) == 'number' and v >= fa.min_range and v <= fa.max_range) then
				local t, h = {}, 128
				while v >= h do
					t[#t + 1] = 128 + v % 64
					v = floor(v / 64)
					h = h > 32 and 32 or h * 0.5
				end
				t[#t + 1] = 256 - 2 * h + v
				return char(unpack(t)):reverse()
			end
			return '?'
		end,

		__index = function(t, i)
			if type(i) == 'string' then
				if i == 'min_range' then
					return 0xe000
				elseif i == 'max_range' then
					return 0xe03e
				end
			end
		
			return t[i]
		end
	})
-- icon fonts

function imgui.ColorConvertFloat4ToARGB(float4)
	local abgr = imgui.ColorConvertFloat4ToU32(float4)
	local a, b, g, r = explode_U32(abgr)
	return join_argb(a, r, g, b)
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

function explode_U32(u32)
	local a = bit.band(bit.rshift(u32, 24), 0xFF)
	local r = bit.band(bit.rshift(u32, 16), 0xFF)
	local g = bit.band(bit.rshift(u32, 8), 0xFF)
	local b = bit.band(u32, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function vec4ToFloat4(vec4, type)
	type = type or 1
	if type == 1 then
		return new.float[4](vec4.x, vec4.y, vec4.z, vec4.w)
	else
		return new.float[4](vec4.z, vec4.y, vec4.x, vec4.w)
	end
end

function ARGBtoStringRGB(abgr)
	local a, r, g, b = explode_U32(abgr)
	local argb = join_argb(a, r, g, b)
	local color = ('%x'):format(bit.band(argb, 0xFFFFFF))
	return ('{%s%s}'):format(('0'):rep(6 - #color), color)
end

function ColorAccentsAdapter(color)
	local function ARGBtoRGB(color)
		return bit.band(color, 0xFFFFFF)
	end
	local a, r, g, b = explode_argb(color)

	local ret = {a = a, r = r, g = g, b = b}

	function ret:apply_alpha(alpha)
		self.a = alpha
		return self
	end

	function ret:as_u32()
		return join_argb(self.a, self.b, self.g, self.r)
	end

	function ret:as_vec4()
		return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
	end

	function ret:as_argb()
		return join_argb(self.a, self.r, self.g, self.b)
	end

	function ret:as_rgba()
		return join_argb(self.r, self.g, self.b, self.a)
	end

	function ret:as_chat()
		return format('%06X', ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
	end

	return ret
end

local ScreenSizeX, ScreenSizeY		= getScreenResolution()
local alphaAnimTime					= 0.3
local getmyrank						= false

local windowtype					= new.int(0)
local sobesetap						= new.int(0)
local lastsobesetap					= new.int(0)
local newwindowtype					= new.int(1)
local clienttype					= new.int(0)
local leadertype					= new.int(0)
local Licenses_select				= new.int(0)
local Licenses_Arr					= {u8'Авто',u8'Мото',u8'Рыболовство',u8'Плавание',u8'Оружие',u8'Охоту',u8'Раскопки',u8'Такси'}
local QuestionType_select			= new.int(0)
local Ranks_select					= new.int(0)
local sobesdecline_select			= new.int(0)
local uninvitebuf					= new.char[256]()
local blacklistbuf					= new.char[256]()
local uninvitebox					= new.bool(false)
local blacklistbuff					= new.char[256]()
local fwarnbuff						= new.char[256]()
local fmutebuff						= new.char[256]()
local fmuteint						= new.int(0)
local lastq							= new.int(0)
local autoupd						= new.int(-600)
local now_zametka					= new.int(1)
local zametka_window				= new.int(1)
local search_rule					= new.char[256]()
local rule_align					= new.int(configuration.main_settings.rule_align)
local auto_update_box				= new.bool(configuration.main_settings.autoupdate)
local get_beta_upd_box				= new.bool(configuration.main_settings.getbetaupd)

local lections						= {}
local questions						= {}
local serverquestions				= {}
local ruless						= {}
local zametki						= {}
local dephistory					= {}
local updateinfo					= {}
local LastActiveTime				= {}
local LastActive					= {}

local notf_sX, notf_sY				= convertGameScreenCoordsToWindowScreenCoords(605, 438)
local notify						= {
	msg = {},
	pos = {x = notf_sX - 200, y = notf_sY - 70}
}
notf_sX, notf_sY = nil, nil

local mainwindow					= new.int(0)
local settingswindow				= new.int(1)
local additionalwindow				= new.int(1)
local infowindow					= new.int(1)
local monetstylechromaselect		= new.float[1](configuration.main_settings.monetstyle_chroma)
local alpha							= new.float[1](0)

local windows = {
	imgui_settings 					= new.bool(),
	imgui_fm 						= new.bool(),
	imgui_binder 					= new.bool(),
	imgui_lect						= new.bool(),
	imgui_depart					= new.bool(),
	imgui_changelog					= new.bool(configuration.main_settings.changelog),
	imgui_fmstylechoose				= new.bool(configuration.main_settings.fmstyle == nil),
	imgui_zametka					= new.bool(false),
}
local bindersettings = {
	binderbuff 						= new.char[4096](),
	bindername 						= new.char[40](),
	binderdelay 					= new.char[7](),
	bindertype 						= new.int(0),
	bindercmd 						= new.char[15](),
	binderbtn						= '',
}
local chatcolors = {
	RChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)),
	DChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)),
	ASChatColor 					= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)),
}
local usersettings = {
	createmarker 					= new.bool(configuration.main_settings.createmarker),
	dorponcmd						= new.bool(configuration.main_settings.dorponcmd),
	replacechat						= new.bool(configuration.main_settings.replacechat),
	replaceash						= new.bool(configuration.main_settings.replaceash),
	dofastscreen					= new.bool(configuration.main_settings.dofastscreen),
	dofastexpel						= new.bool(configuration.main_settings.dofastexpel),
	noscrollbar						= new.bool(configuration.main_settings.noscrollbar),
	playdubinka						= new.bool(configuration.main_settings.playdubinka),
	statsvisible					= new.bool(configuration.main_settings.statsvisible),
	checkmcongun					= new.bool(configuration.main_settings.checkmcongun),
	checkmconhunt					= new.bool(configuration.main_settings.checkmconhunt),
	bodyrank						= new.bool(configuration.main_settings.bodyrank),
	chatrank						= new.bool(configuration.main_settings.chatrank),
	playcd							= new.float[1](configuration.main_settings.playcd / 1000),
	myname 							= new.char[256](configuration.main_settings.myname),
	myaccent 						= new.char[256](configuration.main_settings.myaccent),
	gender 							= new.int(configuration.main_settings.gender),
	fmtype							= new.int(configuration.main_settings.fmtype),
	fmstyle							= new.int(configuration.main_settings.fmstyle or 2),
	expelreason						= new.char[256](u8(configuration.main_settings.expelreason)),
	usefastmenucmd					= new.char[256](u8(configuration.main_settings.usefastmenucmd)),
	moonmonetcolorselect			= vec4ToFloat4(ColorAccentsAdapter(configuration.main_settings.monetstyle):as_vec4()),
}
local pricelist = {
	avtoprice 						= new.char[7](tostring(configuration.main_settings.avtoprice)),
	motoprice 						= new.char[7](tostring(configuration.main_settings.motoprice)),
	ribaprice 						= new.char[7](tostring(configuration.main_settings.ribaprice)),
	lodkaprice 						= new.char[7](tostring(configuration.main_settings.lodkaprice)),
	gunaprice 						= new.char[7](tostring(configuration.main_settings.gunaprice)),
	huntprice 						= new.char[7](tostring(configuration.main_settings.huntprice)),
	kladprice						= new.char[7](tostring(configuration.main_settings.kladprice)),
	taxiprice						= new.char[7](tostring(configuration.main_settings.taxiprice))
}
local tHotKeyData = {
	edit 							= nil,
	save 							= {},
	lasted 							= clock(),
}
local lectionsettings = {
	lection_type					= new.int(configuration.main_settings.lection_type),
	lection_delay					= new.int(configuration.main_settings.lection_delay),
	lection_name					= new.char[256](),
	lection_text					= new.char[65536](),
}
local zametkisettings = {
	zametkaname						= new.char[256](),
	zametkatext						= new.char[4096](),
	zametkacmd						= new.char[256](),
	zametkabtn						= '',
}
local departsettings = {
	myorgname						= new.char[50](u8(configuration.main_settings.astag)),
	toorgname						= new.char[50](),
	frequency						= new.char[7](),
	myorgtext						= new.char[256](),
}
local questionsettings = {
	questionname					= new.char[256](),
	questionhint					= new.char[256](),
	questionques					= new.char[256](),
}
local sobes_settings = {
	pass							= new.bool(configuration.sobes_settings.pass),
	medcard							= new.bool(configuration.sobes_settings.medcard),
	wbook							= new.bool(configuration.sobes_settings.wbook),
	licenses						= new.bool(configuration.sobes_settings.licenses),
}
local tagbuttons = {
	{name = '{my_id}',text = 'Пишет Ваш ID.',hint = '/n /showpass {my_id}\n(( /showpass \'Ваш ID\' ))'},
	{name = '{my_name}',text = 'Пишет Ваш ник из настроек.',hint = 'Здравствуйте, я {my_name}\n- Здравствуйте, я Ваше имя.'},
	{name = '{my_rank}',text = 'Пишет Ваш ранг из настроек.',hint = format('/do На груди бейджик {my_rank}\nНа груди бейджик %s', configuration.RankNames[configuration.main_settings.myrankint])},
	{name = '{my_score}',text = 'Пишет Ваш уровень.',hint = 'Я проживаю в штате уже {my_score} лет!\n- Я проживаю в штате уже \'Ваш уровень\' лет!'},
	{name = '{H}',text = 'Пишет системное время в часы.',hint = 'Давай встретимся завтра тут же в {H} \n- Давай встретимся завтра тут же в чч'},
	{name = '{HM}',text = 'Пишет системное время в часы:минуты.',hint = 'Сегодня в {HM} будет концерт!\n- Сегодня в чч:мм будет концерт!'},
	{name = '{HMS}',text = 'Пишет системное время в часы:минуты:секунды.',hint = 'У меня на часах {HMS}\n- У меня на часах \'чч:мм:сс\''},
	{name = '{gender:Текст1|Текст2}',text = 'Пишет сообщение в зависимости от вашего пола.',hint = 'Я вчера {gender:был|была} в банке\n- Если мужской пол: был в банке\n- Если женский пол: была в банке'},
	{name = '@{ID}',text = 'Узнаёт имя игрока по ID.',hint = 'Ты не видел где сейчас @{43}?\n- Ты не видел где сейчас \'Имя 43 ида\''},
	{name = '{close_id}',text = 'Узнаёт ID ближайшего к Вам игрока',hint = 'О, а вот и @{{close_id}}?\nО, а вот и \'Имя ближайшего ида\''},
	{name = '{delay_*}',text = 'Добавляет задержку между сообщениями',hint = 'Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу Вам помочь?\n{delay_2000}\n/do На груди висит бейджик с надписью Лицензёр Автошколы.\n\n[10:54:29] Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу Вам помочь?\n[10:54:31] На груди висит бейджик с надписью Лицензёр Автошколы.'},
}
local buttons = {
	{name='Настройки',text='Пользователь, вид\nскрипта, цены',icon=fa.ICON_FA_LIGHT_COG,y_hovered=10,timer=0},
	{name='Дополнительно',text='Правила, заметки,\nотыгровки, чекер',icon=fa.ICON_FA_FOLDER,y_hovered=10,timer=0},
	{name='Информация',text='Обновления, автор,\nо скрипте',icon=fa.ICON_FA_LIGHT_INFO_CIRCLE,y_hovered=10,timer=0},
}
local fmbuttons = {
	{name = u8'Действия с клиентом', rank = 1},
	{name = u8'Собеседование', rank = 5},
	{name = u8'Проверка устава', rank = 5},
	{name = u8'Лидерские действия', rank = 9},
}
local settingsbuttons = {
	fa.ICON_FA_USER..u8(' Пользователь'),
	fa.ICON_FA_PALETTE..u8(' Вид скрипта'),
	fa.ICON_FA_FILE_ALT..u8(' Цены'),
}

local additionalbuttons = {
	fa.ICON_FA_BOOK_OPEN..u8(' Правила'),
	fa.ICON_FA_QUOTE_RIGHT..u8(' Заметки'),
	fa.ICON_FA_HEADING..u8(' Отыгровки'),
	fa.ICON_FA_DESKTOP..u8(' Чекер'),
}
local infobuttons = {
	fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN..u8(' Обновления'),
	fa.ICON_FA_AT..u8(' Автор'),
	fa.ICON_FA_CODE..u8(' О скрипте'),
}
local checker_variables = {
	state = imgui.new.bool(configuration.Checker.state),
	delay = imgui.new.int(configuration.Checker.delay),
	note_input = imgui.new.char[256](),

	font_input = imgui.new.char[256](u8(configuration.Checker.font_name)),
	font_size = imgui.new.int(configuration.Checker.font_size),
	font_flag = imgui.new.int(configuration.Checker.font_flag),
	font_offset = imgui.new.int(configuration.Checker.font_offset),
	font_alpha = imgui.new.int(configuration.Checker.font_alpha / 2.55),

	afk_max_l = imgui.new.int(configuration.Checker.afk_max_l),
	afk_max_h = imgui.new.int(configuration.Checker.afk_max_h),

	show = {
		id = imgui.new.bool(configuration.Checker.show_id),
		rank = imgui.new.bool(configuration.Checker.show_rank),
		afk = imgui.new.bool(configuration.Checker.show_afk),
		warn = imgui.new.bool(configuration.Checker.show_warn),
		mute = imgui.new.bool(configuration.Checker.show_mute),
		uniform = imgui.new.bool(configuration.Checker.show_uniform),
		near = imgui.new.bool(configuration.Checker.show_near),
	},

	col = {
		title = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_title), 2),
		default = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_default), 2),
		no_work = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_no_work), 2),
		afk_max = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_afk_max), 2),
		note = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.Checker.col_note), 2),
	},

	online = {afk = 0, online = 0},
	bodyranks = {},

	await = {
		members = false,
		next_page = {
			bool = false,
			i = 0
		}
	},

	temp_player_data = nil,
	last_check = 0,
	dontShowMeMembers = false,
	lastDialogWasActive = clock(),
	font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
}

local ash_image
local font = {}

imgui.OnInitialize(function()
	-- >> BASE85 DATA <<
		local circle_data = '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x30\x00\x00\x00\x30\x08\x06\x00\x00\x00\x57\x02\xF9\x87\x00\x00\x00\x06\x62\x4B\x47\x44\x00\xFF\x00\xFF\x00\xFF\xA0\xBD\xA7\x93\x00\x00\x09\xC8\x49\x44\x41\x54\x68\x81\xED\x99\x4B\x6C\x5C\xE7\x75\xC7\x7F\xE7\x7C\x77\x5E\xE4\x50\x24\x25\xCA\x7A\x90\xB4\x4D\xD3\x92\x9C\xBA\x8E\x8B\x48\xB2\xA4\xB4\x40\xEC\x04\x79\xD4\x81\xD1\x64\x93\x3E\x9C\x45\xBC\x71\x1D\xD7\x06\x8A\xAE\x5A\x20\x0B\x25\x6D\x36\x45\xBB\x69\xA5\xB4\x46\x90\x02\x2E\xEC\x3E\x50\x20\xC9\xA6\x8B\x3A\x80\xA3\x45\x92\x56\xAA\x92\x58\x71\x6D\x90\x52\x6C\xD9\xA2\x45\x51\xA2\x24\x4A\x7C\x0D\xE7\xF1\x9D\xD3\xC5\xCC\x90\x33\x73\x47\x7C\xA4\x41\xBB\xA8\x0E\xF0\xE1\xBB\x73\xEE\xBD\xDF\xFD\xFD\xBF\x73\xBE\xC7\xBD\x03\x77\xED\xAE\xFD\xFF\x36\xF9\x65\x34\xE2\x1C\xD7\x89\x47\x26\x8F\x54\xA9\x7D\xCC\x6B\x7E\x38\xE2\xFB\xDC\x6C\xC4\xCC\xB6\xED\x1B\x75\x73\xF3\x45\xDC\xA7\xCD\x6D\x52\x22\x67\x1D\xFF\xFE\xF6\x1F\x1E\x39\x23\x1C\xB7\xFF\x53\x01\x17\x8E\x3C\x3D\xE2\x15\x79\xC1\x2C\x3E\x6D\xEE\x23\xD1\x0C\x33\xC3\xDC\x30\x73\xCC\x8C\x07\x87\x0D\xDC\x71\x37\x30\xC7\xAD\x59\xFB\x07\xE6\xF1\x95\xA0\x76\x72\xC7\xE9\x53\x1F\xFC\xAF\x0A\x98\x3E\xF8\xEC\x50\x49\x2A\x7F\xE6\x1E\x9F\x31\xB3\x6C\x1D\xDA\xE9\x2A\x60\x6F\xEC\x02\x6F\xAB\x3E\x33\xAB\xA8\xD9\xDF\x95\xCB\xE5\xAF\x8C\x4C\x9C\xB9\xB1\x55\x16\xDD\xEA\x0D\x97\x8E\x3D\xF3\xBB\x95\x50\x9D\x14\xFC\xF7\x81\xEC\x46\xD7\xAF\x07\xEF\x66\x88\x59\xD6\xCC\x9F\xCB\x84\x64\x72\xE6\x43\x47\x7E\x67\xAB\x3C\x9B\x8E\x80\x1F\x7C\x36\x73\x39\x6B\x27\xCC\xED\xD9\x66\xEF\xD6\x7B\xBA\xD9\xEB\xDD\x23\x30\xBE\xAB\x72\x47\x78\xCC\x70\xF3\x46\x6D\xB8\x3B\x78\xFC\xDB\xDD\x7B\x8A\x2F\xCA\xA9\x53\xB5\xCD\x70\x6D\x2A\x02\xDF\x7F\xF8\x64\xF1\x52\x2E\xF9\x37\xE0\xD9\xCD\x0A\x5E\x15\xBE\x15\x78\x33\x3C\xF2\xDC\x95\x4B\xF3\xDF\xBD\xF6\xFC\xCE\xE2\x66\xDA\xDF\x30\x02\x2F\x1D\x3C\x9B\x59\x9C\xBB\xFD\xDD\x87\x7A\xDF\x7E\xF2\xD1\xE2\xB9\xB6\xDE\x6D\x8F\x00\x50\xC8\xA2\xFD\x45\xA4\x58\x80\x44\x21\x97\xB0\x77\xD0\xF0\x95\x32\x56\x2E\x63\xB7\xE7\x89\xD7\x6F\xE2\x0B\x0B\xDD\xE1\x1B\xBE\xFC\x93\xD3\xE4\x3F\x31\x7B\xAA\x30\x10\x3F\x29\x4F\xB0\x6E\x24\x92\x8D\x04\x54\x16\x4A\x27\x42\x08\x4F\x4E\x2C\xFD\x0A\xE6\xCE\xA3\xC5\x37\x52\x7D\x90\x0C\xF6\x91\x1D\xDE\x05\x85\xEC\x5A\x1A\x35\x04\xA2\x02\xF9\x2C\x9A\xCD\x20\xBD\x3D\xE8\xEE\x7B\xF0\xE5\x12\xB5\xF7\xA6\x88\xB3\xD7\xD3\xF0\xBF\x39\x4D\xCF\x93\x33\x00\x8F\x97\x97\x39\x01\x3C\xB7\x1E\xDF\xBA\x11\x78\xE9\x91\xD3\xBF\x57\x8B\xF1\xD5\x18\x23\x66\x91\x18\x23\xFB\x0A\xFF\xC5\x87\x7B\xDF\xC0\xCC\x20\x9B\x90\x1F\x1F\x81\x9E\x5C\x3D\x2A\x6E\x29\x01\x7B\x06\x6B\x6B\x29\x64\x8D\x29\xB5\x91\x42\x36\xBF\x40\x75\xE2\xE7\x58\x69\xA5\x0E\xFF\x99\x69\x0A\x75\xF8\x56\xC2\xA7\x0B\x9F\xE5\x1F\xB6\x2C\xE0\xE5\xC7\x4E\xEF\x58\x59\x96\x09\xC7\x87\x62\x03\x7E\x55\x44\xFE\x4D\x7E\x6D\xD7\x24\xF9\x7D\xA3\x78\xD0\x06\xF4\x1D\x04\xF4\x57\xBB\xC2\x37\x7B\xDC\x2A\x15\xAA\x13\x17\xC8\x1E\x9D\xA4\xF0\x99\x99\x34\x88\x70\xB3\x26\x1C\xD8\xF6\x14\xD7\xBB\x71\xDE\x71\x10\x57\xAB\xC9\xD7\x35\xE8\x90\x88\x10\x34\x10\x42\x40\x1B\xF5\x54\xF6\x23\xCC\xDC\xFB\x38\x92\xD9\x30\x03\xD7\x85\x77\x33\x44\x95\xE2\x33\x03\xF4\x3C\xB5\x02\x46\xBA\x44\xB6\x67\x6A\x7C\xED\x4E\xED\x77\x8D\xC0\x37\x3F\x7C\x6E\x24\x04\x7B\xC7\xDC\xB2\xEE\xF5\x01\xEB\xEE\x44\x8B\x48\x02\xF7\x3C\x5C\xC4\x83\x31\x9A\x79\x87\xB1\xFC\x85\x75\x23\xB0\xAB\xB7\x74\x47\x78\xCC\xC8\x1E\xBE\x4E\xF6\xE8\x4D\xDC\xAA\xC4\xAB\x3F\x81\x58\xEA\xDA\x9F\x92\x30\xDE\xF3\x39\xA6\x3A\x4F\x74\xED\xC2\x24\xE3\x2F\xE0\x92\x55\x14\xC3\x50\x55\xCC\x8C\xA0\x81\xA1\x87\x7A\xC9\xE4\x95\x18\x23\x53\xD5\x71\xDC\x9D\xFB\x72\xE7\x57\xEF\xD5\x42\x8E\xEC\xD0\x20\x5A\xEC\xC1\x73\x09\xB9\xDE\x88\x95\x56\xB0\xB9\x39\x6A\x33\xD7\x60\x71\x69\x0D\xFE\xD0\x75\xB2\x8F\xDD\x04\x03\x21\x43\x18\xFC\x10\xF1\xDA\x4F\xBA\x21\x65\xA8\xF0\x3C\xF0\x27\x1B\x46\xE0\x38\xAE\xF7\x1F\xFC\xD9\xFB\xC0\x88\xBB\xE3\x5E\xEF\x59\x77\x27\x37\x98\xB0\x63\xBC\xA7\x3E\x7D\xBA\x11\x63\x24\x5A\x64\x6F\xF8\x39\xF7\xE7\xCF\x93\xBD\x77\x17\x61\x68\x70\x35\x0A\xD1\x8C\xC1\xDE\xB8\xD6\xFB\x31\x52\x9B\xBE\x4A\xED\xE2\xFB\x64\x3E\x72\x8D\xEC\xE1\x9B\x29\x52\xBB\xF1\x16\xB6\x32\xDB\x4D\xC4\x54\xEF\x04\xF7\xCB\x71\xDA\x36\x80\xA9\x08\x8C\x3D\xF6\xE6\x11\x4C\x46\xDC\x1D\x91\xBA\xBE\x66\x24\xB6\x8F\xF6\x20\x2A\xA8\x35\x86\x4E\xA8\x57\x57\xFC\x41\xB6\x8F\xDD\xC3\xDE\xA1\x39\x62\x8C\x6D\xED\xAD\xA5\x4E\xBD\x13\x74\xD7\x10\x85\x47\x97\x91\x9D\x93\x78\xB7\xBD\x68\xDF\x18\x2C\x75\x15\x30\x5A\xDA\xC7\x21\xE0\x4C\xAB\x33\x3D\x88\xCD\x9F\x00\x56\xE1\x45\x04\x11\x21\x57\xCC\x90\x14\x02\x2A\x5A\x17\x21\x8A\x8A\x12\x42\x60\x68\x6C\x1B\x8B\x7D\x63\x5C\xAD\xEE\x49\x3F\xB6\x09\xDF\x28\xC9\x03\xF3\x64\x1E\x09\x84\xBE\x07\x21\x92\x2A\x22\x3D\x78\xE8\xC3\x8D\x54\xA9\x19\x1F\xEB\x6C\x3E\x2D\xC0\xF5\x50\xF3\xB0\x55\x44\x61\x7B\x06\x9A\x11\x69\x11\x91\xEB\xC9\xD0\xBF\xBB\x80\xAA\x72\xDB\xF6\x30\x5B\xDB\xDB\xDE\x5C\x2B\xFC\xD8\x3C\xC9\xD8\x42\x3D\xE7\xF3\xC3\x10\x8A\x5D\x41\x25\xB7\xA3\xAB\x1F\xE3\xB1\x8D\x05\x88\xEF\x6F\x1D\x1A\x4D\x11\xB9\x62\x68\x3A\xDA\x44\x14\x77\xE5\xD6\x22\xA2\xCA\x3C\xC3\xDC\x88\xC3\x29\x01\xE1\xBE\x79\xC2\x7D\x0B\x78\xA4\x5E\x0C\x24\xBF\xBB\x7B\x14\xC2\x40\x57\x3F\x91\x7D\x9D\xB8\xA9\x31\x20\x22\x7B\xDC\xA1\x2E\xC2\x57\x45\x68\x56\xD7\x3C\x22\xE0\x8E\x8A\x52\x18\xC8\x00\x82\x48\x7D\xAC\xA0\xB0\x60\x23\xB8\x3B\xFD\x5C\xAA\xC3\xDF\x3B\x4F\xB8\xB7\x0E\xDF\xFE\xF4\xED\x5D\xC7\x81\x4B\xB6\xFB\xF8\x80\xE1\x4E\x47\x4A\x80\x09\xFD\x0A\xA4\x44\xE4\x02\xE0\x29\x11\x92\xD3\xC6\x61\xBB\x88\x45\x1B\xC5\x3D\x32\x30\x7A\x86\x30\x5A\x4F\x9B\xB4\xE5\xD2\xA2\x1A\xFE\xEE\xD7\xD3\xB7\xA1\x80\x17\x46\x66\x22\xAB\xF3\xCB\x9A\x7D\x74\xA8\x42\xE8\xB2\x6E\xFF\x7A\xBF\x74\xF5\x03\xD0\x3F\xCE\x6F\x3C\xF0\x2E\xC7\x0A\x09\x1A\x72\x48\xC8\x81\x34\x9B\x16\x70\x23\xB7\xA3\x65\xE1\x6A\xA4\x27\x6E\x30\x5E\xE8\x98\xE4\x05\xDC\x03\xBC\xB6\xBE\x00\x11\x16\x81\xED\x9D\xFE\x9A\x19\x99\x24\xA5\x8B\x4A\x34\x7A\xBB\xF8\xBD\x2F\x8F\x0C\xE4\xF9\x69\x65\x27\x88\x70\x2C\x3F\x87\x42\x8B\x08\x07\x2B\x77\xDC\xE4\x0D\x11\xD5\xC6\x6F\x5A\x44\x38\x88\xDC\xEA\x7C\x4E\x4A\x80\xAA\x4E\xE3\x9E\x16\x10\x1D\xD5\xF4\xCE\x63\x71\x39\xD2\xDF\x93\x69\xF3\xC5\x62\x16\xB6\xE5\x91\xC6\xF5\x6F\x54\xEF\x41\x44\x38\x9A\xBB\xD9\x2E\xA2\x36\x87\x7B\x0D\x91\x16\x0C\x77\xB0\xEA\x1A\x7D\xBB\x88\x2B\x29\xDE\x4E\x47\x40\xCE\xAB\xD6\x67\x94\xD6\x32\x5F\xB2\x94\x4F\x55\xB9\x32\x57\x21\xA8\x92\x84\x40\x12\x02\xBE\x2D\x8F\x37\xE0\x5B\x05\x9F\x8B\xBB\x38\x5D\xD9\x81\xC5\x32\x1E\xCB\xE0\x35\xAC\x7C\x19\x62\x05\xF7\x8E\x77\x96\xB8\xD0\x04\x6E\xAB\x40\x26\x36\x14\x20\x2A\xFF\xA9\x8D\x87\xB7\x96\x5B\x8B\x35\x92\xA0\xA9\x52\xA9\x39\x57\x6F\x57\xC9\x24\x81\x58\xCC\x11\x8B\xD9\x55\xF8\xCE\x88\x9D\xB3\xDD\x9C\xA9\x0D\x61\xB1\x4C\x5C\x7A\x17\xAF\xCE\xE1\x56\x4E\x89\xF0\x6A\xEB\x16\xA3\x45\x84\xF3\xE3\x4E\xDE\x54\x0A\x25\x09\xA7\xDC\xD3\xA3\x72\xB9\x62\x94\xAB\x4E\x4F\x3E\x9D\xEF\x17\x67\x4A\xE4\x76\x16\x28\xF4\x26\x6D\xF0\xD2\x65\x70\x9F\xF3\x3D\xD4\x56\x16\x38\x5A\x7A\x0B\xD1\xB5\xD4\x13\xC0\x03\x88\x95\xF1\xDA\x6D\xD0\x2C\xA2\x4D\xBC\x46\x1E\x99\xBC\xDE\xD9\x5E\xEA\x11\x57\x5F\x7D\xFC\x74\x08\xFA\x7E\x08\x4A\x5B\x51\x65\x6A\xB6\xBC\x9A\x2A\xAD\xA5\x32\x98\xE7\xEC\x92\x33\xB3\x54\x5B\x15\x20\x4A\x2A\x02\xEE\x30\xB3\x7C\x8B\x97\x6F\x28\xDF\xAE\x8C\xE3\x56\xC1\x63\xB9\x5E\x37\x22\x61\xCB\xE7\xC1\x9A\xBE\xD6\xD4\xF2\x4B\x3C\x7C\x74\xE3\x08\x80\x78\x08\x3F\xF8\x47\x90\x3F\xEE\x3C\x73\x63\xA9\xCA\x72\xD9\xD8\xD6\xB3\x76\xDB\x72\x5F\x96\x72\x7F\x16\x05\xDE\xB9\x55\xE5\x5A\xC9\xD8\xB3\x2D\xC3\xF6\xDE\x40\x4F\x10\xDC\x8D\x4A\xAD\xCA\xFC\xCA\x0A\xD7\xCB\xF3\xAC\x78\x0D\x51\xE5\x35\xDB\x8F\x54\x85\xCF\x67\x2E\xAC\x21\xC6\xDB\xF8\xCA\x65\x44\xB3\x2D\x2B\x10\xF5\x48\x08\xAF\x88\xA4\x3F\x45\x76\x7F\xA5\x32\x3D\x91\x64\xE4\x8F\xE8\xF2\xE1\x6A\xE2\x83\x25\x0E\xEF\x1F\x20\x9B\x28\x0B\xBD\x09\xA5\xBE\x0C\x2A\x6B\x3D\xBE\x1C\x9D\x8B\xB7\xAB\xBC\xB7\x50\x43\x14\xB2\x99\x0B\x48\x50\x44\xEB\x45\x5B\x16\x8D\xD7\xFC\x00\x44\xE1\xF3\x9C\xAF\x8F\x81\xA5\x73\x2D\xD8\xAD\xCB\x28\x65\xC9\xC8\x37\xBA\xA1\x76\x5D\x82\x3E\xF8\xFB\x8F\x5E\x4E\x82\x7E\x2B\x95\x46\x41\xA9\x46\xE7\xED\xA9\x45\x16\x7A\x12\x96\x3A\xE0\xD7\xD2\xA7\x7B\x0A\x75\xB3\xEF\xF1\x10\xDF\x89\xE3\xD8\xFC\x8F\xB1\xEA\x7C\x4B\x4A\x55\xF0\x58\x69\xA6\xD3\x37\xE5\xC0\xEB\x97\x37\x2D\x00\x20\x17\xE3\x57\x92\x10\xAE\x77\xCB\xF9\x2B\xF9\x2C\x3F\x2A\x19\x35\x63\x5D\xF8\xE6\x46\x70\x3D\xAB\x79\xE4\xAF\x6E\x0D\x70\xA2\xB4\xBF\x05\xBC\x4D\xC4\x0D\xAD\xAC\x7C\xF5\x4E\xF7\xA7\xA7\x94\x86\xCD\xFE\xF4\x5B\xA5\xDD\xC7\x9E\xBB\x18\x54\xBE\x10\x54\x68\x96\xC5\xC1\x3C\x0B\x83\x79\xAA\x06\x37\xCB\x91\xFE\x42\x20\x9F\xD1\xAE\xF0\xAA\x82\x70\xAE\xEE\x6F\xBC\x57\xB4\x1E\x2F\xD6\xCA\x4C\xDC\xBA\xCC\x72\xAC\xF0\xA6\x0C\x53\x71\xE5\xB0\x5C\x5A\x83\x10\x41\xC4\xBF\x14\x0E\xBD\x79\x76\xCB\x02\x00\x66\xCF\xBC\xF4\xF6\x9E\x63\xCF\xEF\x0E\xAA\x87\x54\x95\x5B\xFD\x39\x6E\x0F\xE4\x56\x67\x99\x88\x70\x6D\xD9\x28\x45\x28\xE6\x94\x6C\x46\xDA\xE1\x15\xF0\xB4\x80\x95\x58\xE1\xBD\x85\x6B\x5C\x5A\xBA\x4E\xC4\x56\xCF\xFD\x4C\x46\x1A\x22\xDE\xAF\xF3\x23\x27\x33\x47\x2E\xFE\xC5\x7A\x8C\x1B\x7E\x17\xD9\x3F\x3D\xF9\xC2\xBB\xF7\xFF\xEA\x03\x37\x7B\xF5\x53\xB7\x8A\xC9\x2A\x58\x6B\xCA\xDC\x28\x45\xE6\xCA\x46\x5F\x3E\x30\xD4\x1B\x18\x2C\x24\xE4\x33\xD0\x13\x20\xBA\x51\x8D\x35\x2A\xD1\x59\xA8\x96\x98\xAF\x95\x58\x8E\xD5\x7A\x1B\x41\xE9\x7C\x2D\x7F\x45\x8E\x20\x2E\x7C\xD9\xFE\xE3\x5F\x33\xD5\xD9\x3F\xDC\x88\x6F\x53\x5F\xA7\x77\x1E\x7F\xAB\x58\x2E\xE6\xFE\x49\x55\x3E\xDB\x09\x2F\x42\x4B\xFA\x08\xAA\xB4\x44\x40\x08\xFA\xA7\xF5\x73\x8D\x99\x48\xB5\x39\x23\x49\xFB\xEC\xA4\xB2\x7A\x5C\xD4\xEA\xEB\x2F\xC6\x7F\xFF\xAD\x2F\x3C\x71\x6A\x71\x23\xB6\x4D\x7D\x9D\x9E\x3D\xFE\xF0\xE2\xFC\xE2\xD4\xE7\x24\xF0\x37\x5B\x81\xEF\xB6\x12\x6F\x64\x82\x7C\x23\xC4\xDC\xA7\x37\x03\x5F\xBF\x7E\x8B\xB6\xF3\xAF\x2F\xFE\x36\x41\x4E\x88\x30\xB4\x11\xBC\xAA\x80\x7D\x6D\x53\x11\x10\x95\x1B\x2A\xF2\xE5\x37\x3E\xF1\xF5\x7F\xD9\x0A\xCF\x96\xFB\x68\xF6\xC5\xB1\x7F\xCE\x65\xC3\x01\x55\x3D\x29\x2A\xE5\xF5\xE0\x9B\xDB\xE9\x0D\xAC\x0C\x9C\x8C\xB5\xEC\xFE\xAD\xC2\xC3\xFF\xF0\x4F\xBE\x91\x97\xA7\x86\xC5\xFD\x0F\x40\xBF\xA8\x2A\xA3\x9D\xF0\x22\x82\x55\x8F\xDF\x21\x02\x5C\xD2\x44\x5F\xAD\x06\x3D\x31\xF9\xA9\x3F\x9F\xFE\x45\x19\x7E\x29\x7F\xB3\x72\xDC\x75\x6C\xDF\xCC\x21\x11\xFF\x38\x41\x0E\xAA\xC8\x01\x11\x19\x16\xF5\xFE\x58\xFE\x6A\x4D\x54\x97\x44\x65\x8A\xA0\x17\x54\xE4\x4C\x92\x24\xA7\xDE\x7A\xEA\x2F\xCF\x22\x2D\xFB\x86\xBB\x76\xD7\xEE\xDA\x2F\x64\xFF\x0D\xB3\xFD\xCF\x34\x8B\x75\x5E\xF4\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82'
		local font85 = "7])#######-Nudj'/###[),##1xL$#Q6>##e@;*>mnM]g8g@J1NA'o/fY;99)M7%#>(m<-0;Bk0'Tx-3HTVck7+:GDAk=qAqV,-GU;P1oK3Qlf&bY98<gXG-$ogl8T(ofL,i;;$%J%/GT_Ae?eaQ3UZAkW%,5LsCaOZ2@<3bKV9*U2Ub';9C8A'YS#9^ooU2cD4AJr9.wYhlJ5drV.V3dW.;h^`I(A_4fH$4>d.hiW%o6Q<B8nXJ;)qBe*T4b(N0iR/G^Hm7[)nC2:V'q?-qmnUCko,.D39N?6O'WHa@C=GH+?k=YJ^k&u^hmiUn_>C#*lpFA=Jws'alVP&S9w0#7EL37WZ3N0*2@&v-HUn#P96&M[bm##>-Lt:EE,WebMcf1G$i--$MBDNgmH&#f:J88u0p88R+vr$8OL^#$,>>#sn&W74xD_&OG:;$W'.;Ql_o6*NT[fCuK1m9+.Vp.2h[%#?I]6E$2ffL5D,s-:pwFM8wA,2.,<6CpYw:#YZA`ah`cf1R3hP97@cA#2o&i#k7?>#EGMJ(+hX]YR;:2Lwos#v^X/&v#,###FLV2M1M#<-6q.>-?XT;-ITiiLv=lCNjCZY#P-4F7'nS2LMlw+M;p)*M_VjfLKI(DN2c7`aR:@`a]v8.$S?mxu.]]F-KWs#0P3w,vf[/&v#*tnLoU@`aT]Uk+$A=gLO%g+MrY#<-.fG<-3NvD-3r0@/*%4A#Y'N+NDET%P?CYcM9BN/NdaW^O*:$##Zp8.$c+?>#(ok&#cHwu#Fle&,GP4;-2Iq>$exdw'mA%&vYfGxkCJOV-Bbu&#*`$s$TGxjLO:?>#(WI&#%DbA#[.@W&0Q/@#<Vtn-'C<L#(I`0#SUu>#Y'9M#9i+u#w:o1$`7a%$YwQO$of0F$9C:r$5(3d$]]i4%iLH(%@`;<%Sq]E%q+]l%kYB^%_C'#&RF]9&kAEl&*un-'&[hr&$KR%'$_F6'C/`G'FSiO'I'YY'Lj?o':[BF(gKx9(%]Kb(]hg')lsfnLxA6##L5Ev5i(),#-Mc##Y@2##HJ8K%G(7B3hq^`jmb%Z#'fX&#rax6*7fx6*`Hbs$f&:;]G]eF3V$nO(]ax9.E';sC4x(cuj+CD3w45w$8A6`ai+`%b:aBj(VcQEn1.f(#d,>>#ZO1x5OZ'u$ZVd8/)$fF4R#s'4P4vr-;`tw5?3lD#XMc7*6#Ui)6gE.3Z_[@#fCb6&n/)ZuOluN'Bobs&i_gi#7+W*%Hr^B%gqk:&mpN?M;<Ilfbm_&PK-kT%ZR`e$%=4C&(_s)%%1]jLX]WV$+QX+`H_0SeUi8>,v)BJ1Xn$##6/QA#*r+gLd^xD*L@[s$tPYx69?RF4PDRv$X_EG%Dl*x'`'6(Q`cEc<<5Wk'II3LDdv2k'CPl.)A]<F3a&<;R>'wC#VB$pKHHKW7L_p]$xDF:Ks9[eur4Cw-BXbRMO=qKMvxuOMRR?>#<s%#,#*%/Cx,3(#Av.l'[cZ_#aY?C#[HSP/W>uD4R`>lLD5M.2m<2W$Zg6d)hDMs$l])mJ?@g*%@/Q,*JaiX-Blx7*YbPg1;>uu#IOxUd,Bo._Uh`i0Vh$##`bLs-;va.3Y?]s$;Go_4twC.3ig'u$&Pto7rLd&4x?7f3x8Qv$a&SF48u_qQ996DfT=Pw$`W49%]8;4'ro%L(g;vn&KR[x,wkR8/EN]a+ISg'/1b5]7Tj#;%PHT6&]Z>3'bClZ,R9,n&O;%1(u8X?6=vkZ-lPwTMOFZY#WY,]k`Qg(WV4lr-Zg>A4t(4I)YEo8%8>%&4+J,G46FVt-/,698rGt87q+gY,d;v3'e?)Q&ObHXJ;K'E<7h3I)nL3GVCRMZuMSKU%X4*p%IXD%&4F=@$s=Id%`c`W%?39A=M[wo%glLW&kZW$#]qbf(0k'u$ok&Y.%<:H*dxrB#7(RW-ep3achtGWM3Txo%D9Ou-cW,n&Jfl-$$vp>?%GnjQZtT;.S=8*+O*Lo&cjsa*Qr2d*(f.;5<:G>#Sg[%#jrgo.^nr?#&Y@C#8n&s$i<a>0bR(f)N0D.3g].HF`RP%tTv5;%T(qB%uS,>JFE-<1?AKAt95k0Eb`o6*?:5gL#W20(e6Fr.u*T*5vn4R*g0@.#'5P:vqDG`a*<li'r)#,2c6%##d#f<CA)'J3TEW@,bkh8.7Lm<-Me`=-We`=-=-f6/EUET%^@F,MCYk[t&c-NUC_39%a6We$pnd6Oenh^%KGKb.wUkA#0@D9.>5u;-Qq0I$#Sg%OU[;;$WooE[sqLF[&6+#(.gIkXs)eR*[%`AP[p7S[)i@W@;:@W$ie#W-qScDS:=(?%R%)@0vOkxu-%H<-$OsM-Kqeg+.%&?7fb&4QN0Iq7]UE=_B/EdFIPcd$_;kb[BRoC&]wC'8aXbxujtFH2%/5##9ZhR#Q`U7#[?O&#`%.63xZ*G4[m5%-IckV-a-ji0Xfgs7omrXI`DuZGAiuYucFs.Li%'/)Jg=A#Eo];1dDI-)oXV]=R9DC+EJt;0HF]:d,Bo._+c`$'w6$`48tFA#lL*L>e?85/85xD*RtC.3[5ZA#xflMri:3D#HC+[.e,_6&&VgQ&Z^(99AE&2B6L_X%g,16&n%:bQ`CYE9osC0(5Q([,0`%C#jkW999f5gLXX:T7BA$vLU,qXuHi:kk`Ia$'A#QA#Gt@m'II#d0c<jv6Z)YA#M$+mLtk*J-^(29.b6FA#^MlD4w3::)#5r1TOq[W$m`w1(gYBu$Osus-EBniL+uKb*.x_5/Lw*t$*b1hL(^p@#6kGR&W<;@G]HkT%hmT/)NUupoH]Dd*?9T'M_])w$trF,ikj5c*M3fS(?>cuu:g-o#'_U7#EPj)#cUG+#$2QA#g'ok92%?g)6f<X(@eA7/+IA8%L@Gm'VAqB#9`]q)K:n=7Z&PA#w0`.3Sh+<%VT4J*33w,*obQP//p^I*$sun&%rqX%e5_6&5<Zv#txvN'dPDg(AnN9%H*Tm&W9tP&Q*X=$;$D?Y7sM)3dew/W4Rp:%Qe3*,`lNa*Uiqm9R1s20H@L-2PObV$tNA30.:>Y%Sj(0(7_P:&D'Ot$(FK/L*oaPoRAj6tVH6I6#&JfLXq-##Wh5r#u_V4#V$(,)oQW@,t-pfL=T]s$kHuD#T^WjLOa`221n,Y%0tSc3fFs_,A8od)=Ln8%f&/F4tMFT[r;^lSD#-b<pGc40i^iB>_Q>n&cP>B,Irl>#LOT6&[VhhLXMvu#P4)eahuC`argai0c6%##O?jb$-2ZZeYAOZ6%vYT%:;gF4Woc;-#LHa$M=-Q8+`<$6N/ob4PF[p%hCBTTh2P,OM?0rm95k0EqW)J<HY.cV/Fwe4r>;@.D7u;-9,lC/XaaJ2H]k0;*6$f4D[r%,=d)J<']T.Zlv?D*3v5.Z9lh;-rVPd$6^UaSoH<eQXtDQOIkr]KO/P:vqrX>#q2dc)VaFN(K)'J3M[jJ1n`aI)`Ld5/OwAv-IBap'dvT-%,&AA4fTTM'`S[e,7)$9%FI4]u*Ki?#2muN'L(CTNwxe`*&HhH296a*.RW&F.@Z$I2-*c6&FbU'#%2Puu0HUn#]9i+9r-6Z$>(J'J`**/:P5P3D42.a3IJJ]$(Tu58/7Wd$GW>7&Bp%*'Wg53'kPU&5J:?O2]KVX,@J#v,J0.%,CUwW$T7D?#ptA'+veBG-N%r-4J`psZR:ov$`5VhLf;$##h^YfLQ*88%>u###G]o[+FFvq7o<Zcaf)P=-%Ti].4/sW#+2QD-OY@Q-r^_t%h#&R1K%h,N0UL+*Zj:9/ql4Z,o(b.3-/5[$wmm.)m7-R]e#iEOFO.W$ffew$fhq8.hb:x$P3Ih,MHB$dG-9U%R53K(W5L'#.0L`J-D]aJ@K7l17@[s$Fc7C#^oJF*&2V92/QNp%n:iDF^hsp%<1I'PLGKTS>F@W$)VnQ0:Tf=%iud(#%,Y:v*`(?#d5i$#d$(,)1Dh;-avF%&FDwW]>'af:,ZY>%Bae],MG,@&Z$VgCX;[q&]d^Q&@T_Q&*'YK1CwHC#otC0(D]Vn&J4a6&,Q,nA>)973IG:;$42I9fq@5P][bHP/]]P`<S&Ou.]*'u$`S6C#&R:a#/]NT/<PsD#FOit-puk/Mfd6l13Xrt-6hH&O.NAf3U+X=_2k3B6ENwY%OX<p%rQv@5mesP&ato60IR.W$ab:@,rU0/)NvHH)vP(n)s5hU%NXEp%)B0I$g<n=hs6E`/++t^/RG*I)qs,m:etYb-QB=X$^tm.+?_ap%mndT.#S3X.YAIL((`oC4]3570KE(K(vptg1X>IL(U%15%U8G>#B7>##eH?D*<w4x#'Ga01u?lD#/_v)4na&],4nmk%8CFA#KfZ@-MS[s/%PDZugco$5V%bK(`pVQ1wK8W$e5Zn&:q1E#N4M?-dD24'`2FP(515-3]#4_5#<kB,XfvW.JXi$#S,Qd*?sZxXlee,;nNN?6NfB.*bj9^#]ru8.KRpQ0)PkA#4.m<-QV`X-x0*+%Z####)DluulD:R#7)+&#Rb<9/#&AA4EddI%1QQJ(+w9j0)U5N'ePU:%^L4H)&4d;%AL*N0$W:<-aBND%s>seMZPr.2I+@8%1x<M&J=D?#nl,?#VYAs.USc`%GKg,*E[.O90+dg)UHuD#d@^&BgtG%B:+5gLpP#v,(d[]uaZP$B<aR#v`BmV#Zq=<MRBT_4_)wv-ZI:E4W/Ke=AcvS/KYn3QpLji-cMR#LFnZ)#v]x9vlcaL#Gh1$#j&U'#vu:9/nfZ%-DU`v#q%fX/ELsY$%-U:%erar&kC)?#2HT<$>m'-M1==2K$SRD&$UST%gVw8@<);?#Gr><-jZ9S//.0m&`c>w#3eH_u,U8&&pBop%?iXg1*G'i<A(DeNAO5hL'/6h-r=ge=>d7iLWvJO9+M)<%.;Rv$Sko;7#eXg;Nx.(63U@#:Uj=vGW'3)%/TEt&>N&r0En*IH%]]q)#QU<H'_9N0=:G>#_Yt&#`G>M9&5Kv-POEn<I3rhLZNs?#`xJ+*bX[6/w4NT/'APjLIXTC4^nr?#/xc<-Q+)X-NB@k;5Hr-MHx9+*.i)F7Akdi9A&=61M=l9/?lG>#Cwo2'dcse)x`lj)I:e8%Os5r%[^N3,e3d*7&=+K15#t^-nwr?9%m]^+[<5N'Iq:+*Qjc?6Eo_;$_`wd)6[l]UDe(HMBf$##&#5>#'8G>#0qm(#abY+#nqdT-Z-uG/-]U@,:^9a<r_l8/agocNN%,t6)&Vv-ZI:E4*NYx6?J))3)+ro.Khkj1s3vr-8GTkLTQU&$*/rv-udnX-;X^:/x<j?#BW[iLu]sFr7u$s$Y(0+*twU<-C`5>#TP.K:g/$r%4%@8%'vct$/%lM(aOrr&$^u_)=taX$.&.['2Z(6&>Rn8%w*ci(=&gU'_TBq%TOR8%A[N5&Ckns$ub:@,_l/C4j.d6<&7bs-63Nl(Fe1/)S6Op%4AXi(H(jP0Q^M7'K*#Q#2uq;$=6DhLqIci(Wn7<$/AP>#Sr[+MYV?_#',[0#n0;,#<->>#AV9+*Cid8/@n>V/a%K+*d)UM':]d8/&,]]4#cx:/.BTk+=%k^obRoU/<vKW-B1BnhM1;*%E1B]$EU@lLT$(E#?;Rv$S-2E4):Z;%+73n'*o&02SiWI)j,/]%<[^`3G/?I426w6'^nV?#</m#>+;tE4dc(/:5Emn&@02;&,/s#56-jW))ljp%:Sd9%r#:Q&FwkU%mE/g)M8Co/D@xN'`Qf8%N+AC#j+vw-h(3%$?e<t$&w@.*mu%m0NiTh3Ga',;$*og)K2Ke*G6`E4x0G4:@T$H)_996&-Y<s%J$Xp%21'X%f]V8&@M+mfx`Do&6B(:8HEV,33V`2'Y1%O=6s^=-$(nY#P5YY#@;xu,rNclAS_P_HmVl]#uF]fLl-F<%:q'E#qI[%-$V/)*t:3T%=^WI)R3*7BI&_W7dv@)GjnBH)Ym=]#jPE>/Bqmk'IXEp%9AalA&>dF+H5P?6L#;Q&jbv@&LBHT0:YtH)DONp%(cQ-Hg>6`aj+`%bN?`l8ggN^,T>V/1-<Tv-/.ji0vR7C#_Tld2gc``3J)TF43h;E4x<7f3trLI$UEW@,V])<-an@8%vA+G4Ug$&4bx&X6vjuN's1FV&[7'U)J;<^4lR4U%r>f8'9h:K(XChT7+VRD&<4K-)sH^m&'e7d$IKN8;1N_6&1V=w53+6_+TUW_&4;vP9g)$N'M(gn/?rpq/3lE]'^`49[P`mY#L-&##9*,Q/:WL7#F[P+#[N;t.26MG)`7.[#sSg*%PXkD#TgZ;.[GYd3IPsD#n`h*%]h=^,p*5gLP0vhLoMh<.ms#E36tFe-_+7g)RHKs$TSm0'2v$E3)b'n/;g=[&H.;t-`XrjM<%KB1LP4q&Lk197oTE$P,F?C+D95%lb,Fj180F#P`xP<-%w$iM,U_8Mi9MhL1_duu9^hR#*4mx3(pm(#T%T*#GEOA#B.i?#a1[s$2-Ch$Gc7C#FwIf0[Z*G4pM.)*gCSfL$#9f3bR(f)[/*E*lAqB#.v+G46`W01;?x;$D*K2'OCXk$3o(9.J=HiP3V#=R6$8]Io8@v$b=&NKw2FSR9R8/M+:HZ$UlS#,TeIv?]2ofL_KAw#OHiY(3SB[5g.t3;q,XP(f#Dk']^2IMji&gL.tVV$8;-`as+$kkkGSY,@G*T8W#r6*ffk/M3o,x#l5MG)YAOZ6aA6N':]d8/xE(E#EiaF30ACkLup'E#sJ))3a>BK24vPA#r6eKu9g+G4V1x;%lpKB#RBs%,995Y'NrKa3C<dJ(Oq@@#Z9''PZnqR[=l(?#u4ej'K$u=$js]r.Mk/B-maDgCX@w:%@ooA,.ij?#J`#Z%Id:^u)eGnAdD24'%QmB&T$]<$0>TH*G9R0%IYP>#$5D?#d&_H2kR,E4l,N6f/Lna1651S8eDeK<hR[/;=/$Z$dWq#>=a,g)Jk*W-o*6`Q71A%'F2HlLS-W,;PD3/MB9Ap&/w%'.Ylp:>m^X&#Zt6J=7_XD#<)]L(VS6N:W;Ee+?]x%B.+CJ)wObA#@hh$'@4CJ):3+V.H*.%,(*xfM)rJfLdxQ:v9q;##AQ=8%4V###CX@8%:q'E#.4Kg%R*R2L6[*#'B(`?#_R]?5i9:n/ni$qLkBa?#^ULJ#aL>-M>$;-M=u+8&,,h9;Vk,#AAvN1)`3lD#bF%U.VRI@#@u$:McYCJ)en]m&3iD1'(E*1a2[mxLFNir&KWdgL.0vL'_E0QC_F&@>w06Z$Lw9e?fJ))3oxJ+*%ABp7a/l*X[&KMXJLc>>au7p&3bLg(*tM'%BSm&M/NHMX#-Bs$o@SZP)aAB+?1$=05e+/(-Ga.qOcnW/slU:%fZX,2FsHd)sRF,MI#NT/eMXV/Z?85/1c<9/SP,G4[^<c4OJ,G4osFA#0j5F%a>_,*Q$F[TP?O2&drvv$>&cu-Njv:&>oAt%dmfw#]$<v#bt7Y-HEv3+d,]&Or])w$$O-32H[.LM:Ib70_@#G*mZaZ#GXE5&;`G(+7e:*4[c*M(KBeIM*)4a*Vd/9&1)q;.L2(E5?@%##'&>uu]4>>#JL6(#I]&*#=sgo.0X<-X,fm=7ST.29c9mG*ES%Q-WMN/%7MN=(-tx>*;iS?R$0t>-s)U:%2d7-)&KM-)&cj<%@Cp.)Cos'4L*/@#jQ[-'dtKHM-C:Q$]%WX.$_7tJ<<.k(^&Y:.eOdu-S_%u-QP:%MZL?C+&U,T%s_@C&G####R3n0#4=O5L^hHP/Y'3:.rM[L(Lov[-u?lD#TMrB#S/DD3Gq6Elg754%F>nM>%u.eaB0?MR1S+fa.+CJ)`0Ne$^f,$&8bfCMFl:p.,3h(,[Jw6*'2>;-DluNFopV]+08>5/)WHG)dR&E#^v7B.R4r?#.8'gLoeZd3$M4H)HC)?#97(wL5KihLtk9i%A2;gLBHr-MIt.>-S#fJM+e7iL9mBgMhS3<%f$g;/=V&E#,:3iMtrbI)vEjV;([xV;dPG<-ZvR/&ea*G43>km'-1em'JNXA#SH;2%@vN*']ggQ&8([gLk)JHDHH;2%1rv<_[2vR&Gbp*%i)%t?.KFm'#0$f?:Jl^??gNH*PJ))3?[^:/x)Qv$8^t'>Pp#8/W%am&ob*9%uAg8%WB_ihURxa+HU+`&owr8%(t&4MX$?d$(L@M9VB')3ig'u$C]R_#=qj7%8jE.3TDj?BG?,na_w6u6-E1l:0xoG3w3Tgsia+,%lsRF4K)^/LdB]@#gYgu:P,'F*lKfN0>jD+=Dn8@#wrdN'EUrV$)G6,EAgxkE0uBX%L[<9%cK,m:TxA5=+DAL(tgJ@#Q1iB78(Gj':4P@5Xd52*q:npIDu(v#kI?b>],kI,>nSm&pEEm/jMRiuO^C/)@bL/)9),##kw>V#aC)4#-'Vl-93$4ixVwZ?8&[#6<TIg)rXd+u-GrB#ANU1;#ki-*[*'u$($_O-C_39%l?^;-pMcpRhIblA5Zs>&GiI-?>abA#-oYGMu;gL:bc9N(nN*20KUNK)55%&4Z&:I$(%x[-&8b5A0;nw'*0F6jSNCD3U+BJ)u'nofu1>;-E$V0,PE;61LG+t&hC5Y#or3R/uV?L2Y[3VR`Uo&,Jgma3+_AG2'&>uu@Rl>#TN7%#6&*)#)$B?&qP[]4wj`a4G+^C4D2$w-YpVa4Bl$],Soxu,E'Yt(jtn8%>B940NT^:%PEZd3gtONDlr1jr#4l:&)KqV(5P3(7Z]hQEWFFb3:?)G#,'Vw.'=.g:n7X_$Oj?H)(Jb.)?$Ym&cAJu.XfrS)bDVO'6^`S&xt#I6G,OL)Z8MsA5GeT%kiLA=fR:J)@Le<$^&hg:VF6T.PEHR&r2Z(-LXnq.9&.Qkfx5Q'k4+gL`2Rha'_A`a-l68%?3GJ(Wo8>,;NHD*R<*H*'k$H3@.OF3(@*Q/P$8s$Wt'E#4`d5/v5qSC2OCau$$4n<Ye&[Jreci9rYtL#<iBWJI@,@')$s<Mq]g%u*85##<vHo#e37:vUoIfLG@Huuq#AsT0C=)#Z]e^$5GU%6(K2^>KC,H3o]d8/;60T.kiic)`'Nu&ML*/3?4HN<?TtD<(vvE3V9LE<7,9u&>oT4(Ppx8RM,bbN'3hQ&cVBp&-h](P[4$##D%`a%E&3>5?n<Q8IuJ,3evTS%3D-T8l?e1,<nS^)=lXZ%SQ^6&g*Td<.+CJ)AOMe2JeGJ)nMOW'voQN'kFe),csJ_/9oF&#&k=m/';P>#cWGG)G&JJ&.%Vu&`9*?#L5koX^V2<%LZL:qvfGb%.6=(jE$qAXl*7T.8LVX-1P)C&':rk%(`c@$Frd@b/v,Da%gf%FlDq1K;8q2:vk>)4uueV%8drk'ds>V/AHaa4PdGg1Q0g://sId)a[2Q/MNBu$lYe)*;2QA#C`WF3U:Ix6_s$-3Y#c;-*^?.%Eg>G(pnO6')uBF*+kRlL-OY2(p2GX$XOmY##md11-;N[$-h)[,C1Z(+4>58.C8rh1NMWm/*dm(5&J)h3u'^:/cTf$5#0%-)u$-0)Gqe<$uSdj'#n4k05B.-)'#9;-)F:)4X',b+;eM`+G%Yi(uR&A$u%IN'K?mV);>cKhtGP&5'*U-HBkA?7FH)M%wE(,),s:D3F]tr-iL0+*I5^+4sUlo7t'vG*+'V*uEiUC,kKe6%RXkD#3^4.-NT_r?RU#pL1e3IfQ+;mQOg]j-<D:I$o,K9.(f>C+Tf=WM[Eo>-c&-p/o,UiIOE,n&YQ>s-q%TH:1]'^#7)hs-Z>?j:n@Im0G=61MJE:Z-+dfF47of1;F8`I3hbtM(ft(%,$xUC(<kuN'KmLEMMxg6(M8kn/4-Vo7kpHJ)*:V9..EVO'ZA,L2?SOS7Hr.cV$lQ=lM3l1+Q:ENrUG6^=032H*Z%AA4VC8j0q_.<8duiW%cljv%)@vV%v>[h*0ViIRqGojLpA$##5=S5#+.MT.<e[%#c@`T.-Yu##;A`T.,Mc##QsG<-5X`=-nsG<-*fG<-:B`T.8.`$#m#XN03c:?#-5>##_RFgLOJhkL0=`T.6:r$#34xU.3xL$#AsG<-5X`=-YsG<-*fG<-&B`T.H9F&#@tG<-JPI+3Ze/*#Xst.#e)1/#I<x-#-#krL;,;'#2_jjL/u@(#0Q?(#Xp/kL<LoqL0xc.#wC.v6F+U.G5E+7DHX5p/W%C,38q:417=vLFa-'##jS3rLP@]qLbqP.#pm-qL5T->>9l7FH5m?n2MT4oLkL#.#6^mL-Kr;Y0BvZ6D.gcdGBh%nLPKCsL3T,.#+W;qLFm%hEgdJX9J%Un=p&Ck=%8)_Sk+=L5B+?']l<4eHR`?F%X<8w^egCSC7;ZhFhXHL28-IL2ce:qWG/5##vO'#vMnBHM4c^;-UU=U%V9YY#*J(v#.c_V$2%@8%6=wo%:UWP&>n82'B0pi'FHPJ(Ja1,)N#ic)R;ID*VS*&+Zla]+_.B>,cF#v,g_YV-kw:8.o9ro.sQRP/wj320%-ki0)EKJ1-^,,21vcc258DD39P%&4=i[]4A+=>5ECtu5I[TV6Mt58761*WHnDmmLJ[#<-WY#<-XY#<-YY#<-ZY#<-[Y#<-]Y#<-^Y#<-_Y#<-`Y#<-hY#<-iY#<-jY#<-kY#<-lY#<-m`>W-hrQF%WuQF%%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2%w*g2'0O,3rX:d-juQF%&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3(9kG3rX:d-kuQF%'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3)?tG3A:w0#H,P:vv039B[-<$#i(ofL^@6##0F;=-345dM,MlCj[O39MdX4Fh5L*##G)-Fq93;At30+:D"
	-- >> BASE85 DATA <<

	imgui.GetIO().IniFilename = nil

	ash_image = imgui.CreateTextureFromFile(getGameDirectory()..'\\moonloader\\AS Helper\\Images\\ASH_Images.png')
	rainbowcircle = imgui.CreateTextureFromFileInMemory(new('const char*', circle_data), #circle_data)
	
	local config = imgui.ImFontConfig()
	config.MergeMode, config.PixelSnapH = true, true
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	local faIconRanges = new.ImWchar[3](fa.min_range, fa.max_range, 0)
	local font_path = getFolderPath(0x14) .. '\\trebucbd.ttf'

	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(font_path, 13.0, nil, glyph_ranges)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(font85, 13.0, config, faIconRanges)
	
	for k,v in pairs({8, 11, 15, 16, 20, 25}) do
		font[v] = imgui.GetIO().Fonts:AddFontFromFileTTF(font_path, v, nil, glyph_ranges)
		imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(font85, v, config, faIconRanges)
	end

	checkstyle()
end)

function checkstyle()
	imgui.SwitchContext()
	local style 							= imgui.GetStyle()
	local colors 							= style.Colors
	local clr 								= imgui.Col
	local ImVec4 							= imgui.ImVec4
	local ImVec2 							= imgui.ImVec2

	style.WindowTitleAlign 					= ImVec2(0.5, 0.5)
	style.WindowPadding 					= ImVec2(15, 15)
	style.WindowRounding 					= 6.0
	style.FramePadding 						= ImVec2(5, 5)
	style.FrameRounding 					= 5.0
	style.ItemSpacing						= ImVec2(12, 8)
	style.ItemInnerSpacing 					= ImVec2(8, 6)
	style.IndentSpacing 					= 25.0
	style.ScrollbarSize 					= 15
	style.ScrollbarRounding 				= 9.0
	style.GrabMinSize 						= 5.0
	style.GrabRounding 						= 3.0
	style.ChildRounding						= 7.0
	if configuration.main_settings.style == 0 or configuration.main_settings.style == nil then
		colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
		colors[clr.ChildBg] 				= ImVec4(0.10, 0.09, 0.12, 0.50)
		colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] 					= ImVec4(0.40, 0.40, 0.53, 0.50)
		colors[clr.Separator]				= ImVec4(0.40, 0.40, 0.53, 0.50)
		colors[clr.BorderShadow] 			= ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] 				= ImVec4(0.15, 0.14, 0.16, 0.50)
		colors[clr.FrameBgHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] 				= ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] 		= ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] 			= ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] 			= ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] 	= ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
		colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
		colors[clr.HeaderHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.HeaderActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.00, 0.00, 0.00, 0.30)
	elseif configuration.main_settings.style == 1 then
		colors[clr.Text]				   	= ImVec4(0.95, 0.96, 0.98, 1.00)
		colors[clr.TextDisabled] 			= ImVec4(0.65, 0.65, 0.65, 0.65)
		colors[clr.WindowBg]			   	= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ChildBg]		  			= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.PopupBg]					= ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.Border]				 	= ImVec4(1.00, 0.28, 0.28, 0.50)
		colors[clr.Separator]			 	= ImVec4(1.00, 0.28, 0.28, 0.50)
		colors[clr.BorderShadow]		   	= ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.22, 0.22, 0.22, 1.00)
		colors[clr.FrameBgHovered]		 	= ImVec4(0.18, 0.18, 0.18, 1.00)
		colors[clr.FrameBgActive]		  	= ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]					= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.TitleBgActive]		  	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.TitleBgCollapsed]	   	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.MenuBarBg]			  	= ImVec4(0.20, 0.20, 0.20, 1.00)
		colors[clr.ScrollbarBg]				= ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]		  	= ImVec4(0.36, 0.36, 0.36, 1.00)
		colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]		= ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.CheckMark]			  	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrabActive]	   	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.Button]				 	= ImVec4(1.00, 0.30, 0.30, 1.00)
		colors[clr.ButtonHovered]		  	= ImVec4(1.00, 0.25, 0.25, 1.00)
		colors[clr.ButtonActive]		   	= ImVec4(1.00, 0.20, 0.20, 1.00)
		colors[clr.Header]				 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.HeaderHovered]		  	= ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.HeaderActive]		   	= ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.ResizeGrip]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.ResizeGripHovered]	  	= ImVec4(1.00, 0.39, 0.39, 1.00)
		colors[clr.ResizeGripActive]	   	= ImVec4(1.00, 0.19, 0.19, 1.00)
		colors[clr.PlotLines]			  	= ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]	   	= ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]		  	= ImVec4(1.00, 0.21, 0.21, 1.00)
		colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
		colors[clr.TextSelectedBg]		 	= ImVec4(1.00, 0.25, 0.25, 1.00)
		colors[clr.ModalWindowDimBg]   		= ImVec4(0.00, 0.00, 0.00, 0.30)
	elseif configuration.main_settings.style == 2 then
		colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TextDisabled]   			= ImVec4(0.24, 0.24, 0.24, 0.30)
		colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.ChildBg]					= ImVec4(0.96, 0.96, 0.96, 1.00)
		colors[clr.PopupBg]			  		= ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.Border]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.BorderShadow]		 	= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			  		= ImVec4(0.68, 0.68, 0.68, 0.50)
		colors[clr.FrameBgHovered]	   		= ImVec4(0.82, 0.82, 0.82, 1.00)
		colors[clr.FrameBgActive]			= ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.TitleBg]			  		= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgCollapsed]	 	= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgActive]			= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.MenuBarBg]				= ImVec4(0.00, 0.37, 0.78, 1.00)
		colors[clr.ScrollbarBg]		  		= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ScrollbarGrab]			= ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
		colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
		colors[clr.CheckMark]				= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrab]		   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrabActive]	 	= ImVec4(0.00, 0.39, 1.00, 0.71)
		colors[clr.Button]			   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.ButtonHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.ButtonActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Header]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.HeaderHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.HeaderActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Separator]			  	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.SeparatorHovered]	   	= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.SeparatorActive]			= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.ResizeGrip]		   		= ImVec4(0.00, 0.39, 1.00, 0.59)
		colors[clr.ResizeGripHovered]		= ImVec4(0.00, 0.27, 1.00, 0.59)
		colors[clr.ResizeGripActive]	 	= ImVec4(0.00, 0.25, 1.00, 0.63)
		colors[clr.PlotLines]				= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotLinesHovered]	 	= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogram]			= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogramHovered]	= ImVec4(0.00, 0.35, 0.92, 0.78)
		colors[clr.TextSelectedBg]			= ImVec4(0.00, 0.47, 1.00, 0.59)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif configuration.main_settings.style == 3 then
		colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg]				= ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildBg]		 			= ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg]					= ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]					= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.Separator]				= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]			= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]			= ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]			   		= ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]	  	= ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]			 	= ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]		   		= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]		 	= ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CheckMark]			 	= ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]				= ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]					= ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]		  	= ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]					= ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]		  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]				= ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]	 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotLines]			 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]		 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]			= ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.ModalWindowDimBg]  		= ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif configuration.main_settings.style == 4 then
		colors[clr.Text]				   	= ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]		   	= ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg]			   	= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildBg]		  			= ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]					= ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]				 	= ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.Separator]			 	= ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]		   	= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]		 	= ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]		  	= ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]					= ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]		  	= ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]	   	= ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]			  	= ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]				= ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]		= ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.CheckMark]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]	   	= ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]		  	= ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]		   	= ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]		  	= ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]		   	= ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.SeparatorHovered]	   	= ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]			= ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]	  	= ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]	   	= ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.PlotLines]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]	   	= ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   	= ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]		 	= ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDimBg]   		= ImVec4(0.17, 0.17, 0.17, 0.48)
	elseif configuration.main_settings.style == 5 then
		colors[clr.Text] 					= ImVec4(0.9, 0.9, 0.9, 1)
		colors[clr.TextDisabled] 			= ImVec4(1, 1, 1, 0.4)
		colors[clr.WindowBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.ChildBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.PopupBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.Border] 					= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.Separator]				= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.BorderShadow] 			= ImVec4(0.35, 0.35, 0.35, 0.66)
		colors[clr.FrameBg] 				= ImVec4(1, 1, 1, 0.28)
		colors[clr.FrameBgHovered] 			= ImVec4(0.68, 0.68, 0.68, 0.67)
		colors[clr.FrameBgActive] 			= ImVec4(0.79, 0.73, 0.73, 0.62)
		colors[clr.TitleBg] 				= ImVec4(0, 0, 0, 1)
		colors[clr.TitleBgActive] 			= ImVec4(0.46, 0.46, 0.46, 1)
		colors[clr.TitleBgCollapsed] 		= ImVec4(0, 0, 0, 1)
		colors[clr.MenuBarBg] 				= ImVec4(0, 0, 0, 0.8)
		colors[clr.ScrollbarBg] 			= ImVec4(0, 0, 0, 0.6)
		colors[clr.ScrollbarGrab] 			= ImVec4(1, 1, 1, 0.87)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(1, 1, 1, 0.79)
		colors[clr.ScrollbarGrabActive] 	= ImVec4(0.8, 0.5, 0.5, 0.4)
		colors[clr.CheckMark] 				= ImVec4(0.99, 0.99, 0.99, 0.52)
		colors[clr.SliderGrab] 				= ImVec4(1, 1, 1, 0.42)
		colors[clr.SliderGrabActive] 		= ImVec4(0.76, 0.76, 0.76, 1)
		colors[clr.Button] 					= ImVec4(0.51, 0.51, 0.51, 0.6)
		colors[clr.ButtonHovered] 			= ImVec4(0.68, 0.68, 0.68, 1)
		colors[clr.ButtonActive] 			= ImVec4(0.67, 0.67, 0.67, 1)
		colors[clr.Header] 					= ImVec4(0.72, 0.72, 0.72, 0.54)
		colors[clr.HeaderHovered] 			= ImVec4(0.92, 0.92, 0.95, 0.77)
		colors[clr.HeaderActive] 			= ImVec4(0.82, 0.82, 0.82, 0.8)
		colors[clr.SeparatorHovered] 		= ImVec4(0.81, 0.81, 0.81, 1)
		colors[clr.SeparatorActive] 		= ImVec4(0.74, 0.74, 0.74, 1)
		colors[clr.ResizeGrip] 				= ImVec4(0.8, 0.8, 0.8, 0.3)
		colors[clr.ResizeGripHovered] 		= ImVec4(0.95, 0.95, 0.95, 0.6)
		colors[clr.ResizeGripActive] 		= ImVec4(1, 1, 1, 0.9)
		colors[clr.PlotLines] 				= ImVec4(1, 1, 1, 1)
		colors[clr.PlotLinesHovered] 		= ImVec4(1, 1, 1, 1)
		colors[clr.PlotHistogram] 			= ImVec4(1, 1, 1, 1)
		colors[clr.PlotHistogramHovered] 	= ImVec4(1, 1, 1, 1)
		colors[clr.TextSelectedBg] 			= ImVec4(1, 1, 1, 0.35)
		colors[clr.ModalWindowDimBg] 		= ImVec4(0.88, 0.88, 0.88, 0.35)
	elseif configuration.main_settings.style == 6 then
		local generated_color				= monetlua.buildColors(configuration.main_settings.monetstyle, configuration.main_settings.monetstyle_chroma, true)
		colors[clr.Text]					= ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
		colors[clr.TextDisabled]			= ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
		colors[clr.WindowBg]				= ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
		colors[clr.ChildBg]					= ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
		colors[clr.PopupBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.Border]					= ColorAccentsAdapter(generated_color.accent3.color_300):apply_alpha(0xcc):as_vec4()
		colors[clr.Separator]					= ColorAccentsAdapter(generated_color.accent3.color_300):apply_alpha(0xcc):as_vec4()
		colors[clr.BorderShadow]			= imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
		colors[clr.FrameBgHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
		colors[clr.FrameBgActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
		colors[clr.TitleBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
		colors[clr.TitleBgCollapsed]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
		colors[clr.TitleBgActive]			= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.MenuBarBg]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
		colors[clr.ScrollbarBg]				= imgui.ImVec4(0,0,0,0)
		colors[clr.ScrollbarGrab]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
		colors[clr.ScrollbarGrabHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ScrollbarGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.CheckMark]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.SliderGrab]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.SliderGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
		colors[clr.Button]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.ButtonHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ButtonActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.Header]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
		colors[clr.HeaderHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.HeaderActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
		colors[clr.ResizeGrip]				= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
		colors[clr.ResizeGripHovered]		= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
		colors[clr.ResizeGripActive]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
		colors[clr.PlotLines]				= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
		colors[clr.PlotLinesHovered]		= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.PlotHistogram]			= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
		colors[clr.PlotHistogramHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.TextSelectedBg]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
		colors[clr.ModalWindowDimBg]		= ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
	else
		configuration.main_settings.style = 0
		checkstyle()
	end
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = '%s'
	end
	local t={} ; i=1
	for str in gmatch(inputstr, '([^'..sep..']+)') do
		t[i] = str
		i = i + 1
	end
	return t
end

function string.separate(a)
	if type(a) ~= 'number' then
		return a
	end
	local b, e = gsub(format('%d', a), '^%-', '')
	local c = gsub(b:reverse(), '%d%d%d', '%1.')
	local d = gsub(c:reverse(), '^%.', '')
	return (e == 1 and '-' or '')..d
end

function string.rlower(s)
	local russian_characters = {
		[155] = '[', [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
	}
	s = lower(s)
	local strlen = len(s)
	if strlen == 0 then return s end
	s = lower(s)
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
		elseif ch == 168 then output = output .. russian_characters[184]
		else output = output .. char(ch)
		end
	end
	return output
end

function isKeysDown(keylist, pressed)
	if keylist == nil then return end
	keylist = (find(keylist, '.+ %p .+') and {keylist:match('(.+) %p .+'), keylist:match('.+ %p (.+)')} or {keylist})
	local tKeys = keylist
	if pressed == nil then
		pressed = false
	end
	if tKeys[1] == nil then
		return false
	end
	local bool = false
	local key = #tKeys < 2 and tKeys[1] or tKeys[2]
	local modified = tKeys[1]
	if #tKeys < 2 then
		if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
			bool = true
		elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
			bool = true
		end
	else
		if isKeyDown(vkeys.name_to_id(modified,true)) and not wasKeyReleased(vkeys.name_to_id(modified, true)) then
			if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
				bool = true
			elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
				bool = true
			end
		end
	end
	if nextLockKey == keylist then
		if pressed and not wasKeyReleased(vkeys.name_to_id(key, true)) then
			bool = false
		else
			bool = false
			nextLockKey = ''
		end
	end
	return bool
end

function changePosition(table)
	lua_thread.create(function()
		local backup = {
			['x'] = table.posX,
			['y'] = table.posY
		}
		ChangePos = true
		sampSetCursorMode(4)
		addNotify('Нажмите {MC}ЛКМ{WC}, чтобы сохранить\nместоположение, или {MC}ПКМ{WC},\nчтобы отменить', 5)
		while ChangePos do
			wait(0)
			local cX, cY = getCursorPos()
			table.posX = cX+10
			table.posY = cY+10
			if isKeyDown(0x01) then
				while isKeyDown(0x01) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				addNotify('Позиция сохранена!', 5)
			elseif isKeyDown(0x02) then
				while isKeyDown(0x02) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				table.posX = backup['x']
				table.posY = backup['y']
				addNotify('Вы отменили изменение\nместоположения', 5)
			end
		end
		ChangePos = false
		inicfg.save(configuration,'AS Helper')
	end)
end

function imgui.Link(link, text)
	text = text or link
	local tSize = imgui.CalcTextSize(text)
	local p = imgui.GetCursorScreenPos()
	local DL = imgui.GetWindowDrawList()
	local col = { 0xFFFF7700, 0xFFFF9900 }
	if imgui.InvisibleButton('##' .. link, tSize) then os.execute('explorer ' .. link) end
	local color = imgui.IsItemHovered() and col[1] or col[2]
	DL:AddText(p, color, text)
	DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

function imgui.BoolButton(bool, name)
	if type(bool) ~= 'boolean' then return end
	if bool then
		local button = imgui.Button(name)
		return button
	else
		local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
		local r, g, b, a = col.x, col.y, col.z, col.w
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		local button = imgui.Button(name)
		imgui.PopStyleColor(2)
		return button
	end
end

function imgui.LockedButton(text, size)
	local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
	local r, g, b, a = col.x, col.y, col.z, col.w
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
	imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
	local button = imgui.Button(text, size)
	imgui.PopStyleColor(4)
	return button
end

function imgui.ChangeLogCircleButton(str_id, bool, color4, choosedcolor4, radius, filled)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local radius = radius or 10
	local choosedcolor4 = choosedcolor4 or imgui.GetStyle().Colors[imgui.Col.Text]
	local filled = filled or false
	local draw_list = imgui.GetWindowDrawList()
	if imgui.InvisibleButton(str_id, imgui.ImVec2(23, 23)) then
		rBool = true
	end

	if filled then
		draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius+1, imgui.ColorConvertFloat4ToU32(choosedcolor4))
	else
		draw_list:AddCircle(imgui.ImVec2(p.x + radius, p.y + radius), radius+1, imgui.ColorConvertFloat4ToU32(choosedcolor4),_,2)
	end

	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius-3, imgui.ColorConvertFloat4ToU32(color4))
	imgui.SetCursorPosY(imgui.GetCursorPosY()+radius)
	return rBool
end

function imgui.CircleButton(str_id, bool, color4, radius, isimage)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local isimage = isimage or false
	local radius = radius or 10
	local draw_list = imgui.GetWindowDrawList()
	if imgui.InvisibleButton(str_id, imgui.ImVec2(23, 23)) then
		rBool = true
	end
	
	if imgui.IsItemHovered() then
		imgui.SetMouseCursor(imgui.MouseCursor.Hand)
	end

	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius-3, imgui.ColorConvertFloat4ToU32(isimage and imgui.ImVec4(0,0,0,0) or color4))

	if bool then
		draw_list:AddCircle(imgui.ImVec2(p.x + radius, p.y + radius), radius, imgui.ColorConvertFloat4ToU32(color4),_,1.5)
		imgui.PushFont(font[8])
		draw_list:AddText(imgui.ImVec2(p.x + 6, p.y + 6), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]),fa.ICON_FA_CHECK);
		imgui.PopFont()
	end

	imgui.SetCursorPosY(imgui.GetCursorPosY()+radius)
	return rBool
end

function imgui.TextColoredRGB(text,align)
	local width = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
	text = gsub(text, '{WC}', '{EBEBEB}')
	text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

	local getcolor = function(color)
		if upper(color:sub(1, 6)) == 'SSSSSS' then
			local r, g, b = colors[0].x, colors[0].y, colors[0].z
			local a = color:sub(7, 8) ~= 'FF' and (tonumber(color:sub(7, 8), 16)) or (colors[0].w * 255)
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return ImVec4(r / 255, g / 255, b / 255, a / 255)
	end

	local render_text = function(text_)
		for w in gmatch(text_, '[^\r\n]+') do
			local textsize = gsub(w, '{.-}', '')
			local text_width = imgui.CalcTextSize(u8(textsize))
			if align == 1 then imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
			elseif align == 2 then imgui.SetCursorPosX(imgui.GetCursorPosX() + width - text_width.x - imgui.GetScrollX() - 2 * imgui.GetStyle().ItemSpacing.x - imgui.GetStyle().ScrollbarSize)
			end
			local text, colors_, m = {}, {}, 1
			w = gsub(w, '{(......)}', '{%1FF}')
			while find(w, '{........}') do
				local n, k = find(w, '{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[0], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(text)
end

function imgui.Hint(str_id, hint_text, color, no_center)
	if str_id == nil or hint_text == nil then
		return false
	end
	color = color or imgui.GetStyle().Colors[imgui.Col.PopupBg]
	local p_orig = imgui.GetCursorPos()
	local hovered = imgui.IsItemHovered()
	imgui.SameLine(nil, 0)

	local animTime = 0.2
	local show = true

	if not POOL_HINTS then POOL_HINTS = {} end
	if not POOL_HINTS[str_id] then
		POOL_HINTS[str_id] = {
			status = false,
			timer = 0
		}
	end

	if hovered then
		for k, v in pairs(POOL_HINTS) do
			if k ~= str_id and imgui.GetTime() - v.timer <= animTime  then
				show = false
			end
		end
	end

	if show and POOL_HINTS[str_id].status ~= hovered then
		POOL_HINTS[str_id].status = hovered
		POOL_HINTS[str_id].timer = imgui.GetTime()
	end

	local rend_window = function(alpha)
		local size = imgui.GetItemRectSize()
		local scrPos = imgui.GetCursorScreenPos()
		local DL = imgui.GetWindowDrawList()
		local center = imgui.ImVec2( scrPos.x - (size.x * 0.5), scrPos.y + (size.y * 0.5) - (alpha * 4) + 10 )
		local a = imgui.ImVec2( center.x - 7, center.y - size.y - 4 )
		local b = imgui.ImVec2( center.x + 7, center.y - size.y - 4)
		local c = imgui.ImVec2( center.x, center.y - size.y + 3 )
		local col = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, alpha))

		DL:AddTriangleFilled(a, b, c, col)
		imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
		imgui.PushStyleColor(imgui.Col.PopupBg, color)
		imgui.PushStyleColor(imgui.Col.Border, color)
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
		imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6)
		imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

		local max_width = function(text)
			local result = 0
			for line in gmatch(text, '[^\n]+') do
				local len = imgui.CalcTextSize(line).x
				if len > result then
					result = len
				end
			end
			return result
		end

		local hint_width = max_width(u8(hint_text)) + (imgui.GetStyle().WindowPadding.x * 2)
		imgui.SetNextWindowSize(imgui.ImVec2(hint_width, -1), imgui.Cond.Always)
		imgui.Begin('##' .. str_id, _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
			for line in gmatch(hint_text, '[^\n]+') do
				if no_center then
					imgui.TextColoredRGB(line)
				else
					imgui.TextColoredRGB(line, 1)
				end
			end
		imgui.End()

		imgui.PopStyleVar(3)
		imgui.PopStyleColor(2)
	end

	if show then
		local between = imgui.GetTime() - POOL_HINTS[str_id].timer
		if between <= animTime then
			local alpha = hovered and ImSaturate(between / animTime) or ImSaturate(1 - between / animTime)
			rend_window(alpha)
		elseif hovered then
			rend_window(1.00)
		end
	end

	imgui.SetCursorPos(p_orig)
end

function bringVec4To(from, to, start_time, duration)
	local timer = clock() - start_time
	if timer >= 0.00 and timer <= duration then
		local count = timer / (duration / 100)
		return imgui.ImVec4(
			from.x + (count * (to.x - from.x) / 100),
			from.y + (count * (to.y - from.y) / 100),
			from.z + (count * (to.z - from.z) / 100),
			from.w + (count * (to.w - from.w) / 100)
		), true
	end
	return (timer > duration) and to or from, false
end

function getNote(note, post_color)
	local color = ARGBtoStringRGB(configuration.Checker.col_note)
	local post_c = ARGBtoStringRGB(post_color)

	note = note:gsub('\n.*', '...')
	note = note:gsub('{%x+}', '')

	return string.format('%s // %s%s', color, note, post_c)
end

function getAfk(rank, afk, post_color)
	local color = ARGBtoStringRGB(configuration.Checker.col_afk_max)
	local post_c = ARGBtoStringRGB(post_color)
	if rank <= 4 then
		if configuration.Checker.afk_max_l > 0 and afk >= configuration.Checker.afk_max_l then
			return string.format(' - %sAFK: %s%s', color, afk, post_c)
		end
	else
		if configuration.Checker.afk_max_h > 0 and afk >= configuration.Checker.afk_max_h then
			return string.format(' - %sAFK: %s%s', color, afk, post_c)
		end
	end
	return string.format(' - AFK: %s', afk)
end

function getAfkCount()
	local count = 0
	for _, v in ipairs(checker_variables.online) do
		if v.afk > 0 then
			count = count + 1
		end
	end
	return count
end

function imgui.AnimButton(label, size, duration)
	if not duration then
		duration = 1.0
	end

	local cols = {
		default = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button]),
		hovered = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]),
		active  = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
	}

	if UI_ANIMBUT == nil then
		UI_ANIMBUT = {}
	end
	if not UI_ANIMBUT[label] then
		UI_ANIMBUT[label] = {
			color = cols.default,
			hovered = {
				cur = false,
				old = false,
				clock = nil,
			}
		}
	end
	local pool = UI_ANIMBUT[label]

	if pool['hovered']['clock'] ~= nil then
		if clock() - pool['hovered']['clock'] <= duration then
			pool['color'] = bringVec4To( pool['color'], pool['hovered']['cur'] and cols.hovered or cols.default, pool['hovered']['clock'], duration)
		else
			pool['color'] = pool['hovered']['cur'] and cols.hovered or cols.default
		end
	else
		pool['color'] = cols.default
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(pool['color']))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(pool['color']))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(pool['color']))
	local result = imgui.Button(label, size or imgui.ImVec2(0, 0))
	imgui.PopStyleColor(3)

	pool['hovered']['cur'] = imgui.IsItemHovered()
	if pool['hovered']['old'] ~= pool['hovered']['cur'] then
		pool['hovered']['old'] = pool['hovered']['cur']
		pool['hovered']['clock'] = clock()
	end

	return result
end

function imgui.ToggleButton(str_id, bool)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
	local height = 20
	local width = height * 1.55
	local radius = height * 0.50

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool[0] = not bool[0]
		rBool = true
		LastActiveTime[tostring(str_id)] = imgui.GetTime()
		LastActive[tostring(str_id)] = true
	end

	local hovered = imgui.IsItemHovered()

	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY()+3)
	imgui.Text(str_id)

	local t = bool[0] and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = imgui.GetTime() - LastActiveTime[tostring(str_id)]
		if time <= 0.13 then
			local t_anim = ImSaturate(time / 0.13)
			t = bool[0] and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg = imgui.ColorConvertFloat4ToU32(bool[0] and imgui.GetStyle().Colors[imgui.Col.CheckMark] or imgui.ImVec4(100 / 255, 100 / 255, 100 / 255, hovered and 220 or 180 / 255))

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 10.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + (bool[0] and radius + 1.5 or radius - 3) + t * (width - radius * 2.0), p.y + radius), radius - 6, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]))

	return rBool
end

function getDownKeys()
	local curkeys = ''
	local bool = false
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT) then
			if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
				curkeys = v
			end
		end
	end
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT) then
			if len(tostring(curkeys)) == 0 then
				curkeys = v
				return curkeys,true
			else
				curkeys = curkeys .. ' ' .. v
				return curkeys,true
			end
			bool = false
		end
	end
	return curkeys, bool
end

function imgui.GetKeysName(keys)
	if type(keys) ~= 'table' then
	   	return false
	else
	  	local tKeysName = {}
	  	for k = 1, #keys do
			tKeysName[k] = vkeys.id_to_name(tonumber(keys[k]))
	  	end
	  	return tKeysName
	end
end

function imgui.HotKey(name, path, pointer, defaultKey, width)
	local width = width or 90
	local cancel = isKeyDown(0x08)
	local tKeys, saveKeys = string.split(getDownKeys(), ' '),select(2,getDownKeys())
	local name = tostring(name)
	local keys, bool = path[pointer] or defaultKey, false

	local sKeys = keys
	for i=0,2 do
		if imgui.IsMouseClicked(i) then
			tKeys = {i==2 and 4 or i+1}
			saveKeys = true
		end
	end

	if tHotKeyData.edit ~= nil and tostring(tHotKeyData.edit) == name then
		if not cancel then
			if not saveKeys then
				if #tKeys == 0 then
					sKeys = (ceil(imgui.GetTime()) % 2 == 0) and '______' or ' '
				else
					sKeys = table.concat(imgui.GetKeysName(tKeys), ' + ')
				end
			else
				path[pointer] = table.concat(imgui.GetKeysName(tKeys), ' + ')
				tHotKeyData.edit = nil
				tHotKeyData.lasted = clock()
				inicfg.save(configuration,'AS Helper')
			end
		else
			path[pointer] = defaultKey
			tHotKeyData.edit = nil
			tHotKeyData.lasted = clock()
			inicfg.save(configuration,'AS Helper')
		end
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
	if imgui.Button((sKeys ~= '' and sKeys or u8'Свободно') .. '## '..name, imgui.ImVec2(width, 0)) then
		tHotKeyData.edit = name
	end
	imgui.PopStyleColor(3)
	return bool
end

function addNotify(msg, time)
	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b = col.x*255, col.y*255, col.z*255
	msg = gsub(msg, '{WC}', '{SSSSSS}')
	msg = gsub(msg, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

	notify.msg[#notify.msg+1] = {text = msg, time = time, active = true, justshowed = nil}
end

local imgui_fm = imgui.OnFrame(
	function() return windows.imgui_fm[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		if not IsPlayerConnected(fastmenuID) then
			windows.imgui_fm[0] = false
			ASHelperMessage('Игрок с которым Вы взаимодействовали вышел из игры!')
			return false
		end
		if configuration.main_settings.fmstyle == 0 then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.Always)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Меню быстрого доступа', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
				if imgui.IsWindowAppearing() then
					windowtype[0] = 0
				end
				if windowtype[0] == 0 then
					imgui.SetCursorPosX(7.5)
					imgui.BeginGroup()
						if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 1 then
								getmyrank = true
								sampSendChat('/stats')
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Доброе утро, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
										{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Добрый день, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
										{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Добрый вечер, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
										{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Доброй ночи, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
										{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
									})
								end
							else
								ASHelperMessage('Данная команда доступна с 1-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 1  then
								sendchatarray(configuration.main_settings.playcd, {
									{'/do В кармане брюк лежит прайс лист на лицензии.'},
									{'/me {gender:достал|достала} прайс лист из кармана брюк и {gender:передал|передала} его клиенту'},
									{'/do В прайс листе написано:'},
									{'/do Лицензия на вождение автомобилей - %s$.', string.separate(configuration.main_settings.avtoprice or 5000)},
									{'/do Лицензия на вождение мотоциклов - %s$.', string.separate(configuration.main_settings.motoprice or 10000)},
									{'/do Лицензия на рыболовство - %s$.', string.separate(configuration.main_settings.ribaprice or 30000)},
									{'/do Лицензия на водный транспорт - %s$.', string.separate(configuration.main_settings.lodkaprice or 30000)},
									{'/do Лицензия на оружие - %s$.', string.separate(configuration.main_settings.gunaprice or 50000)},
									{'/do Лицензия на охоту - %s$.', string.separate(configuration.main_settings.huntprice or 100000)},
									{'/do Лицензия на раскопки - %s$.', string.separate(configuration.main_settings.kladprice or 200000)},
									{'/do Лицензия на работу таксиста - %s$.', string.separate(configuration.main_settings.taxiprice or 250000)},
								})
							else
								ASHelperMessage('Данная команда доступна с 1-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 3 then
								imgui.SetScrollY(0)
								Licenses_select[0] = 0
								windowtype[0] = 1
							else
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на авто'},
									{'/do Спустя некоторое время бланк на получение лицензии был заполнен.'},
									{'/me распечатав лицензию на авто {gender:передал|передала} её человеку напротив'},
									{'/n /givelicense %s', fastmenuID},
								})
							end
						end
						imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(285,30))
						if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
							if imgui.IsMouseReleased(0) then
								if configuration.main_settings.myrankint >= 2 then
									if not sampIsPlayerPaused(fastmenuID) then
										windows.imgui_fm[0] = false
										sendchatarray(configuration.main_settings.playcd, {
											{'/do Рация свисает на поясе.'},
											{'/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней'},
											{'/do Охрана выводит нарушителя из холла.'},
											{'/expel %s %s', fastmenuID, configuration.main_settings.expelreason},
										})
									else
										ASHelperMessage('Игрок находится в АФК!')
									end
								else
									ASHelperMessage('Данная команда доступна с 2-го ранга.')
								end
							end
							if imgui.IsMouseReleased(1) then
								imgui.OpenPopup('##changeexpelreason')
							end
						end
						imgui.Hint('expelhint','ЛКМ для того, чтобы выгнать человека\nПКМ для того, чтобы настроить причину')
						if imgui.BeginPopup('##changeexpelreason') then
							imgui.Text(u8'Причина /expel:')
							if imgui.InputText('##expelreasonbuff',usersettings.expelreason, sizeof(usersettings.expelreason)) then
								configuration.main_settings.expelreason = u8:decode(str(usersettings.expelreason))
								inicfg.save(configuration,'AS Helper')
							end
							imgui.EndPopup()
						end
						imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(285,30))
						if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
							if configuration.main_settings.myrankint >= 9 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'/do Ключи от шкафчика в кармане.'},
									{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
									{'/me {gender:передал|передала} ключ человеку напротив'},
									{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
									{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
									{'/invite %s', fastmenuID},
								})
								if imgui.IsMouseReleased(1) then
									waitingaccept = fastmenuID
								end
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						imgui.Hint('invitehint','ЛКМ для принятия человека в организацию\nПКМ для принятия на должность Консультанта')
						if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								windowtype[0] = 3
								imgui.StrCopy(uninvitebuf, '')
								imgui.StrCopy(blacklistbuf, '')
								uninvitebox[0] = false
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								Ranks_select[0] = 0
								windowtype[0] = 4
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								windowtype[0] = 5
								imgui.StrCopy(blacklistbuff, '')
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:достал|достала} планшет из кармана'},
									{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
									{'/me {gender:ввёл|ввела} имя гражданина в поиск'},
									{'/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\''},
									{'/me {gender:подтведрдил|подтвердила} изменения'},
									{'/do Изменения были сохранены.'},
									{'/unblacklist %s', fastmenuID},
								})
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								imgui.StrCopy(fwarnbuff, '')
								windowtype[0] = 6
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:достал|достала} планшет из кармана'},
									{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
									{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
									{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
									{'/do Выговор был убран из личного дела сотрудника.'},
									{'/unfwarn %s', fastmenuID},
								})
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								imgui.StrCopy(fmutebuff, '')
								fmuteint[0] = 0
								windowtype[0] = 7
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:достал|достала} планшет из кармана'},
									{'/me {gender:включил|включила} планшет'},
									{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
									{'/me {gender:выбрал|выбрала} нужного сотрудника'},
									{'/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\''},
									{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
									{'/funmute %s', fastmenuID},
								})
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
						imgui.Separator()
						if imgui.Button(u8'Проверка устава '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 5 then
								imgui.SetScrollY(0)
								lastq[0] = 0
								windowtype[0] = 8
							else
								ASHelperMessage('Данное действие доступно с 5-го ранга.')
							end
						end
						if imgui.Button(u8'Собеседование '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 5 then
								imgui.SetScrollY(0)
								sobesetap[0] = 0
								sobesdecline_select[0] = 0
								windowtype[0] = 9
								sobes_results = {
									pass = nil,
									medcard = nil,
									wbook = nil,
									licenses = nil
								}
							else
								ASHelperMessage('Данное действие доступно с 5-го ранга.')
							end
						end
					imgui.EndGroup()
				end
		
				if windowtype[0] == 1 then
					imgui.Text(u8'Лицензия: ', imgui.ImVec2(75,30))
					imgui.SameLine()
					imgui.Combo('##chooseselllicense', Licenses_select, new['const char*'][8](Licenses_Arr), #Licenses_Arr)
					imgui.NewLine()
					imgui.SetCursorPosX(7.5)
					if imgui.Button(u8'Продать лицензию на '..u8(string.rlower(u8:decode(Licenses_Arr[Licenses_select[0]+1]))), imgui.ImVec2(285,30)) then
						local to, lic = fastmenuID, string.rlower(u8:decode(Licenses_Arr[Licenses_select[0]+1]))
						if lic ~= nil and to ~= nil then
							if (lic == 'оружие' and configuration.main_settings.checkmcongun) or (lic == 'охоту' and configuration.main_settings.checkmconhunt) then
								sendchatarray(0, {
									{'Хорошо, для покупки лицензии на %s покажите мне свою мед.карту', lic},
									{'/n /showmc %s', select(2,sampGetPlayerIdByCharHandle(playerPed))},
								}, function() sellto = to lictype = lic end, function() ASHelperMessage('Началось ожидание показа мед.карты. При её отсутствии нажмите {MC}Alt{WC} + {MC}O{WC}') skiporcancel = lic tempid = to end)
							else
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на '..lic},
									{'/do Спустя некоторое время бланк на получение лицензии был заполнен.'},
									{'/me распечатав лицензию на %s {gender:передал|передала} её человеку напротив', lic},
								}, function() sellto = to lictype = lic end, function() wait(1000) givelic = true sampSendChat(format('/givelicense %s', to)) end)
							end
						end
					end
					imgui.SetCursorPosX(7.5)
					if imgui.Button(u8'Лицензия на полёты', imgui.ImVec2(285,30)) then
						sendchatarray(0, {
							{'Получить лицензию на полёты Вы можете в авиашколе г. Лас-Вентурас'},
							{'/n /gps -> Важные места -> Следующая страница -> [LV] Авиашкола (9)'},
						})
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 3 then
					imgui.TextColoredRGB('Причина увольнения:',1)
					imgui.SetCursorPosX(52)
					imgui.InputText(u8'##inputuninvitebuf', uninvitebuf, sizeof(uninvitebuf))
					if uninvitebox[0] then
						imgui.TextColoredRGB('Причина ЧС:',1)
						imgui.SetCursorPosX(52)
						imgui.InputText(u8'##inputblacklistbuf', blacklistbuf, sizeof(blacklistbuf))
					end
					imgui.Checkbox(u8'Уволить с ЧС', uninvitebox)
					imgui.SetCursorPosX(7.5)
					if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if configuration.main_settings.myrankint >= 9 then
							if #str(uninvitebuf) > 0 then
								if uninvitebox[0] then
									if #str(blacklistbuf) > 0 then
										windows.imgui_fm[0] = false
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:достал|достала} планшет из кармана'},
											{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
											{'/do Раздел открыт.'},
											{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
											{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
											{'/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения'},
											{'/do Изменения были сохранены.'},
											{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
											{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuf))},
										})
									else
										ASHelperMessage('Введите причину занесения в ЧС!')
									end
								else
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
										{'/do Раздел открыт.'},
										{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
										{'/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} планшет и {gender:положил|положила} его обратно в карман'},
										{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
									})
								end
							else
								ASHelperMessage('Введите причину увольнения.')
							end
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 4 then
					imgui.PushItemWidth(270)
					imgui.Combo('##chooserank9', Ranks_select, new['const char*'][9]({u8('[1] '..configuration.RankNames[1]), u8('[2] '..configuration.RankNames[2]),u8('[3] '..configuration.RankNames[3]),u8('[4] '..configuration.RankNames[4]),u8('[5] '..configuration.RankNames[5]),u8('[6] '..configuration.RankNames[6]),u8('[7] '..configuration.RankNames[7]),u8('[8] '..configuration.RankNames[8]),u8('[9] '..configuration.RankNames[9])}), 9)
					imgui.PopItemWidth()
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
					if imgui.Button(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
						if configuration.main_settings.myrankint >= 9 then
							windows.imgui_fm[0] = false
							sendchatarray(configuration.main_settings.playcd, {
								{'/me {gender:включил|включила} планшет'},
								{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
								{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
								{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
								{'/do Информация о сотруднике была изменена.'},
								{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
								{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
							})
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					end
					imgui.PopStyleColor(3)
					if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
						if configuration.main_settings.myrankint >= 9 then
							windows.imgui_fm[0] = false
							sendchatarray(configuration.main_settings.playcd, {
								{'/me {gender:включил|включила} планшет'},
								{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
								{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
								{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
								{'/do Информация о сотруднике была изменена.'},
								{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
							})
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 5 then
					imgui.TextColoredRGB('Причина занесения в ЧС:',1)
					imgui.SetCursorPosX(52)
					imgui.InputText(u8'##inputblacklistbuff', blacklistbuff, sizeof(blacklistbuff))
					imgui.NewLine()
					imgui.SetCursorPosX(7.5)
					if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if configuration.main_settings.myrankint >= 9 then
							if #str(blacklistbuff) > 0 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'/me {gender:достал|достала} планшет из кармана'},
									{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
									{'/me {gender:ввёл|ввела} имя нарушителя'},
									{'/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\''},
									{'/me {gender:подтведрдил|подтвердила} изменения'},
									{'/do Изменения были сохранены.'},
									{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuff))},
								})
							else
								ASHelperMessage('Введите причину занесения в ЧС!')
							end
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 6 then
					imgui.TextColoredRGB('Причина выговора:',1)
					imgui.SetCursorPosX(50)
					imgui.InputText(u8'##giverwarnbuffinputtext', fwarnbuff, sizeof(fwarnbuff))
					imgui.NewLine()
					imgui.SetCursorPosX(7.5)
					if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if #str(fwarnbuff) > 0 then
							windows.imgui_fm[0] = false
							sendchatarray(configuration.main_settings.playcd, {
								{'/me {gender:достал|достала} планшет из кармана'},
								{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
								{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
								{'/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор'},
								{'/do Выговор был добавлен в личное дело сотрудника.'},
								{'/fwarn %s %s', fastmenuID, u8:decode(str(fwarnbuff))},
							})
						else
							ASHelperMessage('Введите причину выдачи выговора!')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 7 then
					imgui.TextColoredRGB('Причина мута:',1)
					imgui.SetCursorPosX(52)
					imgui.InputText(u8'##fmutereasoninputtext', fmutebuff, sizeof(fmutebuff))
					imgui.TextColoredRGB('Время мута:',1)
					imgui.SetCursorPosX(52)
					imgui.InputInt(u8'##fmutetimeinputtext', fmuteint, 5)
					imgui.NewLine()
					if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
						if configuration.main_settings.myrankint >= 9 then
							if #str(fmutebuff) > 0 then
								if tonumber(fmuteint[0]) and tonumber(fmuteint[0]) > 0 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
										{'/me {gender:выбрал|выбрала} нужного сотрудника'},
										{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
										{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
										{'/fmute %s %s %s', fastmenuID, u8:decode(fmuteint[0]), u8:decode(str(fmutebuff))},
									})
								else
									ASHelperMessage('Введите корректное время мута!')
								end
							else
								ASHelperMessage('Введите причину выдачи мута!')
							end
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
				end
		
				if windowtype[0] == 8 then
					if not serverquestions['server'] then
						QuestionType_select[0] = 1
					end
					if QuestionType_select[0] == 0 then
						imgui.TextColoredRGB(serverquestions['server'], 1)
						for k = 1, #serverquestions do
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8(serverquestions[k].name)..'##'..k, imgui.ImVec2(285, 30)) then
								if not inprocess then
									ASHelperMessage('Подсказка: '..serverquestions[k].answer)
									sampSendChat(serverquestions[k].question)
									lastq[0] = clock()
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
						end
					elseif QuestionType_select[0] == 1 then
						if #questions.questions ~= 0 then
							for k,v in pairs(questions.questions) do
								imgui.SetCursorPosX(7.5)
								if imgui.Button(u8(v.bname..'##'..k), imgui.ImVec2(questions.active.redact and 200 or 285,30)) then
									if not inprocess then
										ASHelperMessage('Подсказка: '..v.bhint)
										sampSendChat(v.bq)
										lastq[0] = clock()
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
									end
								end
								if questions.active.redact then
									imgui.SameLine()
									if imgui.Button(fa.ICON_FA_PEN..'##'..k, imgui.ImVec2(30,30)) then
										question_number = k
										imgui.StrCopy(questionsettings.questionname, u8(v.bname))
										imgui.StrCopy(questionsettings.questionhint, u8(v.bhint))
										imgui.StrCopy(questionsettings.questionques, u8(v.bq))
										imgui.OpenPopup(u8('Редактор вопросов'))
									end
									imgui.SameLine()
									if imgui.Button(fa.ICON_FA_TRASH..'##'..k, imgui.ImVec2(30,30)) then
										table.remove(questions.questions,k)
										local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
										file:write(encodeJson(questions))
										file:close()
									end
								end
							end
						end
					end
					imgui.NewLine()
					imgui.SetCursorPosX(7.5)
					imgui.Text(fa.ICON_FA_CLOCK..' '..(lastq[0] == 0 and u8'0 с. назад' or floor(clock()-lastq[0])..u8' с. назад'))
					imgui.Hint('lastustavquesttime','Прошедшее время с последнего вопроса.')
					imgui.SetCursorPosX(7.5)
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
					imgui.Button(u8'Одобрить', imgui.ImVec2(137,35))
					if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
						if imgui.IsMouseReleased(0) then
							if not inprocess then
								windows.imgui_fm[0] = false
								sampSendChat(format('Поздравляю, %s, Вы сдали устав!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						if imgui.IsMouseReleased(1) then
							if configuration.main_settings.myrankint >= 9 then
								windows.imgui_fm[0] = false
								sendchatarray(configuration.main_settings.playcd, {
									{'Поздравляю, %s, Вы сдали устав!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
									{'/me {gender:включил|включила} планшет'},
									{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
									{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
									{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
									{'/do Информация о сотруднике была изменена.'},
									{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
									{'/giverank %s 2', fastmenuID},
								})
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						end
					end
					imgui.Hint('ustavhint','ЛКМ для информирования о сдаче устава\nПКМ для повышения до 2-го ранга')
					imgui.PopStyleColor(2)
					imgui.SameLine()
		
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
					if imgui.Button(u8'Отказать', imgui.ImVec2(137,35)) then
						if not inprocess then
							windows.imgui_fm[0] = false
							sampSendChat(format('Сожалею, %s, но Вы не смогли сдать устав. Подучите и приходите в следующий раз.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
						else
							ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
						end
					end
					imgui.PopStyleColor(2)
					imgui.Separator()
					imgui.SetCursorPosX(7.5)
					imgui.BeginGroup()
						if serverquestions['server'] then
							imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
							imgui.Text(u8'Вопросы')
							imgui.SameLine()
							imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
							imgui.PushItemWidth(90)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo(u8'##choosetypequestion', QuestionType_select, new['const char*'][8]{u8'Серверные', u8'Ваши'}, 2)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.SameLine()
						end
						if QuestionType_select[0] == 1 then
							if not questions.active.redact then
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.25, 0.25, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.25, 0.25, 1.00))
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.25, 0.25, 1.00))
							else
								if #questions.questions <= 7 then
									if imgui.Button(fa.ICON_FA_PLUS_CIRCLE,imgui.ImVec2(25,25)) then
										question_number = nil
										imgui.StrCopy(questionsettings.questionname, '')
										imgui.StrCopy(questionsettings.questionhint, '')
										imgui.StrCopy(questionsettings.questionques, '')
										imgui.OpenPopup(u8('Редактор вопросов'))
									end
									imgui.SameLine()
								end
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.70, 0.00, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.00, 1.00))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
							end
							if imgui.Button(fa.ICON_FA_COG, imgui.ImVec2(25,25)) then
								questions.active.redact = not questions.active.redact
							end
							imgui.PopStyleColor(3)
						end
					imgui.EndGroup()
		
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
						windowtype[0] = 0
					end
					
					if imgui.BeginPopup(u8'Редактор вопросов', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.Text(u8'Название кнопки:')
						imgui.SameLine()
						imgui.SetCursorPosX(125)
						imgui.InputText('##questeditorname', questionsettings.questionname, sizeof(questionsettings.questionname))
						imgui.Text(u8'Вопрос: ')
						imgui.SameLine()
						imgui.SetCursorPosX(125)
						imgui.InputText('##questeditorques', questionsettings.questionques, sizeof(questionsettings.questionques))
						imgui.Text(u8'Подсказка: ')
						imgui.SameLine()
						imgui.SetCursorPosX(125)
						imgui.InputText('##questeditorhint', questionsettings.questionhint, sizeof(questionsettings.questionhint))
						imgui.SetCursorPosX(17)
						if #str(questionsettings.questionhint) > 0 and #str(questionsettings.questionques) > 0 and #str(questionsettings.questionname) > 0 then
							if imgui.Button(u8'Сохранить####questeditor', imgui.ImVec2(150, 25)) then
								if question_number == nil then
									questions.questions[#questions.questions + 1] = {
										bname = u8:decode(str(questionsettings.questionname)),
										bq = u8:decode(str(questionsettings.questionques)),
										bhint = u8:decode(str(questionsettings.questionhint)),
									}
								else
									questions.questions[question_number].bname = u8:decode(str(questionsettings.questionname))
									questions.questions[question_number].bq = u8:decode(str(questionsettings.questionques))
									questions.questions[question_number].bhint = u8:decode(str(questionsettings.questionhint))
								end
								local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
								file:write(encodeJson(questions))
								file:close()
								imgui.CloseCurrentPopup()
							end
						else
							imgui.LockedButton(u8'Сохранить####questeditor', imgui.ImVec2(150, 25))
							imgui.Hint('notallparamsquesteditor','Вы ввели не все параметры. Перепроверьте всё.')
						end
						imgui.SameLine()
						if imgui.Button(u8'Отменить##questeditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
						imgui.Spacing()
						imgui.EndPopup()
					end
				end
		
				if windowtype[0] == 9 then
					if sobesetap[0] == 0 then
						imgui.TextColoredRGB('Собеседование: Этап 1',1)
						imgui.Separator()
						imgui.SetCursorPosX(7.5)
						if imgui.Button(u8'Поприветствовать', imgui.ImVec2(285,30)) then
							sendchatarray(configuration.main_settings.playcd, {
								{'Здравствуйте, я %s %s, Вы пришли на собеседование?', configuration.RankNames[configuration.main_settings.myrankint], configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
								{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
							})
						end
						imgui.SetCursorPosX(7.5)
						imgui.Button(u8'Попросить документы '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
						if imgui.IsItemHovered() then
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
							imgui.BeginTooltip()
							imgui.Text(u8'ЛКМ для того, чтобы продолжить\nПКМ для того, чтобы настроить документы')
							imgui.EndTooltip()
							imgui.PopStyleVar()

							if imgui.IsMouseReleased(0) then
								if not inprocess then
									local s = configuration.sobes_settings
									local out = (s.pass and 'паспорт' or '')..
												(s.medcard and (s.pass and ', мед. карту' or 'мед. карту') or '')..
												(s.wbook and ((s.pass or s.medcard) and ', трудовую книжку' or 'трудовую книжку') or '')..
												(s.licenses and ((s.pass or s.medcard or s.wbook) and ', лицензии' or 'лицензии') or '')
									sendchatarray(0, {
										{'Хорошо, покажите мне ваши документы, а именно: %s', out},
										{'/n Обязательно по рп!'},
									})
									sobesetap[0] = 1
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							if imgui.IsMouseReleased(1) then
								imgui.OpenPopup('##redactdocuments')
							end
						end
						imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
						if imgui.BeginPopup('##redactdocuments') then
							if imgui.ToggleButton(u8'Проверять паспорт', sobes_settings.pass) then
								configuration.sobes_settings.pass = sobes_settings.pass[0]
								inicfg.save(configuration,'AS Helper')
							end
							if imgui.ToggleButton(u8'Проверять мед. карту', sobes_settings.medcard) then
								configuration.sobes_settings.medcard = sobes_settings.medcard[0]
								inicfg.save(configuration,'AS Helper')
							end
							if imgui.ToggleButton(u8'Проверять трудовую книгу', sobes_settings.wbook) then
								configuration.sobes_settings.wbook = sobes_settings.wbook[0]
								inicfg.save(configuration,'AS Helper')
							end
							if imgui.ToggleButton(u8'Проверять лицензии', sobes_settings.licenses) then
								configuration.sobes_settings.licenses = sobes_settings.licenses[0]
								inicfg.save(configuration,'AS Helper')
							end
							imgui.EndPopup()
						end
						imgui.PopStyleVar()
					end
			
					if sobesetap[0] == 1 then
						imgui.TextColoredRGB('Собеседование: Этап 2',1)
						imgui.Separator()
						if configuration.sobes_settings.pass then
							imgui.TextColoredRGB(sobes_results.pass and 'Паспорт - показан ('..sobes_results.pass..')' or 'Паспорт - не показан',1)
						end
						if configuration.sobes_settings.medcard then
							imgui.TextColoredRGB(sobes_results.medcard and 'Мед. карта - показана ('..sobes_results.medcard..')' or 'Мед. карта - не показана',1)
						end
						if configuration.sobes_settings.wbook then
							imgui.TextColoredRGB(sobes_results.wbook and 'Трудовая книжка - показана' or 'Трудовая книжка - не показана',1)
						end
						if configuration.sobes_settings.licenses then
							imgui.TextColoredRGB(sobes_results.licenses and 'Лицензии - показаны ('..sobes_results.licenses..')' or 'Лицензии - не показаны',1)
						end
						if (configuration.sobes_settings.pass == true and sobes_results.pass == 'в порядке' or configuration.sobes_settings.pass == false) and
						(configuration.sobes_settings.medcard == true and sobes_results.medcard == 'в порядке' or configuration.sobes_settings.medcard == false) and
						(configuration.sobes_settings.wbook == true and sobes_results.wbook == 'присутствует' or configuration.sobes_settings.wbook == false) and
						(configuration.sobes_settings.licenses == true and sobes_results.licenses ~= nil or configuration.sobes_settings.licenses == false) then
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Продолжить '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									sendchatarray(configuration.main_settings.playcd, {
										{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
										{'/todo Хорошо...* отдавая документы обратно'},
										{'Сейчас я задам Вам несколько вопросов, Вы готовы на них отвечать?'},
									})
									sobesetap[0] = 2
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
						end
					end
			
					if sobesetap[0] == 2 then
						imgui.TextColoredRGB('Собеседование: Этап 3',1)
						imgui.Separator()
						imgui.SetCursorPosX(7.5)
						if imgui.Button(u8'Расскажите немного о себе.', imgui.ImVec2(285,30)) then
							if not inprocess then
								sampSendChat('Расскажите немного о себе.')
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						imgui.SetCursorPosX(7.5)
						if imgui.Button(u8'Почему выбрали именно нас?', imgui.ImVec2(285,30)) then
							if not inprocess then
								sampSendChat('Почему Вы выбрали именно нас?')
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						imgui.SetCursorPosX(7.5)
						if imgui.Button(u8'Работали Вы у нас ранее? '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
							if not inprocess then
								sampSendChat('Работали Вы у нас ранее? Если да, то расскажите подробнее')
								sobesetap[0] = 3
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
					end
			
					if sobesetap[0] == 3 then
						imgui.TextColoredRGB('Собеседование: Решение',1)
						imgui.Separator()
						imgui.SetCursorPosX(7.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
						if imgui.Button(u8'Принять', imgui.ImVec2(285,30)) then
							if configuration.main_settings.myrankint >= 9 then
								sendchatarray(configuration.main_settings.playcd, {
									{'Отлично, я думаю Вы нам подходите!'},
									{'/do Ключи от шкафчика в кармане.'},
									{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
									{'/me {gender:передал|передала} ключ человеку напротив'},
									{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
									{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
									{'/invite %s', fastmenuID},
								})
							else
								sendchatarray(configuration.main_settings.playcd, {
									{'Отлично, я думаю Вы нам подходите!'},
									{'/r %s успешно прошёл собеседование! Прошу подойти ко мне, чтобы принять его.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
									{'/rb %s id', fastmenuID},
								})
							end
							windows.imgui_fm[0] = false
						end
						imgui.PopStyleColor(2)
						imgui.SetCursorPosX(7.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
						if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
							lastsobesetap[0] = sobesetap[0]
							sobesetap[0] = 7
						end
						imgui.PopStyleColor(2)
					end
			
					if sobesetap[0] == 7 then
						imgui.TextColoredRGB('Собеседование: Отклонение',1)
						imgui.Separator()
						imgui.PushItemWidth(270)
						imgui.Combo('##declinesobeschoosereasonselect',sobesdecline_select, new['const char*'][5]({u8'Плохое РП',u8'Не было РП',u8'Плохая грамматика',u8'Ничего не показал',u8'Другое'}), 5)
						imgui.PopItemWidth()
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) * 0.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
						if imgui.Button(u8'Отклонить', imgui.ImVec2(270,30)) then
							if not inprocess then
								if sobesdecline_select[0] == 0 then
									sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
									sampSendChat('/b Очень плохое РП')
								elseif sobesdecline_select[0] == 1 then
									sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
									sampSendChat('/b Не было РП')
								elseif sobesdecline_select[0] == 2 then
									sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
									sampSendChat('/b Плохая грамматика')
								elseif sobesdecline_select[0] == 3 then
									sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
									sampSendChat('/b Ничего не показал')
								elseif sobesdecline_select[0] == 4 then
									sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
								end
								windows.imgui_fm[0] = false
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						imgui.PopStyleColor(2)
					end
			
					if sobesetap[0] ~= 3 and sobesetap[0] ~= 7  then
						imgui.Separator()
						imgui.SetCursorPosX(7.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
						if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
							if not inprocess then
								local reasons = {
									pass = {
										['меньше 3 лет в штате'] = {'К сожалению я не могу продолжить собеседование. Вы не проживаете в штате 3 года.'},
										['не законопослушный'] = {'К сожалению я не могу продолжить собеседование. Вы недостаточно законопослушный.'},
										['игрок в организации'] = {'К сожалению я не могу продолжить собеседование. Вы уже работаете в другой организации.'},
										['в чс автошколы'] = {'К сожалению я не могу продолжить собеседование. Вы находитесь в ЧС АШ.'},
										['есть варны'] = {'К сожалению я не могу продолжить собеседование. Вы проф. непригодны.', '/n есть варны'},
										['был в деморгане'] = {'К сожалению я не могу продолжить собеседование. Вы лечились в псих. больнице.', '/n обновите мед. карту'}
									},
									mc = {
										['наркозависимость'] = {'К сожалению я не могу продолжить собеседование. Вы слишком наркозависимый.'},
										['не полностью здоровый'] = {'К сожалению я не могу продолжить собеседование. Вы не полностью здоровый.'},
									},
								}
								if reasons.pass[sobes_results.pass] then
									for k, v in pairs(reasons.pass[sobes_results.pass]) do
										sampSendChat(v)
									end
									windows.imgui_fm[0] = false
								elseif reasons.mc[sobes_results.medcard] then
									for k, v in pairs(reasons.mc[sobes_results.medcard]) do
										sampSendChat(v)
									end
									windows.imgui_fm[0] = false
								else
									lastsobesetap[0] = sobesetap[0]
									sobesetap[0] = 7
								end
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						imgui.PopStyleColor(2)
					end
					imgui.SetCursorPos(imgui.ImVec2(7.5, 478))
					if imgui.Button(u8'Назад', imgui.ImVec2(137, 30)) then
						if sobesetap[0] == 7 then sobesetap[0] = lastsobesetap[0]
						elseif sobesetap[0] ~= 0 then sobesetap[0] = sobesetap[0] - 1
						else
							windowtype[0] = 0
						end
					end
					imgui.SameLine()
					if sobesetap[0] ~= 3 and sobesetap[0] ~= 7 then
						if imgui.Button(u8'Пропустить этап', imgui.ImVec2(137,30)) then
							sobesetap[0] = sobesetap[0] + 1
						end
					end
				end
			imgui.End()
		else
			imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.Always)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.7),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
			imgui.Begin(u8'Меню быстрого доступа', windows.imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
				if imgui.IsWindowAppearing() then
					newwindowtype[0] = 1
					clienttype[0] = 0
				end
				local p = imgui.GetCursorScreenPos()
				imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y), imgui.ImVec2(p.x + 300, p.y + 330), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
				imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y + 75), imgui.ImVec2(p.x + 500, p.y + 75), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)

				imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
				imgui.SetCursorPos(imgui.ImVec2(0, 25))
				imgui.BeginChild('##fmmainwindow', imgui.ImVec2(300, -1), false)
					if newwindowtype[0] == 1 then
						if clienttype[0] == 0 then
							imgui.SetCursorPos(imgui.ImVec2(7.5,15))
							imgui.BeginGroup()
								if configuration.main_settings.myrankint >= 1 then
									if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30)) then
										getmyrank = true
										sampSendChat('/stats')
										if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Доброе утро, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
												{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Добрый день, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
												{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Добрый вечер, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
												{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
											sendchatarray(configuration.main_settings.playcd, {
												{'Доброй ночи, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы г. Сан-Фиерро'},
												{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
											})
										end
									end
								else
									imgui.LockedButton(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30))
									imgui.Hint('firstranghello', 'С 1-го ранга')
								end
								if configuration.main_settings.myrankint >= 1  then
									if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30)) then
										sendchatarray(configuration.main_settings.playcd, {
											{'/do В кармане брюк лежит прайс лист на лицензии.'},
											{'/me {gender:достал|достала} прайс лист из кармана брюк и {gender:передал|передала} его клиенту'},
											{'/do В прайс листе написано:'},
											{'/do Лицензия на вождение автомобилей - %s$.', string.separate(configuration.main_settings.avtoprice or 5000)},
											{'/do Лицензия на вождение мотоциклов - %s$.', string.separate(configuration.main_settings.motoprice or 10000)},
											{'/do Лицензия на рыболовство - %s$.', string.separate(configuration.main_settings.ribaprice or 30000)},
											{'/do Лицензия на водный транспорт - %s$.', string.separate(configuration.main_settings.lodkaprice or 30000)},
											{'/do Лицензия на оружие - %s$.', string.separate(configuration.main_settings.gunaprice or 50000)},
											{'/do Лицензия на охоту - %s$.', string.separate(configuration.main_settings.huntprice or 100000)},
											{'/do Лицензия на раскопки - %s$.', string.separate(configuration.main_settings.kladprice or 200000)},
											{'/do Лицензия на работу таксиста - %s$.', string.separate(configuration.main_settings.taxiprice or 250000)},
										})
									end
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30))
									imgui.Hint('firstrangpricelist', 'С 1-го ранга')
								end
								if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(285,30)) then
									if configuration.main_settings.myrankint >= 3 then
										imgui.SetScrollY(0)
										Licenses_select[0] = 0
										clienttype[0] = 1
									else
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на авто'},
											{'/do Спустя некоторое время бланк на получение лицензии был заполнен.'},
											{'/me распечатав лицензию на авто {gender:передал|передала} её человеку напротив'},
											{'/n /givelicense %s', fastmenuID},
										})
									end
								end
								if configuration.main_settings.myrankint >= 2 then
									imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(285,30))
									if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
										if imgui.IsMouseReleased(0) then
											if not sampIsPlayerPaused(fastmenuID) then
												windows.imgui_fm[0] = false
												sendchatarray(configuration.main_settings.playcd, {
													{'/do Рация свисает на поясе.'},
													{'/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней'},
													{'/do Охрана выводит нарушителя из холла.'},
													{'/expel %s %s', fastmenuID, configuration.main_settings.expelreason},
												})
											else
												ASHelperMessage('Игрок находится в АФК!')
											end
										end
										if imgui.IsMouseReleased(1) then
											imgui.OpenPopup('##changeexpelreason')
										end
									end
									imgui.Hint('expelhint','ЛКМ для того, чтобы выгнать человека\nПКМ для того, чтобы настроить причину')
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
									if imgui.BeginPopup('##changeexpelreason') then
										imgui.Text(u8'Причина /expel:')
										if imgui.InputText('##expelreasonbuff',usersettings.expelreason, sizeof(usersettings.expelreason)) then
											configuration.main_settings.expelreason = u8:decode(str(usersettings.expelreason))
											inicfg.save(configuration,'AS Helper')
										end
										imgui.EndPopup()
									end
									imgui.PopStyleVar()
								else
									imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Выгнать из автошколы', imgui.ImVec2(285,30))
									imgui.Hint('secondrangexpel', 'С 2-го ранга')
								end
							imgui.EndGroup()
						elseif clienttype[0] == 1 then
							imgui.SetCursorPos(imgui.ImVec2(40,20))
							imgui.Text(u8'Лицензия: ', imgui.ImVec2(75,30))
							imgui.SameLine()
							imgui.PushItemWidth(150)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo('##chooseselllicense', Licenses_select, new['const char*'][8](Licenses_Arr), #Licenses_Arr)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Продать лицензию на '..u8(string.rlower(u8:decode(Licenses_Arr[Licenses_select[0]+1]))), imgui.ImVec2(285,30)) then
								local to, lic = fastmenuID, string.rlower(u8:decode(Licenses_Arr[Licenses_select[0]+1]))
								if lic ~= nil and to ~= nil then
									if (lic == 'оружие' and configuration.main_settings.checkmcongun) or (lic == 'охоту' and configuration.main_settings.checkmconhunt) then
										sendchatarray(0, {
											{'Хорошо, для покупки лицензии на %s покажите мне свою мед.карту', lic},
											{'/n /showmc %s', select(2,sampGetPlayerIdByCharHandle(playerPed))},
										}, function() sellto = to lictype = lic end, function() ASHelperMessage('Началось ожидание показа мед.карты. При её отсутствии нажмите {MC}Alt{WC} + {MC}O{WC}') skiporcancel = lic tempid = to end)
									else
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на '..lic},
											{'/do Спустя некоторое время бланк на получение лицензии был заполнен.'},
											{'/me распечатав лицензию на %s {gender:передал|передала} её человеку напротив', lic},
										}, function() sellto = to lictype = lic end, function() wait(1000) givelic = true sampSendChat(format('/givelicense %s', to)) end)
									end
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Лицензия на полёты', imgui.ImVec2(285,30)) then
								sendchatarray(0, {
									{'Получить лицензию на полёты Вы можете в авиашколе г. Лас-Вентурас'},
									{'/n /gps -> Важные места -> Следующая страница -> [LV] Авиашкола (9)'},
								})
							end

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								clienttype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						end
					elseif newwindowtype[0] == 2 then
						imgui.SetCursorPos(imgui.ImVec2(15,20))
						if sobesetap[0] == 0 then
							imgui.TextColoredRGB('Собеседование: Этап 1',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Поприветствовать', imgui.ImVec2(285,30)) then
								sendchatarray(configuration.main_settings.playcd, {
									{'Здравствуйте, я %s %s, Вы пришли на собеседование?', configuration.RankNames[configuration.main_settings.myrankint], configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
									{'/do На груди висит бейджик с надписью %s %s.', configuration.RankNames[configuration.main_settings.myrankint], #configuration.main_settings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)},
								})
							end
							imgui.SetCursorPosX(7.5)
							imgui.Button(u8'Попросить документы '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30))
							if imgui.IsItemHovered() then
								imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
								imgui.BeginTooltip()
								imgui.Text(u8'ЛКМ для того, чтобы продолжить\nПКМ для того, чтобы настроить документы')
								imgui.EndTooltip()
								imgui.PopStyleVar()

								if imgui.IsMouseReleased(0) then
									if not inprocess then
										local s = configuration.sobes_settings
										local out = (s.pass and 'паспорт' or '')..
													(s.medcard and (s.pass and ', мед. карту' or 'мед. карту') or '')..
													(s.wbook and ((s.pass or s.medcard) and ', трудовую книжку' or 'трудовую книжку') or '')..
													(s.licenses and ((s.pass or s.medcard or s.wbook) and ', лицензии' or 'лицензии') or '')
										sendchatarray(0, {
											{'Хорошо, покажите мне ваши документы, а именно: %s', out},
											{'/n Обязательно по рп!'},
										})
										sobesetap[0] = 1
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
									end
								end
								if imgui.IsMouseReleased(1) then
									imgui.OpenPopup('##redactdocuments')
								end
							end
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
							if imgui.BeginPopup('##redactdocuments') then
								if imgui.ToggleButton(u8'Проверять паспорт', sobes_settings.pass) then
									configuration.sobes_settings.pass = sobes_settings.pass[0]
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.ToggleButton(u8'Проверять мед. карту', sobes_settings.medcard) then
									configuration.sobes_settings.medcard = sobes_settings.medcard[0]
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.ToggleButton(u8'Проверять трудовую книгу', sobes_settings.wbook) then
									configuration.sobes_settings.wbook = sobes_settings.wbook[0]
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.ToggleButton(u8'Проверять лицензии', sobes_settings.licenses) then
									configuration.sobes_settings.licenses = sobes_settings.licenses[0]
									inicfg.save(configuration,'AS Helper')
								end
								imgui.EndPopup()
							end
							imgui.PopStyleVar()
						end
					
						if sobesetap[0] == 1 then
							imgui.TextColoredRGB('Собеседование: Этап 2',1)
							imgui.Separator()
							if configuration.sobes_settings.pass then
								imgui.TextColoredRGB(sobes_results.pass and 'Паспорт - показан ('..sobes_results.pass..')' or 'Паспорт - не показан',1)
							end
							if configuration.sobes_settings.medcard then
								imgui.TextColoredRGB(sobes_results.medcard and 'Мед. карта - показана ('..sobes_results.medcard..')' or 'Мед. карта - не показана',1)
							end
							if configuration.sobes_settings.wbook then
								imgui.TextColoredRGB(sobes_results.wbook and 'Трудовая книжка - показана' or 'Трудовая книжка - не показана',1)
							end
							if configuration.sobes_settings.licenses then
								imgui.TextColoredRGB(sobes_results.licenses and 'Лицензии - показаны ('..sobes_results.licenses..')' or 'Лицензии - не показаны',1)
							end
							if (configuration.sobes_settings.pass == true and sobes_results.pass == 'в порядке' or configuration.sobes_settings.pass == false) and
							(configuration.sobes_settings.medcard == true and sobes_results.medcard == 'в порядке' or configuration.sobes_settings.medcard == false) and
							(configuration.sobes_settings.wbook == true and sobes_results.wbook == 'присутствует' or configuration.sobes_settings.wbook == false) and
							(configuration.sobes_settings.licenses == true and sobes_results.licenses ~= nil or configuration.sobes_settings.licenses == false) then
								imgui.SetCursorPosX(7.5)
								if imgui.Button(u8'Продолжить '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
									if not inprocess then
										sendchatarray(configuration.main_settings.playcd, {
											{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
											{'/todo Хорошо...* отдавая документы обратно'},
											{'Сейчас я задам Вам несколько вопросов, Вы готовы на них отвечать?'},
										})
										sobesetap[0] = 2
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
									end
								end
							end
						end
					
						if sobesetap[0] == 2 then
							imgui.TextColoredRGB('Собеседование: Этап 3',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Расскажите немного о себе.', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Расскажите немного о себе.')
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Почему выбрали именно нас?', imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Почему Вы выбрали именно нас?')
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Работали Вы у нас ранее? '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
								if not inprocess then
									sampSendChat('Работали Вы у нас ранее? Если да, то расскажите подробнее')
									sobesetap[0] = 3
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
						end
					
						if sobesetap[0] == 3 then
							imgui.TextColoredRGB('Собеседование: Решение',1)
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
							if imgui.Button(u8'Принять', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									sendchatarray(configuration.main_settings.playcd, {
										{'Отлично, я думаю Вы нам подходите!'},
										{'/do Ключи от шкафчика в кармане.'},
										{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
										{'/me {gender:передал|передала} ключ человеку напротив'},
										{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
										{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
										{'/invite %s', fastmenuID},
									})
								else
									sendchatarray(configuration.main_settings.playcd, {
										{'Отлично, я думаю Вы нам подходите!'},
										{'/r %s успешно прошёл собеседование! Прошу подойти ко мне, чтобы принять его.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
										{'/rb %s id', fastmenuID},
									})
								end
								windows.imgui_fm[0] = false
							end
							imgui.PopStyleColor(2)
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
								lastsobesetap[0] = sobesetap[0]
								sobesetap[0] = 7
							end
							imgui.PopStyleColor(2)
						end
					
						if sobesetap[0] == 7 then
							imgui.TextColoredRGB('Собеседование: Отклонение',1)
							imgui.Separator()
							imgui.PushItemWidth(270)
							imgui.SetCursorPosX(15)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo('##declinesobeschoosereasonselect',sobesdecline_select, new['const char*'][5]({u8'Плохое РП',u8'Не было РП',u8'Плохая грамматика',u8'Ничего не показал',u8'Другое'}), 5)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) * 0.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Отклонить', imgui.ImVec2(270,30)) then
								if not inprocess then
									if sobesdecline_select[0] == 0 then
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
										sampSendChat('/b Очень плохое РП')
									elseif sobesdecline_select[0] == 1 then
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
										sampSendChat('/b Не было РП')
									elseif sobesdecline_select[0] == 2 then
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
										sampSendChat('/b Плохая грамматика')
									elseif sobesdecline_select[0] == 3 then
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
										sampSendChat('/b Ничего не показал')
									elseif sobesdecline_select[0] == 4 then
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
									end
									windows.imgui_fm[0] = false
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							imgui.PopStyleColor(2)
						end
					
						if sobesetap[0] ~= 3 and sobesetap[0] ~= 7  then
							imgui.Separator()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
							if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
								if not inprocess then
									local reasons = {
										pass = {
											['меньше 3 лет в штате'] = {'К сожалению я не могу продолжить собеседование. Вы не проживаете в штате 3 года.'},
											['не законопослушный'] = {'К сожалению я не могу продолжить собеседование. Вы недостаточно законопослушный.'},
											['игрок в организации'] = {'К сожалению я не могу продолжить собеседование. Вы уже работаете в другой организации.'},
											['в чс автошколы'] = {'К сожалению я не могу продолжить собеседование. Вы находитесь в ЧС АШ.'},
											['есть варны'] = {'К сожалению я не могу продолжить собеседование. Вы проф. непригодны.', '/n есть варны'},
											['был в деморгане'] = {'К сожалению я не могу продолжить собеседование. Вы лечились в псих. больнице.', '/n обновите мед. карту'}
										},
										mc = {
											['наркозависимость'] = {'К сожалению я не могу продолжить собеседование. Вы слишком наркозависимый.'},
											['не полностью здоровый'] = {'К сожалению я не могу продолжить собеседование. Вы не полностью здоровый.'},
										},
									}
									if reasons.pass[sobes_results.pass] then
										for k, v in pairs(reasons.pass[sobes_results.pass]) do
											sampSendChat(v)
										end
										windows.imgui_fm[0] = false
									elseif reasons.mc[sobes_results.medcard] then
										for k, v in pairs(reasons.mc[sobes_results.medcard]) do
											sampSendChat(v)
										end
										windows.imgui_fm[0] = false
									else
										lastsobesetap[0] = sobesetap[0]
										sobesetap[0] = 7
									end
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							imgui.PopStyleColor(2)
						end
					
						imgui.SetCursorPos(imgui.ImVec2(15,240))
						if sobesetap[0] ~= 0 then
							if imgui.InvisibleButton('##sobesbackbutton',imgui.ImVec2(55,15)) then
								if sobesetap[0] == 7 then sobesetap[0] = lastsobesetap[0]
								elseif sobesetap[0] ~= 0 then sobesetap[0] = sobesetap[0] - 1
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
							imgui.SameLine()
						end
						imgui.SetCursorPosY(240)
						if sobesetap[0] ~= 3 and sobesetap[0] ~= 7 then
							imgui.SetCursorPosX(195)
							if imgui.InvisibleButton('##sobesforwardbutton',imgui.ImVec2(125,15)) then
								sobesetap[0] = sobesetap[0] + 1
							end
							imgui.SetCursorPos(imgui.ImVec2(195, 240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Пропустить '..fa.ICON_FA_CHEVRON_RIGHT)
							imgui.PopFont()
						end
					elseif newwindowtype[0] == 3 then
						imgui.SetCursorPos(imgui.ImVec2(7.5, 15))
						imgui.BeginGroup()
							if not serverquestions['server'] then
								QuestionType_select[0] = 1
							end
							if QuestionType_select[0] == 0 then
								imgui.TextColoredRGB(serverquestions['server'], 1)
								for k = 1, #serverquestions do
									if imgui.Button(u8(serverquestions[k].name)..'##'..k, imgui.ImVec2(275, 30)) then
										if not inprocess then
											ASHelperMessage('Подсказка: '..serverquestions[k].answer)
											sampSendChat(serverquestions[k].question)
											lastq[0] = clock()
										else
											ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
										end
									end
								end
							elseif QuestionType_select[0] == 1 then
								if #questions.questions ~= 0 then
									for k,v in pairs(questions.questions) do
										if imgui.Button(u8(v.bname)..'##'..k, imgui.ImVec2(questions.active.redact and 200 or 275,30)) then
											if not inprocess then
												ASHelperMessage('Подсказка: '..v.bhint)
												sampSendChat(v.bq)
												lastq[0] = clock()
											else
												ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
											end
										end
										if questions.active.redact then
											imgui.SameLine()
											imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
											imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
											imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
											if imgui.Button(fa.ICON_FA_PEN..'##'..k, imgui.ImVec2(20,25)) then
												question_number = k
												imgui.StrCopy(questionsettings.questionname, u8(v.bname))
												imgui.StrCopy(questionsettings.questionhint, u8(v.bhint))
												imgui.StrCopy(questionsettings.questionques, u8(v.bq))
												imgui.OpenPopup(u8('Редактор вопросов'))
											end
											imgui.SameLine()
											if imgui.Button(fa.ICON_FA_TRASH..'##'..k, imgui.ImVec2(20,25)) then
												table.remove(questions.questions,k)
												local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
												file:write(encodeJson(questions))
												file:close()
											end
											imgui.PopStyleColor(3)
										end
									end
								end
							end
						imgui.EndGroup()
						imgui.NewLine()
						imgui.SetCursorPosX(7.5)
						imgui.Text(fa.ICON_FA_CLOCK..' '..(lastq[0] == 0 and u8'0 с. назад' or floor(clock()-lastq[0])..u8' с. назад'))
						imgui.Hint('lastustavquesttime','Прошедшее время с последнего вопроса.')
						imgui.SetCursorPosX(7.5)
						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
						imgui.Button(u8'Одобрить', imgui.ImVec2(130,30))
						if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
							if imgui.IsMouseReleased(0) then
								if not inprocess then
									windows.imgui_fm[0] = false
									sampSendChat(format('Поздравляю, %s, Вы сдали устав!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
								end
							end
							if imgui.IsMouseReleased(1) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'Поздравляю, %s, Вы сдали устав!', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
										{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
										{'/do Информация о сотруднике была изменена.'},
										{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
										{'/giverank %s 2', fastmenuID},
									})
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
						end
						imgui.Hint('ustavhint','ЛКМ для информирования о сдаче устава\nПКМ для повышения до 2-го ранга')
						imgui.PopStyleColor(2)
						imgui.SameLine()

						imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
						imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
						if imgui.Button(u8'Отказать', imgui.ImVec2(130,30)) then
							if not inprocess then
								windows.imgui_fm[0] = false
								sampSendChat(format('Сожалею, %s, но Вы не смогли сдать устав. Подучите и приходите в следующий раз.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
							else
								ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
							end
						end
						imgui.PopStyleColor(2)
						imgui.Separator()

						imgui.SetCursorPosX(7.5)
						imgui.BeginGroup()
							if serverquestions['server'] then
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
								imgui.Text(u8'Вопросы')
								imgui.SameLine()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
								imgui.PushItemWidth(90)
								imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
								imgui.Combo(u8'##choosetypequestion', QuestionType_select, new['const char*'][8]{u8'Серверные', u8'Ваши'}, 2)
								imgui.PopStyleVar()
								imgui.PopItemWidth()
								imgui.SameLine()
							end
							if QuestionType_select[0] == 1 then
								if not questions.active.redact then
									imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.25, 0.25, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.25, 0.25, 1.00))
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.25, 0.25, 1.00))
								else
									if #questions.questions <= 7 then
										if imgui.Button(fa.ICON_FA_PLUS_CIRCLE,imgui.ImVec2(25,25)) then
											question_number = nil
											imgui.StrCopy(questionsettings.questionname, '')
											imgui.StrCopy(questionsettings.questionhint, '')
											imgui.StrCopy(questionsettings.questionques, '')
											imgui.OpenPopup(u8('Редактор вопросов'))
										end
										imgui.SameLine()
									end
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.70, 0.00, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.00, 1.00))
									imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
								end
								if imgui.Button(fa.ICON_FA_COG, imgui.ImVec2(25,25)) then
									questions.active.redact = not questions.active.redact
								end
								imgui.PopStyleColor(3)
							end
						imgui.EndGroup()
						imgui.Spacing()
						imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
						if imgui.BeginPopup(u8'Редактор вопросов', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.Text(u8'Название кнопки:')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorname', questionsettings.questionname, sizeof(questionsettings.questionname))
							imgui.Text(u8'Вопрос: ')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorques', questionsettings.questionques, sizeof(questionsettings.questionques))
							imgui.Text(u8'Подсказка: ')
							imgui.SameLine()
							imgui.SetCursorPosX(125)
							imgui.InputText('##questeditorhint', questionsettings.questionhint, sizeof(questionsettings.questionhint))
							imgui.SetCursorPosX(17)
							if #str(questionsettings.questionhint) > 0 and #str(questionsettings.questionques) > 0 and #str(questionsettings.questionname) > 0 then
								if imgui.Button(u8'Сохранить####questeditor', imgui.ImVec2(150, 25)) then
									if question_number == nil then
										questions.questions[#questions.questions + 1] = {
											bname = u8:decode(str(questionsettings.questionname)),
											bq = u8:decode(str(questionsettings.questionques)),
											bhint = u8:decode(str(questionsettings.questionhint)),
										}
									else
										questions.questions[question_number].bname = u8:decode(str(questionsettings.questionname))
										questions.questions[question_number].bq = u8:decode(str(questionsettings.questionques))
										questions.questions[question_number].bhint = u8:decode(str(questionsettings.questionhint))
									end
									local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
									file:write(encodeJson(questions))
									file:close()
									imgui.CloseCurrentPopup()
								end
							else
								imgui.LockedButton(u8'Сохранить####questeditor', imgui.ImVec2(150, 25))
								imgui.Hint('notallparamsquesteditor','Вы ввели не все параметры. Перепроверьте всё.')
							end
							imgui.SameLine()
							if imgui.Button(u8'Отменить##questeditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
							imgui.Spacing()
							imgui.EndPopup()
						end
						imgui.PopStyleVar()
					elseif newwindowtype[0] == 4 then
						if leadertype[0] == 0 then
							imgui.SetCursorPos(imgui.ImVec2(7.5, 15))
							imgui.BeginGroup()
								imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(275,30))
								if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/do Ключи от шкафчика в кармане.'},
										{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
										{'/me {gender:передал|передала} ключ человеку напротив'},
										{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
										{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
										{'/invite %s', fastmenuID},
									})
									if imgui.IsMouseReleased(1) then
										waitingaccept = fastmenuID
									end
								end
								imgui.Hint('invitehint','ЛКМ для принятия человека в организацию\nПКМ для принятия на должность Консультанта')
								if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(275,30)) then
									leadertype[0] = 1
									imgui.StrCopy(uninvitebuf, '')
									imgui.StrCopy(blacklistbuf, '')
									uninvitebox[0] = false
								end
								if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(275,30)) then
									Ranks_select[0] = 0
									leadertype[0] = 2
								end
								if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(275,30)) then
									leadertype[0] = 3
									imgui.StrCopy(blacklistbuff, '')
								end
								if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
										{'/me {gender:ввёл|ввела} имя гражданина в поиск'},
										{'/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\''},
										{'/me {gender:подтведрдил|подтвердила} изменения'},
										{'/do Изменения были сохранены.'},
										{'/unblacklist %s', fastmenuID},
									})
								end
								if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(275,30)) then
									imgui.StrCopy(fwarnbuff, '')
									leadertype[0] = 4
								end
								if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
										{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
										{'/do Выговор был убран из личного дела сотрудника.'},
										{'/unfwarn %s', fastmenuID},
									})
								end
								if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(275,30)) then
									imgui.StrCopy(fmutebuff, '')
									fmuteint[0] = 0
									leadertype[0] = 5
								end
								if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(275,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
										{'/me {gender:выбрал|выбрала} нужного сотрудника'},
										{'/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\''},
										{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
										{'/funmute %s', fastmenuID},
									})
								end
							imgui.EndGroup()
						elseif leadertype[0] == 1 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Причина увольнения:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##inputuninvitebuf', uninvitebuf, sizeof(uninvitebuf))
							if uninvitebox[0] then
								imgui.TextColoredRGB('Причина ЧС:',1)
								imgui.SetCursorPosX(52)
								imgui.InputText(u8'##inputblacklistbuf', blacklistbuf, sizeof(blacklistbuf))
							end
							imgui.SetCursorPosX(7.5)
							imgui.ToggleButton(u8'Уволить с ЧС', uninvitebox)
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(uninvitebuf) > 0 then
										if uninvitebox[0] then
											if #str(blacklistbuf) > 0 then
												windows.imgui_fm[0] = false
												sendchatarray(configuration.main_settings.playcd, {
													{'/me {gender:достал|достала} планшет из кармана'},
													{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
													{'/do Раздел открыт.'},
													{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
													{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
													{'/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения'},
													{'/do Изменения были сохранены.'},
													{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
													{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuf))},
												})
											else
												ASHelperMessage('Введите причину занесения в ЧС!')
											end
										else
											windows.imgui_fm[0] = false
											sendchatarray(configuration.main_settings.playcd, {
												{'/me {gender:достал|достала} планшет из кармана'},
												{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
												{'/do Раздел открыт.'},
												{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
												{'/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} планшет и {gender:положил|положила} его обратно в карман'},
												{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
											})
										end
									else
										ASHelperMessage('Введите причину увольнения.')
									end
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						elseif leadertype[0] == 2 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.SetCursorPosX(47.5)
							imgui.PushItemWidth(200)
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
							imgui.Combo('##chooserank9', Ranks_select, new['const char*'][9]({u8('[1] '..configuration.RankNames[1]), u8('[2] '..configuration.RankNames[2]),u8('[3] '..configuration.RankNames[3]),u8('[4] '..configuration.RankNames[4]),u8('[5] '..configuration.RankNames[5]),u8('[6] '..configuration.RankNames[6]),u8('[7] '..configuration.RankNames[7]),u8('[8] '..configuration.RankNames[8]),u8('[9] '..configuration.RankNames[9])}), 9)
							imgui.PopStyleVar()
							imgui.PopItemWidth()
							imgui.SetCursorPosX(7.5)
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
							if imgui.Button(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(285,40)) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
										{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
										{'/do Информация о сотруднике была изменена.'},
										{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
							imgui.PopStyleColor(3)
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
										{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
										{'/do Информация о сотруднике была изменена.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
							
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						elseif leadertype[0] == 3 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Причина занесения в ЧС:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##inputblacklistbuff', blacklistbuff, sizeof(blacklistbuff))
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(blacklistbuff) > 0 then
										windows.imgui_fm[0] = false
										sendchatarray(configuration.main_settings.playcd, {
											{'/me {gender:достал|достала} планшет из кармана'},
											{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
											{'/me {gender:ввёл|ввела} имя нарушителя'},
											{'/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\''},
											{'/me {gender:подтведрдил|подтвердила} изменения'},
											{'/do Изменения были сохранены.'},
											{'/blacklist %s %s', fastmenuID, u8:decode(str(blacklistbuff))},
										})
									else
										ASHelperMessage('Введите причину занесения в ЧС!')
									end
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						elseif leadertype[0] == 4 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Причина выговора:',1)
							imgui.SetCursorPosX(50)
							imgui.InputText(u8'##giverwarnbuffinputtext', fwarnbuff, sizeof(fwarnbuff))
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if #str(fwarnbuff) > 0 then
									windows.imgui_fm[0] = false
									sendchatarray(configuration.main_settings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
										{'/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор'},
										{'/do Выговор был добавлен в личное дело сотрудника.'},
										{'/fwarn %s %s', fastmenuID, u8:decode(str(fwarnbuff))},
									})
								else
									ASHelperMessage('Введите причину выдачи выговора!')
								end
							end

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						elseif leadertype[0] == 5 then
							imgui.SetCursorPos(imgui.ImVec2(15,20))
							imgui.TextColoredRGB('Причина мута:',1)
							imgui.SetCursorPosX(52)
							imgui.InputText(u8'##fmutereasoninputtext', fmutebuff, sizeof(fmutebuff))
							imgui.TextColoredRGB('Время мута:',1)
							imgui.SetCursorPosX(52)
							imgui.InputInt(u8'##fmutetimeinputtext', fmuteint, 5)
							imgui.NewLine()
							imgui.SetCursorPosX(7.5)
							if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
								if configuration.main_settings.myrankint >= 9 then
									if #str(fmutebuff) > 0 then
										if tonumber(fmuteint[0]) and tonumber(fmuteint[0]) > 0 then
											windows.imgui_fm[0] = false
											sendchatarray(configuration.main_settings.playcd, {
												{'/me {gender:достал|достала} планшет из кармана'},
												{'/me {gender:включил|включила} планшет'},
												{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
												{'/me {gender:выбрал|выбрала} нужного сотрудника'},
												{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
												{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
												{'/fmute %s %s %s', fastmenuID, u8:decode(fmuteint[0]), u8:decode(str(fmutebuff))},
											})
										else
											ASHelperMessage('Введите корректное время мута!')
										end
									else
										ASHelperMessage('Введите причину выдачи мута!')
									end
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
							
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,15)) then
								leadertype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()
						end
						imgui.Spacing()
					end
				imgui.EndChild()

				imgui.SetCursorPos(imgui.ImVec2(300, 25))
				imgui.BeginChild('##fmplayerinfo', imgui.ImVec2(200, 75), false)
					imgui.SetCursorPosY(17)
					imgui.TextColoredRGB('Имя: {SSSSSS}'..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', 1)
					imgui.Hint('lmb to copy name', 'ЛКМ - скопировать ник')
					if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
						local name, result = gsub(u8(sampGetPlayerNickname(fastmenuID)), '_', ' ')
						imgui.SetClipboardText(name)
					end
					imgui.TextColoredRGB('Лет в штате: '..sampGetPlayerScore(fastmenuID), 1)
				imgui.EndChild()

				imgui.SetCursorPos(imgui.ImVec2(300, 100))
				imgui.BeginChild('##fmchoosewindowtype', imgui.ImVec2(200, -1), false)
					imgui.SetCursorPos(imgui.ImVec2(20, 17.5))
					imgui.BeginGroup()
						for k, v in pairs(fmbuttons) do
							if configuration.main_settings.myrankint >= v.rank then
								if newwindowtype[0] == k then
									local p = imgui.GetCursorScreenPos()
									imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x + 159, p.y + 10),imgui.ImVec2(p.x + 162, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Left)
								end
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,newwindowtype[0] == k and 0.1 or 0))
								imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0.15))
								imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0.1))
								if imgui.AnimButton(v.name, imgui.ImVec2(162,35)) then
									if newwindowtype[0] ~= k then
										newwindowtype[0] = k
										sobesetap[0] = 0
										sobesdecline_select[0] = 0
										lastq[0] = 0
										sobes_results = {
											pass = nil,
											medcard = nil,
											wbook = nil,
											licenses = nil
										}
									end
								end
								imgui.PopStyleColor(3)
							end
						end
					imgui.EndGroup()
				imgui.EndChild()
				imgui.PopStyleColor()
				imgui.End()
			imgui.PopStyleVar()
		end
	end
)

local imgui_settings = imgui.OnFrame(
	function() return windows.imgui_settings[0] and not ChangePos end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'#MainSettingsWindow', windows.imgui_settings, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.BeginGroup()
			imgui.Image(ash_image,imgui.ImVec2(198,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.8 or 0.9),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.9 or 1))
				imgui.SameLine(510)
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
				if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE..'##allcommands',imgui.ImVec2(23,23)) then
					imgui.OpenPopup(u8'Все команды')
				end
				imgui.SameLine()
				if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
					windows.imgui_settings[0] = false
				end
				imgui.PopStyleColor(3)
				imgui.SetCursorPos(imgui.ImVec2(217, 23))
				imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Border],'v. '..thisScript().version)
				imgui.Hint('lastupdate','Обновление от 13.03.2021')
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
				if imgui.BeginPopupModal(u8'Все команды', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
					imgui.PushFont(font[16])
					imgui.TextColoredRGB('Все доступные команды и горячие клавиши', 1)
					imgui.PopFont()
					imgui.Spacing()
					imgui.TextColoredRGB('Команды скрипта:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						imgui.TextColoredRGB('/ash - Главное меню скрипта')
						imgui.TextColoredRGB('/ashbind - Биндер скрипта')
						imgui.TextColoredRGB('/ashlect - Меню лекций скрипта')
						imgui.TextColoredRGB('/ashdep - Меню департамента скрипта')
						if configuration.main_settings.fmtype == 1 then
							imgui.TextColoredRGB('/'..configuration.main_settings.usefastmenucmd..' [id] - Меню взаимодействия с клиентом')
						end
					imgui.EndGroup()
					imgui.Spacing()
					imgui.TextColoredRGB('Команды сервера с РП отыгровками:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						imgui.TextColoredRGB('/invite [id] | /uninvite [id] [причина] - Принятие/Увольнение человека во фракцию (9+)')
						imgui.TextColoredRGB('/blacklist [id] [причина] | /unblacklist [id] - Занесение/Удаление человека в ЧС фракции (9+)')
						imgui.TextColoredRGB('/fwarn [id] [причина] | /unfwarn [id] - Выдача/Удаление выговора человека во фракции (9+)')
						imgui.TextColoredRGB('/fmute [id] [время] [причина] | /funmute [id] - Выдача/Удаление мута человеку во фракции (9+)')
						imgui.TextColoredRGB('/giverank [id] [ранг] - Изменение ранга человека в фракции (9+)')
						imgui.TextColoredRGB('/expel [id] [причина] - Выгнать человека из автошколы (2+)')
					imgui.EndGroup()
					imgui.Spacing()
					imgui.TextColoredRGB('Горячие клавиши:')
					imgui.SetCursorPosX(20)
					imgui.BeginGroup()
						if configuration.main_settings.fmtype == 0 then
							imgui.TextColoredRGB('ПКМ + '..configuration.main_settings.usefastmenu..' - Меню взаимодействия с клиентом')
						end
						if configuration.main_settings.dofastexpel then
							imgui.TextColoredRGB('ПКМ + '..configuration.main_settings.fastexpel..' - Быстрый /expel')
						end
						imgui.TextColoredRGB(configuration.main_settings.fastscreen..' - Быстрый скриншот')
						imgui.TextColoredRGB('Alt + O - Информировать, что делать при отсутствии мед. карты')
						imgui.TextColoredRGB('Alt + U - Остановить отыгровку')
					imgui.EndGroup()
					imgui.Spacing()
					if imgui.Button(u8'Закрыть##команды', imgui.ImVec2(-1, 30)) then imgui.CloseCurrentPopup() end
					imgui.EndPopup()
				end
				imgui.PopStyleVar()
			imgui.EndGroup()
			imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 0)
			imgui.BeginChild('##MainSettingsWindowChild',imgui.ImVec2(-1,-1),false, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
				if mainwindow[0] == 0 then
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.SetCursorPos(imgui.ImVec2(25,50))
					imgui.BeginGroup()
						for k,v in pairs(buttons) do
							imgui.BeginGroup()
								local p = imgui.GetCursorScreenPos()
								if imgui.InvisibleButton(v.name, imgui.ImVec2(150,130)) then
									mainwindow[0] = k
									alpha[0] = clock()
								end

								if v.timer == 0 then
									v.timer = imgui.GetTime()
								end
								if imgui.IsItemHovered() then
									v.y_hovered = ceil(v.y_hovered) > 0 and 10 - ((imgui.GetTime() - v.timer) * 100) or 0
									v.timer = ceil(v.y_hovered) > 0 and v.timer or 0
									imgui.SetMouseCursor(imgui.MouseCursor.Hand)
								else
									v.y_hovered = ceil(v.y_hovered) < 10 and (imgui.GetTime() - v.timer) * 100 or 10
									v.timer = ceil(v.y_hovered) < 10 and v.timer or 0
								end
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + v.y_hovered), imgui.ImVec2(p.x + 150, p.y + 110 + v.y_hovered), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button]), 7)
								imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x-4, p.y + v.y_hovered - 4), imgui.ImVec2(p.x + 154, p.y + 110 + v.y_hovered + 4), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), 10, nil, 1.9)
								imgui.SameLine(10)
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 10 + v.y_hovered)
								imgui.PushFont(font[25])
								imgui.Text(v.icon)
								imgui.PopFont()
								imgui.SameLine(10)
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 30 + v.y_hovered)
								imgui.BeginGroup()
									imgui.PushFont(font[16])
									imgui.Text(u8(v.name))
									imgui.PopFont()
									imgui.Text(u8(v.text))
								imgui.EndGroup()
							imgui.EndGroup()
							if k ~= #buttons then
								imgui.SameLine(k*200)
							end
						end
					imgui.EndGroup()
					imgui.PopStyleVar()
				elseif mainwindow[0] == 1 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Настройки')
					imgui.PopFont()
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(settingsbuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if settingswindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,settingswindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(162,35)) then
								if settingswindow[0] ~= k then
									settingswindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()
					imgui.SetCursorPos(imgui.ImVec2(187, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.BeginChild('##usersettingsmainwindow',_,false)
						if settingswindow[0] == 1 then
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()
								imgui.PushFont(font[16])
								imgui.Text(u8'Основная информация')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
						
									imgui.BeginGroup()
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
										imgui.Text(u8'Ваше имя')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Акцент')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Ваш пол')
										imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
										imgui.Text(u8'Ваш ранг')
									imgui.EndGroup()
						
									imgui.SameLine(90)
									imgui.PushItemWidth(120)
									imgui.BeginGroup()
										if imgui.InputTextWithHint(u8'##mynickinroleplay', u8((gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' '))), usersettings.myname, sizeof(usersettings.myname)) then
											configuration.main_settings.myname = str(usersettings.myname)
											inicfg.save(configuration,'AS Helper')
										end
										imgui.SameLine()
										imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
										imgui.Hint('NoNickNickFromTab','Если не будет указано, то имя будет браться из ника')
									
										if imgui.InputText(u8'##myaccentintroleplay', usersettings.myaccent, sizeof(usersettings.myaccent)) then
											configuration.main_settings.myaccent = str(usersettings.myaccent)
											inicfg.save(configuration,'AS Helper')
										end
									
										imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
										if imgui.Combo(u8'##choosegendercombo',usersettings.gender, new['const char*'][2]({u8'Мужской',u8'Женский'}), 2) then
											configuration.main_settings.gender = usersettings.gender[0]
											inicfg.save(configuration,'AS Helper')
										end
										imgui.PopStyleVar()
									
										if imgui.Button(u8(configuration.RankNames[configuration.main_settings.myrankint]..' ('..u8(configuration.main_settings.myrankint)..')'), imgui.ImVec2(120, 23)) then
											getmyrank = true
											sampSendChat('/stats')
										end
										imgui.Hint('clicktoupdaterang','Нажмите, чтобы перепроверить')
									imgui.EndGroup()
									imgui.PopItemWidth()
									
								imgui.EndGroup()
								imgui.NewLine()
									
								imgui.PushFont(font[16])
								imgui.Text(u8'Меню быстрого доступа')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
									imgui.Text(u8'Тип активации')
									imgui.SameLine(100)
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
									imgui.PushItemWidth(120)
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
									if imgui.Combo(u8'##choosefmtypecombo',usersettings.fmtype, new['const char*'][2]({u8'Клавиша',u8'Команда'}), 2) then
										configuration.main_settings.fmtype = usersettings.fmtype[0]
										inicfg.save(configuration,'AS Helper')
									end
									imgui.PopStyleVar()
									imgui.PopItemWidth()
								
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
									imgui.Text(u8'Активация')
									imgui.SameLine(100)
								
									if configuration.main_settings.fmtype == 0 then
										imgui.Text(u8' ПКМ +')
										imgui.SameLine(nil, 5)
										imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
										imgui.HotKey('меню быстрого доступа', configuration.main_settings, 'usefastmenu', 'E', find(configuration.main_settings.usefastmenu, '+') and 150 or 75)
									
										if imgui.ToggleButton(u8'Создавать маркер при выделении',usersettings.createmarker) then
											if marker ~= nil then
												removeBlip(marker)
											end
											marker = nil
											oldtargettingped = 0
											configuration.main_settings.createmarker = usersettings.createmarker[0]
											inicfg.save(configuration,'AS Helper')
										end
									elseif configuration.main_settings.fmtype == 1 then
										imgui.Text(u8'/')
										imgui.SameLine(110)
										imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
										imgui.PushItemWidth(110)
										if imgui.InputText(u8'[id]##usefastmenucmdbuff',usersettings.usefastmenucmd,sizeof(usersettings.usefastmenucmd)) then
											configuration.main_settings.usefastmenucmd = str(usersettings.usefastmenucmd)
											inicfg.save(configuration,'AS Helper')
										end
										imgui.PopItemWidth()
									end
									
								imgui.EndGroup()
								imgui.NewLine()
								
								imgui.PushFont(font[16])
								imgui.Text(u8'Статистика')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ToggleButton(u8'Отображать окно статистики', usersettings.statsvisible) then
										configuration.main_settings.statsvisible = usersettings.statsvisible[0]
										inicfg.save(configuration,'AS Helper')
									end
									if imgui.Button(fa.ICON_FA_ARROWS_ALT..'##statsscreenpos') then
										if configuration.main_settings.statsvisible then
											changePosition(configuration.imgui_pos)
										else
											addNotify('Включите отображение\nстатистики.', 5)
										end
									end
									imgui.SameLine()
									imgui.Text(u8'Местоположение')
								imgui.EndGroup()
								imgui.NewLine()

								imgui.PushFont(font[16])
								imgui.Text(u8'Остальное')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
								
									if imgui.ToggleButton(u8'Заменять серверные сообщения', usersettings.replacechat) then
										configuration.main_settings.replacechat = usersettings.replacechat[0]
										inicfg.save(configuration,'AS Helper')
									end

									if imgui.ToggleButton(u8'Показывать ранг перед сообщением в рации', usersettings.chatrank) then
										configuration.main_settings.chatrank = usersettings.chatrank[0]
										inicfg.save(configuration,'AS Helper')
									end

									if imgui.ToggleButton(u8'Показывать ранг на груди сотрудника', usersettings.bodyrank) then
										configuration.main_settings.bodyrank = usersettings.bodyrank[0]
										inicfg.save(configuration,'AS Helper')
									end
								
									if imgui.ToggleButton(u8'Быстрый скрин на', usersettings.dofastscreen) then
										configuration.main_settings.dofastscreen = usersettings.dofastscreen[0]
										inicfg.save(configuration,'AS Helper')
									end
									imgui.SameLine()
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
									imgui.HotKey('быстрого скрина', configuration.main_settings, 'fastscreen', 'F4', find(configuration.main_settings.fastscreen, '+') and 150 or 75)

									if imgui.ToggleButton(u8'Быстрый expel на', usersettings.dofastexpel) then
										configuration.main_settings.dofastexpel = usersettings.dofastexpel[0]
										inicfg.save(configuration,'AS Helper')
									end
									imgui.SameLine(nil, 20)
									imgui.Text(u8'ПКМ +')
									imgui.SameLine(nil, 5)
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
									imgui.HotKey('быстрый /expel', configuration.main_settings, 'fastexpel', 'G', find(configuration.main_settings.fastexpel, '+') and 150 or 75)

									imgui.PushItemWidth(85)
									if imgui.InputText(u8'##expelreasonbuff',usersettings.expelreason,sizeof(usersettings.expelreason)) then
										configuration.main_settings.expelreason = u8:decode(str(usersettings.expelreason))
										inicfg.save(configuration,'AS Helper')
									end
									imgui.PopItemWidth()
									imgui.SameLine()
									imgui.Text(u8'Причина /expel')
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 2 then
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()
								imgui.PushFont(font[16])
								imgui.Text(u8'Выбор стиля')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.CircleButton('##choosestyle0', configuration.main_settings.style == 0, imgui.ImVec4(1.00, 0.42, 0.00, 0.90)) then
										configuration.main_settings.style = 0
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle1', configuration.main_settings.style == 1, imgui.ImVec4(1.00, 0.28, 0.28, 0.90)) then
										configuration.main_settings.style = 1
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle2', configuration.main_settings.style == 2, imgui.ImVec4(0.00, 0.35, 1.00, 0.90)) then
										configuration.main_settings.style = 2
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle3', configuration.main_settings.style == 3, imgui.ImVec4(0.41, 0.19, 0.63, 0.90)) then
										configuration.main_settings.style = 3
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle4', configuration.main_settings.style == 4, imgui.ImVec4(0.00, 0.69, 0.33, 0.90)) then
										configuration.main_settings.style = 4
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle5', configuration.main_settings.style == 5, imgui.ImVec4(0.51, 0.51, 0.51, 0.90)) then
										configuration.main_settings.style = 5
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									local pos = imgui.GetCursorPos()
									imgui.SetCursorPos(imgui.ImVec2(pos.x + 1.5, pos.y + 1.5))
									imgui.Image(rainbowcircle,imgui.ImVec2(17,17))
									imgui.SetCursorPos(pos)
									if imgui.CircleButton('##choosestyle6', configuration.main_settings.style == 6, imgui.GetStyle().Colors[imgui.Col.Button], nil, true) then
										configuration.main_settings.style = 6
										inicfg.save(configuration, 'AS Helper.ini')
										checkstyle()
									end
									imgui.Hint('MoonMonetHint','MoonMonet')
								imgui.EndGroup()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 25)
								imgui.NewLine()
								if configuration.main_settings.style == 6 then
									imgui.PushFont(font[16])
									imgui.Text(u8'Цвет акцента Monet')
									imgui.PopFont()
									imgui.SetCursorPosX(25)
									imgui.BeginGroup()
										imgui.PushItemWidth(200)
										if imgui.ColorPicker3('##moonmonetcolorselect', usersettings.moonmonetcolorselect, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.PickerHueWheel + imgui.ColorEditFlags.NoSidePreview) then
											local r,g,b = usersettings.moonmonetcolorselect[0] * 255,usersettings.moonmonetcolorselect[1] * 255,usersettings.moonmonetcolorselect[2] * 255
											local argb = join_argb(255,r,g,b)
											configuration.main_settings.monetstyle = argb
											inicfg.save(configuration, 'AS Helper.ini')
											checkstyle()
										end
										if imgui.SliderFloat('##CHROMA', monetstylechromaselect, 0.5, 2.0, u8'%0.2f c.m.') then
											configuration.main_settings.monetstyle_chroma = monetstylechromaselect[0]
											checkstyle()
										end
										imgui.PopItemWidth()
									imgui.EndGroup()
									imgui.NewLine()
								end
								imgui.PushFont(font[16])
								imgui.Text(u8'Меню быстрого доступа')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.RadioButtonIntPtr(u8('Старый стиль'), usersettings.fmstyle, 0) then
										configuration.main_settings.fmstyle = usersettings.fmstyle[0]
										inicfg.save(configuration,'AS Helper')
									end
									if imgui.IsItemHovered() then
										imgui.SetMouseCursor(imgui.MouseCursor.Hand)
										imgui.SetNextWindowSize(imgui.ImVec2(90, 150))
										imgui.Begin('##oldstyleshow', _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
											local p = imgui.GetCursorScreenPos()
											for i = 0,6 do
												imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + 5, p.y + 7 + i * 20), imgui.ImVec2(p.x + 85, p.y + 22 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, nil, 1.9)
												imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 14 + i * 20), imgui.ImVec2(p.x + 75, p.y + 14 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											end
										imgui.End()
									end
									if imgui.RadioButtonIntPtr(u8('Новый стиль'), usersettings.fmstyle, 1) then
										configuration.main_settings.fmstyle = usersettings.fmstyle[0]
										inicfg.save(configuration,'AS Helper')
									end
									if imgui.IsItemHovered() then
										imgui.SetMouseCursor(imgui.MouseCursor.Hand)
										imgui.SetNextWindowSize(imgui.ImVec2(200, 110))
										imgui.Begin('##newstyleshow', _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
											local p = imgui.GetCursorScreenPos()
											for i = 0,3 do
												imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + 5, p.y + 5 + i * 20), imgui.ImVec2(p.x + 115, p.y + 20 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, nil, 1.9)
												imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 12 + i * 20), imgui.ImVec2(p.x + 105, p.y + 12 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											end
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 120, p.y + 110), imgui.ImVec2(p.x + 120, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 1)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 120, p.y + 25), imgui.ImVec2(p.x + 200, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 1)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 135, p.y + 8), imgui.ImVec2(p.x + 175, p.y + 8), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 178, p.y + 8), imgui.ImVec2(p.x + 183, p.y + 8), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 145, p.y + 18), imgui.ImVec2(p.x + 175, p.y + 18), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 190, p.y + 30), imgui.ImVec2(p.x + 190, p.y + 45), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
											imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 140, p.y + 37), imgui.ImVec2(p.x + 180, p.y + 37), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											for i = 1,3 do
												imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 140, p.y + 37 + i * 20), imgui.ImVec2(p.x + 180, p.y + 37 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
											end
										imgui.End()
									end
								imgui.EndGroup()
								imgui.NewLine()
								imgui.PushFont(font[16])
								imgui.Text(u8'Дополнительно')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ColorEdit4(u8'##RSet', chatcolors.RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.RChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.RChatColor[0], chatcolors.RChatColor[1], chatcolors.RChatColor[2], chatcolors.RChatColor[3]))
										inicfg.save(configuration, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет чата организации')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##RCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.RChatColor = 4282626093
										if inicfg.save(configuration, 'AS Helper.ini') then
											chatcolors.RChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##RTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[R] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: (( Это сообщение видите только Вы! ))', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##DSet', chatcolors.DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.DChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.DChatColor[0], chatcolors.DChatColor[1], chatcolors.DChatColor[2], chatcolors.DChatColor[3]))
										inicfg.save(configuration, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет чата департамента')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##DCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.DChatColor = 4294940723
										if inicfg.save(configuration, 'AS Helper.ini') then
											chatcolors.DChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##DTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[D] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: Это сообщение видите только Вы!', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##SSet', chatcolors.ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										configuration.main_settings.ASChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.ASChatColor[0], chatcolors.ASChatColor[1], chatcolors.ASChatColor[2], chatcolors.ASChatColor[3]))
										inicfg.save(configuration, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет AS Helper в чате')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##SCol',imgui.ImVec2(65,25)) then
										configuration.main_settings.ASChatColor = 4281558783
										if inicfg.save(configuration, 'AS Helper.ini') then
											chatcolors.ASChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor))
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##ASTest',imgui.ImVec2(37,25)) then
										ASHelperMessage('Это сообщение видите только Вы!')
									end
									if imgui.ToggleButton(u8'Убирать полосу прокрутки', usersettings.noscrollbar) then
										configuration.main_settings.noscrollbar = usersettings.noscrollbar[0]
										inicfg.save(configuration,'AS Helper')
										checkstyle()
									end
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 3 then
							imgui.SetCursorPosY(40)
							imgui.TextColoredRGB('Цены {808080}(?)',1)
							imgui.Hint('pricelisthint','Эти числа будут использоваться при озвучивании прайс листа')
							imgui.PushItemWidth(62)
							imgui.SetCursorPosX(91)
							imgui.BeginGroup()
								if imgui.InputText(u8'Авто', pricelist.avtoprice, sizeof(pricelist.avtoprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.avtoprice = str(pricelist.avtoprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Рыбалка', pricelist.ribaprice, sizeof(pricelist.ribaprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.ribaprice = str(pricelist.ribaprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Оружие', pricelist.gunaprice, sizeof(pricelist.gunaprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.gunaprice = str(pricelist.gunaprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Раскопки', pricelist.kladprice, sizeof(pricelist.kladprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.kladprice = str(pricelist.kladprice)
									inicfg.save(configuration,'AS Helper')
								end
							imgui.EndGroup()
							imgui.SameLine(220)
							imgui.BeginGroup()
								if imgui.InputText(u8'Мото', pricelist.motoprice, sizeof(pricelist.motoprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.motoprice = str(pricelist.motoprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Плавание', pricelist.lodkaprice, sizeof(pricelist.lodkaprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.lodkaprice = str(pricelist.lodkaprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Охота', pricelist.huntprice, sizeof(pricelist.huntprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.huntprice = str(pricelist.huntprice)
									inicfg.save(configuration,'AS Helper')
								end
								if imgui.InputText(u8'Такси', pricelist.taxiprice, sizeof(pricelist.taxiprice), imgui.InputTextFlags.CharsDecimal) then
									configuration.main_settings.taxiprice = str(pricelist.taxiprice)
									inicfg.save(configuration,'AS Helper')
								end
							imgui.EndGroup()
							imgui.PopItemWidth()
						end
					imgui.EndChild()
					imgui.PopStyleVar()
				elseif mainwindow[0] == 2 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Дополнительно')
					imgui.PopFont()
				
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(additionalbuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if additionalwindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,additionalwindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(186,35)) then
								if additionalwindow[0] ~= k then
									additionalwindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()
					
					imgui.SetCursorPos(imgui.ImVec2(235, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					if additionalwindow[0] == 1 then
						imgui.BeginChild('##rulesswindow',_,false, imgui.WindowFlags.NoScrollbar)
							imgui.SetCursorPosY(20)
							if ruless['server'] then
								imgui.TextColoredRGB('Правила сервера '..ruless['server']..' + Ваши {808080}(?)',1)
							else
								imgui.TextColoredRGB('Ваши правила {808080}(?)',1)
							end
							imgui.Hint('txtfileforrules','Вы должны создать .txt файл с кодировкой ANSI\nЛКМ для открытия папки с правилами')
							if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
								createDirectory(getWorkingDirectory()..'\\AS Helper\\Rules')
								os.execute('explorer '..getWorkingDirectory()..'\\AS Helper\\Rules')
							end
							imgui.SetCursorPos(imgui.ImVec2(15, 20))
							imgui.Text(fa.ICON_FA_REDO_ALT)
							if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
								checkRules()
							end
							imgui.Hint('updateallrules','Нажмите для обновления всех правил')
							for i = 1, #ruless do
								imgui.SetCursorPosX(15)
								if imgui.Button(u8(ruless[i].name..'##'..i), imgui.ImVec2(330,35)) then
									imgui.StrCopy(search_rule, '')
									RuleSelect = i
									imgui.OpenPopup(u8('Правила'))
								end
							end
							imgui.Spacing()
							imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15,15))
							if imgui.BeginPopupModal(u8('Правила'), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
								imgui.TextColoredRGB(ruless[RuleSelect].name,1)
								imgui.SetCursorPosX(416)
								imgui.PushItemWidth(200)
								imgui.InputTextWithHint('##search_rule', fa.ICON_FA_SEARCH..u8' Искать', search_rule, sizeof(search_rule), imgui.InputTextFlags.EnterReturnsTrue)
								imgui.SameLine(928)
								if imgui.BoolButton(rule_align[0] == 1,fa.ICON_FA_ALIGN_LEFT, imgui.ImVec2(40, 20)) then
									rule_align[0] = 1
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'AS Helper.ini')
								end
								imgui.SameLine()
								if imgui.BoolButton(rule_align[0] == 2,fa.ICON_FA_ALIGN_CENTER, imgui.ImVec2(40, 20)) then
									rule_align[0] = 2
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'AS Helper.ini')
								end
								imgui.SameLine()
								if imgui.BoolButton(rule_align[0] == 3,fa.ICON_FA_ALIGN_RIGHT, imgui.ImVec2(40, 20)) then
									rule_align[0] = 3
									configuration.main_settings.rule_align = rule_align[0]
									inicfg.save(configuration,'AS Helper.ini')
								end
								imgui.BeginChild('##Правила', imgui.ImVec2(1000, 500), true)
								for _ = 1, #ruless[RuleSelect].text do
									if sizeof(search_rule) < 1 then
										imgui.TextColoredRGB(ruless[RuleSelect].text[_],rule_align[0]-1)
										if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
											sampSetChatInputEnabled(true)
											sampSetChatInputText(gsub(ruless[RuleSelect].text[_], '%{.+%}',''))
										end
									else
										if find(string.rlower(ruless[RuleSelect].text[_]), string.rlower(gsub(u8:decode(str(search_rule)), '(%p)','(%%p)'))) then
											imgui.TextColoredRGB(ruless[RuleSelect].text[_],rule_align[0]-1)
											if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
												sampSetChatInputEnabled(true)
												sampSetChatInputText(gsub(ruless[RuleSelect].text[_], '%{.+%}',''))
											end
										end
									end
								end
								imgui.EndChild()
								imgui.SetCursorPosX(416)
								if imgui.Button(u8'Закрыть',imgui.ImVec2(200,25)) then imgui.CloseCurrentPopup() end
								imgui.EndPopup()
							end
							imgui.PopStyleVar()
						imgui.EndChild()
					elseif additionalwindow[0] == 2 then
						imgui.BeginChild('##zametkimainwindow',_,false, imgui.WindowFlags.NoScrollbar)
							imgui.BeginChild('##zametkizametkichild', imgui.ImVec2(-1, 210), false)
								if zametkaredact_number == nil then
									imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(12,6))
									imgui.SetCursorPosY(10)
									imgui.Columns(4)
									imgui.Text('#')
									imgui.SetColumnWidth(-1, 30)
									imgui.NextColumn()
									imgui.Text(u8'Название')
									imgui.SetColumnWidth(-1, 150)
									imgui.NextColumn()
									imgui.Text(u8'Команда')
									imgui.SetColumnWidth(-1, 75)
									imgui.NextColumn()
									imgui.Text(u8'Кнопка')
									imgui.Columns(1)
									imgui.Separator()
									for i = 1, #zametki do
										if imgui.Selectable(u8('##'..i), now_zametka[0] == i) then
											now_zametka[0] = i
										end
										if imgui.IsMouseDoubleClicked(0) and imgui.IsItemHovered() then
											windows.imgui_zametka[0] = true
											zametka_window[0] = now_zametka[0]
										end
									end
									imgui.SetCursorPosY(35)
									imgui.Columns(4)
									for i = 1, #zametki do
										local name, cmd, button = zametki[i].name, zametki[i].cmd, zametki[i].button
										imgui.Text(u8(i))
										imgui.SetColumnWidth(-1, 30)
										imgui.NextColumn()
										imgui.Text(u8(name))
										imgui.SetColumnWidth(-1, 150)
										imgui.NextColumn()
										imgui.Text(u8(#cmd > 0 and '/'..cmd or ''))
										imgui.SetColumnWidth(-1, 75)
										imgui.NextColumn()
										imgui.Text(u8(button))
										imgui.NextColumn()
									end
									imgui.Columns(1)
									imgui.Separator()
									imgui.PopStyleVar()
									imgui.Spacing()
								else
									imgui.SetCursorPos(imgui.ImVec2(60, 20))
									imgui.BeginGroup()
										imgui.PushFont(font[16])
										imgui.TextColoredRGB(zametkaredact_number ~= 0 and 'Редактирование заметки #'..zametkaredact_number or 'Создание новой заметки', 1)
										imgui.PopFont()
										imgui.Spacing()
										
										imgui.TextColoredRGB('{FF2525}* {SSSSSS}Название заметки:')
										imgui.SameLine(125)
										imgui.PushItemWidth(120)
										imgui.InputText('##zametkaeditorname', zametkisettings.zametkaname, sizeof(zametkisettings.zametkaname))

										imgui.TextColoredRGB('{FF2525}* {SSSSSS}Текст заметки:')
										imgui.SameLine(125)
										imgui.PushItemWidth(120)
										if imgui.Button(u8'Редактировать##neworredactzametka', imgui.ImVec2(120, 0)) then
											imgui.OpenPopup(u8'Редактор текста заметки')
										end
									
										imgui.Text(u8'Команда активации:')
										imgui.SameLine(125)
										imgui.InputText('##zametkaeditorcmd', zametkisettings.zametkacmd, sizeof(zametkisettings.zametkacmd))
										imgui.PopItemWidth()
									
										imgui.Text(u8'Бинд активации:')
										imgui.SameLine(125)
										imgui.HotKey((zametkaredact_number ~= 0 and zametkaredact_number or 'новой')..' заметки', zametkisettings, 'zametkabtn', '', 120)
									imgui.EndGroup()

									imgui.SetCursorPos(imgui.ImVec2(60,190))
									if imgui.InvisibleButton('##zametkigoback',imgui.ImVec2(65,15)) then
										zametkaredact_number = nil
										imgui.StrCopy(zametkisettings.zametkacmd, '')
										imgui.StrCopy(zametkisettings.zametkaname, '')
										imgui.StrCopy(zametkisettings.zametkatext, '')
										zametkisettings.zametkabtn = ''
									end
									imgui.SetCursorPos(imgui.ImVec2(60,190))
									imgui.PushFont(font[16])
									imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Отмена')
									imgui.PopFont()
									imgui.SetCursorPos(imgui.ImVec2(220,190))
									if imgui.InvisibleButton('##zametkisave',imgui.ImVec2(85,15)) then
										if #str(zametkisettings.zametkaname) > 0 then
											if #str(zametkisettings.zametkatext) > 0 then
												if zametkaredact_number ~= 0 then
													sampUnregisterChatCommand(zametki[zametkaredact_number].cmd)
												end
												zametki[zametkaredact_number == 0 and #zametki + 1 or zametkaredact_number] = {name = u8:decode(str(zametkisettings.zametkaname)), text = u8:decode(str(zametkisettings.zametkatext)), button = u8:decode(str(zametkisettings.zametkabtn)), cmd = u8:decode(str(zametkisettings.zametkacmd))}
												zametkaredact_number = nil
												local file = io.open(getWorkingDirectory()..'\\AS Helper\\Zametki.json', 'w')
												file:write(encodeJson(zametki))
												file:close()
												updatechatcommands()
											else
												ASHelperMessage('Текст заметки не введен.')
											end
										else
											ASHelperMessage('Название заметки не введено.')
										end
									end
									imgui.SetCursorPos(imgui.ImVec2(220,190))
									imgui.PushFont(font[16])
									imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Сохранить '..fa.ICON_FA_CHEVRON_RIGHT)
									imgui.PopFont()

									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15, 15))
									if imgui.BeginPopupModal(u8'Редактор текста заметки', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
										imgui.Text(u8'Текст:')
										imgui.InputTextMultiline(u8'##zametkatexteditor', zametkisettings.zametkatext, sizeof(zametkisettings.zametkatext), imgui.ImVec2(435,200))
										if imgui.Button(u8'Закрыть', imgui.ImVec2(-1, 25)) then imgui.CloseCurrentPopup() end
										imgui.EndPopup()
									end
									imgui.PopStyleVar()
								end
							imgui.EndChild()
							imgui.SetCursorPosX(7)
							if zametkaredact_number == nil then
								if imgui.Button(fa.ICON_FA_PLUS_CIRCLE..u8' Создать##zametkas') then
									zametkaredact_number = 0
									imgui.StrCopy(zametkisettings.zametkacmd, '')
									imgui.StrCopy(zametkisettings.zametkaname, '')
									imgui.StrCopy(zametkisettings.zametkatext, '')
									zametkisettings.zametkabtn = ''
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_PEN..u8' Изменить') then
									if zametki[now_zametka[0]] then
										zametkaredact_number = now_zametka[0]
										imgui.StrCopy(zametkisettings.zametkacmd, u8(zametki[now_zametka[0]].cmd))
										imgui.StrCopy(zametkisettings.zametkaname, u8(zametki[now_zametka[0]].name))
										imgui.StrCopy(zametkisettings.zametkatext, u8(zametki[now_zametka[0]].text))
										zametkisettings.zametkabtn = zametki[now_zametka[0]].button
									end
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_TRASH..u8' Удалить') then
									if zametki[now_zametka[0]] then
										table.remove(zametki, now_zametka[0])
										now_zametka[0] = 1
									end
									local file = io.open(getWorkingDirectory()..'\\AS Helper\\Zametki.json', 'w')
									file:write(encodeJson(zametki))
									file:close()
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_ARROW_UP) then
									now_zametka[0] = (now_zametka[0] - 1 < 1) and #zametki or now_zametka[0] - 1
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_ARROW_DOWN) then
									now_zametka[0] = (now_zametka[0] + 1 > #zametki) and 1 or now_zametka[0] + 1
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_WINDOW_RESTORE) then
									windows.imgui_zametka[0] = true
									zametka_window[0] = now_zametka[0]
								end
							end
						imgui.EndChild()
					elseif additionalwindow[0] == 3 then
						imgui.BeginChild('##otigrovkiwindow',_,false)
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()

								imgui.Text(u8'Задержка между сообщениями:')
								imgui.PushItemWidth(200)
								if imgui.SliderFloat('##playcd', usersettings.playcd, 0.5, 10.0, '%.1f c.') then
									if usersettings.playcd[0] < 0.5 then usersettings.playcd[0] = 0.5 end
									if usersettings.playcd[0] > 10.0 then usersettings.playcd[0] = 10.0 end
									configuration.main_settings.playcd = usersettings.playcd[0] * 1000
									inicfg.save(configuration,'AS Helper')
								end
								imgui.PopItemWidth()
								imgui.Spacing()
								
								if imgui.ToggleButton(u8'Начинать отыгровки после команд', usersettings.dorponcmd) then
									configuration.main_settings.dorponcmd = usersettings.dorponcmd[0]
									inicfg.save(configuration,'AS Helper')
								end
								
								if imgui.ToggleButton(u8'Автоотыгровка дубинки', usersettings.playdubinka) then
									configuration.main_settings.playdubinka = usersettings.playdubinka[0]
									inicfg.save(configuration,'AS Helper')
								end
								
								if imgui.ToggleButton(u8'Заменять Автошкола на ГЦЛ в отыгровках', usersettings.replaceash) then
									configuration.main_settings.replaceash = usersettings.replaceash[0]
									inicfg.save(configuration,'AS Helper')
								end
							
								if imgui.ToggleButton(u8'Мед. карта на охоту', usersettings.checkmconhunt) then
									configuration.main_settings.checkmconhunt = usersettings.checkmconhunt[0]
									inicfg.save(configuration,'AS Helper')
								end

								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('mconhunt','Если включено, то перед продажей лицензии на охоту будет проверяться мед. карта')

								if imgui.ToggleButton(u8'Мед. карта на оружие', usersettings.checkmcongun) then
									configuration.main_settings.checkmcongun = usersettings.checkmcongun[0]
									inicfg.save(configuration,'AS Helper')
								end

								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('mcongun','Если включено, то перед продажей лицензии на оружие будет проверяться мед. карта')

							imgui.EndGroup()
						imgui.EndChild()
					elseif additionalwindow[0] == 4 then
						imgui.BeginChild('##checkerwindow',_,false)
							local p = imgui.GetWindowPos()
							imgui.SetCursorPos(imgui.ImVec2(25, 20))
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Основное')
								imgui.PopFont()
								if imgui.ToggleButton(u8'Включить чекер', checker_variables.state) then
									configuration.Checker.state = checker_variables.state[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end

								if imgui.Button(fa.ICON_FA_ARROWS_ALT..'##checkerpos') then
									if configuration.Checker.state then
										changePosition(configuration.Checker)
									else
										addNotify('Включите чекер.', 5)
									end
								end
								imgui.SameLine()
								imgui.Text(u8'Местоположение')
							
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
								imgui.Text(u8'Лимит АФК сотрудников(s):')
								imgui.SameLine()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)

								imgui.PushItemWidth(50)
								if imgui.InputInt('##AFKMax_low', checker_variables.afk_max_l, 0, 0) then
									if checker_variables.afk_max_l[0] < 0 then checker_variables.afk_max_l[0] = 0 end
									if checker_variables.afk_max_l[0] > 3599 then checker_variables.afk_max_l[0] = 3599 end
									configuration.Checker.afk_max_l = checker_variables.afk_max_l[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Hint('hint_slider_int_1', ('Младшие ранги (1 - 4)'))
								imgui.SameLine()
								if imgui.InputInt('##AFKMax_High', checker_variables.afk_max_h, 0, 0) then
									if checker_variables.afk_max_h[0] < 0 then checker_variables.afk_max_h[0] = 0 end
									if checker_variables.afk_max_h[0] > 3599 then checker_variables.afk_max_h[0] = 3599 end
									configuration.Checker.afk_max_h = checker_variables.afk_max_h[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Hint('hint_slider_int_2', ('Старшие ранги (5 - 10)'))
								imgui.PopItemWidth()

								imgui.Text(u8'Частота обновления(s):')
								imgui.SameLine(165)

								imgui.PushItemWidth(110)
								if imgui.DragInt('##checkerDelay', checker_variables.delay, 0.5, 3, 30, u8((checker_variables.delay[0]) .. ' секунд')) then
									if checker_variables.delay[0] < 3 then checker_variables.delay[0] = 3 end
									if checker_variables.delay[0] > 30 then checker_variables.delay[0] = 30 end
									configuration.Checker.delay = checker_variables.delay[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Hint('hint_drag', 'Время, спустя которое будет обновляться список\nЗажать и передвигать мышь')
								imgui.PopItemWidth()

							imgui.EndGroup()

							imgui.SetCursorPosX(25)
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Стиль')
								imgui.PopFont()
								imgui.PushItemWidth(130)
								imgui.Text(u8'Название шрифта:')
								imgui.SameLine(140)
								if imgui.InputTextWithHint('##FontName', u8'Название шрифта', checker_variables.font_input, sizeof(checker_variables.font_input)) then
									configuration.Checker.font_name = #str(checker_variables.font_input) > 0 and u8:decode(str(checker_variables.font_input)) or 'Arial'
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								if not imgui.IsItemActive() and #str(checker_variables.font_input) == 0 then
									imgui.StrCopy(checker_variables.font_input, u8'Arial')
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Text(u8'Размер шрифта:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontSize', checker_variables.font_size, 1, 25, u8'%d') then
									if checker_variables.font_size[0] < 1 then checker_variables.font_size[0] = 1 end
									if checker_variables.font_size[0] > 25 then checker_variables.font_size[0] = 25 end
									configuration.Checker.font_size = checker_variables.font_size[0]
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Text(u8'Стиль шрифта:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontFlag', checker_variables.font_flag, 1, 25, u8'%d') then
									if checker_variables.font_flag[0] < 1 then checker_variables.font_flag[0] = 1 end
									if checker_variables.font_flag[0] > 25 then checker_variables.font_flag[0] = 25 end
									configuration.Checker.font_flag = checker_variables.font_flag[0]
									checker_variables.font = renderCreateFont(configuration.Checker.font_name, configuration.Checker.font_size, configuration.Checker.font_flag)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Text(u8'Расстояние строк:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontOffset', checker_variables.font_offset, 1, 30, u8'%d') then
									if checker_variables.font_offset[0] < 1 then checker_variables.font_offset[0] = 1 end
									if checker_variables.font_offset[0] > 30 then checker_variables.font_offset[0] = 30 end
									configuration.Checker.font_offset = checker_variables.font_offset[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.Text(u8'Непрозрачность:')
								imgui.SameLine(140)
								if imgui.SliderInt('##FontAlpha', checker_variables.font_alpha, 1, 100, u8'%d%%') then
									if checker_variables.font_alpha[0] < 1 then checker_variables.font_alpha[0] = 1 end
									if checker_variables.font_alpha[0] > 100 then checker_variables.font_alpha[0] = 100 end
									configuration.Checker.font_alpha = checker_variables.font_alpha[0] * 2.55
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.PopItemWidth()
							imgui.EndGroup()

							imgui.NewLine()
							imgui.SetCursorPosX(25)
							imgui.BeginGroup()
								imgui.SetCursorPosX(15)
								imgui.PushFont(font[16])
								imgui.Text(u8'Отображение')
								imgui.PopFont()
								if imgui.ToggleButton(u8'Рабочая форма', checker_variables.show.uniform) then
									configuration.Checker.show_uniform = checker_variables.show.uniform[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_uniform', 'Показывать кто из сотрудников в форме, а кто нет\n(Аналог /members)')
								if imgui.ToggleButton(u8'Номер должности', checker_variables.show.rank) then
									configuration.Checker.show_rank = checker_variables.show.rank[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								if imgui.ToggleButton(u8'ID Сотрудника', checker_variables.show.id) then
									configuration.Checker.show_id = checker_variables.show.id[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								if imgui.ToggleButton(u8'Время в АФК', checker_variables.show.afk) then
									configuration.Checker.show_afk = checker_variables.show.afk[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								if imgui.ToggleButton(u8'Кол-во выговоров', checker_variables.show.warn) then
									configuration.Checker.show_warn = checker_variables.show.warn[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								if imgui.ToggleButton(u8'Отображать муты', checker_variables.show.mute) then
									configuration.Checker.show_mute = checker_variables.show.mute[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_mute', 'У сотрудников, на которых наложен организационный мут\nбудет пометка Muted в списке')
								if imgui.ToggleButton(u8'Сотрудники рядом', checker_variables.show.near) then
									configuration.Checker.show_near = checker_variables.show.near[0]
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint('hint_near', 'Сотрудники находящиеся в вашей зоне прорисовки\nбудут отмечатся меткой [N] в списке')
							imgui.EndGroup()

							imgui.SameLine(nil, 25)
							imgui.BeginGroup()
								local col = checker_variables.col
								imgui.SetCursorPosX(209)
								imgui.PushFont(font[16])
								imgui.Text(u8'Цвета')
								imgui.PopFont()
								if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.title[0],  col.title[1], col.title[2],  col.title[3])
									configuration.Checker.col_title = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Заголовок')
								if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.default[0], col.default[1], col.default[2], col.default[3]) 
									configuration.Checker.col_default = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Стандартный')
								if imgui.ColorEdit4('##NoWorkColor', col.no_work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.no_work[0], col.no_work[1], col.no_work[2], col.no_work[3]) 
									configuration.Checker.col_no_work = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Без формы')
								if imgui.ColorEdit4('##AFKMaxColor', col.afk_max, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.afk_max[0], col.afk_max[1], col.afk_max[2], col.afk_max[3]) 
									configuration.Checker.col_afk_max = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'AFK Max')
								if imgui.ColorEdit4('##NoteColor', col.note, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
									local c = imgui.ImVec4(col.note[0], col.note[1], col.note[2], col.note[3]) 
									configuration.Checker.col_note = imgui.ColorConvertFloat4ToARGB(c)
									inicfg.save(configuration, 'AS Helper.ini')
								end
								imgui.SameLine()
								imgui.Text(u8'Заметки')
							imgui.EndGroup()
							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 265, p.y + 230), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 'Author: Cosmo')
							imgui.Spacing()
						imgui.EndChild()
					end
					imgui.PopStyleVar()
				elseif mainwindow[0] == 3 then
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					if imgui.InvisibleButton('##settingsbackbutton',imgui.ImVec2(10,15)) then
						mainwindow[0] = 0
						alpha[0] = clock()
					end
					imgui.SetCursorPos(imgui.ImVec2(15,20))
					imgui.PushFont(font[16])
					imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT)
					imgui.PopFont()
					imgui.SameLine()
					local p = imgui.GetCursorScreenPos()
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 5, p.y - 10),imgui.ImVec2(p.x + 5, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
					imgui.SetCursorPos(imgui.ImVec2(60,15))
					imgui.PushFont(font[25])
					imgui.Text(u8'Информация')
					imgui.PopFont()
				
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(infobuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							if infowindow[0] == k then
								local p = imgui.GetCursorScreenPos()
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,infowindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton(i, imgui.ImVec2(186,35)) then
								if infowindow[0] ~= k then
									infowindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()

					imgui.SetCursorPos(imgui.ImVec2(208, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					imgui.BeginChild('##informationmainwindow',_,false)
					if infowindow[0] == 1 then
						imgui.PushFont(font[16])
						imgui.SetCursorPosX(20)
						imgui.BeginGroup()
							if updateinfo.version and updateinfo.version ~= thisScript().version then
								imgui.SetCursorPosY(20)
								imgui.TextColored(imgui.ImVec4(0.92, 0.71, 0.25, 1), fa.ICON_FA_EXCLAMATION_CIRCLE)
								imgui.SameLine()
								imgui.BeginGroup()
									imgui.Text(u8'Обнаружено обновление на версию '..updateinfo.version..'!')
									imgui.PopFont()
									if imgui.Button(u8'Скачать '..fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN) then
										local function DownloadFile(url, file)
											downloadUrlToFile(url,file,function(id,status)
												if status == dlstatus.STATUSEX_ENDDOWNLOAD then
													ASHelperMessage('Обновление успешно загружено, скрипт перезагружается...')
												end
											end)
										end
										DownloadFile(updateinfo.file, thisScript().path)
										NoErrors = true
									end
									imgui.SameLine()
									if imgui.TreeNodeStr(u8'Список изменений') then
										imgui.SetCursorPosX(135)
										imgui.TextWrapped(u8(updateinfo.change_log))
										imgui.TreePop()
									end
								imgui.EndGroup()
							elseif updateinfo.version and updateinfo.version == thisScript().version then
								imgui.SetCursorPosY(30)
								imgui.TextColored(imgui.ImVec4(0.2, 1, 0.2, 1), fa.ICON_FA_CHECK_CIRCLE)
								imgui.SameLine()
								imgui.SetCursorPosY(20)
								imgui.BeginGroup()
									imgui.Text(u8'У вас установлена последняя версия скрипта.')
									imgui.PushFont(font[11])
									imgui.TextColoredRGB('{SSSSSS90}Время последней проверки: '..(updateinfo.updatelastcheck or 'не определено'))
									imgui.PopFont()
									imgui.PopFont()
									imgui.Spacing()
									if imgui.Button(u8'Проверить наличие обновлений') then
										checkUpdates('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/Updates/update.json', true)
									end
								imgui.EndGroup()
							else
								imgui.SetCursorPosY(30)
								imgui.TextColored(imgui.ImVec4(1, 0.2, 0.2, 1), fa.ICON_FA_TIMES_CIRCLE)
								imgui.SameLine()
								imgui.SetCursorPosY(20)
								imgui.BeginGroup()
									imgui.Text(u8'Обновление не проверено.')
									imgui.PushFont(font[11])
									imgui.TextColoredRGB('{SSSSSS90}Время последней проверки: '..(updateinfo.updatelastcheck or 'не определено'))
									imgui.PopFont()
									imgui.PopFont()
									imgui.Spacing()
									if imgui.Button(u8'Проверить наличие обновлений') then
										checkUpdates('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/Updates/update.json', true)
									end
								imgui.EndGroup()
							end
							imgui.NewLine()
							imgui.PushFont(font[15])
							imgui.Text(u8'Параметры')
							imgui.PopFont()
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Авто-проверка обновлений', auto_update_box) then
								configuration.main_settings.autoupdate = auto_update_box[0]
								inicfg.save(configuration,'AS Helper')
							end
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Получать бета релизы', get_beta_upd_box) then
								configuration.main_settings.getbetaupd = get_beta_upd_box[0]
								inicfg.save(configuration,'AS Helper')
							end
							imgui.SameLine()
							imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
							imgui.Hint('betareleaseshint', 'После включения данной функции Вы будете получать\nобновления раньше других людей для тестирования и\nсообщения о багах разработчику.\n{FF1010}Работа этих версий не будет гарантирована.')
						imgui.EndGroup()
					elseif infowindow[0] == 2 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							if testCheat('dev') then
								configuration.main_settings.myrankint = 10
								addNotify('{20FF20}Режим разработчика включён.', 5)
								sampRegisterChatCommand('ash_temp',function()
									fastmenuID = select(2, sampGetPlayerIdByCharHandle(playerPed))
									windows.imgui_fm[0] = true
								end)
							end
							imgui.PushFont(font[15])
							imgui.TextColoredRGB('Автор - {MC}JustMini')
							imgui.PopFont()
							imgui.NewLine()

							imgui.TextWrapped(u8'Если Вы нашли баг или хотите предложить улучшение/изменение для скрипта, то можете связаться со мной в VK.')
							imgui.SetCursorPosX(25)
							imgui.Text(fa.ICON_FA_LINK)
							imgui.SameLine(40)
							imgui.Text(u8'Связаться со мной в VK:')
							imgui.SameLine(190)
							imgui.Link('https://vk.com/justmini', u8'vk.com/justmini')

							imgui.Spacing()

							imgui.TextWrapped(u8'Если Вы находите этот скрипт полезным, то можете поддержать разработку деньгами.')
							imgui.SetCursorPosX(25)
							imgui.TextColored(imgui.ImVec4(0.31,0.78,0.47,1), fa.ICON_FA_GEM)
							imgui.SameLine(40)
							imgui.Text(u8'Поддержать разработку:')
							imgui.SameLine(190)
							imgui.Link('https://www.donationalerts.com/r/justmini', 'donationalerts.com/r/justmini')
						imgui.EndGroup()
					elseif infowindow[0] == 3 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							imgui.PushFont(font[16])
							imgui.TextColoredRGB('AS Helper',1)
							imgui.PopFont()
							imgui.TextColoredRGB('Версия скрипта - {MC}'..thisScript().version)
							if imgui.Button(u8'Список изменений') then
								windows.imgui_changelog[0] = true
							end
							imgui.Link('https://www.blast.hk/threads/87533/', u8'Тема на Blast Hack')
							imgui.Separator()
							imgui.TextWrapped(u8[[
	* AS Helper - удобный помощник, который облегчит Вам работу в Автошколе. Скрипт был разработан специально для проекта Arizona RP. Скрипт имеет открытый код для ознакомления, любое выставление скрипта без указания авторства запрещено! Обновления скрипта происходят безопасно для Вас, автообновления нет, установку должны подтверждать Вы.

	* Меню быстрого доступа - Прицелившись на игрока с помощью ПКМ и нажав кнопку E (по умолчанию), откроется меню быстрого доступа. В данном меню есть все нужные функции, а именно: приветствие, озвучивание прайс листа, продажа лицензий, возможность выгнать человека из автошколы, приглашение в организацию, увольнение из организации, изменение должности, занесение в ЧС, удаление из ЧС, выдача выговоров, удаление выговоров, выдача организационного мута, удаление организационного мута, автоматизированное проведение собеседования со всеми нужными отыгровками.

	* Команды сервера с отыгровками - /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. Введя любую из этих команд начнётся РП отыгровка, лишь после неё будет активирована сама команда (эту функцию можно отключить в настройках).

	* Команды хелпера - /ash - настройки хелпера, /ashbind - биндер хелпера, /ashlect - меню лекций, /ashdep - меню департамента

	* Настройки - Введя команду /ash откроются настройки в которых можно изменять никнейм в приветствии, акцент, создание маркера при выделении, пол, цены на лицензии, горячую клавишу быстрого меню и многое другое.

	* Меню лекций - Введя команду /ashlect откроется меню лекций, в котором вы сможете озвучить/добавить/удалить лекции.

	* Биндер - Введя команду /ashbind откроется биндер, в котором вы можете создать абсолютно любой бинд на команду, или же кнопку(и).]])
						imgui.Spacing()
						imgui.EndGroup()
					end
					imgui.EndChild()
					imgui.PopStyleVar()
				end
			imgui.EndChild()
			imgui.PopStyleVar()
		imgui.End()
		imgui.PopStyleVar()
	end
)

local imgui_binder = imgui.OnFrame(
	function() return windows.imgui_binder[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(650, 370), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Биндер', windows.imgui_binder, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
		imgui.Image(ash_image,imgui.ImVec2(202,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.4 or 0.5),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.5 or 0.6))
		imgui.SameLine(583)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		if choosedslot then
			if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE,imgui.ImVec2(23,23)) then
				imgui.OpenPopup(u8'Тэги')
			end
		end
		imgui.SameLine(606)
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_binder[0] = false
		end
		imgui.PopStyleColor(3)
		if imgui.BeginPopup(u8'Тэги', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			for k,v in pairs(tagbuttons) do
				if imgui.Button(u8(tagbuttons[k].name),imgui.ImVec2(150,25)) then
					imgui.StrCopy(bindersettings.binderbuff, str(bindersettings.binderbuff)..u8(tagbuttons[k].name))
					ASHelperMessage('Тэг был скопирован.')
				end
				imgui.SameLine()
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8(tagbuttons[k].hint))
					imgui.EndTooltip()
				end
				imgui.Text(u8(tagbuttons[k].text))
			end
			imgui.EndPopup()
		end
		imgui.BeginChild('ChildWindow',imgui.ImVec2(175,270),true, (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
		imgui.SetCursorPosY(7.5)
		for key, value in pairs(configuration.BindsName) do
			imgui.SetCursorPosX(7.5)
			if imgui.Button(u8(configuration.BindsName[key]..'##'..key),imgui.ImVec2(160,30)) then
				choosedslot = key
				imgui.StrCopy(bindersettings.binderbuff, gsub(u8(configuration.BindsAction[key]), '~', '\n' ) or '')
				imgui.StrCopy(bindersettings.bindername, u8(configuration.BindsName[key] or ''))
				imgui.StrCopy(bindersettings.bindercmd, u8(configuration.BindsCmd[key] or ''))
				imgui.StrCopy(bindersettings.binderdelay, u8(configuration.BindsDelay[key] or ''))
				bindersettings.bindertype[0] = configuration.BindsType[key] or 0
				bindersettings.binderbtn = configuration.BindsKeys[key] or ''
			end
		end
		imgui.EndChild()
		if choosedslot ~= nil and choosedslot <= 50 then
			imgui.SameLine()
			imgui.BeginChild('ChildWindow2',imgui.ImVec2(435,200),false)
			imgui.InputTextMultiline('##bindertexteditor', bindersettings.binderbuff, sizeof(bindersettings.binderbuff), imgui.ImVec2(435,200))
			imgui.EndChild()
			imgui.SetCursorPos(imgui.ImVec2(206.5, 261))
			imgui.Text(u8'Название бинда:')
			imgui.SameLine()
			imgui.PushItemWidth(150)
			if choosedslot ~= 50 then imgui.InputText('##bindersettings.bindername', bindersettings.bindername,sizeof(bindersettings.bindername),imgui.InputTextFlags.ReadOnly)
			else imgui.InputText('##bindersettings.bindername', bindersettings.bindername, sizeof(bindersettings.bindername))
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.PushItemWidth(162)
			imgui.Combo('##binderchoosebindtype', bindersettings.bindertype, new['const char*'][2]({u8'Использовать команду', u8'Использовать клавиши'}), 2)
			imgui.PopItemWidth()
			imgui.SetCursorPos(imgui.ImVec2(206.5, 293))
			imgui.TextColoredRGB('Задержка между строками {FF4500}(ms):'); imgui.SameLine()
			imgui.Hint('msbinderhint','Указывайте значение в миллисекундах\n1 секунда = 1.000 миллисекунд')
			imgui.PushItemWidth(64)
			imgui.InputText('##bindersettings.binderdelay', bindersettings.binderdelay, sizeof(bindersettings.binderdelay), imgui.InputTextFlags.CharsDecimal)
			if tonumber(str(bindersettings.binderdelay)) and tonumber(str(bindersettings.binderdelay)) > 60000 then
				imgui.StrCopy(bindersettings.binderdelay, '60000')
			elseif tonumber(str(bindersettings.binderdelay)) and tonumber(str(bindersettings.binderdelay)) < 1 then
				imgui.StrCopy(bindersettings.binderdelay, '1')
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			if bindersettings.bindertype[0] == 0 then
				imgui.Text('/')
				imgui.SameLine()
				imgui.PushItemWidth(145)
				imgui.InputText('##bindersettings.bindercmd',bindersettings.bindercmd,sizeof(bindersettings.bindercmd),imgui.InputTextFlags.CharsNoBlank)
				imgui.PopItemWidth()
			elseif bindersettings.bindertype[0] == 1 then
				imgui.HotKey('##binderbinder', bindersettings, 'binderbtn', '', 162)
			end
			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(535, 330))
			if #str(bindersettings.binderbuff) > 0 and #str(bindersettings.bindername) > 0 and #str(bindersettings.binderdelay) > 0 and bindersettings.bindertype[0] ~= nil then
				if imgui.Button(u8'Сохранить',imgui.ImVec2(100,30)) then
					local kei = nil
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							if u8:decode(str(bindersettings.bindername)) == tostring(value) then
								sampUnregisterChatCommand(configuration.BindsCmd[key])
								kei = key
							end
						end
						local refresh_text = gsub(u8:decode(str(bindersettings.binderbuff)), '\n', '~')
						if kei ~= nil then
							configuration.BindsName[kei] = u8:decode(str(bindersettings.bindername))
							configuration.BindsDelay[kei] = str(bindersettings.binderdelay)
							configuration.BindsAction[kei] = refresh_text
							configuration.BindsType[kei]= bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								configuration.BindsCmd[kei] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								configuration.BindsKeys[kei] = bindersettings.binderbtn
							end
							if inicfg.save(configuration, 'AS Helper') then
								ASHelperMessage('Бинд успешно сохранён!')
							end
						else
							configuration.BindsName[#configuration.BindsName + 1] = u8:decode(str(bindersettings.bindername))
							configuration.BindsDelay[#configuration.BindsDelay + 1] = str(bindersettings.binderdelay)
							configuration.BindsAction[#configuration.BindsAction + 1] = refresh_text
							configuration.BindsType[#configuration.BindsType + 1] = bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								configuration.BindsCmd[#configuration.BindsCmd + 1] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								configuration.BindsKeys[#configuration.BindsKeys + 1] = bindersettings.binderbtn
							end
							if inicfg.save(configuration, 'AS Helper') then
								ASHelperMessage('Бинд успешно создан!')
							end
						end
						imgui.StrCopy(bindersettings.bindercmd, '')
						imgui.StrCopy(bindersettings.binderbuff, '')
						imgui.StrCopy(bindersettings.bindername, '')
						imgui.StrCopy(bindersettings.binderdelay, '')
						imgui.StrCopy(bindersettings.bindercmd, '')
						bindersettings.bindertype[0] = 0
						choosedslot = nil
						updatechatcommands()
					else
						ASHelperMessage('Вы не можете взаимодействовать с биндером во время любой отыгровки!')
					end	
				end
			else
				imgui.LockedButton(u8'Сохранить',imgui.ImVec2(100,30))
				imgui.Hint('notallparamsbinder','Вы ввели не все параметры. Перепроверьте всё.')
			end
			imgui.SameLine()
			imgui.SetCursorPosX(202)
			if imgui.Button(u8'Отменить',imgui.ImVec2(100,30)) then
				imgui.StrCopy(bindersettings.bindercmd, '')
				imgui.StrCopy(bindersettings.binderbuff, '')
				imgui.StrCopy(bindersettings.bindername, '')
				imgui.StrCopy(bindersettings.binderdelay, '')
				imgui.StrCopy(bindersettings.bindercmd, '')
				bindersettings.bindertype[0] = 0
				choosedslot = nil
			end
		else
			imgui.SetCursorPos(imgui.ImVec2(240,180))
			imgui.Text(u8'Откройте бинд или создайте новый для меню редактирования.')
		end
		imgui.SetCursorPos(imgui.ImVec2(14, 330))
		if imgui.Button(u8'Добавить',imgui.ImVec2(82,30)) then
			choosedslot = 50
			imgui.StrCopy(bindersettings.binderbuff, '')
			imgui.StrCopy(bindersettings.bindername, '')
			imgui.StrCopy(bindersettings.bindercmd, '')
			imgui.StrCopy(bindersettings.binderdelay, '')
			bindersettings.bindertype[0] = 0
		end
		imgui.SameLine()
		if choosedslot ~= nil and choosedslot ~= 50 then
			if imgui.Button(u8'Удалить',imgui.ImVec2(82,30)) then
				if not inprocess then
					for key, value in pairs(configuration.BindsName) do
						local value = tostring(value)
						if u8:decode(str(bindersettings.bindername)) == configuration.BindsName[key] then
							sampUnregisterChatCommand(configuration.BindsCmd[key])
							table.remove(configuration.BindsName,key)
							table.remove(configuration.BindsKeys,key)
							table.remove(configuration.BindsAction,key)
							table.remove(configuration.BindsCmd,key)
							table.remove(configuration.BindsDelay,key)
							table.remove(configuration.BindsType,key)
							if inicfg.save(configuration,'AS Helper') then
								imgui.StrCopy(bindersettings.bindercmd, '')
								imgui.StrCopy(bindersettings.binderbuff, '')
								imgui.StrCopy(bindersettings.bindername, '')
								imgui.StrCopy(bindersettings.binderdelay, '')
								imgui.StrCopy(bindersettings.bindercmd, '')
								bindersettings.bindertype[0] = 0
								choosedslot = nil
								ASHelperMessage('Бинд успешно удалён!')
							end
						end
					end
					updatechatcommands()
				else
					ASHelperMessage('Вы не можете удалять бинд во время любой отыгровки!')
				end
			end
		else
			imgui.LockedButton(u8'Удалить',imgui.ImVec2(82,30))
			imgui.Hint('choosedeletebinder','Выберите бинд который хотите удалить')
		end
		imgui.End()
	end
)

local imgui_lect = imgui.OnFrame(
	function() return windows.imgui_lect[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(435, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Лекции', windows.imgui_lect, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
		imgui.Image(ash_image,imgui.ImVec2(199,25),imgui.ImVec2(0.25,configuration.main_settings.style ~= 2 and 0.6 or 0.7),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.7 or 0.8))
		imgui.SameLine(401)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_lect[0] = false
		end
		imgui.PopStyleColor(3)
		imgui.Separator()
		if imgui.RadioButtonIntPtr(u8('Чат'), lectionsettings.lection_type, 1) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/s'), lectionsettings.lection_type, 4) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/r'), lectionsettings.lection_type, 2) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/rb'), lectionsettings.lection_type, 3) then
			configuration.main_settings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(configuration,'AS Helper')
		end
		imgui.SameLine()
		imgui.SetCursorPosX(245)
		imgui.PushItemWidth(50)
		if imgui.DragInt('##lectionsettings.lection_delay', lectionsettings.lection_delay, 0.1, 1, 30, u8('%d с.')) then
			if lectionsettings.lection_delay[0] < 1 then lectionsettings.lection_delay[0] = 1 end
			if lectionsettings.lection_delay[0] > 30 then lectionsettings.lection_delay[0] = 30 end
			configuration.main_settings.lection_delay = lectionsettings.lection_delay[0]
			inicfg.save(configuration,'AS Helper')
			end
		imgui.Hint('lectiondelay','Задержка между сообщениями')
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.SetCursorPosX(307)
		if imgui.Button(u8'Создать новую '..fa.ICON_FA_PLUS_CIRCLE, imgui.ImVec2(112, 24)) then
			lection_number = nil
			imgui.StrCopy(lectionsettings.lection_name, '')
			imgui.StrCopy(lectionsettings.lection_text, '')
			imgui.OpenPopup(u8('Редактор лекций'))
		end
		imgui.Separator()
		if #lections.data == 0 then
			imgui.SetCursorPosY(120)
			imgui.TextColoredRGB('У Вас нет ни одной лекции.',1)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) * 0.5)
			if imgui.Button(u8'Восстановить изначальные лекции', imgui.ImVec2(250, 25)) then
				local function copy(obj, seen)
					if type(obj) ~= 'table' then return obj end
					if seen and seen[obj] then return seen[obj] end
					local s = seen or {}
					local res = setmetatable({}, getmetatable(obj))
					s[obj] = res
					for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
					return res
				end
				lections = copy(default_lect)
				local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
				file:write(encodeJson(lections))
				file:close()
			end
		else
			for i = 1, #lections.data do
				if lections.active.bool == true then
					if lections.data[i].name == lections.active.name then
						if imgui.Button(fa.ICON_FA_PAUSE..'##'..u8(lections.data[i].name), imgui.ImVec2(280, 25)) then
							inprocess = nil
							lections.active.bool = false
							lections.active.name = nil
							lections.active.handle:terminate()
							lections.active.handle = nil
						end
					else
						imgui.LockedButton(u8(lections.data[i].name), imgui.ImVec2(280, 25))
					end
					imgui.SameLine()
					imgui.LockedButton(fa.ICON_FA_PEN..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25))
					imgui.SameLine()
					imgui.LockedButton(fa.ICON_FA_TRASH..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25))
				else
					if imgui.Button(u8(lections.data[i].name), imgui.ImVec2(280, 25)) then
						lections.active.bool = true
						lections.active.name = lections.data[i].name
						lections.active.handle = lua_thread.create(function()
							for key = 1, #lections.data[i].text do
								if lectionsettings.lection_type[0] == 2 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/r %s', lections.data[i].text[key]))
									end
								elseif lectionsettings.lection_type[0] == 3 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/rb %s', lections.data[i].text[key]))
									end
								elseif lectionsettings.lection_type[0] == 4 then
									if lections.data[i].text[key]:sub(1,1) == '/' then
										sampSendChat(lections.data[i].text[key])
									else
										sampSendChat(format('/s %s', lections.data[i].text[key]))
									end
								else
									sampSendChat(lections.data[i].text[key])
								end
								if key ~= #lections.data[i].text then
									wait(lectionsettings.lection_delay[0] * 1000)
								end
							end
							lections.active.bool = false
							lections.active.name = nil
							lections.active.handle = nil
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_FA_PEN..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25)) then
						lection_number = i
						imgui.StrCopy(lectionsettings.lection_name, u8(tostring(lections.data[i].name)))
						imgui.StrCopy(lectionsettings.lection_text, u8(tostring(table.concat(lections.data[i].text, '\n'))))
						imgui.OpenPopup(u8'Редактор лекций')
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_FA_TRASH..'##'..u8(lections.data[i].name), imgui.ImVec2(50, 25)) then
						lection_number = i
						imgui.OpenPopup('##delete')
					end
				end
			end
		end
		if imgui.BeginPopup('##delete') then
			imgui.TextColoredRGB('Вы уверены, что хотите удалить лекцию \n\''..(lections.data[lection_number].name)..'\'',1)
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 100 - imgui.GetStyle().ItemSpacing.x) * 0.5 )
			if imgui.Button(u8'Да',imgui.ImVec2(50,25)) then
				imgui.CloseCurrentPopup()
				table.remove(lections.data, lection_number)
				local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
				file:write(encodeJson(lections))
				file:close()
			end
			imgui.SameLine()
			if imgui.Button(u8'Нет',imgui.ImVec2(50,25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8'Редактор лекций', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.InputTextWithHint('##lecteditor', u8'Название лекции', lectionsettings.lection_name, sizeof(lectionsettings.lection_name))
			imgui.Text(u8'Текст лекции: ')
			imgui.InputTextMultiline('##lecteditortext', lectionsettings.lection_text, sizeof(lectionsettings.lection_text), imgui.ImVec2(700, 300))
			imgui.SetCursorPosX(209)
			if #str(lectionsettings.lection_name) > 0 and #str(lectionsettings.lection_text) > 0 then
				if imgui.Button(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25)) then
					local pack = function(text, match)
						local array = {}
						for line in gmatch(text, '[^'..match..']+') do
							array[#array + 1] = line
						end
						return array
					end
					if lection_number == nil then
						lections.data[#lections.data + 1] = {
							name = u8:decode(str(lectionsettings.lection_name)),
							text = pack(u8:decode(str(lectionsettings.lection_text)), '\n')
						}
					else
						lections.data[lection_number].name = u8:decode(str(lectionsettings.lection_name))
						lections.data[lection_number].text = pack(u8:decode(str(lectionsettings.lection_text)), '\n')
					end
					local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25))
				imgui.Hint('notallparamslecteditor','Вы ввели не все параметры. Перепроверьте всё.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Отменить##lecteditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.Spacing()
			imgui.EndPopup()
		end
		imgui.End()
	end
)

local imgui_depart = imgui.OnFrame(
	function() return windows.imgui_depart[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 365), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'#depart', windows.imgui_depart, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Image(ash_image,imgui.ImVec2(266,25),imgui.ImVec2(0,configuration.main_settings.style ~= 2 and 0 or 0.1),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.1 or 0.2))
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
		imgui.SameLine(622)
		imgui.Button(fa.ICON_FA_INFO_CIRCLE,imgui.ImVec2(23,23))
		imgui.Hint('waitwaitwait!!!','Пока что это окно функционирует как должно не на всех серверах\nВ будущих обновлениях будут доступны более детальные настройки')
		imgui.SameLine(645)
		if imgui.Button(fa.ICON_FA_MINUS_SQUARE,imgui.ImVec2(23,23)) then
			if #dephistory ~= 0 then
				dephistory = {}
				ASHelperMessage('История сообщений успешно очищена.')
			end
		end
		imgui.Hint('clearmessagehistory','Очистить историю сообщений')
		imgui.SameLine(668)
		if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
			windows.imgui_depart[0] = false
		end
		imgui.PopStyleColor(3)

		imgui.BeginChild('##depbuttons',imgui.ImVec2(180,300),true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
			imgui.PushItemWidth(150)
			imgui.TextColoredRGB('Тэг вашей организации {FF2525}*',1)
			if imgui.InputTextWithHint('##myorgnamedep',u8('Автошкола'),departsettings.myorgname, sizeof(departsettings.myorgname)) then
				configuration.main_settings.astag = u8:decode(str(departsettings.myorgname))
			end
			imgui.TextColoredRGB('Тэг с кем связываетесь {FF2525}*',1)
			imgui.InputTextWithHint('##toorgnamedep',u8('Банк'),departsettings.toorgname, sizeof(departsettings.toorgname))
			imgui.TextColoredRGB('Частота соеденения',1)
			imgui.InputTextWithHint('##frequencydep','100,3',departsettings.frequency, sizeof(departsettings.frequency))
			imgui.PopItemWidth()
			imgui.NewLine()

			if imgui.Button(u8'Перейти на частоту',imgui.ImVec2(150,25)) then
				if #str(departsettings.frequency) > 0 and #str(departsettings.myorgname) > 0 then
					sendchatarray(2000, {
						{'/r Перехожу на частоту %s', gsub(u8:decode(str(departsettings.frequency)), '%.',',')},
						{'/d [%s] - [Информация] Перешёл на частоту %s', u8:decode(str(departsettings.myorgname)), gsub(u8:decode(str(departsettings.frequency)), '%.',',')}
					})
				else
					ASHelperMessage('У Вас что-то не указано.')
				end
			end
			imgui.Hint('/r hint depart',format('/r Перехожу на частоту %s\n/d [%s] - [Информация] Перешёл на частоту %s', gsub(u8:decode(str(departsettings.frequency)), '%.',','),u8:decode(str(departsettings.myorgname)), gsub(u8:decode(str(departsettings.frequency)), '%.',',')))

			if imgui.Button(u8'Покинуть частоту',imgui.ImVec2(150,25)) then
				if #str(departsettings.frequency) > 0 and #str(departsettings.myorgname) > 0 then
					sampSendChat('/d ['..u8:decode(str(departsettings.myorgname))..'] - [Информация] Покидаю частоту '..gsub(u8:decode(str(departsettings.frequency)), '%.',','))
				else
					ASHelperMessage('У Вас что-то не указано.')
				end
			end
			imgui.Hint('/d hint depart','/d ['..u8:decode(str(departsettings.myorgname))..'] - [Информация] Покидаю частоту '..gsub(u8:decode(str(departsettings.frequency)), '%.',','))

			if imgui.Button(u8'Тех. Неполадки',imgui.ImVec2(150,25)) then
				if #str(departsettings.myorgname) > 0 then
					sampSendChat('/d ['..u8:decode(str(departsettings.myorgname))..'] - [Информация] Тех. Неполадки')
				else
					ASHelperMessage('У Вас что-то не указано.')
				end
			end
			imgui.Hint('teh hint depart','/d ['..u8:decode(str(departsettings.myorgname))..'] - [Информация] Тех. Неполадки')
		imgui.EndChild()

		imgui.SameLine()

		imgui.BeginChild('##deptext',imgui.ImVec2(480,265),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetScrollY(imgui.GetScrollMaxY())
			imgui.TextColoredRGB('История сообщений департамента {808080}(?)',1)
			imgui.Hint('mytagfind depart','Если в чате департамента будет тэг \''..u8:decode(str(departsettings.myorgname))..'\'\nв этот список добавится это сообщение')
			imgui.Separator()
			for k,v in pairs(dephistory) do
				imgui.TextWrapped(u8(v))
			end
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(207,323))
		imgui.PushItemWidth(368)
		imgui.InputTextWithHint('##myorgtextdep', u8'Напишите сообщение', departsettings.myorgtext, sizeof(departsettings.myorgtext))
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(u8'Отправить',imgui.ImVec2(100,24)) then
			if #str(departsettings.myorgname) > 0 and #str(departsettings.toorgname) > 0 and #str(departsettings.myorgtext) > 0 then
				if #str(departsettings.frequency) > 0 then
					sampSendChat(format('/d [%s] - %s - [%s] %s', u8:decode(str(departsettings.myorgname)), gsub(u8:decode(str(departsettings.frequency)), '%.',','),u8:decode(str(departsettings.toorgname)),u8:decode(str(departsettings.myorgtext))))
				else
					sampSendChat(format('/d [%s] - [%s] %s', u8:decode(str(departsettings.myorgname)),u8:decode(str(departsettings.toorgname)),u8:decode(str(departsettings.myorgtext))))
				end
				imgui.StrCopy(departsettings.myorgtext, '')
			else
				ASHelperMessage('У Вас что-то не указано.')
			end
		end
		imgui.End()
	end
)

local imgui_changelog = imgui.OnFrame(
	function() return windows.imgui_changelog[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(850, 600), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'##changelog', windows.imgui_changelog, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.Image(ash_image,imgui.ImVec2(238,25),imgui.ImVec2(0.10,configuration.main_settings.style ~= 2 and 0.201 or 0.3),imgui.ImVec2(1,configuration.main_settings.style ~= 2 and 0.3 or 0.4))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(810)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_changelog[0] = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.SetCursorPosY(49)
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
			imgui.BeginChild('##TEXTEXTEXT',imgui.ImVec2(-1,-1),false, imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPos(imgui.ImVec2(15,15))
				imgui.BeginGroup()
					for i = #changelog.versions, 1 , -1 do
						imgui.PushFont(font[25])
						imgui.Text(u8('Версия: '..changelog.versions[i].version..' | '..changelog.versions[i].date))
						imgui.PopFont()
						imgui.PushFont(font[16])
						for _,line in pairs(changelog.versions[i].text) do
							if find(line, '%{LINK:.*||.*%}') then
								local name, link = line:match('%{LINK:(.*)||(.*)%}')
								local symbol, lsymbol = line:find('%{.+%}')
								imgui.TextWrapped(u8(' - '..line:sub(1, symbol-1)))
								imgui.SameLine(nil, 0)
								imgui.Link(link, u8(name))
								imgui.SameLine(nil, 0)
								imgui.TextWrapped(u8(line:sub(lsymbol+1)))
							elseif find(line, '%{HINT:.*%}') then
								local text = line:match('%{HINT:(.*)%}')
								imgui.TextWrapped(u8(' - '..gsub(line, '%{HINT:.+%}', '')))
								imgui.SameLine(nil, 5)
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.Hint(line,text)
							else
								imgui.TextWrapped(u8(' - '..line))
							end
						end
						imgui.PopFont()
						if changelog.versions[i].patches then
							imgui.Spacing()
							imgui.PushFont(font[16])
							imgui.TextColoredRGB('{25a5db}Исправления '..(changelog.versions[i].patches.active and '<<' or '>>'))
							imgui.PopFont()
							if imgui.IsItemHovered() and imgui.IsMouseReleased(0) then
								changelog.versions[i].patches.active = not changelog.versions[i].patches.active
							end
							if changelog.versions[i].patches.active then
								imgui.Text(u8(changelog.versions[i].patches.text))
							end
						end
						imgui.NewLine()
					end
				imgui.EndGroup()
			imgui.EndChild()
			imgui.PopStyleColor()
		imgui.End()
		imgui.PopStyleVar()
	end
)

local imgui_stats = imgui.OnFrame(
	function() return configuration.main_settings.statsvisible end,
	function(player)
		player.HideCursor = true
		imgui.SetNextWindowSize(imgui.ImVec2(150, 190), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(configuration.imgui_pos.posX,configuration.imgui_pos.posY),imgui.Cond.Always)
		imgui.Begin(u8'Статистика  ##stats',_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		imgui.Text(fa.ICON_FA_CAR..u8' Авто - '..configuration.my_stats.avto)
		imgui.Text(fa.ICON_FA_MOTORCYCLE..u8' Мото - '..configuration.my_stats.moto)
		imgui.Text(fa.ICON_FA_FISH..u8' Рыболовство - '..configuration.my_stats.riba)
		imgui.Text(fa.ICON_FA_SHIP..u8' Плавание - '..configuration.my_stats.lodka)
		imgui.Text(fa.ICON_FA_CROSSHAIRS..u8' Оружие - '..configuration.my_stats.guns)
		imgui.Text(fa.ICON_FA_SKULL_CROSSBONES..u8' Охота - '..configuration.my_stats.hunt)
		imgui.Text(fa.ICON_FA_DIGGING..u8' Раскопки - '..configuration.my_stats.klad)
		imgui.Text(fa.ICON_FA_TAXI..u8' Такси - '..configuration.my_stats.taxi)
		imgui.End()
	end
)

local imgui_notify = imgui.OnFrame(
	function() return true end,
	function(player)
		player.HideCursor = true
		for k = 1, #notify.msg do
			if notify.msg[k] and notify.msg[k].active then
				local i = -1
				for d in gmatch(notify.msg[k].text, '[^\n]+') do
					i = i + 1
				end
				if notify.pos.y - i * 21 > 0 then
					if notify.msg[k].justshowed == nil then
						notify.msg[k].justshowed = clock() - 0.05
					end
					if ceil(notify.msg[k].justshowed + notify.msg[k].time - clock()) <= 0 then
						notify.msg[k].active = false
					end
					imgui.SetNextWindowPos(imgui.ImVec2(notify.pos.x, notify.pos.y - i * 21))
					imgui.SetNextWindowSize(imgui.ImVec2(250, 60 + i * 21))
					if clock() - notify.msg[k].justshowed < 0.3 then
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((clock() - notify.msg[k].justshowed) * 3.34))
					else
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((notify.msg[k].justshowed + notify.msg[k].time - clock()) * 3.34))
					end
					imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
					imgui.Begin(u8('Notify ##'..k), _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)
						local style = imgui.GetStyle()
						local pos = imgui.GetCursorScreenPos()
						local DrawList = imgui.GetWindowDrawList()
						DrawList:PathClear()
	
						local num_segments = 80
						local step = 6.28 / num_segments
						local max = 6.28 * (1 - ((clock() - notify.msg[k].justshowed) / notify.msg[k].time))
						local centre = imgui.ImVec2(pos.x + 15, pos.y + 15 + style.FramePadding.y)
	
						for i = 0, max, step do
							DrawList:PathLineTo(imgui.ImVec2(centre.x + 15 * cos(i), centre.y + 15 * sin(i)))
						end
						DrawList:PathStroke(imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TitleBgActive]), false, 3)
	
						imgui.SetCursorPos(imgui.ImVec2(30 - imgui.CalcTextSize(u8(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed))))).x * 0.5, 27))
						imgui.Text(tostring(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed)))))
	
						imgui.PushFont(font[16])
						imgui.SetCursorPos(imgui.ImVec2(105, 10))
						imgui.TextColoredRGB('{MC}AS Helper')
						imgui.PopFont()

						imgui.SetCursorPosX(60)
						imgui.BeginGroup()
							imgui.TextColoredRGB(notify.msg[k].text)
						imgui.EndGroup()
					imgui.End()
					imgui.PopStyleVar(2)
					notify.pos.y = notify.pos.y - 70 - i * 21
				else
					if k == 1 then
						table.remove(notify.msg, k)
					end
				end
			else
				table.remove(notify.msg, k)
			end
		end
		local notf_sX, notf_sY = convertGameScreenCoordsToWindowScreenCoords(605, 438)
		notify.pos = {x = notf_sX - 200, y = notf_sY - 70}
	end
)

local imgui_fmstylechoose = imgui.OnFrame(
	function() return (windows.imgui_fmstylechoose[0] and not windows.imgui_changelog[0]) end,
	function(player)
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(350, 225), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Стиль меню быстрого доступа##fastmenuchoosestyle', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
			imgui.TextWrapped(u8('В связи с добавлением нового стиля меню быстрого доступа, мы даём Вам выбрать какой стиль Вы предпочтёте использовать. Вы всегда сможете изменить его в /ash.\n\nДля предпросмотра нужно навести на одну из кнопок!'))
			imgui.Spacing()
			imgui.Columns(2, _, false)
			imgui.SetCursorPosX(52.5)
			imgui.Text(u8('Новый стиль'))
			imgui.SetCursorPosX(72.5)
			if imgui.RadioButtonIntPtr(u8('##newstylechoose'), usersettings.fmstyle, 1) then
				configuration.main_settings.fmstyle = usersettings.fmstyle[0]
				inicfg.save(configuration,'AS Helper')
			end
			if imgui.IsItemHovered() then
				imgui.SetNextWindowSize(imgui.ImVec2(200, 110))
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
				imgui.Begin('##newstyleshow', _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
					local p = imgui.GetCursorScreenPos()
					for i = 0,3 do
						imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + 5, p.y + 5 + i * 20), imgui.ImVec2(p.x + 115, p.y + 20 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, nil, 1.9)
						imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 12 + i * 20), imgui.ImVec2(p.x + 105, p.y + 12 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					end
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 120, p.y + 110), imgui.ImVec2(p.x + 120, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 1)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 120, p.y + 25), imgui.ImVec2(p.x + 200, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 1)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 135, p.y + 8), imgui.ImVec2(p.x + 175, p.y + 8), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 178, p.y + 8), imgui.ImVec2(p.x + 183, p.y + 8), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 145, p.y + 18), imgui.ImVec2(p.x + 175, p.y + 18), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 190, p.y + 30), imgui.ImVec2(p.x + 190, p.y + 45), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
					imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 140, p.y + 37), imgui.ImVec2(p.x + 180, p.y + 37), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					for i = 1,3 do
						imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 140, p.y + 37 + i * 20), imgui.ImVec2(p.x + 180, p.y + 37 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					end
				imgui.End()
				imgui.PopStyleVar()
			end
			imgui.NextColumn()
			imgui.SetCursorPosX(220)
			imgui.Text(u8('Старый стиль'))
			imgui.SetCursorPosX(245)
			if imgui.RadioButtonIntPtr(u8('##oldstylechoose'), usersettings.fmstyle, 0) then
				configuration.main_settings.fmstyle = usersettings.fmstyle[0]
				inicfg.save(configuration,'AS Helper')
			end
			if imgui.IsItemHovered() then
				imgui.SetNextWindowSize(imgui.ImVec2(90, 150))
				imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
				imgui.Begin('##oldstyleshow', _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
					local p = imgui.GetCursorScreenPos()
					for i = 0,6 do
						imgui.GetWindowDrawList():AddRect(imgui.ImVec2(p.x + 5, p.y + 7 + i * 20), imgui.ImVec2(p.x + 85, p.y + 22 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, nil, 1.9)
						imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 14 + i * 20), imgui.ImVec2(p.x + 75, p.y + 14 + i * 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 3)
					end
				imgui.End()
				imgui.PopStyleVar()
			end
			imgui.Columns(1)
			if configuration.main_settings.fmstyle ~= nil then
				imgui.SetCursorPosX(125)
				if imgui.Button(u8('Продолжить'), imgui.ImVec2(100, 23)) then
					windows.imgui_fmstylechoose[0] = false
				end
			end
		imgui.End()
	end
)

local imgui_zametka = imgui.OnFrame(
	function() return windows.imgui_zametka[0] end,
	function(player)
		if not zametki[zametka_window[0]] then return end
		player.HideCursor = isKeyDown(0x12)
		imgui.SetNextWindowSize(imgui.ImVec2(100, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8(zametki[zametka_window[0]].name..'##zametka_windoww'..zametka_window[0]), windows.imgui_zametka)
		imgui.Text(u8(zametki[zametka_window[0]].text))
		imgui.End()
	end
)

local interaction_frame = imgui.OnFrame(
	function() return checker_variables.temp_player_data ~= nil and not isPauseMenuActive() end,
	function(player)
		local data = checker_variables.temp_player_data
		
		imgui.SetNextWindowSize(imgui.ImVec2(200,300), imgui.Cond.Appearing)
		imgui.SetNextWindowPos(imgui.ImVec2( getCursorPos() ), imgui.Cond.Appearing, imgui.ImVec2(-0.2, 0.0))
		imgui.Begin(u8("##admininfo"), _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar)
			imgui.TextColoredRGB("{909090}Действия с сотрудником",1)

			imgui.PushFont(font[20])
			imgui.TextColoredRGB(format('%s (%s)', sub(gsub(data.nickname, "_", " "), 1, 15), data.id),1)
			imgui.PopFont()
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8("ЛКМ - cкопировать ник"))
				imgui.EndTooltip()
				if imgui.IsMouseReleased(0) then
					setClipboardText(data.nickname)
				end
			end

			imgui.PushFont(font[11])
			imgui.TextColoredRGB(format('{909090}%s%s', (data.uniform and 'В форме' or 'Без формы'), (data.mute and ' * MUTED' or '')), 1)
			imgui.PopFont()
			
			imgui.Separator()

			imgui.Button(u8'Местоположение', imgui.ImVec2(-1, 20))
			if imgui.IsItemClicked(1) then
				sampSendChat(string.format('/r %s, где вы находитесь?', data.nickname:gsub('_', ' ')))
				data = nil
			elseif imgui.IsItemClicked(0) then
				sampSendChat(string.format('/rb %s, где вы находитесь?', data.nickname:gsub('_', ' ')))
				data = nil
			end
			imgui.Hint('givemeyourpos', 'ЛКМ - /rb | ПКМ - /r')

			if configuration.main_settings.myrankint >= 9 then
				if imgui.Button(u8'Выдать мут', imgui.ImVec2(-1, 20)) then
					local id = data.id
					local mutetime = 30
					local reason = "Сломанная рация"
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:достал|достала} планшет из кармана'},
						{'/me {gender:включил|включила} планшет'},
						{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
						{'/me {gender:выбрал|выбрала} нужного сотрудника'},
						{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
						{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
						{'/fmute %s %s %s', id, mutetime, reason},
					})
				end
				if imgui.Button(u8'+ WARN', imgui.ImVec2(78, 20)) then
					local id = data.id
					local reason = "Н. У."
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:достал|достала} планшет из кармана'},
						{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
						{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
						{'/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор'},
						{'/do Выговор был добавлен в личное дело сотрудника.'},
						{'/fwarn %s %s', id, reason},
					})
				end
				imgui.SameLine()
				if imgui.Button(u8'- WARN', imgui.ImVec2(78, 20)) then
					local id = data.id
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:достал|достала} планшет из кармана'},
						{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
						{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
						{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
						{'/do Выговор был убран из личного дела сотрудника.'},
						{'/unfwarn %s', id},
					})
				end
				if imgui.Button(u8'Уволить', imgui.ImVec2(-1, 20)) then
					local uvalid = data.id
					local reason = "Н. У."
					sendchatarray(configuration.main_settings.playcd, {
						{'/me {gender:достал|достала} планшет из кармана'},
						{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
						{'/do Раздел открыт.'},
						{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
						{'/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} планшет и {gender:положил|положила} его обратно в карман'},
						{'/uninvite %s %s', uvalid, reason},
					})
				end
			else
				imgui.LockedButton(u8'Выдать мут', imgui.ImVec2(-1, 20))
				imgui.LockedButton(u8'+ WARN', imgui.ImVec2(78, 20))
				imgui.SameLine()
				imgui.LockedButton(u8'- WARN', imgui.ImVec2(78, 20))
				imgui.LockedButton(u8'Уволить', imgui.ImVec2(-1, 20))
			end

			imgui.Separator()
			imgui.TextColoredRGB("{909090}Заметка",1)
			imgui.PushItemWidth(170)
			if imgui.InputText('##specialnoteforadmin', checker_variables.note_input, sizeof(checker_variables.note_input)) then
				configuration.Checker_Notes[data.nickname] = #str(checker_variables.note_input) > 0 and u8:decode(str(checker_variables.note_input)) or nil
				inicfg.save(configuration,'AS Helper')
			end
			imgui.PopItemWidth()
			if imgui.Button(u8"Закрыть",imgui.ImVec2(170,25)) then
				checker_variables.temp_player_data = nil
			end
		imgui.End()
	end
)

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		sampUnregisterChatCommand(configuration.BindsCmd[key])
		if configuration.BindsCmd[key] ~= '' and configuration.BindsType[key] == 0 then
			sampRegisterChatCommand(configuration.BindsCmd[key], function()
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end
					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							else
								local delay = bp:match('%{delay_(%d+)%}')
								wait(delay)
							end
						end
						wait(0)
						inprocess = nil
					end)
				else
					ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
				end
			end)
		end
	end
	for k, v in pairs(zametki) do
		sampUnregisterChatCommand(v.cmd)
		sampRegisterChatCommand(v.cmd, function()
			windows.imgui_zametka[0] = true
			zametka_window[0] = k
		end)
	end
end

function sampev.onPlayerStreamIn(playerId)
	if configuration.main_settings.bodyrank then
		for i, member in ipairs(checker_variables.online) do
			if member.nickname == sampGetPlayerNickname(playerId) then
				sampCreate3dTextEx(i, string.format('%s [%s]', configuration.RankNames[member.rank], member.rank), 0XA0FFFFFF, 0, 0, -0.5, 10, false, playerId, -1)
				checker_variables.bodyranks[#checker_variables.bodyranks + 1] = { player = playerId, text = i }
				break
			end
		end
	end
end

function sampev.onPlayerStreamOut(playerId)
	for i, v in ipairs(checker_variables.bodyranks) do
		if v.player == playerId then
			sampDestroy3dText(v.text)
		end
	end
end

function sampev.onCreatePickup(id, model, pickupType, position)
	if model == 19132 and getCharActiveInterior(playerPed) == 240 then
		return {id, 1272, pickupType, position}
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 6 and givelic then
		local d = {
			['авто'] = 0,
			['мото'] = 1,
			['рыболовство'] = 3,
			['плавание'] = 4,
			['оружие'] = 5,
			['охоту'] = 6,
			['раскопки'] = 7,
			['такси'] = 8,
		}
		sampSendDialogResponse(6, 1, d[lictype], nil)
		lua_thread.create(function()
			wait(1000)
			if givelic then
				sampSendChat(format('/givelicense %s',sellto))
			end
		end)
		return false

	elseif dialogId == 235 and getmyrank then
		if find(text, 'Инструкторы') then
			for DialogLine in gmatch(text, '[^\r\n]+') do
				local nameRankStats, getStatsRank = DialogLine:match('Должность: {B83434}(.+)%p(%d+)%p')
				if tonumber(getStatsRank) then
					local rangint = tonumber(getStatsRank)
					local rang = nameRankStats
					if rangint ~= configuration.main_settings.myrankint then
						ASHelperMessage(format('Ваш ранг был обновлён на %s (%s)',rang,rangint))
					end
					if configuration.RankNames[rangint] ~= rang then
						ASHelperMessage(format('Название {MC}%s{WC} ранга изменено с {MC}%s{WC} на {MC}%s{WC}', rangint, configuration.RankNames[rangint], rang))
					end
					configuration.RankNames[rangint] = rang
					configuration.main_settings.myrankint = rangint
					inicfg.save(configuration,'AS Helper')
				end
			end
		else
			print('{FF0000}Игрок не работает в автошколе. Скрипт был выгружен.')
			ASHelperMessage('Вы не работаете в автошколе, скрипт выгружен! Если это ошибка, то обратитесь к {MC}vk.com/justmini{WC}.')
			NoErrors = true
			thisScript():unload()
		end
		sampSendDialogResponse(235, 0, 0, nil)
		getmyrank = false
		return false

	elseif dialogId == 1234 then
		if find(text, 'Срок действия') then
			if configuration.sobes_settings.medcard and sobes_results and not sobes_results.medcard then
				if not find(text, 'Имя: '..sampGetPlayerNickname(fastmenuID)) then
					return {dialogId, style, title, button1, button2, text}
				end
				if not find(text, 'Полностью здоровый') then
					sobes_results.medcard = ('не полностью здоровый')
					return {dialogId, style, title, button1, button2, text}
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local statusint = DialogLine:match('{CEAD2A}Наркозависимость: (%d+)')
					if tonumber(statusint) and tonumber(statusint) > 5 then
						sobes_results.medcard = ('наркозависимость')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				sobes_results.medcard = ('в порядке')
			end
			if skiporcancel then
				if find(text, 'Имя: '..sampGetPlayerNickname(tempid)) then
					if inprocess then
						inprocess:terminate()
						inprocess = nil
						ASHelperMessage('Прошлая отыгровка была прервана, из-за показа мед. карты.')
					end
					if find(text, 'Полностью здоровый') then
						sendchatarray(configuration.main_settings.playcd, {
							{'/me взяв мед.карту в руки начал её проверять'},
							{'/do Мед.карта в норме.'},
							{'/todo Всё в порядке* отдавая мед.карту обратно'},
							{'/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на %s', skiporcancel},
							{'/do Спустя некоторое время бланк на получение лицензии был заполнен.'},
							{'/me распечатав лицензию на %s {gender:передал|передала} её человеку напротив', skiporcancel},
						}, function() lictype = skiporcancel sellto = tempid end, function() wait(1000) givelic = true skiporcancel = false sampSendChat(format('/givelicense %s', tempid)) end)
					else
						sendchatarray(configuration.main_settings.playcd, {
							{'/me взяв мед.карту в руки начал её проверять'},
							{'/do Мед.карта не в норме.'},
							{'/todo К сожалению, в мед.карте написано, что у Вас есть отклонения.* отдавая мед.карту обратно'},
							{'Обновите её и приходите снова!'},
						}, function() skiporcancel = false ASHelperMessage('Человек не полностью здоровый, требуется поменять мед.карту!') end)
					end
					sampSendDialogResponse(1234, 1, 1, nil)
					return false
				end
			end
		elseif find(text, 'Серия') then
			if configuration.sobes_settings.pass and sobes_results and not sobes_results.pass then
				if not find(text, 'Имя: {FFD700}'..sampGetPlayerNickname(fastmenuID)) then
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, '{FFFFFF}Организация:') then
					sobes_results.pass = ('игрок в организации')
					return {dialogId, style, title, button1, button2, text}
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local passstatusint = DialogLine:match('{FFFFFF}Лет в штате: {FFD700}(%d+)')
					if tonumber(passstatusint) and tonumber(passstatusint) < 3 then
						sobes_results.pass = ('меньше 3 лет в штате')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				for DialogLine in gmatch(text, '[^\r\n]+') do
					local zakonstatusint = DialogLine:match('{FFFFFF}Законопослушность: {FFD700}(%d+)')
					if tonumber(zakonstatusint) and tonumber(zakonstatusint) < 35 then
						sobes_results.pass = ('не законопослушный')
						return {dialogId, style, title, button1, button2, text}
					end
				end
				if find(text, 'Лечился в Психиатрической больнице') then
					sobes_results.pass = ('был в деморгане')
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, 'Состоит в ЧС{FF6200} Инструкторы') then
					sobes_results.pass = ('в чс автошколы')
					return {dialogId, style, title, button1, button2, text}
				end
				if find(text, 'Warns') then
					sobes_results.pass = ('есть варны')
					return {dialogId, style, title, button1, button2, text}
				end
				sobes_results.pass = ('в порядке')
			end
		elseif find(title, 'Лицензии') then
			if configuration.sobes_settings.licenses and sobes_results and not sobes_results.licenses then
				for DialogLine in gmatch(text, '[^\r\n]+') do
					if find(DialogLine, 'Лицензия на авто') then
						if find(DialogLine, 'Нет') then
							sobes_results.licenses = ('нет на авто')
							return {dialogId, style, title, button1, button2, text}
						end
					end
					if find(DialogLine, 'Лицензия на мото') then
						if find(DialogLine, 'Нет') then
							sobes_results.licenses = ('нет на мото')
							return {dialogId, style, title, button1, button2, text}
						end
					end
				end
				sobes_results.licenses = ('в порядке')
				return {dialogId, style, title, button1, button2, text}
			end
		end
	elseif dialogId == 0 then
		if find(title, 'Трудовая книжка '..sampGetPlayerNickname(fastmenuID)) then
			sobes_results.wbook = ('присутствует')
		end
	end

	if dialogId == 2015 then 
		for line in gmatch(text, '[^\r\n]+') do
			local name, rank = line:match('^{%x+}[A-z0-9_]+%([0-9]+%)\t(.+)%(([0-9]+)%)\t%d+\t%d+')
			if name and rank then
				name, rank = tostring(name), tonumber(rank)
				if configuration.RankNames[rank] ~= nil and configuration.RankNames[rank] ~= name then
					ASHelperMessage(format('Название {MC}%s{WC} ранга изменено с {MC}%s{WC} на {MC}%s{WC}', rank, configuration.RankNames[rank], name))
					configuration.RankNames[rank] = name
					inicfg.save(configuration,'AS Helper')
				end
			end
		end
	end

	if dialogId == 2015 and checker_variables.await.members then 
		local count = 0
		checker_variables.await.next_page.bool = false
		checker_variables.online.online = title:match('{FFFFFF}.+%(В сети: (%d+)%)')
		for line in text:gmatch('[^\r\n]+') do
    		count = count + 1
    		if not line:find('Ник игрока') and not line:find('страница') then
	    		local color, nick, id, rank_name, rank_id, warns, afk = string.match(line, '{(%x+)}([A-z_0-9]+)%((%d+)%)\t(.+)%((%d+)%)\t(%d+)\t(%d+)')
	    		local mute = string.find(line, '| MUTED')
	    		local near = select(1, sampGetCharHandleBySampPlayerId(tonumber(id))) or tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed))
	    		local uniform = (color == 'FFFFFF')

	    		checker_variables.online[#checker_variables.online + 1] = { 
					nickname = tostring(nick),
					id = id,
					rank = tonumber(rank_id),
					afk = tonumber(afk),
					warns = tonumber(warns),
					mute = mute,
					near = near,
					uniform = uniform
				}
			end

    		if line:match('Следующая страница') then
    			checker_variables.await.next_page.bool = true
    			checker_variables.await.next_page.i = count - 2
    		end
    	end

    	if checker_variables.await.next_page.bool then
    		sampSendDialogResponse(dialogId, 1, checker_variables.await.next_page.i, _)
    		checker_variables.await.next_page.bool = false
    		checker_variables.await.next_page.i = 0
    	else
			while #checker_variables.online > tonumber(checker_variables.online.online) do 
    			table.remove(checker_variables.online, 1) 
    		end
    		checker_variables.online.afk = getAfkCount()
    		sampSendDialogResponse(dialogId, 0, _, _)
    		checker_variables.await.members = false
    	end
		return false
	elseif checker_variables.await.members and dialogId ~= 2015 then
		checker_variables.dontShowMeMembers = true
		checker_variables.await.members = false
		checker_variables.await.next_page.bool = false
    	checker_variables.await.next_page.i = 0
    	while #checker_variables.online > tonumber(checker_variables.online.online) do 
			table.remove(checker_variables.online, 1) 
		end
	elseif checker_variables.dontShowMeMembers and dialogId == 2015 then
		checker_variables.dontShowMeMembers = false
		lua_thread.create(function()
			wait(0)
			sampSendDialogResponse(dialogId, 0, nil, nil)
		end)
		return false
	end
end

function sampev.onServerMessage(color, message)
	if configuration.main_settings.replacechat then
		if find(message, 'Используйте: /jobprogress %[ ID игрока %]') then
			ASHelperMessage('Вы просмотрели свою рабочую успеваемость.')
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в гражданскую одежду') then
			addNotify('Вы закончили рабочий день,\nприятного отдыха!', 5)
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в рабочую одежду') then
			addNotify('Вы начали рабочий день,\nудачной работы!', 5)
			return false
		end
		if find(message, '%[Информация%] {FFFFFF}Вы покинули пост!') then
			addNotify('Вы покинули пост.', 5)
			return false
		end
	end
	if (find(message, '%[Информация%] {FFFFFF}Вы предложили (.+) купить лицензию (.+)') or find(message, 'Вы далеко от игрока')) and givelic then
		givelic = false
	end
	if message == ('Используйте: /jobprogress(Без параметра)') and color == -1104335361 then
		sampSendChat('/jobprogress')
		return false
	end
	if find(message, '%[R%]') and color == 766526463 then
		if configuration.main_settings.chatrank then
			local nick = message:match('^%[R%].*%s([A-z0-9_]+)%[%d+%]:')
			if nick ~= nil then
				for i, member in ipairs(checker_variables.online) do
					if member.nickname == tostring(nick) then
						message = message:gsub('^%[R%]', '['.. member.rank ..']')
						break
					end
				end
			end
		end

		local color = imgui.ColorConvertU32ToFloat4(configuration.main_settings.RChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message}
	end
	if find(message, '%[D%]') and color == 865730559 or color == 865665023 then
		if find(message, u8:decode(departsettings.myorgname[0])) then
			local tmsg = gsub(message, '%[D%] ','')
			dephistory[#dephistory + 1] = tmsg
		end
		local color = imgui.ColorConvertU32ToFloat4(configuration.main_settings.DChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message }
	end
	if find(message, '%[Информация%] {FFFFFF}Вы успешно продали лицензию') then
		local typeddd, toddd = message:match('%[Информация%] {FFFFFF}Вы успешно продали лицензию (.+) игроку (.+).')
		if typeddd == 'на авто' then
			configuration.my_stats.avto = configuration.my_stats.avto + 1
		elseif typeddd == 'на мото' then
			configuration.my_stats.moto = configuration.my_stats.moto + 1
		elseif typeddd == 'на рыбалку' then
			configuration.my_stats.riba = configuration.my_stats.riba + 1
		elseif typeddd == 'на плавание' then
			configuration.my_stats.lodka = configuration.my_stats.lodka + 1
		elseif typeddd == 'на оружие' then
			configuration.my_stats.guns = configuration.my_stats.guns + 1
		elseif typeddd == 'на охоту' then
			configuration.my_stats.hunt = configuration.my_stats.hunt + 1
		elseif typeddd == 'на раскопки' then
			configuration.my_stats.klad = configuration.my_stats.klad + 1
		elseif typeddd == 'таксиста' then
			configuration.my_stats.taxi = configuration.my_stats.taxi + 1
		else
			if configuration.main_settings.replacechat then
				ASHelperMessage(format('Вы успешно продали лицензию %s игроку %s.',typeddd,gsub(toddd, '_',' ')))
				return false
			end
		end
		if inicfg.save(configuration,'AS Helper') then
			if configuration.main_settings.replacechat then
				ASHelperMessage(format('Вы успешно продали лицензию %s игроку %s. Она была засчитана в вашу статистику.',typeddd,gsub(toddd, '_',' ')))
				return false
			end
		end
	end
	if find(message, 'Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)') and waitingaccept then
		local invited,inviting = message:match('Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)%[')
		if inviting == sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) then
			if invited == sampGetPlayerNickname(waitingaccept) then
				lua_thread.create(function()
					wait(100)
					sampSendChat(format('/giverank %s 2',waitingaccept))
					waitingaccept = false
				end)
			end
		end
	end
end

function sampev.onSendChat(message)
	if find(message, '{my_id}') then
		sampSendChat(gsub(message, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(message, '{my_name}') then
		sampSendChat(gsub(message, '{my_name}', (configuration.main_settings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
		return false
	end
	if find(message, '{my_rank}') then
		sampSendChat(gsub(message, '{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
		return false
	end
	if find(message, '{my_score}') then
		sampSendChat(gsub(message, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(message, '{H}') then
		sampSendChat(gsub(message, '{H}', os.date('%H', os.time())))
		return false
	end
	if find(message, '{HM}') then
		sampSendChat(gsub(message, '{HM}', os.date('%H:%M', os.time())))
		return false
	end
	if find(message, '{HMS}') then
		sampSendChat(gsub(message, '{HMS}', os.date('%H:%M:%S', os.time())))
		return false
	end
	if find(message, '{close_id}') then
		if select(1,getClosestPlayerId()) then
			sampSendChat(gsub(message, '{close_id}', select(2,getClosestPlayerId())))
			return false
		end
		ASHelperMessage('В зоне стрима не найдено ни одного игрока.')
		return false
	end
	if find(message, '@{%d+}') then
		local id = message:match('@{(%d+)}')
		if id and IsPlayerConnected(id) then
			sampSendChat(gsub(message, '@{%d+}', sampGetPlayerNickname(id)))
			return false
		end
		ASHelperMessage('Такого игрока нет на сервере.')
		return false
	end
	if find(message, '{gender:(%A+)|(%A+)}') then
		local male, female = message:match('{gender:(%A+)|(%A+)}')
		if configuration.main_settings.gender == 0 then
			local gendermsg = gsub(message, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(message, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end

	if #configuration.main_settings.myaccent > 1 then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == 'q' or message == ';)' then
			return{message}
		end
		if find(string.rlower(u8:decode(configuration.main_settings.myaccent)), 'акцент') then
			return{format('[%s]: %s', u8:decode(configuration.main_settings.myaccent),message)}
		else
			return{format('[%s акцент]: %s', u8:decode(configuration.main_settings.myaccent),message)}
		end
	end
end

function sampev.onSendCommand(cmd)
	if find(cmd, '{my_id}') then
		sampSendChat(gsub(cmd, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(cmd, '{my_name}') then
		sampSendChat(gsub(cmd, '{my_name}', (configuration.main_settings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
		return false
	end
	if find(cmd, '{my_rank}') then
		sampSendChat(gsub(cmd, '{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
		return false
	end
	if find(cmd, '{my_score}') then
		sampSendChat(gsub(cmd, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(cmd, '{H}') then
		sampSendChat(gsub(cmd, '{H}', os.date('%H', os.time())))
		return false
	end
	if find(cmd, '{HM}') then
		sampSendChat(gsub(cmd, '{HM}', os.date('%H:%M', os.time())))
		return false
	end
	if find(cmd, '{HMS}') then
		sampSendChat(gsub(cmd, '{HMS}', os.date('%H:%M:%S', os.time())))
		return false
	end
	if find(cmd, '{close_id}') then
		if select(1,getClosestPlayerId()) then
			sampSendChat(gsub(cmd, '{close_id}', select(2,getClosestPlayerId())))
			return false
		end
		ASHelperMessage('В зоне стрима не найдено ни одного игрока.')
		return false
	end
	if find(cmd, '@{%d+}') then
		local id = cmd:match('@{(%d+)}')
		if id and IsPlayerConnected(id) then
			sampSendChat(gsub(cmd, '@{%d+}', sampGetPlayerNickname(id)))
			return false
		end
		ASHelperMessage('Такого игрока нет на сервере.')
		return false
	end
	if find(cmd, '{gender:(%A+)|(%A+)}') then
		local male, female = cmd:match('{gender:(%A+)|(%A+)}')
		if configuration.main_settings.gender == 0 then
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end
	if configuration.main_settings.fmtype == 1 then
		com = #cmd > #configuration.main_settings.usefastmenucmd+1 and sub(cmd, 2, #configuration.main_settings.usefastmenucmd+2) or sub(cmd, 2, #configuration.main_settings.usefastmenucmd+1)..' '
		if com == configuration.main_settings.usefastmenucmd..' ' then
			if windows.imgui_fm[0] == false then
				if find(cmd, '/'..configuration.main_settings.usefastmenucmd..' %d+') then
					local param = cmd:match('.+ (%d+)')
					if sampIsPlayerConnected(param) then
						if doesCharExist(select(2,sampGetCharHandleBySampPlayerId(param))) then
							fastmenuID = param
							ASHelperMessage(format('Вы использовали меню быстрого доступа на: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
							ASHelperMessage('Зажмите {MC}ALT{WC} для того, чтобы скрыть курсор. {MC}ESC{WC} для того, чтобы закрыть меню.')
							windows.imgui_fm[0] = true
						else
							ASHelperMessage('Игрок не находится рядом с вами')
						end
					else
						ASHelperMessage('Игрок не в сети')
					end
				else
					ASHelperMessage('/'..configuration.main_settings.usefastmenucmd..' [id]')
				end
			end
			return false
		end
	end
end

function IsPlayerConnected(id)
	return (sampIsPlayerConnected(tonumber(id)) or select(2, sampGetPlayerIdByCharHandle(playerPed)) == tonumber(id))
end

function checkServer(ip)
	local servers = {
		['185.169.134.3'] = 'Phoenix',
		['185.169.134.4'] = 'Tucson',
		['185.169.134.43'] = 'Scottdale',
		['185.169.134.44'] = 'Chandler',
		['185.169.134.45'] = 'Brainburg',
		['185.169.134.5'] = 'Saint Rose',
		['185.169.134.59'] = 'Mesa',
		['185.169.134.61'] = 'Red-Rock',
		['185.169.134.107'] = 'Yuma',
		['185.169.134.109'] = 'Surprise',
		['185.169.134.166'] = 'Prescott',
		['185.169.134.171'] = 'Glendale',
		['185.169.134.172'] = 'Kingman',
		['185.169.134.173'] = 'Winslow',
		['185.169.134.174'] = 'Payson',
		['80.66.82.191'] = 'Gilbert',
		['80.66.82.190'] = 'Show Low',
		['80.66.82.188'] = 'Casa-Grande',
		['80.66.82.168'] = 'Page',
	}
	return servers[ip] or false
end

function ASHelperMessage(text)
	local col = imgui.ColorConvertU32ToFloat4(configuration.main_settings.ASChatColor)
	local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
	text = gsub(text, '{WC}', '{EBEBEB}')
	text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))
	sampAddChatMessage(format('[ASHelper]{EBEBEB} %s', text),join_argb(a, r, g, b)) -- ff6633 default
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B and not isPauseMenuActive() then
		if windows.imgui_settings[0] or windows.imgui_fm[0] or windows.imgui_binder[0] or windows.imgui_lect[0] or windows.imgui_depart[0] or windows.imgui_changelog[0] then
			consumeWindowMessage(true, false)
			if(msg == 0x101)then
				windows.imgui_settings[0] = false
				windows.imgui_fm[0] = false
				windows.imgui_binder[0] = false
				windows.imgui_lect[0] = false
				windows.imgui_depart[0] = false
				windows.imgui_changelog[0] = false
			end
		end
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if not sampIsDialogActive() then
			showCursor(false, false)
		end
		if marker ~= nil then
			removeBlip(marker)
		end

		if NoErrors then
			return false
		end

		local file = getWorkingDirectory()..'\\moonloader.log'

		local moonlog = ''
		local tags = {['%(info%)'] = 'A9EFF5', ['%(debug%)'] = 'AFA9F5', ['%(error%)'] = 'FF7070', ['%(warn%)'] = 'F5C28E', ['%(system%)'] = 'FA9746', ['%(fatal%)'] = '040404', ['%(exception%)'] = 'F5A9A9', ['%(script%)'] = '7DD156',}
		local i = 0
		local lasti = 0

		local function ftable(line)
			for key, value in pairs(tags) do
				if find(line, key) then return true end
			end
			return false
		end

		for line in io.lines(file) do
			local sameline = not ftable(line) and i-1 == lasti
			if find(line, 'Loaded successfully.') and find(line, thisScript().name) then moonlog = '' sameline = false end
			if find(line, thisScript().name) or sameline then
				for k,v in pairs(tags) do
					if find(line, k) then
						line = sub(line, 19, #line)
						line = gsub(line, '	', ' ')
						line = gsub(line, k, '{'..v..'}'..k..'{FFFFFF}')
					end
				end
				line = gsub(line, thisScript().name..':', thisScript().name..':{C0C0C0}')
				line = line..'{C0C0C0}'
				moonlog = moonlog..line..'\n'
				lasti = i
			end
			i = i + 1
		end

		sampShowDialog(536472, '{ff6633}[AS Helper]{ffffff} Скрипт был выгружен сам по себе.', [[
{f51111}Если Вы самостоятельно перезагрузили скрипт, то можете закрыть это диалоговое окно.
В ином случае, для начала попытайтесь восстановить работу скрипта сочетанием клавиш CTRL + R.
Если же это не помогло, то следуйте дальнейшим инструкциям.{ff6633}
1. Возможно у Вас установлены конфликтующие LUA файлы и хелперы, попытайтесь удалить их.
2. Возможно Вы не доустановили некоторые нужные библиотеки, а именно:
 - SAMPFUNCS 5.5.1
 - CLEO 4.1+
 - MoonLoader 0.26
3. Если данной ошибки не было ранее, попытайтесь сделать следующие действия:
- В папке moonloader > config > Удаляем файл AS Helper.ini
- В папке moonloader > Удаляем папку AS Helper
4. Если ничего из вышеперечисленного не исправило ошибку, то следует установить скрипт на другую сборку.
5. Если даже это не помогло Вам, то отправьте автору {2594CC}(vk.com/justmini){FF6633} скриншот ошибки.{FFFFFF}
———————————————————————————————————————————————————————
{C0C0C0}]]..moonlog, 'ОК', nil, 0)
	end
end

function getClosestPlayerId()
	local temp = {}
	local tPeds = getAllChars()
	local me = {getCharCoordinates(playerPed)}
	for i = 1, #tPeds do 
		local result, id = sampGetPlayerIdByCharHandle(tPeds[i])
		if tPeds[i] ~= playerPed and result then
			local pl = {getCharCoordinates(tPeds[i])}
			local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
			temp[#temp + 1] = { dist, id }
		end
	end
	if #temp > 0 then
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		return true, temp[1][2]
	end
	return false
end

function sendchatarray(delay, text, start_function, end_function)
	start_function = start_function or function() end
	end_function = end_function or function() end
	if inprocess ~= nil then
		ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
		return false
	end
	inprocess = lua_thread.create(function()
		start_function()
		for i = 1, #text do
			sampSendChat(format(text[i][1], unpack(text[i], 2)))
			if i ~= #text then
				if sub(text[i][1], 1, 3) == '/do' or sub(text[i][1], 1, 5) == '/todo' then
					if delay < 5100 then
						wait(5100)
					else
						wait(delay)
					end
				else
					wait(delay)
				end
			end
		end
		end_function()
		wait(0)
		inprocess = nil
	end)
	return true
end

function createJsons()
	createDirectory(getWorkingDirectory()..'\\AS Helper')
	createDirectory(getWorkingDirectory()..'\\AS Helper\\Rules')
	if not doesFileExist(getWorkingDirectory()..'\\AS Helper\\Lections.json') then
		lections = default_lect
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
		file:write(encodeJson(lections))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'r')
		lections = decodeJson(file:read('*a'))
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\AS Helper\\Questions.json') then
		questions = {
			active = { redact = false },
			questions = {}
		}
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
		file:write(encodeJson(questions))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'r')
		questions = decodeJson(file:read('*a'))
		questions.active.redact = false
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\AS Helper\\Zametki.json') then
		zametki = {}
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Zametki.json', 'w')
		file:write(encodeJson(zametki))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Zametki.json', 'r')
		zametki = decodeJson(file:read('*a'))
		file:close()
	end
	return true
end

function checkRules()
	ruless = {}
	for line in lfs.dir(getWorkingDirectory()..'\\AS Helper\\Rules') do
		if line == nil then
		elseif line:match('.+%.txt') then
			local temp = io.open(getWorkingDirectory()..'\\AS Helper\\Rules\\'..line:match('.+%.txt'), 'r+')
			local temptable = {}
			for linee in temp:lines() do
				if linee == '' then
					temptable[#temptable + 1] = ' '
				else
					temptable[#temptable + 1] = linee
				end
			end
			ruless[#ruless + 1] = {
				name = line:match('(.+)%.txt'),
				text = temptable
			}
			temp:close()
		end
	end

	if not checkServer(select(1, sampGetCurrentServerAddress())) then
		ASHelperMessage('Ошибка в импротировании правил сервера! Неизвестный сервер. Обратитесь к {MC}vk.com/justmini{WC}.')
		return
	end

	local json_url = 'https://github.com/Just-Mini/biblioteki/raw/main/Rules/rules.json'
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-rules.json'

	if doesFileExist(json) then
		os.remove(json)
	end

	downloadUrlToFile(json_url, json, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				local info = decodeJson(f:read('*a'))
				f:close(); os.remove(json)
				if f then
					if info[checkServer(select(1, sampGetCurrentServerAddress()))] then
						ruless['server'] = checkServer(select(1, sampGetCurrentServerAddress()))
						for k,v in pairs(info[checkServer(select(1, sampGetCurrentServerAddress()))]) do
							if type(v) == 'string' then
								local temptable = {}
								for line in gmatch(v, '[^\n]+') do
									if find(line, '%{space%}') then
										temptable[#temptable+1] = ' '
									else
										if #line > 151 and find(line:sub(151), ' ') then
											temptable[#temptable+1] = line:sub(1,150 + find(line:sub(151), ' '))..'\n'..line:sub(151 + find(line:sub(151), ' '))
										else
											temptable[#temptable+1] = line
										end
									end
								end
								ruless[#ruless+1] = {name=k,text=temptable}
							end
						end
					else
						ASHelperMessage('Ошибка в импротировании правил сервера! Неизвестный сервер. Обратитесь к {MC}vk.com/justmini{WC}.')
					end
				end
			end
		end
	end)

	serverquestions = {}
	
	local json_url = 'https://github.com/Just-Mini/biblioteki/raw/main/Rules/questions.json'
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-questions.json'

	if doesFileExist(json) then
		os.remove(json)
	end

	downloadUrlToFile(json_url, json, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				local info = decodeJson(f:read('*a'))
				f:close(); os.remove(json)
				if f then
					if info[checkServer(select(1, sampGetCurrentServerAddress()))] then
						serverquestions['server'] = checkServer(select(1, sampGetCurrentServerAddress()))
						for k,v in pairs(info[checkServer(select(1, sampGetCurrentServerAddress()))]) do
							serverquestions[k] = {}
							for i,t in pairs(v) do
								serverquestions[k][i] = t
							end
						end
					else
						ASHelperMessage('Ошибка в импротировании устава сервера! Неизвестный сервер. Обратитесь к {MC}vk.com/justmini{WC}.')
					end
				end
			end
		end
	end)
end

function checkUpdates(json_url, show_notify)
	show_notify = show_notify or false
	local function getTimeAfter(unix)
		local function plural(n, forms) 
			n = abs(n) % 100
			if n % 10 == 1 and n ~= 11 then
				return forms[1]
			elseif 2 <= n % 10 and n % 10 <= 4 and (n < 10 or n >= 20) then
				return forms[2]
			end
			return forms[3]
		end
		
		local interval = os.time() - unix
		if interval < 86400 then
			return 'сегодня'
		elseif interval < 604800 then
			local days = floor(interval / 86400)
			local text = plural(days, {'день', 'дня', 'дней'})
			return ('%s %s назад'):format(days, text)
		elseif interval < 2592000 then
			local weeks = floor(interval / 604800)
			local text = plural(weeks, {'неделя', 'недели', 'недель'})
			return ('%s %s назад'):format(weeks, text)
		elseif interval < 31536000 then
			local months = floor(interval / 2592000)
			local text = plural(months, {'месяц', 'месяца', 'месяцев'})
			return ('%s %s назад'):format(months, text)
		else
			local years = floor(interval / 31536000)
			local text = plural(years, {'год', 'года', 'лет'})
			return ('%s %s назад'):format(years, text)
		end
	end
	
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'

	if doesFileExist(json) then
		os.remove(json)
	end

	downloadUrlToFile(json_url, json, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					local updateversion = (configuration.main_settings.getbetaupd and info.beta_upd) and info.beta_version or info.version
					f:close()
					os.remove(json)
					if updateversion ~= thisScript().version then
						addNotify('Обнаружено обновление на\nверсию {MC}'..updateversion..'{WC}. Подробности:\n{MC}/ashupd', 5)
					else
						if show_notify then
							addNotify('Обновлений не обнаружено!', 5)
						end
					end
					if configuration.main_settings.getbetaupd and info.beta_upd then
						updateinfo = {
							file = info.beta_file,
							version = updateversion,
							change_log = info.beta_changelog,
						}
					else
						updateinfo = {
							file = info.file,
							version = updateversion,
							change_log = info.change_log,
						}
					end

					updateinfo.updatelastcheck = getTimeAfter(os.time({day = os.date('%d'), month = os.date('%m'), year = os.date('%Y')}))..' в '..os.date('%X')
					inicfg.save(configuration, 'AS Helper.ini')
				end
			end
		end
	end
	)
end

function ImSaturate(f)
	return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
end

function renderFontDrawClickableText(active, font, text, posX, posY, color, color_hovered)
	local cursorX, cursorY = getCursorPos()
	local lenght = renderGetFontDrawTextLength(font, text)
	local height = renderGetFontDrawHeight(font)
	local hovered = false
	local result = false
	if active and cursorX > posX and cursorY > posY and cursorX < posX + lenght and cursorY < posY + height then
		hovered = true
		if isKeyJustPressed(0x01) then
			result = true 
		end
	end	
	local anim = floor(sin(clock() * 10) * 3 + 5)
	renderFontDrawText(font, text, posX, posY - (hovered and anim or 0), hovered and color_hovered or color)
	return result
end
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(1000) end

	createJsons()
	checkRules()

	getmyrank = true
	sampSendChat('/stats')
	print('{00FF00}Успешная загрузка')
	addNotify(format('Успешная загрузка скрипта,\nверсия {MC}%s{WC}.\nНастроить скрипт: {MC}/ash', thisScript().version), 10)

	if configuration.main_settings.changelog then
		windows.imgui_changelog[0] = true
		configuration.main_settings.changelog = false
		inicfg.save(configuration, 'AS Helper.ini')
	end
	
	sampRegisterChatCommand('ash', function()
		windows.imgui_settings[0] = not windows.imgui_settings[0]
		alpha[0] = clock()
	end)
	sampRegisterChatCommand('ashbind', function()
		choosedslot = nil
		windows.imgui_binder[0] = not windows.imgui_binder[0]
	end)
	sampRegisterChatCommand('ashstats', function()
		ASHelperMessage('Это окно теперь включается в {MC}/ash{WC} - {MC}Настройки{WC}.')
	end)
	sampRegisterChatCommand('ashlect', function()
		if configuration.main_settings.myrankint < 5 then
			return addNotify('Данная функция доступна с 5-го\nранга.', 5)
		end
		windows.imgui_lect[0] = not windows.imgui_lect[0]
	end)
	sampRegisterChatCommand('ashdep', function()
		if configuration.main_settings.myrankint < 5 then
			return addNotify('Данная функция доступна с 5-го\nранга.', 5)
		end
		windows.imgui_depart[0] = not windows.imgui_depart[0]
	end)
	sampRegisterChatCommand('ashupd', function()
		windows.imgui_settings[0] = true
		mainwindow[0] = 3
		infowindow[0] = 1
		alpha[0] = clock()
	end)

	sampRegisterChatCommand('uninvite', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/uninvite %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local uvalid = param:match('(%d+)')
		local reason = select(2, param:match('(%d+) (.+),')) or select(2, param:match('(%d+) (.+)'))
		local withbl = select(2, param:match('(.+), (.+)'))
		if uvalid == nil or reason == nil then
			return ASHelperMessage('/uninvite [id] [причина], [причина чс] (не обязательно)')
		end
		if tonumber(uvalid) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете увольнять из организации самого себя.')
		end
		if withbl then
			return sendchatarray(configuration.main_settings.playcd, {
				{'/me {gender:достал|достала} планшет из кармана'},
				{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
				{'/do Раздел открыт.'},
				{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
				{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
				{'/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения'},
				{'/do Изменения были сохранены.'},
				{'/uninvite %s %s', uvalid, reason},
				{'/blacklist %s %s', uvalid, withbl},
			})
		else
			return sendchatarray(configuration.main_settings.playcd, {
				{'/me {gender:достал|достала} планшет из кармана'},
				{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
				{'/do Раздел открыт.'},
				{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
				{'/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} планшет и {gender:положил|положила} его обратно в карман'},
				{'/uninvite %s %s', uvalid, reason},
			})
		end
	end)

	sampRegisterChatCommand('invite', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/invite %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/invite [id]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете приглашать в организацию самого себя.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/do Ключи от шкафчика в кармане.'},
			{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
			{'/me {gender:передал|передала} ключ человеку напротив'},
			{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
			{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
			{'/invite %s', id},
		})
	end)

	sampRegisterChatCommand('giverank', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/giverank %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,rank = param:match('(%d+) (%d)')
		if id == nil or rank == nil then
			return ASHelperMessage('/giverank [id] [ранг]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете менять ранг самому себе.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:включил|включила} планшет'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
			{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
			{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения'},
			{'/do Информация о сотруднике была изменена.'},
			{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
			{'/giverank %s %s', id, rank},
		})
	end)

	sampRegisterChatCommand('blacklist', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/blacklist %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/blacklist [id] [причина]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете внести в ЧС самого себя.')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
			{'/me {gender:ввёл|ввела} имя нарушителя'},
			{'/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\''},
			{'/me {gender:подтведрдил|подтвердила} изменения'},
			{'/do Изменения были сохранены.'},
			{'/blacklist %s %s', id, reason},
		})
	end)

	sampRegisterChatCommand('unblacklist', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/unblacklist %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/unblacklist [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
			{'/me {gender:ввёл|ввела} имя гражданина в поиск'},
			{'/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\''},
			{'/me {gender:подтведрдил|подтвердила} изменения'},
			{'/do Изменения были сохранены.'},
			{'/unblacklist %s', id},
		})
	end)

	sampRegisterChatCommand('fwarn', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/fwarn %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/fwarn [id] [причина]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
			{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
			{'/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор'},
			{'/do Выговор был добавлен в личное дело сотрудника.'},
			{'/fwarn %s %s', id, reason},
		})
	end)

	sampRegisterChatCommand('unfwarn', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/unfwarn %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/unfwarn [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
			{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
			{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
			{'/do Выговор был убран из личного дела сотрудника.'},
			{'/unfwarn %s', id},
		})
	end)
	
	sampRegisterChatCommand('fmute', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/fmute %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,mutetime,reason = param:match('(%d+) (%d+) (.+)')
		if id == nil or reason == nil or mutetime == nil then
			return ASHelperMessage('/fmute [id] [время] [причина]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:включил|включила} планшет'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
			{'/me {gender:выбрал|выбрала} нужного сотрудника'},
			{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
			{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
			{'/fmute %s %s %s', id, mutetime, reason},
		})
	end)

	sampRegisterChatCommand('funmute', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/funmute %s',param))
		end
		if configuration.main_settings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/funmute [id]')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:включил|включила} планшет'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', configuration.main_settings.replaceash and 'ГЦЛ' or 'Автошколы'},
			{'/me {gender:выбрал|выбрала} нужного сотрудника'},
			{'/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\''},
			{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
			{'/funmute %s', id},
		})
	end)

	sampRegisterChatCommand('expel', function(param)
		if not configuration.main_settings.dorponcmd then
			return sampSendChat(format('/expel %s',param))
		end
		if configuration.main_settings.myrankint < 2 then
			return ASHelperMessage('Данная команда доступна с 2-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/expel [id] [причина]')
		end
		if sampIsPlayerPaused(id) then
			return ASHelperMessage('Игрок находится в АФК!')
		end
		return sendchatarray(configuration.main_settings.playcd, {
			{'/do Рация свисает на поясе.'},
			{'/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней'},
			{'/do Охрана выводит нарушителя из холла.'},
			{'/expel %s %s',id,reason},
		})
	end)

	updatechatcommands()

	lua_thread.create(function()
		local function sampIsLocalPlayerSpawned()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
		while not sampIsLocalPlayerSpawned() do wait(1000) end
		if sampIsLocalPlayerSpawned() then
			wait(2000)
			getmyrank = true
			sampSendChat('/stats')
		end
	end)

	while true do
		if getCharPlayerIsTargeting() then
			if configuration.main_settings.fmtype == 0 then
				if configuration.main_settings.createmarker then
					local targettingped = select(2,getCharPlayerIsTargeting())
					if sampGetPlayerIdByCharHandle(targettingped) then
						if marker ~= nil and oldtargettingped ~= targettingped then
							removeBlip(marker)
							marker = nil
							marker = addBlipForChar(targettingped)
						elseif marker == nil and oldtargettingped ~= targettingped then
							marker = addBlipForChar(targettingped)
						end
					end
					oldtargettingped = targettingped
				end
				if isKeysDown(configuration.main_settings.usefastmenu) and not sampIsChatInputActive() then
					if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
						setVirtualKeyDown(0x02,false)
						fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
						ASHelperMessage(format('Вы использовали меню быстрого доступа на: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
						ASHelperMessage('Зажмите {MC}ALT{WC} для того, чтобы скрыть курсор. {MC}ESC{WC} для того, чтобы закрыть меню.')
						wait(0)
						windows.imgui_fm[0] = true
					end
				end
			end

			if isKeysDown(configuration.main_settings.fastexpel) and not sampIsChatInputActive() and configuration.main_settings.dofastexpel then
				if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
					if configuration.main_settings.myrankint > 2 then
						local id, reason = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting()))), configuration.main_settings.expelreason
						if #reason > 0 then
							if not sampIsPlayerPaused(id) then
								sendchatarray(configuration.main_settings.playcd, {
									{'/do Рация свисает на поясе.'},
									{'/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней'},
									{'/do Охрана выводит нарушителя из холла.'},
									{'/expel %s %s',id,reason},
								})
							else
								ASHelperMessage('Игрок находится в АФК!')
							end
						else
							ASHelperMessage('/expel [id] [причина]')
						end
					else
						ASHelperMessage('Данное действие доступно с 2-го ранга.')
					end
				end
			end
		end

		if isKeysDown(configuration.main_settings.fastscreen) and configuration.main_settings.dofastscreen and (clock() - tHotKeyData.lasted > 0.1) and not sampIsChatInputActive() then
			sampSendChat('/time')
			wait(500)
			setVirtualKeyDown(0x77, true)
			wait(0)
			setVirtualKeyDown(0x77, false)
		end

		if inprocess and isKeyDown(0x12) and isKeyJustPressed(0x55) then
			inprocess:terminate()
			inprocess = nil
			ASHelperMessage('Отыгровка успешно прервана!')
		end

		if skiporcancel and isKeyDown(0x12) and isKeyJustPressed(0x4F) then
			skiporcancel = false
			sampSendChat('Сожалею, но без мед. карты я не продам. Оформите её в любой больнице.')
			ASHelperMessage('Ожидание мед. карты остановлено!')
		end

		if isKeyDown(0x11) and isKeyJustPressed(0x52) then
			NoErrors = true
			print('{FFFF00}Скрипт был перезагружен комбинацией клавиш Ctrl + R')
		end

		if configuration.main_settings.playdubinka then
			local weapon = getCurrentCharWeapon(playerPed)
			if weapon == 3 and not rp_check then 
				sampSendChat('/me сняв дубинку с пояса {gender:взял|взяла} в правую руку')
				rp_check = true
			elseif weapon ~= 3 and rp_check then
				sampSendChat('/me {gender:повесил|повесила} дубинку на пояс')
				rp_check = false
			end
		end

		for key = 1, #configuration.BindsName do
			if isKeysDown(configuration.BindsKeys[key]) and not sampIsChatInputActive() and configuration.BindsType[key] == 1 then
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for _ in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end

					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(configuration.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							else
								local delay = bp:match('%{delay_(%d+)%}')
								wait(delay)
							end
						end
						wait(0)
						inprocess = nil
					end)
				else
					ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}U{WC}')
				end
			end
		end

		for k = 1, #zametki do
			if isKeysDown(zametki[k].button) and not sampIsChatInputActive() then
				windows.imgui_zametka[0] = true
				zametka_window[0] = k
			end
		end

		if sampIsDialogActive() then
			checker_variables.lastDialogWasActive = clock()
		end

		if configuration.Checker.state then
			local ch = checker_variables
			local cfgch = configuration.Checker
	
			local offset = cfgch.font_offset
	
			local col_title = changeColorAlpha(cfgch.col_title, cfgch.font_alpha)
			local col_default = changeColorAlpha(cfgch.col_default, cfgch.font_alpha)
			local col_no_work = changeColorAlpha(cfgch.col_no_work, cfgch.font_alpha)
	
			if renderFontDrawClickableText(true, ch.font, 'Сотрудники онлайн ['..(ch.online.online or 0)..' | AFK: '..(ch.online.afk or 0)..']', cfgch.posX, cfgch.posY, col_title, 0x90FFFFFF) then
				if not checker_variables.await.members then
					sampSendChat('/members')
					checker_variables.await.members = true
					checker_variables.dontShowMeMembers = false
				end
			end
			
			for k, member in ipairs(ch.online) do
				local render_color = cfgch.show_uniform and (member.uniform and col_default or col_no_work) or col_default
	
				local rank = cfgch.show_rank and '['..member.rank..'] ' or ''
				local nick = member.nickname
				local id = cfgch.show_id and '('..member.id..')' or ''
				local afk = cfgch.show_afk and getAfk(member.rank, member.afk, render_color) or ''
				local warns = cfgch.show_warn and ' - Warns: '..member.warns or ''
				local mute = cfgch.show_mute and member.mute and ' || Muted' or ''
				local near = cfgch.show_near and (member.near and ' [N]' or '') or ''
				local note = configuration.Checker_Notes[nick] and getNote(configuration.Checker_Notes[nick], render_color) or ''
	
				local render_text = format('%s%s%s%s%s%s%s%s', rank, nick, id, afk, warns, mute, near, note)
	
				if renderFontDrawClickableText(true, ch.font, render_text, cfgch.posX, cfgch.posY + k * offset, render_color, render_color) then
					imgui.StrCopy(ch.note_input, u8(configuration.Checker_Notes[nick] or ''))
					checker_variables.temp_player_data = member
				end
			end
		end

		if configuration.main_settings.autoupdate and clock() - autoupd[0] > 600 then
			checkUpdates('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/Updates/update.json')
			autoupd[0] = clock()
		end

		if clock() - checker_variables.last_check >= configuration.Checker.delay and clock() - checker_variables.lastDialogWasActive > 2 then
			sampSendChat('/members')
			checker_variables.await.members = true
			checker_variables.dontShowMeMembers = false
			checker_variables.last_check = clock()
		end
		wait(0)
	end
end

changelog = {
	versions = {
		{
			version = '1.0',
			date = '31.03.2021',
			text = {'Релиз (спасибо zody за помощь в разработке)'},
		},

		{
			version = '2.1',
			date = '01.05.2021',
			text = {
				'Меню статистики /ashstats сделано более удобным',
				'Двойной клик сохранит местоположение статистики /ashstats',
				'Изменены кнопки в главном меню /ash',
				'Теперь можно тестировать цвета в /ash',
				'Теперь при активации бинда последнее сообщение будет без задержки',
				'Добавлен список изменений',
				'Исправлена проверка обновлений через /ash',
				'Кардинальный редизайн главного меню /ash',
				'Добавлены разные стили окон',
				'Добавлены настройки цветов /r чата и /d чата',
				'Добавлена функция просмотра правил',
				'Добавлена функция быстрого /time + скрин',
				'Добавлено автоопределение пола',
				'Добавлена функция удаления конфига',
			},
			patches = {
				active = false,
				text = [[
 - Исправлен баг с собеседованиями
 - Исправлен баг с поиском по уставу
 - Исправлен баг с ударом при принятии человека в организацию]]
			},
		},

		{
			version = '2.2',
			date = '10.05.2021',
			text = {
				'Добавлена функция увольнения с ЧС через команду',
				'Добавлена функция озвучивания лекций /ashlect',
				'Переделана система проверки нахождения на сервере Аризоны',
				'Переработана система правил',
				'Исправлен краш при поиске в правилах вводя управляющие символы',
				'Исправлены некоторые грамматические ошибки',
			},
 			patches = {
				active = false,
				text = [[
 - Исправлен краш при открытии /ashstats
 - Исправлен краш при сбросе цвета
 - Исправлен баг с непродающимися лицензиями
 - Исправлен баг с пропадающим курсором после использования быстрого меню]]
			},
		},

		{
			version = '2.3',
			date = '14.05.2021',
			text = {
				'Убрана зависимость от библиотеки rkeys',
				'Убрана зависимость от библиотеки fAwesome5',
				'Добавлена функция показа полосы прокрутки',
				'Оптимизирована и улучшена система указаний клавиш для биндера',
				'Добавлены png картинки вместо заголовков у окон',
				'Добавлены тэги в биндер',
			},
		},

		{
			version = '2.4',
			date = '16.05.2021',
			text = {
				'Добавлена функция общения в рацию департамента /ashdep',
				'Изменён список изменений',
				'Удалена светло-тёмная тема',
				'Удалена система повышений из изначальных правилах из-за ненадобности',
				'Добавлена поддержка 16-го сервера (Gilbert)',
				'Исправлены размеры изображений',
				'Теперь меню лекций доступно с 5-го ранга',
			},
			patches = {
				active = false,
				text = [[
 - Добавлена функция продажи лицензии на таксование
 - Исправлен баг с вводом /givelicense самостоятельно]]
			},
		},

		{
			version = '2.5',
			date = '25.07.2021',
			text = {
				'Добавлена автоотыгровка дубинки',
				'Выгонять теперь можно со 2-го ранга',
				'Переделана система проверки устава',
				'Добавлен таймер последнего вопроса в проверку устава',
			},
			patches = {
				active = false,
				text = [[ - Исправлен баг с крашем скрипта при озвучивании прайс листа]]
			},
		},

		{
			version = '2.6',
			date = '28.08.2021',
			text = {
				'Добавлена поддержка 17-го сервера (Show Low)',
			},
			patches = {
				active = false,
				text = [[
 - Исправлен краш при открытии вкладки 'Связь со мной'
 - Исправлен баг с восстановлением лекций/вопросов
 - Испралена неработоспособность скрипта из-за перехода сервера на R3]]
			},
		},

		{
			version = '2.7',
			date = '02.11.2021',
			text = {
				'Добавлена функция задержки между сообщениями в биндере',
				'Добавлена причина /expel',
				'Теперь ранги в хелпере синхронизируются с вашими',
				'Добавлена поддержка 18-го сервера (Casa-Grande)',
			},
		},
		
		{
			version = '3.0',
			date = '11.12.2021',
			text = {
				'Изменение интерфейса в списке изменений и /ash',
				'Добавлен новый интерфейс в меню быстрого доступа',
				'Полный рефакторинг и переосмысление кода',
				'Изменена система проверки и установки обновлений, теперь установку должны подтверждать Вы',
				'Добавлены уведомления, заметки',
				'Добавлена поддержка «MoonMonet»',
				'Полный переход на mimgui',
				'Изменена система проверки и подкачки библиотек',
				'Добавлены правила и проверка устава в зависимости от вашего сервера (правила были взяты с форума 13.11.2021, при изменении писать автору)',
				'Добавлена вкладка \'Отыгровки\', в которой можно настроить: проверку мед. карты при продаже лицензии на оружие, охоту; замену слова \'Автошкола\' на \'ГЦЛ\'; выставить задержку между сообщениями',
				'Добавлена проверка трудовой книжки и лицензий в собеседовании.',
				'Удалена система проверки сервера, теперь скрипт работает на всех серверах.',
			},
			patches = {
				active = false,
				text = [[
 - Исправлен краш скрипта при изменении местоположения выключенной статистики
 - Исправлен баг с неработающей командой /ashupd
 - Исправлен баг с размером меню быстрого доступа при смене стиля
 - Исправлен баг с причиной увольнения через меню быстрого доступа
 - Изменены некоторые отыгровки]]
			},
		},

		{
			version = '3.1',
			date = '13.03.2022',
			text = {
				'Исправлен баг с \'Не флуди\' после /do и /todo',
				'Добавлен встроенный чекер сотрудников на экране ({LINK:идея Cosmo||https://www.blast.hk/threads/59761/})',
				'Добавлен быстрый /expel на ПКМ + G (по умолчанию)',
				'Добавлена функция отображения ранга сотрудника в рации и на груди',
				'Изменены/добавлены некоторые отыгровки {HINT:1. nRP ник в отказе собеседования\n2. Некоторые обращения к клиентам на Вы\n3. Некоторые грамматические ошибки\n4. Раздевалка теперь не за дверью при инвайте}',
				'Изменена система PNG файлов {HINT:Теперь вместо 10-ти файлов нужно скачивать всего один}',
			},
		},

	},
}

default_lect = {
	active = { bool = false, name = nil, handle = nil },
	data = {
		{
			name = 'Правила дорожного движения',
			text = {
				'Дорогие сотрудники, сейчас я проведу лекцию на тему Правил Дорожного Движения.',
				'Водитель должен пропускать пешеходов в специальных местах для перехода.',
				'Водителю запрещается нарушать правила дорожного движения предписанные на офф.портале.',
				'Сотрудники нарушившие ПДД будут наказаны в виде выговора, в худшем случае - увольнение.',
				'Все мы хотим вернуться после работы домой здоровыми и невредимыми...',
				'Спасибо за внимание, лекция окончена.'
			}
		},
		{
			name = 'Субординация в Автошколе',
			text = {
				'Дорогие сотрудники! Минуточку внимания.',
				'Прошу вас соблюдать Субординацию в Автошколе...',
				'К старшим по должности необходимо обращаться на \'Вы\'.',
				'Также , запрещено нецензурно выражаться , и оскорблять сотрудников...',
				'За такие поступки , будут выдаваться выговоры.',
				'Благодарю за внимание!',
				'Прошу не нарушать Субординацию.'
			}
		},
		{
			name = 'Запреты в рацию',
			text = {
				'Сейчас я расскажу вам лекцию на тему \'Запреты в рацию\'.',
				'Хочу напомнить вам о том, что в рацию запрещено...',
				'торговать домами, автомобилями, бизнесами и т.п.',
				'Так же в рацию нельзя материться и выяснять отношения между собой.',
				'За данные нарушения у вас отберут рацию. При повторном нарушении Вы будете уволены.',
				'Спасибо за внимание. Можете продолжать работать.'
			}
		},
		{
			name = 'Основные правила Автошколы',
			text = {
				'Cейчас я проведу лекцию на тему \'Основные правила Автошколы\'.',
				'Сотрудникам автошколы запрещено прогуливать рабочий день.',
				'Сотрудникам автошколы запрещено в рабочее время посещать мероприятия.',
				'Сотрудникам автошколы запрещено в рабочее время посещать казино.',
				'Сотрудникам автошколы запрещено в рабочее время посещать любые подработки.',
				'Сотрудникам автошколы запрещено носить при себе огнестрельное оружие.',
				'Сотрудникам автошколы запрещено курить в здании автошколы.',
				'Сотрудникам автошколы запрещено употреблять алкогольные напитки в рабочее время.',
				'На этом у меня всё, спасибо за внимание.'
			}
		},
		{
			name = 'Рабочий день',
			text = {
				'Уважаемые сотрудники, минуточку внимания!',
				'Сейчас я проведу лекцию на тему Рабочий день.',
				'Сотрудники в рабочее время обязаны находиться в офисе автошколы в форме.',
				'За прогул рабочего дня сотрудник получит выговор или увольнение.',
				'С понедельника по пятницу рабочий день с 9:00 до 19:00.',
				'В субботу и воскресенье рабочий день с 10:00 до 18:00.',
				'В не рабочее время или в обед сотрудник может покинуть офис Автошколы.',
				'Но перед этим обязательно нужно снять форму.',
				'Обед идёт с 13:00 до 14:00.',
				'На этом у меня всё, спасибо за внимание.'
			}
		}
	}
}