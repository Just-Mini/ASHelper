--[[
	[стили imgui]
		1-ый imgui стиль (переделан под лад mimgui): https://www.blast.hk/threads/25442/post-310168

	[библиотеки]
		mimgui: https://www.blast.hk/threads/66959/
		SAMP.lua: https://www.blast.hk/threads/14624/
		MoonMonet: https://www.blast.hk/threads/105945/

	[гайды]
		Картинки и шрифт в base85: https://www.blast.hk/threads/28761/ | https://www.blast.hk/threads/28761/post-289682
		Обновление скрипта: https://www.blast.hk/threads/30501/

	[функции]
		string.separate: https://www.blast.hk/threads/13380/post-220949
		imgui.BoolButton: https://www.blast.hk/threads/59761/
		imgui.Hint: https://www.blast.hk/threads/13380/post-778921
		imgui.AnimButton (слегка изменён): https://www.blast.hk/threads/13380/post-793501
		imgui.Spinner: https://www.blast.hk/threads/13380/post-1609390
		sampIsLocalPlayerSpawned: https://www.blast.hk/threads/65247/post-899293
		getTimeAfter: bank helper
]]

script_name('autoschool helper')
script_description('Удобный помощник для Автошколы.')
script_author('JustMini')
script_version('3.4.1')
script_dependencies('mimgui; samp events; MoonMonet')

require 'moonloader'

local dlstatus					= require 'moonloader'.download_status
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local bit 						= require 'bit'
local ffi 						= require 'ffi'

local encodingcheck, encoding	= pcall(require, 'encoding')
local imguicheck, imgui			= pcall(require, 'mimgui')
local monetluacheck, monetlua 	= pcall(require, 'MoonMonet')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')

if not imguicheck or not sampevcheck or not encodingcheck or (not monetluacheck and doesDirectoryExist(getWorkingDirectory()..'\\lib\\MoonMonet')) then
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
			downladinglibname = '',
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
		
		function ImSaturate(f)
			return f < 0.0 and 0.0 or (f > 190.0 and 190.0 or f)
		end

		lua_thread.create(function()
			local x = select(1,getScreenResolution()) * 0.5 - 100
			local y = select(2, getScreenResolution()) - 70
			while true do
				if progressbar and progressbar.max ~= nil and progressbar.downloadinglibname and progressbar.downloaded and progressbar.downloadingtheme then
					local jj = (200-10)/progressbar.max
					local downloaded = ImSaturate(progressbar.downloadedvisual * jj)
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
			print('{FFFF00}Скачивание: mimgui (v1.7.1)')
			createDirectory('moonloader/lib/mimgui')
			DownloadFiles({theme = 'mimgui',
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/init.lua', file = 'moonloader/lib/mimgui/init.lua', name = 'init.lua'},
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/imgui.lua', file = 'moonloader/lib/mimgui/imgui.lua', name = 'imgui.lua'},
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/dx9.lua', file = 'moonloader/lib/mimgui/dx9.lua', name = 'dx9.lua'},
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/cimguidx9.dll', file = 'moonloader/lib/mimgui/cimguidx9.dll', name = 'cimguidx9.dll'},
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/cdefs.lua', file = 'moonloader/lib/mimgui/cdefs.lua', name = 'cdefs.lua'},
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/mimgui/win32.lua', file = 'moonloader/lib/mimgui/win32.lua', name = 'win32.lua'},
			})
			print('{00FF00}mimgui успешно скачан')
		end

		if not monetluacheck and doesDirectoryExist(getWorkingDirectory()..'\\lib\\MoonMonet') then -- У нортхна
			print('{FFFF00}Скачивание: MoonMonet (v0.1.0)')
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
				{url = 'https://raw.githubusercontent.com/Just-Mini/ASHelper/main/lib/encoding.lua', file = 'moonloader/lib/encoding.lua', name = 'encoding.lua'}
			})
			print('{00FF00}encoding успешно скачан')
		end

		print('{FFFF00}Файлы были успешно скачаны, скрипт перезагружен.')
		thisScript():reload()
	end
	return
end

local print, clock, sin, floor, ceil, abs, format, gsub, gmatch, find, char, len, upper, lower, sub, u8, new, str, sizeof = print, os.clock, math.sin, math.floor, math.ceil, math.abs, string.format, string.gsub, string.gmatch, string.find, string.char, string.len, string.upper, string.lower, string.sub, encoding.UTF8, imgui.new, ffi.string, ffi.sizeof

encoding.default = 'CP1251'

json = setmetatable({
	defPath = getWorkingDirectory()..'/AS Helper/',
	save = function(t,path) 
		if not path:find('[\\/]') then
			path = json.defPath..path
		end
		if not doesDirectoryExist(path:match('(.+)/.+%.%S+$')) then
			createDirectory(path:match('(.+)/.+%.%S+$'))
		end

		t = (t == nil and {} or (type(t) == 'table' and t or {}))
		local f = io.open(path,'w')
		f:write(encodeJson(t) or {})
		f:close()
	end,
	load = function(t,path) 
		if not path:find('[\\/]') then
			path = json.defPath..path
		end
		if (not doesFileExist(path) or not doesDirectoryExist(path:match('(.+)/.+%.%S+$'))) then
			json.save(t,path)
		end

		local f = io.open(path,'r+')
		local T = decodeJson(f:read('*a'))
		f:close()

		checktable = function(x, y)
			for k, v in pairs(x) do
				if y[k] == nil then
					y[k] = v
				end
				if type(y[k]) == 'table' then
					checktable(x[k], y[k])
				end
			end
		end
		checktable(t, T)

		return setmetatable(T, {__call = function(t) json.save(t,path) end,})
	end},{
	__call = function(self, n, func, ...)
		if not doesDirectoryExist(getWorkingDirectory()..'/AS Helper/') then
			createDirectory(getWorkingDirectory()..'/AS Helper/')
		end
	end,}
)

AshSettings = json.load({
	MainSettings = {
		myrankint = 1,
		gender = 0,
		style = 0,
		rule_align = 1,
		lection_delay = 10,
		lection_type = 1,
		fmtype = 0,
		playcd = 2000,
		myname = '',
		myaccent = '',
		astag = 'Автошкола',
		expelreason = 'Н.П.А.',
		usefastmenucmd = 'ashfm',
		replaceashto = 'ГЦЛ',
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
		checkmcongun = true,
		checkmconhunt = false,
		bodyrank = false,
		chatrank = false,
		autorepair = false,
		autocheckmc = true,
		autodoor = true,
		guiinform = true,
		usefastmenu = 'E',
		fastscreen = 'F4',
		fastexpel = 'G',
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = {
			color = 4281558783,
			themeBased = true,
		},
		monetstyle = -16729410,
		monetstyle_chroma = 1.0,
	},

	Interview = {
		pass = {
			state = true,
			minLvl = 3,
			minLaw = 35,
		},
		mc = {
			state = true,
			healthStatus = true,
			maxAddiction = 5,
		},
		licenses = {
			state = false,
			auto = true,
			moto = true,
		},

		additional_questions = {
			'Расскажите немного о себе',
			'Работали Вы уже в организациях ЦА?',
			'Почему Вы выбрали именно нас?',
		}
	},
	
	ScannedVariables = {
		PriceList = {
			{
				price = {
					200000,
					360000,
					410000
				},
				rank = 1,
				medcard = false
			},
			{
				price = {
					300000,
					350000,
					450000
				},
				rank = 2,
				medcard = false
			},
			{
				price = {
					1200000,
				},
				rank = 7,
				medcard = false
			},
			{
				price = {
					500000,
					550000,
					590000
				},
				rank = 3,
				medcard = false
			},
			{
				price = {
					500000,
					550000,
					590000
				},
				rank = 4,
				medcard = false
			},
			{
				price = {
					1000000,
					1090000,
					1150000
				},
				rank = 5,
				medcard = true
			},
			{
				price = {
					1000000,
					1100000,
					1190000
				},
				rank = 5,
				medcard = true
			},
			{
				price = {
					1100000,
					1200000,
					1290000
				},
				rank = 6,
				medcard = false
			},
			{
				price = {
					800000,
					1150000,
					1250000
				},
				rank = 6,
				medcard = false
			},
			{
				price = {
					800000,
					1150000,
					1250000
				},
				rank = 6,
				medcard = false
			}
		},
	
		RankNames = {
			[1] = 'Стажёр',
			[2] = 'Консультант',
			[3] = 'Лицензёр',
			[4] = 'Мл.Инструктор',
			[5] = 'Инструктор',
			[6] = 'Менеджер',
			[7] = 'Ст. Менеджер',
			[8] = 'Помощник директора',
			[9] = 'Директор',
			[10] = 'Управляющий',
		},
	},

	Checker = {
		confirm = false,
    	state = true,
    	delay = 30,
    	afk_max_l = 300,
    	afk_max_h = 600,
    	posX = -100,
    	posY = -100,
		align = 0,

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
    	show_specwarn = false,
		show_quests = false,
    	show_mute = false,
    	show_demorgan = false,
    	show_uniform = true,
    	show_near = false,

		Notes = {},
	},

	TaskChecker = {
		state = true,
    	delay = 30,
    	posX = -100,
    	posY = -100,
		align = 0,

    	col_title = 0xFFFF6633,
    	col_default = 0xFFFFFFFF,
    	col_completed = 0xAAFF3333,
    	col_tasks = 0xFFFF0000,

		font_name = 'Arial',
    	font_size = 9,
    	font_flag = 5,
    	font_offset = 14,
    	font_alpha = 255,

		completed_tasks = true,
	},

	Binder = {
		BindsName = {},
		BindsDelay = {},
		BindsType = {},
		BindsAction = {},
		BindsCmd = {},
		BindsKeys = {}
	},
}, 'Configuration.Json')

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
		['ICON_FA_CAR_WRENCH'] = '\xee\x80\xbf',
		['ICON_FA_PLANE'] = '\xee\x81\x80',
		['ICON_FA_CHEVRON_DOWN'] = '\xee\x81\x81',
		['ICON_FA_LOCK'] = '\xee\x81\x82',
		['ICON_FA_HEART'] = '\xee\x81\x83',
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
					return 0xe043
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
local scriptInitialized				= false

local newwindowtype					= new.int(1)
local clienttype					= new.int(0)
local leadertype					= new.int(0)
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
local auto_update_box				= new.bool(AshSettings.MainSettings.autoupdate)
local get_beta_upd_box				= new.bool(AshSettings.MainSettings.getbetaupd)

local lections						= {}
local zametki						= {}
local dephistory					= {}
local updateinfo					= {}
local LastActiveTime				= {}
local LastActive					= {}

local mainwindow					= new.int(0)
local settingswindow				= new.int(1)
local additionalwindow				= new.int(1)
local infowindow					= new.int(1)
local monetstylechromaselect		= new.float[1](AshSettings.MainSettings.monetstyle_chroma)
local alpha							= new.float[1](0)
local thanksAlpha					= new.float[1](0)

local windows = {
	imgui_settings 					= new.bool(),
	imgui_fm 						= new.bool(),
	imgui_binder 					= new.bool(),
	imgui_lect						= new.bool(),
	imgui_depart					= new.bool(),
	imgui_changelog					= new.bool(),
	imgui_first_launch				= {},
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
	RChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.RChatColor)),
	DChatColor 						= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.DChatColor)),
	ASChatColor 					= vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)),
}
local usersettings = {
	createmarker 					= new.bool(AshSettings.MainSettings.createmarker),
	dorponcmd						= new.bool(AshSettings.MainSettings.dorponcmd),
	replacechat						= new.bool(AshSettings.MainSettings.replacechat),
	replaceash						= new.bool(AshSettings.MainSettings.replaceash),
	dofastscreen					= new.bool(AshSettings.MainSettings.dofastscreen),
	dofastexpel						= new.bool(AshSettings.MainSettings.dofastexpel),
	playdubinka						= new.bool(AshSettings.MainSettings.playdubinka),
	tasksvisible					= new.bool(AshSettings.TaskChecker.state),
	completedtasksvisible			= new.bool(AshSettings.TaskChecker.completed_tasks),
	bodyrank						= new.bool(AshSettings.MainSettings.bodyrank),
	chatrank						= new.bool(AshSettings.MainSettings.chatrank),
	autorepair						= new.bool(AshSettings.MainSettings.autorepair),
	autodoor						= new.bool(AshSettings.MainSettings.autodoor),
	guiinform						= new.bool(AshSettings.MainSettings.guiinform),
	autocheckmc						= new.bool(AshSettings.MainSettings.autocheckmc),
	themeBased						= new.bool(AshSettings.MainSettings.ASChatColor.themeBased),
	playcd							= new.float[1](AshSettings.MainSettings.playcd / 1000),
	myname 							= new.char[256](AshSettings.MainSettings.myname),
	myaccent 						= new.char[256](AshSettings.MainSettings.myaccent),
	fmtype							= new.int(AshSettings.MainSettings.fmtype),
	expelreason						= new.char[256](u8(AshSettings.MainSettings.expelreason)),
	usefastmenucmd					= new.char[256](u8(AshSettings.MainSettings.usefastmenucmd)),
	replaceashto					= new.char[256](u8(AshSettings.MainSettings.replaceashto)),
	moonmonetcolorselect			= vec4ToFloat4(ColorAccentsAdapter(AshSettings.MainSettings.monetstyle):as_vec4()),
}
local pricelist = {
	avtoprice 						= new.char[7](tostring(AshSettings.MainSettings.avtoprice)),
	motoprice 						= new.char[7](tostring(AshSettings.MainSettings.motoprice)),
	ribaprice 						= new.char[7](tostring(AshSettings.MainSettings.ribaprice)),
	lodkaprice 						= new.char[7](tostring(AshSettings.MainSettings.lodkaprice)),
	gunaprice 						= new.char[7](tostring(AshSettings.MainSettings.gunaprice)),
	huntprice 						= new.char[7](tostring(AshSettings.MainSettings.huntprice)),
	kladprice						= new.char[7](tostring(AshSettings.MainSettings.kladprice)),
	taxiprice						= new.char[7](tostring(AshSettings.MainSettings.taxiprice)),
	mechprice						= new.char[7](tostring(AshSettings.MainSettings.mechprice))
}
local tHotKeyData = {
	edit 							= nil,
	save 							= {},
	lasted 							= clock(),
}
local lectionsettings = {
	lection_type					= new.int(AshSettings.MainSettings.lection_type),
	lection_delay					= new.int(AshSettings.MainSettings.lection_delay),
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
	myorgname						= new.char[50](u8(AshSettings.MainSettings.astag)),
	toorgname						= new.char[50](),
	frequency						= new.char[7](),
	myorgtext						= new.char[256](),
}
local questionsettings = {
	questionname					= new.char[256](),
	questionhint					= new.char[256](),
	questionques					= new.char[256](),
}
local tagbuttons = {
	{name = '{my_id}',text = 'Пишет Ваш ID.',hint = '/n /showpass {my_id}\n(( /showpass \'Ваш ID\' ))'},
	{name = '{my_name}',text = 'Пишет Ваш ник из настроек.',hint = 'Здравствуйте, я {my_name}\n- Здравствуйте, я Ваше имя.'},
	{name = '{my_rank}',text = 'Пишет Ваш ранг из настроек.',hint = format('/do На груди бейджик {my_rank}\nНа груди бейджик %s', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint])},
	{name = '{my_score}',text = 'Пишет Ваш уровень.',hint = 'Я проживаю в штате уже {my_score} лет!\n- Я проживаю в штате уже \'Ваш уровень\' лет!'},
	{name = '{H}',text = 'Пишет серверное время в часы.',hint = 'Давай встретимся завтра тут же в {H} \n- Давай встретимся завтра тут же в чч'},
	{name = '{HM}',text = 'Пишет серверное время в часы:минуты.',hint = 'Сегодня в {HM} будет концерт!\n- Сегодня в чч:мм будет концерт!'},
	{name = '{HMS}',text = 'Пишет серверное время в часы:минуты:секунды.',hint = 'У меня на часах {HMS}\n- У меня на часах \'чч:мм:сс\''},
	{name = '{gender:Текст1|Текст2}',text = 'Пишет сообщение в зависимости от вашего пола.',hint = 'Я вчера {gender:был|была} в банке\n- Если мужской пол: был в банке\n- Если женский пол: была в банке'},
	{name = '@{ID}',text = 'Узнаёт имя игрока по ID.',hint = 'Ты не видел где сейчас @{43}?\n- Ты не видел где сейчас \'Имя 43 ида\''},
	{name = '{close_id}',text = 'Узнаёт ID ближайшего к Вам игрока',hint = 'О, а вот и @{{close_id}}?\nО, а вот и \'Имя ближайшего ида\''},
	{name = '{interact_id}',text = 'Пишет ID игрока с которым вы взаимодействуете',hint = '/pay {interact_id} 50000\nПередаёт игроку 50.000$'},
	{name = '{delay_*}',text = 'Добавляет задержку между сообщениями',hint = 'Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу Вам помочь?\n{delay_2000}\n/do На груди висит бейджик с надписью Лицензёр Автошколы.\n\n[10:54:29] Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу Вам помочь?\n[10:54:31] На груди висит бейджик с надписью Лицензёр Автошколы.'},
}
local buttons = {
	{name='Настройки',text='Персональное, чекер,\nвид скрипта',icon=fa.ICON_FA_LIGHT_COG,y_hovered=10,timer=0},
	{name='Организация',text='Отыгровки, лицензии,\nзаметки',icon=fa.ICON_FA_FOLDER,y_hovered=10,timer=0},
	{name='Информация',text='Обновления, автор,\nо скрипте',icon=fa.ICON_FA_LIGHT_INFO_CIRCLE,y_hovered=10,timer=0},
}
local fmbuttons = {
	{name = u8'Действия с клиентом', rank = 1},
	{name = u8'Собеседование', rank = 5},
	{name = u8'Лидерские действия', rank = 9},
}
local settingsbuttons = {
	{
		icon = fa.ICON_FA_USER,
		text = u8('Персональное'),
	},
	{
		icon = fa.ICON_FA_DESKTOP,
		text = u8('Чекер сотрудников'),
	},
	{
		icon = fa.ICON_FA_PALETTE,
		text = u8('Вид скрипта'),
	},
}
local additionalbuttons = {
	{
		icon = fa.ICON_FA_HEADING,
		text = u8(' Отыгровки'),
	},
	{
		icon = fa.ICON_FA_FILE_ALT,
		text = u8(' Лицензии'),
	},
	{
		icon = fa.ICON_FA_QUOTE_RIGHT,
		text = u8(' Заметки'),
	},
}
local infobuttons = {
	{
		icon = fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN,
		text = u8(' Обновления'),
	},
	{
		icon = fa.ICON_FA_AT,
		text = u8(' Автор'),
	},
	{
		icon = fa.ICON_FA_CODE,
		text = u8(' О скрипте'),
	},
}
local licenses = {
	{text = 'Авто', chat = 'авто',icon = fa.ICON_FA_CAR,bool = false,month = 1},
	{text = 'Мото', chat = 'мото-транспорт',icon = fa.ICON_FA_MOTORCYCLE,bool = false,month = 1},
	{text = 'Полеты', chat = 'воздушный транспорт',icon = fa.ICON_FA_PLANE,bool = false,month = 1},
	{text = 'Рыбалка', chat = 'рыбалку',icon = fa.ICON_FA_FISH,bool = false,month = 1},
	{text = 'Плавание', chat = 'водный транспорт',icon = fa.ICON_FA_SHIP,bool = false,month = 1},
	{text = 'Оружие', chat = 'владение оружием',icon = fa.ICON_FA_CROSSHAIRS,bool = false,month = 1},
	{text = 'Охота', chat = 'охоту',icon = fa.ICON_FA_SKULL_CROSSBONES,bool = false,month = 1},
	{text = 'Раскопки', chat = 'раскопки',icon = fa.ICON_FA_DIGGING,bool = false,month = 1},
	{text = 'Такси', chat = 'работу в такси',icon = fa.ICON_FA_TAXI,bool = false,month = 1},
	{text = 'Механик', chat = 'работу механиком',icon = fa.ICON_FA_CAR_WRENCH,bool = false,month = 1},
}
local sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
local repair = {
	signs_parcing = {
		dialogOpened = false,

		in_parcing = 0,
		signs = {},
		showed_signs = {},
		state = 0,
		sort = 1,
		sort_dontshow = true,
		make_path = 0,
		page = 0,
		max_pages = 3,
	},
}

local Interview = {
	stage = 1,
	previous_stage = 0,
	stage_changing_clock = 0,

	additional_docs = false,
	additional_docs_time = 0,

	additional_docs_config = {
		state = 0,
		clock = 0,
		pass = {
			state = imgui.new.bool(AshSettings.Interview.pass.state),
			minLvl = imgui.new.int(AshSettings.Interview.pass.minLvl),
			minLaw = imgui.new.int(AshSettings.Interview.pass.minLaw),
		},
		mc = {
			state = imgui.new.bool(AshSettings.Interview.mc.state),
			healthStatus = imgui.new.bool(AshSettings.Interview.mc.healthStatus),
			maxAddiction = imgui.new.int(AshSettings.Interview.mc.maxAddiction),
		},
		licenses = {
			state = imgui.new.bool(AshSettings.Interview.licenses.state),
			auto = imgui.new.bool(AshSettings.Interview.licenses.auto),
			moto = imgui.new.bool(AshSettings.Interview.licenses.moto),
		}
	},

	Checking = {
		state = 0,
		pass = {
			state = 0,
			reason = 0,
		},
		mc = {
			state = 0,
			reason = 0,
		},
		licenses = {
			state = 0,
			reason = 0,
		},
	},

	additional_questions_redact = 0,
	additional_questions_redact_input = new.char[256](),

	additional_reasons = false,
	additional_reasons_time = 0,

	additional_reasons_config = {
		clock = 0,
		lockedReasons = {
			['Мало лет в штате'] = false,
			['Маленькая законопослушность'] = false,
			['Не полностью здоров'] = false,
			['Высокая зависимость'] = false,
			['Нет лицензии на авто'] = false,
			['Нет лицензии на мото'] = false,
		},
		unlockedReasons = {
			choosed = 6,
			[1] = 'Плохое РП',
			[2] = 'Не было РП',
			[3] = 'Плохая грамматика',
			[4] = 'Ничего не показал',
			[5] = 'Документы',
			[6] = 'Без причины',
		}
	},
}

local checker_variables = {
	state = imgui.new.bool(AshSettings.Checker.state),
	delay = imgui.new.int(AshSettings.Checker.delay),
	note_input = imgui.new.char[256](),

	font_input = imgui.new.char[256](u8(AshSettings.Checker.font_name)),
	font_size = imgui.new.int(AshSettings.Checker.font_size),
	font_flag = imgui.new.int(AshSettings.Checker.font_flag),
	font_offset = imgui.new.int(AshSettings.Checker.font_offset),
	font_alpha = imgui.new.int(AshSettings.Checker.font_alpha / 2.55),

	afk_max_l = imgui.new.int(AshSettings.Checker.afk_max_l),
	afk_max_h = imgui.new.int(AshSettings.Checker.afk_max_h),

	show = {
		id = imgui.new.bool(AshSettings.Checker.show_id),
		rank = imgui.new.bool(AshSettings.Checker.show_rank),
		afk = imgui.new.bool(AshSettings.Checker.show_afk),
		warn = imgui.new.bool(AshSettings.Checker.show_warn),
		specwarn = imgui.new.bool(AshSettings.Checker.show_specwarn),
		quests = imgui.new.bool(AshSettings.Checker.show_quests),
		mute = imgui.new.bool(AshSettings.Checker.show_mute),
		demorgan = imgui.new.bool(AshSettings.Checker.show_demorgan),
		uniform = imgui.new.bool(AshSettings.Checker.show_uniform),
		near = imgui.new.bool(AshSettings.Checker.show_near),
	},

	col = {
		title = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.Checker.col_title), 2),
		default = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.Checker.col_default), 2),
		no_work = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.Checker.col_no_work), 2),
		afk_max = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.Checker.col_afk_max), 2),
		note = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.Checker.col_note), 2),
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
	font = renderCreateFont(AshSettings.Checker.font_name, AshSettings.Checker.font_size, AshSettings.Checker.font_flag)
}

local task_checker_variables = {

	state = imgui.new.bool(AshSettings.TaskChecker.state),
	delay = imgui.new.int(AshSettings.TaskChecker.delay),

	font_input = imgui.new.char[256](u8(AshSettings.TaskChecker.font_name)),
	font_size = imgui.new.int(AshSettings.TaskChecker.font_size),
	font_flag = imgui.new.int(AshSettings.TaskChecker.font_flag),
	font_offset = imgui.new.int(AshSettings.TaskChecker.font_offset),
	font_alpha = imgui.new.int(AshSettings.TaskChecker.font_alpha / 2.55),

	col = {
		title = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.TaskChecker.col_title), 2),
		default = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.TaskChecker.col_default), 2),
		completed = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.TaskChecker.col_completed), 2),
		tasks = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.TaskChecker.col_tasks), 2),
	},

	is_upgrade = 2,
	tasks = {completed = 0},

	font = renderCreateFont(AshSettings.TaskChecker.font_name, AshSettings.TaskChecker.font_size, AshSettings.TaskChecker.font_flag)
}

local ash_image
local rainbowcircle
local font = {}

imgui.OnInitialize(function()
	-- >> BASE85 DATA <<
		local circle_data = '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x30\x00\x00\x00\x30\x08\x06\x00\x00\x00\x57\x02\xF9\x87\x00\x00\x00\x06\x62\x4B\x47\x44\x00\xFF\x00\xFF\x00\xFF\xA0\xBD\xA7\x93\x00\x00\x09\xC8\x49\x44\x41\x54\x68\x81\xED\x99\x4B\x6C\x5C\xE7\x75\xC7\x7F\xE7\x7C\x77\x5E\xE4\x50\x24\x25\xCA\x7A\x90\xB4\x4D\xD3\x92\x9C\xBA\x8E\x8B\x48\xB2\xA4\xB4\x40\xEC\x04\x79\xD4\x81\xD1\x64\x93\x3E\x9C\x45\xBC\x71\x1D\xD7\x06\x8A\xAE\x5A\x20\x0B\x25\x6D\x36\x45\xBB\x69\xA5\xB4\x46\x90\x02\x2E\xEC\x3E\x50\x20\xC9\xA6\x8B\x3A\x80\xA3\x45\x92\x56\xAA\x92\x58\x71\x6D\x90\x52\x6C\xD9\xA2\x45\x51\xA2\x24\x4A\x7C\x0D\xE7\xF1\x9D\xD3\xC5\xCC\x90\x33\x73\x47\x7C\xA4\x41\xBB\xA8\x0E\xF0\xE1\xBB\x73\xEE\xBD\xDF\xFD\xFD\xBF\x73\xBE\xC7\xBD\x03\x77\xED\xAE\xFD\xFF\x36\xF9\x65\x34\xE2\x1C\xD7\x89\x47\x26\x8F\x54\xA9\x7D\xCC\x6B\x7E\x38\xE2\xFB\xDC\x6C\xC4\xCC\xB6\xED\x1B\x75\x73\xF3\x45\xDC\xA7\xCD\x6D\x52\x22\x67\x1D\xFF\xFE\xF6\x1F\x1E\x39\x23\x1C\xB7\xFF\x53\x01\x17\x8E\x3C\x3D\xE2\x15\x79\xC1\x2C\x3E\x6D\xEE\x23\xD1\x0C\x33\xC3\xDC\x30\x73\xCC\x8C\x07\x87\x0D\xDC\x71\x37\x30\xC7\xAD\x59\xFB\x07\xE6\xF1\x95\xA0\x76\x72\xC7\xE9\x53\x1F\xFC\xAF\x0A\x98\x3E\xF8\xEC\x50\x49\x2A\x7F\xE6\x1E\x9F\x31\xB3\x6C\x1D\xDA\xE9\x2A\x60\x6F\xEC\x02\x6F\xAB\x3E\x33\xAB\xA8\xD9\xDF\x95\xCB\xE5\xAF\x8C\x4C\x9C\xB9\xB1\x55\x16\xDD\xEA\x0D\x97\x8E\x3D\xF3\xBB\x95\x50\x9D\x14\xFC\xF7\x81\xEC\x46\xD7\xAF\x07\xEF\x66\x88\x59\xD6\xCC\x9F\xCB\x84\x64\x72\xE6\x43\x47\x7E\x67\xAB\x3C\x9B\x8E\x80\x1F\x7C\x36\x73\x39\x6B\x27\xCC\xED\xD9\x66\xEF\xD6\x7B\xBA\xD9\xEB\xDD\x23\x30\xBE\xAB\x72\x47\x78\xCC\x70\xF3\x46\x6D\xB8\x3B\x78\xFC\xDB\xDD\x7B\x8A\x2F\xCA\xA9\x53\xB5\xCD\x70\x6D\x2A\x02\xDF\x7F\xF8\x64\xF1\x52\x2E\xF9\x37\xE0\xD9\xCD\x0A\x5E\x15\xBE\x15\x78\x33\x3C\xF2\xDC\x95\x4B\xF3\xDF\xBD\xF6\xFC\xCE\xE2\x66\xDA\xDF\x30\x02\x2F\x1D\x3C\x9B\x59\x9C\xBB\xFD\xDD\x87\x7A\xDF\x7E\xF2\xD1\xE2\xB9\xB6\xDE\x6D\x8F\x00\x50\xC8\xA2\xFD\x45\xA4\x58\x80\x44\x21\x97\xB0\x77\xD0\xF0\x95\x32\x56\x2E\x63\xB7\xE7\x89\xD7\x6F\xE2\x0B\x0B\xDD\xE1\x1B\xBE\xFC\x93\xD3\xE4\x3F\x31\x7B\xAA\x30\x10\x3F\x29\x4F\xB0\x6E\x24\x92\x8D\x04\x54\x16\x4A\x27\x42\x08\x4F\x4E\x2C\xFD\x0A\xE6\xCE\xA3\xC5\x37\x52\x7D\x90\x0C\xF6\x91\x1D\xDE\x05\x85\xEC\x5A\x1A\x35\x04\xA2\x02\xF9\x2C\x9A\xCD\x20\xBD\x3D\xE8\xEE\x7B\xF0\xE5\x12\xB5\xF7\xA6\x88\xB3\xD7\xD3\xF0\xBF\x39\x4D\xCF\x93\x33\x00\x8F\x97\x97\x39\x01\x3C\xB7\x1E\xDF\xBA\x11\x78\xE9\x91\xD3\xBF\x57\x8B\xF1\xD5\x18\x23\x66\x91\x18\x23\xFB\x0A\xFF\xC5\x87\x7B\xDF\xC0\xCC\x20\x9B\x90\x1F\x1F\x81\x9E\x5C\x3D\x2A\x6E\x29\x01\x7B\x06\x6B\x6B\x29\x64\x8D\x29\xB5\x91\x42\x36\xBF\x40\x75\xE2\xE7\x58\x69\xA5\x0E\xFF\x99\x69\x0A\x75\xF8\x56\xC2\xA7\x0B\x9F\xE5\x1F\xB6\x2C\xE0\xE5\xC7\x4E\xEF\x58\x59\x96\x09\xC7\x87\x62\x03\x7E\x55\x44\xFE\x4D\x7E\x6D\xD7\x24\xF9\x7D\xA3\x78\xD0\x06\xF4\x1D\x04\xF4\x57\xBB\xC2\x37\x7B\xDC\x2A\x15\xAA\x13\x17\xC8\x1E\x9D\xA4\xF0\x99\x99\x34\x88\x70\xB3\x26\x1C\xD8\xF6\x14\xD7\xBB\x71\xDE\x71\x10\x57\xAB\xC9\xD7\x35\xE8\x90\x88\x10\x34\x10\x42\x40\x1B\xF5\x54\xF6\x23\xCC\xDC\xFB\x38\x92\xD9\x30\x03\xD7\x85\x77\x33\x44\x95\xE2\x33\x03\xF4\x3C\xB5\x02\x46\xBA\x44\xB6\x67\x6A\x7C\xED\x4E\xED\x77\x8D\xC0\x37\x3F\x7C\x6E\x24\x04\x7B\xC7\xDC\xB2\xEE\xF5\x01\xEB\xEE\x44\x8B\x48\x02\xF7\x3C\x5C\xC4\x83\x31\x9A\x79\x87\xB1\xFC\x85\x75\x23\xB0\xAB\xB7\x74\x47\x78\xCC\xC8\x1E\xBE\x4E\xF6\xE8\x4D\xDC\xAA\xC4\xAB\x3F\x81\x58\xEA\xDA\x9F\x92\x30\xDE\xF3\x39\xA6\x3A\x4F\x74\xED\xC2\x24\xE3\x2F\xE0\x92\x55\x14\xC3\x50\x55\xCC\x8C\xA0\x81\xA1\x87\x7A\xC9\xE4\x95\x18\x23\x53\xD5\x71\xDC\x9D\xFB\x72\xE7\x57\xEF\xD5\x42\x8E\xEC\xD0\x20\x5A\xEC\xC1\x73\x09\xB9\xDE\x88\x95\x56\xB0\xB9\x39\x6A\x33\xD7\x60\x71\x69\x0D\xFE\xD0\x75\xB2\x8F\xDD\x04\x03\x21\x43\x18\xFC\x10\xF1\xDA\x4F\xBA\x21\x65\xA8\xF0\x3C\xF0\x27\x1B\x46\xE0\x38\xAE\xF7\x1F\xFC\xD9\xFB\xC0\x88\xBB\xE3\x5E\xEF\x59\x77\x27\x37\x98\xB0\x63\xBC\xA7\x3E\x7D\xBA\x11\x63\x24\x5A\x64\x6F\xF8\x39\xF7\xE7\xCF\x93\xBD\x77\x17\x61\x68\x70\x35\x0A\xD1\x8C\xC1\xDE\xB8\xD6\xFB\x31\x52\x9B\xBE\x4A\xED\xE2\xFB\x64\x3E\x72\x8D\xEC\xE1\x9B\x29\x52\xBB\xF1\x16\xB6\x32\xDB\x4D\xC4\x54\xEF\x04\xF7\xCB\x71\xDA\x36\x80\xA9\x08\x8C\x3D\xF6\xE6\x11\x4C\x46\xDC\x1D\x91\xBA\xBE\x66\x24\xB6\x8F\xF6\x20\x2A\xA8\x35\x86\x4E\xA8\x57\x57\xFC\x41\xB6\x8F\xDD\xC3\xDE\xA1\x39\x62\x8C\x6D\xED\xAD\xA5\x4E\xBD\x13\x74\xD7\x10\x85\x47\x97\x91\x9D\x93\x78\xB7\xBD\x68\xDF\x18\x2C\x75\x15\x30\x5A\xDA\xC7\x21\xE0\x4C\xAB\x33\x3D\x88\xCD\x9F\x00\x56\xE1\x45\x04\x11\x21\x57\xCC\x90\x14\x02\x2A\x5A\x17\x21\x8A\x8A\x12\x42\x60\x68\x6C\x1B\x8B\x7D\x63\x5C\xAD\xEE\x49\x3F\xB6\x09\xDF\x28\xC9\x03\xF3\x64\x1E\x09\x84\xBE\x07\x21\x92\x2A\x22\x3D\x78\xE8\xC3\x8D\x54\xA9\x19\x1F\xEB\x6C\x3E\x2D\xC0\xF5\x50\xF3\xB0\x55\x44\x61\x7B\x06\x9A\x11\x69\x11\x91\xEB\xC9\xD0\xBF\xBB\x80\xAA\x72\xDB\xF6\x30\x5B\xDB\xDB\xDE\x5C\x2B\xFC\xD8\x3C\xC9\xD8\x42\x3D\xE7\xF3\xC3\x10\x8A\x5D\x41\x25\xB7\xA3\xAB\x1F\xE3\xB1\x8D\x05\x88\xEF\x6F\x1D\x1A\x4D\x11\xB9\x62\x68\x3A\xDA\x44\x14\x77\xE5\xD6\x22\xA2\xCA\x3C\xC3\xDC\x88\xC3\x29\x01\xE1\xBE\x79\xC2\x7D\x0B\x78\xA4\x5E\x0C\x24\xBF\xBB\x7B\x14\xC2\x40\x57\x3F\x91\x7D\x9D\xB8\xA9\x31\x20\x22\x7B\xDC\xA1\x2E\xC2\x57\x45\x68\x56\xD7\x3C\x22\xE0\x8E\x8A\x52\x18\xC8\x00\x82\x48\x7D\xAC\xA0\xB0\x60\x23\xB8\x3B\xFD\x5C\xAA\xC3\xDF\x3B\x4F\xB8\xB7\x0E\xDF\xFE\xF4\xED\x5D\xC7\x81\x4B\xB6\xFB\xF8\x80\xE1\x4E\x47\x4A\x80\x09\xFD\x0A\xA4\x44\xE4\x02\xE0\x29\x11\x92\xD3\xC6\x61\xBB\x88\x45\x1B\xC5\x3D\x32\x30\x7A\x86\x30\x5A\x4F\x9B\xB4\xE5\xD2\xA2\x1A\xFE\xEE\xD7\xD3\xB7\xA1\x80\x17\x46\x66\x22\xAB\xF3\xCB\x9A\x7D\x74\xA8\x42\xE8\xB2\x6E\xFF\x7A\xBF\x74\xF5\x03\xD0\x3F\xCE\x6F\x3C\xF0\x2E\xC7\x0A\x09\x1A\x72\x48\xC8\x81\x34\x9B\x16\x70\x23\xB7\xA3\x65\xE1\x6A\xA4\x27\x6E\x30\x5E\xE8\x98\xE4\x05\xDC\x03\xBC\xB6\xBE\x00\x11\x16\x81\xED\x9D\xFE\x9A\x19\x99\x24\xA5\x8B\x4A\x34\x7A\xBB\xF8\xBD\x2F\x8F\x0C\xE4\xF9\x69\x65\x27\x88\x70\x2C\x3F\x87\x42\x8B\x08\x07\x2B\x77\xDC\xE4\x0D\x11\xD5\xC6\x6F\x5A\x44\x38\x88\xDC\xEA\x7C\x4E\x4A\x80\xAA\x4E\xE3\x9E\x16\x10\x1D\xD5\xF4\xCE\x63\x71\x39\xD2\xDF\x93\x69\xF3\xC5\x62\x16\xB6\xE5\x91\xC6\xF5\x6F\x54\xEF\x41\x44\x38\x9A\xBB\xD9\x2E\xA2\x36\x87\x7B\x0D\x91\x16\x0C\x77\xB0\xEA\x1A\x7D\xBB\x88\x2B\x29\xDE\x4E\x47\x40\xCE\xAB\xD6\x67\x94\xD6\x32\x5F\xB2\x94\x4F\x55\xB9\x32\x57\x21\xA8\x92\x84\x40\x12\x02\xBE\x2D\x8F\x37\xE0\x5B\x05\x9F\x8B\xBB\x38\x5D\xD9\x81\xC5\x32\x1E\xCB\xE0\x35\xAC\x7C\x19\x62\x05\xF7\x8E\x77\x96\xB8\xD0\x04\x6E\xAB\x40\x26\x36\x14\x20\x2A\xFF\xA9\x8D\x87\xB7\x96\x5B\x8B\x35\x92\xA0\xA9\x52\xA9\x39\x57\x6F\x57\xC9\x24\x81\x58\xCC\x11\x8B\xD9\x55\xF8\xCE\x88\x9D\xB3\xDD\x9C\xA9\x0D\x61\xB1\x4C\x5C\x7A\x17\xAF\xCE\xE1\x56\x4E\x89\xF0\x6A\xEB\x16\xA3\x45\x84\xF3\xE3\x4E\xDE\x54\x0A\x25\x09\xA7\xDC\xD3\xA3\x72\xB9\x62\x94\xAB\x4E\x4F\x3E\x9D\xEF\x17\x67\x4A\xE4\x76\x16\x28\xF4\x26\x6D\xF0\xD2\x65\x70\x9F\xF3\x3D\xD4\x56\x16\x38\x5A\x7A\x0B\xD1\xB5\xD4\x13\xC0\x03\x88\x95\xF1\xDA\x6D\xD0\x2C\xA2\x4D\xBC\x46\x1E\x99\xBC\xDE\xD9\x5E\xEA\x11\x57\x5F\x7D\xFC\x74\x08\xFA\x7E\x08\x4A\x5B\x51\x65\x6A\xB6\xBC\x9A\x2A\xAD\xA5\x32\x98\xE7\xEC\x92\x33\xB3\x54\x5B\x15\x20\x4A\x2A\x02\xEE\x30\xB3\x7C\x8B\x97\x6F\x28\xDF\xAE\x8C\xE3\x56\xC1\x63\xB9\x5E\x37\x22\x61\xCB\xE7\xC1\x9A\xBE\xD6\xD4\xF2\x4B\x3C\x7C\x74\xE3\x08\x80\x78\x08\x3F\xF8\x47\x90\x3F\xEE\x3C\x73\x63\xA9\xCA\x72\xD9\xD8\xD6\xB3\x76\xDB\x72\x5F\x96\x72\x7F\x16\x05\xDE\xB9\x55\xE5\x5A\xC9\xD8\xB3\x2D\xC3\xF6\xDE\x40\x4F\x10\xDC\x8D\x4A\xAD\xCA\xFC\xCA\x0A\xD7\xCB\xF3\xAC\x78\x0D\x51\xE5\x35\xDB\x8F\x54\x85\xCF\x67\x2E\xAC\x21\xC6\xDB\xF8\xCA\x65\x44\xB3\x2D\x2B\x10\xF5\x48\x08\xAF\x88\xA4\x3F\x45\x76\x7F\xA5\x32\x3D\x91\x64\xE4\x8F\xE8\xF2\xE1\x6A\xE2\x83\x25\x0E\xEF\x1F\x20\x9B\x28\x0B\xBD\x09\xA5\xBE\x0C\x2A\x6B\x3D\xBE\x1C\x9D\x8B\xB7\xAB\xBC\xB7\x50\x43\x14\xB2\x99\x0B\x48\x50\x44\xEB\x45\x5B\x16\x8D\xD7\xFC\x00\x44\xE1\xF3\x9C\xAF\x8F\x81\xA5\x73\x2D\xD8\xAD\xCB\x28\x65\xC9\xC8\x37\xBA\xA1\x76\x5D\x82\x3E\xF8\xFB\x8F\x5E\x4E\x82\x7E\x2B\x95\x46\x41\xA9\x46\xE7\xED\xA9\x45\x16\x7A\x12\x96\x3A\xE0\xD7\xD2\xA7\x7B\x0A\x75\xB3\xEF\xF1\x10\xDF\x89\xE3\xD8\xFC\x8F\xB1\xEA\x7C\x4B\x4A\x55\xF0\x58\x69\xA6\xD3\x37\xE5\xC0\xEB\x97\x37\x2D\x00\x20\x17\xE3\x57\x92\x10\xAE\x77\xCB\xF9\x2B\xF9\x2C\x3F\x2A\x19\x35\x63\x5D\xF8\xE6\x46\x70\x3D\xAB\x79\xE4\xAF\x6E\x0D\x70\xA2\xB4\xBF\x05\xBC\x4D\xC4\x0D\xAD\xAC\x7C\xF5\x4E\xF7\xA7\xA7\x94\x86\xCD\xFE\xF4\x5B\xA5\xDD\xC7\x9E\xBB\x18\x54\xBE\x10\x54\x68\x96\xC5\xC1\x3C\x0B\x83\x79\xAA\x06\x37\xCB\x91\xFE\x42\x20\x9F\xD1\xAE\xF0\xAA\x82\x70\xAE\xEE\x6F\xBC\x57\xB4\x1E\x2F\xD6\xCA\x4C\xDC\xBA\xCC\x72\xAC\xF0\xA6\x0C\x53\x71\xE5\xB0\x5C\x5A\x83\x10\x41\xC4\xBF\x14\x0E\xBD\x79\x76\xCB\x02\x00\x66\xCF\xBC\xF4\xF6\x9E\x63\xCF\xEF\x0E\xAA\x87\x54\x95\x5B\xFD\x39\x6E\x0F\xE4\x56\x67\x99\x88\x70\x6D\xD9\x28\x45\x28\xE6\x94\x6C\x46\xDA\xE1\x15\xF0\xB4\x80\x95\x58\xE1\xBD\x85\x6B\x5C\x5A\xBA\x4E\xC4\x56\xCF\xFD\x4C\x46\x1A\x22\xDE\xAF\xF3\x23\x27\x33\x47\x2E\xFE\xC5\x7A\x8C\x1B\x7E\x17\xD9\x3F\x3D\xF9\xC2\xBB\xF7\xFF\xEA\x03\x37\x7B\xF5\x53\xB7\x8A\xC9\x2A\x58\x6B\xCA\xDC\x28\x45\xE6\xCA\x46\x5F\x3E\x30\xD4\x1B\x18\x2C\x24\xE4\x33\xD0\x13\x20\xBA\x51\x8D\x35\x2A\xD1\x59\xA8\x96\x98\xAF\x95\x58\x8E\xD5\x7A\x1B\x41\xE9\x7C\x2D\x7F\x45\x8E\x20\x2E\x7C\xD9\xFE\xE3\x5F\x33\xD5\xD9\x3F\xDC\x88\x6F\x53\x5F\xA7\x77\x1E\x7F\xAB\x58\x2E\xE6\xFE\x49\x55\x3E\xDB\x09\x2F\x42\x4B\xFA\x08\xAA\xB4\x44\x40\x08\xFA\xA7\xF5\x73\x8D\x99\x48\xB5\x39\x23\x49\xFB\xEC\xA4\xB2\x7A\x5C\xD4\xEA\xEB\x2F\xC6\x7F\xFF\xAD\x2F\x3C\x71\x6A\x71\x23\xB6\x4D\x7D\x9D\x9E\x3D\xFE\xF0\xE2\xFC\xE2\xD4\xE7\x24\xF0\x37\x5B\x81\xEF\xB6\x12\x6F\x64\x82\x7C\x23\xC4\xDC\xA7\x37\x03\x5F\xBF\x7E\x8B\xB6\xF3\xAF\x2F\xFE\x36\x41\x4E\x88\x30\xB4\x11\xBC\xAA\x80\x7D\x6D\x53\x11\x10\x95\x1B\x2A\xF2\xE5\x37\x3E\xF1\xF5\x7F\xD9\x0A\xCF\x96\xFB\x68\xF6\xC5\xB1\x7F\xCE\x65\xC3\x01\x55\x3D\x29\x2A\xE5\xF5\xE0\x9B\xDB\xE9\x0D\xAC\x0C\x9C\x8C\xB5\xEC\xFE\xAD\xC2\xC3\xFF\xF0\x4F\xBE\x91\x97\xA7\x86\xC5\xFD\x0F\x40\xBF\xA8\x2A\xA3\x9D\xF0\x22\x82\x55\x8F\xDF\x21\x02\x5C\xD2\x44\x5F\xAD\x06\x3D\x31\xF9\xA9\x3F\x9F\xFE\x45\x19\x7E\x29\x7F\xB3\x72\xDC\x75\x6C\xDF\xCC\x21\x11\xFF\x38\x41\x0E\xAA\xC8\x01\x11\x19\x16\xF5\xFE\x58\xFE\x6A\x4D\x54\x97\x44\x65\x8A\xA0\x17\x54\xE4\x4C\x92\x24\xA7\xDE\x7A\xEA\x2F\xCF\x22\x2D\xFB\x86\xBB\x76\xD7\xEE\xDA\x2F\x64\xFF\x0D\xB3\xFD\xCF\x34\x8B\x75\x5E\xF4\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82'
		local font85 = '7])#######Md=es\'/###[),##1xL$#Q6>##e@;*>?Qex1`3Xc2kA\'o/fY;99\'B+.#B)m<-@A^01qZn42EC=R6`.>>#I@^01aNV=B;)I0od7YY#uY,11<2XGHU=.@#lG:;$FlK8/d_(*Hlme+M%FYc278Bk0#-0%J=?k_UHRUV$o;jT///d<B\'hvQW<r.>-b@pV-TT$=(s\'eg#=>9C-VqEn/<_[FH5)w$#R*m<-D*.m/)2JuBEw2u??5v5M-//5Fn2#/#6@E-Zfq.nLcLNDFeF2t^j1m1#HYoiLU_g6GR)orLn2s##LP\'F.Ff;^M>b-##8tt&\'Fhe<6:Ht]#u@58.=<xoghBw#mLevuu.HUn#N3-&M[bm##>-Lt:EE,WebMcf1G$i--#D\')NgmH&#kh\'m9$_Lm9*_wr$8OL^#$,>>#sn&W74xD_&OG:;$X*.;Ql_o6*NT[fCuK1m9+.Vp.2h[%#?I]6E$2ffL5D,s-:pwFM<EYD3.,<6CpYw:#_jA`ah`cf17ZEM97@cA#2o&i#k7?>#EGMJ(+hX]YR;:2Lwos#v^X/&v#,###FLV2M1M#<-6q.>-?XT;-ITiiLv=lCNjCZY#P-4F7\'nS2LMlw+M;p)*M_VjfLKI(DN2c7`aR:@`a^#9.$S?mxu.]]F-KWs#0P3w,vf[/&v#*tnLoU@`aT]Uk+$A=gL\'MZY#S1b(NgcBK-3NvD-0V4C.*%4A#%R5:;.NPF%PHfkXi;#:;I/5##KG?.m*6(FIwsHwT?e:#vw%###\'S5s-nlRfLP:$##p6FGMm8#&#R[CxLZLH##5be6/GKR:v1XA(M79$##e7s9)B?=_/_uK##.GY##2Sl##6`($#:l:$#>xL$#B.`$#F:r$#JF.%#NR@%#R_R%#Vke%#Zww%#_-4&#c9F&#gEX&#kQk&#o^\'\'#sj9\'#wvK\'#%-_\'#)9q\'#-E-(#1Q?(#5^Q(#9jd(#=vv(#A,3)#E8E)#IDW)#MPj)#Q]&*#Ui8*#1crmL.WZ##wbb?T1vjo7=gh$\'$MbA#OS(?%4Q/@#@oBo-\'C<L#6t`0#SUu>#Y\'9M#9i+u#w:o1$`7a%$YwQO$of0F$9C:r$5(3d$]]i4%iLH(%@`;<%Sq]E%q+]l%kYB^%_C\'#&RF]9&kAEl&*un-\'&[hr&$KR%\'$_F6\'C/`G\'FSiO\'I\'YY\'Lj?o\':[BF(gKx9(%]Kb(]hg\')Q1D4)K&[8)[xWA)j15##09R/6i(),#-Mc##Y@2##HJ8K%G(7B3hq^`jmb%Z#\'fX&#rax6*7fx6*`Hbs$f&:;]G]eF3V$nO(]ax9.E\';sC4x(cuj+CD3w45w$9DH%bguC`a9PSj0S-4&#.jd(#d,>>#ZO1x5OZ\'u$ZVd8/)$fF4R#s\'4P4vr-;`tw5?3lD#XMc7*6#Ui)6gE.3Z_[@#fCb6&n/)ZuOluN\'Bobs&i_gi#7+W*%Hr^B%gqk:&mpN?M;<Ilfbm_&PK-kT%ZR`e$%=4C&(_s)%%1]jLX]WV$-^tF`GUk7eUi8>,v)BJ1Xn$##6/QA#*r+gLd^xD*L@[s$tPYx69?RF4PDRv$X_EG%Dl*x\'`\'6(Q`cEc<<5Wk\'II3LDdv2k\'CPl.)A]<F3a&<;R>\'wC#VB$pKHHKW7L_p]$xDF:Ks9[eur4Cw-BXbRMO=qKMvxuOMRR?>#>)A>,ws_iBx,3(#Av.l\'[cZ_#aY?C#[HSP/W>uD4R`>lLD5M.2m<2W$Zg6d)hDMs$l])mJ?@g*%@/Q,*JaiX-Blx7*YbPg1;>uu#IOxUd,Bo._Uh`i0Vh$##`bLs-;va.3Y?]s$;Go_4twC.3ig\'u$&Pto7rLd&4x?7f3x8Qv$a&SF48u_qQ996DfT=Pw$`W49%]8;4\'ro%L(g;vn&KR[x,wkR8/EN]a+ISg\'/1b5]7Tj#;%PHT6&]Z>3\'bClZ,R9,n&O;%1(u8X?6=vkZ-lPwTMOFZY#WS#]k^EKcVV4lr-Zg>A4t(4I)YEo8%8>%&4+J,G46FVt-/,698sP9T7q+gY,d;v3\'e?)Q&ObHXJ;K\'E<7h3I)nL3GVCRMZuMSKU%X4*p%IXD%&4F=@$s=Id%`c`W%?39A=M[wo%<Mfo7v0Un\'JC$##<IcI)PEZd32-Nm.$-;o0m+a+&j5g88Ta45TYoxB#+XZ(+#0?n&Sb;mL$ScS.A$g._tu.>-^K9o/]t+#+V[/n&Q0]Y-^&h-mtt;##SI\'&+D1$##,grk\'&VW/23ekD#EtN*IvfB.*1W$E3*N,98)NWD#Gc]#,ThY/CV3.b>?H=GJq$=9%u&v3;ah$gL(p6;%@Bj8&O<Qn*b&38:AP4gL(Pj0E\';G##Zw>V#0C)4#Q3=&#<Ja)#T.,jLssfF4k&B.*[*\'u$:]sx\'MbYR*W*ZR*7]sx\'d[*T%7o$s$wIO]u._@6//mjp%c]-6M@4/GV;(ApA/dj/MDD#W-dl-`&AZ59%nv@jLH46>#PAMG[&6+#(.gIkXs)eR*[%`AP[p7S[)i@W@;:@W$ie#W-qScDS:=(?%R%)@0vOkxuNOup71f-g)AD-wPLQm<-krsv%**KGW$pBq7O4l%l>n`ca.ikA#W_+%&O&A^HTC$##%&>uuiA3L#`XI%#((;YPc(YD#x3YD#w:H>#XmgM\'s3vr-(g&W&6Y79%fkn9%>-h(*f-W@#]*>F)knd6O;<34\':h[(<$8=rZBQ7iL+x`^%Kc`$\'w6$`48tFA#lL*L>e?85/85xD*RtC.3[5ZA#xflMri:3D#HC+[.e,_6&&VgQ&Z^(99AE&2B6L_X%g,16&n%:bQ`CYE9osC0(5Q([,0`%C#jkW999f5gLXX:T7BA$vLT/6uu7-B&5[/T,365qKG/`OcMHt@C#IV/)*W<7f33i4sL2mmhMpSl]##<(C&6jE.3wb7F40/3-)PEkx#uX>J&@kgsL$MEs%OLit-,4>gLgVv/(S53E*L)7\'42b?W&CH@T*$BIe)Gsi`\'jE^2\'&K`t(uVX9[7q7T%l^:0(pj)B(k`tT[N=S%#\'&>uu\'b/E#qqm(#SoA*#TkP]4)>WD#W*1T&/M0+*CdA=%_wkj1#&;9/[7%s$x)Qv$o+Q-3[cJD*-V&E#;Z^k93V]=%F%r8.,grk\'dx+G4Mn24%a#=w91ACW-DQ?=La<]j0hOLs-F_nS%Hkjp%[ljE*Fqew#H%iv#cg\'[7_k7NWPbcE#g`]#,JaId)[#?3\';YB@%<.aC&2@aN=DEgq%%J8L(#FGN\'jkCw,lRE5&bOml/iF\'NBRx((93YZd)b5f;%qx8;-j%$a2X4>>#=;F&#N;+G4v:^Y,bv./08bUa4?a2@$57fT%de75/r#W)\'fRgO;r1<=.Pw<p%dqh[,q;T&,>q7?#*K:3\'7m#p%)g*61qX8V%9r8,31d24\';l1s\'/lIH%C>Jb-f5a9D>O,/L^N78.84,876a=T82$.m0`9Ss-wHil87=P)4G-LB-<bH29eYpJ)f;)B\'JM/)*TvtxFC_39%\'5h;-2jsv5iU>7;J+1=//qDJ)H*.%,3nx9.72M3&ZTXp%djDC&u7v?0sMJOE=\'oK)DmPO0uXk0(8)Lm\'k@\'eZI-2BZn9+o9-gG,*6x_caIlplT[Ec-Qb[1_#np$cr^qcxO5kS\'Jnm7f30sxiLuoYA#^nr?#8ekD#<G[Z$grKp7B6V>78QW@,==D?#Z?_a<7)\'Y&8iNE&%NtM&H.)Zu(;OR/V&q6&(,Rn&QVhJ)P5pp&UcgZP3L>;)N####vc+:vc>*L#UC>d$jEOA#he#T/?TMm$U/_p.F?uD#p>kKPO<>`#SdL;$K%v>uU4@H)&2Z/$*tH)4o>)^u4u?%-:7fCWb-A<$[;Vo&T+>J&_^0q%a8[%-efH988K[A5IoW:,s3Wj&k,W]+3HSs7YDlA#9KB5)grc>eikH##B;eS##*Y6#gk\'hL+Fr2:($_>$jFm;-Z-Kg1::tD#DMn;%*vZ]4f[I>:$o0B>(f>C+t4de$I<Qg(<4I\'PoN1K(YZ`::=rcG*Mk\'i#%\'5<$RjwF4ERR8%M####xwP50IG;F47@&s$$d(T/b.i?#Mu6:R$Y^L$@I@<$1h\'?$@1r;$FveYLGhxP&6lhV$S,1I$_II<$3s[fLMUQu#ZB*1#b2h\'#u^M3VfRDU8i-$Z$F+i;-43n#)IXIh&o:SW?ZkuN\':1[`<*aWE*@OTk1];;o&Kn+A\'.eF^&D37o[NYRW?+VRD&IW4d.4j;K*%@Yp#mXx5#[d0\'#E8F@R3_P^,Enn8%9G@A4%v.&4(xkj1$V/)*V*d8/]X\':)S48C#IPvG*ID$]03U[LM.j7h%og,s8ki8H)]:LW-,0ai2O&RH)UI9t%Duh;$l=ol\'l>qq%MW^U%1T8(+nG7H)O&[d)4;^;-Nq6k%>*EQK^n-w$QNbX$=PAX/BR0Z$eLEAbKAWu$Ls$-)0Yn21XC^p&REFX$/wUr&]n5q&RGn-)otbq&RNbt$(AEg1B(8YcPRDM0p7A(4K1$m8kvY-3wc``3/W8f3:\'PA#$b9N9[5MG)82dA#/(0\'5-5Oo7Nnbr/E)0F*f[)C,i0>j\'@7_T7O@.##[(T5\'wwU<-KJ[n&<vE1)QNdY%;v=>-B+\'9&nCJfL&%pwu-$<c8[x9L3<q\'a#aIcI),mh`3kbf88@=/\'PO*]S%K,F>H1xO]uZu6^4$,>>#`xY=l+X4GV@%$##1UZd3w0`.35rZs-Wne0:nkL*4J@i?#k$x8%.KUhLexe)*ID0$Hf]V8&k^1H)sATU)]X&.*V8$TIr3XN\'[`xu,1;)>P57<H*mM],M8+8x,H0>$.uX]L(ECI>#-ONE-h4ja-$XL$B=-*/M0#nXlOG=kb0GR7n+4<MTI:[/)tARI/Fe75/:9\',;n<BZ-8l`(a3P;.ZYf1BSq-;\'7wYs[tj)%)NH)UP&jNai0OLvP/u$:C4a?T:%L7&-<hw4(-#4L+*`Ome4vcU:%/E@s&j<4m&70W@$B4o;Q&M7)&i,lp%Ajmp%(]`C&cWDO+Jmpw#iH[-\'7HuD3x[;<Hpf:(&p<fp%^BBa<_qt,2G6w<(3YX<U-#;3rT_d##D(m<-Z5Sn$1IE:.oBpTVh%AA48>F$%#i.(62U@#:Uj=vGW\'3)%/TEt&>N&r0En*IH%]]q)#QU<H\'LxT.>=#+#(+Bk$mEZd3-OS,*9`:5/B.i?#Z+hkL^0#V/w^v)4P:.6/DUcI)g7+gLP]XjL<[tD#4Le;-`DL[-Abln*gO&9.o;d31lqkd?:mi,)1xqv#M\'S@#I5,j)@ekX$<Usl&n,0+EZ?W8&_g)B#X;rsLbj^VKs:(X%lcZr%37(x5k2S$9O/mX$EWUg(_/20(Z+K>-%Z&03\'>cuu%8YY#P*[0#FVs)#YaqpL>U-1M&OrB#l5MG)*Dei$UekD#X7KgL.`,c4CY@C#g3YD#,]0v56W8x,r<;W-O9ki0SBo8%q>Ib3#C7f30d%H)nGSF4nGUv-[YWI)ue0h2&iv8%6C3p%qre-)q(J-)X##+%E\'d**I17s$n%f;6kRl_+L9N*.#SiZukh,##dG.P\'Y>l@5CbjP&U(1s-e$8@#N^[h(bYR1(>k/Q&A-5/(SmGr%Fvfe*6lJ-)x*?h>nr24\'_GnI2ulWa*ln9n\'+C36/](o*3/K7L(.O1v#^_-X-,Be61#5\'F*9oUv#)Auu#XLVS%)=*L#A,^*#=aX.#mp@.*&@*Q/*W8f3<U/[#,eAj0V::8.6iZx6S4-J*CANBomuYD4v2(H*n0ldtHx6%-B#mG;8;;H*rHRF4#$650WH5<.vu/+*^l-F%pVGq;c7%s$*C&s$:\'ihL`DN`#O8@F#%RL1;5S>C+@_oi\'\')539\'?@F#`FC.*stq<-,kuN\'u/:\'-q.;?%7<9a<ujJ7/;JT0MTW]L=BNX4SiYh&=p?j20*SN/2G<At#0XFT%au6s$FI@w#kr2x-oU-##%b$M;4UD%6B0^30,0mj\']*JI4LhR>#eu.P\'nT8n/dNl/(f3E6/n?^6&=2&_4+N[f)>k>F#fa:L;vM(&=AUwS%4)qG=WXtJ2R,U\'#$&5uu0(YS7Gt^`*G:$##w+m]#uF]fLl-F<%:q\'E#qI[%-$V/)*t:3T%?^WI)R3*7BI&_W7dv@)GjnBH)Ym=]#jPE>/Bqmk\'IXEp%9AalA&>dF+H5P?6L#;Q&jbv@&LBHT0:YtH)DONp%4SYY#$D%6/Ni8*#_Uef;qF)L)@f)T/_2qB#FkRP/T9D9/wHeF4KG>c49x*<7o:gF4`V>s-dsNfM=xcG*oIQp.-)b.3$pvC#7NQ51SQ^6&CjMH2N[@:.*Ks@??fo/16QbN9ss4O0<K<T\'+<UN\'X9GO0G(;Zu2We5&b*p$.up10(;GUG+*8=M(nqWN0mPX9\';$/$PDD\'0M$R@0)%L/X$[1cM?t7?5/s(7G;Bw0\'#c&kl/KWLfLaEq,3+$lk0;CI8%8YPs-[$UfLTF4jLj:C%6E+]]4di/gL0KPA#&j$@\'eOEe-[M5Q\'9ulhM5t[JMd1kb3MUX,21e4n&u->.<<P+q&MQfZ,5\'/T&a1\'%\'p7m<7oS-n&mKd51Nde%\'3Pk.)_QB(M-eg-<t[Oo36p.5^[0t\'8%`Oh5hs9-mM5P:vP?b%b6Ih=.DX,87kN%##Vapi\'cQ+,2W_d5//Yd8.dC587&8J$-R+h.*`69u$r%<X(I;gF4?DXI)^4K+*x3vr-VWCl:Bc$C#=kCv#FRwW$WCd2\'*4$?$,@.JQnLqJ-kBX/>re;Z#h&#b%HPoVM9F*UMTtMv#*wHiL,0>&@`2Gb%Fx>29:E2I2$?&#.$Us-4U$.C+UZg6&2/l8&Q;a&#(7I@@S_d##qw^4./crmLMVd8/_&mM)ZsFA#0Zc8/:QD<%x,Tv-G7[=7ih^F*6IYj1KY.<7A3YD#c_e6/dGh_,u6>GMVv)a40x&>.r<RP/7)5\',G(*DF.Oe`%g%j#$`>I-)$G]907,*ZuAZw8%gtku%VmI(+H2s]+Rh;r7&pVW%c7S:+*i)w-J(YR\'Cu&I6R4eo/sHTK(bj*.)(4-3LZ224\'sOof/X^O0_NkiZ#$,D6&4O82\'eHEa.(RYJ(&T[kgvF.H+XPYi9lBT;..B9<-j#:D&\'^p;->RU`$S8/(>h35dN%\'2$5575+%nKs;-e]MX-oU=_A3puXl2tOcVQiou,^?W:.MN>m/Rq@.*dZ\'u$bJPD%^=Ip.Dh+%,0E9I$\'9PF%J4X#-.f4GMT4/cV]:q0MM+d<-;\'FK48A6`a<G?`a;\'GJ(;NHD*W_d5/`UW`<i0wC#[=fOo^]%@#%apf\'$-mK5iNj?#Bx37/MHPn&BbjjL>ID=-Tlk*>4N%a+o8o6W[jp5/h=K,3nM#lLtGGA#L,/;M;9rx0+s$C#B4;ZuuL.GVg3%dM1T7U.V5/$5_eHG>l&=#-HW4<-b@)*%Bv:9/d>6$6urGA#atr?#&_va$lx*iHa:nJ#:YDm&F-%w%/%Lp7WLO]uh.2i15D6t63*?(\'J1F=%)FPgLa`ZY#K1*]b*ag(a?bfZ$sq[s$aY?C#YlWI)lm6[Bkxt/M]k<9/i7Yd34qVa4;(]%-rFg+415-J*nG.)*H%T,M9OU:%0p<06n.$w#iW4T%?>Ns%h6ss-xdos$ge3p%(f`M0@3Es%aq7Y-[[U4+_HSs$M]%12sGCI$=OX<%df;o&me&m&mv^d2d#u=$<0Qu%wp<U.EE[h,G/L=QuHA<$ZL+N1N<+22jG:;$YfY=lr%.GV8f3>5Z2Xf:ggN^,,wrR+iK(E#L>e,tm5c=$#@&a4@xq;-;b7U.%jA%,*-6a&5KA&,,kJj0j,24\'$xPR&ptdYuT<+.)1PwC#Ub<5&cc>w#qL3=(@<]8.L9r/)p:.\'&XZbq.<a$?$+ek>-UbKv-h&i05*CHr@,7>N\'36VT.%5YY#(DNfL]:^0#^d0\'#&dTv-d(4I)kHL,3wc``3B4vr-dtC.3s7Ul%*[8W-/?Pu](UZF\'BpqA\'8Zo[)o?/[u0pCp.?f69%RbUe-\'#_#?>\'DJ)l#oU.mFgJ)`Bf72?t3xu1g9B#\'H.%#D%AA4E#@^,\'7)/:U0:kFxba=.^GB:%H(@8%6.5I$=8`$\'9VT2g,CWt(Boat(>wZ;%M;3;;xH]s$8fcj16HSP/^Z:I?r<J@#?tBC-Lilt86,dG*jm06/nce1213)hLVLs?#`M.)*gmg20#[2n&<,$6SR6g*%ptV[&dQk5/lr3e&)Lu,M:S5W-jFRAIb9W$#CQdD-vEH&%M.lI)r37+45+gm0(kC)N-^+>/EN]a+m6UH2C=@W$LxgDNR(=\'MND$8/-gbQ&kJw8%4k#x^(L@M9VB\')3ig\'u$C]R_#=qj7%8jE.3TDj?BG?,na_w6u6-E1l:0xoG3w3Tgsia+,%lsRF4K)^/LdB]@#gYgu:P,\'F*lKfN0>jD+=Dn8@#wrdN\'EUrV$)G6,EAgxkE0uBX%L[<9%cK,m:TxA5=+DAL(tgJ@#Q1iB78(Gj\':4P@5Xd52*q:npIDu(v#kI?b>],kI,>nSm&pEEm/jMRiuO^C/)@bL/)9),##kw>V#aC)4#-\'Vl-93$4ixVwZ?8&[#6<TIg)rXd+u-GrB#ANU1;#ki-*[*\'u$($_O-C_39%l?^;-pMcpRhIblA5Zs>&GiI-?>abA#-oYGMu;gL:bc9N(nN*20KUNK)55%&4Z&:I$(%x[-&8b5A0;nw\'*0F6jSNCD3U+BJ)u\'nofu1>;-E$V0,PE;61LG+t&hC5Y#or3R/uV?L2Y[3VR`Uo&,Jgma3+_AG2\'&>uuARl>#SN7%#6&*)#)$B?&qP[]4wj`a4G+^C4D2$w-YpVa4Bl$],Soxu,E\'Yt(jtn8%>B940NT^:%PEZd3gtONDlr1jr#4l:&)KqV(5P3(7Z]hQEWFFb3:?)G#,\'Vw.\'=.g:n7X_$Oj?H)(Jb.)?$Ym&cAJu.XfrS)bDVO\'6^`S&xt#I6G,OL)Z8MsA5GeT%kiLA=fR:J)@Le<$^&hg:VF6T.PEHR&r2Z(-LXnq.9&.Qkfx5Q\'mFbGM2KO[7=-&v#5FNP&K&@D*@%$##0G2T/aw(a4N$s8.CeL+*u*mV-vc(T/HD]=%7hJrmXR`N2Bn)K9IHVQC`vcV$/.g`*^Hc>##b[Nj?1dcaxcAG2ED:v#$v4uu,7958%P:v#qx8;-8r+G-7(c(.M5^l8bj(9/vf%&4n0Yo&(:k=.Y((*>)9Bj0nJn_>?#-eQPH^@#CG0H);l%n&>%\'I,7&$9%V3=MCK:lgLL0W=-YZ+Z-L[t05@<A?Pv-8u-lRPM9:]R&,-qAAeAO4s%Zrk@?*%gG3*55p\'TaeC#-^v7A0LPN\'^]/B+u5+%,/<#LQ]e/GV1^[N8u<CH2&t@E+jwu0Lo=_Y(o:%?7QO?>#PPViK4E0A=LKu`4aeO,2S(Ls-22\'9%mTgU%L=Zd)5*j<%oQl)*E`j)*/bY,M.R@T.&`X]u)Jg9;hO/2\'/`]+r#I187[9AVHKG\'##8=Nc+NqR*5;\'&i)(??A4AaAf3$fNT/+kRP/oGUv-Nki?#_Qo8%l(KF*97#`4oo/f)+2pb4$,]]477DB%P5#l9PO-C#-duJ(5+7X-D45@5c@nM05kJ30kh6X-7X=5T?1^P\'4F4g1=QWh)C6ihL#[Z(+bvZ;)?m(q<rTF+5?S39/st+E&QN)R\'W^Kq%oHpM\'oN/7/Wjpq%QDbl($=cgLJ6GhUhv[).Jki%,PP?w-hTBq%B0ZA4hXP_+OaFm\'UsX-H6]aOD`CT8/dtU2B,11V&b6ai0Vh$##bl@d)^^D.3FH7l1\'/dt$p&A+4@vTs-l9]c;cD^v-wHeF4Dk:B#&SwvK(mL5/+ugfQ0t.\'M4.VH2r^?3:*+l.)eBA@#6V`iL^2oiLvN2DfxvnT%K5a:M^&_m&HB+g$NW^5/%XL7#Z>?j:n@Im0G=61MJE:Z-+dfF47of1;F8`I3hbtM(ft(%,$xUC(<kuN\'KmLEMMxg6(GWrt-w,Z+Mj=CJ)*:V9..EVO\'Y;#L2?SOS7Hr.cV$lQ=l\'@N<-)fj=BU,-Z$>05L\'kcq[e$7L+*:i]1;b>qB#xmWZ%esbp%1bHgL3QN#PDxMu$E5Bm+&`,_JN8P:vHAH2\'te83C)wNlSpa:YYDth=.ue\'K2ujDE4EKeL2oP2)33`<9/F=#<.=Fn8%^Bd8/L8Hb%=Esw$9:9&$?WEI3^wn8%KOgfL3.L+*X/>H3SV>c4m7a$\'tS*C&YQiT/%.aV$7*YA#M(m<-1os#..:UhL]xSfLO[kD#BP%`&If&02:1cc-vMc6<c6;b7*VO,MwS^C4o@Qt0^B(Po35G>#M6:,)36+6\'E%`;$kwJo3L8e-)x9k5&x1nD*x-]w#;Lw8%<$JY-Q[&v1YFw8%RDL[-ouZt1:WhL1RWIv$kji\'5h2&fh\'`L,)l/tP&XN(^#S#V0(D(;?#7E5H2l138&GDG%Po&hU%N.mY#58T;-,lf87?K1;?SQF=$?XET%6f1Z#S@$p.5uZS%Sc1?#6=n8%cU<.--rTDNCRGgLhLQ>#%_Zh,)D@5&C_E?#]fGq..>piL`AlG-RkNj0kXcm\'RH;k\'1*@.MTj,d*R4p&#$,Y:vK;%N0N,>>#0k\'u$.>4gL=`d8/djfGNO@<9/sJ))3HfnU/d??GMHnRxk93Ya,c&Ip%#/VZ#A66[$esbp%fMcA#j$JT%8/H0D[Y_V$#eqv%=g/##]&m2_A3V;ZxqjT%f]am&iP?2$<:nS%&=6hGPGY##q<1R#>u<(&ZVt#n0_q%%+__&;9#gS8v*DhL<>6##:x2<-hVg_%8@=Yf@wXD#Jva.3%i:8.*/rv-@Bx(<H.Je*O8(j<?ls&l(Fn[)HO3j0^vp`?gj:b,3822:wmd#vY-Zr#wXM4#;(2t-a_L0CqSD^42,h.*dMYx6#UvA2v6hI&4S=(1BqNHEB097/9FO$0HcQJ&H:5qJI$FQ/&G&t%1LJM\'(:D>#2cWh#=EU`3/(1B#9`8MB01L^#QDQlJ-xB#$v4poS.+_>$2vIP^3LHZ$i:Hxk9t;w$1iC;$\'5>>#*dDE-asllM\'xSfLon(1NaF6##$l84N).gfLf]j6N*4pfLxg%:NWXQ##3g5=N,@,gLf%Y<#+mk.#cSq/#TH4.#HB+.#c:F&#Y#S-#S@Rm/0E-(#1K6(#RfG<-Zw\'w-2sarLo<DP8DX=gG&>.FHMeZ<0-K*.3b1RGE>@=GH#$),#U@f>-6ZlS.J0f-#rIC51[*eFH(KfUCdc$##-Srt--)trLxgipLe31A=\'DvlEL\'\'##t4)=-rX*+.VuRNM%l1X/l9]/GZ#uLF8@n]>6=h]GrdufDw^Y>-RYgJ2j<.j1ecGL24gCSC7;ZhFhXHL28-IL2Jd+tVv(+GM5N-ipgVYb%tt\'m9M=JvP\'8P>#*AY>#.Ml>#2Y(?#6f:?#:rL?#>(`?#B4r?#F@.@#JL@@#NXR@#Ree@#Vqw@#Z\'4A#_3FA#c?XA#gKkA#kW\'B#od9B#spKB#w&_B#%3qB#)?-C#-K?C#1WQC#5ddC#9pvC#=&3D#A2ED#E>WD#IJjD#MV&E#Qc8E#UoJE#`[U?%aZ8=9`iWF%WuQF%XxQF%Y%RF%Z(RF%[+RF%].RF%^1RF%_4RF%`7RF%hORF%iRRF%jURF%kXRF%3rfP9`)0g2VY#<-iIP)N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N%jv-N&iZL2tmN,3iIP)N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N&p).N\'odL2uvjG3iIP)N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N\'v2.N(umL2v)0d3iIP)N5XjI3$,>>#%;cY#Z2c\'&*tj-$$vSY,on]88T^u9)0/<X(G)###;FcA#2cWh#]Cl`k%T*1McX4Fh5L*##[w5ruM)9AtmCWYu'
		local ash_image_data = '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x02\x47\x00\x00\x02\x25\x08\x06\x00\x00\x00\xDF\x7F\x5C\xA6\x00\x00\x01\x37\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\x91\x95\x8F\xBF\x4A\xC3\x50\x14\x87\xBF\x1B\x45\xC5\xA1\x56\x08\xE2\xE0\x70\x27\x51\x50\x6C\xD5\xC1\x8C\x49\x5B\x8A\x20\x58\xAB\x43\x92\xAD\x49\x43\x95\x62\x12\x6E\xAE\x7F\xFA\x10\x8E\x6E\x1D\x5C\xDC\x7D\x02\x27\x47\xC1\x41\xF1\x09\x7C\x03\xC5\xA9\x83\x43\x84\x0C\x05\x8B\xDF\xF4\x9D\xDF\x39\x1C\xCE\x01\xA3\x62\xD7\x9D\x86\x51\x86\xF3\x58\xAB\x76\xD3\x91\xAE\xE7\xCB\xD9\x17\x66\x98\x02\x80\x4E\x98\xA5\x76\xAB\x75\x00\x10\x27\x71\xC4\x18\xDF\xEF\x08\x80\xD7\x4D\xBB\xEE\x34\xC6\xFB\x7F\x32\x1F\xA6\x4A\x03\x23\x60\xBB\x1B\x65\x21\x88\x0A\xD0\xBF\xD2\xA9\x06\x31\x04\xCC\xA0\x9F\x6A\x10\x0F\x80\xA9\x4E\xDA\x35\x10\x4F\x40\xA9\x97\xFB\x1B\x50\x0A\x72\xFF\x00\x4A\xCA\xF5\x7C\x10\x5F\x80\xD9\x73\x3D\x1F\x8C\x39\xC0\x0C\x72\x5F\x01\x4C\x1D\x5D\x6B\x80\x5A\x92\x0E\xD4\x59\xEF\x54\xCB\xAA\x65\x59\xD2\xEE\x26\x41\x24\x8F\x07\x99\x8E\xCE\x33\xB9\x1F\x87\x89\x4A\x13\xD5\xD1\x51\x17\xC8\xEF\x03\x60\x31\x1F\x6C\x37\x1D\xB9\x56\xB5\xAC\xBD\xF5\x7F\xFE\x3D\x11\xD7\xF3\x65\x6E\x9F\x47\x08\x40\x2C\x3D\x17\x59\x41\x78\xA1\x2E\x7F\x55\x18\x3B\x93\xEB\x62\xC7\x70\x19\x0E\xEF\x61\x7A\x54\x64\xBB\x37\x70\xB7\x01\x0B\xB7\x45\xB6\x5A\x85\xF2\x16\x3C\x0E\x7F\x00\xC0\xC6\x4F\xFD\xF3\x53\x3F\xC8\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x09\x12\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x36\x2E\x30\x2D\x63\x30\x30\x32\x20\x37\x39\x2E\x31\x36\x34\x34\x36\x30\x2C\x20\x32\x30\x32\x30\x2F\x30\x35\x2F\x31\x32\x2D\x31\x36\x3A\x30\x34\x3A\x31\x37\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x32\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x32\x34\x54\x31\x31\x3A\x31\x36\x3A\x34\x33\x2B\x30\x32\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x32\x34\x54\x31\x31\x3A\x31\x36\x3A\x34\x33\x2B\x30\x32\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x32\x34\x54\x31\x31\x3A\x31\x36\x3A\x34\x33\x2B\x30\x32\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x31\x31\x66\x32\x37\x37\x62\x38\x2D\x61\x33\x30\x61\x2D\x61\x63\x34\x36\x2D\x61\x63\x31\x65\x2D\x38\x66\x33\x30\x31\x32\x30\x32\x35\x31\x36\x61\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x64\x62\x65\x30\x61\x30\x61\x62\x2D\x35\x32\x37\x35\x2D\x65\x62\x34\x39\x2D\x62\x37\x33\x31\x2D\x37\x65\x36\x66\x34\x38\x32\x64\x64\x39\x34\x35\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x32\x64\x36\x62\x31\x38\x64\x61\x2D\x33\x36\x33\x63\x2D\x37\x38\x34\x61\x2D\x38\x37\x32\x63\x2D\x65\x32\x38\x65\x65\x37\x35\x38\x62\x34\x35\x38\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x32\x64\x36\x62\x31\x38\x64\x61\x2D\x33\x36\x33\x63\x2D\x37\x38\x34\x61\x2D\x38\x37\x32\x63\x2D\x65\x32\x38\x65\x65\x37\x35\x38\x62\x34\x35\x38\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x32\x34\x54\x31\x31\x3A\x31\x36\x3A\x34\x33\x2B\x30\x32\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x32\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x31\x31\x66\x32\x37\x37\x62\x38\x2D\x61\x33\x30\x61\x2D\x61\x63\x34\x36\x2D\x61\x63\x31\x65\x2D\x38\x66\x33\x30\x31\x32\x30\x32\x35\x31\x36\x61\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x32\x34\x54\x31\x31\x3A\x31\x36\x3A\x34\x33\x2B\x30\x32\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x32\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x41\x6E\x63\x65\x73\x74\x6F\x72\x73\x3E\x20\x3C\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x30\x30\x61\x34\x65\x38\x66\x62\x2D\x36\x65\x37\x37\x2D\x39\x34\x34\x30\x2D\x38\x35\x31\x30\x2D\x31\x38\x31\x33\x64\x66\x64\x34\x61\x38\x64\x38\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x30\x35\x66\x33\x38\x66\x65\x34\x2D\x37\x65\x32\x37\x2D\x63\x39\x34\x31\x2D\x39\x65\x61\x64\x2D\x38\x65\x33\x37\x37\x62\x64\x64\x37\x31\x37\x64\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x32\x66\x33\x36\x35\x35\x64\x30\x2D\x62\x37\x65\x61\x2D\x39\x31\x34\x66\x2D\x38\x62\x64\x37\x2D\x65\x34\x38\x64\x38\x33\x39\x64\x64\x62\x62\x36\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x34\x32\x32\x61\x65\x36\x35\x32\x2D\x31\x35\x66\x38\x2D\x62\x32\x34\x65\x2D\x38\x66\x31\x32\x2D\x30\x66\x35\x33\x62\x66\x65\x32\x32\x62\x63\x33\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x35\x31\x34\x34\x36\x64\x36\x38\x2D\x38\x64\x36\x38\x2D\x31\x36\x34\x39\x2D\x62\x39\x35\x37\x2D\x62\x31\x31\x38\x34\x61\x62\x37\x35\x61\x34\x32\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x37\x30\x31\x62\x39\x65\x65\x39\x2D\x62\x61\x37\x62\x2D\x37\x30\x34\x37\x2D\x62\x32\x31\x36\x2D\x64\x64\x37\x62\x38\x62\x61\x32\x33\x30\x62\x61\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x61\x39\x34\x65\x63\x38\x64\x63\x2D\x35\x34\x65\x36\x2D\x63\x37\x34\x37\x2D\x39\x66\x32\x37\x2D\x64\x61\x31\x65\x30\x66\x33\x33\x65\x66\x38\x31\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x62\x36\x34\x39\x31\x34\x32\x65\x2D\x37\x66\x34\x37\x2D\x61\x34\x34\x37\x2D\x39\x63\x34\x30\x2D\x66\x39\x38\x32\x33\x36\x31\x37\x35\x65\x32\x30\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x62\x65\x38\x62\x66\x31\x61\x61\x2D\x33\x64\x64\x65\x2D\x34\x36\x34\x32\x2D\x62\x65\x37\x61\x2D\x63\x36\x30\x61\x61\x63\x64\x64\x36\x36\x35\x64\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x64\x33\x36\x32\x32\x35\x34\x64\x2D\x65\x37\x62\x35\x2D\x64\x34\x34\x35\x2D\x39\x30\x32\x63\x2D\x65\x64\x30\x61\x38\x62\x37\x62\x39\x31\x30\x34\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x41\x6E\x63\x65\x73\x74\x6F\x72\x73\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\x80\xCE\x5C\x9D\x00\x00\x88\x4F\x49\x44\x41\x54\x78\x9C\xED\x9D\xDB\x55\x2B\x39\xD3\x86\xDF\xF9\xD7\x24\xE0\x1D\x02\x13\x82\x77\x08\x26\x04\x76\x08\x10\x02\xDC\x7C\x73\x0D\x21\xE0\x10\x70\x08\x10\x02\x0E\x01\x42\xC0\x21\xF4\x7F\xA1\xAE\x69\xB9\xDC\xAD\x53\xEB\xD0\xB6\xDF\x67\xAD\x5E\x33\x1B\xDB\x5D\x3A\x96\x4A\x25\xA9\xF4\x57\xD7\x75\x20\x84\x90\x8C\xAC\x01\x6C\xAC\x7F\x6F\x01\x1C\x1A\xA5\x85\x10\x42\xA2\xF9\x8B\xC6\x11\x21\x24\x33\x6F\x00\xEE\xFA\xFF\xFF\x06\xF0\x4F\xC3\xB4\x10\x42\x48\x34\xFF\xD7\x3A\x01\x84\x90\x8B\x62\x85\xC1\x30\x02\x8C\xD7\x88\x10\x42\xCE\x0A\x1A\x47\x84\x90\x9C\xDC\xAB\x7F\xEF\x9A\xA4\x82\x10\x42\x66\x40\xE3\x88\x10\x92\x13\xDB\x6B\xB4\x83\x59\x56\x23\x84\x90\xB3\x82\xC6\x11\x69\xCD\x3B\x80\xCE\x7A\x48\x5E\x6A\x96\xEF\xBA\x7F\x84\x8F\x8C\xEF\xD6\xF9\xB0\x9F\xC7\x8C\x72\x08\x21\x84\xC6\x11\x21\x24\x1B\xB6\xD7\xE8\x00\xEE\x37\x22\x84\x9C\x29\x34\x8E\x08\x21\xB9\xB0\xF7\x1B\x71\xAF\x11\x21\xE4\x6C\xB9\x46\xE3\xC8\x76\xC7\xBF\x37\x4E\x0B\x21\x97\xC2\x1D\xCC\x49\x35\x81\x5E\x23\x92\x0A\x97\x50\x49\x29\x82\xDB\xD6\x35\x1A\x47\x84\x90\xFC\xD8\x4B\x6A\xDF\x00\xF6\xAD\x12\x42\x08\x21\x73\xA1\x71\x44\x08\x99\x0B\x63\x1B\x11\x42\x2E\x0A\x1A\x47\x84\x90\xB9\xE8\xD8\x46\x34\x8E\x08\x21\x67\x0D\x8D\x23\x42\xC8\x5C\x74\x6C\x23\xDE\xA3\x46\x08\x39\x6B\x68\x1C\x11\x42\xE6\xA0\x63\x1B\xF1\x94\x1A\x21\xE4\xEC\xA1\x71\x44\x08\x99\x83\x8E\x6D\x44\xE3\x88\x10\x72\xF6\xFC\xED\xF9\x7C\x0D\xE0\xA6\x7F\x6C\xF6\x30\x27\x52\x78\x35\xC0\x31\x32\x8B\x5E\xA9\xBF\xEF\x91\x37\x5A\xB0\x96\xB9\xC2\xF1\xEC\x1D\x30\x03\xD5\x77\x01\xB9\x53\x6D\x42\xDA\x43\x89\x53\x4A\x37\x96\x5C\xE1\xD0\xCB\x2A\x21\xAF\x55\x3D\xD6\x96\x99\x03\x7B\xBF\x51\xEA\x5E\xA3\x35\x80\x8D\xF5\x6F\x69\xB7\x35\x96\xE7\x5C\x3A\xAE\x74\xB9\xAF\x60\xF2\x6D\xCB\xCE\x2D\x77\xAA\x5D\x49\x5F\xAD\xA5\xC3\x6F\x70\x7A\xA2\xB1\x56\x1D\x6B\x96\x50\x26\x1B\x1C\xEB\xEC\x98\xF2\xA8\xD1\x6E\x84\x96\xFD\x43\x98\x53\x56\xE9\x74\x5D\xA7\x9F\x9B\xAE\xEB\x9E\xBB\xAE\xFB\xEA\xFC\x7C\x76\x5D\x77\x3F\xF2\x0E\xDF\xF3\xAE\xDE\x13\xFB\x7B\x79\x6C\xDE\x03\xBF\x17\xC2\x26\x22\x0D\x37\x5D\xD7\xBD\x76\x5D\xF7\x13\xF0\xDE\xD7\xC8\x77\xBB\x64\x86\xD6\x51\xD7\x99\xB2\x79\xEC\xBA\x6E\x35\x43\x5E\x68\x1E\x7F\xFA\xEF\xDE\x04\xBE\x7B\xAA\x2D\xAC\xFA\x34\xFB\xF2\xF8\xD5\x75\xDD\x5D\x62\xBE\x96\x50\x8F\xA5\x65\xE6\xEA\x6B\x63\xCF\x9D\x7A\xF7\x3A\xF2\xF7\xF7\xDD\x74\xFD\xFE\x74\xA6\xFE\xA7\xF2\x61\x63\x7F\x2F\xA6\xFF\xF8\xCA\x5D\xD2\x10\xD3\x6F\x36\x8E\xF7\xD9\x3A\xEA\xD1\x21\xFF\x2B\x21\x4F\x3A\x0D\x6F\x01\xF9\xB3\x65\xC5\xEA\x06\x57\x3E\xBB\x6E\x68\xAB\xAB\x3E\x2D\x53\xBC\x76\x43\x5F\x8F\xC5\xA5\xF3\x6B\x97\x49\x68\xBD\xDF\x75\x6E\x9D\xE6\xD2\x9D\xAB\xFE\xF3\x29\x52\xDA\x6B\xED\xFE\x91\xAB\x8F\x74\x9D\xA9\xCF\x90\x71\x26\xA9\x6D\xE9\x82\x7F\x4E\x78\x49\xD7\x19\x23\x29\x46\x31\x5E\x8A\x71\x94\x52\xE8\x5D\x67\xCA\x39\x35\xCF\xA9\x32\xBB\xCE\x34\xB4\xE7\x2E\xAE\x31\xA7\xB6\x89\xAE\x0B\xCB\xE7\x58\x5B\x58\x77\xE1\x86\x9F\xF0\x1A\x20\xEB\x12\xEA\x31\x56\x66\x49\xE3\xC8\x1E\xF4\x3E\x23\x7F\xEB\x52\xF2\x36\x9F\x9D\x69\xAF\xB9\x8C\xA3\x94\x72\xFF\xE9\xC2\x0D\xF0\x10\xC5\x1F\x9B\xF7\xD0\xBC\xAD\x3B\x77\x39\xB9\xF8\xE9\xE2\x26\xBA\x21\xC6\xD1\xBA\x0B\x33\x46\x3E\xBB\x72\xC6\x51\xAD\x32\xC9\x59\xEF\x3F\xDD\xE9\x78\x1A\x5A\x96\x5D\x17\x3F\x1E\xD7\xEC\x1F\x25\xCA\xCA\x57\x47\xB3\x8C\xA3\x55\x67\x0A\x74\x0E\x63\x15\x3A\xF5\x5C\x82\x71\x14\x5A\x79\x53\xC4\x0E\x26\x2E\x99\x3F\x9D\xC9\xBF\xFD\xB8\xF8\x09\x94\x37\xB7\x4D\x74\x9D\x5F\xC1\xEB\xB4\xC6\x28\x01\x4D\x8A\x81\xB4\xA4\x7A\x2C\x21\xB3\x94\x71\x74\xA3\xDE\x1B\x63\xA0\xC4\xE6\xFF\x6D\x24\x1F\x29\xB2\xE7\x96\x7B\xC8\x40\xE9\x53\xFC\xB1\x93\x8D\x50\xEF\xC8\x7D\xE4\x7B\xA7\x08\x2D\x4B\x9F\x71\xE4\xF3\x90\x68\x99\x25\x8C\xA3\x9A\x65\xE2\xAB\xF7\xD8\xFC\xD9\xE3\x69\x8A\x4E\x8C\x35\xAC\x6B\xF5\x8F\x12\x65\xD5\x75\xEE\x31\x7B\x96\x71\x34\xF6\x63\xB1\xE6\xC7\x0C\x9E\x75\x37\x5E\x90\x5F\x5D\x58\x85\xD4\x36\x8E\x36\xD6\xA3\xF3\xB8\x19\x79\x7C\x79\x18\x2B\x2F\x71\x31\xEA\x4A\x5A\x77\xD3\xCB\x43\x31\x5E\x80\x31\x99\xAF\x9D\xDB\x20\x15\xD9\xDA\xC8\x09\x69\xC4\x63\x4A\x5C\x3C\x4F\xBA\x8C\x56\xFD\xDF\xA6\x96\x88\xDE\x1C\x72\x74\x5B\xB0\x7F\xFF\xDA\x19\x25\xAB\x65\xDD\x75\xD3\xAE\xFA\x98\x19\xCC\x52\xEA\xB1\xA4\xCC\x52\xC6\x91\xCE\x47\xA8\x22\xD6\x4B\x71\xA1\xB8\x06\x87\x90\xC1\x6B\x8E\x07\xD4\xC6\x37\x01\x74\x29\xFE\x54\xA3\xDF\x97\xBF\xD5\x8C\x77\x8F\x11\xD2\x87\x7C\xC6\x51\xCC\x92\xFF\x54\xBF\x08\xFD\xED\x12\xCA\xC4\x55\x1E\xB1\x5E\x70\x41\x0C\x9C\xD4\xDF\xC7\x4C\x16\x6B\xF5\x8F\x52\x65\xF5\xE5\x90\x37\x7B\x59\xED\xAE\x33\x8D\xE9\xAB\x0B\x5F\x56\xDA\x74\xA7\x0D\x30\x44\x51\xD5\x36\x8E\xE6\xFE\xC6\x7E\xF4\x8C\xB9\xEB\xCC\x40\xED\x1B\x1C\xA6\xD6\x8B\x43\xCB\xDA\x2E\xE7\x9F\x88\xDF\xD9\x75\x25\x33\xD7\x94\xC6\x1B\x92\x47\xC9\xA7\x6D\xB8\xF8\x3C\x8A\x63\x1E\x81\x50\x2F\xE4\x58\xFB\x73\x75\x92\xD6\xF5\xD8\x42\x66\x29\xE3\xC8\x56\x62\x2E\xE3\xD7\xF5\xBB\x5C\xF8\x74\x8E\x6F\x20\x8F\xC1\xE7\xB5\xCB\x29\x4B\xF8\xE9\xFC\x6D\x64\x8E\xC7\x35\x45\x5E\x8E\x7C\xDA\x72\x4A\x78\x8E\x6A\x96\x49\x89\x7A\xEF\xBA\xF9\xDE\xFB\x90\x3D\x39\x35\xFB\x47\xC9\xB2\x9A\x9A\xF4\x27\xB5\x2D\xFB\x28\xFF\x0E\xC0\x3F\x00\x7E\x23\x7C\x17\xFA\x07\x80\x07\xF5\x37\x1D\x2D\xF7\xD2\xD0\x17\x1F\xEE\x01\xFC\x81\x7F\xE7\xFC\x01\xA6\xAC\xF4\x89\x9E\x90\x8B\x14\xF5\xA5\x9E\x2F\x88\x3F\x29\xF0\x01\xE0\x16\xC0\x53\xA0\x3C\xFD\xDB\x90\x3C\xA2\xFF\xCE\x1F\x98\x7C\x1E\x7A\x99\xB1\x27\xCA\x42\x7F\x23\xE9\xB2\x91\x93\x6D\x3E\x5A\xD4\x63\x0B\x99\x25\xD0\x27\x07\x43\x8F\xEF\xDF\xE1\xF4\xD4\x4B\x0D\x9E\x33\xBE\x6B\x8D\xFA\x3A\x4E\x5F\xCF\x32\xC6\x1E\xA6\xDF\xE4\x38\xC1\x13\x22\x2F\x07\x0F\x28\x7B\xE2\xE8\x1C\xCB\x44\x13\xA2\xCB\x5C\x84\xB4\xD5\x73\xEF\x1F\x42\x56\xB9\x3A\xCE\xD1\x01\xF1\x0D\x69\x87\xE3\x81\x2C\x74\x70\x3A\x57\x74\x07\xD1\x83\xB3\x8F\x27\x1C\x97\xB1\x3E\x92\x39\x86\xFE\xBC\xF4\xF5\x0C\xBA\x91\x69\x03\x38\x84\x07\x18\x63\x3B\xD6\x30\x7A\x89\xFC\xCD\x07\x4E\xCB\x63\x33\xF6\x45\x45\x8B\x7A\x6C\x21\xB3\x04\x76\xFB\x88\x89\x6D\xE4\xD3\x0B\x07\x98\x3C\xDE\xF6\xCF\x9F\x88\x77\xBB\x64\xBA\xE4\x7E\x63\x68\xAB\x7F\xF5\xCF\x1F\xB8\xDB\xE0\x5C\x25\x2C\x46\xBD\xE4\x33\xC4\x48\x08\x69\xD3\xDA\x18\xF8\x86\x29\xCF\xDF\x18\xF2\xF6\x17\x80\x5F\x01\x32\x43\xE4\x85\x70\x80\xE9\xD3\x4F\xFD\xB3\xB5\xFE\x66\xD7\xED\x8B\x95\x3E\xD7\xC4\xEF\xC9\xFA\xDE\x6D\x80\xFC\x25\x95\xC9\x54\x59\xCC\xF9\xBD\x0F\x9F\x41\xB7\xC4\xFE\x01\x9C\xE6\xF5\x05\xFE\xB2\x1A\x0B\xCF\x00\xA4\xB6\xAD\x09\x37\x54\xEC\xA3\xDD\x56\x3E\x37\xF7\xB9\x2E\xAB\x69\x77\x60\xCC\x72\x82\xFD\xE8\xF5\xDD\xD8\xDD\xF6\xB9\xEA\xAD\x64\x1E\x43\x1F\xDD\x16\x52\x8E\xAB\xAF\xD5\x3B\x7C\xF5\xDA\xA2\x1E\x5B\xB5\x9D\x12\xCB\x6A\xF6\x52\x45\xCC\x7E\x2B\xD7\xA6\x6A\xD7\x52\xAA\x6F\xA3\xA8\x4B\xDF\xB8\xF6\x52\xB8\x36\xAD\xFA\x0E\xA9\x4C\x2D\x57\xF8\x96\x0C\xA6\xEA\xDD\xB7\x04\x14\xBA\x5C\x2C\xEF\x0A\xD9\xDE\xE0\x92\xE9\x3B\xB4\x11\xB2\x34\x32\x55\xBE\xEB\x89\xBF\x87\xB4\x93\xD4\x10\x07\xA5\xCB\xC4\x57\x1E\x53\x65\x11\x7A\x18\xCA\x55\x96\xBE\xA5\x43\x57\x59\xD7\xEE\x1F\xA5\xCB\xCA\x37\x7E\x04\xB7\xAD\x5C\x11\xB2\x4B\x04\xE2\x5B\x22\xDA\xC2\x4E\xCD\xB7\xB6\x5E\xC7\xAC\x5D\x17\xB1\xDF\x8F\x21\x57\x1E\x53\x49\x09\x2C\xA6\xD3\xE8\xF3\xA6\xB4\xA8\xC7\xA5\xB4\x9D\xB9\xDC\x2B\x99\x31\x9E\x1D\xD7\xCC\x7B\x8B\xE9\x32\x09\x59\x0A\x9E\xC2\x35\x2B\x76\x2D\x69\x8A\x17\x6B\x8A\x54\x2F\xC2\xD4\x3B\xF7\x30\x33\xDC\x29\x62\x3C\x84\xBE\x77\xD9\xDF\x9B\xAA\xBF\xB9\xED\x4A\x96\xD4\xC7\xCA\x77\x3F\xF1\xF7\x92\xB4\x2E\x13\xED\xF5\x15\x64\x1B\x82\x8F\xA9\xB6\xBA\x87\xBF\x7F\xB8\xFA\xC0\xD2\xFA\x07\x30\xAF\xAC\xB2\xAD\x5A\xF1\xFA\x90\x79\xA4\x0E\x70\xFA\x77\xBE\x86\xA4\x1B\x4A\xCD\x35\xDD\x73\x31\x7C\xF5\xD2\x6E\xEA\x6F\xE7\xFC\x2E\x46\x21\xB4\x90\x99\x03\x5B\x5E\xCE\x08\xE5\x2E\xA3\xF8\xE0\xF9\xDC\xC5\x54\xF9\xEC\xE0\x8F\x84\xFC\x81\xE9\xFC\xA5\x28\x61\xDF\xAD\x02\x3E\x43\xB3\x44\x5D\x97\x8A\x06\x7D\xCE\x17\x10\xE7\x2E\x13\x5F\xFB\xF5\xDD\x64\xE0\x8B\xDA\xED\x5B\x9E\x73\x19\x75\x4B\xEA\x1F\xC0\xFC\xB2\xCA\x06\x8D\xA3\x36\xC4\x2A\x0D\xDD\x18\x9E\x01\xBC\xE1\xB2\xF7\x76\xC5\xD2\x42\x11\x5F\x8B\x4C\x41\x5F\x01\x91\xF3\x1E\xB5\xDA\x57\xA4\x84\x1A\x75\x53\xE9\x4A\xD9\xEB\xE5\x1B\x6C\x2E\xE9\x3A\xA6\x4B\xCA\xCB\x5C\x42\xDA\x9A\xEB\x3B\x21\x7D\xDE\xF5\xFB\x94\xB6\xDA\xA2\x7F\xC4\xC8\x2D\xCE\xD8\xDD\x6A\x77\x18\xEE\x32\xE1\xE0\xBB\x0C\xBE\x61\x5C\xC2\xF6\xE9\xA4\x3B\x0C\x03\x95\x34\x50\xED\xAE\x96\x7F\x2F\xA6\xC1\x91\xB3\x46\x6F\xEE\x8C\x39\x18\xB0\x34\x5D\x12\xEA\x85\x99\x4A\x77\x6D\x8F\x5D\x28\x62\xC0\x8A\xFE\x6E\xB1\x61\x1F\x58\x96\xCE\x59\x4A\x99\xB8\x70\x19\x40\x2D\xEE\x56\xBC\xD4\xFE\x11\x8C\x6D\x1C\xAD\x01\xBC\x62\x79\x4A\x8C\x18\x9E\x60\xDC\xA3\x63\x4B\x6A\x1B\xF5\xDF\x31\x76\x18\x3F\xD9\x45\x48\x28\x76\xDB\x8B\x5D\x36\xA9\xBD\x37\x0A\x70\xEB\xB2\x0D\x2E\x40\x81\x2B\x9E\xD1\x2E\xBC\xC3\x52\x61\x99\x4C\x73\x6D\xFD\x23\x0A\x31\x8E\xD6\x00\xDE\xD1\x46\x81\x91\x70\x1E\x60\x0C\x1C\xDB\x6B\x14\xCA\x9D\xF5\x84\xC6\x2C\x22\x44\x48\x8D\x6D\xD4\x92\x6B\xD2\x67\x9F\xE0\xC4\x56\xC3\x32\x71\x73\x4D\xFD\x23\x9A\xBF\x61\x0A\x68\xCC\x30\xDA\xC3\x0C\xC4\x21\x83\xE8\x0D\x2E\x3F\xF8\xE3\x52\xD8\x61\x18\x98\x24\xCE\xCD\xAA\x7F\x44\x11\xD8\xFF\xAF\xD9\xC0\xD4\xF7\xEF\x82\x69\x24\x97\x47\x6A\x6C\x23\x52\x9E\x47\xD0\x08\xD0\xB0\x4C\xC8\x2C\xFE\xC6\xE9\xD1\x5C\x39\x2E\x17\xB3\xCE\xB9\x01\x8D\xA3\x16\xF8\xEA\x48\x02\x72\xDE\xE3\xD8\x45\xBA\x86\x51\x1E\x21\x47\x5B\x09\x01\x8E\x3D\x95\x29\x4B\xB3\x2D\x3C\x95\x4B\xDA\xF7\x52\x8A\x15\xF2\x46\x38\xBE\x04\x58\x26\x61\x5C\x43\xFF\x48\xE6\x6F\x8C\x47\xED\x6D\xB1\x01\x8C\xE4\x47\x8E\x0E\xEF\x60\x0C\xA4\x57\xEB\xB3\x3B\xD0\x38\x22\x61\xCC\x89\x6D\x24\xB4\x50\xC4\x2E\x83\x6C\x8B\xCB\xF0\x7E\xF9\x96\xD7\xB7\x70\x9F\x1C\xBB\xC4\xBD\x25\x2C\x93\x30\xAE\xA1\x7F\x24\xF3\x37\x8E\x5D\x8F\xB2\x94\x46\xCA\xD2\xE2\xB4\xC4\x16\xC7\xF7\xDE\xD0\xE5\x3C\x9F\x16\xF5\xD8\x42\x66\xA9\xD8\x46\x5A\x46\x4D\xDD\xB3\xAA\x2C\x0F\x88\xBF\x26\x48\x33\x36\x98\xB9\xF6\x8D\xDC\x22\x2C\x8F\x97\x66\x08\xB0\x4C\xE6\xD3\xA2\x7F\x2C\x0A\x1D\xE7\xA8\x55\x61\x2C\xF1\x68\xE5\x18\x5A\x39\xA5\x1A\x18\xFA\x77\xB5\xCA\x5D\x0F\x6A\x21\x1B\xF2\x2E\xD1\x88\x6A\x51\x8F\xE7\xDA\x76\x4A\xC6\x36\xB2\x71\x0D\x46\x2B\xCF\xE7\x2E\xA6\x0C\xB9\x16\x97\xE0\xDE\x78\x64\x86\x5C\x2E\xAB\x99\x6A\x47\xD7\x3C\xD1\x65\x99\x84\xB3\xA4\xFE\xB1\x28\x5A\x05\x81\xCC\x11\xE5\xB7\x85\x65\xAF\xD3\x9D\x7A\x4B\xB3\x4E\x7B\xAD\x80\x69\x7A\x80\x1E\x33\x8E\x5A\x47\x60\xAE\x41\x8B\x7A\x3C\xD7\xB6\x33\x27\xB6\x91\xC6\x35\x30\xB9\x36\xD0\xCE\xD9\x3F\xE2\x92\xF9\x06\xFF\x04\x61\x85\xBC\x21\x4E\xA6\xF2\x22\xFB\x00\xA7\x28\x55\xCF\xE7\x76\x62\x29\xB5\xDF\xC4\x70\x6E\x65\x32\x87\xA5\xF5\x8F\x96\x1C\xB5\x2D\x6D\x1C\xD5\x1A\x08\x75\x47\x4F\x69\xF0\x35\x3A\x89\x46\x87\x71\x5F\x23\xBE\xCC\xC6\x4E\xF6\xD5\x9A\xCD\xE8\x06\x3C\xA6\x70\xF5\x09\xC5\x39\xEB\xEF\x4B\x55\x32\x2D\xEA\xF1\x5C\xDB\xCE\x9C\xD8\x46\x1A\xDF\x72\xDC\x27\x8C\xF1\x20\x6D\xEE\x1E\xE6\x64\xE5\x9C\xC3\x1E\xAE\xF2\x59\xF7\x32\xF5\x9E\x2A\xF9\xEC\x11\xC0\x97\x95\x8E\x1C\x03\xC0\x9D\xF5\x4E\xC9\xE7\x33\xFC\xA1\x54\xA6\xF2\xE1\xBA\xBE\xC1\x57\x6E\x4B\x3D\x48\xE3\x32\x04\xD7\x30\xE5\xF7\x8E\x69\x43\xF3\x12\xCB\xA4\x14\x4B\xEB\x1F\xA5\x09\x6E\x5B\xFF\x87\xE3\x86\xB4\x46\x9A\xD1\x11\x3B\x08\x6A\xD7\xFC\x06\x71\x81\xBA\x72\x35\xE0\x94\xC1\x5B\xCF\x9C\x9F\x23\xDF\xF3\xAA\xFE\xED\xBB\x17\x07\xFD\xFB\x3F\x31\xCF\x78\xD5\x01\x24\x5D\x03\x95\xAE\x9F\xD8\x3C\x02\xC7\x83\xC0\x12\x69\x51\x8F\x2D\x64\x6A\x62\x14\x58\xEE\xD8\x46\x21\xBF\x7F\x84\x51\x4E\xEF\x30\xF9\x9D\x3B\x61\x73\xDD\xFF\x04\x98\xFC\xBD\x02\xF8\xC1\xA0\x18\x3B\x0C\x86\x9A\xD4\x8F\x84\x3C\xC9\xD1\x9E\x45\xA6\xE4\xF3\x11\xFE\x76\x90\xB2\xCF\xEB\x15\x66\xF6\xFF\xA8\x9E\x67\x98\xFC\x2D\x35\xB6\x9D\xCF\x4B\x76\x83\xE1\x16\x87\x58\xCE\xB5\x4C\x4A\xB1\xC4\xFE\x51\x92\xF0\xB6\xD5\x75\xDD\x63\x77\xCC\x4F\xD7\x75\x77\x5D\xD7\x21\xF0\xB9\xE9\xBA\xEE\x53\xBD\xE3\x31\xE0\x77\xAF\xDD\x29\x21\xBF\xDB\xF4\x69\xD4\xBC\x07\xA6\xF7\x4B\xFD\x2E\x26\xAF\xE8\xBA\x6E\x35\x22\xFF\xB3\x2F\x07\xDF\xEF\xDE\x46\xD2\xED\xFB\x1D\xBA\xE3\xF2\x7D\xEF\xCB\x20\x26\xCD\xEB\xEE\xB4\x8E\xEE\x1D\xDF\xBF\x19\x49\xE7\x67\xFF\x9E\x90\xF2\x79\x8E\x90\xF5\xAE\xBE\x1B\x93\xAF\x39\xEF\x69\x51\x8F\x2D\x64\xEA\xFE\xFD\xDE\xBF\x2F\xA4\x4C\xED\x3E\xFA\x13\xF8\x1B\xDF\xA3\xFB\x5F\x0E\x7C\x7A\x63\x93\x59\x9E\xAB\x3D\xE7\x96\xD5\x75\xEE\xB2\x5F\x17\x90\x27\xCC\x29\xD3\x58\x1D\x65\x3F\xF7\x81\xE9\x9B\xD2\xF9\x2D\xCA\xC4\x55\x1E\x21\x63\x93\xEE\xA7\x36\x21\xE3\xA2\xD6\x7F\x31\xBF\xAF\xD9\x3F\x72\x94\xD5\x9C\xBC\x06\xB7\xAD\xFF\xC3\xE9\xEC\x73\x05\x63\x59\x7F\xC2\x58\xD4\x9B\x91\xE7\x0E\xC3\x0C\xEF\x0B\x69\x16\xFC\x0B\x4E\x67\xBD\xCF\xFD\xFB\x44\xAE\x04\x38\xB4\x5D\xEC\x62\xD9\xA7\xBA\xF7\xB5\x1B\xF1\xAD\x97\x6B\xBB\xB9\x5D\x33\x87\x03\x4C\xA4\x6A\x1B\x71\xC7\xBD\x62\xB8\x9B\x4E\xFE\x7E\x87\x21\x5F\xDA\x2B\xF7\x04\xBF\x25\xAB\xF7\x62\x48\x10\xC7\xCF\x91\xCF\x6C\x56\xBD\xBC\x57\x9C\x46\x8A\xDD\xC3\xBD\x77\xE4\xBB\x4F\x9B\x8D\xB8\x58\xDF\x30\x94\x95\x5D\x3F\x22\x4B\xEA\x4F\xFF\x76\x69\xD4\xAE\xC7\x56\x32\xC7\xBC\xB4\x32\xEB\x93\x59\xF3\xD4\x6C\x6F\x6E\x6C\xA3\x31\x74\xBB\xAA\xC1\x07\xF2\x86\xAD\x48\xF1\xA4\x02\xE9\x3A\xCB\x55\x66\x97\xB8\xC9\x78\xAE\x87\xF2\x12\xCB\xA4\x24\x4B\xE9\x1F\x35\x08\x6F\x5B\xDD\x60\x69\x8F\x79\x63\x52\x09\xB1\x74\x63\xAC\x38\xCD\x4F\x77\x3A\x3B\x08\xF5\x1C\x8D\x79\x45\x34\x21\xB3\x9E\xD4\xB4\x0B\xAF\x81\xE9\x9D\xF2\x1A\x68\xBE\x3A\x53\x06\x2E\xAB\xBA\xEB\x8C\xA7\x22\xC5\x73\x90\x8A\x2F\x9F\xAD\x3C\x47\xB5\xEB\xB1\xA5\x4C\xED\xC9\xD3\x8C\xF5\x1D\x9D\xC6\x10\xAF\x61\xE8\x13\xDB\xAE\x7C\xED\x3A\x54\xDF\xF8\xCA\x21\x04\x9F\xA7\xCF\x37\x2B\x8E\xCD\x7B\x48\x5D\xCF\xF1\x94\xB8\xF4\xBE\x4B\x66\x49\xCF\x51\x68\x5D\xB9\x74\x7E\xED\x32\x39\x67\xCF\x51\xCD\xFE\x91\xA3\xAC\xE6\xE6\x35\xA8\x6D\xC9\x86\xEC\x3D\x4C\xFC\x87\x94\x13\x11\x07\xA4\xCF\x2A\xB7\x30\x33\xE9\x98\x19\x95\xA4\x35\x35\xD6\xCA\x37\x4E\x67\xEF\x29\x6C\x91\x76\x47\xD9\x01\x66\x26\x18\x9A\x06\x89\x58\xEE\x8B\xCF\x21\x6B\xA5\xAE\x3D\x1A\x2F\xFD\x7B\x42\xD3\xFC\x00\x93\xD6\x94\x19\x6F\x6C\x3E\x5B\x51\xAB\x1E\x5B\xCA\x7C\x41\xFC\x4C\xBA\x64\x6C\xA3\x07\x84\xCF\x54\xF7\x30\x65\x95\x83\xA7\xFE\x5D\xA9\x7A\xEE\x09\xE6\xDA\x9D\x39\x27\xC7\x9E\x10\x5E\x96\xA2\x1F\x7D\xEC\x11\xAF\x47\x01\x53\x07\x4B\x0D\x04\x9B\xD2\x66\x6D\x2E\xB1\x4C\x4A\xB3\x84\xFE\x51\x83\xA0\xB6\x65\x9F\x56\xDB\xC3\x64\x2C\xB4\xF3\xEE\xFB\xEF\xFE\x83\x79\x6E\xD0\x6D\x2F\xD7\xB7\xB9\x54\x1A\xFB\xEF\xC0\xF4\xF9\x64\xDE\x22\xCF\x06\xD3\x7F\x10\x56\x66\xB2\x54\xF5\x1B\x69\x9D\xEF\x03\x26\xCD\xA1\xF2\x84\x7D\x2F\x4F\x7E\x97\xA2\x2C\x62\x64\xDA\xED\xE2\x5C\x94\x4C\xCD\x7A\x6C\x21\xF3\x00\xD3\x76\xE4\xE2\x62\x1F\x35\x62\x1B\x3D\xC1\x6D\xF0\x1F\xAC\xEF\xE4\xBC\x7A\x44\xCA\xFD\x01\x61\xF9\xDA\xF5\xDF\xFD\x85\x3C\xED\xF9\x80\x41\xCF\x4E\xE5\x4B\x0C\xC2\x18\x23\x38\x54\x8F\xCA\x64\xF6\x16\x6D\x96\x38\x43\xB1\xDB\x6C\xAA\xBE\xBF\xB4\x32\xA9\x41\xEB\xFE\x51\x83\xA0\xB6\xF5\x57\xD7\x75\x53\x9F\xD9\x97\x97\xCA\x7F\xE5\x45\x25\xD7\x73\xED\x3D\x17\xDF\x30\x19\xD9\xA3\xEC\xDD\x4C\xFA\xA2\xD6\x54\x79\xF2\x9E\x15\xCC\x00\x23\xE9\x97\x6B\x3C\x4A\x20\xF2\x44\xA6\xC8\x03\xCA\xD4\x93\xAB\x5D\x94\xAE\xA7\x5A\xB4\xA8\xC7\x16\x32\xA7\x90\xD3\x3B\xC2\x2F\xD4\xE9\x7F\x72\x32\xEE\x1B\x75\xF7\x8C\x88\xCE\x91\x3D\x74\x73\xF4\x9C\xEC\x09\x1C\x43\x26\x38\xFA\xFB\xB6\xDC\x5C\xF5\x2D\x6D\xC9\xEE\xA3\xA2\x4B\xCF\x15\xAD\xA7\x63\xF3\x73\x89\x65\x52\x83\x9C\xFD\x63\xA9\x9C\xB4\x2D\x97\x71\x44\x08\xB9\x4E\xBE\x30\x18\x2A\x3B\xE4\x5B\xD6\xBA\x06\x62\x8D\x23\x42\xC8\x02\x69\x15\x21\x9B\x10\xB2\x4C\x72\xC7\x36\x22\x84\x90\xB3\x83\xC6\x11\x21\xC4\xC6\x3E\xD6\x7F\x00\x8D\x23\x42\xC8\x15\x42\xE3\x88\x10\x62\x53\x22\xB6\x11\x21\x84\x9C\x15\x34\x8E\x08\x21\x82\xBE\x43\x89\xC6\x11\x21\xE4\x2A\xA1\x71\x44\x08\x11\x74\x6C\xA3\xA5\xC7\x2B\x21\x84\x90\x22\xFC\xDD\x3A\x01\x84\x90\xC5\xB0\xC5\xE0\x2D\xA2\x61\x44\x08\xB9\x5A\x68\x1C\x11\x42\x84\x4B\x8A\x5B\x42\x08\x21\xC9\x70\x59\x8D\x10\x42\x08\x21\xC4\x82\x41\x20\x09\x21\x84\x10\x42\x2C\xE8\x39\x22\x84\x10\x42\x08\xB1\xF8\xEB\x7F\xFF\xFB\x5F\xEB\x34\x10\x42\x2E\x8B\x35\x8E\x4F\xBE\xF9\x2E\xFE\x24\x84\x90\x45\xC1\x0D\xD9\x84\x90\xDC\x3C\x62\x08\x26\xF9\x8D\xF3\xB9\xAD\x9B\x10\x42\x00\x70\x59\x8D\x10\x92\x97\x15\x18\x65\x9B\x10\x72\xE6\xD0\x38\x22\x84\xE4\xE4\x5E\xFD\x9B\x77\xB3\x11\x42\xCE\x0E\x1A\x47\x84\x90\x9C\xD8\x5E\xA3\x1D\x18\x4C\x92\x10\x72\x86\xD0\x38\x22\xAD\x79\x07\xD0\x59\x0F\xC9\x4B\xCD\xF2\x5D\xF7\x8F\x90\x33\xA8\xA4\xCE\x87\xFD\x3C\x66\x94\x43\x08\x21\x34\x8E\x08\x21\xD9\xB0\xBD\x46\x07\x70\xBF\x11\x21\xE4\x4C\xA1\x71\x44\x08\xC9\x85\xBD\xDF\x88\x7B\x8D\x08\x21\x67\xCB\x35\x1A\x47\xB6\x3B\xFE\xBD\x71\x5A\x08\xB9\x14\xEE\x60\x4E\xAA\x09\xF4\x1A\x91\x54\xB8\x84\x4A\x4A\x11\xDC\xB6\xAE\xD1\x38\x22\x84\xE4\xC7\x5E\x52\xFB\x06\xB0\x6F\x95\x10\x42\x08\x99\x0B\x8D\x23\x42\xC8\x5C\x18\xDB\x88\x10\x72\x51\xD0\x38\x22\x84\xCC\x45\xC7\x36\xA2\x71\x44\x08\x39\x6B\x68\x1C\x11\x42\xE6\xA2\x63\x1B\xF1\x1E\x35\x42\xC8\x59\x43\xE3\x88\x10\x32\x07\x1D\xDB\x88\xA7\xD4\x08\x21\x67\x0F\x8D\x23\x42\xC8\x1C\x74\x6C\x23\x1A\x47\x84\x90\xB3\xE7\x6F\xCF\xE7\x6B\x00\x37\xFD\x63\xB3\x87\x39\x91\xC2\xAB\x01\x8E\x91\x59\xF4\x4A\xFD\x7D\x8F\xBC\xD1\x82\xB5\xCC\x15\x8E\x67\xEF\x80\x19\xA8\xBE\x0B\xC8\x9D\x6A\x13\xD2\x1E\x4A\x9C\x52\xBA\xB1\xE4\x0A\x87\x5E\x56\x09\x79\xAD\xEA\xB1\xB6\xCC\x1C\xD8\xFB\x8D\x52\xF7\x1A\xAD\x01\x6C\xAC\x7F\x4B\xBB\xAD\xB1\x3C\xE7\xD2\x71\xA5\xCB\x7D\x05\x93\x6F\x5B\x76\x6E\xB9\x53\xED\x4A\xFA\x6A\x2D\x1D\x7E\x83\xD3\x13\x8D\xB5\xEA\x58\xB3\x84\x32\xD9\xE0\x58\x67\xC7\x94\x47\x8D\x76\x23\xB4\xEC\x1F\xC2\x9C\xB2\x4A\x66\xCC\x38\xBA\x81\x51\x78\x77\x38\x2D\x10\xCD\x1E\x46\x21\xC6\x2A\xC5\x77\x1C\x2B\xC3\xBF\x22\x7F\x2F\xD8\xD7\x21\x7C\x00\xB8\x0D\xF8\x9E\xCD\x66\xE2\xB3\x5B\x84\x57\xFC\x0D\x4C\x7C\x04\x1D\xE7\x65\x8C\x2D\xCC\xCC\x7A\x6E\xA3\x8A\xA9\x23\xF4\xF2\x3E\x7A\xF9\x29\x0D\x2A\x26\x8F\xE2\x3D\x78\xC1\x3C\x25\xB3\x82\xC9\xE3\x3D\xDC\x79\xFC\x06\xF0\x84\xF9\x1E\x8B\x56\xF5\x58\x5B\x66\x4E\x74\xBA\x63\xEB\xE0\x1E\x26\xFF\x63\xF5\x7B\x80\x69\x43\x2F\x69\x49\x73\x22\xFD\xE7\x1E\xEE\x72\x97\x34\xC4\xF4\x9B\x0D\xA6\xE3\xA7\xD9\x3A\xEA\xB1\x7F\xC6\xE4\x7F\xF7\x32\x53\xF3\xBE\x81\xC9\xDB\x66\xE2\xFD\x63\xB2\x62\x75\x83\x2B\x9F\xC0\xA0\x43\x57\x00\x5E\x71\x6C\x18\xD9\x6C\x61\xFA\xEF\x3D\x80\xE7\x00\xB9\xCF\xD6\xF7\x5C\x3A\x5F\x53\xBA\x4C\x42\xEB\xFD\x0E\x26\xFD\x53\x3A\x4D\xEA\x7D\x4C\x77\xAE\xFA\xDF\xEA\x03\x10\x42\x4A\x7B\x1D\xA3\x64\xFF\x00\xF2\xF4\x11\xC0\xE8\x9B\x27\xF8\xC7\x99\x47\x24\xB4\x2D\x7B\x59\x4D\x0A\xFE\x0B\xD3\x0A\x4B\xB3\x86\x69\xF8\x9F\x38\xF5\x5C\x5C\x03\x8F\x30\xE5\xE5\x6B\x44\xC2\x3D\x4C\xA3\x08\xA9\x28\x9F\xCC\xD0\x3A\x02\x4C\x63\x94\xBA\x7D\x46\x58\x5A\x05\xF9\x5D\x68\x1E\xC5\xA8\x11\x59\x29\xAC\x61\xDA\x94\x4B\x89\x08\x37\x00\xDE\x60\xDA\x61\x2A\x2D\xEB\xB1\xA6\xCC\xDC\xD8\x03\x5E\xAC\x17\xEF\xB5\x7F\xA6\xEA\x57\xF4\xD1\x27\xE2\xDA\xAB\x0F\xBB\xFF\xF8\xDE\x6B\xEB\xC4\xA9\xC1\x3D\x85\x57\xB8\xFB\xE1\x0D\xD2\xF2\xBE\x86\x69\x23\xEF\x08\x33\xB8\x6D\x59\xD2\x16\x73\xB2\x86\xBF\xEC\xA4\x5D\x97\x62\x49\x65\xF2\x0A\xA3\xAB\x5C\x3A\xED\x1E\xE3\xE3\xA9\x94\xA5\x2B\x3D\xD2\x5E\xDF\x47\x7E\x1F\xCA\x12\xFA\x07\xE0\xEF\x23\xE8\x65\x7E\x22\x7F\xBB\x05\x30\xEC\x39\x5A\xC1\x14\x68\x6A\xF4\x51\x69\x80\xD7\x64\x20\x49\xE5\xA5\xF0\x08\x53\xA9\xB9\x64\x1E\x30\x78\x87\xE4\x19\x63\x85\xA1\xF1\x87\xF0\x89\x79\x11\x69\x25\x9F\x29\x0A\x3E\xD4\xF0\x13\xEE\x91\x66\x20\x2D\xA9\x1E\x4B\xCA\xCC\x8D\x5E\x26\x89\xF1\x1A\xBD\x22\x5C\xA1\xC9\x04\x2C\x07\xA9\xE5\xBE\x82\x19\xD4\x72\x28\x61\xD7\xCC\x5F\xB3\xEE\xE5\x86\x20\x83\xEA\xC6\xF7\xC5\x09\xC4\xC3\x93\x2B\x02\xB5\x94\x59\x48\xDF\x2F\xB5\x4F\x6D\x49\x65\xF2\x88\xF0\x7A\x97\xF1\x58\xC6\x53\xD1\x89\xA1\x7A\x54\xFA\x4C\xEC\xA4\x62\x09\xFD\x03\x88\x2F\xAB\x57\xA4\xD7\xF1\x24\x62\x1C\xDD\xE3\xD4\xB0\xD9\xC3\xB8\xAC\x7E\xC3\x2C\x7B\xD9\xCF\x6F\x9C\x2E\xA5\xC5\x74\x86\xDA\xDC\x5A\x8F\xCD\x5E\x7D\x26\x8F\x6F\x06\x3C\x56\x79\x07\x98\xF2\xBA\xC5\x69\x59\x8D\xB9\xFE\xD6\x88\x6B\x88\x63\x32\xB7\xFD\xFB\x7F\x8D\xE4\xC1\x96\xAD\xF3\xF3\x14\x20\xEF\x19\xE3\xFB\x98\x5E\xFA\xF7\xFF\xC2\x90\x47\x91\x3F\xE6\x5E\x8D\x1D\xDC\x6C\x25\xB0\x05\xF0\x67\x44\xD6\x1F\x8C\x2B\x54\x59\x6A\x0C\x65\x29\xF5\x58\x5A\x66\x09\x74\x39\x87\x2E\xAD\xDF\x21\x5E\x89\xDE\x61\xFE\xC4\x2B\xC6\x28\x99\xE2\x75\x66\x3A\xD6\x88\x1F\x68\x37\x01\xBF\x91\x19\x7C\x0E\x9E\x91\xC7\x0B\x10\xE2\xF5\x05\xCC\x44\xAE\xC4\xD2\xE9\x92\xCA\x44\x3C\x51\x31\xC8\xA0\x9F\x3A\xAE\xC6\xEA\x88\x25\xF4\x0F\x20\xAD\xAC\x44\x76\x56\xFE\xFA\xDF\xFF\xFE\x27\xFF\x7F\xD7\x0B\x38\x00\x78\x40\xD8\xDE\x86\x0D\x4E\x2B\xEE\x09\xFE\xC6\x5E\x7B\xCF\xD1\xDC\xDF\xD8\xDC\xE0\xD4\xF3\xB2\x83\x29\x33\xD7\xBA\xEB\xD4\x7A\x71\xE8\xFE\xA6\x1F\x0C\xE5\x7C\x80\x31\x10\x62\xF6\x9F\x88\x92\x15\xA3\xD7\xF7\x5D\xED\xEA\x0E\xC9\x23\x70\xBA\xC7\xE0\x00\xB7\xC1\xA9\xDB\x42\xC8\x6F\xEC\x74\xEA\xF6\xF7\x0D\xE0\x1F\xCF\xEF\x80\x36\xF5\xD8\x42\x66\xAE\xBE\xA6\xF9\xC2\x30\xF8\xED\x60\xDA\x63\xEC\xEF\x72\xE1\xD3\x39\xBE\xFD\x31\x31\xEC\x61\x8C\xD6\x1A\xB2\x84\x03\x4C\x9B\x76\xB5\x91\x58\xEF\xC2\x5C\x79\x39\xF2\x69\xCB\x09\xDD\x17\x62\xE3\xD3\xDF\x35\xCB\xA4\x44\xBD\x03\xA6\xBD\xCD\x31\x38\xFE\x81\x7F\x4F\x4E\xCD\xFE\x91\x5B\x9E\xCD\x03\xC6\x27\x69\x49\x6D\xCB\xDE\x73\xB4\x83\x29\xC8\xDF\x08\x1F\x74\x3F\xFA\x04\xD9\x14\x59\xFF\x5B\x10\x7A\x16\xB7\x87\x19\x18\x7C\x46\x83\x18\x9D\xBA\xF2\x42\x66\x92\x7A\xAD\xFC\x05\xF1\x1B\x73\x45\x91\x84\x78\x8D\xF4\x2C\xE9\x03\x61\x79\x04\x06\xC3\x4D\xBC\x48\x21\x46\x8E\x26\xF4\x37\x92\x2E\x1B\x39\xD9\xE6\xA3\x45\x3D\xB6\x90\x59\x02\x7D\x72\x30\x74\x59\x24\xF4\x00\x41\x6E\x72\x7A\xD9\xD6\xA8\xAF\xE3\xF4\xF5\x2C\x63\x88\x17\x3C\xC7\x09\x9E\x10\x79\x39\x08\x99\x6C\xCD\xE1\x1C\xCB\x44\x33\xD7\x13\x13\xD2\x56\xCF\xBD\x7F\x08\x59\xE5\xEA\x38\x47\x07\xC4\x37\xA4\x1D\x8E\x07\xB2\xD0\xC1\xE9\x5C\xD1\x1D\x24\x74\xC6\x2C\x3C\xE1\xB8\x8C\xF5\x91\xCC\x31\xF4\xE7\xA5\xAF\x67\xD0\x8D\x4C\x1B\xC0\x21\x3C\xC0\x18\xDB\xB1\x86\xD1\x4B\xE4\x6F\xE4\x14\x9E\x4D\xC8\xFA\x73\x8B\x7A\x6C\x21\xB3\x04\x76\xFB\x88\x89\x6D\xE4\xD3\x0B\xF6\xF2\xE2\x2D\xA6\x97\x4F\x63\xD0\x41\x2A\x35\xDF\x18\xDA\xAA\x2C\x67\xFE\x81\xBB\x0D\xCE\x55\xC2\x62\xD4\x4B\x3E\x43\x8C\x84\x90\x36\xAD\x8D\x01\x39\xC9\xA9\xB7\x46\xFC\x0A\x90\x99\x6B\x0F\x87\x2C\xC5\x3F\xF5\xCF\xD6\xFA\x9B\x5D\xB7\x2F\x56\xFA\x5C\x13\xBF\x27\xEB\x7B\x21\x5E\xFF\x25\x95\xC9\x54\x59\xCC\xF9\xBD\x0F\x9F\x41\xB7\xC4\xFE\x01\x9C\xE6\xF5\x05\xFE\xB2\x1A\x0B\xCF\x00\x24\xB6\x2D\x5F\x9C\xA3\x50\x76\x38\x2E\xE0\x0D\x2E\xF3\x56\x6E\x7D\x0C\x74\x87\xF8\xE3\xEA\x07\x98\x46\x6D\xCF\xFA\x37\x88\x33\x78\x4A\xCE\xB6\xB4\x02\x48\xC9\xA3\x90\x92\xCE\x94\xA3\xEA\x5B\x1C\x77\xC8\x0D\xFC\xCB\x2C\xB5\xEB\x71\x29\x6D\x27\x07\xA9\x97\xCC\xBA\x94\xF0\x94\x97\x71\x87\xB8\x0D\xDC\x1A\xD7\xE0\x30\xE5\x59\x90\x90\x09\x53\x87\x4C\xC4\x73\x96\xD2\x2F\xA6\x96\x20\xF7\x70\x2F\x01\x85\x4E\x38\x25\x4F\xAE\x3E\x20\xED\xC8\x25\x33\x87\x71\x34\x55\xBE\x5B\xD4\x8D\x91\xB7\x84\x32\x99\x2A\x8B\x27\x84\x1D\x66\x72\x95\xA5\xAB\xDD\xDC\xF4\x9F\x4D\xE9\xE2\xA5\xF5\x0F\x97\xDC\x17\x87\x4C\x5B\x76\x96\x70\x27\xB9\x22\x64\x5F\xA2\x21\x34\xC6\xD8\xA6\xF5\x14\x74\xE5\xC5\xAE\x89\x97\xDC\xF4\x9E\x2B\x8F\xA9\xA4\x34\x6C\x9D\x46\x9F\x37\xA5\x45\x3D\x2E\xA5\xED\xCC\x45\x87\x1E\x88\xF1\xEC\xB8\x06\x17\x19\x98\xC6\x08\x59\x0A\x9E\xC2\xA5\x48\x5D\x4B\x9A\xE2\xC5\x9A\x22\x75\xA0\x9C\x7A\xE7\x1E\x6E\x83\x3E\xC6\x43\xE8\x7B\x97\xFD\xBD\xA9\xFA\x9B\xDB\xAE\xC4\xD8\x1D\x2B\xDF\xFD\xC4\xDF\x4B\xD2\xBA\x4C\xB4\xD7\x57\x90\x6D\x08\x3E\xA6\xDA\x6A\xC8\x1E\x52\x9F\x31\x11\x2B\x13\x28\xD7\x3F\x80\x79\x65\x95\x6D\xD5\x8A\xD7\x87\xCC\x23\x75\x80\xD3\xBF\xF3\x35\x24\xDD\x50\x6A\xAE\xE9\x9E\x8B\xE1\xAB\x97\x76\x53\x7F\x3B\xE7\x77\x31\x0A\xA1\x85\xCC\x1C\xD8\xF2\x72\x46\x28\x77\x19\xC5\x07\xCF\xE7\x2E\xA6\xCA\x27\xC4\x73\xF7\x81\xE9\xFC\xA5\x28\x61\xDF\xAD\x02\x3E\x43\xB3\x44\x5D\x97\xF2\xE0\x9C\xF3\x05\xC4\xB9\xCB\xC4\xD7\x7E\x7D\x37\x19\xF8\xA2\x76\xFB\x96\xE7\x5C\x46\xDD\x92\xFA\x07\x30\xBF\xAC\xB2\x41\xE3\xA8\x0D\xB1\x4A\x43\x37\x86\x67\x98\x53\x5A\x97\xBC\xB7\x2B\x96\x16\x8A\xF8\x5A\x64\x0A\x73\x62\x1B\xF9\xA8\x1D\xF9\x3B\xD4\xA8\x9B\x4A\x57\xCA\x5E\x2F\xDF\x60\x73\x49\xD7\x31\x5D\x52\x5E\xE6\x12\xD2\xD6\x5C\xDF\x09\xE9\xF3\xAE\xDF\xA7\xB4\xD5\x16\xFD\x23\x46\x6E\x71\xC6\xF6\x1C\xDD\x61\xB8\xCB\x84\x83\xEF\x32\xF8\x86\x71\x09\xDB\x7B\x4D\xEE\x30\x0C\x54\xD2\x40\xB5\xBB\x5A\xFE\xBD\x98\x06\x47\xCE\x9A\xD4\xD8\x46\xC0\xF2\x74\x49\xA8\x17\x66\x2A\xDD\xB5\x3D\x76\xA1\x88\x01\x2B\xFA\xBB\xC5\x86\x7D\x60\x59\x3A\x67\x29\x65\xE2\xC2\x65\x00\xB5\xB8\x32\xE8\x52\xFB\x47\x30\xB6\x71\x24\xC1\xFA\x96\xA6\xC4\x88\xE1\x09\xC3\xD5\x1C\x9A\x8D\xFA\xEF\x18\xB2\x89\xAE\xF6\xE6\x5D\x72\x39\xD8\x6D\x2F\x76\xD9\xA4\x45\x70\x58\x97\x2E\xDB\xE0\x02\x14\xB8\xE2\x19\xED\xC2\x3B\x2C\x15\x96\xC9\x34\xD7\xD6\x3F\xA2\x10\xE3\x28\x67\xB0\x2C\x52\x0E\x09\xCE\x69\x7B\x8D\x42\xB9\xB3\x9E\xD0\x98\x45\x84\x08\xA9\xB1\x8D\x5A\x72\x4D\xFA\xEC\x5A\xEF\xB7\x74\xC1\x32\x71\x73\x4D\xFD\x23\x9A\xBF\x31\xDC\xE3\xA2\x0B\x6A\x0F\x33\x10\x87\x0C\xA2\x72\x8B\x2F\x29\xCF\x0E\xC3\xC0\x24\x71\x6E\x56\xFD\x23\x8A\xC0\xFE\x7F\x8D\x44\x27\xF5\x45\x31\x25\xC4\x26\x35\xB6\x11\x29\xCF\x23\x68\x04\x68\x58\x26\x64\x16\x7F\xE3\xF4\x68\x6E\xEA\xD5\x14\x34\x8E\xEA\x13\x72\x5D\x85\x44\x2C\xB5\x5D\xA4\x72\xC7\x53\x89\x3B\x8D\xC8\x65\x92\x1A\xDB\x48\x68\xE1\xA9\x5C\xD2\xBE\x97\x52\xE4\xBC\x43\xEC\x52\x60\x99\x84\x71\x0D\xFD\x23\x99\xBF\x31\x1E\xB5\xB7\xC5\x06\x30\x92\x1F\x39\x3A\xBC\xC3\xE9\xAD\xF5\x77\xA0\x71\x44\xC2\x98\x13\xDB\x48\x68\xA1\x88\x5D\x06\xD9\x16\x97\xE1\xFD\xF2\x2D\xAF\xFB\x02\x2E\x5E\xE2\xDE\x12\x96\x49\x18\xD7\xD0\x3F\x92\xF9\x1B\xC7\xAE\x47\x59\x4A\x23\x65\x69\x71\x5A\x62\x8B\xE3\x7B\x6F\xE8\x72\x9E\x4F\x8B\x7A\x6C\x21\xB3\x54\x6C\x23\x2D\xA3\xA6\xEE\x59\x55\x96\x07\xC4\x5F\x13\xA4\x19\x1B\xCC\x5C\xFB\x46\x42\x2F\xB5\xBE\x34\x43\x80\x65\x32\x9F\x16\xFD\x63\x51\xE8\x38\x47\xAD\x0A\x63\x89\x47\x2B\xC7\xD0\xCA\x29\xD5\xC0\xD0\xBF\xAB\x55\xEE\x7A\x50\x0B\xD9\x90\x77\x89\x46\x54\x8B\x7A\x3C\xD7\xB6\x53\x32\xB6\x91\x8D\x6B\x30\x5A\x79\x3E\x77\x31\x65\xC8\xB5\xB8\x04\xF7\xC6\x23\x33\xE4\x72\x59\xCD\x54\x3B\xBA\xE6\x89\x2E\xCB\x24\x9C\x25\xF5\x8F\x45\xD1\x2A\x08\x64\x8E\x28\xBF\x2D\x2C\x7B\x9D\xEE\xD4\x5B\x9A\x75\xDA\x6B\x05\x4C\xD3\x03\xF4\x98\x71\xD4\x3A\x02\x73\x0D\x5A\xD4\xE3\xB9\xB6\x9D\x39\xB1\x8D\x34\xAE\x81\xC9\xB5\x81\x76\xCE\xFE\x11\x97\xCC\x37\xF8\x27\x08\x2B\xE4\x0D\x71\x32\x95\x17\xD9\x07\x38\x45\xA9\x7A\x3E\xB7\x13\x4B\xA9\xFD\x26\x86\x73\x2B\x93\x39\x2C\xAD\x7F\xB4\xE4\xA8\x6D\x69\xE3\xA8\xD6\x40\xA8\x3B\x7A\x4A\x83\xAF\xD1\x49\x34\x3A\x8C\xFB\x1A\xF1\x65\x36\x76\xB2\xAF\xD6\x6C\x46\x37\xE0\x31\x85\xAB\x4F\x28\xCE\x59\x7F\x5F\xAA\x92\x69\x51\x8F\xE7\xDA\x76\xE6\xC4\x36\xD2\xF8\x96\xE3\x3E\x61\x8C\x07\x69\x73\xF7\x30\x27\x2B\xE7\x1C\xF6\x70\x95\xCF\xBA\x97\xA9\xF7\x54\xC9\x67\x8F\x00\xBE\xAC\x74\xE4\x18\x00\xEE\xAC\x77\x4A\x3E\x9F\xE1\x0F\xA5\x32\x95\x0F\xD7\xF5\x0D\xBE\x72\x5B\xEA\x41\x1A\x97\x21\xB8\x86\x29\xBF\x77\x4C\x1B\x9A\x97\x58\x26\xA5\x58\x5A\xFF\x28\x4D\x70\xDB\xFA\x3F\x1C\x37\xA4\x35\xD2\x8C\x8E\xD8\x41\x50\xBB\xE6\x37\x88\x0B\xD4\x95\xAB\x01\xA7\x0C\xDE\x7A\xE6\xFC\x1C\xF9\x9E\x57\xF5\x6F\xDF\xBD\x38\xE8\xDF\xFF\x89\x79\xC6\xAB\x0E\x20\xE9\x1A\xA8\x74\xFD\xC4\xE6\x11\x38\x1E\x04\x96\x48\x8B\x7A\x6C\x21\x53\x13\xA3\xC0\x72\xC7\x36\x0A\xF9\xFD\x23\x8C\x72\x7A\x87\xC9\xEF\xDC\x09\x9B\xEB\xFE\x27\xC0\xE4\xEF\x15\xC0\x0F\x06\xC5\xD8\x61\x30\xD4\xA4\x7E\x24\xE4\x49\x8E\xF6\x2C\x32\x25\x9F\x8F\xF0\xB7\x83\x94\x7D\x5E\xAF\x30\xB3\xFF\x47\xF5\x3C\xC3\xE4\x6F\xA9\xB1\xED\x7C\x5E\xB2\x1B\x0C\xB7\x38\xC4\x72\xAE\x65\x52\x8A\x25\xF6\x8F\x92\x04\xB7\xAD\xFF\xC3\xA9\xC2\x7A\x45\x9C\x81\x74\x83\xF8\x08\xA4\x07\x8C\x0F\x14\x21\xEF\xD9\xC0\x34\xEE\x54\xF4\xEC\x3D\xD6\x18\xD4\x03\x92\x04\xD0\xF4\xAD\xCF\xAE\x60\xD2\xAD\x95\x7D\xC8\x89\x31\xB1\xCA\x45\x99\xC6\x0E\x18\x63\x41\x3E\x5D\xCB\x23\x3A\x4D\xF2\xFB\x10\x65\x24\xC7\x68\xC5\x25\xFB\x8A\x65\x76\x98\x16\xF5\xD8\x42\xE6\xD8\xBD\x7C\xA1\xCA\x3F\x77\x6C\x23\xDF\x05\x9A\xA5\xF0\xDD\x5A\x2E\x88\x62\x9C\xA2\x55\x7B\x1E\xD3\x97\x82\xCF\x73\x78\x07\x53\xE7\xF6\xB3\xF4\x18\x40\x73\xC3\x3E\x5C\x62\x99\x94\xE4\xDC\xFB\x47\x0C\xC1\x6D\xEB\xFF\x70\xAA\xB0\x45\x11\x7F\xC2\x34\x98\xCD\xC8\x73\x87\x61\x86\xF7\x85\xB4\x46\xF5\x32\x92\xD0\xE7\xFE\x7D\x22\x57\x02\x1C\xDA\x2E\x76\x19\xE4\x53\x3B\x90\xEE\x38\x6F\xBD\x5C\xDB\xCD\xED\x1A\x3C\x0E\x30\x91\xAA\x6D\xC4\x1D\x27\x86\xE5\xC6\xFA\xBB\x74\xC4\x2F\x9C\x1A\x62\x4F\xF0\x0F\x16\xBA\xD3\x4A\x10\xC7\xCF\x91\xCF\x6C\x56\xBD\xBC\x57\x9C\x46\x8A\xDD\xC3\x6D\x1C\x7D\xE3\xB4\xC3\x88\x8B\xF5\x0D\x43\x59\xD9\xF5\x23\xB2\xA4\xFE\xF4\x6F\x97\x46\xED\x7A\x6C\x25\x73\xCC\x4B\x2B\xB3\x3E\x99\x35\x4F\x29\xB3\xB9\xB1\x8D\xC6\x08\x55\xC4\x39\xF9\x40\xDE\xB0\x15\x29\x9E\x54\x20\x5D\x67\xB9\xCA\xEC\x12\x37\x19\xE7\x30\xC2\x2F\xAD\x4C\x4A\xB2\x94\xFE\x51\x83\xE0\xB6\xF5\x37\x4C\x87\xBD\xC5\xA9\x67\xA1\xF4\xC5\xB3\x32\x00\xEB\xA5\x82\x1B\xF8\x37\x60\x4A\x9A\x3F\x13\xE4\xBE\xE0\x74\x30\xD0\x83\xB9\xEF\xB8\xE7\x0E\x66\x90\xD3\x69\xBF\x1F\x79\xF7\x14\x5B\x84\x7B\x1B\xC6\x3C\x5C\xBA\x7E\x24\xA6\x11\xE0\xB6\xEE\xF7\x30\xF9\xF3\xF1\x82\xF1\x3D\x2E\xB1\x57\x97\x6C\x71\x6A\x10\x2C\x85\x9A\xF5\xD8\x4A\xE6\xD8\xA5\xC5\xDA\xDB\x3B\x76\xE7\x5E\x8E\xD8\x46\x63\xEC\x7A\x59\x31\xB3\x4B\xE9\x8B\x73\x96\xD8\xC4\xC0\x98\x7B\xCF\xD6\x1E\xE9\xD7\xEF\x88\xE7\x2C\x26\xEF\x5B\xF8\x0D\xD3\x27\xA4\xE9\x42\xC0\xE4\x63\x69\x03\xD9\x01\xA7\x6D\x36\x96\x4B\x2B\x93\xD2\x2C\xA1\x7F\xD4\x20\xB8\x6D\xC9\x86\x6C\x19\x30\x53\x5C\xDE\x2E\x97\xAF\x0F\x19\x38\x63\x0A\x52\xD2\x9A\x1A\x6B\xE5\x1B\x79\x06\xEB\x2D\xD2\x1A\xC1\x01\xA6\x21\x86\xA6\x41\x22\x96\xFB\x0C\x36\x71\x79\xBA\x06\x90\x97\xFE\x3D\xA1\x69\x7E\x80\x49\x6B\x4A\x43\x8F\xCD\x67\x2B\x6A\xD5\x63\x4B\x99\x2F\x88\x9F\x49\x97\x8C\x6D\xF4\x80\x70\xE3\x4E\x94\x6D\x0E\x9E\xFA\x77\xA5\xEA\xB9\x27\x98\x6B\x77\xE6\x2C\x0D\x3E\x21\xBC\x2C\x43\x27\x16\x7B\xC4\xEB\x51\xC0\xD4\xC1\x52\x03\xC1\xA6\xB4\x59\x9B\x4B\x2C\x93\xD2\x2C\xA1\x7F\xD4\x20\xA8\x6D\xD9\xA7\xD5\xF6\x30\x19\x0B\xED\xBC\xFB\xFE\xBB\xFF\x60\xDE\xAC\x72\xDB\xCB\xF5\x6D\x2E\x95\xC6\xFE\x3B\x30\x7D\x3E\x99\xB7\xC8\xB3\xC1\xF4\x1F\x84\x95\x99\x78\xCA\x7E\x23\xAD\xF3\x7D\xC0\xA4\x39\x54\x9E\xB0\xEF\xE5\xC9\xEF\x52\x94\x45\x8C\x4C\xBB\x5D\x9C\x8B\x92\xA9\x59\x8F\x2D\x64\x8A\xA7\x55\x2E\x2E\xF6\x51\x23\xB6\xD1\x13\xDC\x06\xFF\xC1\xFA\x4E\xCE\x59\xA8\x94\xFB\x03\xC2\xF2\x25\x9E\xBE\x5F\xC8\xD3\x9E\x0F\x18\xF4\xEC\x54\xBE\xC4\x20\x8C\x31\x82\x43\xF5\xA8\x4C\x66\x6F\xD1\x66\x89\x33\x14\xBB\xCD\xA6\xEA\xFB\x4B\x2B\x93\x1A\xB4\xEE\x1F\x35\x08\x6A\x5B\x7F\xFD\xEF\x7F\xFF\x9B\xFA\xCC\xBE\xBC\x54\xFE\x2B\x2F\x2A\xB9\x9E\x6B\xEF\xB9\xF8\x86\xC9\xC8\x1E\x65\xDD\x74\xFA\xA2\xD6\x54\x79\xF2\x9E\x15\xCC\x00\x23\xE9\xB7\x97\xBC\x72\x23\xF2\x44\xA6\xC8\x03\xCA\xD4\x93\xAB\x5D\x94\xAE\xA7\x5A\xB4\xA8\xC7\x16\x32\xA7\x90\xD3\x3B\xC2\x2F\xD4\xE9\x7F\xB2\x31\xFD\x1B\x75\xF7\x8C\x88\xCE\x91\x3D\x74\x73\xF4\x9C\xEC\x09\x1C\x43\x26\x38\xFA\xFB\xB6\xDC\x5C\xF5\x2D\x6D\xC9\xEE\xA3\xA2\x4B\xCF\x15\xAD\xA7\x63\xF3\x73\x89\x65\x52\x83\x9C\xFD\x63\xA9\x9C\xB4\x2D\x97\x71\x44\x08\xB9\x4E\xBE\x30\x18\x2A\x3B\xE4\x5B\xD6\xBA\x06\x62\x8D\x23\x42\xC8\x02\x69\x15\x21\x9B\x10\xB2\x4C\x72\xC7\x36\x22\x84\x90\xB3\x83\xC6\x11\x21\xC4\x26\x77\x6C\x23\x42\x08\x39\x3B\x68\x1C\x11\x42\x6C\x4A\xC4\x36\x22\x84\x90\xB3\x82\xC6\x11\x21\x44\xD0\xB1\x8D\x68\x1C\x11\x42\xAE\x12\x1A\x47\x84\x10\x41\xC7\x36\x5A\x7A\xBC\x12\x42\x08\x29\xC2\xDF\xAD\x13\x40\x08\x59\x0C\x76\x34\x66\x1A\x46\x84\x90\xAB\x85\xC6\x11\x21\x44\xB8\xA4\xB8\x25\x84\x10\x92\x0C\x97\xD5\x08\x21\x84\x10\x42\x2C\xFE\xEA\xBA\xAE\x75\x1A\x08\x21\x84\x10\x42\x16\x03\x3D\x47\x84\x10\x42\x08\x21\x16\xDC\x73\x44\x08\x21\xF3\x59\xE3\xF8\xB4\x9F\xEF\xB2\x53\x42\xC8\x82\xE1\xB2\x1A\x21\x84\xCC\xE7\x0D\x43\x00\xCD\x6F\x98\x9B\xCD\x09\x21\x67\x0A\x97\xD5\x08\x21\x64\x1E\x2B\x30\xB2\x38\x21\x17\x05\x8D\x23\x42\x08\x99\xC7\xBD\xFA\x37\xEF\xA3\x23\xE4\xCC\xA1\x71\x44\x08\x21\xF3\xB0\xBD\x46\x3B\x30\x80\x26\x21\x67\x0F\x8D\x23\x42\xEA\xF3\x0E\xA0\xB3\x1E\x92\x97\x9A\xE5\xBB\xEE\x1F\xA1\x55\x20\xCD\x0D\x8E\xF3\x6C\x3F\xEF\x8D\xD2\x44\xCE\x0F\xB6\xA3\x1E\x1A\x47\x84\x10\x92\x8E\xED\x35\x3A\x80\xFB\x8D\x08\xB9\x08\x68\x1C\x11\x42\x48\x3A\xF6\x7E\x23\xEE\x35\x22\xE4\x42\xA0\x71\x74\x1D\x5C\xAD\x6B\x94\x90\x82\xDC\xC1\x9C\x54\x13\xE8\x35\x22\xE4\x42\xA0\x71\x44\x08\x21\x69\xD8\x4B\x6A\xDF\x00\xF6\xAD\x12\x42\x08\xC9\x0B\x8D\x23\x42\x08\x89\x87\xB1\x8D\x08\xB9\x60\x68\x1C\x11\x42\x48\x3C\x3A\xB6\x11\x8D\x23\x42\x2E\x08\x1A\x47\x84\x10\x12\x8F\x8E\x6D\xC4\x7B\xD4\x08\xB9\x20\x68\x1C\x11\x42\x48\x1C\x3A\xB6\x11\x4F\xA9\x11\x72\x61\xD0\x38\x22\x84\x90\x38\x74\x6C\x23\x1A\x47\x84\x5C\x18\x7F\xB7\x4E\xC0\x02\x59\x03\xB8\xE9\x1F\x9B\x3D\xCC\x89\x14\x5E\x0D\x70\x8C\xCC\xA2\x57\xEA\xEF\x7B\x94\x89\x16\x2C\xB2\xD6\xEA\xEF\x07\x98\xBA\x29\x25\x73\xAC\x4D\x48\x7B\x28\x71\x4A\xE9\xC6\x92\x2B\x1C\x7A\x59\x25\xE4\xD5\xAE\xC7\x56\x32\x73\x60\xEF\x37\x9A\xBB\xD7\x48\xDA\x95\x6E\xCF\x25\xDB\x16\x60\x22\x21\xDB\x32\xA5\xEF\xE4\x5C\x1E\x9C\xAA\x5F\xC9\x57\x0D\x5D\x5A\x3A\x9F\xEB\x5E\x46\xA9\xF7\xFB\x64\x4F\x8D\x55\x4B\xEC\x3F\x1B\x98\xB4\x8E\xF5\xF7\x3D\xF2\xB7\xBD\x79\xF5\xD2\x75\x1D\x9F\xAE\xBB\xE9\xBA\xEE\xB9\xEB\xBA\xAF\xCE\xCF\x67\xD7\x75\xF7\x09\x32\xDE\xD5\x7B\x52\xD3\x6A\xF3\x1E\xF8\xBD\x10\x36\x11\x69\xB8\xE9\xBA\xEE\xB5\xEB\xBA\x9F\x80\xF7\xBE\x46\xBE\x7B\x6E\xFD\x74\x9D\x29\x97\xC7\xAE\xEB\x56\x33\x65\x86\xE6\xF1\xA7\xFF\xEE\x4D\xE0\xBB\xA7\xDA\xC2\xAA\x4F\xB7\x2F\x9F\x5F\x5D\xD7\xDD\xCD\xC8\x5B\xAB\x7A\xAC\x25\x33\x57\x5F\x1B\x7B\xEE\xD4\xBB\xD7\x09\xEF\x08\xAD\xE7\xAE\x1B\xDA\x96\xAF\x1C\x36\x8E\x77\xD8\x7A\xE2\xB1\x73\x97\xFD\x5B\x17\xDE\x8E\xA7\xD2\xF1\xE6\x91\x21\x7C\x75\xF1\xFD\x74\x29\xF9\xBC\xEF\xA6\xEB\xEF\xA7\x97\x3F\xD5\x1E\x6D\xEC\xEF\x85\xF6\x9F\x67\x4F\xDE\xEC\x34\xC4\xEA\xC0\xD0\xF2\x8D\x6D\x0F\x21\xBC\x75\x69\x63\x6B\x91\x7A\x99\x93\x88\x4B\x78\x56\x9D\x69\x68\x29\x7C\x76\x71\x8A\xF1\x52\x8C\xA3\xC7\x84\x77\x77\x9D\x29\xE7\x94\xFC\xA6\xCA\xEB\x3A\xD3\x19\x9E\xBB\x78\x05\x91\xDA\x26\xBA\x2E\x2C\x9F\x63\x6D\x61\xDD\x85\x1B\x7F\xC2\x6B\x80\xAC\xA5\xD4\x63\x4D\x99\x25\x8D\x23\x5B\xD1\x7F\x26\x96\x41\x88\xE1\x30\xC6\x7B\x37\x3D\xA0\x87\x0C\x6A\xAF\x81\x72\x7E\xBA\xF8\x41\x6A\xDD\xB9\x07\x9B\x5C\xF2\x5A\xE7\x33\xE6\xFD\x9F\x9D\xD1\x3D\xB9\x8C\xA3\x94\xFE\xF3\xD3\xC5\x4D\xA4\x72\x19\x47\xBE\x7C\xBB\x88\x1D\x5B\x8B\xD4\x4B\x4E\xA5\x71\x6E\xCF\xAA\x2F\xA4\x39\xFC\x74\xE1\x95\x78\x09\xC6\x51\x68\xE3\x9B\x22\x76\x30\x99\x92\xF7\xD3\x99\xBC\xDB\x8F\x8B\x9F\x08\x99\x73\xDB\x44\xD7\x0D\x9D\x2F\xB4\x2D\xAC\xBB\xF4\x01\x33\xC5\x40\xAA\x5D\x8F\xB5\x65\x96\x32\x8E\x6E\xD4\x7B\x63\x67\xFD\x73\xCB\xA0\xEB\xA6\x07\x3B\xDF\xA0\x96\x32\xB0\x86\x4E\x98\xEE\x13\xDE\x3D\x46\x48\x79\xB6\xCC\x67\x4A\x1D\xBE\x75\x79\x8C\xA3\xB9\x6D\x27\xA7\xF1\xE9\x7B\x52\x26\x7A\x9A\x98\xB1\xB5\x48\xBD\xE4\x52\x1A\xE7\xF8\x8C\x75\xA2\xCF\xFE\xEF\x63\x95\xB2\xEE\xC6\x2B\xE0\xAB\x0B\xF3\x4C\xD4\x36\x8E\x36\xD6\xA3\xF3\xB8\x19\x79\x7C\x79\x18\x2B\x2F\x71\x53\x6A\xE5\xB2\xEE\xA6\x97\x0D\x42\xBD\x00\x63\xF2\x5E\x3B\x77\x87\x11\xB9\xDA\xC0\x09\x55\x0C\x63\x1E\x23\xF1\x3E\xE9\x32\x5A\xF5\x7F\x9B\x5A\x22\x7A\x73\xC8\xD1\x6D\xC1\xFE\xFD\x6B\x67\x06\x3F\x2D\xEB\xAE\x9B\x76\x4F\xC7\xCC\x0C\x6B\xD7\x63\x0B\x99\xA5\x8C\x23\x9D\x8F\x18\x8F\xE4\x1C\x6F\xE4\x18\xBA\x1F\xB8\x06\xB5\xD4\x81\xEA\xAB\xF3\xE7\x6B\xD5\xA5\x1B\xF6\x63\xF8\xDA\x72\xAB\x7C\xA2\x3B\x5D\x52\x0D\xC5\x55\x3E\x21\xC6\x51\xAE\xB6\x13\x62\x6C\xCC\x35\x8E\x72\x38\x1D\x84\x9F\x2E\x6C\xE9\xB3\x48\xBD\xE4\x52\x1A\xE7\xFA\xDC\xF5\x05\xF4\xD5\x85\xCF\x1E\x36\x23\x85\x1A\xD2\xC0\x6B\x1B\x47\x73\x7F\x63\x3F\x7A\xC6\xDC\x75\x66\xA0\xF6\x0D\x0E\xAB\x6E\xDC\xA0\x0C\x29\x6B\xBB\x8C\x7F\x02\x7F\xA3\xEB\xE9\xBD\x0B\x1F\x50\xC7\x94\x42\x48\x1E\x25\x9F\xB6\xE1\xE2\x9B\xF5\x8C\xCD\x58\x42\x67\x4A\x63\xED\x2F\x54\xB9\xB7\xA8\xC7\x16\x32\x4B\x19\x47\xF6\xE0\xEB\x32\x7E\x43\xDA\xD6\x1C\xC6\x3C\x93\xB9\x65\x08\x21\x13\x8B\x39\x9E\x4F\xCD\x4F\xE7\x6E\x1B\x2D\xF3\x39\xD7\x1B\x32\x86\x6F\xEC\xC8\x99\xDF\x10\xEF\xEB\x5C\xE3\x28\xF7\x24\x20\x44\x66\x91\x7A\xB9\xF6\xA3\xFC\x3B\x00\xFF\x00\xF8\x8D\xF0\xDD\xFD\x1F\x00\x1E\xD4\xDF\x74\xB4\xDC\x4B\xE3\x51\xFD\x7B\x0F\xE0\x0F\xFC\x3B\xFF\x0F\x30\x65\xA5\x4F\xF4\xE8\xF7\x69\xF4\x85\x9E\x2F\x88\x3F\x7D\xF1\x01\xE0\x16\xC0\x53\xE0\xF7\xEF\xD4\xBF\x3F\x10\x96\x47\xF4\xDF\xF9\x03\x93\xCF\x43\x2F\x37\xF6\x94\x51\xE8\x6F\x24\x5D\x36\x63\xA7\x9D\xC6\xA8\x5D\x8F\xAD\x64\x96\x40\x9F\x1C\x8C\x39\xBE\xFF\x9A\x31\x1D\x3B\x98\xB6\x52\x2B\xE8\x64\x88\x6E\xDB\x23\x5F\x9A\xF4\xB5\x2C\xB5\xF0\xE5\xF3\x0E\xA7\xA7\xC2\x6A\xF0\x9C\xF1\x5D\x6B\x94\x1D\xAB\x56\xC8\xDF\x3F\xF5\x69\x43\x4D\xB1\x7A\xB9\x76\xE3\x08\x30\x1D\x3A\xB6\x53\xEF\x70\x3C\x90\x85\x0E\x4E\xE7\x8A\x56\x56\x7A\x70\xF6\xF1\x84\xE3\x32\x96\x23\x9D\x53\xE8\xCF\x6A\x5C\xCD\xA0\x95\x86\x36\x80\x43\x78\x80\x31\xB6\x63\x0D\xA3\x97\xC8\xDF\x7C\xE0\xB4\x4C\x36\x63\x5F\x54\xD4\xAE\xC7\x56\x32\x4B\x60\xB7\x8F\x98\xD8\x46\xA1\xE9\xDD\xC1\xE4\x55\x9E\x17\x9C\x1E\x75\xDF\x22\xDC\x60\x1F\xE3\xD0\xBF\xD7\x96\xE1\x7B\xD7\xD8\x51\xFC\x31\xB4\x81\xF4\xDD\xCB\xF8\x0D\xE0\x2F\xEB\xF9\x05\xD3\x4F\x5C\x72\x43\xDA\xB2\x8B\x12\xF9\xF4\xE9\xF7\x43\x2F\xEB\xB6\x7F\xFE\x60\x7E\xFC\x2B\x1D\x6C\x54\xF3\x8D\x41\xE7\x48\xF9\xFE\x81\x5B\x97\x94\x34\x8E\x42\x0D\x69\xBB\x9D\x87\x4C\x7A\x5D\xEF\x2D\x57\x2F\x01\x2E\x2B\x3E\xE3\x8F\xDE\x7F\xE0\x73\x8F\x9E\xEB\xB2\x9A\x76\xB3\xC6\x2C\x27\xD8\x8F\x76\xB7\xBA\xDC\xD8\xBA\x6C\x4B\xD7\x65\xAE\x3C\x86\x3E\xBA\x2D\xA4\x1C\x57\x5F\xAB\x77\xF8\xEA\xB5\x45\x3D\xB6\x90\x39\x56\xBE\x39\xEA\xCC\x5E\x36\x8A\xD9\x6F\xE5\x5B\x66\xF8\xEC\xDC\xFB\x2A\xEE\xBB\xE1\x38\x7F\x4C\xFD\x8E\xC9\x19\x5B\xAE\x0A\xD9\x23\x12\xD3\x3E\x65\xCF\x58\xC8\xF7\xA6\x96\xE2\x5C\x07\x28\x5A\xE5\xD3\xB5\x79\xD7\xB5\x24\xEE\xDB\x28\xEC\x2A\x2B\x57\xDB\x71\x1D\xFA\xF0\xE5\xD5\xD5\xDE\xE6\x2C\xAB\xF9\x0E\xC6\x4C\xF5\xDB\xB1\xAD\x02\x36\xAE\x6D\x03\xC5\xEA\x85\x9E\xA3\x74\x4A\x05\x67\x5B\x1A\xDA\x32\x4F\xCD\xB7\x9E\x21\x84\xCC\x46\x53\xBE\x9B\x42\xAE\x3C\xA6\x92\x12\xB0\x4D\xA7\xD1\xE7\x9D\x68\x51\x8F\x4B\x68\x3B\x39\xB8\x57\x32\x63\x3C\x02\x2E\x2F\x88\x2C\xC1\xBA\x82\x21\x6E\x61\x3C\x03\x29\x9E\x4C\x1B\xED\x81\xB3\xD3\xE0\xF3\xE6\xC5\x78\xC5\xF7\x30\x9E\x9A\x90\xEF\x4D\x95\xE3\x9C\xFA\x2D\x95\x4F\x57\x3D\x6E\x31\xDD\xB6\x43\x97\xF5\xC7\x70\xA5\xC7\xE5\x41\x14\x6F\xC9\x14\x73\x3D\x73\x53\xB8\xD2\xBB\xC5\xF4\x0A\xC0\x07\xDC\x6D\x66\x2C\x70\xA4\x50\xAC\x5E\x68\x1C\x91\x58\x52\x07\x38\xFD\x3B\xDF\xA0\x61\x53\x7B\x4F\xD7\xB9\x18\xBE\x7A\x69\x37\xF5\xB7\x73\x7E\x17\xA3\x68\x5B\xC8\xCC\x81\x2D\x2F\x36\x42\xB9\x6B\xC0\x08\x59\xEE\x41\xE0\x77\x7C\xBF\x77\x19\xE0\xA5\x22\xCB\xFB\xC8\x1D\x21\xBB\x55\x3E\x5D\xEF\xF4\xA5\xC9\xC5\x54\x3B\xDF\xC1\x5F\x76\x1F\x98\x6E\xA7\xA5\xB6\x80\xB8\x8C\x5A\xDF\x84\xC2\xB7\x75\x22\x25\xCD\xB3\xEA\x85\xC6\x11\xA9\x45\x8C\x82\xD7\x8D\xF6\x19\xC0\x1B\x2E\x7B\x5F\x57\x0A\x2D\x6E\x82\xBF\x16\x99\xC2\x0D\x8E\xF7\x4D\xE5\xBC\x47\xAD\x96\x41\x72\x2E\xC6\xFE\x5C\x5A\xE5\xB3\xB6\x61\x19\x9A\xCF\xA9\x74\xB5\xD8\xB3\xE7\x2B\xA3\x12\x7D\x7C\x56\xBD\xF0\x6E\x35\xC3\x1D\x86\x5D\xF1\x1C\x80\xDB\xF3\x0D\x33\xAB\xB6\x4F\x3E\xDC\x61\x18\xA4\xA4\xD1\xEB\xFB\x78\xE4\xDF\xD7\x32\x18\x90\xF2\xE8\x0D\xE5\x39\x0F\x07\x5C\x5A\x3B\x15\x43\x52\xF4\x68\x8B\x41\xB8\x04\x4B\x1B\x13\x42\x3D\xA7\x53\xE9\x2E\xE1\x79\x6D\x51\x46\x45\x65\x5E\xBB\x71\xB4\x86\x39\x66\xBB\xB4\xC6\x4F\xCC\x9A\xF0\x0A\xE3\x4B\x6A\x1B\xF5\xDF\x31\x76\x18\x3F\xD5\x45\x48\x0C\x76\xFB\xDB\x21\x6E\x86\x5B\x7B\xF9\xAF\x25\xCF\x68\x17\x66\xA1\x34\xB5\xF7\xB8\x01\xFE\xFD\x4F\x4B\x6B\x5B\x2D\xCA\xA8\xA8\xCC\x6B\x5E\x56\x5B\x03\x78\x07\x0D\xA3\x25\xF3\x80\xF4\x23\xB1\x77\x30\x86\xEF\x3B\xDA\x74\x5C\x72\xFE\xCC\x89\x6D\x74\x4D\x7C\xE2\x72\x0D\xA3\x56\x50\x67\x35\xE6\x5A\x3D\x47\x2B\x8C\x0F\x9A\x7B\x18\x6F\x43\xC8\xEC\xF0\x06\x97\x1F\xFC\x71\x09\xEC\x30\x0C\x4A\x12\x33\x66\xD5\x3F\x62\xD8\xDA\xFF\xAF\xD9\xC0\xD4\xF5\xEF\x82\x69\x24\x97\x49\x6A\x6C\x23\xFB\x37\x97\xCE\x23\x38\xC1\x24\x17\xC8\xB5\x1A\x47\xFA\x68\xAE\x1C\xF3\x8C\xD9\xC0\xB5\x01\x8D\xA3\xDA\xF8\xEA\x47\x82\x71\xDE\xE3\xD8\xED\xBC\x86\x51\xE2\x21\x47\x8C\x09\x11\xEC\xFD\x46\x29\xCB\xB3\x97\xB6\xA7\x48\xB3\x42\xDE\x08\xCE\x4B\xA5\x85\x91\x7B\x6E\x6D\x27\xF7\xC9\xC3\x10\x8A\xD6\xCB\xB5\x1A\x47\x63\x51\x7B\x5B\x1C\x65\x25\x79\xF9\xEE\x9F\x1D\x8C\x81\x64\x5F\xDB\x70\x07\x1A\x47\x24\x9C\x39\xB1\x8D\x42\xD9\xE0\xBC\xF5\x8E\xEF\x9A\x8F\x2D\xDC\x83\xE6\x12\xF7\xCE\x8C\xD1\xC2\x50\x71\x0D\xFC\x5B\x2C\x6F\x89\xB7\x85\x71\x54\xB4\x5E\xAE\xD5\x38\xB2\xDD\xC0\xB2\x94\x46\xCA\x52\xFB\xE4\xCA\x16\xC7\x77\x09\xD1\xF5\x9F\x87\x16\x27\x90\x5A\xC8\x9C\x13\xDB\x28\x94\x35\xCE\x5B\xF7\xB8\xF6\xC5\xDC\x22\x2C\x6F\xE7\x60\x1C\xF9\xA8\x6D\xE4\xAE\x2A\xCB\xCB\xC1\x1D\xDC\x06\x5D\x89\x3E\x3E\xAB\x5E\xAE\x79\x43\xB6\xD0\xAA\x91\x9D\xCB\x31\x57\x3D\x83\x49\x35\x32\xF4\xEF\x6A\x94\xBB\x1E\xD0\x42\x37\x39\x5E\xA2\x21\xD5\xA2\x1E\xCF\xB5\xED\xE4\x8C\x6D\xE4\x4A\x6B\xE8\x7E\x1D\x7D\x11\xF3\x52\x98\x4A\xFB\xB5\x4D\x38\x5D\x06\xDE\xCA\xF3\xB9\x8B\x29\x83\xBC\xD5\x25\xB8\xBE\x36\xE8\xF2\x1E\xF9\xBC\x8C\xBE\xCF\x53\xDA\xD3\xAC\x7A\xA1\x71\x54\x8F\x1C\x51\x7E\x5B\xCC\xB2\x74\xBA\x53\x6F\xCC\xD6\x69\xAF\xE1\x86\xD5\x83\xF3\x54\xE7\x6E\x1D\x81\xB9\x06\x2D\xEA\xF1\x5C\xDB\x4E\xCE\xD8\x46\x2E\xA5\x2E\x07\x43\xA6\xDA\x9B\xDC\x72\xFE\x86\xCB\x3C\x75\x79\x4E\xF9\x49\x35\x72\xE7\xEC\xC9\x72\xC9\x7C\x83\xBF\xFC\x56\xC8\x1B\xAA\xC6\xF6\xC4\x8F\xE1\xF2\xAE\xDE\x61\xFA\x44\xE3\x23\xDC\xE5\xE4\xEA\xEF\xC5\xEA\x85\xC6\x51\xBD\x81\x50\x57\x70\xCA\x40\x91\x3A\xB8\xCC\x61\x8F\xE3\xB4\xAF\x11\x5F\x66\x63\x27\xFB\x6A\xCC\x2C\x75\xC7\x98\xEA\x64\xFA\x84\xE2\x9C\xBD\x10\x4B\x55\xF8\x2D\xEA\xF1\x5C\xDB\xCE\x9C\xD8\x46\x1A\x5F\x5A\xC5\x40\xFA\xC4\x10\x2B\xE8\xB1\xFF\xDB\x0F\x06\x25\x2E\xA1\x47\x96\xD4\xBE\x5C\xD7\x53\xF8\x0E\xAB\x9C\xDB\x81\x16\xDF\xB2\xAA\xD4\x9F\xE8\x8E\x7B\x98\xFA\x9A\x93\x47\x57\xDB\x59\xF7\x32\xF5\xDE\x38\xF9\xEC\x11\xC0\x97\x95\x8E\x5C\x06\xD2\x2B\x80\xAE\x7F\x74\x5F\xF6\xB5\xF5\xE7\x3E\x4D\xD2\xCE\xED\x7F\xBB\x70\x79\x6E\x8B\xD5\xCB\xB5\x1A\x47\x76\x81\xAE\x91\x66\x74\xC4\x2A\x29\x5D\xC1\x1B\xC4\xC5\x06\xC9\xA5\x4C\x52\x94\xAB\x9E\x39\x3F\x47\xBE\xE7\x55\xFD\x7B\x0B\xF7\x80\xB3\x82\x69\xD4\x73\x0C\x57\x1D\x40\xD2\xD7\x89\x74\xFD\xC4\xE6\x11\x30\xED\x48\x14\xD2\x12\xA9\x5D\x8F\xAD\x64\x6A\x62\x06\x86\xDC\xB1\x8D\x42\x97\x98\x64\x40\x7B\xC6\xA0\xCC\xC7\xBE\xB3\x34\x03\x69\x8A\x57\x18\xEF\xC6\xA3\x7A\x9E\x61\xFA\xF6\xB9\xE4\x43\x08\x69\x07\x62\xD4\xBE\xC3\xE4\x7F\xEE\xC4\xDB\x75\x3F\x1A\x60\xDA\xE9\x2B\x8C\x11\xFD\xD5\xCB\xED\x30\x18\x04\x52\xBE\x62\x80\x97\xD6\x4B\x21\x13\x89\x1B\x0C\xED\xE0\x11\x61\xCB\x83\x2E\xCF\x6D\xB9\x7A\xE9\xBA\xEE\x1A\x9F\xC7\xEE\x98\x9F\xAE\xEB\xEE\x22\x7E\x7F\xD3\x75\xDD\xA7\x7A\xC7\x63\xC0\xEF\x5E\xBB\x53\x42\x7E\xB7\xE9\xD3\xA8\x79\x0F\x4C\xEF\x97\xFA\x5D\x4C\x5E\xD1\x75\xDD\x6A\x44\xFE\x67\x5F\x0E\xBE\xDF\xBD\x8D\xA4\xDB\xF7\x3B\xBB\x6C\xDF\xFB\xFC\xC7\xA4\x77\xDD\x9D\xD6\xCF\xBD\xE7\x37\x37\x23\xE9\xFC\xEC\xDF\x15\x52\x3E\xCF\x11\xF2\xDE\xD5\x77\x53\xDB\x71\xEC\x7B\x6A\xD7\x63\x2B\x99\xBA\x7F\xBF\xF7\xEF\x0B\x29\x53\xBB\x8F\xFE\x04\xFE\x26\xA4\x3D\xE6\xE4\x73\x24\x3F\x1B\xC7\xF7\x43\xF4\x84\x6E\x4B\x36\x53\x3A\x2A\x77\xBE\x6C\xA6\xD2\xD9\x22\x9F\xF2\x68\x3D\x9A\x03\x9F\x4C\x57\x7E\x53\xF0\xE9\x41\x44\xBC\x6B\x4C\x2F\xEB\xBE\x37\x97\xD7\x89\x34\x16\xAF\x97\x6B\xF5\x1C\xE9\xD9\xE7\x0A\x66\x96\x23\x91\x5E\x37\x23\x8F\xAC\x99\xBE\xC3\x58\xE9\x29\x6E\xCA\xB1\x5B\xB8\xC5\xB5\x28\x72\x25\xC8\xA1\xED\x02\x94\x59\x56\xAA\x7B\x5F\xCF\x5C\xDF\x7A\xB9\x12\x0F\x68\x03\xF7\x2C\xEE\x00\x13\xAD\xDA\x66\xDD\xA7\xFB\x15\xC3\xDD\x74\xF2\xF7\x3B\x0C\xF9\xD2\x5E\xB9\x27\xB8\xD7\x90\xF5\x3A\xB1\x04\x71\xFC\x1C\xF9\xCC\x66\x85\x21\x2A\xF6\xA7\xFA\xDE\x1E\xFE\x7D\x23\xDF\x7D\xDA\x6C\xC4\x75\xFD\x86\xA1\xAC\xEC\xFA\x11\x79\x52\x7F\xFA\xB7\x4B\xA3\x66\x3D\xB6\x94\x39\xE6\xA5\xD5\xCB\x56\x53\xB3\xE8\xB9\xB1\x8D\xC6\xD8\xE3\xB4\x6D\xCD\xE1\x06\xCB\x38\xD0\x71\x6D\x1B\xAF\x73\xD6\x61\x28\x1F\xC8\x1B\x82\x24\xC4\x73\x3B\xA7\xDD\xBF\x20\xDF\xC9\xCE\x31\x9D\x3C\x46\x99\x7A\x09\xB0\xCA\x2E\xF5\x59\x77\xE3\xDE\x98\x54\x42\x3C\x40\xE8\x8C\xE5\x9E\xC2\x4F\x77\x3A\x53\x0B\xF5\x1C\x8D\x79\x45\x34\x21\xDE\x99\xD4\xB4\x0B\x21\xB3\x80\x29\x8F\x81\xE6\xAB\x33\xF9\x77\xCD\x04\xBB\x6E\x7C\x96\xED\x7A\xC6\xBC\x7B\xB1\xF8\xF2\xD9\xCA\x73\x54\xB3\x1E\x5B\xCB\xD4\x9E\x3C\xCD\x58\xDF\xD1\x69\x0C\xF1\x1A\xC6\x3C\x39\x66\xD5\xA2\x07\xF4\xBB\x5B\x79\x54\xE6\x78\x8F\x5C\xFA\x77\x4A\x5E\x4B\xCF\x51\x8A\x7E\xF0\xE9\xA8\xD0\x71\xC3\xD7\x9E\x43\x08\xF1\xD8\xA2\xFF\x4E\xC8\xD8\x38\x35\x66\xAC\xBA\x53\xCF\x7D\x2C\x5F\x5D\x5C\xFF\xCB\x5E\x2F\xD7\xEA\x39\x02\x8C\x75\x7B\x8B\xB4\x93\x2F\x07\xA4\x5B\xD7\x5B\x98\x99\x74\x8C\x17\x48\xD2\x9A\x6A\x91\x7F\xE3\x74\xF6\x9E\xC2\x16\x26\x60\x66\xAC\x07\xEB\x00\x63\xDD\x87\xA4\x41\xA2\x95\xFB\xE2\xA4\xDC\xC0\xBF\x71\xFA\xA5\x7F\x4F\x4C\x7A\x1F\x60\xD2\x9A\xE2\xA5\x8B\xC9\x67\x4B\x6A\xD4\x63\x6B\x99\x2F\x88\xF7\x6A\x94\x8E\x6D\xF4\x02\x53\x06\xA9\xA7\xED\xB6\x00\xFE\xC1\xB2\xA2\x27\xEF\x11\xAF\xCF\x00\x53\x16\xE7\x18\x94\xF5\x01\xE1\xE9\xDE\xC3\xD4\x77\x0E\x9E\x90\xDE\x76\xA4\x0F\xFD\x0E\xFC\xFD\x37\xE2\xF5\xA6\x96\x77\x8B\xF4\xFA\xDD\xC1\xA4\x35\xA6\x9D\x67\xAF\x97\x6B\x36\x8E\x00\x53\x48\xBF\x61\x1A\x4E\x48\x45\x88\x7B\xFC\x1F\xCC\xDB\xA8\xB9\xED\xE5\xFA\x36\x97\x8A\xE2\x89\x6D\x28\x53\x32\x6F\x31\x7F\x83\xE9\x0E\x26\xFF\x21\x65\x26\x6E\xD1\xDF\x88\xEF\x28\x1F\x30\xE9\x0D\x95\x25\xEC\x7B\x59\xF2\xBB\x94\x0E\x6E\xFF\x3E\xB6\x5D\x9C\x8B\xC2\xAF\x55\x8F\xAD\x64\x8A\x82\x7E\x40\x98\x91\x94\x33\xB6\x91\x0B\x29\x83\x87\x40\x19\xDF\x18\xDA\x63\x8A\x11\x52\x83\x50\x7D\x26\x93\xCA\x5B\xB4\x59\xA2\xCA\xC5\x13\xDC\x93\xB7\x83\xF5\x9D\x9C\xF5\x15\xDB\x76\x76\xFD\x77\x7F\x21\xBE\x0F\xED\x31\xF4\xD5\x94\xA5\x53\x29\x03\xD1\x89\x3E\xA3\xCC\x6E\x1B\x29\x93\x28\x20\x73\xBD\xFC\xD5\x75\x5D\x42\x1A\x2E\x16\xFB\x02\x53\xF9\xAF\x28\xF1\x92\x6B\xEB\xF6\x9E\x8B\x6F\x98\x8A\xDB\xA3\xAC\x22\xD4\x97\xB5\xA6\xCA\x93\xF7\xAC\x60\x06\x18\x49\xBF\x5C\xE5\x91\x1B\x91\x25\xF2\x44\x16\x50\xAE\x8E\x5C\xED\xA2\x74\x3D\xD5\xA2\x76\x3D\xB6\x92\x39\x85\x8E\xB5\xF2\x0B\xF5\xEA\xD5\xEE\xFF\xC0\xF9\xB7\x2D\xA9\x53\x3B\x3F\xA2\xD3\x2E\x0D\xC9\xA7\xEC\x01\xFB\xC6\xA9\x1E\x72\xC5\xB2\x7A\xC2\xBC\x09\x87\xBC\x57\xF6\x42\xD6\x18\xAF\x52\x91\xBD\x72\x35\xFA\xFB\xEC\x7A\xA1\x71\x44\x08\x21\x66\x03\xB8\x28\xD2\x1D\xF2\x2D\x87\x90\xEB\x66\x05\x73\xD4\x7E\x8A\xD0\x6B\x56\x48\x5E\xBC\xF5\x72\xED\xCB\x6A\x84\x10\x92\x3B\xB6\x11\xB9\x7C\x24\x7A\xB9\x0F\x5F\x80\xC3\x16\x17\xB6\x5E\x32\xD9\xEA\x85\xC6\x11\x21\xE4\xDA\xB1\x8F\xF5\x1F\x40\xE3\x88\xB8\x91\x60\x9C\xCF\x98\x5E\x9A\x91\xAB\x3B\x5C\x81\x17\x5B\x2C\x1F\x5F\x32\x59\xEB\xE5\xEF\xEC\xC9\x23\x84\x90\xF3\xA2\x44\x6C\x23\x72\x99\xE8\x28\xE5\x72\x62\x56\x1B\x3A\x21\x51\x98\xD9\xD6\xF2\x91\xBD\x5E\xB8\xE7\x88\x10\x72\xCD\xDC\xE3\xF8\x8A\x92\x7F\xC0\xD9\x3C\x19\x27\xE7\xF5\x2D\x07\x84\x1F\xAD\x27\x6E\x8A\xD4\x0B\x97\xD5\x08\x21\xD7\x8C\x8E\x6D\xC4\xC1\x8A\x8C\x21\x91\xFA\x73\xDD\x07\x17\x72\xBC\x9D\xF8\x29\x56\x2F\xF4\x1C\x11\x42\xAE\x19\xDB\x38\xE2\x1E\x10\x32\x85\x5C\xDE\x9A\xE3\x5A\x20\x09\x04\x4C\xE6\x53\xAC\x5E\x68\x1C\x11\x42\x08\x21\x7E\xE4\x0E\xCE\xB0\x5B\xDD\xC7\xA1\x61\x94\x9F\x22\xF5\xC2\x65\x35\x42\x08\x21\xC4\x8F\x1D\x75\x3D\xD6\xC3\x28\x57\x40\xD1\x30\xCA\x4F\x91\x7A\xA1\xE7\x88\x10\x42\x08\x21\xC4\x82\x9E\x23\x42\x08\x21\x84\x10\x8B\xAB\x8C\x73\xF4\xEF\xBF\xFF\xB6\x4E\x02\x21\xE4\xB2\x58\xE3\x78\xCF\x83\xEF\x12\x56\x42\xC8\x82\xB9\x4A\xE3\x88\x10\x42\x32\xF3\x88\x21\x98\xE4\x37\xE6\x5D\x26\x4A\x08\x69\x0C\x97\xD5\x08\x21\x64\x1E\x2B\x30\xCA\x36\x21\x17\x05\x8D\x23\x42\x08\x99\x87\xBE\xA7\x89\x77\xB3\x11\x72\xE6\xD0\x38\x22\x84\x90\x79\xD8\x5E\xA3\x1D\x18\x48\x92\x90\xB3\x87\xC6\x11\x21\xF5\x79\x07\xD0\x59\x0F\xC9\x4B\xCD\xF2\x5D\xE3\x38\x3A\xEF\x47\x61\x79\x53\x6C\x70\x9C\x67\xFB\x79\x6F\x94\x26\x72\x7E\xB0\x1D\xF5\xD0\x38\x22\x84\x90\x74\x6C\xAF\xD1\x01\xDC\x6F\x44\xC8\x45\x40\xE3\x88\x10\x42\xD2\xB1\xF7\x1B\x71\xAF\x11\x21\x17\x02\x8D\xA3\xEB\xE0\x6A\x5D\xA3\x84\x14\xE4\x0E\xC7\xB7\x81\xD3\x6B\x44\xC8\x85\x40\xE3\x88\x10\x42\xD2\xB0\x97\xD4\xBE\x61\xEE\x69\x22\x84\x5C\x00\x34\x8E\x08\x21\x24\x1E\xC6\x36\x22\xE4\x82\xA1\x71\x44\x08\x21\xF1\xE8\xD8\x46\x34\x8E\x08\xB9\x20\x68\x1C\x11\x42\x48\x3C\x3A\xB6\x11\xEF\x51\x23\xE4\x82\xA0\x71\x44\x08\x21\x71\xE8\xD8\x46\x3C\xA5\x46\xC8\x85\x41\xE3\x88\x10\x42\xE2\xD0\xB1\x8D\x68\x1C\x11\x72\x61\xFC\xDD\x3A\x01\x0B\x64\x0D\xE0\xA6\x7F\x6C\xF6\x30\x27\x52\x78\x35\xC0\x31\x32\x8B\x5E\xA9\xBF\xEF\x51\x26\x5A\xB0\xC8\x5A\xAB\xBF\x1F\x60\xEA\xA6\x94\xCC\xB1\x36\x21\xED\xA1\xC4\x29\xA5\x1B\x4B\xAE\x70\xE8\x65\x95\x90\x57\xBB\x1E\x5B\xC9\xCC\x81\xBD\xDF\x68\xEE\x5E\x23\x69\x57\xBA\x3D\x97\x6C\x5B\x80\x89\x84\x6C\xCB\x94\xBE\x93\x73\x79\x70\xAA\x7E\x25\x5F\x35\x74\x69\xE9\x7C\xAE\x7B\x19\xA5\xDE\xEF\x93\x3D\x35\x56\x2D\xB1\xFF\x6C\x60\xD2\x3A\xD6\xDF\xF7\xC8\xDF\xF6\x66\xD5\x0B\x8D\x23\xC3\x0D\x8C\xC2\xBB\xC3\x69\x43\xD3\xEC\x61\x14\x62\xAC\x52\x7C\xC7\x71\x65\xFD\x15\xF9\x7B\xC1\xBE\x0E\xE1\x03\xC0\x6D\xC0\xF7\x6C\x36\x13\x9F\xDD\x22\xBC\x43\xDD\x00\x78\xC4\x69\x9C\x97\x31\xB6\x30\x33\xEB\x39\x9D\x35\xA6\x7E\xD0\xCB\xFA\xE8\x65\xA7\x76\xB8\x98\x3C\x8A\xF7\xE0\x05\xF3\x14\xFE\x0A\x26\x9F\xF7\x70\xE7\xF3\x1B\xC0\x13\xE6\x7B\x2C\x6A\xD7\x63\x2B\x99\x39\xD1\xE9\x4E\xA9\x83\xD0\x7A\x06\x86\xB6\x95\xAB\x1C\x1E\xFB\x67\xAA\xEC\x77\x30\x6D\x2B\xB5\x1D\x6F\x60\xF2\xB5\x71\xC8\x10\xBE\x31\xE8\xD2\xD0\x7E\xBA\xC1\x74\xAC\x36\x5B\x1F\x96\xCE\xE7\x7D\xFF\xFE\xB1\xFA\x3B\xC0\xE8\x82\x97\xFE\xDF\x5A\xF7\xDB\x3C\x59\xDF\x0B\x41\x74\xE1\x3D\xDC\xE5\x2B\x69\x98\xA3\x03\x73\x20\xED\xE1\xCE\xF7\x45\x0C\x6D\x7C\xCE\x84\x23\x5B\xBD\x5C\xFB\xB2\xDA\x0A\xC0\x33\x80\x2F\x4C\x17\xA8\x66\x0D\xE0\x15\xC0\x27\x4E\x67\x7B\xD7\xC0\x23\x4C\x79\xF9\x3A\xA7\x70\x0F\xD3\x08\x9F\x67\xCA\x0B\xAD\x1F\xC0\x34\x78\xA9\xD7\x67\x84\xA5\xD3\x46\x7E\x1B\x9A\x47\x19\xEC\x44\x5E\x0A\x6B\x98\x36\xF5\x0C\x7F\x3E\x6F\x00\xBC\xC1\xB4\xC3\x54\x6A\xD7\x63\x2B\x99\xB9\xB1\x95\x7C\x8A\x17\x4F\xCA\x20\xA4\x9E\x81\xA1\x6D\xBD\xF7\x4F\x68\x1F\x18\xE3\x15\xFE\xFE\x70\x07\xD3\x0E\xF5\x69\x3C\x1F\x6B\x0C\x69\x0C\x31\x7C\x01\x93\x17\xBB\xAF\xE5\xA2\x64\x3E\xE5\xFD\xAF\x98\xAE\x0B\x19\x57\x3E\x3D\x69\x88\xC5\xD6\x85\xBE\xF7\xDA\x63\x5B\x88\x61\x92\x9B\x15\x8E\xDB\x43\x08\x77\x98\x37\xB6\x66\xAD\x97\x6B\x36\x8E\xA4\xF2\x1E\x13\x7F\x2F\xCA\xE0\x9A\x0C\x24\x51\x3A\x29\x3C\xC2\x34\xCA\x1C\xF2\x0E\x18\xBC\x43\xF2\x8C\xB1\xC2\xA0\x50\x42\xF9\x44\x7A\x9B\x00\x86\x7C\xC6\x28\x45\x69\x4B\xB1\x03\xDF\x3D\xD2\x0C\xA4\xDA\xF5\xD8\x4A\x66\x6E\x6E\x70\x7A\x4A\x2D\x86\x90\x41\xDB\xC5\x06\xA6\x1C\x52\x06\xBB\x47\x84\x1B\x02\x2B\x98\xB4\x4E\xCD\xAA\x35\xF7\x7D\xBA\x42\xBF\x3F\x25\x6F\x4E\xBF\x13\x4A\xE6\x13\xFD\xF7\x43\xDF\x2F\x13\xE9\x1C\xA4\xF6\x9F\x15\xCC\x44\x2A\xA7\xF1\xE9\x43\x26\x7A\xA9\xED\x21\x65\x6C\xCD\x5E\x2F\xD7\x6C\x1C\xDD\xE3\xB4\xF0\xF7\x30\x6E\xCE\xDF\x30\xCB\x5E\xF6\xF3\x1B\xA7\xEE\x3E\x69\x78\x39\x67\x07\xB9\xB8\xB5\x1E\x9B\xBD\xFA\x4C\x1E\xDF\x0C\x78\x4C\xE9\x1C\x60\xCA\xEB\x16\xA7\x65\x35\xE6\xB2\x5E\x23\xBC\x83\x8F\xC9\xDB\xF6\xEF\xFE\x35\x92\x7E\x5B\xAE\xCE\xCB\x53\xA0\xCC\x67\x8C\xEF\x65\x7A\xE9\x65\xFC\xC2\x90\x47\x49\xC3\x98\xDB\x3A\x56\x29\xBE\x63\x68\x43\x5B\x00\x7F\x46\x64\xFD\xC1\xF8\x60\x1C\xEA\xB2\x16\x6A\xD7\x63\x2B\x99\x25\xD0\xE5\x1C\xE3\xFE\x7F\x46\x9E\x01\x4A\x74\x4E\xCC\xC0\x21\x1E\x9A\x58\x42\xDA\xB0\xCC\xC6\x73\xF0\x8C\x79\x5E\x8E\x92\xF9\x04\x4C\xDA\x62\xEB\xF0\x0E\xF3\x27\xD0\x39\xDA\xCE\x6B\x86\x74\x84\x20\x06\xE7\x1C\x0F\xA7\xBC\x27\x74\xC2\x58\xA4\x5E\xFE\xEA\xBA\xA9\xAD\x29\x97\xCB\xBF\xFF\xFE\x2B\xFF\x2B\x6E\xBC\x03\x80\x07\x84\xAD\xE9\x6F\x70\x6A\x10\x85\xAC\x1B\xD7\xDE\x73\x34\xF7\x37\x36\x37\x38\xF5\xBE\xEC\x60\xCA\xCC\xB5\x9E\x2D\x8A\x53\x37\xDC\x90\xFD\x4D\x3F\x18\xCA\xF8\x00\x63\x1C\xC4\xEC\xB9\xD8\xC0\x0C\xCA\x62\xF0\x86\x7C\x5F\xEF\x65\x08\xC9\x23\x30\x28\x04\x51\xEC\x07\xB8\x0D\xCE\xB1\xB5\x6E\xDF\x6F\xEC\x74\xEA\xF6\xF7\x0D\xE0\x1F\xCF\xEF\x80\x36\xF5\xD8\x42\x66\xAE\xBE\xA6\xF9\xC2\xA0\xAC\x77\x30\x6D\x32\x04\xD7\x3E\x99\x14\x64\x82\x63\x97\x5F\x6E\x19\xC2\x03\xFC\x46\xA0\xCC\xF4\x73\x4C\x12\x0F\x30\x6D\x79\xAA\x6D\xB4\xCC\xA7\x5D\xFF\xB9\xF0\x8D\x1D\x39\xF3\xBB\x87\x99\x7C\xB8\x08\xDD\xD3\x35\xC5\x33\xF2\x78\x00\x63\x64\x16\xA9\x97\x6B\xF6\x1C\x01\x46\xC1\xFD\x03\xD3\x60\x42\x07\xDE\x0F\x98\x8E\x64\x53\xD3\x65\xD9\x02\xDD\xD8\xF7\x30\x03\x83\xCF\x68\x10\xA3\x53\x2B\x1D\x5F\xE7\xD1\x7B\x16\x5E\x10\xBF\x19\x55\x3A\x55\xA8\xD7\x48\xCF\x58\x3F\x10\x96\x47\x60\x30\xDE\xC4\x8B\x14\x62\xE4\x68\x42\x7F\x23\xE9\xB2\x19\x3B\xED\x34\x46\xED\x7A\x6C\x25\xB3\x04\xFA\xE4\x60\xCC\x92\x5A\xAE\xA5\x15\x91\xAB\x0D\xA3\x92\x84\xE8\xB6\x31\x63\x2D\x15\x7D\x2D\x4B\x2D\x7C\xF9\x0C\x3D\x0C\x92\x9B\x9C\xDE\xD2\x35\xCA\x8E\x55\xB2\x8D\x21\x27\xFA\xB4\xA1\xA6\x58\xBD\x5C\xBB\x71\x04\x98\x0E\x1D\xDB\xA9\x77\x38\x1E\xC8\x42\x07\xA7\x73\x45\x2B\xAB\xD0\x19\xB3\xF0\x84\xD3\x59\xAE\xAB\x41\xEB\xCF\x6A\x5C\xCD\xA0\x95\x86\x36\x80\x43\x78\x80\x31\xB6\x63\x0D\xA3\x97\xC8\xDF\x8C\x9D\xE8\x08\x59\xDF\xAF\x5D\x8F\xAD\x64\x96\xC0\x6E\x1F\x31\xB1\x8D\x42\xD3\x2B\xA7\xA7\xE4\x19\x3B\xF9\x28\x4B\xAE\xA9\x46\x88\x2C\x11\xDB\x32\x7C\xEF\x1A\x3B\x8A\x3F\x86\x36\x90\xE4\x44\xA5\xDE\xA2\xF0\x0B\x7E\xAF\x61\xEA\x5E\x15\xA1\x44\x3E\x7D\xFA\xDD\x5E\x26\xBE\xC5\xF4\x32\x78\x0C\x3A\xD8\xA8\xE6\x1B\x83\xCE\x91\xF2\xFD\x03\xB7\x2E\x29\x69\x1C\x85\x1A\xD2\x76\x3B\x0F\x99\xF4\xBA\xDE\x5B\xAC\x5E\x78\x94\x3F\x9D\x1D\x8E\x2B\x66\x83\xCB\xBC\x95\x5B\x1F\xC9\xDD\x21\xFE\xF8\xEB\x01\x46\xB1\xDB\xB3\x8A\x0D\xC2\x8D\x9E\xD2\xB3\x64\xAD\x8C\x53\xF2\x28\xA4\xA4\x35\xE5\x88\xF6\x16\xC7\x4A\x63\x03\xBF\x7B\xBE\x76\x3D\x2E\xA1\xED\xE4\x22\xF5\x92\x59\xDF\x40\x2F\x9E\xB4\xB1\x72\x79\x82\xA9\xE3\x67\x0C\x4B\x91\xA9\x4C\x79\x77\x5E\xE0\xDF\xFC\xBA\x46\x58\x1B\x15\x19\xAE\xB6\x28\xF5\xB9\xC7\xF4\x52\xDC\x1C\xE3\xA8\x54\x3E\x5D\xBF\x9B\xF2\x16\xEF\x10\xB7\x51\x58\xE3\xF2\xA0\x4D\xE5\x53\x8E\xC3\x4F\xE5\x55\x3C\xA0\x25\x62\x4C\xF9\xEA\x6D\xCC\x13\xFC\x82\xF1\xAD\x02\xA1\xEF\x2D\x56\x2F\xF4\x1C\xA5\x73\x89\x86\xD0\x18\x63\x9B\xD6\x53\xD0\x4A\x27\x66\x7F\x42\xE9\x0D\xEF\xB9\xF2\x98\x4A\x8A\x71\xA4\xD3\xE8\xF3\x4E\xB4\xA8\xC7\x25\xB4\x9D\x1C\xE8\xD0\x03\x31\x1E\x01\x97\x62\x17\xE5\xED\x1A\xA8\xB6\x30\x9E\x81\x39\x86\x11\x70\xEA\x81\xB3\xD3\xE0\xF3\xE6\xC5\x78\xC5\xF7\x08\x8B\xDB\xB3\xC7\x74\x39\xCE\xA9\xDF\x52\xF9\x74\xD5\xA3\x18\x7B\x53\xE9\x49\xC5\x95\x1E\x97\x07\x51\xBC\x25\x53\xCC\xF5\xCC\x4D\xE1\x4A\xAF\x2B\x36\xE0\x07\xDC\x6D\x66\x2C\x70\xA4\x50\xAC\x5E\x68\x1C\x91\x58\x52\x07\x38\xFD\x3B\xDF\xA0\x61\x53\x7B\x4F\xD7\xB9\x18\xBE\x7A\x69\x37\xF5\xB7\x73\x7E\x17\xA3\x68\x5B\xC8\xCC\x81\x2D\x2F\x36\xB6\x91\x6B\xC0\x08\x59\xEE\x41\xE0\x77\x7C\xBF\x77\x19\xE0\xA5\x22\xCB\xFB\xC8\xED\xBD\x68\x95\x4F\xD7\x3B\x7D\x69\x72\x31\xD5\xCE\x43\x3C\xB0\x1F\x98\x6E\xA7\xA5\xB6\x80\xB8\x8C\x5A\xDF\x84\x22\x64\xD3\x7F\x2C\xB3\xEA\x85\xC6\x11\xA9\x45\x8C\x82\xD7\x8D\xF6\x19\xF1\xC7\x97\xAF\x81\x16\x91\x6F\xAF\x45\xA6\x30\x37\xB6\x91\x8B\x5A\x06\xC9\xB9\x18\xFB\x73\x69\x95\xCF\xDA\x86\x65\x68\x3E\xA7\xD2\xD5\x62\xCF\x9E\xAF\x8C\x4A\xF4\xF1\x59\xF5\xC2\x3D\x47\x86\x3B\x0C\xBB\xE2\x39\x00\xB7\xE7\x1B\x66\x56\x6D\xEF\x33\xB9\xC3\x30\x48\x49\xA3\xD7\xF7\xF1\xC8\xBF\xAF\x65\x30\x20\xE5\x99\x13\xDB\xC8\xC7\xA5\xB5\x53\x31\x24\x45\x8F\xB6\x18\x84\x4B\xB0\xB4\x31\x21\xD4\x73\x3A\x95\xEE\x12\x9E\xD7\x16\x65\x54\x54\xE6\xB5\x1B\x47\x12\xAC\x6F\x69\x8D\x9F\x98\x35\x61\xB9\x3A\x41\xB3\x51\xFF\x1D\x23\xC7\x3D\x3D\x84\xD8\xED\x6F\x87\xB8\x19\x6E\xED\xE5\xBF\x96\xE4\x8E\x6F\xB3\x24\x5A\x04\xF9\xF5\xED\x7F\x5A\x5A\xDB\x6A\x51\x46\x45\x65\x5E\xF3\xB2\xDA\x35\x5E\xFF\x71\x6E\x3C\x20\xFD\x48\xAC\x04\xF8\xCC\x15\x9C\x8E\x5C\x1F\x73\x62\x1B\x5D\x13\x73\xAF\xDC\x21\xA7\x50\x67\x35\xE6\x5A\x3D\x47\x12\x9A\x5C\x37\xC0\x3D\x8C\xB7\x21\x64\x76\x28\xB7\x23\x93\xB2\xC8\x8D\xE4\xC0\x10\x33\x66\xD5\x3F\x62\xD8\xDA\xFF\xAF\x91\x88\xAF\xBE\xC8\xB0\x84\x68\x52\x63\x1B\xD9\xBF\xB9\x74\x1E\xC1\x09\x26\xB9\x40\xAE\xD5\x38\xD2\x47\x73\x53\xAF\xA7\xA0\x71\x54\x97\x90\xAB\x2A\x24\x0A\xAC\xED\x76\x5E\xC3\x28\xF1\x90\x23\xC6\x84\x08\xA9\xB1\x8D\x84\x4B\xDB\x53\xA4\xC9\x79\xAF\xDA\x92\x69\x61\xE4\x9E\x5B\xDB\x29\x11\x37\xC9\x47\xD1\x7A\xB9\x56\xE3\x68\x2C\x6A\x6F\x8B\xA3\xAC\x24\x2F\xDF\xFD\xB3\xC3\xE9\x8D\xF5\x77\xA0\x71\x44\xC2\x99\x13\xDB\x28\x94\x0D\xCE\x5B\xEF\xF8\xAE\xF9\xD8\xC2\x3D\x68\x2E\x71\xEF\xCC\x18\x2D\x0C\x15\xD7\xC0\xBF\xC5\xF2\x96\x78\x5B\x18\x47\x45\xEB\xE5\x5A\x8D\x23\xDB\x0D\x2C\x4B\x69\xA4\x2C\xB5\x4F\xAE\x6C\x71\x7C\x97\x10\x5D\xFF\x79\x68\x71\x02\xA9\x85\xCC\x39\xB1\x8D\x42\x09\x8D\x3C\xBD\x54\x5C\xFB\x62\x42\x2E\x08\x06\xCE\xC3\x38\xF2\x51\xDB\xC8\x5D\x55\x96\x97\x83\x3B\xB8\x0D\xBA\x12\x7D\x7C\x56\xBD\x5C\xF3\x86\x6C\xA1\x55\x23\x3B\x97\x63\xAE\x7A\x06\x93\x6A\x64\xE8\xDF\xD5\x28\x77\x3D\xA0\x85\x6E\x72\xBC\x44\x43\xAA\x45\x3D\x9E\x6B\xDB\xC9\x19\xDB\xC8\x95\xD6\xD0\xFD\x3A\xFA\x22\xE6\xA5\x30\x95\xF6\x6B\x9B\x70\xBA\x0C\xBC\x95\xE7\x73\x17\x53\x06\x79\xAB\x4B\x70\x7D\x6D\xD0\xE5\x3D\xF2\x79\x19\x7D\x9F\xA7\xB4\xA7\x59\xF5\x42\xE3\xA8\x1E\x39\xA2\xFC\xB6\x98\x65\xE9\x74\xA7\xDE\x98\xAD\xD3\x5E\xC3\x0D\xAB\x07\xE7\xA9\xCE\xDD\x3A\x02\x73\x0D\x5A\xD4\xE3\xB9\xB6\x9D\x9C\xB1\x8D\x5C\x4A\x5D\x0E\x86\x4C\xB5\x37\xB9\xE5\xFC\x0D\x97\x79\xEA\xF2\x9C\xF2\x93\x6A\xE4\xCE\xD9\x93\xE5\x92\xE9\xBA\x8B\x4C\x58\x21\x6F\xA8\x1A\xDB\x13\x3F\x86\xCB\xBB\x7A\x87\xE9\x13\x8D\x8F\x70\x97\x93\xAB\xBF\x17\xAB\x17\x1A\x47\xF5\x06\x42\x5D\xC1\x29\x03\x45\xEA\xE0\x32\x87\x3D\x8E\xD3\xBE\x46\x7C\x99\x8D\x9D\xEC\xAB\x31\xB3\xD4\x1D\x63\xAA\x93\xE9\x13\x8A\x73\xF6\x42\x2C\x55\xE1\xB7\xA8\xC7\x73\x6D\x3B\x73\x62\x1B\x69\x7C\x69\x15\x03\xE9\x13\x43\xAC\xA0\xC7\xFE\x6F\x3F\x18\x94\xB8\x84\x1E\x59\x52\xFB\x72\x5D\x4F\xE1\x3B\xAC\x72\x6E\x07\x5A\x7C\xCB\xAA\x52\x7F\xA2\x3B\xEE\x61\xEA\x6B\x4E\x1E\x5D\x6D\x67\xDD\xCB\xD4\x7B\xE3\xE4\xB3\x47\x00\x5F\x56\x3A\x72\x19\x48\xAF\x00\xBA\xFE\xD1\x7D\xD9\xD7\xD6\x9F\xFB\x34\x49\x3B\xB7\xFF\xED\xC2\xE5\xB9\x2D\x56\x2F\xD7\x6A\x1C\xD9\x05\xBA\x46\x9A\xD1\x11\xAB\xA4\x74\x05\x6F\x10\x17\x1B\x24\x97\x32\x49\x51\xAE\x7A\xE6\xFC\x1C\xF9\x9E\x57\xF5\xEF\x2D\xDC\x03\xCE\x0A\xA6\x51\xCF\x31\x5C\x75\x00\x49\x5F\x27\xD2\xF5\x13\x9B\x47\xC0\xB4\x23\x51\x48\x4B\xA4\x76\x3D\xB6\x92\xA9\x89\x19\x18\x72\xC7\x36\x0A\x5D\x62\x92\x01\xED\x19\x83\x32\x1F\xFB\xCE\xD2\x0C\xA4\x29\x5E\x61\xBC\x1B\x8F\xEA\x79\x86\xE9\xDB\xE7\x92\x0F\x21\xA4\x1D\x88\x51\xFB\x0E\x93\xFF\xB9\x13\x6F\xD7\xFD\x68\x80\x69\xA7\xAF\x30\x46\xF4\x57\x2F\xB7\xC3\x60\x10\x48\xF9\x8A\x01\x5E\x5A\x2F\x85\x4C\x24\x6E\x30\xB4\x83\x47\x84\x2D\x0F\xBA\x3C\xB7\xC5\xEA\xE5\x5A\x8D\x23\x5D\xA0\xAF\x88\x33\x90\xA4\x82\x63\x38\x60\x7C\xA0\x08\x79\xCF\x06\x46\xD1\xA4\xA2\x67\xEF\xB1\xC6\xA0\x1E\x90\x44\x49\xFB\x1A\xF6\x0A\x26\xDD\xBA\x31\xFA\x4E\x8D\xC9\x4C\x47\x1A\x74\xAC\x92\x19\x1B\x44\x7C\x4B\x23\x3A\x4D\x31\x41\x42\xE5\x48\xB3\xB8\xBA\x5F\xB1\x4C\x03\xA9\x76\x3D\xB6\x92\x39\x76\x37\x5F\xE8\x40\x3C\x37\xB6\xD1\x18\x73\x6E\x66\xD7\x2C\xC9\x40\xF2\x19\x7D\x77\x18\x8C\x3D\x79\xCE\x35\x2E\x92\xF6\x82\xD6\x22\xB4\xED\xDC\xC0\xBF\xC7\x26\x44\x2F\xCD\xF1\xCA\x1E\x90\xFF\x44\xB0\xEF\xC4\x63\xB1\x7A\xB9\x56\xE3\x48\x2B\x6C\x51\xC4\x12\xE9\x75\x33\xF2\xC8\x9A\xE9\x3B\x8C\x95\x9E\xD2\xC1\xC7\x6E\xE1\x16\xD7\xA2\xC8\x95\x20\x87\xB6\x0B\x50\x94\x61\xAA\x7B\x5F\x37\xF8\xB7\x5E\xAE\xC4\x03\xDA\xC0\xAD\x6C\x0F\x30\xD1\xAA\x6D\xD6\x7D\xBA\xC5\xB0\xDC\x58\x7F\x17\xA5\xF8\x85\x53\x43\xEC\x09\xEE\xC6\xAC\x95\xA7\x04\x71\xFC\x1C\xF9\xCC\x66\x85\x21\x2A\xF6\xA7\xFA\xDE\x1E\x7E\xE3\xE8\x1B\xA7\x8A\x48\x5C\xD7\x6F\x18\xCA\xCA\xAE\x1F\x91\x27\xF5\xA7\x7F\xBB\x34\x6A\xD6\x63\x4B\x99\x63\x5E\x5A\xBD\x6C\x35\x35\x48\xCC\x8D\x6D\x34\xC6\x1E\x79\x0D\xA4\x1B\x2C\xE3\x40\xC7\xB5\x6D\xBC\xCE\x59\x87\xA1\x7C\x20\xAF\xC1\x11\x32\x51\x98\xD3\xEE\x5F\x90\xEF\x64\xE7\x98\x4E\x1E\xA3\x48\xBD\x5C\xEB\x51\xFE\x03\xCC\x51\x53\x3D\x03\x2B\x7D\xF1\xAC\x54\xB6\x5E\x2A\xB8\x81\x7F\xDD\x55\xD2\xFC\x99\x20\xF7\x05\xA7\x83\x81\x1E\xCC\x7D\x47\x6F\x77\x30\x83\x9C\x4E\xFB\xFD\xC8\xBB\xA7\xD8\xC2\xDF\xD1\xE5\x08\xBE\x1E\x18\x75\xDD\x48\x4C\x23\xC0\x3D\x63\xDA\xC3\xE4\x2D\x84\x17\x8C\xEF\x71\xB1\x2F\xBD\x0D\x61\x8B\x53\x83\x60\x29\xD4\xAA\xC7\x96\x32\xC7\x2E\x2E\xD6\xDE\xDE\xB1\x7B\xF7\x4A\xC6\x36\x92\xB4\xCF\x0D\x9A\x28\x7A\x60\x29\x41\x02\x9F\x90\xA6\x93\x00\x93\x97\x25\x78\xC0\x42\xD9\xC1\xB4\x99\x18\xAF\xB0\xE8\xD4\x39\x4B\x6C\x32\xF8\xCF\xBD\xA2\x65\x0F\x13\xD3\xCF\x37\xC9\x7E\xC1\xBC\x13\x92\x32\xB6\xCE\x19\x4B\xBF\x11\x96\x56\xA0\x50\xBD\x5C\xAB\xE7\x08\x18\x06\xCD\x14\x97\xDC\xD8\x12\x59\x28\x32\x70\xC6\x78\x81\x24\xAD\xA9\x0A\xF1\x1B\x79\x06\xEB\x2D\xC2\x1B\xAC\xCD\x01\xA6\x83\x87\xA4\x41\xA2\x95\xFB\x8C\x35\x71\x23\xBB\x94\xCE\x4B\xFF\x9E\x98\xF4\x3E\xC0\xA4\x35\xC5\x4B\x17\x93\xCF\x96\xD4\xA8\xC7\xD6\x32\x5F\x10\xEF\xD5\x28\x1D\xDB\xE8\x05\xA6\x0C\x52\x97\x01\xB6\x00\xFE\xC1\x72\x0C\x23\xC0\xA4\x25\x56\x9F\x01\xA6\x2C\xCE\x31\x28\xEB\x03\xC2\xD3\x2D\xC6\x48\x0E\x9E\x90\xDE\x76\xA4\x0F\xFD\x0E\xFC\xFD\x37\xE2\xF5\xA6\x96\x77\x8B\xF4\xFA\xDD\xC1\xA4\x35\xA6\x9D\x67\xAF\x97\x6B\x36\x8E\x00\x53\x48\xBF\x61\x1A\x4E\x48\x45\x88\x7B\xFC\x1F\xCC\x9B\x55\x6E\x7B\xB9\xBE\xCD\xA5\xA2\x78\x62\x1B\xCA\x94\xCC\x5B\xCC\x9F\x0D\xEF\x60\xF2\x1F\x52\x66\xE2\x29\xFB\x8D\xF8\x8E\xF2\x01\x93\xDE\x50\x59\xC2\xBE\x97\x25\xBF\x4B\xE9\xE0\xF6\xEF\x63\xDB\xC5\xB9\x28\xFC\x5A\xF5\xD8\x4A\xA6\x28\xE8\x07\x84\x19\x49\x39\x63\x1B\xB9\x90\x32\x78\x08\x94\x21\x5E\x30\xF9\xCD\x12\xEF\x6B\x0B\xD5\x67\x32\xA9\xBC\x45\x9B\x25\xAA\x5C\x3C\xC1\x3D\x79\x3B\x58\xDF\xC9\x59\x5F\xB1\x6D\x47\x3C\xB6\xBF\x10\xDF\x87\xF6\x18\xFA\x6A\xCA\xD2\xA9\x94\x81\xE8\x44\x9F\x51\x66\xB7\x8D\x94\x49\x14\x90\xB9\x5E\xFE\xEA\xBA\x2E\x21\x0D\xE7\xCD\xBF\xFF\xFE\x3B\xF5\x91\x7D\x81\xA9\xFC\x57\x94\x78\xC9\xB5\x75\x7B\xCF\xC5\x37\x4C\xC5\xED\x51\x56\x11\xEA\xCB\x5A\x53\xE5\xC9\x7B\x56\x30\x03\x8C\xA4\xDF\x5E\xF6\xCA\x89\xC8\x12\x79\x22\x0B\x28\x57\x47\xAE\x76\x51\xBA\x9E\x6A\x51\xBB\x1E\x5B\xC9\x9C\x42\xC7\x5A\xF9\x85\x7A\xF5\x6A\xF7\x7F\xE0\xFC\xDB\x96\xD4\xA9\x9D\x1F\xD1\x69\x97\x86\xE4\x53\xF6\x80\x7D\xE3\x54\x0F\xB9\x0E\x95\x3C\x61\xDE\x84\x43\xDE\x2B\x7B\x21\x6B\x8C\x57\xA9\xC8\x5E\xB9\x1A\xFD\x7D\x76\xBD\xD0\x38\x22\x84\x10\xB3\x01\x5C\x14\xE9\x0E\xF9\x96\x43\xC8\x75\xB3\x82\x39\x6A\x3F\x45\xE8\x35\x2B\x24\x2F\xDE\x7A\xB9\xF6\x65\x35\x42\x08\xC9\x1D\xDB\x88\x5C\x3E\x12\xBD\xDC\x87\x6F\x03\x7E\x8B\xF0\x00\x97\x4C\xB6\x7A\xA1\x71\x44\x08\xB9\x76\x4A\xC4\x36\x22\x97\x8B\xC4\x9A\x7A\xC6\xF4\xD2\x4C\x48\x5C\xA1\x16\xCB\xC7\x97\x4C\xD6\x7A\xB9\xD6\xA3\xFC\x84\x10\x22\x94\x88\x6D\x44\x2E\x13\x1D\x84\x53\x4E\xCC\x6A\x43\x27\xE4\xE8\x3E\xDB\x5A\x3E\xB2\xD7\x0B\x8D\x23\x42\xC8\x35\xA3\x63\x1B\x71\xC0\x22\x53\xB8\xA2\x93\xC7\x06\xE6\xA4\x87\x32\x1F\x45\xEA\x85\xCB\x6A\x84\x90\x6B\x46\xC7\x36\xE2\x32\x07\x19\x43\x22\xF5\xE7\x0A\x5A\x19\x72\xBC\x9D\xF8\x29\x56\x2F\x34\x8E\x08\x21\xD7\x8C\xC4\x56\x91\xF8\x2A\x84\x8C\x91\xD3\x70\x8E\x8D\x30\x4F\xA6\x29\x56\x2F\x34\x8E\x08\x21\xD7\xCC\x87\xF5\x70\x26\x4F\xA6\x90\xA0\xA2\x73\x8F\xDD\x2F\xF9\x6A\xA1\x73\xA4\x58\xBD\xD0\x38\x22\x84\x10\x42\xFC\xD8\x51\xD7\x63\x0D\x69\xB9\x02\x8A\x86\x51\x7E\x8A\xD4\xCB\x55\x06\x81\x24\x84\x10\x42\x08\x99\x82\x9E\x23\x42\x08\x21\x84\x10\x0B\x1E\xE5\x27\x84\x10\x72\x2E\xAC\x71\x7C\xC2\xD0\x77\xD9\x2D\x21\x49\x70\x59\x8D\x10\x42\xC8\xB9\xF0\x86\x21\x68\xE7\x37\xCC\xAD\xEF\x84\x64\x87\xCB\x6A\x84\x10\x42\xCE\x81\x15\x18\xCD\x9C\x54\x82\xC6\x11\x21\x84\x90\x73\x40\xDF\x87\xC5\x08\xD3\xA4\x18\x34\x8E\x08\x21\x84\x9C\x03\xB6\xD7\x68\x07\xC6\xA5\x22\x05\xA1\x71\x44\x08\xB9\x44\xDE\x01\x74\xD6\x43\xF2\x52\xBB\x7C\xD7\xFD\x23\xD8\x41\xFF\x36\x2A\x2D\xF6\xF3\x5E\x28\x3D\x3A\xFF\xF6\xF3\x58\x48\x66\x0B\xAE\x25\x9F\x27\xD0\x38\x22\x84\x10\xB2\x74\x6C\xAF\xD1\x01\xDC\x6F\x44\x0A\x43\xE3\x88\x10\x42\xC8\xD2\xB1\xF7\x1B\x71\xAF\x11\x29\x0E\x8D\x23\x42\xF2\x50\xC3\x95\x4F\xC8\x35\x72\x87\xE3\x5B\xD7\xE9\x35\x22\xC5\xA1\x71\x44\x08\x21\x64\xC9\xD8\x4B\x6A\xDF\x30\xF7\x61\x11\x52\x14\x1A\x47\x84\x10\x42\x96\x0A\x63\x1B\x91\x26\xD0\x38\x22\x84\x10\xB2\x54\x74\x6C\x23\x1A\x47\xA4\x0A\xBC\x5B\x8D\x10\x42\xC8\x52\xD1\xB1\x8D\x96\x72\x8F\xDA\x13\x8E\xF7\x41\xD9\x30\xFE\xD2\x05\x40\xE3\x88\x10\x42\xC8\x12\xD1\xB1\x8D\x96\x74\x4A\x8D\xFB\x9E\x2E\x1C\x2E\xAB\x11\x42\x08\x59\x22\x3A\xB6\xD1\x92\x8C\x23\x72\xE1\xD0\x73\x44\x5A\xB0\x06\x70\xD3\x3F\x36\x7B\x18\x97\x34\xDD\xD2\xA7\xC8\x2C\x5A\xBB\xF2\xF7\x38\x8E\x16\x9C\x53\xDE\x0A\xC7\x33\x77\xC0\x0C\x52\xDF\x05\x65\x8E\xB5\x0B\x69\x13\xB9\x67\xEB\x37\x96\x4C\xE1\xD0\xCB\x29\xE1\x19\xA8\x5D\x87\xAD\x64\xE6\xC2\xDE\x6F\x94\x6B\xAF\xD1\x0A\x26\xA2\xB6\x5D\xE7\x4B\x2E\x8B\x0D\x8E\xFB\xA0\xF4\xBD\x1C\xCB\x8B\xEB\xFE\xFD\x25\xDE\x1D\x22\x7B\x6A\x0C\xA8\x55\x17\x37\x38\x3D\x09\x39\xE4\xBF\xEB\x3A\x3E\x7C\x6A\x3C\x37\x5D\xD7\x3D\x77\x5D\xF7\xD5\xF9\xF9\xEC\xBA\xEE\x3E\x51\xCE\xBB\x7A\x57\x6A\x7A\x6D\xDE\x03\xBE\x13\xC2\x26\x32\x0D\x37\x5D\xD7\xBD\x76\x5D\xF7\x13\xF0\xEE\xD7\x84\xF7\xCF\xA9\xA3\xAE\x33\xE5\xF2\xD8\x75\xDD\x6A\xA6\xCC\xD0\x3C\xFE\xF4\xDF\xBD\x09\x78\xEF\x54\x3B\x58\xF5\x69\xF6\xE5\xF1\xAB\xEB\xBA\xBB\x19\xF9\x6A\x55\x87\xB5\x64\xE6\xEA\x67\x53\xCF\x9D\x7A\xFF\xDA\xF1\xDD\x8D\x23\x7F\x76\xDF\x7D\xEC\xA6\xCB\xE4\xAB\xFF\x3C\x35\xFF\x36\xAE\xF7\xE4\x48\x6B\xD7\x75\xDD\x5B\x17\xD6\x0F\xC6\x9E\xFB\x6E\xBA\xFD\xFF\xA8\xF4\xA7\xE6\x73\xAA\x5D\x3E\x7B\xF2\x65\xA7\x21\x56\xAF\xB8\xCA\xB6\xEB\x86\x76\xBE\xEA\x4C\xF9\x4D\xF1\xDA\x75\xDD\x2A\x77\x83\xE6\xC3\x47\x3F\xAB\xCE\x74\x88\x14\x3E\x3B\xB7\x52\x1C\x7B\x2E\xC5\x38\x7A\x4C\x78\x7F\xD7\x99\xB2\x4E\xC9\x6F\xAA\xBC\xAE\x33\xCA\xEC\xB9\x8B\x57\x66\xA9\xED\xA2\xEB\xFC\xF9\x1C\x6B\x07\xEB\x2E\xDC\xF0\x13\x5E\x3D\x72\x96\x54\x87\x35\x65\x96\x36\x8E\xEC\xC1\xEB\xD3\xF3\xDD\x10\x83\xE3\x35\xB0\x1C\x3E\xBB\xB0\x76\x5C\xD2\x38\x0A\x4D\xEB\x4F\x17\x3F\x89\x8C\x2D\x87\x5C\xC6\x51\x4A\xBB\xFC\xE9\xE2\x26\x28\x21\xC6\xD1\xBA\x0B\x9B\x34\x7C\x72\xCF\x11\x29\xC9\x0A\x26\x5A\x74\xEA\x05\x85\xEB\xFE\xF7\x7A\x69\xE7\xD2\x79\x05\xF0\x9C\xF8\xDB\x47\x00\x9F\x99\xE4\x1D\x60\xDC\xCC\xF6\x33\xC6\xAA\x97\xFB\x15\x21\xF3\x13\xF3\x2E\xAE\x94\x7C\x4E\x9D\x18\xD2\x48\x5B\xD2\x6E\x7C\x1F\xF7\x30\xE5\x13\x4B\xED\x3A\x6C\x25\xB3\x04\x7A\xB9\x63\xEE\x5E\xA3\x67\x9C\x86\x04\x98\x62\x0D\xE0\x6D\xA6\xBC\x39\x3C\x22\x3C\xAD\x2B\x98\x3A\xDF\xF8\xBE\xD8\xF3\x1A\xF1\xEE\x35\xD2\xDA\xFD\x94\xDC\x94\x76\xB9\x82\xA9\x8B\xD0\x34\x87\xBE\x2F\x44\x67\xEC\x68\x1C\x91\x92\xDC\xE3\xD4\xB0\xD9\xC3\x1C\x83\xFD\x0D\xE0\x2F\xF5\xFC\xC6\xE9\xDE\x82\x98\x06\x5D\x9B\x5B\xEB\xB1\xD9\xAB\xCF\xE4\x09\xD9\xC7\x32\xA6\x1C\x0F\x30\x65\x76\x8B\xD3\xF2\x7A\xC2\xE9\x1E\xAD\x35\xC2\x95\xD1\x98\xBC\x6D\xFF\xEE\x5F\x23\x79\xB0\xE5\xEA\xFC\x3C\x05\xCA\x7C\xC6\xF8\x5E\xA6\x97\x5E\xC6\x2F\x0C\x79\x94\x34\x6C\x71\xBA\x17\x22\x46\x81\xBF\x63\x68\x43\x5B\x00\x7F\x46\xE4\xFC\xC1\xF8\x40\x7C\x8F\xE3\xC1\xDA\x47\xED\x3A\x6C\x25\xB3\x14\xBA\xAC\xE7\xEC\x37\x5A\x23\xDE\x08\xDF\x24\xFC\x26\x07\x37\x48\x2B\xFF\x90\x3E\x70\x87\x78\x23\xE3\x0E\xF3\x27\xA6\x31\x86\xE9\x14\xAF\x19\xD2\x21\x69\x09\x99\x1C\x7D\x00\x78\xC9\xED\x0A\xE5\xC3\x47\x3F\x77\x9D\x71\x63\x7E\x75\xE1\xCB\x4A\x9B\xEE\xD4\xF5\x19\xEA\xC2\xAD\xB9\xAC\x36\xE7\xFB\x63\xCF\x4D\x77\xCA\x5B\xE7\x77\xF3\xAF\xBA\x71\x77\x79\x48\x79\xDB\xE5\xFC\x13\xF8\x1B\x5D\x57\xEF\x5D\xF8\xB2\xCC\x98\xEB\x3B\x24\x8F\x92\x4F\x7B\xB9\xE5\xA7\x9B\x5E\x76\x1D\x5B\x0E\x70\x7D\xDF\xD7\xFE\xBE\x02\xF3\xD7\xA2\x0E\x5B\xC8\x2C\xB9\xAC\x66\x2F\x7D\xBE\x05\x7C\xDF\xB7\x9C\x92\xC2\x4F\xE7\x2E\xBF\x12\xCB\x6A\x73\xF0\x2D\xAF\xC5\x2E\x27\x87\xE0\xD3\xC9\x39\xF3\xEA\x5B\x5A\xCD\x25\xEF\xBF\x7A\xA7\xE7\x88\x94\x66\x07\xE0\x1F\x98\xD9\x6A\xE8\x29\x84\x0F\x00\x0F\xEA\x6F\xB9\x5C\xAB\x4B\x46\xCF\x56\xF7\x30\xDE\x0C\xDF\xE9\x91\x03\x4C\x79\xE9\x19\xB6\x6F\xF6\xAB\x2F\xF4\x7C\x41\xFC\x49\x91\x0F\x18\xCF\x44\xA8\xD7\x48\x7B\x05\x3E\x10\x96\x47\xF4\xDF\xF9\x83\xC1\x8B\x14\xEA\x8D\x13\x42\xBF\x2F\x69\xB2\x91\x93\x6D\x3E\x6A\xD7\x61\x2B\x99\xA5\xD0\xA7\x07\x5B\x1D\xDF\xD7\xD7\x96\x2C\x1D\x97\x7E\xBC\x43\xFC\x72\x72\x0E\x72\x7A\x21\xD7\xA8\x33\x06\x3C\xA0\xEF\x37\x34\x8E\x48\x0D\x0E\x88\x3F\x1E\xBA\xC3\xF1\x40\x16\x3A\x38\x9D\x33\x5A\x19\xEB\x01\xDA\xC7\x13\x8E\xCB\x59\x1F\x59\xD6\xE8\xCF\x6A\x5C\xCD\xA0\x15\x9C\x36\x82\x43\x78\x80\x31\xB8\x63\x0C\xA3\x97\xC8\xEF\x7F\xE0\xB4\x3C\x42\xF6\x76\xD4\xAE\xC3\x56\x32\x4B\x61\xB7\x8F\x9C\xB1\x8D\xC4\xE0\x95\xE5\xE1\xFF\x06\x41\x07\xA1\x7B\x79\x72\x23\x4B\xCC\x4F\xFD\xF3\x02\x7F\x5A\xC7\xC2\x35\xD8\x9F\xF9\xE4\xC9\xF2\xEB\x2D\xA6\x97\x97\x63\xD0\x01\x3C\x35\xDF\x18\xFA\xB1\x2C\xF7\xFE\x81\xBB\x8F\xE6\x32\x8E\x74\xF9\x6E\xAD\xBF\xFD\x97\x6F\xC6\x39\x22\x4B\x66\x87\xE3\x0E\xB6\xC1\xE5\x46\xA6\xDD\xE0\x58\xB9\xED\x10\x1F\xEF\xE9\x00\xD3\xD1\xED\x99\xFF\x06\xE1\x46\x4F\xE9\xF8\x26\x7A\xB0\x49\xC9\xA3\x10\x9B\xD6\x94\xD8\x29\x5B\x1C\x2B\xE4\x0D\x8C\x02\x9D\xA2\x45\x1D\x2E\xA1\xDD\xE4\xA4\xC4\x25\xB3\x3B\x8C\x1B\x8C\x7B\x1C\xEF\x45\xD3\xB4\x98\x8C\xC9\x7E\x45\xDD\xBE\x5F\xE0\x3F\x9C\xB2\xC6\x78\x3B\x77\xFD\x66\xCA\x03\xBB\x43\xDC\x06\x6E\x8D\xCB\xEB\x36\x95\xC7\x1D\x4C\xFA\xA7\xF2\x29\x5E\xC5\x39\x71\xF0\xA6\x64\x6F\xF5\x7B\xE9\x39\x22\x4B\xE6\x52\x0D\xA1\x31\xC6\x36\xAE\xA7\xA0\x95\x63\xCC\x46\xF6\xD2\x9B\xDE\x73\xE5\x31\x85\x14\xE3\x48\xA7\xCF\xE7\x4D\x69\x51\x87\x4B\x68\x37\xB9\xB8\xC7\xA9\xA1\x97\x83\xA9\x25\xDF\x3D\xDC\xC6\x6E\x0B\xEF\x99\xF6\xE2\x09\xB2\xA4\xEC\x62\xCA\x08\x72\x79\xC0\xB6\x98\x6E\x33\xA1\x4B\xE5\x31\x69\x01\xDC\x4B\xBE\xE2\xC5\x9A\x62\x8E\x37\x4F\x0C\xC1\x31\xD9\x7B\xFD\x77\x1A\x47\x84\x2C\x93\xD4\x41\x4E\xFF\xCE\xA5\x4C\xB4\x92\xA8\xBD\xAF\xEB\x1C\x8C\x5F\xBD\xB4\x9B\xFA\xDB\x39\xBF\x8B\x19\x10\x5A\xC8\xCC\x85\x2D\x33\x57\x94\x72\x5F\xC4\x7D\x9F\x01\x56\xB3\x1C\x24\x74\xC6\x14\x25\x22\xD3\xBB\xDE\xE7\x4B\x8F\x8B\xA9\x72\x0B\xF1\x6C\x7E\x60\xBA\xEE\xE7\x78\xF3\xA2\x2E\x2E\xA6\x71\x44\xC8\x65\x11\xB3\xDC\xA4\x15\xDF\x33\x4C\xD8\x84\x4B\xDF\xDB\x15\x43\x8B\x5B\xE0\xAF\x45\xA6\x4D\xEE\xD8\x46\x82\x6F\x20\x5E\xD2\x55\x45\x2D\x26\x0B\xB5\xAF\x4D\x09\xCD\xE3\x54\xBA\xE6\x78\xF3\xA2\xEA\x9A\x7B\x8E\x48\x2D\xEE\x30\xDC\x13\xC4\xC1\x77\x19\x7C\xC3\x2C\x2B\xD8\x7B\x4D\xEE\x30\x0C\x52\xA2\xA0\xB4\xCB\x59\xFE\x7D\x0E\x9E\x1F\x72\x1E\xE4\x8C\x6D\x44\x06\x96\xA6\x6B\x43\x3D\x71\x29\x4B\x84\x3E\xA2\xF4\x15\x8D\x23\x52\x1A\x09\xD4\xB7\xB4\x4E\x4A\x0C\x4F\x30\xFB\x3C\xC6\x96\xD4\x36\xEA\xBF\x63\xC8\x26\x4A\x0E\x66\x64\x0E\x76\xFB\x8B\x5A\xFE\x20\x4E\x5A\xEC\x1D\x73\xE9\xFA\x0D\xDA\x9D\x02\x8C\x82\xCB\x6A\xA4\x24\xD7\x7A\xFD\xC7\xB9\xF1\x80\xF4\xE3\xBB\x77\x30\xC6\xAF\xEB\xD4\x0F\x21\x2E\x96\x12\xDB\x88\xE4\xE1\x22\xF4\x00\x3D\x47\xA4\x14\x72\xAF\x9A\xEE\x28\x7B\x18\x4F\x43\xC8\xCC\xF0\x06\xD7\x11\xFC\x71\x09\xEC\x30\x0C\x4A\x12\xE7\x66\xD5\x3F\x62\xDC\xDA\xFF\xAF\xD9\xC0\xD4\xF7\xEF\x82\x69\x24\x97\x49\xA9\xD8\x46\x84\x24\x43\xE3\x88\x94\x42\x1F\xCB\x95\xA3\xA8\x31\x1B\x00\x37\xA0\x71\xD4\x02\x5F\x1D\x49\x40\xCE\x7B\x1C\xBB\xC8\xE5\x1E\x2B\xD7\xF1\x68\x42\x34\x25\x62\x1B\x11\x43\x8B\xE5\xC9\x8B\xD8\x8B\x48\xE3\x88\x94\x62\x2C\x6A\x6F\xED\x93\x11\xA4\x0C\x72\x3C\x7A\x87\xD3\x5B\xEB\xEF\x40\xE3\x88\x84\x53\x2A\xB6\x11\x31\xB4\x30\x54\x5C\x06\xD9\x16\x67\x52\xC7\x34\x8E\x48\x29\xEC\xE5\x17\x59\x4A\x23\xE5\xA9\x1D\xB8\x6E\x8B\xE3\x7B\x8F\xB8\xBF\x6C\x3E\x2D\x82\x0F\xB6\xBA\x2E\xA4\x44\x6C\x23\x1B\x5F\xBE\x7C\x9F\x5F\xFA\xC6\xF0\x0D\xEA\xEA\xE6\x55\x65\x79\xC9\x70\x43\x36\xA9\x41\xCB\xCE\xD0\x4A\xE9\xC7\xA2\x95\x70\xAA\x91\xA1\x7F\x57\xA3\xEC\xF5\x80\x16\xBA\x21\xF3\xD2\x0C\xA9\x16\x75\x78\xCE\xED\xA6\x54\x6C\x23\x2D\xC3\xA5\x03\x7C\x97\xCB\x5E\xC4\x12\x91\x03\xD7\xC9\xB1\x95\xE7\x73\x17\x53\xE5\xD6\xEA\x12\xDC\x68\x68\x1C\x91\x4B\x23\x47\xA4\xDF\x16\x47\x4D\x75\xBA\x53\x6F\x04\xD7\x69\xAF\x11\xE4\x4E\x0F\xD0\x53\xC6\xD1\x12\xA2\x30\x97\xA4\x45\x1D\x9E\x73\xBB\xA9\x15\xDB\x68\xEA\x76\x78\xD9\x23\x37\xC5\x92\x02\x44\xCE\xC1\x65\xE8\x3E\x62\xDA\xA0\x9E\x2A\xB7\xB9\x32\xDF\xE0\x9F\x40\xAD\xD0\x38\x04\x0C\x8D\x23\x52\x83\x9A\x83\xA0\x56\x68\x29\x83\x45\xEA\x00\x33\x87\x3D\x8E\xD3\xBE\x46\x7C\xB9\x8D\x9D\xEE\xAB\xE1\x01\xD0\x0A\x6C\x6A\x50\xD1\xA7\x14\xE7\xC4\x3C\x59\xE2\x71\xE1\x16\x75\x78\xCE\xED\xA6\x56\x6C\xA3\x3B\x00\x5F\x18\x0E\x10\x6C\x60\x06\x7E\x5F\xF8\x89\xB3\x58\xFE\x09\xC0\xE7\xFD\xFA\x84\x29\x0F\x29\x9B\x7B\x98\xB2\x99\x73\x18\xC6\x55\x76\xEB\x5E\xA6\xDE\x6F\x26\x9F\x3D\x62\xA8\xAF\x66\xA1\x60\x68\x1C\x91\x52\xD8\x1D\x72\x8D\x34\x83\x23\x65\x00\xD4\xAE\xF9\x0D\xDC\xB3\x43\x4D\x8E\x13\x72\xA9\x03\xB7\x9E\x39\x3F\x47\xBE\xEB\x55\xFD\x7B\x0B\xF7\x80\xB3\x82\x51\x52\x73\x8C\x57\x1D\x40\xD2\xA7\x88\x75\xFD\xC4\xE6\x11\x38\x1E\xEC\x96\x46\xED\x3A\x6C\x25\x53\x13\x3B\x80\xD5\x8E\x6D\x74\x83\x21\x1E\xD7\x3B\x8C\x4E\xF0\x95\xD1\xA5\x2C\xA9\x85\x94\xED\x23\x86\xB2\x79\xC5\xFC\x09\xAD\xEB\x7E\x34\x60\xA8\x8F\x1F\x98\xBE\xFC\x0E\xA0\xC3\x60\xA8\x49\xDD\x48\x48\x98\xEA\x7D\x9D\xC6\x11\x29\x85\xEE\x90\xAF\x88\x33\x90\x6E\x10\x67\xD4\x08\x07\x8C\x0F\x16\x21\xEF\xDA\xC0\xB8\x7C\x53\xD0\xB3\xF7\x14\x63\x50\x0F\x4A\x12\x44\xD3\xB7\x46\xBF\x82\x49\xB7\x56\x68\xBE\x53\x63\x32\x2B\x13\xA5\x18\xAB\x10\xE5\xB7\xF6\x20\xE3\x5B\x1A\xD1\x69\x8A\x09\x14\xBA\xC2\x70\xFF\x9B\xB8\xDD\x97\x66\x20\xD5\xAE\xC3\x56\x32\xC7\xEE\xE5\x8B\x31\xC8\x96\x1E\xDB\x68\x4C\x8F\x9C\x2B\xDA\xBB\x58\x8B\xA7\xC0\xEF\xDD\xC0\xBF\xF7\xA9\x7A\x5F\xE7\x69\x35\x52\x8A\x2D\x8E\x67\x67\xA2\x88\xF7\x30\x8A\x70\x6C\x56\xB1\xC2\xD0\x51\xE6\xCC\x5C\x5E\x60\x8C\x13\x5B\x59\x3F\xC3\x74\xAE\x2D\x06\x65\x71\xC0\x30\x83\x95\xBB\xDF\xD0\xFF\x3D\xD6\x9B\xF1\x81\xE3\xCE\xFB\xD6\xA7\xC3\xBE\x15\x5C\xDF\x51\xA6\x39\xC0\x44\xAB\xB6\x0D\xB4\x35\xCC\xCC\x6A\x8B\x61\x59\xEA\xC3\x4A\xB7\x9C\x14\xD3\xE9\x7D\x82\x5B\x21\xEA\xBD\x06\x52\xE6\x52\x3F\x53\x33\xBF\x15\x8E\xDD\xEF\x36\x7B\xF8\x07\x94\xEF\x3E\x6D\xF6\x7E\x06\x71\xB3\x8B\x5C\x29\x33\xA9\x1F\x91\xA9\xEB\x54\x7E\xBB\x24\x6A\xD6\x61\x4B\x99\x3B\x1C\xD7\xE1\x06\x43\x1D\x4A\x1B\x77\x19\x18\xB5\x62\x1B\xA5\xF4\x65\x20\x7C\x60\x3F\x17\x9E\x90\x3E\xF1\x4B\xE5\x03\xA7\x77\x37\xCE\xE1\x19\x35\xAF\x96\xE9\xBA\x8E\x0F\x9F\x52\xCF\xBA\xEB\xBA\x9F\x2E\x1F\x8F\x11\xB2\xEF\x13\x65\xFC\x74\x26\xDD\x36\xEF\x01\xF2\x6E\x02\xDE\xBD\x29\x9C\x76\xE1\x35\x40\xC6\xAA\xEB\xBA\xB7\x80\x77\x7D\x75\x26\xFF\xEF\x9E\xEF\x7D\xF6\xEF\x0C\xAD\x9F\xD7\x98\x0C\x4D\xE0\xCA\xA7\x4E\x6F\x6A\x1B\x4E\x7D\x4F\x8D\x3A\x6C\x2D\xF3\xD9\xF3\xBE\xA9\x7E\xA3\xD3\xB9\x8E\x94\xAB\x9F\x8D\x27\x0D\xB1\x6D\x2D\xA4\x1C\x5C\xFD\xC1\xA5\xA7\x7C\x69\x2D\x25\x37\xA5\xCF\xF9\xFA\x7D\xA8\x3E\xF6\xB5\x93\x10\x3E\x3B\xA3\x63\x53\xDB\x41\xD7\x85\xEB\x5F\x74\x5D\xC7\x65\x35\x52\x94\x3D\x80\x5B\xA4\xB9\x74\xE7\xBA\xB5\xB7\x30\xB3\xE9\x98\x59\x86\xA4\x37\x65\xAF\xC1\x77\x2F\x2F\x07\x5B\x98\xA0\x99\xB1\x33\xA4\x03\xCC\x0C\x31\x24\x1D\x12\xB1\xFC\x16\xEE\xCD\x93\x21\x9E\xBC\x97\xFE\x3D\x31\xE9\x7D\x80\x49\x6B\xCA\x2C\x30\x26\x9F\xAD\xA8\x51\x87\xAD\x65\xBE\x20\x6D\xD3\x72\xE9\xD8\x46\x9A\xA7\x08\x19\xA2\x37\x2E\x91\x07\x84\x07\x68\xDD\xC3\xB4\xA5\x1C\x3C\xF5\xEF\x4A\x1D\x07\x9E\x60\xAE\x25\xAA\xBA\x34\x48\xE3\x88\x94\x66\x0F\xD3\xB0\x43\x15\xD4\xBE\xFF\xEE\x3F\x98\xBF\x0F\x61\xDB\xCB\xF6\x6D\x30\xDD\xC3\x28\x8E\xDF\x81\x69\x74\xC9\xBB\x45\x9E\xFD\x13\x3B\x98\x32\x08\x29\x37\x59\xAA\xFA\x8D\xF8\xE8\xD4\x1F\x30\x69\x0E\x95\x25\xEC\x7B\x59\xF2\xBB\x14\x23\xC7\xFE\x7D\x6C\xDB\x38\x87\x28\xDC\xB5\xEA\xB0\x95\xCC\x03\x4C\xDB\x79\x40\xB8\x91\x54\x23\xB6\x91\xE6\x80\x41\x07\x4D\xB5\x53\x31\x06\x2E\xD5\x30\x12\x9E\xE0\x9E\x10\x1D\xAC\xEF\xE4\x5C\xBE\x92\x76\xF9\x80\xB0\x3A\xDF\xF5\xDF\xFD\x85\x46\x7D\xFD\xAF\xAE\xEB\x5A\xC8\x25\xD7\x8B\x7D\x79\xA9\xFC\x57\x94\x78\xE9\xA3\xB3\x32\x63\x5D\x63\xD8\xD3\xE2\xDB\x07\x34\x07\x7D\x51\xEB\x1C\x59\xF2\x2E\xD9\x97\x25\xE9\xB7\xF7\x34\xE5\x44\x64\x89\x3C\x91\x05\x94\xAB\x27\x57\xDB\x28\x59\x4F\xB5\xA8\x5D\x87\xAD\x64\xBA\x78\xC4\xF1\x5E\xA5\x5F\xA8\x5F\xAF\xF6\xC5\xCA\xB2\xFF\xF0\x52\x62\x1A\xC5\x20\x6D\x43\x36\xEE\x7F\xA3\x6E\xF8\x02\xD1\xC7\x76\x5D\xA0\x72\x1A\x26\xA1\x71\x44\x08\x21\xA4\x16\x5F\x18\x06\xE3\x1D\xF2\x2D\xDD\x10\x92\x15\x2E\xAB\x11\x42\x08\xA9\x41\xED\xD8\x46\x84\x24\x43\xE3\x88\x10\x42\x48\x0D\x96\x1E\xDB\x88\x90\xFF\xA0\x71\x44\x08\x21\xA4\x06\xB5\x62\x1B\x11\x32\x1B\x1A\x47\x84\x10\x42\x4A\xA3\x03\x4E\xD2\x38\x22\x8B\x86\xC6\x11\x21\x84\x90\xD2\xE8\xD8\x46\xD7\x78\x3A\x8C\x9C\x11\x3C\xAD\x46\x08\x21\xA4\x34\xB6\x71\x74\xAD\x47\xE7\xC9\x19\x41\xE3\x88\x10\x42\x08\x21\xC4\x82\xCB\x6A\x84\x10\x42\x08\x21\x16\x34\x8E\x08\x21\x84\x10\x42\x2C\x68\x1C\x11\x42\x08\x21\x84\x58\xFC\xDD\x3A\x01\xE4\x32\xF9\xF7\xDF\x7F\x5B\x27\x81\x10\x72\x79\xAC\x71\xBC\xB9\xDB\x77\xA9\x34\x21\x49\xD0\x38\x22\x84\x10\x72\x2E\x3C\x62\x08\x26\xF9\x8D\x46\x37\xB6\x93\xCB\x87\xCB\x6A\x84\x10\x42\xCE\x81\x15\x18\x65\x9B\x54\x82\xC6\x11\x21\x84\x90\x73\xE0\x5E\xFD\x9B\x77\xB3\x91\x62\xD0\x38\x22\x84\x10\x72\x0E\xD8\x5E\xA3\x1D\x18\x48\x92\x14\x84\xC6\x11\x21\xE4\x12\x79\x07\xD0\x59\x0F\xC9\x4B\xED\xF2\x5D\xF7\x8F\xF0\x61\xFD\xFF\x46\xA5\xC5\x7E\xDE\x0B\xA5\x47\xE7\xDF\x7E\x1E\x0B\xC9\x6C\xC1\xB5\xE4\xF3\x04\x1A\x47\x84\x10\x42\x96\x8E\xED\x35\x3A\x80\xFB\x8D\x48\x61\x68\x1C\x11\x42\x08\x59\x3A\xF6\x7E\x23\xEE\x35\x22\xC5\xA1\x71\x44\x48\x1E\x6A\xB8\xF2\x09\xB9\x46\xEE\x60\x4E\xAA\x09\xF4\x1A\x91\xE2\xD0\x38\x22\x84\x10\xB2\x64\xEC\x25\xB5\x6F\x00\xFB\x56\x09\x21\xD7\x03\x8D\x23\x42\x08\x21\x4B\x85\xB1\x8D\x48\x13\x68\x1C\x11\x42\x08\x59\x2A\x3A\xB6\x11\x8D\x23\x52\x05\x5E\x1F\x42\x08\x21\x64\xA9\xE8\xD8\x46\x4B\xB9\x47\xED\x09\xC7\xFB\xA0\x6C\x18\x7F\xE9\x02\xA0\x71\x44\x08\x21\x64\x89\xE8\xD8\x46\x4B\x3A\xA5\xC6\x7D\x4F\x17\x0E\x97\xD5\x08\x21\x84\x2C\x11\x1D\xDB\x68\x49\xC6\x11\xB9\x70\xE8\x39\x22\x2D\x58\x03\xB8\xE9\x1F\x9B\x3D\x8C\x4B\x9A\x6E\xE9\x53\x64\x16\xAD\x5D\xF9\x7B\x1C\x47\x0B\xCE\x29\x6F\x85\xE3\x99\x3B\x60\x06\xA9\xEF\x82\x32\xC7\xDA\x85\xB4\x89\xDC\xB3\xF5\x1B\x4B\xA6\x70\xE8\xE5\x94\xF0\x0C\xD4\xAE\xC3\x56\x32\x73\x61\xEF\x37\xCA\xB5\xD7\x68\x05\x13\x51\xDB\xAE\xF3\x25\x97\xC5\x06\xC7\x7D\x50\xFA\x5E\x8E\xE5\xC5\x75\xFF\xFE\x12\xEF\x0E\x91\x3D\x35\x06\xD4\xAA\x8B\x1B\x9C\x9E\x84\xFC\x2F\xFF\x34\x8E\x48\x2D\x6E\x60\x94\xDD\x1D\x4E\x3B\x84\x66\x0F\xA3\x0C\x53\x14\xE2\x3B\x8E\x3B\xFC\x5F\x09\xEF\x00\x8E\xAF\x44\xF8\x00\x70\xEB\xF9\x8E\xCD\x66\xE2\xB3\x5B\xC4\x75\xFC\x1B\x98\x10\xFD\x3A\xCE\xCB\x18\x5B\x98\x99\xF5\x1C\xC5\x12\x53\x47\xE8\x65\x7D\xF4\xB2\x53\x15\x6A\x4C\x1E\xC5\x7B\xF0\x82\x74\x03\x7A\x05\x93\xC7\x7B\xB8\xF3\xF8\x0D\xB3\xAF\x64\xAE\xB7\xA2\x76\x1D\xB6\x92\x99\x1B\x9D\xF6\x1C\x5E\xA3\xC7\xFE\x19\x2B\x93\x6F\x98\xB2\x78\x09\x7C\x97\xD6\x33\x36\x4F\x8E\xF7\x6C\x30\x1D\x07\xCD\xD6\x33\xAE\xB4\x02\xA6\x3C\x9E\x90\xD6\x0F\xEE\xFB\x77\x8F\xB5\xFF\x03\x4C\xDA\x43\xCB\x21\x06\xD1\x2F\xF7\x70\xB7\x4B\x49\x43\xAC\x5E\x71\x95\x2D\x30\xE8\xDF\x15\x80\x57\x1C\x1B\x46\x36\x5B\x00\x4F\x5C\x56\x23\xA5\x59\x01\x78\x06\xF0\x85\xE9\x0E\xA9\x59\xC3\x34\xDE\x4F\x9C\x7A\x2E\xAE\x85\x47\x98\x32\xF3\x29\x12\xE1\x1E\x46\x31\x3C\xCF\x94\x17\x5A\x47\x80\x51\x46\x52\xB7\xCF\x08\x4B\xA7\x8D\xFC\x36\x34\x8F\x62\xD8\x88\xBC\x58\xD6\x30\x6D\xEA\x19\xFE\x3C\xDE\x00\x78\x83\x69\x87\xA9\xD4\xAE\xC3\x56\x32\x4B\x60\x0F\x5C\x39\x3C\x79\xAF\x70\xB7\xD1\x9B\xFE\xF3\x4F\xC7\x77\x6A\xE1\x4B\x2B\x60\xCA\xE7\x13\xA7\xA7\xF9\x42\xDE\xFD\x8A\xE9\xF6\x2F\xFA\x3A\x77\x39\xD8\xFA\xC5\xF7\x5E\x7B\xCC\x98\x32\x60\x52\x59\x07\xBC\xF7\x1E\xC0\x3B\x8D\x23\x52\x92\x15\x8C\xE2\x4D\xBD\xA0\x70\xDD\xFF\xFE\xDA\x0C\x24\x51\x8E\x29\x3C\xC2\x28\xB6\x1C\xF2\x0E\x18\xBC\x43\xF2\x8C\xB1\xC2\xA0\xFC\x42\xF9\xC4\xBC\x8B\x2B\x25\x9F\xA1\x0A\x5C\xDA\x52\xA8\xE1\x27\xDC\x23\xCD\x40\xAA\x5D\x87\xAD\x64\x96\x40\x2F\x77\xCC\xF5\x1A\x3D\x23\xDC\x88\x58\xC3\x18\xC5\xAD\x78\x44\x78\x5A\xC5\x03\x32\xE5\xC1\xD2\xBC\x46\xBC\x5B\x26\xA8\x39\x48\x6D\x97\x2B\x98\xBA\x88\x35\x00\x7D\xEF\x0B\xD1\x19\x3B\x1A\x47\xA4\x24\xF7\x38\x35\x6C\xF6\x30\xEE\xE0\xDF\x30\x4B\x5E\xF6\xF3\x1B\xA7\x4B\x69\x31\x0D\xBA\x36\xB7\xD6\x63\xB3\x57\x9F\xC9\x13\x32\xFB\x1D\x53\x8E\x07\x98\x32\xBB\xC5\x69\x79\x8D\xB9\xD6\xD7\x08\x57\x46\x63\xF2\xB6\xFD\xBB\x7F\x8D\xE4\xC1\x96\xAB\xF3\xF3\x14\x28\xF3\x19\xE3\x7B\x99\x5E\x7A\x19\xBF\x30\xE4\x51\xD2\x30\xE6\x62\x8F\x51\xE0\xEF\x18\xDA\xD0\x16\xC0\x9F\x11\x39\x7F\x30\x3E\x10\xCB\x52\x63\x28\xB5\xEB\xB0\x95\xCC\x52\xE8\xB2\x9E\xB3\xDF\x68\x8D\x78\x23\x7C\x93\xF0\x9B\x1C\x88\xF7\x2A\x96\x90\x3E\x70\x87\x78\x23\xE3\x0E\xF3\x27\xA6\x31\x86\xE9\x14\xAF\x19\xD2\x21\x69\x09\xDD\x2E\xF0\xF2\x57\xD7\x4D\x6D\x9B\x20\x24\x9D\x7F\xFF\xFD\x57\xFE\xF7\x0E\xA6\x71\x1F\x00\x3C\x20\x6C\x6F\xC3\x06\xA7\x06\x91\x6B\x1D\xDF\xA6\xE6\x9E\xA3\x39\xDF\x1F\xE3\x06\xA7\xDE\x97\x1D\x4C\xB9\xB9\xD6\xDE\xC5\x0D\xAD\x95\x50\xC8\x1E\xA7\x1F\x0C\xE5\x7C\x80\x31\x10\x62\xF6\x9F\xC8\x40\x22\x46\x6F\xC8\xF7\xF5\xBE\x80\x90\x3C\x02\xA7\x7B\x05\x0E\x98\x36\x3A\xC7\xF6\x84\xB8\xBE\xAF\xD3\xA8\xDB\xDF\x37\x80\x7F\x3C\xBF\x03\xDA\xD4\x61\x0B\x99\xB9\xFA\xD9\x18\x5F\x18\x06\xB1\x1D\x4C\x9B\x74\xE1\xDB\x6B\x92\xC2\x01\xA6\xBE\xA7\xCA\xAF\xC4\x9E\xA3\x39\x3C\xC0\x6D\x44\xDA\x65\x9A\x0B\x9F\x4E\xCE\x99\xD7\x3D\x8C\x51\xEF\x22\x87\xBC\xFF\xEA\x9D\x9E\x23\x52\x9A\x1D\x4C\x63\xFB\x8D\xF0\x41\xF7\x03\xA6\xB3\xDB\xE4\x72\xAD\x2E\x19\x3D\x5B\xDD\xC3\x0C\x0C\x3E\xA3\x41\x0C\x4F\xAD\x1C\x7D\xB3\x5F\xBD\xE9\xF5\x05\xF1\x1B\x73\xC5\x10\x0C\xF5\x1A\x69\xAF\xC0\x07\xC2\xF2\x08\x0C\xC6\x9B\x78\x91\x42\xBD\x71\x42\xE8\xF7\x25\x4D\x36\x72\xB2\xCD\x47\xED\x3A\x6C\x25\xB3\x14\xFA\xF4\x60\xAB\xE3\xFB\xFA\xDA\x92\xA5\xE3\xD2\x8F\xA1\x07\x2C\x72\x93\xD3\x0B\xB9\x46\x9D\x31\xE0\xBF\x09\x05\x8D\x23\x52\x83\x03\xE2\x4F\x33\xED\x70\x3C\x90\x85\x0E\x4E\xE7\x8C\x56\xC6\xBE\x19\xB3\xE6\x09\xC7\xE5\xAC\x8F\x2C\x6B\xF4\x67\x35\xAE\x66\xD0\x0A\x4E\x1B\xC1\x21\x3C\xC0\x18\xDC\x31\x86\xD1\x4B\xE4\xF7\xE5\x14\x9E\x4D\xC8\xDE\x8E\xDA\x75\xD8\x4A\x66\x29\xEC\xF6\x91\x33\xB6\x91\x18\xBC\xB2\x3C\x1C\xE2\xA9\x0C\xDD\xCB\x93\x1B\x59\x62\x7E\xC2\xE0\x9D\xF1\xA5\x75\x2C\x5C\x83\xFD\x99\x4F\x9E\x2C\xBF\xDE\x62\x7A\x79\x39\x06\x1D\xC0\x53\xF3\x8D\xA1\x1F\xCB\x72\xEF\x1F\xB8\xFB\x68\x2E\xE3\x48\x97\xEF\xD6\xFA\xDB\x7F\xF9\xE6\x51\x7E\xB2\x64\x76\x38\xEE\x60\x1B\x5C\x6E\x64\xDA\x0D\x4E\x8F\x2E\xC7\x1E\xD3\x3D\xC0\x74\x74\x7B\xE6\xBF\x41\xB8\xD1\x53\x3A\xBE\x89\x1E\x6C\x52\xF2\x28\xC4\xA6\x35\xE5\xA8\xFA\x16\xC7\x0A\x79\x03\xFF\x32\x42\xED\x3A\x5C\x42\xBB\xC9\x49\x89\x4B\x66\xA7\x96\xE6\xF6\x38\xDE\x8B\xA6\x69\x31\x19\x93\xFD\x8A\xBA\x7D\xBF\xC0\x7F\x38\x65\x8D\xF1\x76\xEE\xFA\xCD\x94\x07\x76\x87\xB8\x0D\xDC\x1A\x97\xD7\x6D\x2A\x8F\x12\x52\x62\x2A\x9F\xE2\x55\x9C\x13\x07\x6F\x4A\xF6\x56\xBF\x97\x9E\x23\xB2\x64\x2E\xD5\x10\x1A\x63\x6C\xE3\x7A\x0A\x5A\x39\xC6\x6C\x64\x2F\xBD\xE9\x3D\x57\x1E\x53\x48\x31\x8E\x74\xFA\x7C\xDE\x94\x16\x75\xB8\x84\x76\x93\x0B\x1D\x7E\x20\x97\xD7\x68\x6A\xC9\x77\x0F\xB7\xB1\xDB\xC2\x7B\xA6\xBD\x78\x82\x2C\x29\xBB\x98\x32\x82\x5C\x1E\xB0\x2D\xA6\xDB\x4C\xE8\x52\x79\x4C\x5A\x00\xF7\x92\xAF\x78\xB1\xA6\x98\xE3\xCD\x13\x43\x70\x4C\xF6\x5E\xFF\x9D\xC6\x11\x21\xCB\x24\x75\x90\xD3\xBF\x73\x29\x13\xAD\x24\x6A\xEF\xEB\x3A\x07\xE3\x57\x2F\xED\xA6\xFE\x76\xCE\xEF\x62\x06\x84\x16\x32\x73\x61\xCB\xCC\x15\xA5\xDC\x17\x71\xDF\x67\x80\xD5\x2C\x07\x09\x9D\x31\x45\x89\xC8\xF4\xAE\xF7\xF9\xD2\xE3\x62\xAA\xDC\x42\x3C\x9B\x1F\x98\xAE\xFB\x39\xDE\xBC\xA8\x8B\x8B\x69\x1C\x11\x72\x59\xC4\x2C\x37\x69\xC5\xF7\x0C\x73\x4A\xEB\xD2\xF7\x76\xC5\xD0\xE2\x16\xF8\x6B\x91\x69\x93\x3B\xB6\x91\xE0\x1B\x88\x97\x74\x55\x51\x8B\xC9\x42\xED\xC8\xE8\xA1\x79\x9C\x4A\xD7\x1C\x6F\x5E\x54\x5D\x73\xCF\x11\xA9\xC5\x1D\x86\x7B\x82\x38\xF8\x2E\x83\x6F\x98\x65\x05\x7B\xAF\xC9\x1D\x86\x41\x4A\x14\x94\x76\x39\xCB\xBF\xCF\xC1\xF3\x43\xCE\x83\x9C\xB1\x8D\xC8\xC0\xD2\x74\x6D\xA8\x27\x2E\x65\x89\xD0\x47\x94\xBE\xA2\x71\x44\x4A\x23\x81\xFA\x96\xD6\x49\x89\xE1\x09\xC3\xB5\x1C\x9A\x8D\xFA\xEF\x18\xB2\x89\x92\x83\x19\x99\x83\xDD\xFE\xA2\x96\x3F\x88\x93\x16\x7B\xC7\x5C\xBA\x7E\x83\x76\xA7\x00\xA3\xE0\xB2\x1A\x29\xC9\xB5\x5E\xFF\x71\x6E\x3C\x20\xFD\xF8\xAE\x04\xF9\x74\x9D\xFA\x21\xC4\xC5\x52\x62\x1B\x91\x3C\x5C\x84\x1E\xA0\xE7\x88\x94\x42\xEE\x55\xD3\x1D\x65\x0F\xE3\x69\x08\x99\x19\xCA\x2D\xCE\xA4\x3C\x3B\x0C\x83\x92\xC4\xB9\x59\xF5\x8F\x18\xB7\xF6\xFF\x6B\x24\x3A\xAD\x2F\x8A\x2D\x21\x9A\x52\xB1\x8D\x08\x49\x86\xC6\x11\x29\x85\x3E\x96\x9B\x7A\x35\x05\x8D\xA3\xFA\x84\x5C\x57\x21\x11\x6B\x6D\x17\xB9\xDC\x63\x15\x72\xCD\x0B\x21\x42\x89\xD8\x46\xC4\xD0\x62\x79\xF2\x22\xF6\x22\xD2\x38\x22\xA5\x18\x8B\xDA\x5B\xFB\x64\x04\x29\x83\x1C\x8F\xDE\xE1\xF4\xD6\xFA\x3B\xD0\x38\x22\xE1\x94\x8A\x6D\x44\x0C\x2D\x0C\x15\x97\x41\xB6\xC5\x99\xD4\x31\x8D\x23\x52\x0A\x7B\xF9\x45\x96\xD2\x48\x79\x6A\x07\xAE\xDB\xE2\xF8\xDE\x23\xEE\x2F\x9B\x4F\x8B\xE0\x83\xAD\xAE\x0B\x29\x11\xDB\xC8\xC6\x97\x2F\xDF\xE7\x97\xBE\x31\x7C\x83\xBA\xBA\x79\x55\x59\x5E\x32\xDC\x90\x4D\x6A\xD0\xB2\x33\xB4\x52\xFA\xB1\x68\x25\x9C\x6A\x64\xE8\xDF\xD5\x28\x7B\x3D\xA0\x85\x6E\xC8\xBC\x34\x43\xAA\x45\x1D\x9E\x73\xBB\x29\x15\xDB\x48\xCB\x70\xE9\x00\xDF\xE5\xB2\x17\xB1\x44\xE4\xC0\x75\x72\x6C\xE5\xF9\xDC\xC5\x54\xB9\xB5\xBA\x04\x37\x1A\x1A\x47\xE4\xD2\xC8\x11\xE9\xB7\xC5\x51\x53\x9D\xEE\xD4\x1B\xC1\x75\xDA\x6B\x04\xB9\xD3\x03\xF4\x94\x71\xB4\x84\x28\xCC\x25\x69\x51\x87\xE7\xDC\x6E\x6A\xC5\x36\x9A\xBA\x1D\x5E\xF6\xC8\x4D\xB1\xA4\x00\x91\x73\x70\x19\xBA\x8F\x98\x36\xA8\xA7\xCA\x6D\xAE\xCC\x37\xF8\x27\x50\x2B\x34\x0E\x01\x43\xE3\x88\xD4\xA0\xE6\x20\xA8\x15\x5A\xCA\x60\x91\x3A\xC0\xCC\x61\x8F\xE3\xB4\xAF\x11\x5F\x6E\x63\xA7\xFB\x6A\x78\x00\xB4\x02\x9B\x1A\x54\xF4\x29\xC5\x39\x31\x4F\x96\x78\x5C\xB8\x45\x1D\x9E\x73\xBB\xA9\x15\xDB\xE8\x0E\xC0\x17\x86\x03\x04\x1B\x98\x81\xDF\x17\x7E\xE2\x2C\x96\x7F\x02\xF0\x79\xBF\x3E\x61\xCA\x43\xCA\xE6\x1E\xA6\x6C\xE6\x1C\x86\x71\x95\xDD\xBA\x97\xA9\xF7\x9B\xC9\x67\x8F\x18\xEA\xAB\x59\x28\x18\x1A\x47\xA4\x14\x76\x87\x5C\x23\xCD\xE0\x48\x19\x00\xB5\x6B\x7E\x03\xF7\xEC\x50\x93\xE3\x84\x5C\xEA\xC0\xAD\x67\xCE\xCF\x91\xEF\x7A\x55\xFF\xDE\xC2\x3D\xE0\xAC\x60\x94\xD4\x1C\xE3\x55\x07\x90\xF4\x29\x62\x5D\x3F\xB1\x79\x04\x8E\x07\xBB\xA5\x51\xBB\x0E\x5B\xC9\xD4\xC4\x0E\x60\xB5\x63\x1B\xDD\x60\x88\xC7\xF5\x0E\xA3\x13\x7C\x65\x74\x29\x4B\x6A\x21\x65\xFB\x88\xA1\x6C\x5E\x31\x7F\x42\xEB\xBA\x1F\x0D\x18\xEA\xE3\x07\xA6\x2F\xBF\x03\xE8\x30\x18\x6A\x52\x37\x12\x12\xA6\x7A\x5F\xA7\x71\x44\x4A\xA1\x3B\xE4\x2B\xE2\x0C\xA4\x1B\xC4\x19\x35\xC2\x01\xE3\x83\x45\xC8\xBB\x36\x30\x2E\xDF\x14\xF4\xEC\x3D\xC5\x18\xD4\x83\x92\x04\xD1\xF4\xAD\xD1\xAF\x60\xD2\xAD\x15\x9A\xEF\xD4\x98\xCC\xCA\x44\x29\xC6\x2A\x44\xF9\xAD\x3D\xC8\xF8\x96\x46\x74\x9A\x62\x02\x85\xAE\x30\xDC\xFF\x26\x6E\xF7\xA5\x19\x48\xB5\xEB\xB0\x95\xCC\xB1\x7B\xF9\x62\x0C\xB2\xA5\xC7\x36\x1A\xD3\x23\xE7\x8A\xF6\x2E\xD6\xE2\x29\xF0\x7B\x37\xF0\xEF\x7D\xAA\xDE\xD7\x79\x5A\x8D\x94\x62\x8B\xE3\xD9\x99\x28\xE2\x3D\x8C\x22\x1C\x9B\x55\xAC\x30\x74\x94\x39\x33\x97\x17\x18\xE3\xC4\x56\xD6\xCF\x30\x9D\x6B\x8B\x41\x59\x1C\x30\xCC\x60\xE5\xEE\x37\xF4\x7F\x8F\xF5\x66\x7C\xE0\xB8\xF3\xBE\xF5\xE9\xB0\x6F\x05\xD7\x77\x94\x69\x0E\x30\xD1\xAA\x6D\x03\x6D\x0D\x33\xB3\xDA\x62\x58\x96\xFA\xB0\xD2\x2D\x27\xC5\x74\x7A\x9F\xE0\x56\x88\x7A\xAF\x81\x94\xB9\xD4\xCF\xD4\xCC\x6F\x85\x63\xF7\xBB\xCD\x1E\xFE\x01\xE5\xBB\x4F\x9B\xBD\x9F\x41\xDC\xEC\x22\x57\xCA\x4C\xEA\x47\x64\xEA\x3A\x95\xDF\x2E\x89\x9A\x75\xD8\x52\xE6\x0E\xC7\x75\xB8\xC1\x50\x87\xD2\xC6\x5D\x06\x46\xAD\xD8\x46\x29\x7D\x19\x08\x1F\xD8\xCF\x85\x27\xA4\x4F\xFC\x52\xF9\xC0\xE9\xDD\x8D\x73\x78\x46\xC5\xAB\x65\x68\x1C\x91\x52\x1C\x00\xDC\xE2\xD4\xB3\x50\xE3\xE2\x59\x19\x80\xF5\x72\xC1\x0D\xFC\x9B\x0C\x25\xDD\x9F\x91\x32\x5F\x70\x6A\x2C\x68\xA5\x70\x0B\xFF\x3E\x86\x1D\xCC\x40\xA7\xD3\x7E\x3F\xF2\xFE\x29\xB6\xF0\xCF\xFE\xE5\x08\xBE\xF6\x70\xE9\xFA\xB1\x8D\x3B\x97\xC1\xBA\x87\xC9\x5F\x08\x2F\x18\xDF\xE7\x62\x5F\x7A\x1B\xC2\x16\xA6\xAC\x96\x46\xAD\x3A\x6C\x29\x73\xEC\xD2\x62\xED\xED\x9D\xBA\x73\xAF\x66\x6C\x23\x99\x08\xC5\x78\x1D\xB6\xB8\x1C\xAF\x91\xB0\x83\xC9\x53\x4C\x39\x88\xAE\x9A\x33\x51\x15\x23\x73\xAE\x81\xB4\x87\x89\x95\x57\x2D\xB4\x02\x97\xD5\x48\x49\x64\xC0\x4C\x71\xE9\xCE\x75\x6B\xCB\xC0\x19\xD3\x99\x24\xBD\x29\x7B\x0D\xBE\x91\x6F\xA0\xDE\x22\x4D\x11\x1C\x60\x94\x51\x48\x3A\x24\x62\xB9\xCF\x60\x0B\xF1\xE4\xBD\xF4\xEF\x89\x49\xEF\x03\x4C\x5A\x53\x94\x5D\x4C\x3E\x5B\x51\xA3\x0E\x5B\xCB\x7C\x41\xDA\xA6\xE5\xD2\xB1\x8D\x34\x4F\x11\x32\x96\x6A\x70\xE7\xE0\x01\xE1\xC6\xAF\x18\x23\x39\x78\xEA\xDF\x95\x3A\x0E\x3C\xC1\x5C\x4B\x54\x75\x69\x90\xC6\x11\x29\xCD\x1E\xA6\x61\x87\x2A\xA8\x7D\xFF\xDD\x7F\x30\x7F\x46\xB9\xED\x65\xFB\x36\x98\xEE\x61\x14\xC7\xEF\xC0\x34\xBA\xE4\xDD\x22\xCF\x4C\x78\x07\x53\x06\x21\xE5\x26\x9E\xB2\xDF\x88\x8F\x4E\xFD\x01\x93\xE6\x50\x59\xC2\xBE\x97\x25\xBF\x4B\x31\x72\xEC\xDF\xC7\xB6\x8D\x73\x88\xC2\x5D\xAB\x0E\x5B\xC9\x14\x2F\xEB\x03\xC2\x8D\xA4\x1A\xB1\x8D\x34\x07\x0C\x3A\x68\xAA\x9D\x8A\x31\x70\xA9\x86\x91\xF0\x04\xF7\x84\xE8\x60\x7D\x27\xA7\x97\x46\xDA\xE5\x03\xC2\xEA\x5C\x3C\xA1\xBF\xD0\xA8\xAF\xFF\xD5\x75\x5D\x0B\xB9\xE4\xC2\xF9\xF7\xDF\x7F\xA7\x3E\xB2\x2F\x2F\x95\xFF\x8A\x12\x2F\x7D\x74\x56\x66\xAC\x6B\x0C\x7B\x5A\x7C\xFB\x80\xE6\xA0\x2F\x6A\x9D\x23\x4B\xDE\x25\xFB\xB2\x24\xFD\xF6\xB2\x57\x4E\x44\x96\xC8\x13\x59\x40\xB9\x7A\x72\xB5\x8D\x92\xF5\x54\x8B\xDA\x75\xD8\x4A\xA6\x8B\x47\x1C\x2F\x6D\xFF\x42\xFD\x7A\xB5\x2F\x56\x96\x65\xB7\x4B\x89\x69\x14\x83\xB4\x0D\xD9\xB8\xFF\x8D\xBA\xE1\x0B\x44\x1F\xDB\x75\x81\xCA\x69\x98\x84\xC6\x11\x29\x82\xC3\x38\x22\x84\x5C\x2F\x5F\x18\x06\xE3\x1D\xF2\x2D\xDD\x10\x92\x15\x2E\xAB\x11\x42\x08\xA9\x41\xED\xD8\x46\x84\x24\x43\xE3\x88\x10\x42\x48\x0D\x96\x1E\xDB\x88\x90\xFF\xA0\x71\x44\x08\x21\xA4\x06\xB5\x62\x1B\x11\x32\x1B\x1A\x47\x84\x10\x42\x4A\xA3\x63\x1B\xD1\x38\x22\x8B\x86\xC6\x11\x21\x84\x90\xD2\xE8\xD8\x46\xD7\x78\x3A\x8C\x9C\x11\x8C\x90\x4D\x08\x21\xA4\x34\x76\xD4\x69\x1A\x46\x64\xF1\xF0\x28\x3F\x21\x84\x10\x42\x88\x05\x97\xD5\x08\x21\x84\x10\x42\x2C\x68\x1C\x11\x42\x08\x21\x84\x58\xD0\x38\x22\x84\x10\x42\x08\xB1\xE0\x86\x6C\x42\x08\x21\x4B\x64\x8D\xE3\x53\x6E\xBE\x0B\xA4\x09\xC9\x06\x37\x64\x13\x42\x08\x59\x22\x6F\x18\x02\x47\x7E\xC3\xDC\xEA\x4E\x48\x15\xB8\xAC\x46\x08\x21\x64\x69\xAC\xC0\x88\xDA\xA4\x21\x34\x8E\x08\x21\x84\x2C\x8D\x7B\xF5\x6F\xDE\xC3\x46\xAA\x42\xE3\x88\x10\x42\xC8\xD2\xB0\xBD\x46\x3B\x30\x70\x24\xA9\x0C\x8D\x23\x42\xC8\xB9\xF3\x0E\xA0\xB3\x1E\x92\x97\xDA\xE5\xBB\xEE\x1F\xE1\xC3\xFA\xFF\x8D\x4A\x8B\xFD\xBC\x57\x48\xDB\xA5\xA3\xEB\xDA\x7E\x1E\x1B\xA6\xAB\x3A\x34\x8E\x08\x21\x84\x2C\x09\xDB\x6B\x74\x00\xF7\x1B\x91\x06\xD0\x38\x22\x84\x10\xB2\x24\xEC\xFD\x46\xDC\x6B\x44\x9A\x40\xE3\x88\x90\x78\xE8\xCA\x27\xA4\x0C\x77\x30\x27\xD5\x04\x7A\x8D\xE2\xE0\xB2\x58\x26\x68\x1C\x11\x42\x08\x59\x0A\xF6\x92\xDA\x37\x80\x7D\xAB\x84\x90\xEB\x86\xC6\x11\x21\x84\x90\x25\xC0\xD8\x46\x64\x31\xD0\x38\x22\x84\x10\xB2\x04\x74\x6C\x23\x1A\x47\xA4\x19\xBC\x5B\x8D\x10\x42\xC8\x12\xD0\xB1\x8D\x78\x8F\x5A\x7D\x9E\x70\xBC\xE7\xCB\xE6\xAA\x62\x4D\xD1\x38\x22\x84\x10\xD2\x1A\x1D\xDB\x88\xA7\xD4\xDA\xC0\x3D\x5E\x3D\x5C\x56\x23\x84\x10\xD2\x1A\x1D\xDB\x88\xC6\x11\x69\x0A\x3D\x47\xA4\x34\x6B\x00\x37\xFD\x63\xB3\x87\x71\xD3\x5E\x95\xAB\x36\x10\x99\x45\x6B\xF7\xF6\x1E\xC7\xD1\x82\x73\xCA\x5B\xE1\x78\xE6\x0E\x98\x41\xEA\xBB\xA0\xCC\xB1\x76\x21\x6D\x22\xF7\x0C\xF6\xC6\x92\x29\x1C\x7A\x39\x25\x66\xCB\xB5\xEB\xB0\x95\xCC\x5C\xD8\xFB\x8D\x5A\xEE\x35\x72\xE9\xAB\x12\x65\x28\xB2\x74\xDF\x2B\xD5\x0F\x5A\xB1\x81\xC9\xE7\x58\xDB\xDC\xA3\xCE\x12\xEA\x06\xC7\xE5\x2C\xBA\x6D\x5C\x76\xD7\x75\x7C\xF8\xE4\x7E\x6E\xBA\xAE\x7B\xEE\xBA\xEE\xAB\xF3\xF3\xD9\x75\xDD\x7D\xA2\x9C\x77\xF5\xAE\xD4\xF4\xDA\xBC\x07\x7C\x27\x84\x4D\x64\x1A\x6E\xBA\xAE\x7B\xED\xBA\xEE\x27\xE0\xDD\xAF\x09\xEF\x9F\x53\x47\x5D\x67\xCA\xE5\xB1\xEB\xBA\xD5\x4C\x99\xA1\x79\xFC\xE9\xBF\x7B\x13\xF0\xDE\xA9\x76\xB0\xEA\xD3\xEC\xCB\xE3\x57\xD7\x75\x77\x33\xF2\xD5\xAA\x0E\x6B\xC9\xCC\xD5\xCF\xA6\x9E\x3B\xF5\xFE\xB5\xE3\xBB\x1B\x47\xFE\xA6\xFA\x6E\x68\x5F\xF0\x95\xE1\x4F\x37\xBF\x0F\xC4\xB4\x4B\x91\xE9\xAB\xB7\xC7\x80\xF7\x68\xA6\xCA\x4A\xD7\xB5\xCD\xA3\x23\x0D\x53\x75\xF5\x16\x98\x9E\xB7\x2E\x7E\x1C\x08\x6D\x0B\x8F\x9D\xBB\x6E\xDF\xBA\x11\x3D\x93\xBB\x91\xF3\xB9\xEE\x67\xD5\x19\x25\x93\xC2\x67\xE7\x56\x8A\x63\xCF\xA5\x18\x47\x29\xCA\xAD\xEB\x4C\x59\xA7\xE4\x37\x55\x5E\xD7\x19\x25\xF3\xDC\xC5\x0F\x10\xA9\xED\xA2\xEB\xFC\xF9\x1C\x6B\x07\xEB\x2E\xDC\xF0\x13\x5E\x3D\x72\x96\x54\x87\x35\x65\x96\x36\x8E\xEC\x01\xF4\xD3\xF3\xDD\xDC\xC6\x51\x4A\x19\xFE\x74\xE9\xC6\xB4\x6F\xA0\x76\xF1\xDE\x8D\x4F\x16\x96\x66\x1C\xAD\x3C\xEF\x71\x11\x33\x0E\x84\xB4\x85\xD7\x40\xB9\x3F\x9D\x32\xCE\xB8\xE7\x88\xE4\x62\x05\x13\x9D\x35\x35\x0A\xEB\xBA\xFF\xBD\x76\x2F\x5F\x3A\xAF\x00\x9E\x13\x7F\xFB\x08\xE0\x33\x93\xBC\x03\x8C\x8B\xD9\x7E\xC6\x58\xF5\x72\xBF\x22\x64\x7E\x62\x5E\x74\x5E\xC9\xE7\xD4\x29\x1A\x8D\xB4\x25\xBD\x34\xE2\xE3\x1E\xA6\x7C\x62\xA9\x5D\x87\xAD\x64\x96\xE0\x06\xA7\xA7\xD4\x6A\x91\x5A\x86\x2B\x00\x6F\x38\x0D\x3D\x10\x2A\x2F\xB4\x1D\x6B\x36\x30\xF5\x76\xE7\xFB\x62\x43\xD6\x30\x69\xDC\xCC\xF8\x7D\xAE\x71\xE0\x11\xE1\x75\xB4\x82\xA9\x9F\xFF\xD2\x4D\xE3\x88\xE4\xE2\x1E\xA7\x0D\x7A\x0F\x73\x34\xF4\x37\x80\xBF\xD4\xF3\x1B\xA7\x7B\x0B\x44\xE9\xA4\x2A\x8F\x92\xDC\x5A\x8F\xCD\x5E\x7D\x26\x4F\xC8\x5E\x81\xB1\xCE\x7B\x80\x29\xB3\x5B\x9C\x96\xD7\x13\x4E\xF7\x68\xAD\x11\xAE\xE0\xC7\xE4\x6D\xFB\x77\xFF\x1A\xC9\x83\x2D\x57\xE7\xE7\x29\x50\xE6\x33\xC6\xF7\x32\xBD\xF4\x32\x7E\x61\xC8\xA3\xA4\x61\x8B\xD3\x7D\x00\x6B\x84\x1B\x2E\xEF\x18\xDA\xD0\x16\xC0\x9F\x11\x39\x7F\x30\x3E\x10\xDF\x23\x6E\xF0\xA9\x5D\x87\xAD\x64\x96\x42\x97\x75\xAD\xFD\x46\xCF\x88\x37\x6E\x34\xAF\x08\x1F\xC4\x73\xC8\x03\x06\x1D\xB9\xC4\x49\xA4\x18\x18\xB1\x93\x92\xB1\xF7\xA4\x4C\x6E\x6C\x6E\x90\xD6\xBE\x07\x1D\x13\xE8\xBE\xE2\xC3\x27\xE4\xB9\xEB\x8C\x7B\xF2\xAB\x0B\x5F\x56\xDA\x74\xA7\x6E\xE6\x50\xF7\x6D\xCD\x65\xB5\x39\xDF\x1F\x7B\x6E\xBA\x53\xDE\x3A\xFF\x72\xD5\xAA\x1B\x77\x15\x87\x94\xB7\x5D\xCE\x3F\x81\xBF\xD1\x75\xF5\xDE\x85\x2F\xCB\x8C\xB9\xBD\x43\xF2\x28\xF9\xB4\x97\x5B\x7E\xBA\x69\x77\xFB\x98\x0B\xDF\xF5\x7D\x5F\xFB\xFB\x0A\xCC\x5F\x8B\x3A\x6C\x21\xB3\xE4\xB2\x9A\xBD\xF4\xF9\x16\xF0\xFD\x1C\xCB\x6A\xAE\x77\xC4\xE2\x5B\x06\xCC\x2D\x4F\x64\xDA\xF5\xBD\x94\x65\xB5\x39\x4B\xE7\x31\x69\x2C\x55\xAE\xC2\x7D\xD7\x71\x59\x8D\xE4\x65\x07\xE0\x1F\x98\xD9\x6A\xE8\xC9\x8E\x0F\x00\x0F\xEA\x6F\x39\x66\x58\x4B\x47\x2F\x33\xED\x61\xBC\x19\xBE\x53\x1B\x07\x98\xF2\xD2\x33\x6C\xDF\xB2\x95\xBE\xD0\xF3\x05\xF1\xA7\x6F\x3E\x60\x3C\x13\xA1\x5E\x23\xED\x15\xF8\x40\x58\x1E\xD1\x7F\xE7\x0F\x06\x2F\x52\xA8\x37\x4E\x08\xFD\xBE\xA4\xC9\x66\xEC\xF4\xD0\x18\xB5\xEB\xB0\x95\xCC\x52\xE8\xD3\x83\xB5\x96\xD4\x72\x7A\xCC\xD6\xF0\xEB\xAB\x94\xA5\xDA\x29\x76\x30\x6D\x7B\x69\x01\x32\x65\xB9\x3D\x27\xFA\x74\x59\x2D\xEE\x01\x2E\xAB\x91\xFC\x1C\x10\xDF\x71\x77\x38\x1E\xC8\x42\x07\xA7\x73\x46\x1B\x0E\x7A\x80\xF6\xF1\x84\xE3\x72\x96\xA3\xB2\x53\xE8\xCF\x6A\x2C\x5F\xE8\x41\x43\x1B\xC1\x21\x3C\xC0\x18\xDC\x31\x86\xD1\x4B\xE4\xF7\x3F\x70\x5A\x1E\x21\x7B\x26\x6A\xD7\x61\x2B\x99\xA5\xB0\xDB\x47\xAD\xD8\x46\x3A\xD8\xA4\xE6\x1B\x43\x9B\x93\xA5\xC9\x3F\x70\xB7\x27\x97\x71\x14\x5A\xBE\x3B\x98\xBA\x91\xE7\x05\xA7\x4B\xA1\xB2\x44\xAC\xF5\xEB\x8B\x95\x56\xD7\x84\xE7\xC9\xFA\x9E\xDE\x1E\x30\x97\x90\x09\xAD\x6C\xB3\x90\x27\x64\x72\x36\x77\xA2\x2C\x4B\xF8\x76\xB9\xFA\xC6\xA7\x35\x80\x15\x8D\x23\xB2\x14\xB4\x62\x4C\xDD\xD0\x77\x0E\x6C\x70\xEC\xC5\xD9\x21\x3E\xDE\xD3\x01\x69\x03\xBA\xFD\xFB\x92\xE8\xB4\xA4\xE4\x51\x88\x4D\x6B\x4A\x3C\x9A\xD8\xB2\x6C\x51\x87\x4B\x68\x37\x39\x69\x71\xC9\xAC\x6B\x3F\xD9\x1E\xC3\x5E\x48\xBB\x5C\xC5\x5B\x33\x65\x20\x69\x0F\x98\x8D\xAF\x6C\xF7\x30\x86\xD8\x1F\x98\x81\x5B\x9E\xA7\xFE\xEF\x0F\x18\xEA\x2C\x65\x72\x51\x0B\x5F\x3E\x1F\x60\xCA\xD6\xCE\xA3\xEC\x6D\x74\xF5\xEF\x39\x6D\x53\xCA\x56\x8C\x22\xBB\x5C\x7D\x93\xA7\x35\x8D\x23\xB2\x14\x2E\x25\xD8\x59\x08\x63\x1B\xD7\x53\xD0\x46\x40\xCC\x46\xF6\xD2\x9B\xDE\x73\xE5\x31\x85\x14\xE3\x48\xA7\xCF\x37\xDB\x6F\x51\x87\x4B\x68\x37\xB9\xB8\xC7\xA9\xA1\x57\x03\x97\xD7\xC8\xB5\x3C\x29\x1B\xDE\xA7\x98\x1A\xC4\x5D\x83\xBB\x2C\x17\xBB\x0C\xDC\x2D\x06\x23\x69\xC9\xB8\xCA\x75\x8B\x69\xE3\xF7\x03\xC6\x68\x99\x62\x2C\x70\x64\x28\xDA\x4B\x2A\xC8\x92\xBD\x0B\x1A\x47\x84\x2C\x80\xD4\x41\x4E\xFF\xCE\xA7\x88\x6D\x6A\xEF\xEB\x3A\x07\xE3\x57\x2F\xED\xA6\xFE\x76\xCE\xEF\x62\x66\xCA\x2D\x64\xE6\xC2\x96\x59\x2A\x4A\xB9\x4F\xAE\x4D\x88\x17\xEE\x03\x6E\xEF\x51\xCC\xDF\x81\xB0\x25\x1E\x04\x7E\xA7\x35\x2E\x03\xC6\x67\xF8\xFA\xBC\x86\x29\x5B\x2C\x24\x34\xC9\x14\xDE\xC8\xFF\x34\x8E\x08\x39\x5F\x62\x94\xA6\x56\x04\xCF\x58\xEE\x91\xE0\x56\xB4\x18\x84\xAE\x45\xA6\x4D\xCB\xD8\x46\x53\x84\x1A\x67\x53\x03\x6A\xCA\xBE\xAD\xA5\x5F\xE9\x92\x0B\x5F\x3E\x4B\xB4\xC7\xD9\xC6\x36\xEF\x56\x23\x25\xB8\xC3\x70\xD2\x80\x83\xEF\x32\xF8\x86\x99\xA9\xDA\x27\x4A\xEE\x30\x0C\x52\xA2\xC0\xF4\x3D\x47\xF2\xEF\x73\xF0\xFC\x90\xF3\xA0\x55\x6C\x23\x17\xA1\xDE\xB3\x29\x7D\x96\xE2\x7D\xBB\x94\x3E\x75\x91\x3A\x9E\xC6\x11\xC9\x89\x04\xEA\xBB\xC8\xCE\x72\x01\x3C\xC1\xB8\xBF\xC7\x96\xD4\x36\xEA\xBF\x63\xEC\x30\x7E\xB2\x8B\x90\x18\xEC\xF6\xB7\x43\x3D\x4F\x96\x4B\x2F\x6D\x90\x7F\x79\xF1\x92\x0F\x95\xD8\x2C\x31\x68\xEF\x6C\xB8\xAC\x46\x72\x71\xAD\xD7\x7F\x9C\x1B\x0F\x98\x8E\x0E\xED\xE3\x0E\xC6\xF8\xB5\x23\x50\x13\x12\x43\xAB\xD8\x46\x00\xDB\x2C\x89\x80\x9E\x23\x92\x03\x09\xF7\xAE\x95\xCF\x1E\xC6\xD3\x10\x32\x33\xBC\xC1\x75\x04\x7F\x5C\x02\x3B\x0C\x83\x92\xC4\x61\x59\xF5\x8F\x18\xB7\xF6\xFF\x6B\x36\x30\xF5\xFD\xBB\x60\x1A\xC9\x65\xD2\x22\xB6\x51\x2B\x5A\xEF\xED\x22\x33\xA0\x71\x44\x72\xA0\x8F\xE5\xCA\x51\xC9\x98\x0D\x87\x1B\xD0\x38\x6A\x81\xAF\x8E\x24\x20\xE7\x3D\x8E\x97\x09\xD6\x30\xFB\x97\x5C\xC7\x70\x09\xD1\xB4\x88\x6D\x24\xD4\xDE\xE3\x73\x29\x7B\x8A\x7C\xA4\xC6\x2F\x5B\x34\x34\x8E\x48\x0E\xC6\xA2\xF6\x5E\xCB\x49\x8C\x4B\xE7\xBB\x7F\x76\x38\xBD\xB5\xFE\x0E\x34\x8E\x48\x38\xAD\x62\x1B\x09\x2E\x4F\xCE\x16\xF5\xD3\xB3\xC1\x65\xE8\x49\x1A\x47\x84\x4C\x60\x2F\xBF\xC8\x52\x1A\x29\x4F\xED\x6B\x1F\xB6\x38\xBE\x4B\x8A\xFB\xCB\xE6\xD3\xE2\xEA\x8E\x56\xD7\x85\xB4\x8A\x6D\x14\xC2\x0A\xF5\xF5\xD6\xBA\x81\xCC\x16\xDC\xC1\x6D\x78\xB6\x6A\x8F\x4E\xB8\x21\x9B\xE4\xA6\x65\x67\x5F\x64\x27\x1B\x41\xCF\x60\x53\x8D\x0C\xFD\xBB\x1A\x65\xAF\x07\xB4\xD0\x4D\xAE\x97\x66\x48\xB5\xA8\xC3\x73\x6E\x37\x35\x62\x1B\x85\xB4\xC5\x29\x83\xEC\x0E\x65\xF4\x87\xAB\x6C\x1F\x11\x56\x87\xFA\xD2\xE8\x25\xE2\xF2\x1E\xB9\xAE\x6C\x09\xF9\xBC\xC9\x98\x42\xE3\x88\x9C\x33\x39\x22\xFD\xB6\x38\x6E\xAB\xD3\xED\x53\x0E\x53\xE8\xB4\xD7\x70\x6F\xEB\x01\x7A\x4A\x69\x2F\x21\x0A\x73\x49\x5A\xD4\xE1\x39\xB7\x9B\x1A\xB1\x8D\x6C\xAF\xE6\x14\xAE\x81\xF6\x0D\x7E\x23\x64\x85\xB8\x70\x25\x2E\x79\x72\x90\x65\xAA\x6F\xC8\x4D\xF7\x6F\xC8\x73\x42\x34\xB5\xBD\x84\xE0\xF2\x02\xDE\xE1\x38\xBE\x9A\xCD\x23\x4C\x40\xDA\x29\x9A\x2D\xD9\xD1\x38\x22\xB9\xA9\x39\x08\xEA\x8E\x93\xD2\xF9\x4B\x2A\x8C\x29\xF6\x38\x4E\xFB\x1A\xF1\xE5\x36\x76\xBA\xAF\xC6\x0C\x4B\x0F\x0A\x53\xCA\x4B\x9F\x52\x9C\x13\x47\x66\x89\xB3\xE6\x16\x75\x78\xCE\xED\xA6\x56\x6C\xA3\x57\x00\x5D\xFF\x8C\x95\x8D\x2B\xAF\x6B\x00\x9F\x38\xDD\x1B\x25\x9F\x3D\x02\xF8\xEA\x3F\x0F\x0D\x5B\xE2\x2B\x5B\x31\x90\x3E\x61\x8C\x84\xC7\xFE\x79\x07\xF0\x83\xC1\x70\x90\x50\x29\xBE\xBE\xE0\x32\x26\xD6\x30\xE9\x7F\x87\xDB\x20\x49\xC1\x97\xCF\xE7\x5E\xB6\xE4\xD1\xFE\xB7\x8B\x66\xA7\x19\x69\x1C\x91\x1C\xD8\xB3\x86\x35\xD2\x0C\x8E\x94\x01\x50\x77\x9C\x0D\xA6\x67\x28\x63\xE4\x38\x21\x97\x3A\x70\xEB\x99\xF3\x73\xE4\xBB\x5E\xD5\xBF\xB7\x70\x0F\x38\x2B\x18\x05\x3C\xC7\x78\xD5\x01\x24\x7D\x7B\x46\x74\xFD\xC4\xE6\x11\x30\x6D\x49\x06\xA4\xA5\x51\xBB\x0E\x5B\xC9\xD4\xC4\x2E\xE7\xB5\x8C\x6D\xA4\x71\xDD\x8F\x06\x98\x74\xBE\xC2\x18\x26\x62\x48\x74\x18\x8C\x17\x29\x6B\x31\x6A\x7C\xED\x32\x74\x0F\xA6\x18\x5F\xCF\xFD\x33\xD6\x4F\x43\x0C\x24\x9F\xA7\xE5\x06\xC3\xED\x05\x39\x09\x31\x78\x6F\x30\xE4\xF1\x11\x61\xCB\x98\xCD\x02\xCE\xD2\x38\x22\x39\xD0\xCA\xEE\x15\x71\x06\x92\x74\x9A\x58\x0E\x18\x1F\x2C\x42\xDE\xB5\x81\x71\x57\xA7\xA0\x67\xEF\x29\xC6\xA0\x1E\x94\x44\xF1\xF9\x14\xC6\x0A\x26\xDD\x5A\x79\xFA\x4E\x8D\xC9\x4C\xF7\x1D\x6E\x57\xFE\x14\x63\x8A\xD9\xA7\xB8\x74\x9A\x62\x02\x85\xAE\x30\xDC\xFF\x26\x4B\x19\x4B\x33\x90\x6A\xD7\x61\x2B\x99\x63\xF7\xF2\xC5\x18\x64\x39\x63\x1B\xE5\xF0\x72\x3D\x05\x7E\x4F\x0C\x89\x29\x42\xDB\x65\xA8\xBC\x10\x7C\x06\x52\xAB\xD8\x4A\x07\xE4\x3F\xB9\xBA\x45\xC3\x65\x35\x9E\x56\x23\x39\xD8\xC2\x18\x24\xF6\xAC\xEA\x0D\x66\xD6\xB4\xC3\xF8\x4C\x6D\x85\x41\xF9\xCC\xF1\x66\xBC\xE0\x74\xC3\xE2\x33\x8C\xC2\xDA\x62\x58\x8A\x38\x60\x98\xC1\xCA\xDD\x6F\xE8\xFF\x1E\xEB\xCD\xF8\xC0\xB1\x42\x7C\xEB\xD3\x21\xC7\xDE\x81\xD3\x3B\xCA\x34\x07\x98\x68\xD5\xB6\x81\x26\x6E\xEF\x2D\x86\x65\xA9\x0F\x2B\xDD\xB2\xA7\x42\xA7\xF7\x09\x6E\x25\xA2\x37\x7E\x4A\x99\x4B\xFD\x4C\xCD\xA6\x57\xD6\x77\xF5\x00\xB0\x87\xDF\x38\xFA\xEE\xD3\x66\xBB\xCE\x65\xE9\x42\xE4\x4A\x99\x49\xFD\x88\xCC\xB1\x4D\xA8\x4B\xDB\xD4\x5D\xB3\x0E\x5B\xCA\xDC\xE1\xB8\x0E\x37\x18\xEA\x50\xDA\xF8\xD8\x44\x45\xC8\x1D\xDB\x68\x8B\x79\x86\xF2\x07\x4E\xEF\x19\x9C\xC3\x33\xDC\x9E\x93\x3D\x4E\xFB\xC1\x1C\x6E\xFA\x67\xAC\xCF\xEE\x70\xEA\x1D\xAC\x85\xE8\xE2\x1C\xFD\x54\x74\x47\x3B\xBA\xAE\xE3\xC3\x27\xC7\xB3\xEE\xBA\xEE\xA7\xCB\xC7\x63\x84\xEC\xFB\x44\x19\x3F\x9D\x49\xB7\xCD\x7B\x80\xBC\x9B\x80\x77\x6F\x0A\xA7\x5D\x78\x0D\x90\xB1\xEA\xBA\xEE\x2D\xE0\x5D\x5F\x9D\xC9\xFF\xBB\xE7\x7B\x9F\xFD\x3B\x43\xEB\xE7\x35\x26\x43\x13\xB8\xF2\xA9\xD3\x9B\xDA\x86\x53\xDF\x53\xA3\x0E\x5B\xCB\x7C\xF6\xBC\x6F\xAA\xDF\xE8\x74\xAE\x23\xE5\x4E\xF5\xBF\x10\x5D\xE3\xEB\x83\xBE\x3C\x85\xF0\xD9\xA7\x27\x24\xDD\x8F\x19\xE4\x89\xCE\x9A\x9B\xAF\xA9\xFA\x72\xF5\xFD\x10\x9D\xBC\xEA\x4C\x99\xCC\xE1\xAB\x0B\x6B\x27\x1B\xC7\x3B\x42\xF4\xB8\x33\xAF\x5C\x56\x23\xB9\xD8\x03\xB8\x45\x9A\x1B\xD4\x35\xEB\x0C\x61\x0B\x33\x9B\x8E\x71\x29\x4B\x7A\x53\x62\xAD\x7C\xF7\xF2\x72\xB0\x85\x09\x9A\x19\xEB\x0E\x3F\xC0\xCC\xAC\x42\xD2\x21\x11\xCB\x6F\xE1\x5E\x96\x08\xF1\xE4\xBD\xF4\xEF\x89\x49\xEF\x03\x4C\x5A\x53\x5C\xFE\x31\xF9\x6C\x45\x8D\x3A\x6C\x2D\xF3\x05\x69\x4B\x5A\x25\x62\x1B\x7D\x23\xBE\x0D\x8E\xF1\x04\x53\x86\xA9\x3A\xEB\x09\xE6\x0A\x9D\xD0\xDF\xBF\xCC\x90\x07\x98\x3A\xFF\x07\xFE\x32\x4C\xAD\xAB\x1C\x1C\x60\xEA\x26\x75\x89\x6D\x07\x53\xA6\xCD\x63\x60\xD1\x38\x22\x39\xD9\xC3\x34\xEC\x27\x84\x35\x6E\x71\x37\xFF\x83\xF9\x9B\x34\xB7\xBD\x6C\xDF\x06\xD3\x3D\xCC\xC0\x30\xB7\x03\x6E\x61\x94\x40\x8E\xCD\xA5\x3B\x98\x32\x08\x29\x37\x71\x37\xFF\x46\xBC\x02\xFA\x80\x49\x73\xA8\x2C\x61\xDF\xCB\x92\xDF\xA5\x0C\x4A\xF6\xEF\x63\xDB\xC6\x39\x44\xE1\xAE\x55\x87\xAD\x64\xCA\xA0\xF7\x80\xF0\x81\xB7\x64\x6C\xA3\x3D\x86\xBC\xCF\x31\x04\xA4\x0C\x1F\x10\x96\xBE\x5D\xFF\xDD\x5F\x48\x2B\xC7\x58\x79\xDF\x18\xFA\x4E\xE8\x04\xD0\xAE\xAB\x16\x46\x86\x18\x8E\xD2\x77\x7D\xC6\xA0\x4C\x8E\x6F\x91\x66\xF0\x17\xE1\xAF\xAE\xEB\x5A\xA7\x81\x5C\x2E\xF6\xE5\xA5\xF2\x5F\xE9\xAC\xA5\x67\x36\x32\x63\x5D\x63\xD8\xD3\xE2\xDB\x07\x34\x07\x7D\x51\xEB\x1C\x59\xF2\x2E\xD9\x97\x25\xE9\xB7\xF7\x34\xE5\x44\x64\x89\x3C\x91\x05\x94\xAB\x27\x57\xDB\x28\x59\x4F\xB5\xA8\x5D\x87\xAD\x64\xBA\xD0\x31\x6C\x7E\xE1\x3C\xEA\x55\x74\x87\x5C\xC8\x5C\x5A\x67\xD9\xBA\x0A\x28\xD3\x0F\xB4\x7E\x12\x7D\x58\x0B\xD9\x27\xB5\x94\xB6\xE9\x85\xC6\x11\x21\x84\x90\x12\x7C\x61\x38\x45\xB7\x83\xF1\x0A\x10\x72\x16\x70\x59\x8D\x10\x42\x48\x6E\x96\x14\xDB\x88\x90\x68\x68\x1C\x11\x42\x08\xC9\x4D\xCE\xD8\x46\x84\x54\x87\xC6\x11\x21\x84\x90\xDC\xE4\x8E\x6D\x44\x48\x55\x68\x1C\x11\x42\x08\xC9\x89\x0E\x38\x49\xE3\x88\x9C\x1D\x34\x8E\x08\x21\x84\xE4\x44\xC7\x36\x5A\xE4\x69\x24\x42\x5C\xF0\xB4\x1A\x21\x84\x90\x9C\xD8\xC6\xD1\x62\x8F\x6A\x13\xE2\x82\xC6\x11\x21\x84\x10\x42\x88\x05\x97\xD5\x08\x21\x84\x10\x42\x2C\x68\x1C\x11\x42\x08\x21\x84\x58\xD0\x38\x22\x84\x10\x42\x08\xB1\xF8\xBB\x75\x02\xC8\xF9\xF3\xEF\xBF\xFF\xB6\x4E\x02\x21\xE4\xF2\x58\xE3\x78\x73\xB7\xEF\x52\x69\x42\xB2\x41\xE3\x88\x10\x42\xC8\x12\x79\xC4\x10\x4C\x52\x6E\xA7\x27\xA4\x0A\x5C\x56\x23\x84\x10\xB2\x34\x56\x60\x94\x6D\xD2\x10\x1A\x47\x84\x10\x42\x96\xC6\xBD\xFA\x37\xEF\x66\x23\x55\xA1\x71\x44\x08\x21\x64\x69\xD8\x5E\xA3\x1D\x18\x48\x92\x54\x86\xC6\x11\x21\xE4\xDC\x79\x07\xD0\x59\x0F\xC9\x4B\xED\xF2\x5D\xF7\x8F\xF0\x61\xFD\xFF\x46\xA5\xC5\x7E\xDE\x2B\xA4\xED\xD2\xD1\x75\x6D\x3F\x8F\x0D\xD3\x55\x1D\x1A\x47\x84\x10\x42\x96\x84\xED\x35\x3A\x80\xFB\x8D\x48\x03\x68\x1C\x11\x42\x08\x59\x12\xF6\x7E\x23\xEE\x35\x22\x4D\xA0\x71\x44\x48\x3C\x74\xE5\x13\x52\x86\x3B\x98\x93\x6A\x02\xBD\x46\x71\x70\x59\x2C\x13\x34\x8E\x08\x21\x84\x2C\x05\x7B\x49\xED\x1B\xC0\xBE\x55\x42\xC8\x75\x43\xE3\x88\x10\x42\xC8\x12\x60\x6C\x23\xB2\x18\x68\x1C\x11\x42\x08\x59\x02\x3A\xB6\x11\x8D\x23\xD2\x0C\x5E\x1F\x42\x08\x21\x64\x09\xE8\xD8\x46\xBC\x47\xAD\x3E\x4F\x38\xDE\xF3\x65\x73\x55\xB1\xA6\x68\x1C\x11\x42\x08\x69\x8D\x8E\x6D\xC4\x53\x6A\x6D\xE0\x1E\xAF\x1E\x2E\xAB\x11\x42\x08\x69\x8D\x8E\x6D\x44\xE3\x88\x34\x85\x9E\x23\x52\x9A\x35\x80\x9B\xFE\xB1\xD9\xC3\xB8\x69\xAF\xCA\x55\x1B\x88\xCC\xA2\xB5\x7B\x7B\x8F\xE3\x68\xC1\x39\xE5\xAD\x70\x3C\x73\x07\xCC\x20\xF5\x5D\x50\xE6\x58\xBB\x90\x36\x91\x7B\x06\x7B\x63\xC9\x14\x0E\xBD\x9C\x12\xB3\xE5\xDA\x75\xD8\x4A\x66\x2E\xEC\xFD\x46\x2D\xF7\x1A\xB9\xF4\x55\x89\x32\x14\x59\xBA\xEF\x95\xEA\x07\xAD\xD8\xC0\xE4\x73\xAC\x6D\xEE\x51\x67\x09\x75\x83\xE3\x72\x16\xDD\x36\x2A\x9B\xC6\x11\x29\xC1\x0D\x8C\xB2\xBB\xC3\xA9\x92\xD1\xEC\x61\x94\x61\x8A\x42\x7C\x87\x69\xF0\xC2\x5F\x09\xEF\x00\x8E\xAF\x44\xF8\x00\x70\xEB\xF9\x8E\xCD\x66\xE2\xB3\x5B\xC4\x29\xD3\x1B\x98\x38\x24\x3A\xCE\xCB\x18\x5B\x98\x99\xF5\x1C\x65\x1D\x53\x47\xE8\x65\x7D\xF4\xB2\x53\x15\x59\x4C\x1E\xC5\x7B\xF0\x82\x74\x03\x7A\x05\x93\xC7\x7B\xB8\xF3\xF8\x0D\xB3\xD7\x62\xAE\xB7\xA2\x76\x1D\xB6\x92\x99\x1B\x9D\xF6\xDA\x5E\x23\xE9\x0B\xF7\x70\x97\xE1\x01\xA6\x3D\xCE\xE9\x03\x40\x78\xBB\x14\x99\x3B\xB8\xEB\xED\x11\xC0\x73\x80\xDC\x67\xEB\x7B\x53\x7A\x4E\xEB\x54\x9B\x27\x98\xFC\x87\xB2\xC1\xA0\x63\x7C\x48\xFE\x62\xC6\x81\x0D\xA6\xE3\xCC\xD9\xF9\x7B\xEC\x9F\xA9\xBA\xDD\xC1\xE4\xED\x48\xCF\x70\x59\x8D\xE4\x64\x05\xD3\xF9\xBE\x60\x1A\x63\xC8\xA0\xBB\x06\xF0\x0A\xE0\x13\xA7\xB3\xA7\x6B\xE1\x11\xA6\xCC\x7C\xCA\x59\xB8\x87\x51\x0A\x21\x0A\xD1\x25\x2F\xB4\x8E\x00\xA3\x88\xA4\x6E\x9F\x11\x96\x4E\x1B\xF9\x6D\x68\x1E\x65\x00\x11\x79\xB1\xAC\x61\xDA\xD4\x33\xFC\x79\xBC\x01\xF0\x06\xD3\x0E\x53\xA9\x5D\x87\xAD\x64\x96\xC0\x1E\x3C\x4B\x79\xF2\xA6\xB0\xFB\x82\xAF\x0C\x6D\xFD\x16\x32\xE0\xBB\xE4\x85\xB4\x4B\x91\x29\xF5\xF6\x1E\xF8\x9B\xD6\xAC\x30\xA4\x37\xB4\x9C\xEE\x50\x66\x1C\x78\x85\x5F\x5F\xDD\xF5\x72\x8F\x4E\x4B\xD2\x38\x22\xB9\x90\x0E\x91\x1A\x85\x75\xDD\xFF\xFE\xDA\x0C\x24\xE9\xBC\x29\x3C\xC2\x74\xEA\x1C\xF2\x0E\x18\xBC\x43\xF2\x8C\xB1\xC2\xA0\xE0\x43\xF9\xC4\xBC\xE8\xBC\x92\xCF\x50\x83\x4C\xDA\x52\xEC\x40\x72\x8F\x34\x03\xA9\x76\x1D\xB6\x92\x59\x82\x1B\x9C\x9E\x52\xAB\x45\x6A\x19\xAE\x60\x8C\x69\x1D\x7A\x20\x54\x5E\xEC\xC4\x42\xD8\xC0\xD4\x5B\xAA\x61\x56\x03\x99\x94\x4C\x79\x9F\x42\x7E\x9F\x6B\x1C\x78\x44\x78\x1D\xAD\x60\xEA\xE7\xBF\x74\xD3\x38\x22\xB9\xB8\xC7\x69\x83\xDE\xC3\xB8\x2B\x7F\xC3\x2C\x79\xD9\xCF\x6F\x9C\xBA\x50\x45\xE9\xA4\x2A\x8F\x92\xDC\x5A\x8F\xCD\x5E\x7D\x26\x4F\xC8\xEC\x77\xAC\xF3\x1E\x60\xCA\xEC\x16\xA7\xE5\x75\xE2\xFA\x85\x29\xF3\x50\x05\x3F\x26\x6F\xDB\xBF\xFB\xD7\x48\x1E\x6C\xB9\x3A\x3F\x4F\x81\x32\x9F\x31\xBE\x97\xE9\xA5\x97\xF1\x0B\x43\x1E\x25\x0D\x63\xCB\x16\xE2\x61\x0C\xE1\x1D\x43\x1B\xDA\x02\xF8\x33\x22\xE7\x0F\xC6\x07\xE2\xD0\x65\x00\xA1\x76\x1D\xB6\x92\x59\x0A\x5D\xD6\xB5\xF6\x1B\x3D\x23\xDE\xB8\xD1\xBC\x22\x7C\x10\xCF\x21\x0F\x18\x74\xE4\x12\x27\x91\x62\x60\xCC\xF5\x6E\xC9\x44\x7B\xCE\x7B\x6E\x90\xD6\xBE\xFF\xD3\x31\x7F\x75\xDD\xD4\x56\x0A\x42\xC2\xF8\xF7\xDF\x7F\xE5\x7F\xC5\x35\x7A\x00\xF0\x80\xB0\xBD\x0D\x1B\x9C\x1A\x44\xA1\x6B\xDB\x35\xF7\x1C\xCD\xF9\xFE\x18\x37\x38\xF5\xBE\xEC\x60\xCA\xCD\xB5\x9F\x41\x5C\xFB\x5A\xD1\x86\xEC\x71\xFA\xC1\x50\xCE\x07\x18\x03\x21\x66\xFF\xC9\x06\x66\x60\x16\xA3\x37\xE4\xFB\x7A\x4F\x40\x48\x1E\x81\x41\xD1\xCA\xE0\x79\xC0\xB4\xD1\x39\xB6\x4F\xC2\xF5\x7D\x9D\x46\xDD\xFE\xBE\x01\xFC\xE3\xF9\x1D\xD0\xA6\x0E\x5B\xC8\xCC\xD5\xCF\xC6\xF8\xC2\x30\x08\xEE\x60\xDA\xA4\x8B\xD0\x7D\x26\xA9\xEF\x88\x65\x0F\x63\x80\xD6\x92\x27\x32\x6F\x31\xD4\x77\xE8\x9E\x23\x9B\x12\x7B\x8E\x9E\x91\xF7\xFE\x36\x5F\x7D\xE6\x2E\x57\xE1\x01\xC0\x96\x9E\x23\x92\x93\x1D\xCC\xA0\xF2\x1B\xE1\x83\xEE\x07\x4C\x63\xB4\xC9\x31\xC3\x5A\x3A\x5A\x89\xEC\x61\x06\x06\x9F\xD1\x20\x86\xA7\x9E\x61\xFB\x94\x92\xDE\xF4\xFA\x82\xF8\x8D\xB9\xA2\xAC\x42\xBD\x46\xDA\x2B\xF0\x81\xB0\x3C\x02\x83\xF1\x26\x5E\xA4\x50\x6F\x9C\x10\xFA\x7D\x49\x93\xCD\xD8\xE9\xA1\x31\x6A\xD7\x61\x2B\x99\xA5\xD0\xA7\x07\x6B\x2D\xA9\xE5\xF4\x98\xAD\xE1\xD7\x57\x73\xF6\xB2\x69\x76\x38\x36\x8C\x96\x82\x2C\xB7\xE7\x44\x9F\x2E\xAB\xC5\x3D\xC0\x65\x35\x92\x9F\x03\xE2\x3B\xEE\x0E\xC7\x03\x59\xE8\xE0\x74\xCE\x68\xC3\xC1\x37\x63\xD6\x3C\xE1\xB8\x9C\xE5\xA8\xEC\x14\xFA\xB3\x1A\xCB\x17\x7A\xD0\xD0\x46\x70\x08\x0F\x30\x06\x77\x8C\x61\xF4\x12\xF9\xFD\xB1\x53\x32\x21\x7B\x26\x6A\xD7\x61\x2B\x99\xA5\xB0\xDB\x47\xAD\xD8\x46\x3A\xD8\xA4\xE6\x1B\x43\x9B\x93\xA5\xC9\x3F\x70\xB7\x27\x97\x71\x14\x5A\xBE\x72\x62\x4A\x9E\xB1\x53\x9A\xB2\x44\xAC\xF5\xEB\x8B\x95\x56\xD7\x84\xE7\xC9\xFA\x5E\x8A\xB7\xDB\x45\xC8\x84\x56\x3C\xCE\xF2\x84\x4C\xCE\xE6\x4E\x94\x65\x09\xDF\x2E\x57\xDF\xF8\xB4\x06\xB0\xA2\x71\x44\x96\x82\x56\x8C\xA9\x1B\xFA\xCE\x81\x0D\x4E\x8F\x2E\xC7\x1E\x57\x3F\x20\x6D\x40\xB7\x7F\x5F\x12\x9D\x96\x94\x3C\x0A\xB1\x69\x4D\x39\xAA\x1E\x5B\x96\x2D\xEA\x70\x09\xED\x26\x27\x2D\x2E\x99\x75\xED\x27\x93\x25\xB2\x2D\x8E\xCB\x55\xBC\x35\x53\x06\x92\xF6\x80\xD9\xF8\xCA\x76\x0F\x63\x88\xFD\x81\x19\xB8\xE5\x79\xEA\xFF\x2E\xCB\xA5\x5B\xA4\x4D\x2E\x6A\xE1\xCB\xE7\x03\x4C\xD9\xDA\x79\x94\xBD\x8D\xAE\xFE\x3D\xA7\x6D\x4A\xD9\x8A\x51\x64\x97\xAB\x6F\xF2\xB4\xA6\x71\x44\x96\xC2\xA5\x04\x3B\x0B\x61\x6C\xE3\x7A\x0A\xDA\x08\x88\xD9\xC8\x5E\x7A\xD3\x7B\xAE\x3C\xA6\x90\x62\x1C\xE9\xF4\xF9\x66\xFB\x2D\xEA\x70\x09\xED\x26\x17\x3A\xFC\x40\xAD\x25\x35\x97\xD7\xC8\xB5\x3C\x29\x1B\xDE\xA7\x98\x1A\xC4\x5D\x83\xBB\x2C\x17\xBB\x0C\xDC\x2D\x06\x23\x69\xC9\xB8\xCA\xD5\x15\xC7\xEE\x03\xEE\x7D\x4C\x63\x81\x23\x43\xD1\x5E\x52\x41\x96\xEC\x5D\xD0\x38\x22\x64\x01\xA4\x0E\x72\xFA\x77\x3E\x45\x6C\x53\x7B\x5F\xD7\x39\x18\xBF\x7A\x69\x37\xF5\xB7\x73\x7E\x17\x33\x53\x6E\x21\x33\x17\xB6\xCC\x9A\xB1\x8D\xA6\xF2\x1A\xE2\x85\xFB\x80\xDB\x7B\x14\xF3\x77\x20\x6C\x89\x07\x81\xDF\x69\x8D\xCB\x80\xF1\x19\xBE\x3E\xAF\x61\xCA\x16\x0B\x09\x4D\x32\x85\x37\xF2\x3F\x8D\x23\x42\xCE\x97\x18\xA5\xA9\x15\xC1\x33\x96\x7B\x24\xB8\x15\x2D\x06\xA1\x6B\x91\x69\xD3\x32\xB6\xD1\x14\xA1\xC6\xD9\xD4\x80\x9A\xB2\x6F\x6B\x69\x91\xCA\x4B\xE1\xCB\x67\x89\xF6\x38\xDB\xD8\xE6\xF5\x21\xA4\x04\x77\x18\x4E\x1A\x70\xF0\x5D\x06\xDF\x30\x33\x55\xFB\x44\xC9\x1D\x86\x41\x4A\x14\x98\xBE\xE7\x48\xFE\x7D\x0E\x9E\x1F\x72\x1E\xB4\x8A\x6D\xE4\x22\xD4\x7B\x36\xA5\xCF\x52\xBC\x6F\x97\xD2\xA7\x2E\x52\xC7\xD3\x38\x22\x39\x91\x40\x7D\x17\xD9\x59\x2E\x80\x27\x0C\xD7\x11\x68\x36\xEA\xBF\x63\xA4\xDC\x7F\x44\x88\xC6\x6E\x7F\x3B\xD4\xF3\x64\xB9\xF4\xD2\x06\xF9\x97\x17\x2F\xF9\x50\x89\xCD\x12\x83\xF6\xCE\x86\xCB\x6A\x24\x17\xD7\x7A\xFD\xC7\xB9\xF1\x80\xE9\xE8\xD0\x3E\x24\xC8\xA7\x1D\x81\x9A\x90\x18\x5A\xC5\x36\x02\xD8\x66\x49\x04\xF4\x1C\x91\x1C\x48\xB8\x77\xAD\x7C\xF6\x30\x9E\x86\x90\x99\xA1\xDC\x8C\x4D\xCA\x23\xB7\x7C\x03\x43\x1C\x96\x55\xFF\x88\x71\x6B\xFF\xBF\x46\x22\xD3\xFA\x22\x03\x13\xA2\x69\x11\xDB\xA8\x15\xAD\xF7\x76\x91\x19\xD0\x38\x22\x39\xD0\xC7\x72\x53\xAF\xA6\xA0\x71\x54\x9F\x90\xEB\x2A\x24\x0A\xB0\xBD\x4C\xB0\x86\xD9\xBF\x14\x72\xCD\x0B\x21\x42\x8B\xD8\x46\x42\xED\x3D\x3E\x97\xB2\xA7\xC8\x47\x6A\xFC\xB2\x45\x43\xE3\x88\xE4\x60\x2C\x6A\xEF\xB5\x9C\xC4\xB8\x74\xBE\xFB\x67\x87\xD3\x5B\xEB\xEF\x40\xE3\x88\x84\xD3\x2A\xB6\x91\xE0\xF2\xE4\x6C\x51\x3F\x3D\x1B\x5C\x86\x9E\xA4\x71\x44\xC8\x04\xF6\xF2\x8B\x2C\xA5\x91\xF2\xD4\xBE\xF6\x61\x8B\xE3\xBB\xA4\xB8\xBF\x6C\x3E\x2D\xAE\xEE\x68\x75\x5D\x48\xAB\xD8\x46\x21\xAC\x50\x5F\x6F\xAD\x1B\xC8\x6C\xC1\x1D\xDC\x86\x67\xAB\xF6\xE8\x84\x1B\xB2\x49\x6E\x5A\x76\xF6\x45\x76\xB2\x11\xF4\x0C\x36\xD5\xC8\xD0\xBF\xAB\x51\xF6\x7A\x40\x0B\xDD\xE4\x7A\x69\x86\x54\x8B\x3A\x3C\xE7\x76\x53\x23\xB6\x51\x48\x5B\x9C\x32\xC8\xEE\x50\x46\x7F\xB8\xCA\xF6\x11\x61\x75\xA8\x2F\x8D\x5E\x22\x2E\xEF\x91\xEB\xCA\x96\x90\xCF\x9B\x8C\x29\x34\x8E\xC8\x39\x93\x23\xD2\x6F\x8B\xE3\xB6\x3A\xDD\x3E\xE5\x30\x85\x4E\x7B\x0D\xF7\xB6\x1E\xA0\xA7\x94\xF6\x12\xA2\x30\x97\xA4\x45\x1D\x9E\x73\xBB\xA9\x11\xDB\xC8\xF6\x6A\x4E\xE1\x1A\x68\xDF\xE0\x37\x42\x56\x88\x0B\x57\xE2\x92\x27\x07\x59\xA6\xFA\x86\xDC\x74\xFF\x86\x3C\x27\x44\x53\xDB\x4B\x08\x2E\x2F\xE0\x1D\x8E\xE3\xAB\xD9\x3C\xC2\x04\xA4\x9D\xA2\xD9\x92\x1D\x8D\x23\x92\x9B\x9A\x83\xA0\xEE\x38\x29\x9D\xBF\xA4\xC2\x98\x62\x8F\xE3\xB4\xAF\x11\x5F\x6E\x63\xA7\xFB\x6A\xCC\xB0\xF4\xA0\x30\xA5\xBC\xF4\x29\xC5\x39\x71\x64\x96\x38\x6B\x6E\x51\x87\xE7\xDC\x6E\x6A\xC5\x36\x7A\x05\xD0\xF5\xCF\x58\xD9\xB8\xF2\xBA\x06\xF0\x89\xD3\xBD\x51\xF2\xD9\x23\x80\xAF\xFE\xF3\xD0\xB0\x25\xBE\xB2\x15\x03\xE9\x13\xC6\x48\x78\xEC\x9F\x77\x00\x3F\x18\x0C\x07\x09\x95\xE2\xEB\x0B\x2E\x63\x62\x0D\x93\xFE\x77\xB8\x0D\x92\x14\x7C\xF9\x7C\xEE\x65\x4B\x1E\xED\x7F\xBB\x68\x76\x9A\x91\xC6\x11\xC9\x81\x3D\x6B\x58\x23\xCD\xE0\x48\x19\x00\x75\xC7\xD9\x60\x7A\x86\x32\x46\x8E\x13\x72\xA9\x03\xB7\x9E\x39\x3F\x47\xBE\xEB\x55\xFD\x7B\x0B\xF7\x80\xB3\x82\x51\xC0\x73\x8C\x57\x1D\x40\xD2\xB7\x67\x44\xD7\x4F\x6C\x1E\x01\xD3\x96\x64\x40\x5A\x1A\xB5\xEB\xB0\x95\x4C\x4D\xEC\x72\x5E\xCB\xD8\x46\x1A\xD7\xFD\x68\x80\x49\xE7\x2B\x8C\x61\x22\x86\x44\x87\xC1\x78\x91\xB2\x16\xA3\xC6\xD7\x2E\x43\xF7\x60\x8A\xF1\xF5\xDC\x3F\x63\xFD\x34\xC4\x40\xF2\x79\x5A\x6E\x30\xDC\x5E\x90\x93\x10\x83\xF7\x06\x43\x1E\x1F\x11\xB6\x8C\xD9\x2C\xE0\x2C\x8D\x23\x92\x03\xAD\xEC\x5E\x11\x67\x20\x49\xA7\x89\xE5\x80\xF1\xC1\x22\xE4\x5D\x1B\x18\x77\x75\x0A\x7A\xF6\x9E\x62\x0C\xEA\x41\x49\x14\x9F\x4F\x61\xAC\x60\xD2\xAD\x95\xA7\xEF\xD4\x98\xCC\x74\xDF\xE1\x76\xE5\x4F\x31\xA6\x98\x7D\x8A\x4B\xA7\x29\x26\x50\xE8\x0A\xC3\xFD\x6F\xB2\x94\xB1\x34\x03\xA9\x76\x1D\xB6\x92\x39\x76\x2F\x5F\x8C\x41\x96\x33\xB6\x51\x0E\x2F\xD7\x53\xE0\xF7\xC4\x90\x98\x22\xB4\x5D\x86\xCA\x0B\xC1\x67\x20\xB5\x8A\xAD\x74\x40\xFE\x93\xAB\x5B\x34\x5C\x56\xE3\x69\x35\x92\x83\x2D\x8C\x41\x62\xCF\xAA\xDE\x60\x66\x4D\x3B\x8C\xCF\xD4\x56\x18\x94\xCF\x1C\x6F\xC6\x0B\x4E\x37\x2C\x3E\xC3\x28\xAC\x2D\x86\xA5\x88\x03\x86\x19\xAC\xDC\xFD\x86\xFE\xEF\xB1\xDE\x8C\x0F\x1C\x2B\xC4\xB7\x3E\x1D\x72\xEC\x1D\x38\xBD\xA3\x4C\x73\x80\x89\x56\x6D\x1B\x68\xE2\xF6\xDE\x62\x58\x96\xFA\xB0\xD2\x2D\x7B\x2A\x74\x7A\x9F\xE0\x56\x22\x7A\xE3\xA7\x94\xB9\xD4\xCF\xD4\x6C\x7A\x65\x7D\x57\x0F\x00\x7B\xF8\x8D\xA3\xEF\x3E\x6D\xB6\xEB\x5C\x96\x2E\x44\xAE\x94\x99\xD4\x8F\xC8\x1C\xDB\x84\xBA\xB4\x4D\xDD\x35\xEB\xB0\xA5\xCC\x1D\x8E\xEB\x70\x83\xA1\x0E\xA5\x8D\x8F\x4D\x54\x84\xDC\xB1\x8D\xB6\x98\x67\x28\x7F\xE0\xF4\x9E\xC1\x39\x3C\xC3\xED\x39\xD9\xE3\xB4\x1F\xCC\xE1\xA6\x7F\xC6\xFA\xEC\x0E\xA7\xDE\xC1\x5A\x88\x2E\xCE\xD1\x4F\x45\x77\x34\x83\xC6\x11\xC9\xC1\x01\xC0\x2D\x4E\x67\x34\x35\x2E\x9E\x95\x4E\xA4\x15\xC2\x0D\xFC\xCA\x48\xD2\xFD\x19\x29\xF3\x05\xA7\xCA\x59\x2B\xDA\x5B\xF8\x67\xB9\x3B\x98\x81\x4E\xA7\xFD\x7E\xE4\xFD\x53\x6C\xE1\x9F\xB1\xC9\x11\x7C\xED\xE1\xD2\xF5\x63\x1B\x77\x2E\x83\x75\x0F\x93\xBF\x10\x5E\x30\xBE\xCF\xC5\xBE\xF4\x36\x84\x2D\x4C\x59\x2D\x8D\x5A\x75\xD8\x52\xE6\xD8\xA5\xC5\xDA\xDB\x3B\x75\xE7\x5E\x89\xD8\x46\x63\x13\xA2\x58\x64\xE0\x9D\x6B\x20\xED\x61\xE2\xBA\xF9\x3C\x36\x52\xD6\x73\x0D\x24\xD1\x59\x53\x4B\x83\xE2\xC1\xC9\x65\xF8\xC5\x22\xE3\xC0\x1C\xBD\xFF\x8D\xB0\x32\x2D\x0A\x97\xD5\x48\x2E\x64\xC0\x4C\x71\x83\xBA\x66\x9D\x21\xC8\xC0\x19\xD3\x99\x24\xBD\x29\xB1\x56\xBE\x91\x6F\xA0\xDE\x22\x4D\x11\x1C\x60\x14\x7C\x48\x3A\x24\x62\xB9\xCF\x60\x0B\xF1\xE4\xBD\xF4\xEF\x89\x49\xEF\x03\x4C\x5A\x53\x94\x5D\x4C\x3E\x5B\x51\xA3\x0E\x5B\xCB\x7C\x41\xDA\x92\x56\x89\xD8\x46\xDF\x88\x6F\x83\x63\x3C\xC1\x94\x61\xAA\xCE\x7A\x82\xB9\x42\x27\xF4\xF7\x2F\x33\xE4\x01\xA6\xCE\xFF\x81\xBF\x0C\x53\xEB\x2A\x07\x62\xBC\xA5\x2E\xB1\xED\x60\xCA\xB4\x79\x0C\x2C\x1A\x47\x24\x27\x7B\x98\x86\xFD\x84\xB0\xC6\x2D\xEE\xE6\x7F\x30\x7F\x46\xB9\xED\x65\xFB\x36\x98\xEE\x61\x06\x86\xB9\x1D\x70\x0B\xA3\x04\x72\xCC\x84\x77\x30\x65\x10\x52\x6E\xE2\x29\xFB\x8D\x78\x05\xF4\x01\x93\xE6\x50\x59\xC2\xBE\x97\x25\xBF\x4B\x19\x94\xEC\xDF\xC7\xB6\x8D\x73\x88\xC2\x5D\xAB\x0E\x5B\xC9\x94\x41\xEF\x01\xE1\x03\x6F\xC9\xD8\x46\x7B\x0C\x79\x9F\x63\x08\x48\x19\x3E\x20\x2C\x7D\xE2\xB5\xFB\x85\xB4\x72\x8C\x95\x27\x5E\x3B\xF9\x4D\x48\xDF\xB3\xEB\xAA\x85\x91\x21\x86\xA3\xF4\x5D\x9F\x31\x28\x93\xE3\x5B\x2C\xC0\x63\x24\xFC\xD5\x75\x5D\xEB\x34\x90\x33\xE7\xDF\x7F\xFF\x9D\xFA\xC8\xBE\xBC\x54\xFE\x2B\x9D\xB5\xF4\xCC\x46\x66\xAC\x6B\x0C\x7B\x5A\x7C\xFB\x80\xE6\xA0\x2F\x6A\x9D\x23\x4B\xDE\x25\xFB\xB2\x24\xFD\xF6\xB2\x57\x4E\x44\x96\xC8\x13\x59\x40\xB9\x7A\x72\xB5\x8D\x92\xF5\x54\x8B\xDA\x75\xD8\x4A\xA6\x0B\x1D\xC3\xE6\x17\xCE\xA3\x5E\x45\x77\xC8\x85\xCC\xA5\x75\x96\xAD\xAB\x80\x32\xFD\x40\xEB\x27\xD1\x87\xB5\x90\x7D\x52\x4B\x69\x9B\x5E\x68\x1C\x91\xD9\x38\x8C\x23\x42\xC8\xF5\xF2\x85\xE1\x14\xDD\x0E\xC6\x2B\x40\xC8\x59\xC0\x65\x35\x42\x08\x21\xB9\x59\x52\x6C\x23\x42\xA2\xA1\x71\x44\x08\x21\x24\x37\x39\x63\x1B\x11\x52\x1D\x1A\x47\x84\x10\x42\x72\x93\x3B\xB6\x11\x21\x55\xA1\x71\x44\x08\x21\x24\x27\x3A\xB6\x11\x8D\x23\x72\x76\xD0\x38\x22\x84\x10\x92\x13\x1D\xDB\x68\x91\xA7\x91\x08\x71\xC1\x08\xD9\x84\x10\x42\x72\xB2\xC5\xE0\x2D\xA2\x61\x44\xCE\x12\x1E\xE5\x27\x84\x10\x42\x08\xB1\xE0\xB2\x1A\x21\x84\x10\x42\x88\x05\x8D\x23\x42\x08\x21\x84\x10\x0B\x1A\x47\x84\x10\x42\x08\x21\x16\xDC\x90\x4D\x08\x21\x64\xE9\xAC\x71\x7C\x0A\xCE\x77\xC1\x34\x21\xB3\xE0\x86\x6C\x42\x08\x21\x4B\xE7\x0D\x43\x60\xC9\x6F\x98\x1B\xDF\x09\x29\x06\x97\xD5\x08\x21\x84\x2C\x99\x15\x18\x71\x9B\x54\x86\xC6\x11\x21\x84\x90\x25\x73\xAF\xFE\xCD\x7B\xDA\x48\x71\x68\x1C\x11\x42\x08\x59\x32\xB6\xD7\x68\x07\x06\x96\x24\x15\xA0\x71\x44\x08\xB9\x24\xDE\x01\x74\xD6\x43\xF2\x53\xB3\x8C\xD7\xFD\x23\x7C\x58\xFF\xBF\x51\xE9\xB0\x9F\xF7\xC2\xE9\xAA\xCD\x35\xE5\x75\x11\xD0\x38\x22\x84\x10\xB2\x54\x6C\xAF\xD1\x01\xDC\x6F\x44\x2A\x41\xE3\x88\x10\x42\xC8\x52\xB1\xF7\x1B\x71\xAF\x11\xA9\x06\x8D\x23\x42\xE6\x43\x17\x37\x21\xF9\xB9\x83\x39\xA9\x26\xD0\x6B\x44\xAA\x41\xE3\x88\x10\x42\xC8\x12\xB1\x97\xD4\xBE\x01\xEC\x5B\x25\x84\x5C\x1F\x34\x8E\x08\x21\x84\x2C\x0D\xC6\x36\x22\x4D\xA1\x71\x44\x08\x21\x64\x69\xE8\xD8\x46\x34\x8E\x48\x55\x68\x1C\x11\x42\x08\x59\x1A\x3A\xB6\x11\xEF\x51\x23\x55\xA1\x71\x44\x08\x21\x64\x49\xE8\xD8\x46\x3C\xA5\x46\xAA\x43\xE3\x88\x10\x42\xC8\x92\xD0\xB1\x8D\x68\x1C\x91\xEA\xFC\xDD\x3A\x01\xE4\xAA\x58\x03\xB8\xE9\x1F\x9B\x3D\xCC\x69\x14\x5E\x0B\x70\x8A\xCC\xA2\x57\xEA\xEF\x7B\x1C\x47\x0B\xCE\x29\x6F\x85\xE3\x99\x3B\x60\x06\xA9\xEF\x82\x32\xC7\xDA\x85\xB4\x89\xDC\xA7\x94\x6E\x2C\x99\xC2\xA1\x97\x53\xE2\x44\x54\xED\x3A\x6C\x25\x33\x17\xF6\x7E\xA3\x9C\x7B\x8D\x36\x38\x6E\xD7\xD2\x9E\x73\x2F\xD9\xB9\xF4\xDC\xD2\xCB\x7E\x05\x53\x4E\x76\xDA\x4B\xA4\x7B\x09\x65\x74\x83\xD3\x13\x91\x43\x7B\xE8\xBA\x8E\x0F\x9F\x92\xCF\x4D\xD7\x75\xCF\x5D\xD7\x7D\x75\x7E\x3E\xBB\xAE\xBB\x4F\x94\xF3\xAE\xDE\x95\x9A\x5E\x9B\xF7\xC0\xEF\x85\xB0\x89\x48\xC3\x4D\xD7\x75\xAF\x5D\xD7\xFD\x04\xBC\xF7\x35\xF2\xDD\x73\xEB\xA8\xEB\x4C\xB9\x3C\x76\x5D\xB7\x9A\x29\x33\x34\x8F\x3F\xFD\x77\x6F\x02\xDE\x3B\xD5\x0E\x56\x7D\x9A\x7D\x79\xFC\xEA\xBA\xEE\x6E\x46\xBE\x5A\xD5\x61\x4D\x99\xB9\xFA\xDA\xD8\x73\xA7\xDE\xBD\x76\x7C\x77\xE3\xC8\x9F\xDD\x77\x1F\x3B\x77\x99\xBC\x75\x61\x6D\x2B\xA4\x0F\xF9\xCA\xFE\xA7\x4B\xEB\x3B\xA1\x79\x2D\x55\x4E\x5F\xFD\xE7\xE7\x5A\x46\x5D\x37\xB4\xF7\x55\x67\xEA\x7C\x8A\xD7\xAE\xEB\x56\x39\x1B\x35\x1F\x3E\xF6\xB3\xEA\x4C\x47\x48\xE1\xB3\x73\x2B\xC5\xB1\xE7\x52\x8C\xA3\xC7\x84\x77\x77\x9D\x29\xEB\x94\xFC\xA6\xCA\xEB\x3A\xA3\xC4\x9E\xBB\x78\x25\x96\xDA\x2E\xBA\xCE\x9F\xCF\xB1\x76\xB0\xEE\xC2\x0D\x3F\xE1\xD5\x23\x67\x49\x75\x58\x5B\x66\x49\xE3\xC8\x1E\xB4\x3E\x3D\xDF\x0D\x19\xF4\x5F\x03\xCB\xE1\xA7\x4B\x9F\x98\xA5\x94\xFD\x4F\x17\x67\x84\x97\x36\x8E\x42\xCB\xE9\xB3\x4B\x9B\x14\xB5\x2E\xA3\xAE\xFF\x7C\xDD\x85\x4D\x1E\x3E\xB9\xE7\x88\x94\x60\x05\x13\x29\xFA\x31\xF1\xF7\xEB\xFE\xF7\x7A\x69\xE7\xD2\x79\x05\xF0\x9C\xF8\xDB\x47\x00\x9F\x99\xE4\x1D\x60\xDC\xCB\xF6\x33\xC6\xAA\x97\xFB\x15\x21\xF3\x13\xE9\xED\x02\x18\xF2\xA9\x97\x8B\xA6\x90\xB6\xA4\xDD\xF7\x3E\xEE\x61\xCA\x27\x96\xDA\x75\xD8\x4A\x66\x09\xF4\x32\xC7\xDC\xBD\x46\x8F\x38\x0D\x09\x30\xC5\x0A\xA6\x1C\x37\x91\x32\x52\xCB\x7E\x05\xE0\x0D\xE1\xE9\x2B\xC9\x33\xC2\xD3\xB1\x86\x49\x77\x0C\x4B\x29\x23\x79\x5F\x88\xEE\xD8\xD1\x38\x22\x25\xB8\xC7\xA9\x61\xB3\x07\xF0\x04\xE0\x37\x80\xBF\xD4\xF3\x1B\xA7\x7B\x0B\x62\x1A\x72\x0B\x6E\xAD\xC7\x66\xAF\x3E\x93\xC7\xB7\x97\x65\x4C\x91\x1F\x60\xCA\xEC\x16\xA7\xE5\xF5\x84\xD3\x3D\x5A\x6B\x84\x2B\xA1\x31\x79\xDB\xFE\xDD\xBF\x46\xD2\x6F\xCB\xD5\x79\x79\x0A\x94\xF9\x8C\xF1\xBD\x4C\x2F\xBD\x8C\x5F\x18\xF2\x28\x69\xD8\xE2\x74\x4F\xC8\x1A\xE1\x86\xCB\x3B\x86\x36\xB4\x05\xF0\x67\x44\xCE\x1F\x8C\x0F\xC4\xF7\x38\x1E\xAC\x7D\xD4\xAE\xC3\x56\x32\x4B\xA1\xCB\x7A\xCE\x7E\xA3\x1B\xA4\xE5\x29\xC6\x20\x8E\x31\x2A\x5C\xF2\x5A\x4E\x02\xD7\x88\x9F\xAC\x6C\x22\x7E\xB3\xA4\x32\x7A\x46\xD8\x24\xE9\x03\xC0\x4B\x4E\x77\x28\x1F\x3E\xF6\x73\xD7\x19\xF7\xE5\x57\x17\xBE\xA4\xB4\xE9\x4E\x5D\x9E\xA1\xEB\xDC\xB5\x97\xD5\xE6\xFE\xC6\x7E\x6E\xBA\x53\xDE\x3A\xBF\xFB\x7A\xD5\x8D\xBB\xC3\x43\xCA\xDB\x2E\xE7\x9F\xC0\xDF\xE8\xBA\x7A\xEF\xC2\x97\x65\xC6\x5C\xDE\x21\x79\x94\x7C\xDA\xCB\x2D\x3F\xDD\xF4\xB2\xAB\x6E\x07\xBE\xEF\xFB\xDA\xDF\x57\x60\xFE\x5A\xD4\x61\x0B\x99\x63\x65\x1C\xDB\xDE\xA7\x1E\x7B\xE9\xF3\x2D\xE0\xFB\xBE\x65\x94\x54\x42\x96\xD7\x72\xCA\xF6\x2D\x1F\xFA\xE4\xCD\x59\x56\x4B\xE5\xA7\xF3\xB7\xB3\x25\x95\x51\x28\xFF\xE5\x8B\x9E\x23\x52\x8A\x1D\x80\x7F\x60\x66\xAB\xA1\xA7\x0F\x3E\x00\x3C\xA8\xBF\x2D\xC1\xED\x5C\x1A\x3D\x0B\xDB\xC3\x78\x33\x7C\xA7\x68\x0E\x30\xE5\xA5\x67\xD8\xBE\x59\x9D\xBE\xD0\xF3\x05\xF1\x27\x44\x3E\x60\x3C\x13\xA1\x5E\x23\xED\x15\xF8\x40\x58\x1E\xD1\x7F\xE7\x0F\x06\x2F\x52\x88\x27\xCE\x26\xF4\xFB\x92\x26\x1B\x39\xD9\xE6\xA3\x76\x1D\xB6\x92\x59\x0A\x7D\x7A\xB0\xE5\xF1\xFD\x10\x9D\x93\xD3\xD3\xB6\x0E\x94\xB9\x24\xF4\xF5\x2E\x63\x9C\x63\x19\x3D\xA0\xEF\x3F\x34\x8E\x48\x49\x0E\x88\x3F\x26\xBB\xC3\xF1\x40\x16\x3A\x38\x9D\x33\x5A\xC9\xE8\x01\xDA\xC7\x13\x8E\xCB\x59\x1F\xC5\xD5\xE8\xCF\x6A\x5C\xCD\xA0\x15\x9B\x36\x82\x43\x78\x80\x31\xB8\x63\x0C\xA3\x97\xC8\xEF\x7F\xE0\xB4\x3C\x42\xF6\xA1\xD4\xAE\xC3\x56\x32\x4B\x61\xB7\x8F\x9C\xB1\x8D\x64\xD9\xF6\xA9\x7F\x5E\xE0\xD7\x49\x63\x21\x10\xF4\xE7\x2E\x9D\xF4\x8D\xA1\xAD\xCA\x92\xE6\x1F\xB8\xDB\x61\x6B\xE3\x48\x26\x06\xB2\x8C\xFE\x9F\x91\xE0\xC0\xD5\x2F\x96\x5C\x46\xBA\x4D\x6C\xAD\xBF\xFD\xD7\xEE\x68\x1C\x91\x25\xA2\x15\x63\xEC\x26\xC9\x73\x62\x83\x63\x45\xBC\x43\x7C\xBC\xA7\x03\xD2\x06\x74\xFB\xF7\x25\xD1\x69\x49\xC9\xA3\x10\x9B\xD6\x94\x98\x29\xB1\x65\xD9\xA2\x0E\x97\xD0\x6E\x72\x52\xE2\x92\xD9\x3D\xCC\xE0\x2B\x46\x91\x0C\x88\x21\x06\xB6\x6B\x60\x77\x79\x4C\xF6\x18\xF6\x50\xDA\xF5\xB1\x83\xDB\x83\xA9\x3D\x67\x35\x91\xB4\xED\x30\x1C\xC0\xD8\xF6\x7F\x73\xF5\xB7\x73\x2C\xA3\xB1\x36\xF1\xD0\xCB\x7D\xB1\xBF\x48\xE3\x88\x2C\x91\x12\x81\xF8\x96\xCA\xD8\xC6\xF5\x14\xB4\x11\x10\xB3\x91\xBD\xF4\xA6\xF7\x5C\x79\x4C\x21\xC5\x38\xD2\xE9\xF3\x29\xE4\x16\x75\xB8\x84\x76\x93\x8B\x7B\x9C\x1A\x7A\x39\xD0\x9E\x31\x41\x96\x69\x5D\xB8\x06\x7E\xD7\x67\xAE\x65\x4D\xD9\x28\x3F\x45\x2B\xC3\x74\x2A\x4D\x7B\x28\x83\x41\xE1\xEA\x17\x4B\x2C\x23\x59\x92\x1F\x93\xBD\xD7\x7F\xA7\x71\x44\xC8\xB2\x48\x1D\xE4\xF4\xEF\x5C\x4A\x44\x2B\x87\xDA\x2E\xFD\x73\x30\x7E\xF5\xD2\x6E\xEA\x6F\xE7\xFC\x2E\x66\x20\x68\x21\x33\x17\xB6\xCC\x5C\x51\xCA\x25\x1C\xC5\x14\x73\xA2\xBD\x4F\x95\x51\x88\xF7\xEE\x03\x6E\xCF\x48\x6D\x7C\x37\x13\xF8\x0C\xD5\xA9\xB2\x58\x62\x19\x45\x5D\x60\x4C\xE3\x88\x90\xCB\x20\x66\xB9\x49\x0F\x0A\xCF\x30\x61\x13\x2E\x7D\x6F\x57\x0C\x2D\x6E\x81\xBF\x16\x99\x36\xB9\x63\x1B\x09\x2D\x0C\xF0\x50\x99\x53\x46\x59\x8B\x65\x35\x9F\xA1\x92\xFB\x4A\xA7\x96\x65\x14\x95\x17\xDE\xAD\x46\x4A\x73\x87\xE1\x4E\x23\x0E\xBE\xCB\xE0\x1B\xC6\x5D\x6E\x9F\x4E\xBA\xC3\x30\x48\x89\x62\xD2\xAE\x66\xF9\xF7\x39\x78\x7E\xC8\x79\x90\x33\xB6\x51\x6B\x42\xBD\x6E\x53\x7A\xF0\x92\xF7\x56\x0A\x2D\xCB\x28\x4A\x6F\xD1\x38\x22\xA5\x90\x40\x7D\x34\x88\x96\xC9\x13\xCC\x3E\x8F\xB1\x25\xB5\x8D\xFA\xEF\x18\xB2\x79\xF3\x9C\x07\x33\xD2\x1E\xBB\xFD\x45\x2D\x7B\x34\xC2\xA5\xCF\x36\xB8\x0E\x03\xC7\xC7\x45\x94\x11\x97\xD5\x48\x09\xAE\xF5\xFA\x8F\x73\xE3\x01\xD3\xD1\xA1\x7D\xDC\xC1\x18\xBF\x76\x04\x6A\x42\x62\x58\x52\x6C\xA3\x50\xD8\xD6\xFD\x5C\x44\x19\xD1\x73\x44\x72\x23\xF7\xAA\xE9\x0E\xB2\x87\xF1\x34\x84\xCC\x0C\x6F\xD0\x3E\xEE\xC7\xB5\xB0\xC3\x30\x28\x49\x9C\x9B\x55\xFF\x88\x71\x6B\xFF\xBF\x66\x03\x53\xDF\xBF\x0B\xA6\x91\x5C\x26\xA5\x62\x1B\x11\x32\x1B\x1A\x47\x24\x37\xFA\x58\xAE\x1C\x9B\x8D\x39\x19\xB2\x01\x8D\xA3\x16\xF8\xEA\x48\x02\x72\xDE\xE3\xD8\x35\x2E\xF7\x33\xB9\x8E\xFD\x12\xA2\x29\x11\xDB\xA8\x34\xDC\x6F\xE7\xE7\x22\xCA\x88\xC6\x11\xC9\xCD\x58\xD4\xDE\xD4\x23\xB3\x64\x59\xC8\xB1\xDF\x1D\x4E\x6F\xAD\xBF\x03\x8D\x23\x12\x4E\xA9\xD8\x46\xA5\x71\x79\xBE\xB7\x38\x9F\x7C\x94\xE4\x22\xCA\x88\xC6\x11\xC9\x8D\xBD\xFC\x22\x4B\x69\xA4\x3C\xB5\x8F\x01\x6F\x71\x7C\xDF\x11\xF7\x97\xCD\xA7\xC5\x51\xEE\x56\x51\x99\x4B\xC4\x36\x6A\xCD\x0A\xE7\xA7\xEF\x7C\xF5\xEF\xFB\x3C\x76\x03\xFD\xD9\x94\x11\x37\x64\x93\x92\xB4\xEC\x04\xAD\x94\x7E\x2C\x5A\xB9\xA4\x1A\x19\xFA\x77\x35\xCA\x5E\x0F\x68\xA1\x1B\x31\x2F\xCD\x90\x6A\x51\x87\xE7\xDC\x6E\x4A\xC5\x36\xAA\xC5\x94\x21\x77\x87\x36\x7A\x67\xCE\x06\xE8\x1B\xB8\xD3\xEC\xBB\x5C\x76\xAA\x2C\x96\x56\x46\xD1\xD0\x38\x22\x97\x42\x8E\x48\xBF\x2D\x8E\x98\xEA\x74\xFB\x94\xD1\x14\x3A\xED\xB9\x83\xB7\x8D\xA1\x07\xE8\x29\x25\xBD\x84\x28\xCC\x25\x69\x51\x87\xE7\xDC\x6E\xCE\x3D\xB6\x91\xCB\x80\x7C\x83\xDF\x58\x59\x21\x6F\x98\x93\xB9\x37\xD6\x3F\x3B\xDE\xFB\x38\xF1\x19\xE0\x6E\x2B\x4B\x2B\xA3\x68\x68\x1C\x91\x92\xD4\x1C\x04\x75\x47\x4D\x19\x2C\x52\x07\x98\x39\xEC\x71\x9C\xF6\x35\xE2\xCB\x6D\xEC\x74\x5F\x0D\x0F\x80\x56\x5C\x53\xCA\x52\x9F\x52\x9C\x13\xEB\x64\x89\xC7\x84\x5B\xD4\xE1\x39\xB7\x9B\x73\x8B\x6D\xA4\x71\x95\xD1\x1A\xC0\x27\x4E\xF7\x54\xC9\x67\x8F\x00\xBE\xFA\xCF\x73\x86\x3B\x79\x05\xD0\xF5\x4F\x6C\x3B\xB8\xB3\xD2\x24\x7D\xF3\x19\xFE\x30\x1D\xAE\x72\x58\x62\x19\x45\x41\xE3\x88\xE4\xC6\x9E\xD1\xAE\x91\x66\x70\xA4\x0C\x80\xDA\x35\xBF\x81\x7B\xD6\xA3\xC9\x75\x42\x2E\x25\xED\x7A\xE6\xFC\x1C\xF9\x9E\x57\xF5\xEF\x2D\xDC\x03\xCE\x0A\x46\x39\xCD\x31\x5E\x75\x00\x49\xDF\x9E\x11\x5D\x3F\xB1\x79\x04\x8E\x95\xF8\xD2\xA8\x5D\x87\xAD\x64\x8E\x11\x33\x78\x9D\x63\x6C\x23\x8D\xEB\xEE\x2F\xC0\xE4\xEF\x15\xC0\x0F\x4C\x7B\x7D\x87\x31\x5A\x3E\x71\x5C\x47\x12\xF6\x64\x09\xED\x59\xD2\xFC\xDE\x3F\x8F\xF0\xB7\x25\x57\x19\x9C\x7D\x19\xD1\x38\x22\xB9\xD1\xCA\xEE\x15\x71\x06\xD2\x0D\xE2\x8C\x1A\xE1\x80\xF1\xC1\x22\xE4\x5D\x1B\x18\x57\x6F\x2A\x7A\x06\x1F\x6B\x10\xEA\x41\x49\x82\x68\xFA\xD6\xE6\x57\x30\xE9\xD6\x46\x8E\xEF\xD4\x98\xCC\xC6\x44\x11\xC6\x1A\x49\xF2\x5B\x5B\x79\xFA\x96\x46\x74\x9A\x62\x02\x85\xAE\x30\xDC\xFF\x26\xEE\xF6\x25\x0C\x28\x36\xB5\xEB\xB0\x95\x4C\x60\xFC\x6E\xBE\x50\xA3\xEC\x52\x62\x1B\xB9\x6E\x8E\xB7\xB9\x81\xBB\x7F\x85\xB6\xE7\xA5\x6D\x62\x1E\xD3\xB7\x9A\xDA\x65\x94\x15\x9E\x56\x23\xB9\xD9\xE2\x78\xD6\x21\x8A\x78\x0F\xA3\x08\xC7\x66\x13\x2B\x0C\x1D\x64\x8E\x37\xE3\x05\xC6\x30\xB1\x15\xF5\x33\x4C\xA7\xDA\x62\x58\x8A\x38\x60\x98\xC1\xCA\xDD\x6F\xE8\xFF\x9E\xE2\xF9\xF9\xC0\x71\xC7\x7D\xEB\xD3\x62\xDF\x78\xAD\xEF\x29\xB3\x39\xC0\x44\xAB\xB6\x0D\xB4\x35\xCC\x8C\x6A\x8B\x61\x59\xEA\xC3\x4A\xB7\xEC\x33\xD0\xE9\x7D\x82\x7B\x2F\xC0\x23\x8E\x0D\x12\x29\x73\xA9\x9F\xA9\x19\xDF\xCA\xFA\xAE\x56\x52\x7B\xF8\x15\xE5\x77\x9F\x36\x7B\x7F\x83\xB8\xD7\x45\xAE\x94\x97\xD4\x8F\xC8\xD4\x75\x2A\xBF\x5D\x12\x35\xEB\xB0\xA5\x4C\xC0\xD4\x97\x5D\x8F\x1B\x0C\xF5\x28\x6D\x7C\x6A\xF0\x3C\xC7\xD8\x46\x63\x7C\xE0\xF4\x7E\xC2\x39\x3C\xC3\xBF\xC4\xB8\x45\x7E\x03\x21\x55\xE7\x85\x18\x3E\x2D\xCA\x28\x1F\x5D\xD7\xF1\xE1\x93\xFB\x59\x77\x5D\xF7\xD3\xE5\xE3\x31\x42\xF6\x7D\xA2\x8C\x9F\xCE\xA4\xDB\xE6\x3D\x50\xE6\x4D\xC0\xFB\x37\x05\xD3\x2E\xBC\x06\xC8\x58\x75\x5D\xF7\x16\xF0\xAE\xAF\xCE\xE4\xFF\xDD\xF3\xBD\xCF\xFE\x9D\xA1\xF5\xF3\x1A\x93\xA1\x09\x5C\xF9\xD4\xE9\x4D\x6D\xC3\xA9\xEF\xA9\x51\x87\x4B\x90\xF9\xEC\x79\xE7\x58\xDF\xD1\xE9\x5C\x27\xC8\xB5\x9F\x4D\xA4\x7C\x5F\x1D\xDB\x84\xEA\x1C\x5F\x39\x84\xF0\xD9\x19\x1D\x12\xA2\x67\x42\xF4\xAA\xD6\x35\xBE\x72\x8A\xED\x93\xB1\xED\xA5\x56\x19\xB9\xF2\xD9\x75\x61\x3A\xF8\xBF\x87\xCB\x6A\xA4\x04\x7B\x00\xB7\x48\x3B\xF9\x12\xE2\xAE\x75\xB1\x85\x99\x4D\xC7\xCC\x2E\x24\xBD\xA9\xB1\x56\xBE\x7B\x99\x73\xD9\xC2\x04\xCD\x8C\x9D\x19\x1D\x60\x66\x72\x21\x69\x90\x88\xE5\xB7\x70\xBB\xEA\x43\x3C\x79\x2F\xFD\x7B\x62\xD2\xFB\x00\x93\xD6\x94\xD9\x5F\x4C\x3E\x5B\x51\xA3\x0E\x97\x20\xF3\x05\xF1\x4B\x3D\x97\x18\xDB\xE8\x09\xA6\xEC\x53\x75\xDD\x13\xCC\xD5\x3B\x21\xBF\xFF\x46\x7C\x7F\x0B\xE1\x09\xE1\x75\x21\xFA\x35\xF6\xFD\xB5\xCA\x28\x1B\x34\x8E\x48\x29\xF6\x30\x0D\x3A\xB4\xE3\xED\xFB\xEF\xFE\x83\xF9\xFB\x10\xB6\xBD\x6C\xDF\x06\xD3\x3D\x4C\x47\xFF\x1D\x98\x46\x9F\xCC\x5B\xCC\x4F\xFB\x0E\xA6\x0C\x42\xCA\x4D\x96\xAA\x7E\x23\x3E\x3A\xF5\x07\x4C\x7A\x43\x65\x09\xFB\x5E\x96\xFC\x2E\x45\x51\xDB\xBF\x8F\x6D\x1B\xE7\x10\x85\xBB\x56\x1D\xB6\x94\x79\x80\x69\x3F\x0F\x08\x33\x92\xCE\x3D\xB6\x91\x0B\x29\xFB\x07\x84\xE5\x6B\xD7\x7F\xF7\x17\xE2\xCB\x7F\x8F\xA1\x9E\x73\xED\x43\x3A\x60\xD0\xD5\x53\xFD\x79\x0F\x63\xE0\xA4\x4E\x4C\x6A\x96\x51\x16\xFE\xEA\xBA\xAE\x85\x5C\x72\x7D\xD8\x97\x97\xCA\x7F\x45\x89\x97\xDE\x6C\x28\x33\xD6\x35\x86\x3D\x2D\xAE\x3D\x40\x39\xD0\x97\xB5\xA6\xCA\x93\xF7\xC8\xBE\x2C\x49\xBF\xBD\x9F\x29\x27\x22\x4B\xE4\x89\x2C\xA0\x5C\x3D\xB9\xDA\x46\xE9\x7A\xAA\x41\xED\x3A\x6C\x25\xD3\xC5\x23\x8E\xF7\x29\xFD\xC2\xF9\xD7\xAB\x0B\xD1\x39\x72\x91\x73\x2D\x5D\x37\x95\x96\xF7\x89\xCF\x64\x92\xA4\xBF\x6F\xA7\xBB\x54\x9B\x59\x52\x19\x9D\x40\xE3\x88\x10\x42\x48\x69\xBE\x30\x9C\xA2\xDB\xC1\x78\x21\x48\x1D\x62\x8D\x23\x02\x2E\xAB\x11\x42\x08\x29\xCB\x25\xC4\x36\x22\x57\x06\x8D\x23\x42\x08\x21\x25\xB9\x94\xD8\x46\xE4\x8A\xA0\x71\x44\x08\x21\xA4\x24\x97\x12\xDB\x88\x5C\x11\x34\x8E\x08\x21\x84\x94\x42\x07\x9C\xA4\x71\x44\xCE\x02\x1A\x47\x84\x10\x42\x4A\xA1\x63\x1B\xB5\x38\x29\x47\x48\x34\xBC\x3E\x84\x10\x42\x48\x29\xB6\x18\xBC\x45\x34\x8C\xC8\xD9\x40\xE3\x88\x10\x42\x48\x29\x16\x11\xB3\x86\x90\x58\xB8\xAC\x46\x08\x21\x84\x10\x62\x41\xE3\x88\x10\x42\x08\x21\xC4\x82\x11\xB2\x09\x21\x84\x10\x42\x2C\xB8\xE7\x88\x64\xE5\xDF\x7F\xFF\x6D\x9D\x04\x42\xC8\xE5\xB1\xC6\xF1\xC9\x37\xDF\xA5\xD2\x84\xCC\x82\xC6\x11\x21\x84\x90\xA5\xF3\x88\x21\x98\xE4\x37\x1A\xDD\xD4\x4E\xAE\x07\xEE\x39\x22\x84\x10\xB2\x64\x56\x60\x94\x6D\x52\x19\x1A\x47\x84\x10\x42\x96\xCC\xBD\xFA\x37\xEF\x66\x23\xC5\xA1\x71\x44\x08\x21\x64\xC9\xD8\x5E\xA3\x1D\x18\x4C\x92\x54\x80\xC6\x11\x21\xE4\x92\x78\x07\xD0\x59\x0F\xC9\x4F\xCD\x32\x5E\xF7\x8F\x60\x07\x95\xDC\xA8\x74\xD8\xCF\x7B\xE1\x74\xD5\xE6\x9A\xF2\xBA\x08\x68\x1C\x11\x42\x08\x59\x2A\xB6\xD7\xE8\x00\xEE\x37\x22\x95\xA0\x71\x44\x08\x21\x64\xA9\xD8\xFB\x8D\xB8\xD7\x88\x54\x83\xC6\x11\x21\xF3\xA1\x8B\x9B\x90\xFC\xDC\xC1\x9C\x54\x13\xE8\x35\x22\xD5\xA0\x71\x44\x08\x21\x64\x89\xD8\x4B\x6A\xDF\x00\xF6\xAD\x12\x42\xAE\x0F\x1A\x47\x84\x10\x42\x96\x06\x63\x1B\x91\xA6\xD0\x38\x22\x84\x10\xB2\x34\x74\x6C\x23\x1A\x47\xA4\x2A\x34\x8E\x08\x21\x84\x2C\x0D\x1D\xDB\x88\xF7\xA8\x91\xAA\xD0\x38\x22\x84\x10\xB2\x24\x74\x6C\x23\x9E\x52\x23\xD5\xA1\x71\x44\x08\x21\x64\x49\xE8\xD8\x46\x34\x8E\x48\x75\xFE\x6E\x9D\x00\x72\x55\xAC\x01\xDC\xF4\x8F\xCD\x1E\xE6\x34\x0A\xAF\x05\x38\x45\x66\xD1\x2B\xF5\xF7\x3D\x8E\xA3\x05\xE7\x94\xB7\xC2\xF1\xCC\x1D\x30\x83\xD4\x77\x41\x99\x63\xED\x42\xDA\x44\xEE\x53\x4A\x37\x96\x4C\xE1\xD0\xCB\x29\x71\x22\xAA\x76\x1D\xB6\x92\x99\x0B\x7B\xBF\x51\xCE\xBD\x46\x1B\x1C\xB7\x6B\x69\xCF\xB9\x97\xEC\x5C\x7A\x6E\xE9\x65\xBF\x82\x29\x27\x3B\xED\x25\xD2\xBD\x84\x32\xBA\xC1\xE9\x89\xC8\xFF\xDA\x03\x8D\x23\x52\x9A\x1B\x18\x65\x77\x87\xD3\x8E\xA0\xD9\xC3\x28\xC3\x14\x85\xF8\x0E\xD3\xA9\x85\xBF\x12\xDE\x01\x1C\x5F\x87\xF0\x01\xE0\x36\xE0\x7B\x36\x9B\x89\xCF\x6E\x11\xDE\xE9\x6F\x00\x3C\xE2\x34\xCE\xCB\x18\x5B\x98\x99\xF5\x1C\x85\x12\x53\x47\xE8\x65\x7D\xF4\xB2\x53\x07\x96\x98\x3C\x8A\xF7\xE0\x05\xE9\x06\xF4\x0A\x26\x8F\xF7\x70\xE7\xF1\x1B\xC0\x13\xE6\x7B\x2B\x6A\xD7\x61\x2B\x99\xB9\xD1\x69\xCF\xE1\x35\x7A\xEC\x9F\xA9\x32\xD9\xC1\xD4\xF9\x9C\xC9\x99\xF4\xA1\x7B\x87\x1C\xC0\xB4\xE5\x17\xCC\xEB\x3B\xB1\x6C\x30\x1D\x7F\xCD\xD6\x71\xAE\x72\xFA\x86\x49\xF3\xCB\x8C\x74\x94\x2E\x23\x57\x3E\x81\x41\x07\xAF\x00\xBC\xE2\xD8\x30\xB2\xD9\x02\x78\xE2\xB2\x1A\x29\xC5\x0A\xC0\x33\x80\x2F\x98\x0E\x17\x32\xE8\xAE\x61\x1A\xED\x27\x4E\x3D\x17\xD7\xC2\x23\x4C\x99\xF9\x14\x88\x70\x0F\xA3\x10\x9E\x67\xCA\x0B\xAD\x23\xC0\x28\x21\xA9\xDB\x67\x84\xA5\xD3\x46\x7E\x1B\x9A\x47\x31\x6C\x44\x5E\x2C\x6B\x98\x36\xF5\x0C\x7F\x1E\x6F\x00\xBC\xC1\xB4\xC3\x54\x6A\xD7\x61\x2B\x99\x25\xB0\x07\xAC\x1C\x9E\xBC\x57\xF8\xDB\xE8\x1D\x4C\xFB\xD0\x27\xE4\x42\xB1\xFB\x90\xAF\xEC\x6D\xBD\x38\x35\x38\xB7\xC0\x57\x4E\x37\xFD\xE7\x9F\x8E\xEF\xB8\x58\x4A\x19\xAD\x03\xDE\x7B\x0F\xE0\x9D\xC6\x11\x29\xC1\x0A\x46\xF1\x3E\x26\xFE\x7E\xDD\xFF\xFE\xDA\x0C\x24\x51\x50\x29\x3C\xC2\x28\xAE\x1C\xF2\x0E\x18\xBC\x43\xF2\x8C\xB1\xC2\xA0\xF4\x42\xF9\x44\x7A\xBB\x00\x86\x7C\x86\x2A\x68\x69\x4B\xA1\x86\x9F\x70\x8F\x34\x03\xA9\x76\x1D\xB6\x92\x59\x02\xBD\xCC\x31\xD7\x6B\xF4\x88\x70\x83\x47\xBC\x09\x1B\xDF\x17\x15\xA9\x65\xBF\x82\x31\xC2\x53\x0D\xB2\x9C\x3C\x23\x3C\x1D\x6B\x98\x74\xC7\xB0\x94\x32\x92\xF7\x85\xE8\x8E\x1D\x8D\x23\x52\x82\x7B\x9C\x1A\x36\x7B\x18\xD7\xF5\x6F\x98\x25\x2F\xFB\xF9\x8D\xD3\xA5\xB4\x98\x86\xDC\x82\x5B\xEB\xB1\xD9\xAB\xCF\xE4\xF1\xCD\x80\xC7\x14\xF9\x01\xA6\xCC\x6E\x71\x5A\x5E\x63\xCB\x00\x6B\x84\x2B\xA1\x31\x79\xDB\xFE\xDD\xBF\x46\xD2\x6F\xCB\xD5\x79\x79\x0A\x94\xF9\x8C\xF1\xBD\x4C\x2F\xBD\x8C\x5F\x18\xF2\x28\x69\x18\x73\xAD\x8B\x87\x31\x84\x77\x0C\x6D\x68\x0B\xE0\xCF\x88\x9C\x3F\x18\x1F\x88\x65\xA9\x31\x94\xDA\x75\xD8\x4A\x66\x29\x74\x59\xCF\xD9\x6F\x24\x9E\x8E\x58\x62\x0C\xE2\x18\xA3\xC2\x25\xAF\xE5\x24\x70\x8D\xF8\xC9\xCA\x26\xE2\x37\x4B\x2A\xA3\x10\xCF\x31\x60\x26\x83\x2F\x7F\x75\xDD\xD4\xD6\x09\x42\xE2\xF9\xF7\xDF\x7F\xE5\x7F\xEF\x60\x1A\xF5\x01\xC0\x03\xC2\xF6\x36\x6C\x70\x6A\x10\x3D\x21\x6C\x9D\xBB\xF6\x9E\xA3\xB9\xBF\xB1\xB9\xC1\xA9\xF7\x65\x07\x53\x6E\xAE\x35\x77\x71\x3F\x6B\xE5\x13\xB2\xBF\xE9\x07\x43\x39\x1F\x60\x0C\x84\x98\xFD\x27\xA2\x20\xC5\xE8\x0D\xF9\xBE\xDE\x0F\x10\x92\x47\xE0\x74\x8F\xC0\x01\xD3\x06\xA7\x6E\x07\xBE\xEF\xEB\x34\xEA\xF6\xF7\x0D\xE0\x1F\xCF\xEF\x80\x36\x75\xD8\x42\x26\x90\xAF\xAF\x69\xBE\x30\x0C\x5E\x3B\x98\x36\xE9\xC2\xB7\xC7\x24\x95\x07\xF8\x0D\xB3\x9C\xB2\xF7\x30\x86\x6B\xAA\x3C\x9F\xCE\x29\x51\x4E\x07\x98\x7E\xE1\x6A\x67\x4B\x2A\xA3\x50\xFE\xCB\x17\x3D\x47\xA4\x14\x3B\x98\x46\xF6\x1B\xE1\x83\xEE\x07\x8C\x62\xB2\x59\x82\xDB\xB9\x34\x7A\x16\xB6\x87\x19\x18\x7C\x46\x83\x18\x9E\x5A\x91\xFB\x66\x75\x7A\xD3\xEB\x0B\xE2\x37\xE6\x8A\x42\x0E\xF5\x1A\x69\xAF\xC0\x07\xC2\xF2\x08\x0C\xC6\x9B\x78\x91\x42\x0C\x1D\x9B\xD0\xEF\x4B\x9A\x6C\xE4\x64\x9B\x8F\xDA\x75\xD8\x4A\x66\x29\xF4\xE9\xC1\x96\xC7\xF7\x43\x74\x4E\x4E\x4F\xDB\x3A\x50\xE6\x92\xD0\xD7\xBB\x8C\x71\x8E\x65\xF4\xDF\xC4\x82\xC6\x11\x29\xC9\x01\xF1\x27\x32\x76\x38\x1E\xC8\x42\x07\xA7\x73\x46\x2B\x19\xDF\x8C\x59\xF3\x84\xE3\x72\xD6\x47\x71\x35\xFA\xB3\x1A\x57\x33\x68\xC5\xA6\x8D\xE0\x10\x1E\x60\x0C\xEE\x18\xC3\xE8\x25\xF2\xFB\x72\x0A\xCF\x26\x64\x1F\x4A\xED\x3A\x6C\x25\xB3\x14\x76\xFB\xC8\x19\xDB\x48\x96\x6D\x9F\x30\x78\xA1\x7D\x3A\x69\x2C\x04\x82\xFE\xDC\xA5\x93\xBE\x31\xB4\x55\x59\xD2\xFC\x03\x77\x3B\x6C\x6D\x1C\xC9\xC4\x40\x96\xD1\x43\x3C\xBA\xAE\x7E\xB1\xE4\x32\xD2\x6D\x62\x6B\xFD\xED\xBF\x76\x47\xE3\x88\x2C\x11\xAD\x18\x63\x37\x49\x9E\x13\x1B\x9C\x1E\x5D\x8E\x3D\x52\x7C\x40\xDA\x80\x6E\xFF\xBE\x24\x3A\x2D\x29\x79\x14\x62\xD3\x9A\x72\x54\x3D\xB6\x2C\x5B\xD4\xE1\x12\xDA\x4D\x4E\x4A\x5C\x32\xBB\x87\x19\x7C\xC5\x28\x92\x01\x31\xC4\xC0\x76\x0D\xEC\x2E\x8F\x89\x2C\xFF\x6C\x71\x5C\x1F\x3B\xB8\x3D\x98\xDA\x73\x56\x13\x49\x9B\x84\x76\x90\x09\xC2\x2D\xDC\xFD\xED\x1C\xCB\x68\xAC\x4D\x3C\xF4\x72\x8F\xB6\x6F\xD0\x38\x22\x4B\xA4\x44\x20\xBE\xA5\x32\xB6\x71\x3D\x05\x6D\x04\xC4\x6C\x64\x2F\xBD\xE9\x3D\x57\x1E\x53\x48\x31\x8E\x74\xFA\x7C\x0A\xB9\x45\x1D\x2E\xA1\xDD\xE4\x42\x87\x1F\xC8\xE5\x35\xD2\x9E\x31\x41\x96\x69\x5D\xB8\x06\x7E\xD7\x67\xAE\x65\x4D\xD9\x28\x3F\x45\x2B\xC3\x74\x2A\x4D\x7B\xB8\xF7\x7B\xBA\xFA\xC5\x12\xCB\x48\x96\xE4\xC7\x64\xEF\xF5\xDF\x69\x1C\x11\xB2\x2C\x52\x07\x39\xFD\x3B\x97\x12\xD1\xCA\xA1\xB6\x4B\xFF\x1C\x8C\x5F\xBD\xB4\x9B\xFA\xDB\x39\xBF\x8B\x19\x08\x5A\xC8\xCC\x85\x2D\x33\x57\x94\x72\x09\x47\x31\xC5\x9C\x68\xEF\x53\x65\x14\xE2\xBD\xFB\x80\xDB\x33\x52\x1B\xDF\xCD\x04\x3E\x43\x75\xAA\x2C\x96\x58\x46\x51\x17\x18\xD3\x38\x22\xE4\x32\x88\x59\x6E\xD2\x83\xC2\x33\xCC\x29\xAD\x4B\xDF\xDB\x15\x43\x8B\x5B\xE0\xAF\x45\xA6\x4D\xEE\xD8\x46\x42\x0B\x03\x3C\x54\xE6\x94\x51\xD6\x62\x59\xCD\x67\xA8\xE4\xBE\xD2\xA9\x65\x19\x45\xE5\x85\xD7\x87\x90\xD2\xDC\x61\xB8\xD3\x88\x83\xEF\x32\xF8\x86\x71\x97\xDB\xA7\x93\xEE\x30\x0C\x52\xA2\x98\xB4\xAB\x59\xFE\x7D\x0E\x9E\x1F\x72\x1E\xE4\x8C\x6D\xD4\x9A\x50\xAF\xDB\x94\x1E\xBC\xE4\xBD\x95\x42\xCB\x32\x8A\xD2\x5B\x34\x8E\x48\x29\x24\x50\x1F\x0D\xA2\x65\xF2\x84\xE1\x5A\x0E\xCD\x46\xFD\x77\x0C\xD9\xBC\x79\xCE\x83\x19\x69\x8F\xDD\xFE\xA2\x96\x3D\x1A\xE1\xD2\x67\x1B\x5C\x87\x81\xE3\xE3\x22\xCA\x88\xCB\x6A\xA4\x04\xD7\x7A\xFD\xC7\xB9\xF1\x80\xE9\xE8\xD0\x3E\x24\xC8\xA7\x1D\x81\x9A\x90\x18\x96\x14\xDB\x28\x14\xB6\x75\x3F\x17\x51\x46\xF4\x1C\x91\xDC\xC8\xBD\x6A\xBA\x83\xEC\x61\x3C\x0D\x21\x33\x43\xB9\xBD\x99\x94\x67\x87\x61\x50\x92\x38\x37\xAB\xFE\x11\xE3\xD6\xFE\x7F\x8D\x44\xA5\xF5\x45\xAF\x25\x44\x53\x2A\xB6\x11\x21\xB3\xA1\x71\x44\x72\xA3\x8F\xE5\xA6\x5E\x4D\x41\xE3\xA8\x3E\x21\xD7\x55\x48\xA4\x5A\xDB\x35\x2E\xF7\x33\x85\x5C\xF3\x42\x88\x50\x22\xB6\x51\x69\xB8\xDF\xCE\xCF\x45\x94\x11\x8D\x23\x92\x9B\xB1\xA8\xBD\xA9\x47\x66\xC9\xB2\x90\x63\xBF\x3B\x9C\xDE\x5A\x7F\x07\x1A\x47\x24\x9C\x52\xB1\x8D\x4A\xE3\xF2\x7C\x6F\x71\x3E\xF9\x28\xC9\x45\x94\x11\x8D\x23\x92\x1B\x7B\xF9\x45\x96\xD2\x48\x79\x6A\x1F\x03\xDE\xE2\xF8\xBE\x23\xEE\x2F\x9B\x4F\x8B\xA3\xDC\xAD\xA2\x32\x97\x88\x6D\xD4\x9A\x15\xCE\x4F\xDF\xF9\xEA\xDF\xF7\x79\xEC\x06\xFA\xB3\x29\x23\x6E\xC8\x26\x25\x69\xD9\x09\x5A\x29\xFD\x58\xB4\x72\x49\x35\x32\xF4\xEF\x6A\x94\xBD\x1E\xD0\x42\x37\x62\x5E\x9A\x21\xD5\xA2\x0E\xCF\xB9\xDD\x94\x8A\x6D\x54\x8B\x29\x43\xEE\x0E\x6D\xF4\xCE\x9C\x0D\xD0\x37\x70\xA7\xD9\x77\xB9\xEC\x54\x59\x2C\xAD\x8C\xA2\xA1\x71\x44\x2E\x85\x1C\x91\x7E\x5B\x1C\x31\xD5\xE9\xF6\x29\xA3\x29\x74\xDA\x73\x07\x6F\x1B\x43\x0F\xD0\x53\x4A\x7A\x09\x51\x98\x4B\xD2\xA2\x0E\xCF\xB9\xDD\x9C\x7B\x6C\x23\x97\x01\xF9\x06\xBF\xB1\xB2\x42\xDE\x30\x27\x73\x6F\xAC\x7F\x76\xBC\xF7\x71\xE2\x33\xC0\xDD\x56\x96\x56\x46\xD1\xD0\x38\x22\x25\xA9\x39\x08\xEA\x8E\x9A\x32\x58\xA4\x0E\x30\x73\xD8\xE3\x38\xED\x6B\xC4\x97\xDB\xD8\xE9\xBE\x1A\x1E\x00\xAD\xB8\xA6\x94\xA5\x3E\xA5\x38\x27\xD6\xC9\x12\x8F\x09\xB7\xA8\xC3\x73\x6E\x37\xE7\x16\xDB\x48\xE3\x2A\xA3\x35\x80\x4F\x9C\xEE\xA9\x92\xCF\x1E\x01\x7C\xF5\x9F\xE7\x0C\x77\xF2\x0A\xA0\xEB\x9F\xD8\x76\x70\x67\xA5\x49\xFA\xE6\x33\xFC\x61\x3A\x5C\xE5\xB0\xC4\x32\x8A\x82\xC6\x11\xC9\x8D\x3D\xA3\x5D\x23\xCD\xE0\x48\x19\x00\xB5\x6B\x7E\x03\xF7\xAC\x47\x93\xEB\x84\x5C\x4A\xDA\xF5\xCC\xF9\x39\xF2\x3D\xAF\xEA\xDF\x5B\xB8\x07\x9C\x15\x8C\x72\x9A\x63\xBC\xEA\x00\x92\xBE\x3D\x23\xBA\x7E\x62\xF3\x08\x1C\x2B\xF1\xA5\x51\xBB\x0E\x5B\xC9\x1C\x23\x66\xF0\x3A\xC7\xD8\x46\x1A\xD7\xDD\x5F\x80\xC9\xDF\x2B\x80\x1F\x98\xF6\xFA\x0E\x63\xB4\x7C\xE2\xB8\x8E\x24\xEC\xC9\x12\xDA\xB3\xA4\xF9\xBD\x7F\x1E\xE1\x6F\x4B\xAE\x32\x38\xFB\x32\xA2\x71\x44\x72\xA3\x95\xDD\x2B\xE2\x0C\xA4\x1B\xC4\x19\x35\xC2\x01\xE3\x83\x45\xC8\xBB\x36\x30\xAE\xDE\x54\xF4\x0C\x3E\xD6\x20\xD4\x83\x92\x04\xD1\xF4\xAD\xCD\xAF\x60\xD2\xAD\x8D\x1C\xDF\xA9\x31\x99\x8D\x89\x22\x8C\x35\x92\xE4\xB7\xB6\xF2\xF4\x2D\x8D\xE8\x34\xC5\x04\x0A\x5D\x61\xB8\xFF\x4D\xDC\xED\x4B\x18\x50\x6C\x6A\xD7\x61\x2B\x99\xC0\xF8\xDD\x7C\xA1\x46\xD9\xA5\xC4\x36\x72\xDD\x1C\x6F\x73\x03\x77\xFF\x0A\x6D\xCF\x4B\xDB\xC4\x3C\xA6\x6F\x35\xB5\xCB\x28\x2B\x3C\xAD\x46\x72\xB3\xC5\xF1\xAC\x43\x14\xF1\x1E\x46\x11\x8E\xCD\x26\x56\x18\x3A\xC8\x1C\x6F\xC6\x0B\x8C\x61\x62\x2B\xEA\x67\x98\x4E\xB5\xC5\xB0\x14\x71\xC0\x30\x83\x95\xBB\xDF\xD0\xFF\x3D\xC5\xF3\xF3\x81\xE3\x8E\xFB\xD6\xA7\xC5\xBE\xF1\x5A\xDF\x53\x66\x73\x80\x89\x56\x6D\x1B\x68\x6B\x98\x19\xD5\x16\xC3\xB2\xD4\x87\x95\x6E\xD9\x67\xA0\xD3\xFB\x04\xF7\x5E\x80\x47\x1C\x1B\x24\x52\xE6\x52\x3F\x53\x33\xBE\x95\xF5\x5D\xAD\xA4\xF6\xF0\x2B\xCA\xEF\x3E\x6D\xF6\xFE\x06\x71\xAF\x8B\x5C\x29\x2F\xA9\x1F\x91\xA9\xEB\x54\x7E\xBB\x24\x6A\xD6\x61\x4B\x99\x80\xA9\x2F\xBB\x1E\x37\x18\xEA\x51\xDA\xF8\xD4\xE0\x79\x8E\xB1\x8D\xC6\xF8\xC0\xE9\xFD\x84\x73\x78\x86\x7F\x89\x71\x8B\xFC\x06\x42\xAA\xCE\x0B\x31\x7C\x5A\x94\x51\x36\x68\x1C\x91\xDC\x1C\x00\xDC\xE2\xD4\xB3\x50\xE3\xE2\x59\x19\x80\xF5\x72\xC1\x0D\xA6\x37\x1D\x0A\x92\xEE\xCF\x04\xB9\x2F\x38\x55\x5A\x5A\x21\xDC\xC2\x3D\xFB\xDB\xC1\x0C\x74\x3A\xED\xF7\x23\xEF\x9E\x62\x0B\xFF\xEC\x5F\x8E\xE0\x6B\xEF\x96\xAE\x1F\xDB\xB0\x73\x19\xAC\x7B\x98\xBC\x85\xF0\x82\xF1\x7D\x2E\xF6\xA5\xB7\x21\x6C\x61\xCA\x6A\x69\xD4\xAA\xC3\xD6\x32\xC7\x2E\x2E\xD6\x1E\xDF\xB1\x7B\xF7\xCE\x35\xB6\xD1\x14\x62\x20\xCC\x1D\xFC\xF7\x30\xF1\xE0\x7C\x83\xFE\xD8\xE4\x6F\x2E\x32\x61\x8C\x31\xBA\xB6\x08\x37\x6C\x6B\x97\x51\x36\xB8\xAC\x46\x4A\x20\x03\x66\xCA\xC9\x97\x10\x77\xAD\x0B\x19\x38\x63\x3A\x91\xA4\x37\x35\xD6\xCA\x37\xF2\x0C\xD6\x5B\xA4\x29\x80\x03\x8C\x12\x0A\x49\x83\x44\x2C\xF7\x19\x6B\x21\x9E\xBC\x97\xFE\x3D\x31\xE9\x7D\x80\x49\x6B\x8A\x92\x8B\xC9\x67\x2B\x6A\xD4\xE1\x12\x64\xBE\x20\x7E\xA9\xE7\x12\x63\x1B\x3D\xC1\x94\x7D\xAA\xAE\x7B\x82\xB9\x7A\x27\xE4\xF7\xDF\x88\xEF\x6F\x21\x3C\x21\xBC\x2E\x52\x26\x26\x35\xCB\x28\x1B\x34\x8E\x48\x29\xF6\x30\x0D\x3A\xB4\xE3\xED\xFB\xEF\xFE\x83\xF9\x33\xCA\x6D\x2F\xDB\xB7\xC1\x74\x0F\xD3\xD1\x7F\x07\xA6\xD1\x27\xF3\x16\xF3\xD3\xBE\x83\x29\x83\x90\x72\x13\x4F\xD9\x6F\xC4\x47\xA7\xFE\x80\x49\x6F\xA8\x2C\x61\xDF\xCB\x92\xDF\xA5\x28\x6A\xFB\xF7\xB1\x6D\xE3\x1C\xA2\x70\xD7\xAA\xC3\x96\x32\xC5\xD3\xFA\x80\x30\x23\xE9\xDC\x63\x1B\xB9\x90\xB2\x7F\x40\x58\xBE\xC4\xDB\xF7\x0B\xF1\xE5\xBF\xC7\x50\xCF\xB9\xF6\x21\x1D\x30\xE8\xEA\xA9\xFE\x2C\x9E\x9B\xD4\x89\x49\xCD\x32\xCA\xC2\x5F\x5D\xD7\xB5\x90\x4B\x2E\x94\x7F\xFF\xFD\x77\xEA\x23\xFB\xF2\x52\xF9\xAF\x28\xF1\xD2\x9B\x0D\x65\xC6\xBA\xC6\xB0\xA7\xC5\xB5\x07\x28\x07\xFA\xB2\xD6\x54\x79\xF2\x1E\xD9\x97\x25\xE9\xB7\x97\xBD\x72\x22\xB2\x44\x9E\xC8\x02\xCA\xD5\x93\xAB\x6D\x94\xAE\xA7\x1A\xD4\xAE\xC3\x56\x32\x5D\x3C\xE2\x78\x69\xFB\x17\xCE\xBF\x5E\x5D\x88\xCE\x91\x8B\x9C\x6B\xE9\xBA\xA9\xB4\xBC\x4F\x7C\x26\x93\x24\xFD\x7D\x3B\xDD\xA5\xDA\xCC\x92\xCA\xE8\x04\x1A\x47\x24\x2B\x0E\xE3\x88\x10\x72\xBD\x7C\x61\x38\x45\xB7\x83\xF1\x42\x90\x3A\xC4\x1A\x47\x04\x5C\x56\x23\x84\x10\x52\x96\x4B\x88\x6D\x44\xAE\x0C\x1A\x47\x84\x10\x42\x4A\x72\x29\xB1\x8D\xC8\x15\x41\xE3\x88\x10\x42\x48\x49\x2E\x25\xB6\x11\xB9\x22\x68\x1C\x11\x42\x08\x29\x85\x8E\x6D\x44\xE3\x88\x9C\x05\x34\x8E\x08\x21\x84\x94\x42\xC7\x36\x6A\x71\x52\x8E\x90\x68\x18\x21\x9B\x10\x42\x48\x29\xEC\x68\xCA\x34\x8C\xC8\xD9\x40\xE3\x88\x10\x42\x48\x29\x16\x11\xB3\x86\x90\x58\xB8\xAC\x46\x08\x21\x84\x10\x62\x41\xE3\x88\x10\x42\x08\x21\xC4\xE2\xFF\x01\xF0\xCC\x65\x5A\x55\x61\xAF\xF5\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82'
	-- >> BASE85 DATA <<

	imgui.GetIO().IniFilename = nil

	ash_image = imgui.CreateTextureFromFileInMemory(new('const char*', ash_image_data), #ash_image_data)
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
	if not monetluacheck and AshSettings.MainSettings.style == 2 then
		AshSettings.MainSettings.style = 0
	end
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
	if AshSettings.MainSettings.style == 0 or AshSettings.MainSettings.style == nil then
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
	elseif AshSettings.MainSettings.style == 1 then
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
	elseif AshSettings.MainSettings.style == 2 then
		local generated_color				= monetlua.buildColors(AshSettings.MainSettings.monetstyle, AshSettings.MainSettings.monetstyle_chroma, true)
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
		AshSettings.MainSettings.style = 0
		checkstyle()
	end

	if AshSettings.MainSettings.ASChatColor.themeBased then
		local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
		local r, g, b, a = col.x, col.y, col.z, col.w
		
		local colors = {
			[0] = 4281558783,
			[1] = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, 1.0)),
			[2] = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, 1.0))
		}
		AshSettings.MainSettings.ASChatColor.color = colors[AshSettings.MainSettings.style]
		chatcolors.ASChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color))
		AshSettings.Checker.col_title = AshSettings.MainSettings.style == 0 and 0xFFFF6633 or (join_argb(a * 255, r * 255, g * 255, b * 255))
		local a, r, g, b = explode_argb(AshSettings.Checker.col_title)
		checker_variables.col.title = new.float[4](r/255, g/255, b/255, a/255)
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
	if a then a = tostring(a) else return end
    local b, e = ('%d'):format(a):gsub('^%-', '')
    local c = b:reverse():gsub('%d%d%d', '%1.')
    local d = c:reverse():gsub('^%.', '')
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
			['y'] = table.posY,
			['align'] = table.align
		}
		ChangePos = true
		local font = renderCreateFont('trebucbd', 11, 9)
		local text = 'ЛКМ - сохранить местоположение\nПКМ - отменить настройку\nстрелочки - выравнивание'
		local color = 0xFFFFFFFF
		sampSetCursorMode(4)
		while ChangePos do
			wait(0)
			local cX, cY = getCursorPos()
			table.posX = cX
			table.posY = cY

			renderFontDrawText(font, text, cX, cY - 60, color)

			if isKeyDown(0x01) then
				while isKeyDown(0x01) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				ASHelperMessage('Позиция сохранена!')
			elseif isKeyDown(0x02) then
				while isKeyDown(0x02) do wait(0) end
				ChangePos = false
				sampSetCursorMode(0)
				table.posX = backup['x']
				table.posY = backup['y']
				table.align = backup['align']
				ASHelperMessage('Вы отменили изменение\nместоположения')
			end

			if isKeyJustPressed(0x25) then
				table.align = 0
			end
			if isKeyJustPressed(0x26) then
				table.align = 1
			end
			if isKeyJustPressed(0x27) then
				table.align = 2
			end
		end
		ChangePos = false
		inicfg.save(AS_Settings,'AS Helper')
	end)
end

function imgui.Link(link, text)
	text = text or link
	local tSize = imgui.CalcTextSize(text)
	local p = imgui.GetCursorScreenPos()
	local DL = imgui.GetWindowDrawList()
	local col = { 0xFFFF7700, 0xFFFF9900 }
	if imgui.GetStyle().Alpha ~= 1 then
		col[1] = changeColorAlpha(col[1], imgui.GetStyle().Alpha * 255)
		col[2] = changeColorAlpha(col[2], imgui.GetStyle().Alpha * 255)
	end
	local button = imgui.InvisibleButton('##' .. text, tSize)
	if button and link then os.execute('explorer ' .. link) end
	local color = imgui.IsItemHovered() and col[1] or col[2]
	DL:AddText(p, color, text)
	DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
	return button
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

function imgui.LicenseButton(lic_num, rounding)
	local size = imgui.ImVec2(125, 30)
	local dl = imgui.GetWindowDrawList()
	local locpos = imgui.GetCursorPos()
	local pos = imgui.GetCursorScreenPos()
	local lic = licenses[lic_num]
	local lic_num_ = lic_num > 5 and lic_num - 5 or lic_num

	local function imCol(col)
		return imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[col])
	end
	
	local rounding = lic_num_ == 1 and (imgui.DrawCornerFlags.TopLeft + imgui.DrawCornerFlags.TopRight) or lic_num_ == 5 and (imgui.DrawCornerFlags.BotLeft + imgui.DrawCornerFlags.BotRight) or 0
	
	if lic.bool then
		imgui.SetCursorPosX(locpos.x + 12)
		pos = imgui.GetCursorScreenPos()
		
		dl:AddText(imgui.ImVec2(lic_num > 5 and pos.x + 115 or pos.x - 30, pos.y + 8), imCol(imgui.Col.Text), lic.icon)

		for i = 1, #AshSettings.ScannedVariables.PriceList[lic_num].price do
			if imgui.InvisibleButton(i..'m.##'..i..'month'..lic.text, imgui.ImVec2(101/#AshSettings.ScannedVariables.PriceList[lic_num].price, 30)) then lic.month = i end
			local col = imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or lic.month == i and imgui.Col.ButtonHovered or imgui.Col.Button

			local width = 101
			dl:AddRectFilled(imgui.ImVec2(pos.x + (i - 1) * (width / #AshSettings.ScannedVariables.PriceList[lic_num].price), pos.y), imgui.ImVec2(pos.x + i * (width / #AshSettings.ScannedVariables.PriceList[lic_num].price), pos.y + 30), imCol(col), 0)
			imgui.PushFont(font[11])
			dl:AddText(imgui.ImVec2(pos.x + (i - 1) * (width / #AshSettings.ScannedVariables.PriceList[lic_num].price) + (width / #AshSettings.ScannedVariables.PriceList[lic_num].price) / 2 - imgui.CalcTextSize(i..u8' мес.').x / 2 + 2, pos.y + 10), imCol(imgui.Col.Text), i..u8' мес.')
			imgui.PopFont()
			if i ~= #AshSettings.ScannedVariables.PriceList[lic_num].price then imgui.SameLine() end
		end

		imgui.SetCursorPos(imgui.ImVec2(locpos.x, locpos.y))
		pos = imgui.GetCursorScreenPos()
		if imgui.InvisibleButton('##cancel'..lic.text, imgui.ImVec2(12, 30)) then lic.bool = not lic.bool lic.month = 1 end
		local cancelcol = imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button
		imgui.SameLine(114)
		if imgui.InvisibleButton('##info'..lic.text, imgui.ImVec2(12, 30)) then
			sampSendChat('Лицензия на '..string.rlower(lic.chat)..' сроком '..lic.month..(lic.month > 1 and ' месяца стоит ' or ' месяц стоит ')..string.separate(AshSettings.ScannedVariables.PriceList[lic_num].price[lic.month])..'$')
		end
		local infocol = imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button

		dl:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 12, pos.y + 30), imCol(cancelcol), 5, lic_num_ == 1 and imgui.DrawCornerFlags.TopLeft or lic_num_ == 5 and imgui.DrawCornerFlags.BotLeft or 0)
		dl:AddRectFilled(imgui.ImVec2(pos.x + 113, pos.y), imgui.ImVec2(pos.x + size.x, pos.y + 30), imCol(infocol), 5, lic_num_ == 1 and imgui.DrawCornerFlags.TopRight or lic_num_ == 5 and imgui.DrawCornerFlags.BotRight or 0)

		imgui.PushFont(font[11])
		dl:AddText(imgui.ImVec2(pos.x + 2, pos.y + 10), imCol(imgui.Col.Text), fa.ICON_FA_TIMES)
		imgui.PopFont()
		imgui.PushFont(font[13])
		dl:AddText(imgui.ImVec2(pos.x  + 116, pos.y + 8), imCol(imgui.Col.Text), '$')
		imgui.PopFont()
	else
		if imgui.InvisibleButton(lic.text..'##lic', imgui.ImVec2(size.x, size.y)) and AshSettings.ScannedVariables.PriceList[lic_num].rank <= AshSettings.MainSettings.myrankint then
			lic.bool = not lic.bool lic.month = 1
		end

		if AshSettings.ScannedVariables.PriceList[lic_num].rank <= AshSettings.MainSettings.myrankint then
			local col = imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button
			
			dl:AddRectFilled(pos, imgui.ImVec2(pos.x + size.x, pos.y + size.y), imCol(col), 5, rounding)
			dl:AddText(imgui.ImVec2(pos.x + 7, pos.y + 8), imCol(imgui.Col.Text), u8(lic.text))
			dl:AddText(imgui.ImVec2(pos.x + 100, pos.y + 8), imCol(imgui.Col.Text), lic.icon)
		else
			local butcol = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
			local r, g, b, a = butcol.x, butcol.y, butcol.z, butcol.w

			local col = imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button
			dl:AddRectFilled(pos, imgui.ImVec2(pos.x + size.x, pos.y + size.y), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r, g, b, a/2)), 5, rounding)
			dl:AddText(imgui.ImVec2(pos.x + 7, pos.y + 8), imCol(imgui.Col.TextDisabled), u8(lic.text))
			dl:AddText(imgui.ImVec2(pos.x + 100, pos.y + 8), imCol(imgui.Col.TextDisabled), lic.icon)
			dl:AddText(imgui.ImVec2(pos.x + 50, pos.y + 8), imCol(imgui.Col.Text), fa.ICON_FA_LOCK)
			dl:AddText(imgui.ImVec2(pos.x + 65, pos.y + 8), imCol(imgui.Col.Text), AshSettings.ScannedVariables.PriceList[lic_num].rank..u8'+')
		end
	end
end

function imgui.TextColoredRGB(text,align)
	local width = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local col = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)
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

function imgui.Spinner(label, radius, thickness, color, speed)
	speed = speed or 1.0
	local segments = 36
	local style = imgui.GetStyle()
	local pos = imgui.GetCursorScreenPos()
	pos.y = pos.y + 2
	imgui.BeginGroup()
	local draw_list = imgui.GetWindowDrawList()
	local center = imgui.ImVec2(pos.x + radius, pos.y + radius)
	local current_time = imgui.GetTime() * speed
	local col_vec4 = type(color) == "number" and imgui.ColorConvertU32ToFloat4(color) or imgui.ImVec4(color.Value.x, color.Value.y, color.Value.z, color.Value.w)
	local text_color = imgui.GetStyle().Colors[imgui.Col.Text] 
	local spin_angle = current_time * 6.28318
	for i = 0, segments - 1 do
		local angle = spin_angle + (i / segments) * 6.28318
		local opacity = 0.3 + 0.7 * (1.0 - ((segments - i) % segments) / segments)
		local point = imgui.ImVec2(center.x + math.cos(angle) * radius, center.y + math.sin(angle) * radius)
		draw_list:AddCircleFilled(point, thickness, imgui.GetColorU32Vec4(imgui.ImVec4(col_vec4.x, col_vec4.y, col_vec4.z, col_vec4.w * opacity)), 8)
	end
	local dot_animation = math.floor(current_time * 2) % 4
	local loading_text = label .. string.rep(".", dot_animation)
	imgui.SameLine()
	local text_height = imgui.GetTextLineHeight()
	local text_pos = imgui.ImVec2(pos.x + radius * 2 + 5, pos.y + (radius * 2 - text_height) / 2)
	draw_list:AddText(text_pos, imgui.GetColorU32Vec4(text_color), loading_text)
	imgui.EndGroup()
	local text_width = imgui.CalcTextSize(label .. "...").x
	return imgui.ImVec2(radius * 2 + style.ItemSpacing.x + text_width, radius * 2)
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
	local color = ARGBtoStringRGB(AshSettings.Checker.col_note)
	local post_c = ARGBtoStringRGB(post_color)

	note = note:gsub('\n.*', '...')
	note = note:gsub('{%x+}', '')

	return string.format('%s // %s%s', color, note, post_c)
end

function getAfk(rank, afk, post_color)
	local color = ARGBtoStringRGB(AshSettings.Checker.col_afk_max)
	local post_c = ARGBtoStringRGB(post_color)
	if rank <= 4 then
		if AshSettings.Checker.afk_max_l > 0 and afk >= AshSettings.Checker.afk_max_l then
			return string.format(' - %sAFK: %s%s', color, afk, post_c)
		end
	else
		if AshSettings.Checker.afk_max_h > 0 and afk >= AshSettings.Checker.afk_max_h then
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
	local animTime = 0.13
	
	local color_active = imgui.GetStyle().Colors[imgui.Col.CheckMark]
	local color_inactive = imgui.ImVec4(100 / 255, 100 / 255, 100 / 255, 180 / 255)

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool[0] = not bool[0]
		rBool = true
		LastActiveTime[tostring(str_id)] = clock()
		LastActive[tostring(str_id)] = true
	end

	local hovered = imgui.IsItemHovered()

	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY()+3)
	imgui.Text(str_id)

	local t = bool[0] and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = clock() - LastActiveTime[tostring(str_id)]
		if time <= animTime then
			local t_anim = ImSaturate(time / animTime)
			t = bool[0] and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg = bringVec4To(not bool[0] and color_active or color_inactive, bool[0] and color_active or color_inactive, LastActiveTime[tostring(str_id)] or 0, animTime)

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), imgui.ColorConvertFloat4ToU32(col_bg), 10.0)
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

function inicfg.save(_, _)
	AshSettings()
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
				inicfg.save(AS_Settings,'AS Helper')
			end
		else
			path[pointer] = defaultKey
			tHotKeyData.edit = nil
			tHotKeyData.lasted = clock()
			inicfg.save(AS_Settings,'AS Helper')
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

function imgui.PopupButton(dl, name, text, color, popupname, popup, popupwidth)
	local p = imgui.GetCursorScreenPos()
	
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
	imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.5)
	imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 5, imgui.GetCursorPos().y - 5))
	if imgui.Button(name, imgui.ImVec2(imgui.CalcTextSize(text).x + 36 , 25)) then
		imgui.OpenPopup(popupname)
	end
	imgui.PopStyleColor()
	imgui.PopStyleVar()

	imgui.SetNextWindowSize(imgui.ImVec2(popupwidth or imgui.CalcTextSize(text).x + 36, -1), imgui.Cond.Always)
	imgui.SetNextWindowPos(imgui.ImVec2(p.x - 5, p.y + 20))
	popup()

	dl:AddText(p, color, text)
	dl:AddLine(imgui.ImVec2(p.x + imgui.CalcTextSize(text).x + 7, p.y), imgui.ImVec2(p.x + imgui.CalcTextSize(text).x + 7, p.y + 15), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1)
	dl:AddText(imgui.ImVec2(p.x + imgui.CalcTextSize(text).x +  14, p.y + 1), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), fa.ICON_FA_CHEVRON_DOWN)
end

local imgui_fm = imgui.OnFrame(
	function() return windows.imgui_fm[0] end,
	function(player)
		player.HideCursor = isKeyDown(0x02)
		if not IsPlayerConnected(fastmenuID) then
			windows.imgui_fm[0] = false
			sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
			ASHelperMessage('Игрок с которым Вы взаимодействовали вышел из игры!')
			return false
		end
		imgui.SetNextWindowSize(imgui.ImVec2(500, 280), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.7),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0,0))
		imgui.Begin(u8'Меню взаимодействия', windows.imgui_fm, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
			if imgui.IsWindowAppearing() then
				newwindowtype[0] = 1
				clienttype[0] = 0
			end
			local p = imgui.GetCursorScreenPos()
			imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y), imgui.ImVec2(p.x + 300, p.y + 330), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
			imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 300, p.y + 75), imgui.ImVec2(p.x + 500, p.y + 75), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 2)
		
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0,0,0,0))
			imgui.SetCursorPos(imgui.ImVec2(0, 5))
			imgui.BeginChild('##fmmainwindow', imgui.ImVec2(300, -1), false, imgui.WindowFlags.NoScrollbar)
				if newwindowtype[0] == 1 then
					if clienttype[0] == 0 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							if AshSettings.MainSettings.myrankint >= 1 then
								if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(270,30)) then
									getmyrank = true
									sampSendChat('/stats')
									if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Доброе утро, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы г. Сан-Фиерро'},
											{'/do На груди висит бейджик с надписью %s %s.', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], #AshSettings.MainSettings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname)},
										})
									elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Добрый день, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы г. Сан-Фиерро'},
											{'/do На груди висит бейджик с надписью %s %s.', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], #AshSettings.MainSettings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname)},
										})
									elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Добрый вечер, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы г. Сан-Фиерро'},
											{'/do На груди висит бейджик с надписью %s %s.', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], #AshSettings.MainSettings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname)},
										})
									elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Доброй ночи, я {gender:сотрудник|сотрудница} %s, чем могу Вам помочь?', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы г. Сан-Фиерро'},
											{'/do На груди висит бейджик с надписью %s %s.', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], #AshSettings.MainSettings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname)},
										})
									end
								end
							else
								imgui.LockedButton(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(270,30))
								imgui.Hint('firstranghello', 'С 1-го ранга')
							end
							if AshSettings.MainSettings.myrankint >= 1  then
								if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(270,30)) then
									local prices = AshSettings.ScannedVariables.PriceList

									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/todo Сейчас я ознакомлю вас с прайс-листом*открывая тумбочку'},
										{'/me перебирая стопку листов {gender:взял|взяла} один заламинированный лист, читает с него'},
										{'Водительские права: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[1].price[1]) or '... Стёрто', string.separate(prices[1].price[2]) or '... Стёрто', string.separate(prices[1].price[3]) or '... Стёрто'},
										{'Мото-транспорт: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[2].price[1]) or '... Стёрто', string.separate(prices[2].price[2]) or '... Стёрто', string.separate(prices[2].price[3]) or '... Стёрто'},
										{'Воздушный транспорт: на 1 месяц - %s$', string.separate(prices[3].price[1]) or '... Стёрто'},
										{'Рыбалка: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[4].price[1]) or '... Стёрто', string.separate(prices[4].price[2]) or '... Стёрто', string.separate(prices[4].price[3]) or '... Стёрто'},
										{'Водный транспорт: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[5].price[1]) or '... Стёрто', string.separate(prices[5].price[2]) or '... Стёрто', string.separate(prices[5].price[3]) or '... Стёрто'},
										{'Владение оружием: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[6].price[1]) or '... Стёрто', string.separate(prices[6].price[2]) or '... Стёрто', string.separate(prices[6].price[3]) or '... Стёрто'},
										{'Охота: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[7].price[1]) or '... Стёрто', string.separate(prices[7].price[2]) or '... Стёрто', string.separate(prices[7].price[3]) or '... Стёрто'},
										{'Раскопки: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[8].price[1]) or '... Стёрто', string.separate(prices[8].price[2]) or '... Стёрто', string.separate(prices[8].price[3]) or '... Стёрто'},
										{'Работа в такси: на 1 месяц %s -$ на, 2 месяца - %s$ ,на 3 месяца - %s$ ', string.separate(prices[9].price[1]) or '... Стёрто', string.separate(prices[9].price[2]) or '... Стёрто', string.separate(prices[9].price[3]) or '... Стёрто'},
										{'Работа механиком: на 1 месяц - %s$, на 2 месяца - %s$, на 3 месяца - %s$', string.separate(prices[10].price[1]) or '... Стёрто', string.separate(prices[10].price[2]) or '... Стёрто', string.separate(prices[10].price[3]) or '... Стёрто'},
										{'/todo Если у вас нет вопросов, то мы можем продолжить*убирая лист в тумбочку'},
									})
								end
							else
								imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(270,30))
								imgui.Hint('firstrangpricelist', 'С 1-го ранга')
							end
							if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(270,30)) then
								imgui.SetScrollY(0)
								clienttype[0] = 1
								for k, v in ipairs(licenses) do
									v.bool = false
								end
							end
							if AshSettings.MainSettings.myrankint >= 2 then
								if imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(270,30)) then
									imgui.OpenPopup('##changeexpelreason')
								end
								imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
								if imgui.BeginPopup('##changeexpelreason') then
									imgui.Text(u8'Причина /expel:')
									if imgui.InputText('##expelreasonbuff',usersettings.expelreason, sizeof(usersettings.expelreason)) then
										AshSettings.MainSettings.expelreason = u8:decode(str(usersettings.expelreason))
										inicfg.save(AS_Settings,'AS Helper')
									end
									if imgui.Button(u8'Выгнать', imgui.ImVec2(-1, 25)) then
										if not sampIsPlayerPaused(fastmenuID) then
											windows.imgui_fm[0] = false
											sendchatarray(AshSettings.MainSettings.playcd, {
												{'/me {gender:схватил|схватила} человека за руку, и {gender:повёл|повела} к выходу'},
												{'/me открыв дверь рукой, {gender:вывел|вывела} человека на улицу'},
												{'/expel %s %s', fastmenuID, AshSettings.MainSettings.expelreason},
											})
										else
											ASHelperMessage('Игрок находится в АФК!')
										end
									end
									imgui.EndPopup()
								end
								imgui.PopStyleVar()
							else
								imgui.LockedButton(fa.ICON_FA_FILE_ALT..u8' Выгнать из автошколы', imgui.ImVec2(270,30))
								imgui.Hint('secondrangexpel', 'С 2-го ранга')
							end
						imgui.EndGroup()
					elseif clienttype[0] == 1 then
						imgui.SetCursorPos(imgui.ImVec2(20, 20))
						local p = imgui.GetCursorScreenPos()
						local dl = imgui.GetWindowDrawList()

						local spacingx = 1
						local spacingy = 1
						local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
						local textcolor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text])
						local sizex = 7
						local sizey = 7

						local choosedlic = function()
							local i = 0
							for k, v in ipairs(licenses) do
								if v.bool then i = i + 1 end
							end
							return i
						end
						choosedlic = choosedlic()

						if #sellList > 0 and sellList.sellPerson == fastmenuID then
							imgui.PushFont(font[15])
							if sellList.sellLicense ~= 0 then
								if sellList.checking_medcard.status ~= 0 then
									if sellList.checking_medcard.status == 1 then
										local popup = function()
											if imgui.BeginPopup('##skipornomc') then
												imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 1))
												imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
												imgui.PushFont(font[12])
												if imgui.Button(u8'Нету мед карты', imgui.ImVec2(-1, 25)) then
													if not inprocess then
														if #sellList == 1 then
															sampSendChat('Сожалею, но без мед. карты я не продам. Оформите её в любой больнице.')
														end
														for i = #sellList, 1, -1 do
															if AshSettings.ScannedVariables.PriceList[sellList[i].licenseNumber].medcard then
																table.remove(sellList, i)
															end
														end
														sellList.checking_medcard.status = 5
														sellNextLicense()
													else
														ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
													end
												end
												if imgui.Button(u8'Всё равно продать', imgui.ImVec2(-1, 25)) then
													if not inprocess then
														sellList.checking_medcard.status = 0
														sellNextLicense()
													else
														ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
													end
												end
												imgui.PopStyleVar(2)
												imgui.PopFont()
												imgui.EndPopup()
											end
										end
	
										imgui.SetCursorPos(imgui.ImVec2(70, 20))
										imgui.PopupButton(dl, '##checkingmc', u8'Проверка мед. карты', textcolor, '##skipornomc', popup)
									elseif sellList.checking_medcard.status == 3 then
										imgui.TextColoredRGB('{FF0000}Мед.карта не в норме. Информирование...', 1)
									elseif sellList.checking_medcard.status == 4 then
										local popup = function()
											if imgui.BeginPopup('##skipornomc') then
												imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 1))
												imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
												imgui.PushFont(font[12])
												if imgui.Button(u8'Пропустить лицензии', imgui.ImVec2(-1, 25)) then
													for i = #sellList, 1, -1 do
														if AshSettings.ScannedVariables.PriceList[sellList[i].licenseNumber].medcard then
															table.remove(sellList, i)
														end
													end
													sellList.checking_medcard.status = 0
													sellNextLicense()
												end
												if imgui.Button(u8'Всё равно продать', imgui.ImVec2(-1, 25)) then
													sellList.checking_medcard.status = 0
													sellNextLicense()
												end
												imgui.PopStyleVar(2)
												imgui.PopFont()
												imgui.EndPopup()
											end
										end
	
										imgui.SetCursorPos(imgui.ImVec2(70, 20))
										imgui.PopupButton(dl, '##notgoodmc', u8'Мед.карта не в норме', imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0, 0, 1)), '##skipornomc', popup)
									end
								else
									local status = sellList[sellList.sellLicense].status
									if status > 3 and status < 12 then
										local statusText = {
											[4] = 'Клиент отошел слишком\nдалеко',
											[5] = 'У клиента уже есть эта\nлицензия сроком 3+ дней',
											[6] = 'У клиента недостаточно\nденег для покупки',
											[7] = 'Вы пытаетесь продать\nлицензию самому себе?',
											[8] = 'Вы не можете продать\nэту лицензию',
											[9] = 'Вы не перееодеты',
											[10] = 'Мед. карта не в норме.',
											[11] = 'Игрок отказался от\nпокупки'
										}
										local statusReplies = {
											[4] = 'Подойдите ближе, чтобы я смог передать вам лицензию.',
											[5] = 'У вас уже есть данная лицензия сроком более чем 3 дня.',
											[6] = 'У вас точно есть средства для покупки этой лицензии?',
											[7] = 'Ой...',
											[8] = 'Простите, моя должность не позволяет мне выдать эту лицензию.',
											[9] = 'Мне нужно переодеться в форму.',
											[11] = 'Вы решили не покупать лицензию? Чем я могу вам помочь?',
										}
										local popup = function()
											if imgui.BeginPopup('##errorpopup') then
												imgui.PushFont(font[12])
												imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
												imgui.Spacing()
												imgui.TextColoredRGB(statusText[sellList[sellList.sellLicense].status], 1)
												imgui.Separator()
												imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 1))
												if imgui.Button(u8'Попробовать ещё раз', imgui.ImVec2(-1, 25)) then
													sellNextLicense()
												end
												if imgui.Button(u8'Сообщить клиенту', imgui.ImVec2(-1, 25)) then
													sampSendChat(statusReplies[sellList[sellList.sellLicense].status])
												end
												if sellList.sellLicense < #sellList then
													if imgui.Button(u8'Пропустить лицензию', imgui.ImVec2(-1, 25)) then
														sellList[sellList.sellLicense].status = 12
														sellList.sellLicense = sellList.sellLicense + 1
														sellNextLicense()
													end
												end
												imgui.PopStyleVar()
												imgui.Spacing()
												imgui.Separator()
		
												if imgui.Button(u8'Отменить продажу', imgui.ImVec2(-1, 25)) then
													sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
												end
		
												imgui.PopStyleVar()
												imgui.Spacing()
												imgui.PopFont()
												imgui.EndPopup()
											end
										end

										imgui.SetCursorPos(imgui.ImVec2(90, 20))
										imgui.PopupButton(dl, '##errorpopupbutton', u8'Возникла ошибка', imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0, 0, 1)), '##errorpopup', popup)
									else
										local statusText = {
											[0] = 'Не готово',
											[1] = 'Разговор...',
											[2] = 'Ожидается продажа',
											[3] = 'Продажа успешна',
										}
										imgui.TextColoredRGB(statusText[sellList[sellList.sellLicense].status] and statusText[sellList[sellList.sellLicense].status] or '{FF0000}Ошибка', 1)
									end
									
								end
							end
							imgui.SetCursorPosY(60)
							imgui.BeginGroup()
							for k, v in ipairs(sellList) do
								if k == 6 then imgui.SetCursorPosY(60) end
								imgui.SetCursorPosX(k > 5 and 180 or 40)
								local p = imgui.GetCursorScreenPos()
								imgui.Text(licenses[v.licenseNumber].icon..' '..u8(v.license))
								imgui.Spacing()
								local function getLineInfo()
									if sellList.checking_medcard.status ~= 0 then return {0, 0} end
									if v.status == 1 then
										local lenghtScale = ImSaturate((clock() - v.changed) / v.dialogTime)
										local lenght = p.y - 5 + lenghtScale * (imgui.CalcTextSize(licenses[k].icon..' '..u8(v.license)).y + 10)
										return {AshSettings.MainSettings.ASChatColor.color, lenght}
									elseif v.status == 2 then
										local blinkTime = 1
										local alphaTime = (clock() - v.changed + blinkTime) / blinkTime % 2
										local alpha = alphaTime > 1 and 2 - alphaTime or alphaTime
										
										local color = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)
										local r, g, b = color.x, color.y, color.z

										return {imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r, g, b, alpha)), p.y + imgui.CalcTextSize(licenses[k].icon..' '..u8(v.license)).y + 5}
									elseif v.status == 3 then
										return {AshSettings.MainSettings.ASChatColor.color, p.y + imgui.CalcTextSize(licenses[k].icon..' '..u8(v.license)).y + 5}
									elseif v.status > 3 then
										return {imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0, 0, 1)), p.y + imgui.CalcTextSize(licenses[k].icon..' '..u8(v.license)).y + 5}
									end
									return {0, 0}
								end
								local lineInfo = getLineInfo()
								dl:AddLine(imgui.ImVec2(p.x - 10, p.y - 5), imgui.ImVec2(p.x - 10, p.y + imgui.CalcTextSize(licenses[k].icon..' '..u8(v.license)).y + 5), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 2)
								dl:AddLine(imgui.ImVec2(p.x - 10, p.y - 5), imgui.ImVec2(p.x - 10, lineInfo[2]), lineInfo[1], 2)
							end
							imgui.PopFont()
							imgui.EndGroup()

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmcancellic',imgui.ImVec2(138,20)) then
								sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
								if inprocess then
									inprocess:terminate()
									inprocess = nil
								end
								ASHelperMessage('Отыгровка успешно прервана!')
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Отменить (Alt + K)')
							imgui.PopFont()
						else
							imgui.BeginGroup()
								if choosedlic == 0 then
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
									imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.5)
									imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 5, imgui.GetCursorPos().y - 5))
									if imgui.Button('##selectalllicenses', imgui.ImVec2(sizex + spacingx + 89, 25)) then
										for k, v in ipairs(licenses) do
											if AshSettings.ScannedVariables.PriceList[k].rank <= AshSettings.MainSettings.myrankint then
												v.month = 1
												v.bool = true
											end
										end
									end
									imgui.PopStyleColor()
									imgui.PopStyleVar()
	
									dl:AddRectFilled(imgui.ImVec2(p.x , p.y), imgui.ImVec2(p.x + sizex, p.y + sizey), color, 2, imgui.DrawCornerFlags.TopLeft)
									dl:AddRectFilled(imgui.ImVec2(p.x + sizex + spacingx, p.y), imgui.ImVec2(p.x + sizex * 2 + spacingx, p.y + sizey), color, 2, imgui.DrawCornerFlags.TopRight)
									dl:AddRectFilled(imgui.ImVec2(p.x , p.y + sizey + spacingy), imgui.ImVec2(p.x + sizex, p.y + sizey * 2 + spacingy), color, 2, imgui.DrawCornerFlags.BotLeft)
									dl:AddRectFilled(imgui.ImVec2(p.x + sizex + spacingx , p.y + sizey + spacingy), imgui.ImVec2(p.x + sizex * 2 + spacingx, p.y + sizey * 2 + spacingy), color, 2, imgui.DrawCornerFlags.BotRight)
	
									dl:AddText(imgui.ImVec2(p.x + sizex * 2 + spacingx + 5, p.y + 1), textcolor, u8'Выбрать все')
								else
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
									imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.5)
									imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 5, imgui.GetCursorPos().y - 5))
									if imgui.Button('##deselectalllicenses', imgui.ImVec2(sizex + spacingx + 111, 25)) then
										for k, v in ipairs(licenses) do
											v.bool = false
										end
									end
									imgui.PopStyleColor()
									imgui.PopStyleVar()
	
									dl:AddRect(imgui.ImVec2(p.x , p.y), imgui.ImVec2(p.x + sizex, p.y + sizey), color, 2, imgui.DrawCornerFlags.TopLeft)
									dl:AddRect(imgui.ImVec2(p.x + sizex + spacingx, p.y), imgui.ImVec2(p.x + sizex * 2 + spacingx, p.y + sizey), color, 2, imgui.DrawCornerFlags.TopRight)
									dl:AddRect(imgui.ImVec2(p.x , p.y + sizey + spacingy), imgui.ImVec2(p.x + sizex, p.y + sizey * 2 + spacingy), color, 2, imgui.DrawCornerFlags.BotLeft)
									dl:AddRect(imgui.ImVec2(p.x + sizex + spacingx , p.y + sizey + spacingy), imgui.ImVec2(p.x + sizex * 2 + spacingx, p.y + sizey * 2 + spacingy), color, 2, imgui.DrawCornerFlags.BotRight)
	
									dl:AddText(imgui.ImVec2(p.x + sizex * 2 + spacingx + 5, p.y + 1), textcolor, u8'Отменить выбор')
	
									local popup = function()
										if imgui.BeginPopup('##choosealllicensestime') then
											imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 1))
											imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
											if imgui.Button(u8'1 месяц', imgui.ImVec2(-1, 25)) then
												for k, v in pairs(licenses) do
													if v.bool then v.month = 1 end
												end
											end
											if imgui.Button(u8'2 месяца', imgui.ImVec2(-1, 25)) then
												for k, v in pairs(licenses) do
													if v.bool then v.month = #AshSettings.ScannedVariables.PriceList[k].price >= 2 and 2 or #AshSettings.ScannedVariables.PriceList[k].price end
												end
											end
											if imgui.Button(u8'3 месяца', imgui.ImVec2(-1, 25)) then
												for k, v in pairs(licenses) do
													if v.bool then v.month = #AshSettings.ScannedVariables.PriceList[k].price >= 3 and 3 or #AshSettings.ScannedVariables.PriceList[k].price end
												end
											end
											imgui.Spacing()
											imgui.Separator()
											imgui.Spacing()
											if imgui.Button(u8'Спросить у клиента', imgui.ImVec2(-1, 25)) then
												sampSendChat('На какой срок желаете оформить?')
											end
											imgui.PopStyleVar(2)
											imgui.EndPopup()
										end
									end

									imgui.SetCursorPos(imgui.ImVec2(145, 20))
									imgui.PopupButton(dl, '##licensestime', u8'Срок хранения', textcolor, '##choosealllicensestime', popup)
	
									imgui.SetCursorPos(imgui.ImVec2(275, 20))
									local p = imgui.GetCursorScreenPos()
									imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
									imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0.5)
									imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x - 7, imgui.GetCursorPos().y - 5))
									if imgui.Button('##saytheprice', imgui.ImVec2(sizex + spacingx + 10, 25)) then
										local price = 0
										for k, v in pairs(licenses) do
											if v.bool then
												price = price + AshSettings.ScannedVariables.PriceList[k].price[v.month]
											end
										end
										if choosedlic == 1 then
											sampSendChat('Итоговая сумма желаемой вами лицензии будет составлять '..string.separate(price)..'$')
										elseif choosedlic > 1 then
											sampSendChat('Итоговая сумма желаемых вами лицензий будет составлять '..string.separate(price)..'$')
										end
									end
									imgui.PopStyleColor()
									imgui.PopStyleVar()
									dl:AddText(imgui.ImVec2(p.x - 1, p.y + 1), textcolor, '$')
								end
							imgui.EndGroup()

							imgui.Separator()
							imgui.Spacing()

							imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 1))
							local y = imgui.GetCursorPosY()
							imgui.SetCursorPos(imgui.ImVec2(23,y))
							imgui.BeginGroup()
								for i = 1, 5 do
									imgui.LicenseButton(i)
								end
							imgui.EndGroup()
							imgui.SetCursorPos(imgui.ImVec2(155,y))
							imgui.BeginGroup()
								for i = 6, 10 do
									imgui.LicenseButton(i)
								end
							imgui.EndGroup()
							imgui.PopStyleVar()

							imgui.SetCursorPos(imgui.ImVec2(15,240))
							if imgui.InvisibleButton('##fmbackbutton',imgui.ImVec2(55,20)) then
								clienttype[0] = 0
							end
							imgui.SetCursorPos(imgui.ImVec2(15,240))
							imgui.PushFont(font[16])
							imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_CHEVRON_LEFT..u8' Назад')
							imgui.PopFont()

							if choosedlic > 0 then
								imgui.SetCursorPos(imgui.ImVec2(210,240))
								if imgui.InvisibleButton('##fmselllicense',imgui.ImVec2(75,20)) then
									if not inprocess then
										sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
										for k, v in pairs(licenses) do
											if v.bool then
												sellList[#sellList+1] = {
													license = v.text,
													licenseNumber = k,
													chat = v.chat,
													month = v.month,
													status = 0, -- 0 - not yet; 1 - speaking; 2 - waiting; 3 - success; 4 - fail | too far, 5 - fail | more than 3 days, 6 - fail | no money, 7 - to fail | myself | fail
													dialogTime = 0,
													changed = clock(),
												}
												
												if AshSettings.ScannedVariables.PriceList[k].medcard then
													sellList.checking_medcard.status = 1
													sellList.checking_medcard.licenses = sellList.checking_medcard.licenses == '' and v.chat or sellList.checking_medcard.licenses..', '..v.chat
												end
	
												licenses[k].bool = false
												licenses[k].month = 1
											end
										end
										sellList.sellLicense = 1
										sellList.sellPerson = fastmenuID
										sellList.lastSell = clock()
		
										sellNextLicense()
									else
										sendchatarray(AshSettings.MainSettings.playcd, {''})
									end
								end
								imgui.SetCursorPos(imgui.ImVec2(210,240))
								imgui.PushFont(font[16])
								imgui.TextColored(imgui.IsItemHovered() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], u8'Продать '..fa.ICON_FA_FILE_SIGNATURE)
								imgui.PopFont()
							end
						end
					end
				elseif newwindowtype[0] == 2 then
					local dl = imgui.GetWindowDrawList()
					local startPos = imgui.GetCursorScreenPos()

					local alphaChangeAnimTime = 0.25
					local titleMoveTime = 0.25
					local titleMoveTime2 = 0.25
					local inAnim = {
						clock() - Interview.stage_changing_clock <= alphaChangeAnimTime + titleMoveTime,
						clock() - Interview.stage_changing_clock >= alphaChangeAnimTime + titleMoveTime and clock() - Interview.stage_changing_clock <= alphaChangeAnimTime + titleMoveTime + titleMoveTime2,
						clock() - Interview.stage_changing_clock >= alphaChangeAnimTime + titleMoveTime + titleMoveTime2
					}
					imgui.SetCursorPos(imgui.ImVec2(15,15 + 25 * (inAnim[1] and Interview.previous_stage or Interview.stage)))

					imgui.BeginGroup()
						if (Interview.stage == 1 and (inAnim[2] or inAnim[3])) or (Interview.previous_stage == 1 and inAnim[1]) then
							local alpha = 1
							if Interview.previous_stage == 1 and inAnim[1] then
								alpha = 1 - ImSaturate((clock() - Interview.stage_changing_clock) / alphaChangeAnimTime)
							elseif Interview.stage == 1 and (inAnim[2] or inAnim[3]) then
								alpha = ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime + titleMoveTime2)) / alphaChangeAnimTime)
							end

							imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

							if imgui.Button(u8'Поприветствовать игрока', imgui.ImVec2(270,25)) then
								sendchatarray(AshSettings.MainSettings.playcd, {
									{'Здравствуйте, я %s %s, Вы пришли на собеседование?', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы г. Сан-Фиерро'},
									{'/do На груди висит бейджик с надписью %s %s.', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint], #AshSettings.MainSettings.myname < 1 and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname)},
								})
							end
							local pos = imgui.GetCursorScreenPos()
							if imgui.InvisibleButton(u8'Проверить документы', imgui.ImVec2(270,25)) then
								if AshSettings.Interview.pass.state or AshSettings.Interview.mc.state or AshSettings.Interview.licenses.state then
									if not inprocess then
										local s = AshSettings.Interview
										local out = (s.pass.state and 'ваш паспорт' or '')..
													(s.mc.state and (s.pass.state and (s.licenses.state and ', мед. карту' or ' и мед. карту') or 'вашу мед. карту') or '')..
													(s.licenses.state and ((s.pass.state or s.mc.state) and ' и пакет лицензий' or 'ваш пакет лицензий') or '')
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Хорошо, чтобы мы могли продолжить, мне нужно увидеть %s', out},
											{'/n Обязательно отыграть РП!'},
										})
										Interview.stage = 2
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
									end
								else
									Interview.stage = 3
								end
								Interview.Checking = {
									state = 0,
									pass = {
										state = 0,
										reason = 0,
									},
									mc = {
										state = 0,
										reason = 0,
									},
									licenses = {
										state = 0,
										reason = 0,
									}
								}
								Interview.previous_stage = 1
								Interview.stage_changing_clock = clock()
								inAnim[1] = true
							end

							local butcol = imgui.GetStyle().Colors[imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button]
							local butCol = imgui.ImVec4(butcol.x, butcol.y, butcol.z, butcol.w * alpha)
							local textcol = imgui.GetStyle().Colors[imgui.Col.Text]
							local textCol = imgui.ImVec4(textcol.x, textcol.y, textcol.z, textcol.w * alpha)
							dl:AddRectFilled(pos, imgui.ImVec2(pos.x + 270, pos.y + 25), imgui.ColorConvertFloat4ToU32(butCol), 5, imgui.DrawCornerFlags.Top)
							local text = (AshSettings.Interview.pass.state or AshSettings.Interview.mc.state or AshSettings.Interview.licenses.state) and u8'Проверить документы' or u8'Пропустить проверку документов'
							dl:AddText(imgui.ImVec2(pos.x + 135 - imgui.CalcTextSize(text).x / 2, pos.y + 6), imgui.ColorConvertFloat4ToU32(textCol), text)

							local anim_time = 0.2
							local plus_y = 105
							local anim_scale = ImSaturate((clock() - Interview.additional_docs_time) / anim_time)
							local anim = Interview.additional_docs == true and plus_y * anim_scale or plus_y - plus_y * anim_scale
							imgui.SetCursorPosY(imgui.GetCursorPosY() - imgui.GetStyle().ItemSpacing.y)
							local pos = imgui.GetCursorScreenPos()
							local curPos = imgui.GetCursorPos()
							imgui.SetCursorPosY(curPos.y + anim)
							if imgui.InvisibleButton(u8'Остальные настройки', imgui.ImVec2(270,15)) then
								if anim_scale == 1 then
									Interview.additional_docs_time = clock()
									Interview.additional_docs_config.clock = clock() + 0.2
									Interview.additional_docs = not Interview.additional_docs
								end
							end
							local butcol = imgui.GetStyle().Colors[imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button]
							local butCol = imgui.ImVec4(butcol.x, butcol.y, butcol.z, butcol.w * alpha)
							dl:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 270, pos.y + anim), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1,1,1,0.05*alpha)))
							dl:AddRectFilled(imgui.ImVec2(pos.x, pos.y + anim), imgui.ImVec2(pos.x + 270, pos.y + 15 + anim), imgui.ColorConvertFloat4ToU32(butCol), 5, imgui.DrawCornerFlags.Bot)
							dl:AddText(imgui.ImVec2(pos.x + 135 - imgui.CalcTextSize('...').x / 2, pos.y - 2 + anim), imgui.ColorConvertFloat4ToU32(textCol), '...')

							if Interview.additional_docs == true then
								local anim_scale = ImSaturate((clock() - Interview.additional_docs_config.clock) / anim_time)
								
								imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha == 1 and (Interview.additional_docs_config.state >= 4 and 1 - anim_scale or anim_scale) or alpha)
								imgui.SetCursorPos(imgui.ImVec2(curPos.x + (Interview.additional_docs_config.state >= 4 and 20 or 15) + 5 * anim_scale, curPos.y + 10))
								imgui.BeginGroup()
									if Interview.additional_docs_config.state == 0 or Interview.additional_docs_config.state == 4 then
										if imgui.Checkbox(u8'Проверять паспорт', Interview.additional_docs_config.pass.state) then
											AshSettings.Interview.pass.state = Interview.additional_docs_config.pass.state[0]
											AshSettings()
										end
										imgui.SameLine(220)
										if imgui.Button(fa.ICON_FA_CHEVRON_RIGHT..'##ПАСПОРТ') then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 4
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 1
											end)
										end
										if imgui.Checkbox(u8'Проверять мед. карту', Interview.additional_docs_config.mc.state) then
											AshSettings.Interview.mc.state = Interview.additional_docs_config.mc.state[0]
											AshSettings()
										end
										imgui.SameLine(220)
										if imgui.Button(fa.ICON_FA_CHEVRON_RIGHT..'##МЕДКАРТА') then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 4
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 2
											end)
										end
										if imgui.Checkbox(u8'Проверять лицензии', Interview.additional_docs_config.licenses.state) then
											AshSettings.Interview.licenses.state = Interview.additional_docs_config.licenses.state[0]
											AshSettings()
										end
										imgui.SameLine(220)
										if imgui.Button(fa.ICON_FA_CHEVRON_RIGHT..'##ЛИЦЕНЗИИ') then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 4
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 3
											end)
										end
									elseif Interview.additional_docs_config.state == 1 or Interview.additional_docs_config.state == 5 then
										if imgui.Button(fa.ICON_FA_CHEVRON_LEFT) then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 5
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 0
											end)
										end
										imgui.SameLine()
										imgui.Text(u8'Проверка паспорта')
										imgui.PushItemWidth(100)
										if imgui.InputInt(u8'Мин. лет в штате', Interview.additional_docs_config.pass.minLvl) then
											AshSettings.Interview.pass.minLvl = Interview.additional_docs_config.pass.minLvl[0]
											AshSettings()
										end
										if imgui.InputInt(u8'Мин. законопослушность', Interview.additional_docs_config.pass.minLaw) then
											AshSettings.Interview.pass.minLaw = Interview.additional_docs_config.pass.minLaw[0]
											AshSettings()
										end
										imgui.PopItemWidth()
									elseif Interview.additional_docs_config.state == 2 or Interview.additional_docs_config.state == 6 then
										if imgui.Button(fa.ICON_FA_CHEVRON_LEFT) then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 6
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 0
											end)
										end
										imgui.SameLine()
										imgui.Text(u8'Проверка мед. карты')
										if imgui.Checkbox(u8'Полностью здоровый', Interview.additional_docs_config.mc.healthStatus) then
											AshSettings.Interview.mc.healthStatus = Interview.additional_docs_config.mc.healthStatus[0]
											AshSettings()
										end
										imgui.PushItemWidth(100)
										if imgui.InputInt(u8'Макс. зависимость', Interview.additional_docs_config.mc.maxAddiction) then
											AshSettings.Interview.mc.maxAddiction = Interview.additional_docs_config.mc.maxAddiction[0]
											AshSettings()
										end
										imgui.PopItemWidth()
									elseif Interview.additional_docs_config.state == 3 or Interview.additional_docs_config.state == 7 then
										if imgui.Button(fa.ICON_FA_CHEVRON_LEFT) then
											lua_thread.create(function()
												Interview.additional_docs_config.state = 7
												Interview.additional_docs_config.clock = clock()
												wait(anim_time * 1000)
												Interview.additional_docs_config.clock = clock()
												Interview.additional_docs_config.state = 0
											end)
										end
										imgui.SameLine()
										imgui.Text(u8'Проверка лицензий')
										if imgui.Checkbox(u8'Требовать авто', Interview.additional_docs_config.licenses.auto) then
											AshSettings.Interview.licenses.auto = Interview.additional_docs_config.licenses.auto[0]
											AshSettings()
										end
										if imgui.Checkbox(u8'Требовать мото', Interview.additional_docs_config.licenses.moto) then
											AshSettings.Interview.licenses.moto = Interview.additional_docs_config.licenses.moto[0]
											AshSettings()
										end
									end
								imgui.EndGroup()
								imgui.PopStyleVar()
							end
							imgui.PopStyleVar()
						elseif (Interview.stage == 2 and (inAnim[2] or inAnim[3])) or (Interview.previous_stage == 2 and inAnim[1]) then
							if not AshSettings.Interview.pass.state and not AshSettings.Interview.mc.state and not AshSettings.Interview.licenses.state then
								Interview.stage = 3
							end
							local alpha = 1
							if Interview.previous_stage == 2 and inAnim[1] then
								alpha = 1 - ImSaturate((clock() - Interview.stage_changing_clock) / alphaChangeAnimTime)
							elseif Interview.stage == 2 and (inAnim[2] or inAnim[3]) then
								alpha = ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime + titleMoveTime2)) / alphaChangeAnimTime)
							end
							imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
							if Interview.Checking.state == 0 then
								imgui.SetCursorPosX(70)
								imgui.Spinner(u8' Ожидание документов', 5, 1, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
								imgui.NewLine()
								if imgui.Button(u8'Пропустить', imgui.ImVec2(270, 25)) then
									Interview.stage = 3
									Interview.previous_stage = 2
									Interview.stage_changing_clock = clock()
									inAnim[1] = true
								end
							elseif Interview.Checking.state == 1 or Interview.Checking.state == 2 then
								imgui.SetCursorPosX(66)
								imgui.Spinner(u8' Документы проверяются', 6, 1, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
								imgui.NewLine()
							elseif Interview.Checking.state == 3 then
								imgui.SetCursorPosX(300 / 2 - imgui.CalcTextSize(fa.ICON_FA_CHECK_CIRCLE..u8' Документы в порядке').x / 2)
								imgui.TextColored(imgui.ImVec4(0.3, 1, 0.3, alpha), fa.ICON_FA_CHECK_CIRCLE..u8' Документы в порядке')
								imgui.Spacing()
								if imgui.Button(u8'Продолжить',imgui.ImVec2(270, 30)) then
									if not inprocess then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
											{'/do Документы в порядке.'},
											{'/todo Хорошо, с формальностями закончили...* отдавая документы обратно'},
											{'Сейчас мы с Вами поговорим, чтобы я понял, что Вы нам точно подходите.'},
										})
										Interview.previous_stage = 2
										Interview.stage = 3
										Interview.stage_changing_clock = clock()
										inAnim[1] = true
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
									end
								end
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
								if imgui.Button(u8'Перейти к заключению',imgui.ImVec2(270, 23)) then
									Interview.previous_stage = 2
									Interview.stage = 4
									Interview.additional_reasons_config.unlockedReasons.choosed = 1
									Interview.stage_changing_clock = clock()
									inAnim[1] = true
								end
							elseif Interview.Checking.state == 4 then
								imgui.SetCursorPosX(300 / 2 - imgui.CalcTextSize(fa.ICON_FA_TIMES_CIRCLE..u8' Человек не подходит').x / 2)
								imgui.TextColored(imgui.ImVec4(1, 1, 0.3, alpha), fa.ICON_FA_TIMES_CIRCLE..u8' Человек не подходит')
								if AshSettings.Interview.pass.state then
									imgui.Text(u8'Паспорт: ')
									imgui.SameLine()
									local text = u8(Interview.Checking.pass.state == 2 and Interview.Checking.pass.reason or 'В норме')
									imgui.SetCursorPosX(285 - imgui.CalcTextSize(text).x)
									imgui.TextColored(Interview.Checking.pass.state == 2 and imgui.ImVec4(1, 0.3, 0.3, alpha) or imgui.ImVec4(0.3, 1, 0.3, alpha), text)
								end
								if AshSettings.Interview.mc.state then
									imgui.Text(u8'Мед. карта: ')
									imgui.SameLine()
									local text = u8(Interview.Checking.mc.state == 2 and Interview.Checking.mc.reason or 'В норме')
									imgui.SetCursorPosX(285 - imgui.CalcTextSize(text).x)
									imgui.TextColored(Interview.Checking.mc.state == 2 and imgui.ImVec4(1, 0.3, 0.3, alpha) or imgui.ImVec4(0.3, 1, 0.3, alpha), text)
								end
								if AshSettings.Interview.licenses.state then
									imgui.Text(u8'Лицензии: ')
									imgui.SameLine()
									local text = u8(Interview.Checking.licenses.state == 2 and Interview.Checking.licenses.reason or 'В норме')
									imgui.SetCursorPosX(285 - imgui.CalcTextSize(text).x)
									imgui.TextColored(Interview.Checking.licenses.state == 2 and imgui.ImVec4(1, 0.3, 0.3, alpha) or imgui.ImVec4(0.3, 1, 0.3, alpha), text)
								end
								imgui.Spacing()
								if imgui.Button(u8'Перейти к заключению',imgui.ImVec2(270, 30)) then
									Interview.previous_stage = 2
									Interview.stage = 4
									Interview.additional_reasons_config.unlockedReasons.choosed = 5
									Interview.stage_changing_clock = clock()
									inAnim[1] = true
								end
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
								if imgui.Button(u8'Всё равно продолжить',imgui.ImVec2(270, 23)) then
									if not inprocess then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
											{'/todo Хорошо, с формальностями закончили...* отдавая документы обратно'},
											{'Сейчас мы с Вами поговорим, чтобы я понял, что Вы нам точно подходите.'},
										})
										Interview.previous_stage = 2
										Interview.stage = 3
										Interview.stage_changing_clock = clock()
										inAnim[1] = true
									else
										ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
									end
								end
							end
							if Interview.Checking.pass.state == 1 and Interview.Checking.mc.state == 1 and Interview.Checking.licenses.state == 1 and Interview.Checking.state == 2 then
								Interview.Checking.state = 3
							elseif (Interview.Checking.pass.state == 2 or Interview.Checking.mc.state == 2 or Interview.Checking.licenses.state == 2) and Interview.Checking.state == 2 then
								Interview.Checking.state = 4
							end

							imgui.PopStyleVar()

						elseif (Interview.stage == 3 and (inAnim[2] or inAnim[3])) or (Interview.previous_stage == 3 and inAnim[1]) then
							local alpha = 1
							if Interview.previous_stage == 3 and inAnim[1] then
								alpha = 1 - ImSaturate((clock() - Interview.stage_changing_clock) / alphaChangeAnimTime)
							elseif Interview.stage == 3 and (inAnim[2] or inAnim[3]) then
								alpha = ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime + titleMoveTime2)) / alphaChangeAnimTime)
							end
							imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)

							imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(5, 2))
							imgui.BeginGroup()
							for i = 1, 2 do
								if AshSettings.Interview.additional_questions[i] ~= nil and #AshSettings.Interview.additional_questions[i] > 0 then
									local text = AshSettings.Interview.additional_questions[i]
									local showen_text = #text > 18 and u8(text:sub(1, 18)..'...') or u8(text)
									if imgui.Button(showen_text, imgui.ImVec2(135, 25)) then
										if not inprocess then
											sampSendChat(text)
										else
											ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
										end
									end
									if imgui.IsItemHovered() and imgui.IsMouseReleased(1) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, u8(text))
									end
								else
									if imgui.Button(u8'Пусто##'..i, imgui.ImVec2(135, 25)) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, '')
									end
									if imgui.IsItemHovered() and imgui.IsMouseReleased(1) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, '')
									end
								end
							end
							imgui.EndGroup()
							imgui.SameLine(nil, 2)
							imgui.BeginGroup()
							for i = 3, 4 do
								if AshSettings.Interview.additional_questions[i] ~= nil and #AshSettings.Interview.additional_questions[i] > 0 then
									local text = AshSettings.Interview.additional_questions[i]
									local showen_text = #text > 18 and u8(text:sub(1, 18)..'...') or u8(text)
									if imgui.Button(showen_text, imgui.ImVec2(135, 25)) then
										if not inprocess then
											sampSendChat(text)
										else
											ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
										end
									end
									if imgui.IsItemHovered() and imgui.IsMouseReleased(1) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, u8(text))
									end
								else
									if imgui.Button(u8'Пусто##'..i, imgui.ImVec2(135, 25)) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, '')
									end
									if imgui.IsItemHovered() and imgui.IsMouseReleased(1) then
										Interview.additional_questions_redact = i
										imgui.StrCopy(Interview.additional_questions_redact_input, '')
									end
								end
							end
							imgui.EndGroup()
							imgui.PopStyleVar()

							imgui.Spacing()
							if Interview.additional_questions_redact == 0 then
								if imgui.Button(u8'Продолжить', imgui.ImVec2(272, 25)) then
									if Interview.Checking.state == 0 then
										Interview.additional_reasons_config.unlockedReasons.choosed = 4
									else
										Interview.additional_reasons_config.unlockedReasons.choosed = 6
									end
									Interview.stage = 4
									Interview.previous_stage = 3
									Interview.stage_changing_clock = clock()
									inAnim[1] = true
								end
							else
								if imgui.Button(fa.ICON_FA_TIMES_CIRCLE) then
									Interview.additional_questions_redact = 0
									imgui.StrCopy(Interview.additional_questions_redact_input, '')
								end
								imgui.SameLine()
								imgui.PushItemWidth(202)
								imgui.InputText(u8'##additional_questions_redact', Interview.additional_questions_redact_input, sizeof(Interview.additional_questions_redact_input))
								imgui.PopItemWidth()
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_CHECK_CIRCLE) then
									AshSettings.Interview.additional_questions[Interview.additional_questions_redact] = u8:decode(str(Interview.additional_questions_redact_input))
									Interview.additional_questions_redact = 0
									imgui.StrCopy(Interview.additional_questions_redact_input, '')
									AshSettings()
								end
							end

							imgui.PopStyleVar()
						elseif (Interview.stage == 4 and (inAnim[2] or inAnim[3])) or (Interview.previous_stage == 4 and inAnim[1]) then
							local alpha = 1
							if Interview.previous_stage == 4 and inAnim[1] then
								alpha = 1 - ImSaturate((clock() - Interview.stage_changing_clock) / alphaChangeAnimTime)
							elseif Interview.stage == 4 and (inAnim[2] or inAnim[3]) then
								alpha = ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime + titleMoveTime2)) / alphaChangeAnimTime)
							end
							imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
							if imgui.Button(u8'Успешно пройдено', imgui.ImVec2(270, 25)) then
								if not inprocess then
									if AshSettings.MainSettings.myrankint >= 9 then
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Отлично, я думаю Вы нам подходите!'},
											{'/do Ключи от шкафчика в кармане.'},
											{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
											{'/me {gender:передал|передала} ключ человеку напротив'},
											{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
											{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
											{'/invite %s', fastmenuID},
										})
									else
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'Отлично, я думаю Вы нам подходите! Я сообщу руководству и вам предоставят ключ от шкафчика.'},
											{'/r %s успешно прошёл собеседование! Прошу подойти ко мне, чтобы принять его.', gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')},
											{'/rb %s id', fastmenuID},
										})
									end
									windows.imgui_fm[0] = false
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
								end
							end

							local pos = imgui.GetCursorScreenPos()
							if imgui.InvisibleButton(u8'Провалено', imgui.ImVec2(270,25)) then
								if not inprocess then
									local reason = Interview.additional_reasons_config.unlockedReasons.choosed
									if reason == 5 then
										local text = {
											pass = {
												['Слишком маленький уровень'] = 'Вы проживаете в штате меньше 3-ёх лет.',
												['Слишком маленькая законопослушность'] = 'Вы недостаточно законопослушный.',
												['Работает в другой организации'] = 'Вы уже работаете в другой организации.',
											},
											mc = {
												['Не полностью здоровый'] = 'В мед. карте сказано, что Вы не полностью здоровый.',
												['Нету мед. карты'] = 'Я не вижу мед. карты в предоставленных документах.',
												['зависимости'] = 'В мед. карте стоит пометка, что вы наркозависимый.'
											},
											licenses = {
												['Нету лицензии на авто'] = 'У вас нет лицензии на авто.',
												['Нету лицензии на мото'] = 'У вас нет лицензии на мото.',
											}
										}
										local reasons = {}

										if Interview.Checking.pass.state ~= 1 and AshSettings.Interview.pass.state and type(Interview.Checking.pass.reason) == 'string' then
											for k, v in pairs(text.pass) do
												if Interview.Checking.pass.reason:find(k) then
													reasons[#reasons+1] = v
												end
											end
										end

										if Interview.Checking.mc.state ~= 1 and AshSettings.Interview.mc.state and type(Interview.Checking.mc.reason) == 'string' then
											for k, v in pairs(text.mc) do
												if Interview.Checking.mc.reason:find(k) then
													reasons[#reasons+1] = v
												end
											end
										end

										if Interview.Checking.licenses.state ~= 1 and AshSettings.Interview.licenses.state and type(Interview.Checking.licenses.reason) == 'string' then
											for k, v in pairs(text.licenses) do
												if Interview.Checking.licenses.reason:find(k) then
													reasons[#reasons+1] = v
												end
											end
										end

										local array = {}

										if #reasons > 0 then
											array = {
												{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
												{'/do Документы не в порядке.'},
												{'/todo Так-так-так, у Вас тут проблемка...* отдавая документы обратно'},
												{'К сожалению мы не можем продолжить собеседование. %s', reasons[1]}
											}
											table.remove(reasons, 1)
										else
											array = {
												{'/me взяв документы из рук человека напротив {gender:начал|начала} их проверять'},
												{'/do Документы не в порядке.'},
												{'/todo Так-так-так, у Вас тут проблемка...* отдавая документы обратно'},
												{'К сожалению мы не можем продолжить собеседование.'}
											}
										end

										if #reasons > 0 then
											for k, v in ipairs(reasons) do
												array[#array+1] = {v}
											end
										end
										sendchatarray(AshSettings.MainSettings.playcd, array)
									else
										sampSendChat('К сожалению я не могу принять Вас из-за того, что Вы проф. непригодны.')
										local text = {
											[1] = '/b Ты плохо отыграл РП',
											[2] = '/b Ты не отыграл РП',
											[3] = '/b Ты очень неграмотно пишешь',
											[4] = '/b Ты не показал документы',
										}
										if text[reason] ~= nil then
											sampSendChat(text[reason])
										end
									end
									windows.imgui_fm[0] = false
								else
									ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
								end
							end

							local butcol = imgui.GetStyle().Colors[imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button]
							local butCol = imgui.ImVec4(butcol.x, butcol.y, butcol.z, butcol.w * alpha)
							local textcol = imgui.GetStyle().Colors[imgui.Col.Text]
							local textCol = imgui.ImVec4(textcol.x, textcol.y, textcol.z, textcol.w * alpha)
							dl:AddRectFilled(pos, imgui.ImVec2(pos.x + 270, pos.y + 25), imgui.ColorConvertFloat4ToU32(butCol), 5, imgui.DrawCornerFlags.Top)
							local text = u8('Провалено ('..string.rlower(Interview.additional_reasons_config.unlockedReasons[Interview.additional_reasons_config.unlockedReasons.choosed])..')')
							dl:AddText(imgui.ImVec2(pos.x + 135 - imgui.CalcTextSize(text).x / 2, pos.y + 6), imgui.ColorConvertFloat4ToU32(textCol), text)

							local anim_time = 0.2
							local plus_y = 88
							local anim_scale = ImSaturate((clock() - Interview.additional_reasons_time) / anim_time)
							local anim = Interview.additional_reasons == true and plus_y * anim_scale or plus_y - plus_y * anim_scale
							imgui.SetCursorPosY(imgui.GetCursorPosY() - imgui.GetStyle().ItemSpacing.y)
							local pos = imgui.GetCursorScreenPos()
							local curPos = imgui.GetCursorPos()
							imgui.SetCursorPosY(curPos.y + anim)
							if imgui.InvisibleButton(u8'Выбор причины', imgui.ImVec2(270,15)) then
								if anim_scale == 1 then
									Interview.additional_reasons_time = clock()
									Interview.additional_reasons_config.clock = clock() + 0.2
									Interview.additional_reasons = not Interview.additional_reasons
								end
							end
							local butcol = imgui.GetStyle().Colors[imgui.IsItemActive() and imgui.Col.ButtonActive or imgui.IsItemHovered() and imgui.Col.ButtonHovered or imgui.Col.Button]
							local butCol = imgui.ImVec4(butcol.x, butcol.y, butcol.z, butcol.w * alpha)
							dl:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 270, pos.y + anim), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1,1,1,0.05*alpha)))
							dl:AddRectFilled(imgui.ImVec2(pos.x, pos.y + anim), imgui.ImVec2(pos.x + 270, pos.y + 15 + anim), imgui.ColorConvertFloat4ToU32(butCol), 5, imgui.DrawCornerFlags.Bot)
							dl:AddText(imgui.ImVec2(pos.x + 135 - imgui.CalcTextSize('...').x / 2, pos.y - 2 + anim), imgui.ColorConvertFloat4ToU32(textCol), '...')
							if Interview.additional_reasons == true then
								local anim_scale = ImSaturate((clock() - Interview.additional_reasons_config.clock) / anim_time)
								
								imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha == 1 and anim_scale or alpha)
								imgui.SetCursorPos(imgui.ImVec2(curPos.x + 5 + 5 * anim_scale, curPos.y + 10))
								imgui.BeginGroup()
									local colBut = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
									local colButHovered = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
									local colButActive = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
									local r, g, b, a = colBut.x, colBut.y, colBut.z, colBut.w
									for k = 1, 3 do
										local v = Interview.additional_reasons_config.unlockedReasons[k]
										if Interview.additional_reasons_config.unlockedReasons.choosed == k then
											imgui.PushStyleColor(imgui.Col.ButtonActive, colButHovered)
											imgui.PushStyleColor(imgui.Col.Button, colButHovered)
											if imgui.Button('##'..v, imgui.ImVec2(120, 20)) then
												Interview.additional_reasons_config.unlockedReasons.choosed = k
											end
											imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 120 / 2 - imgui.CalcTextSize(u8(v)).x / 2, imgui.GetCursorPosY() - 25))
											imgui.Text(u8(v))
											imgui.PopStyleColor(2)
										else
											local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
											local r, g, b, a = col.x, col.y, col.z, col.w
											imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
											if imgui.Button('##'..v, imgui.ImVec2(120, 20)) then
												Interview.additional_reasons_config.unlockedReasons.choosed = k
											end
											imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 120 / 2 - imgui.CalcTextSize(u8(v)).x / 2, imgui.GetCursorPosY() - 25))
											imgui.Text(u8(v))
											imgui.PopStyleColor(1)
										end
									end
								imgui.EndGroup()
								imgui.SetCursorPos(imgui.ImVec2(curPos.x + 135 + 5 * anim_scale, curPos.y + 10))
								imgui.BeginGroup()
									for k = 4, 6 do
										local v = Interview.additional_reasons_config.unlockedReasons[k]
										if Interview.additional_reasons_config.unlockedReasons.choosed == k then
											imgui.PushStyleColor(imgui.Col.ButtonActive, colButHovered)
											imgui.PushStyleColor(imgui.Col.Button, colButHovered)
											if imgui.Button('##'..v, imgui.ImVec2(120, 20)) then
												Interview.additional_reasons_config.unlockedReasons.choosed = k
											end
											imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 120 / 2 - imgui.CalcTextSize(u8(v)).x / 2, imgui.GetCursorPosY() - 25))
											imgui.Text(u8(v))
											imgui.PopStyleColor(2)
										else
											imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
											if imgui.Button('##'..v, imgui.ImVec2(120, 20)) then
												Interview.additional_reasons_config.unlockedReasons.choosed = k
											end
											imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPos().x + 120 / 2 - imgui.CalcTextSize(u8(v)).x / 2, imgui.GetCursorPosY() - 25))
											imgui.Text(u8(v))
											imgui.PopStyleColor(1)
										end
									end
								imgui.EndGroup()
								imgui.PopStyleVar()
							end
							imgui.SetCursorPosY(imgui.GetCursorPosY() + 25)
							imgui.PopStyleVar()
						end
					imgui.EndGroup()

					local endPos = imgui.GetCursorScreenPos()

					local textClr = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text])
					local disabledTextClr = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled])

					imgui.PushFont(font[20])

					local pos = imgui.ImVec2(
						startPos.x + 15,
						startPos.y + 10
					)
					local text = u8'Знакомство'
					local hovering = imgui.IsMouseHoveringRect(
						pos,
						imgui.ImVec2(pos.x + imgui.CalcTextSize(text).x, pos.y + imgui.CalcTextSize(text).y)
					)
					local color = Interview.stage == 1 and textClr or hovering and textClr or disabledTextClr
					if Interview.stage ~= 1 and hovering and imgui.IsMouseReleased(0) then
						Interview.stage_changing_clock = clock()
						Interview.previous_stage = Interview.stage
						Interview.stage = 1
						inAnim[1] = true
					end
					dl:AddText(
						pos,
						color,
						text
					)

					local add = {
						startPos = 35,
						endPos = 0,
						stage = 2,
					}
					local y = Interview.stage >= add.stage and startPos.y + add.startPos or endPos.y + add.endPos
					local anim = 0
					if inAnim[1] then
						if Interview.previous_stage < add.stage then
							local def = endPos.y - (startPos.y + add.startPos)
							y = endPos.y + add.endPos
							anim = -(def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime)) / titleMoveTime))
						else
							y = startPos.y + add.startPos
						end
					elseif inAnim[2] and Interview.stage < add.stage then
						local def = endPos.y - (startPos.y + add.startPos)
						y = startPos.y + add.startPos
						anim = def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime)) / titleMoveTime2)
					end
					local pos = imgui.ImVec2(
						startPos.x + 15,
						y + anim
					)
					local text = u8'Проверка документов'
					local hovering = imgui.IsMouseHoveringRect(
						pos,
						imgui.ImVec2(pos.x + imgui.CalcTextSize(text).x, pos.y + imgui.CalcTextSize(text).y)
					)
					local color = Interview.stage == add.stage and textClr or hovering and textClr or disabledTextClr
					if Interview.stage ~= add.stage and (AshSettings.Interview.pass.state or AshSettings.Interview.mc.state or AshSettings.Interview.licenses.state) and hovering and imgui.IsMouseReleased(0) then
						Interview.stage_changing_clock = clock()
						Interview.previous_stage = Interview.stage
						Interview.stage = add.stage
						inAnim[1] = true
					end
					dl:AddText(
						pos,
						color,
						text
					)

					local add = {
						startPos = 60,
						endPos = 25,
						stage = 3,
					}
					if not inAnim[1] then
						if Interview.stage == 2 then
							add.endPos = 0
						end
					end
					local y = Interview.stage >= add.stage and startPos.y + add.startPos or endPos.y + add.endPos
					local anim = 0
					if inAnim[1] then
						if Interview.previous_stage == 2 then
							add.endPos = 0
						end
						if Interview.previous_stage < add.stage then
							local def = endPos.y + add.endPos - (startPos.y + add.startPos)
							y = endPos.y + add.endPos
							anim = -(def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime)) / titleMoveTime))
						else
							y = startPos.y + add.startPos
						end
					elseif inAnim[2] and Interview.stage < add.stage then
						local def = endPos.y + add.endPos - (startPos.y + add.startPos)
						y = startPos.y + add.startPos
						anim = def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime)) / titleMoveTime2)
					end
					local pos = imgui.ImVec2(
						startPos.x + 15,
						y + anim
					)
					local text = u8'Доп. вопросы'
					local hovering = imgui.IsMouseHoveringRect(
						pos,
						imgui.ImVec2(pos.x + imgui.CalcTextSize(text).x, pos.y + imgui.CalcTextSize(text).y)
					)
					local color = Interview.stage == add.stage and textClr or hovering and textClr or disabledTextClr
					if Interview.stage ~= add.stage and hovering and imgui.IsMouseReleased(0) then
						Interview.stage_changing_clock = clock()
						Interview.previous_stage = Interview.stage
						Interview.stage = add.stage
						inAnim[1] = true
					end
					dl:AddText(
						pos,
						color,
						text
					)
					imgui.PushFont(font[11])
					dl:AddText(
						imgui.ImVec2(pos.x + 120, pos.y + 8),
						disabledTextClr,
						Interview.stage == 3 and u8'ПКМ для настройки' or ''
					)
					imgui.PopFont()

					local add = {
						startPos = 85,
						endPos = 50,
						stage = 4,
					}

					if not inAnim[1] then
						if Interview.stage == 2 then
							add.endPos = 25
						elseif Interview.stage == 3 then
							add.endPos = 0
						end
					end

					local y = Interview.stage >= add.stage and startPos.y + add.startPos or endPos.y + add.endPos
					local anim = 0
					if inAnim[1] then
						if Interview.previous_stage == 2 then
							add.endPos = 25
						elseif Interview.previous_stage == 3 then
							add.endPos = 0
						end
						if Interview.previous_stage < add.stage then
							local def = endPos.y + add.endPos - (startPos.y + add.startPos)
							y = endPos.y + add.endPos
							anim = -(def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime)) / titleMoveTime))
						else
							y = startPos.y + add.startPos
						end
					elseif inAnim[2] and Interview.stage < add.stage then
						local def = endPos.y + add.endPos - (startPos.y + add.startPos)
						y = startPos.y + add.startPos
						anim = def * ImSaturate((clock() - (Interview.stage_changing_clock + alphaChangeAnimTime + titleMoveTime)) / titleMoveTime2)
					end
					local pos = imgui.ImVec2(
						startPos.x + 15,
						y + anim
					)
					local text = u8'Заключение'
					local hovering = imgui.IsMouseHoveringRect(
						pos,
						imgui.ImVec2(pos.x + imgui.CalcTextSize(text).x, pos.y + imgui.CalcTextSize(text).y)
					)
					local color = Interview.stage == add.stage and textClr or hovering and textClr or disabledTextClr
					if Interview.stage ~= add.stage and hovering and imgui.IsMouseReleased(0) then
						Interview.stage_changing_clock = clock()
						Interview.previous_stage = Interview.stage
						Interview.stage = add.stage
						if Interview.Checking.state == 0 then
							Interview.additional_reasons_config.unlockedReasons.choosed = 4
						else
							Interview.additional_reasons_config.unlockedReasons.choosed = 6
						end
						inAnim[1] = true
					end
					dl:AddText(
						pos,
						color,
						text
					)
					imgui.PopFont()
				elseif newwindowtype[0] == 3 then
					if leadertype[0] == 0 then
						imgui.SetCursorPos(imgui.ImVec2(15, 15))
						imgui.BeginGroup()
							local isMember
							for k, member in ipairs(checker_variables.online) do
								if member.nickname == sampGetPlayerNickname(fastmenuID) then
									isMember = true
								end
							end

							if isMember then
								imgui.TextColoredRGB('Действия с сотрудником', 1)
								imgui.Spacing()
								if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(270,30)) then
									Ranks_select[0] = 0
									leadertype[0] = 2
								end
								if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(270,30)) then
									leadertype[0] = 1
									imgui.StrCopy(uninvitebuf, '')
									imgui.StrCopy(blacklistbuf, '')
									uninvitebox[0] = false
								end
								if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор', imgui.ImVec2(130,30)) then
									imgui.StrCopy(fwarnbuff, '')
									leadertype[0] = 4
								end
								imgui.SameLine(nil, 10)
								if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор', imgui.ImVec2(130,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
										{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
										{'/do Выговор был убран из личного дела сотрудника.'},
										{'/unfwarn %s', fastmenuID},
									})
								end
								if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут', imgui.ImVec2(130,30)) then
									imgui.StrCopy(fmutebuff, '')
									fmuteint[0] = 0
									leadertype[0] = 5
								end
								imgui.SameLine(nil, 10)
								if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут', imgui.ImVec2(130,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы'},
										{'/me {gender:выбрал|выбрала} нужного сотрудника'},
										{'/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\''},
										{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
										{'/funmute %s', fastmenuID},
									})
								end
							else
								imgui.TextColoredRGB('Действия с посетителем', 1)
								imgui.Spacing()
								imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(270,30))
								if imgui.IsItemHovered() and (imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1)) then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
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
								if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в ЧС', imgui.ImVec2(130,30)) then
									leadertype[0] = 3
									imgui.StrCopy(blacklistbuff, '')
								end
								imgui.SameLine(nil, 10)
								if imgui.Button(fa.ICON_FA_USER..u8' Убрать из ЧС', imgui.ImVec2(130,30)) then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/me {gender:достал|достала} планшет из кармана'},
										{'/me {gender:перешёл|перешла} в раздел \'Чёрный список\''},
										{'/me {gender:ввёл|ввела} имя гражданина в поиск'},
										{'/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\''},
										{'/me {gender:подтведрдил|подтвердила} изменения'},
										{'/do Изменения были сохранены.'},
										{'/unblacklist %s', fastmenuID},
									})
								end
							end
						imgui.EndGroup()
					elseif leadertype[0] == 1 then
						local isMember
						for i, member in ipairs(checker_variables.online) do
							if member.nickname == sampGetPlayerNickname(fastmenuID) then
								isMember = true
							end
						end
						if not isMember then leadertype[0] = 0 imgui.PopStyleVar() imgui.PopStyleColor() return end
						imgui.SetCursorPosY(15)
						imgui.TextColoredRGB('Причина увольнения', 1)
						imgui.Spacing()
						imgui.SetCursorPosX(50)
						imgui.PushItemWidth(200)
						imgui.InputText(u8'##inputuninvitebuf', uninvitebuf, sizeof(uninvitebuf))
						imgui.PopItemWidth()
						imgui.SetCursorPosX(60)
						imgui.Checkbox(u8'Занести в черный список', uninvitebox)
						if uninvitebox[0] then
							imgui.SetCursorPosX(50)
							imgui.PushItemWidth(200)
							imgui.InputText(u8'##inputblacklistbuf', blacklistbuf, sizeof(blacklistbuf))
							imgui.PopItemWidth()
						end
						imgui.NewLine()
						imgui.SetCursorPosX(15)
						if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
							if AshSettings.MainSettings.myrankint >= 9 then
								if #str(uninvitebuf) > 0 then
									if uninvitebox[0] then
										if #str(blacklistbuf) > 0 then
											windows.imgui_fm[0] = false
											sendchatarray(AshSettings.MainSettings.playcd, {
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
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'/me {gender:достал|достала} планшет из кармана'},
											{'/me {gender:перешёл|перешла} в раздел \'Увольнение\''},
											{'/do Раздел открыт.'},
											{'/me {gender:внёс|внесла} человека в раздел \'Увольнение\''},
											{'/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} планшет и {gender:положил|положила} его обратно в карман'},
											{'/uninvite %s %s', fastmenuID, u8:decode(str(uninvitebuf))},
										})
									end
								else
									ASHelperMessage('Введите причину увольнения!')
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
						local memberRank
						for i, member in ipairs(checker_variables.online) do
							if member.nickname == sampGetPlayerNickname(fastmenuID) then
								memberRank = member.rank
							end
						end
						if not memberRank then leadertype[0] = 0 imgui.PopStyleVar() imgui.PopStyleColor() return end
						local ranks = {}
						for k, v in pairs(AshSettings.ScannedVariables.RankNames) do
							if k ~= memberRank and k ~= 10 then
								ranks[#ranks+1] = u8('['..k..'] '..v)
							end
						end
						imgui.SetCursorPosY(15)
						imgui.TextColoredRGB('Изменение должности', 1)
						imgui.Spacing()
						imgui.SetCursorPosX(50)
						imgui.PushItemWidth(200)
						imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
						imgui.Combo('##chooserank9', Ranks_select, new['const char*'][#ranks](ranks), #ranks)
						imgui.PopStyleVar()
						imgui.PopItemWidth()
						imgui.NewLine()
						imgui.SetCursorPosX(15)
						if Ranks_select[0] + 2 > memberRank then
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
							if imgui.Button(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
								if AshSettings.MainSettings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
										{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтвердил|подтвердила} изменения'},
										{'/do Информация о сотруднике была изменена.'},
										{'Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
							imgui.PopStyleColor(3)
						else
							if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
								if AshSettings.MainSettings.myrankint >= 9 then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
										{'/me {gender:включил|включила} планшет'},
										{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
										{'/me {gender:выбрал|выбрала} в разделе нужного сотрудника'},
										{'/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтвердил|подтвердила} изменения'},
										{'/do Информация о сотруднике была изменена.'},
										{'/giverank %s %s', fastmenuID, Ranks_select[0]+1},
									})
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
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
						imgui.SetCursorPosY(15)
						imgui.TextColoredRGB('Причина занесения в ЧС',1)
						imgui.SetCursorPosX(50)
						imgui.PushItemWidth(200)
						imgui.InputText(u8'##inputblacklistbuff', blacklistbuff, sizeof(blacklistbuff))
						imgui.PopItemWidth()
						imgui.NewLine()
						imgui.SetCursorPosX(15)
						if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
							if AshSettings.MainSettings.myrankint >= 9 then
								if #str(blacklistbuff) > 0 then
									windows.imgui_fm[0] = false
									sendchatarray(AshSettings.MainSettings.playcd, {
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
						local isMember
						for i, member in ipairs(checker_variables.online) do
							if member.nickname == sampGetPlayerNickname(fastmenuID) then
								isMember = true
							end
						end
						if not isMember then leadertype[0] = 0 imgui.PopStyleVar() imgui.PopStyleColor() return end
						imgui.SetCursorPosY(15)
						imgui.TextColoredRGB('Причина выговора:',1)
						imgui.Spacing()
						imgui.SetCursorPosX(50)
						imgui.PushItemWidth(200)
						imgui.InputText(u8'##giverwarnbuffinputtext', fwarnbuff, sizeof(fwarnbuff))
						imgui.PopItemWidth()
						imgui.NewLine()
						imgui.SetCursorPosX(15)
						if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
							if #str(fwarnbuff) > 0 then
								windows.imgui_fm[0] = false
								sendchatarray(AshSettings.MainSettings.playcd, {
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
						imgui.SetCursorPosX(15)
						if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
							if AshSettings.MainSettings.myrankint >= 9 then
								if #str(fmutebuff) > 0 then
									if tonumber(fmuteint[0]) and tonumber(fmuteint[0]) > 0 then
										windows.imgui_fm[0] = false
										sendchatarray(AshSettings.MainSettings.playcd, {
											{'/me {gender:достал|достала} планшет из кармана'},
											{'/me {gender:включил|включила} планшет'},
											{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы'},
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
			
			imgui.SetCursorPos(imgui.ImVec2(300, 5))
			imgui.BeginChild('##fmplayerinfo', imgui.ImVec2(200, 75), false)
				imgui.SetCursorPos(imgui.ImVec2(15, 15))
				imgui.BeginGroup()
				imgui.TextColoredRGB(sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', 1)
				imgui.Hint('lmb to copy name', 'ЛКМ - скопировать ник')
				if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
					local name, result = gsub(u8(sampGetPlayerNickname(fastmenuID)), '_', ' ')
					imgui.SetClipboardText(name)
				end
				imgui.TextColoredRGB('Лет в штате: '..sampGetPlayerScore(fastmenuID), 1)
				imgui.EndGroup()
			imgui.EndChild()
			
			imgui.SetCursorPos(imgui.ImVec2(300, 100))
			imgui.BeginChild('##fmchoosewindowtype', imgui.ImVec2(200, -1), false)
				imgui.SetCursorPos(imgui.ImVec2(20, 17.5))
				imgui.BeginGroup()
					for k, v in pairs(fmbuttons) do
						if AshSettings.MainSettings.myrankint >= v.rank then
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
									sobesdecline_select[0] = 0
									lastq[0] = 0
									Interview.Checking = {
										state = 0,
										pass = {
											state = 0,
											reason = 0,
										},
										mc = {
											state = 0,
											reason = 0,
										},
										licenses = {
											state = 0,
											reason = 0,
										}
									}
									Interview.additional_docs = false
									Interview.additional_reasons_config.unlockedReasons.choosed = 6
									Interview.additional_reasons = false
									Interview.stage = 1
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
)

local imgui_settings = imgui.OnFrame(
	function() return windows.imgui_settings[0] and not ChangePos end,
	function(player)
		player.HideCursor = isKeyDown(0x02)
		imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'#MainSettingsWindow', windows.imgui_settings, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.BeginGroup()
			imgui.Image(ash_image,imgui.ImVec2(198,25),imgui.ImVec2(0.25, 0.8),imgui.ImVec2(1, 0.9))
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
				imgui.Hint('lastupdate','Обновление от 28.06.2022')
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
						if AshSettings.MainSettings.fmtype == 1 then
							imgui.TextColoredRGB('/'..AshSettings.MainSettings.usefastmenucmd..' [id] - Меню взаимодействия с клиентом')
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
						if AshSettings.MainSettings.fmtype == 0 then
							imgui.TextColoredRGB('ПКМ + '..AshSettings.MainSettings.usefastmenu..' - Меню взаимодействия с клиентом')
						end
						if AshSettings.MainSettings.dofastexpel then
							imgui.TextColoredRGB('ПКМ + '..AshSettings.MainSettings.fastexpel..' - Быстрый /expel')
						end
						if AshSettings.MainSettings.dofastscreen then
							imgui.TextColoredRGB(AshSettings.MainSettings.fastscreen..' - Быстрый скриншот')
						end
						imgui.TextColoredRGB('Alt + K - Остановить отыгровку')
					imgui.EndGroup()
					imgui.Spacing()
					if imgui.Button(u8'Закрыть##команды', imgui.ImVec2(-1, 30)) then imgui.CloseCurrentPopup() end
					imgui.EndPopup()
				end
				imgui.PopStyleVar()
			imgui.EndGroup()
			imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, 6)
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
							local p = imgui.GetCursorScreenPos()
							if settingswindow[0] == k then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end

							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 10, p.y + 12), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.icon)
							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 30, p.y + 11), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.text)

							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,settingswindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton('##'..i.text, imgui.ImVec2(162,35)) then
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
								imgui.Text(u8'Меню взаимодействия')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
									imgui.Text(u8'Тип активации')
									imgui.SameLine(100)
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
									imgui.PushItemWidth(120)
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(10,10))
									if imgui.Combo('##choosefmtypecombo',usersettings.fmtype, new['const char*'][2]({u8'Клавиша',u8'Команда'}), 2) then
										AshSettings.MainSettings.fmtype = usersettings.fmtype[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									imgui.PopStyleVar()
									imgui.PopItemWidth()
								
									if AshSettings.MainSettings.fmtype == 0 then
										imgui.SameLine()
										imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
										imgui.Hint('fastmenuhint','Прицельтесь на игрока и нажмите назначенную клавишу')

										local p = imgui.GetCursorScreenPos()
										p.y = p.y - 5
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 15, p.y + 58), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 20, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 58),imgui.ImVec2(p.x + 20, p.y + 58), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.SetCursorPosX(50)

										imgui.HotKey('Меню взаимодействия', AshSettings.MainSettings, 'usefastmenu', 'E', find(AshSettings.MainSettings.usefastmenu, '+') and 150 or 75)
										imgui.SameLine()
										imgui.Text(u8'Активация')

										imgui.SetCursorPosX(50)
										if imgui.ToggleButton(u8'Создавать маркер при выделении',usersettings.createmarker) then
											if marker ~= nil then
												removeBlip(marker)
											end
											marker = nil
											oldtargettingped = 0
											AshSettings.MainSettings.createmarker = usersettings.createmarker[0]
											inicfg.save(AS_Settings,'AS Helper')
										end
									elseif AshSettings.MainSettings.fmtype == 1 then
										local p = imgui.GetCursorScreenPos()
										p.y = p.y - 5
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 15, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 20, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 26),imgui.ImVec2(p.x + 20, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.SetCursorPosX(50)
										imgui.Text(u8'/')
										imgui.SameLine(35)
										imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
										imgui.PushItemWidth(110)
										if imgui.InputText(u8'[id]##usefastmenucmdbuff',usersettings.usefastmenucmd,sizeof(usersettings.usefastmenucmd)) then
											AshSettings.MainSettings.usefastmenucmd = str(usersettings.usefastmenucmd)
											inicfg.save(AS_Settings,'AS Helper')
										end
										imgui.PopItemWidth()
									end
									
								imgui.EndGroup()
								imgui.NewLine()
								
								imgui.PushFont(font[16])
								imgui.Text(u8'Чекер заданий')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ToggleButton(u8'Чекер заданий', usersettings.tasksvisible) then
										AshSettings.TaskChecker.state = usersettings.tasksvisible[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									if AshSettings.TaskChecker.state then
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 15, p.y + 60), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 20, p.y - 3), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 60),imgui.ImVec2(p.x + 20, p.y + 60), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)

										imgui.SetCursorPosX(50)
										if imgui.ToggleButton(u8'Показывать выполненные', usersettings.completedtasksvisible) then
											AshSettings.TaskChecker.completed_tasks = usersettings.completedtasksvisible[0]
											inicfg.save(AS_Settings,'AS Helper')
										end
										imgui.SetCursorPosX(50)
										if imgui.Button(fa.ICON_FA_ARROWS_ALT..'##statsscreenpos') then
											changePosition(AshSettings.TaskChecker)
										end
										imgui.SameLine()
										imgui.Text(u8'Местоположение')
									end
								imgui.EndGroup()
								imgui.NewLine()

								imgui.PushFont(font[16])
								imgui.Text(u8'Остальное')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
								
									if imgui.ToggleButton(u8'Заменять серверные сообщения', usersettings.replacechat) then
										AshSettings.MainSettings.replacechat = usersettings.replacechat[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									
									if imgui.ToggleButton(u8'Показывать ранг перед сообщением в рации', usersettings.chatrank) then
										AshSettings.MainSettings.chatrank = usersettings.chatrank[0]
										inicfg.save(AS_Settings,'AS Helper')
									end

									if imgui.ToggleButton(u8'Показывать ранг на груди сотрудников', usersettings.bodyrank) then
										AshSettings.MainSettings.bodyrank = usersettings.bodyrank[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
								
									if imgui.ToggleButton(u8'Быстрый /time + screenshot', usersettings.dofastscreen) then
										AshSettings.MainSettings.dofastscreen = usersettings.dofastscreen[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									if AshSettings.MainSettings.dofastscreen then
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 4),imgui.ImVec2(p.x + 15, p.y + 27), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 4),imgui.ImVec2(p.x + 20, p.y - 4), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 27),imgui.ImVec2(p.x + 20, p.y + 27), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)


										imgui.SetCursorPosX(50)
										imgui.HotKey('быстрого скрина', AshSettings.MainSettings, 'fastscreen', 'F4', find(AshSettings.MainSettings.fastscreen, '+') and 150 or 75)
										imgui.SameLine()
										imgui.Text(u8'Активация')
									end
									if imgui.ToggleButton(u8'Автооткрытие дверей', usersettings.autodoor) then
										AshSettings.MainSettings.autodoor = usersettings.autodoor[0]
										autodoor:run()
										inicfg.save(AS_Settings,'AS Helper')
									end
									if imgui.ToggleButton(u8'Автоматически чинить знаки', usersettings.autorepair) then
										AshSettings.MainSettings.autorepair = usersettings.autorepair[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									imgui.SameLine()
									imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
									imgui.Text(fa.ICON_FA_INFO_CIRCLE)
									imgui.Hint('Autorepair warning', 'Не уверен, что это разрешено. Включайте на свой страх и риск!')
									imgui.SetCursorPosY(imgui.GetCursorPosY() - 1)
									if imgui.ToggleButton(u8'Скрывать интерфейс после рабочего дня', usersettings.guiinform) then
										AshSettings.MainSettings.guiinform = usersettings.guiinform[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 3 then
							imgui.SetCursorPos(imgui.ImVec2(15,15))
							imgui.BeginGroup()
								imgui.PushFont(font[16])
								imgui.Text(u8'Выбор темы')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.CircleButton('##choosestyle0', AshSettings.MainSettings.style == 0, imgui.ImVec4(1.00, 0.42, 0.00, 0.90)) then
										AshSettings.MainSettings.style = 0
										inicfg.save(AS_Settings, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()
									if imgui.CircleButton('##choosestyle3', AshSettings.MainSettings.style == 1, imgui.ImVec4(0.41, 0.19, 0.63, 0.90)) then
										AshSettings.MainSettings.style = 1
										inicfg.save(AS_Settings, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SameLine()

									local p = imgui.GetCursorScreenPos()
									p.x = p.x + 1.5
									p.y = p.y + 1.5
									imgui.GetWindowDrawList():AddImageQuad(
										rainbowcircle, 
										imgui.ImVec2(p.x + 17, p.y),
										imgui.ImVec2(p.x + 17, p.y + 17),
										imgui.ImVec2(p.x, p.y + 17),
										imgui.ImVec2(p.x, p.y),
										nil,
										nil,
										nil,
										nil,
										monetluacheck and 0xFFFFFFFF or 0x50FFFFFF
									)
									
									if not monetluacheck then
										imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 7, p.y + 2), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), '!')
									end

									if imgui.CircleButton('##choosestyle6', AshSettings.MainSettings.style == 2, imgui.GetStyle().Colors[imgui.Col.Button], nil, true) then
										if not monetluacheck then
											imgui.OpenPopup(u8'Установка билиотеки')
										end
										AshSettings.MainSettings.style = 2
										inicfg.save(AS_Settings, 'AS Helper.ini')
										checkstyle()
									end
									imgui.SetNextWindowSize(imgui.ImVec2(400, 135))
									imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(15, 15))
									if imgui.BeginPopupModal(u8'Установка билиотеки', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
										imgui.TextColoredRGB('Для работы Monet Вам требуется установить следующую библиотеку:', 1)
										imgui.TextColoredRGB('{FF0000}MoonMonet', 1)
										imgui.Spacing()
										if imgui.Button(downloading_monet and u8'Установка...' or u8'Установить', imgui.ImVec2(179, 30)) then
											if not downloading_monet then
												downloading_monet = lua_thread.create(function()
													NoErrors = true
													createDirectory(getWorkingDirectory()..'\\lib\\MoonMonet')
													wait(1000)
													thisScript():reload()
												end)
											end
										end
										imgui.SameLine()
										if imgui.Button(u8'Отмена', imgui.ImVec2(179, 30)) then
											imgui.CloseCurrentPopup()
										end
										imgui.EndPopup()
									end
									imgui.PopStyleVar()
									imgui.Hint('MoonMonetHint','MoonMonet')
								imgui.EndGroup()
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 25)
								imgui.NewLine()
								if AshSettings.MainSettings.style == 2 then
									imgui.PushFont(font[16])
									imgui.Text(u8'Цвет акцента Monet')
									imgui.PopFont()
									imgui.SetCursorPosX(25)
									imgui.BeginGroup()
										imgui.PushItemWidth(200)
										if imgui.ColorPicker3('##moonmonetcolorselect', usersettings.moonmonetcolorselect, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.PickerHueWheel + imgui.ColorEditFlags.NoSidePreview) then
											local r,g,b = usersettings.moonmonetcolorselect[0] * 255,usersettings.moonmonetcolorselect[1] * 255,usersettings.moonmonetcolorselect[2] * 255
											local argb = join_argb(255,r,g,b)
											AshSettings.MainSettings.monetstyle = argb
											inicfg.save(AS_Settings, 'AS Helper.ini')
											checkstyle()
										end
										if imgui.SliderFloat('##CHROMA', monetstylechromaselect, 0.5, 2.0, '%0.2f c.m.') then
											AshSettings.MainSettings.monetstyle_chroma = monetstylechromaselect[0]
											checkstyle()
										end
										imgui.PopItemWidth()
									imgui.EndGroup()
									imgui.NewLine()
								end
								imgui.PushFont(font[16])
								imgui.Text(u8'Дополнительно')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ColorEdit4(u8'##RSet', chatcolors.RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										AshSettings.MainSettings.RChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.RChatColor[0], chatcolors.RChatColor[1], chatcolors.RChatColor[2], chatcolors.RChatColor[3]))
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет чата организации')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##RCol',imgui.ImVec2(65,25)) then
										AshSettings.MainSettings.RChatColor = 4282626093
										chatcolors.RChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.RChatColor))
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##RTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.RChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[R] '..AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: (( Это сообщение видите только Вы! ))', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##DSet', chatcolors.DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										AshSettings.MainSettings.DChatColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.DChatColor[0], chatcolors.DChatColor[1], chatcolors.DChatColor[2], chatcolors.DChatColor[3]))
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет чата департамента')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##DCol',imgui.ImVec2(65,25)) then
										AshSettings.MainSettings.DChatColor = 4294940723
										chatcolors.DChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.DChatColor))
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##DTest',imgui.ImVec2(37,25)) then
										local result, myid = sampGetPlayerIdByCharHandle(playerPed)
										local color4 = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.DChatColor)
										local r, g, b, a = color4.x * 255, color4.y * 255, color4.z * 255, color4.w * 255
										sampAddChatMessage('[D] '..AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: Это сообщение видите только Вы!', join_argb(a, r, g, b))
									end
								
									if imgui.ColorEdit4(u8'##SSet', chatcolors.ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
										AshSettings.MainSettings.ASChatColor.color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(chatcolors.ASChatColor[0], chatcolors.ASChatColor[1], chatcolors.ASChatColor[2], chatcolors.ASChatColor[3]))
										if AshSettings.MainSettings.ASChatColor.themeBased then
											AshSettings.MainSettings.ASChatColor.themeBased = false
											usersettings.themeBased[0] = false
										end
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Цвет AS Helper в чате')
									imgui.SameLine(190)
									if imgui.Button(u8'Сбросить##SCol',imgui.ImVec2(65,25)) then
										if AshSettings.MainSettings.ASChatColor.themeBased then
											local col = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button])
											local r, g, b, a = col.x, col.y, col.z, col.w
									
											local colors = {
												[0] = 4281558783,
												[1] = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, 1.0)),
												[2] = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, 1.0))
											}
											AshSettings.MainSettings.ASChatColor.color = colors[AshSettings.MainSettings.style]
											chatcolors.ASChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color))
										else
											AshSettings.MainSettings.ASChatColor.color = 4281558783
											chatcolors.ASChatColor = vec4ToFloat4(imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color))
											inicfg.save(AS_Settings, 'AS Helper.ini')
										end
									end
									imgui.SameLine(265)
									if imgui.Button(u8'Тест##ASTest',imgui.ImVec2(37,25)) then
										ASHelperMessage('Это сообщение видите только Вы!')
									end
									local p = imgui.GetCursorScreenPos()
									imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 15, p.y + 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
									imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 20, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
									imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 20),imgui.ImVec2(p.x + 20, p.y + 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
									imgui.SetCursorPosX(50)
									if imgui.ToggleButton(u8'Подбирать цвет под выбранную тему', usersettings.themeBased) then
										AshSettings.MainSettings.ASChatColor.themeBased = usersettings.themeBased[0]
										inicfg.save(AS_Settings,'AS Helper')
										checkstyle()
									end
								imgui.EndGroup()
								imgui.Spacing()
							imgui.EndGroup()
						elseif settingswindow[0] == 2 then
							imgui.BeginChild('##checkerwindow',_,false)
							local p = imgui.GetWindowPos()
							if AshSettings.Checker.confirm then
								imgui.SetCursorPos(imgui.ImVec2(15, 15))
								imgui.PushFont(font[16])
								imgui.Text(u8'Основное')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									if imgui.ToggleButton(u8'Включить чекер', checker_variables.state) then
										AshSettings.Checker.state = checker_variables.state[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
								
									if imgui.Button(fa.ICON_FA_ARROWS_ALT..'##checkerpos') then
										if AshSettings.Checker.state then
											changePosition(AshSettings.Checker)
										else
											ASHelperMessage('Включите чекер.')
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
										AshSettings.Checker.afk_max_l = checker_variables.afk_max_l[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Hint('hint_slider_int_1', ('Младшие ранги (1 - 4)'))
									imgui.SameLine()
									if imgui.InputInt('##AFKMax_High', checker_variables.afk_max_h, 0, 0) then
										if checker_variables.afk_max_h[0] < 0 then checker_variables.afk_max_h[0] = 0 end
										if checker_variables.afk_max_h[0] > 3599 then checker_variables.afk_max_h[0] = 3599 end
										AshSettings.Checker.afk_max_h = checker_variables.afk_max_h[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Hint('hint_slider_int_2', ('Старшие ранги (5 - 10)'))
									imgui.PopItemWidth()
								
									imgui.Text(u8'Частота обновления(s):')
									imgui.SameLine(165)
								
									imgui.PushItemWidth(110)
									if imgui.DragInt('##checkerDelay', checker_variables.delay, 0.5, 3, 30, u8((checker_variables.delay[0]) .. ' секунд')) then
										if checker_variables.delay[0] < 3 then checker_variables.delay[0] = 3 end
										if checker_variables.delay[0] > 30 then checker_variables.delay[0] = 30 end
										AshSettings.Checker.delay = checker_variables.delay[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
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
										AshSettings.Checker.font_name = #str(checker_variables.font_input) > 0 and u8:decode(str(checker_variables.font_input)) or 'Arial'
										checker_variables.font = renderCreateFont(AshSettings.Checker.font_name, AshSettings.Checker.font_size, AshSettings.Checker.font_flag)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if not imgui.IsItemActive() and #str(checker_variables.font_input) == 0 then
										imgui.StrCopy(checker_variables.font_input, u8'Arial')
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Text(u8'Размер шрифта:')
									imgui.SameLine(140)
									if imgui.SliderInt('##FontSize', checker_variables.font_size, 1, 25, u8'%d') then
										if checker_variables.font_size[0] < 1 then checker_variables.font_size[0] = 1 end
										if checker_variables.font_size[0] > 25 then checker_variables.font_size[0] = 25 end
										AshSettings.Checker.font_size = checker_variables.font_size[0]
										checker_variables.font = renderCreateFont(AshSettings.Checker.font_name, AshSettings.Checker.font_size, AshSettings.Checker.font_flag)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Text(u8'Стиль шрифта:')
									imgui.SameLine(140)
									if imgui.SliderInt('##FontFlag', checker_variables.font_flag, 1, 25, u8'%d') then
										if checker_variables.font_flag[0] < 1 then checker_variables.font_flag[0] = 1 end
										if checker_variables.font_flag[0] > 25 then checker_variables.font_flag[0] = 25 end
										AshSettings.Checker.font_flag = checker_variables.font_flag[0]
										checker_variables.font = renderCreateFont(AshSettings.Checker.font_name, AshSettings.Checker.font_size, AshSettings.Checker.font_flag)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Text(u8'Расстояние строк:')
									imgui.SameLine(140)
									if imgui.SliderInt('##FontOffset', checker_variables.font_offset, 1, 30, u8'%d') then
										if checker_variables.font_offset[0] < 1 then checker_variables.font_offset[0] = 1 end
										if checker_variables.font_offset[0] > 30 then checker_variables.font_offset[0] = 30 end
										AshSettings.Checker.font_offset = checker_variables.font_offset[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.Text(u8'Непрозрачность:')
									imgui.SameLine(140)
									if imgui.SliderInt('##FontAlpha', checker_variables.font_alpha, 1, 100, u8'%d%%') then
										if checker_variables.font_alpha[0] < 1 then checker_variables.font_alpha[0] = 1 end
										if checker_variables.font_alpha[0] > 100 then checker_variables.font_alpha[0] = 100 end
										AshSettings.Checker.font_alpha = checker_variables.font_alpha[0] * 2.55
										inicfg.save(AS_Settings, 'AS Helper.ini')
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
										AshSettings.Checker.show_uniform = checker_variables.show.uniform[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
									imgui.Hint('hint_uniform', 'Показывать кто из сотрудников в форме, а кто нет\n(Аналог /members)')
									if imgui.ToggleButton(u8'Номер должности', checker_variables.show.rank) then
										AshSettings.Checker.show_rank = checker_variables.show.rank[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if imgui.ToggleButton(u8'ID Сотрудника', checker_variables.show.id) then
										AshSettings.Checker.show_id = checker_variables.show.id[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if imgui.ToggleButton(u8'Время в АФК', checker_variables.show.afk) then
										AshSettings.Checker.show_afk = checker_variables.show.afk[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if imgui.ToggleButton(u8'Кол-во выговоров', checker_variables.show.warn) then
										AshSettings.Checker.show_warn = checker_variables.show.warn[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if AshSettings.Checker.show_warn then
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 15, p.y + 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y),imgui.ImVec2(p.x + 20, p.y), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 20),imgui.ImVec2(p.x + 20, p.y + 20), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)

										imgui.SetCursorPosX(50)
										if imgui.ToggleButton(u8'Кол-во [СПЕЦ]', checker_variables.show.specwarn) then
											AshSettings.Checker.show_specwarn = checker_variables.show.specwarn[0]
											inicfg.save(AS_Settings, 'AS Helper.ini')
										end
									end
									if imgui.ToggleButton(u8'Выполненные задания', checker_variables.show.quests) then
										AshSettings.Checker.show_quests = checker_variables.show.quests[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									if imgui.ToggleButton(u8'Отображать муты', checker_variables.show.mute) then
										AshSettings.Checker.show_mute = checker_variables.show.mute[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
									imgui.Hint('hint_mute', 'У сотрудников, на которых наложен организационный мут\nбудет пометка Muted в списке')
									if imgui.ToggleButton(u8'Отображать деморган', checker_variables.show.demorgan) then
										AshSettings.Checker.show_demorgan = checker_variables.show.demorgan[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
									imgui.Hint('hint_demorgan', 'У сотрудников, на которых наложен организационный мут\nбудет пометка Demorgan в списке')
									if imgui.ToggleButton(u8'Сотрудники рядом', checker_variables.show.near) then
										AshSettings.Checker.show_near = checker_variables.show.near[0]
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
									imgui.Hint('hint_near', 'Сотрудники находящиеся в вашей зоне прорисовки\nбудут отмечатся меткой [N] в списке')
								imgui.EndGroup()
								
								imgui.SameLine(230, 25)
								imgui.BeginGroup()
									local col = checker_variables.col
									imgui.SetCursorPosX(240)
									imgui.PushFont(font[16])
									imgui.Text(u8'Цвета')
									imgui.PopFont()
									if imgui.ColorEdit4('##TitleColor', col.title, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
										local c = imgui.ImVec4(col.title[0],  col.title[1], col.title[2],  col.title[3])
										AshSettings.Checker.col_title = imgui.ColorConvertFloat4ToARGB(c)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Заголовок')
									if imgui.ColorEdit4('##DefaultColor', col.default, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
										local c = imgui.ImVec4(col.default[0], col.default[1], col.default[2], col.default[3]) 
										AshSettings.Checker.col_default = imgui.ColorConvertFloat4ToARGB(c)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Стандартный')
									if imgui.ColorEdit4('##NoWorkColor', col.no_work, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
										local c = imgui.ImVec4(col.no_work[0], col.no_work[1], col.no_work[2], col.no_work[3]) 
										AshSettings.Checker.col_no_work = imgui.ColorConvertFloat4ToARGB(c)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Без формы')
									if imgui.ColorEdit4('##AFKMaxColor', col.afk_max, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
										local c = imgui.ImVec4(col.afk_max[0], col.afk_max[1], col.afk_max[2], col.afk_max[3]) 
										AshSettings.Checker.col_afk_max = imgui.ColorConvertFloat4ToARGB(c)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'AFK Max')
									if imgui.ColorEdit4('##NoteColor', col.note, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha) then
										local c = imgui.ImVec4(col.note[0], col.note[1], col.note[2], col.note[3]) 
										AshSettings.Checker.col_note = imgui.ColorConvertFloat4ToARGB(c)
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									imgui.Text(u8'Заметки')
								imgui.EndGroup()
								imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 320, p.y + 230), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), u8'Идея: Cosmo')
							else
								imgui.SetCursorPos(imgui.ImVec2(25, 20))
								imgui.BeginGroup()
									imgui.PushFont(font[25])
									imgui.TextColoredRGB('Осторожно!', 1)
									imgui.PopFont()
									imgui.Spacing()
									imgui.TextColoredRGB('На некоторых серверах Arizona RP чекеры игроков\nзапрещены, именно поэтому перед его включением я\nнастоятельно прошу вас внимательно ознакомиться с\nправилами вашего сервера, чтобы обезопасить себя.\nСпасибо за понимание!', 1)
									imgui.Spacing()
									if imgui.Button(u8'Начать использование', imgui.ImVec2(175, 50)) then
										AshSettings.Checker.state = true
										AshSettings.Checker.confirm = true
										inicfg.save(AS_Settings, 'AS Helper.ini')
									end
									imgui.SameLine()
									if AshSettings.Checker.state then
										if imgui.Button(u8'Отключить чекер', imgui.ImVec2(175, 50)) then
											AshSettings.Checker.state = false
											inicfg.save(AS_Settings, 'AS Helper.ini')
										end
									else
										imgui.LockedButton(u8'Отключить чекер', imgui.ImVec2(175, 50))
									end
								imgui.EndGroup()
							end
							imgui.Spacing()

						imgui.EndChild()
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
					imgui.Text(u8'Организация')
					imgui.PopFont()
				
					imgui.SetCursorPos(imgui.ImVec2(15,65))
					imgui.BeginGroup()
						imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.05,0.5))
						for k, i in pairs(additionalbuttons) do
							local clr = imgui.GetStyle().Colors[imgui.Col.Text].x
							local p = imgui.GetCursorScreenPos()
							if additionalwindow[0] == k then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end

							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 10, p.y + 12), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.icon)
							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 30, p.y + 11), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.text)

							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,additionalwindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton('##'..i.text, imgui.ImVec2(186,35)) then
								if additionalwindow[0] ~= k then
									additionalwindow[0] = k
									alpha[0] = clock()
								end
							end
							imgui.PopStyleColor(3)
						end
						imgui.PopStyleVar()
					imgui.EndGroup()
					
					imgui.SetCursorPos(imgui.ImVec2(210, 0))
					imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate(1 / (alphaAnimTime / (clock() - alpha[0]))))
					if additionalwindow[0] == 3 then
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
									imgui.SetCursorPos(imgui.ImVec2(70, 20))
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
								if imgui.Button(fa.ICON_FA_PLUS_CIRCLE..u8' Создать##zametkas', imgui.ImVec2(82, 23)) then
									zametkaredact_number = 0
									imgui.StrCopy(zametkisettings.zametkacmd, '')
									imgui.StrCopy(zametkisettings.zametkaname, '')
									imgui.StrCopy(zametkisettings.zametkatext, '')
									zametkisettings.zametkabtn = ''
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_PEN..u8' Изменить', imgui.ImVec2(82, 23)) then
									if zametki[now_zametka[0]] then
										zametkaredact_number = now_zametka[0]
										imgui.StrCopy(zametkisettings.zametkacmd, u8(zametki[now_zametka[0]].cmd))
										imgui.StrCopy(zametkisettings.zametkaname, u8(zametki[now_zametka[0]].name))
										imgui.StrCopy(zametkisettings.zametkatext, u8(zametki[now_zametka[0]].text))
										zametkisettings.zametkabtn = zametki[now_zametka[0]].button
									end
								end
								imgui.SameLine()
								if imgui.Button(fa.ICON_FA_TRASH..u8' Удалить', imgui.ImVec2(82, 23)) then
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
					elseif additionalwindow[0] == 1 then
						imgui.BeginChild('##otigrovkiwindow',_,false)
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
											AshSettings.MainSettings.myname = str(usersettings.myname)
											inicfg.save(AS_Settings,'AS Helper')
										end
										imgui.SameLine()
										imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
										imgui.Hint('NoNickNickFromTab','Если не будет указано, то имя будет браться из ника')
									
										if imgui.InputText(u8'##myaccentintroleplay', usersettings.myaccent, sizeof(usersettings.myaccent)) then
											AshSettings.MainSettings.myaccent = str(usersettings.myaccent)
											inicfg.save(AS_Settings,'AS Helper')
										end
									
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 23), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[AshSettings.MainSettings.gender == 0 and imgui.Col.ButtonHovered or imgui.Col.FrameBg]), 5, imgui.DrawCornerFlags.Left)
										imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0,0,0,0))
										if imgui.Button(u8'Мужской', imgui.ImVec2(60, 23)) then
											AshSettings.MainSettings.gender = 0
										end
										imgui.PopStyleColor()
										imgui.SameLine(nil, 0)
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + 60, p.y + 23), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[AshSettings.MainSettings.gender == 1 and imgui.Col.ButtonHovered or imgui.Col.FrameBg]), 5, imgui.DrawCornerFlags.Right)
										imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0,0,0,0))
										if imgui.Button(u8'Женский', imgui.ImVec2(60, 23)) then
											AshSettings.MainSettings.gender = 1
										end
										imgui.PopStyleColor()
									
										if imgui.Button(u8(AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint]..' ('..u8(AshSettings.MainSettings.myrankint)..')'), imgui.ImVec2(120, 23)) then
											getmyrank = true
											sampSendChat('/stats')
										end
										imgui.Hint('clicktoupdaterang','Нажмите, чтобы перепроверить')
									imgui.EndGroup()
									imgui.PopItemWidth()
								imgui.EndGroup()
								imgui.NewLine()
								imgui.PushFont(font[16])
								imgui.Text(u8'Отыгровки')
								imgui.PopFont()
								imgui.SetCursorPosX(25)
								imgui.BeginGroup()
									imgui.Text(u8'Задержка между сообщениями:')
									imgui.PushItemWidth(200)
									if imgui.SliderFloat('##playcd', usersettings.playcd, 0.5, 10.0, '%.1f c.') then
										if usersettings.playcd[0] < 0.5 then usersettings.playcd[0] = 0.5 end
										if usersettings.playcd[0] > 10.0 then usersettings.playcd[0] = 10.0 end
										AshSettings.MainSettings.playcd = usersettings.playcd[0] * 1000
										inicfg.save(AS_Settings,'AS Helper')
									end
									imgui.PopItemWidth()
									imgui.Spacing()
									
									if imgui.ToggleButton(u8'Начинать отыгровки после серверных команд', usersettings.dorponcmd) then
										AshSettings.MainSettings.dorponcmd = usersettings.dorponcmd[0]
										inicfg.save(AS_Settings,'AS Helper')
									end

									if imgui.ToggleButton(u8'Автоматически проверять мед. карту', usersettings.autocheckmc) then
										AshSettings.MainSettings.autocheckmc = usersettings.autocheckmc[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									
									if imgui.ToggleButton(u8'Автоотыгровка дубинки', usersettings.playdubinka) then
										AshSettings.MainSettings.playdubinka = usersettings.playdubinka[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									
									if imgui.ToggleButton(u8'Заменять \'Автошкола г. Сан-Фиерро\'', usersettings.replaceash) then
										AshSettings.MainSettings.replaceash = usersettings.replaceash[0]
										inicfg.save(AS_Settings,'AS Helper')
									end
									
									if AshSettings.MainSettings.replaceash then
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 15, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 20, p.y - 3), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 26),imgui.ImVec2(p.x + 20, p.y + 26), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)

										imgui.SetCursorPosX(50)
										imgui.PushItemWidth(75)
										if imgui.InputText(u8'##replaceashtobuff',usersettings.replaceashto,sizeof(usersettings.replaceashto)) then
											AshSettings.MainSettings.replaceashto = u8:decode(str(usersettings.replaceashto))
											inicfg.save(AS_Settings,'AS Helper')
										end
										imgui.PopItemWidth()
										imgui.SameLine()
										imgui.Text(u8'Шаблон замены')
									end

									if imgui.ToggleButton(u8'Быстрый expel', usersettings.dofastexpel) then
										AshSettings.MainSettings.dofastexpel = usersettings.dofastexpel[0]
										inicfg.save(AS_Settings,'AS Helper')
									end

									if AshSettings.MainSettings.dofastexpel then
										local p = imgui.GetCursorScreenPos()
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 15, p.y + 56), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y - 3),imgui.ImVec2(p.x + 20, p.y - 3), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)
										imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x + 15, p.y + 56),imgui.ImVec2(p.x + 20, p.y + 56), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 1.5)


										imgui.SetCursorPosX(50)
										imgui.HotKey('быстрый /expel', AshSettings.MainSettings, 'fastexpel', 'G', find(AshSettings.MainSettings.fastexpel, '+') and 150 or 75)
										imgui.SameLine()
										imgui.Text(u8'Активация')

										imgui.SetCursorPosX(50)
										imgui.PushItemWidth(75)
										if imgui.InputText(u8'##expelreasonbuff',usersettings.expelreason,sizeof(usersettings.expelreason)) then
											AshSettings.MainSettings.expelreason = u8:decode(str(usersettings.expelreason))
											inicfg.save(AS_Settings,'AS Helper')
										end
										imgui.PopItemWidth()
										imgui.SameLine()
										imgui.Text(u8'Причина (по умолчанию)')
									end
								imgui.EndGroup()						
							imgui.EndGroup()
							imgui.Spacing()
						imgui.EndChild()
					elseif additionalwindow[0] == 2 then
						imgui.BeginChild('##licenses',_,false)
							imgui.SetCursorPos(imgui.ImVec2(0, 10))
							imgui.BeginGroup()
								local getAllMCValues = function()
									for k, v in pairs(AshSettings.ScannedVariables.PriceList) do
										if v.medcard then
											return true
										end
									end
									return false
								end

								imgui.Columns(6)
									imgui.Text(u8'Лицензия')
									imgui.SetColumnWidth(-1, 70)
									imgui.NextColumn()
									imgui.Text(fa.ICON_FA_LOCK)
									imgui.Hint('minrank', 'Требуемый ранг для продажи этой лицензии')
									imgui.SetColumnWidth(-1, 35)
									imgui.NextColumn()
									imgui.Text(u8'1 месяц')
									imgui.SetColumnWidth(-1, 80)
									imgui.NextColumn()
									imgui.Text(u8'2 месяца')
									imgui.SetColumnWidth(-1, 80)
									imgui.NextColumn()
									imgui.Text(u8'3 месяца')
									imgui.SetColumnWidth(-1, 80)
									imgui.NextColumn()
									local cur = imgui.GetCursorPos()
									if imgui.InvisibleButton(i..'##doyouneedallmc', imgui.ImVec2(10,15)) then
										if getAllMCValues() then
											for k, v in pairs(AshSettings.ScannedVariables.PriceList) do
												AshSettings.ScannedVariables.PriceList[k].medcard = false
											end
										else
											for k, v in pairs(AshSettings.ScannedVariables.PriceList) do
												AshSettings.ScannedVariables.PriceList[k].medcard = true
											end
										end
										inicfg.save()
									end
									imgui.SetCursorPos(cur)
									imgui.Hint('doyouneedmc', 'Требовать мед. карту для этой лицензии')
									imgui.TextColored(getAllMCValues() and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_FILE_ALT)
									imgui.SetColumnWidth(-1, 80)
									imgui.NextColumn()
								imgui.Columns(1)
								imgui.Separator()
								imgui.SetCursorPosY(40)
								imgui.Columns(6)
									for i = 1, #AshSettings.ScannedVariables.PriceList do
										local lic, rank, prices, medcard = licenses[i].text, AshSettings.ScannedVariables.PriceList[i].rank, AshSettings.ScannedVariables.PriceList[i].price, AshSettings.ScannedVariables.PriceList[i].medcard
										imgui.Text(u8(lic))
										imgui.NextColumn()
										
										imgui.Text(u8(rank)..'+')
										imgui.NextColumn()
										
										for i = 1, 3 do
											if prices[i] ~= nil then imgui.Text(string.separate(tostring(prices[i]))..'$') else imgui.Text(u8'N/A') end
											imgui.NextColumn()
										end

										local cur = imgui.GetCursorPos()
										if imgui.InvisibleButton(i..'##doyouneedmc', imgui.ImVec2(10,15)) then
											AshSettings.ScannedVariables.PriceList[i].medcard = not AshSettings.ScannedVariables.PriceList[i].medcard
											inicfg.save()
										end
										imgui.SetCursorPos(cur)
										imgui.TextColored(medcard and imgui.GetStyle().Colors[imgui.Col.Text] or imgui.GetStyle().Colors[imgui.Col.TextDisabled], fa.ICON_FA_FILE_ALT)
										imgui.NextColumn()
									end
								imgui.Columns(1)
							imgui.EndGroup()
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
							local p = imgui.GetCursorScreenPos()
							if infowindow[0] == k then
								imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(p.x, p.y + 10),imgui.ImVec2(p.x + 3, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Border]), 5, imgui.DrawCornerFlags.Right)
							end

							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 10, p.y + 12), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.icon)
							imgui.GetWindowDrawList():AddText(imgui.ImVec2(p.x + 30, p.y + 11), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), i.text)

							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(clr,clr,clr,infowindow[0] == k and 0.1 or 0))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(clr,clr,clr,0.15))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(clr,clr,clr,0.1))
							if imgui.AnimButton('##'..i.text, imgui.ImVec2(186,35)) then
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
									if imgui.Button(u8'Обновить '..fa.ICON_FA_ARROW_ALT_CIRCLE_DOWN) then
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
										checkUpdates('https://raw.githubusercontent.com/Just-Mini/ASHelper/main/Jsons/update.json', true)
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
										checkUpdates('https://raw.githubusercontent.com/Just-Mini/ASHelper/main/Jsons/update.json', true)
									end
								imgui.EndGroup()
							end
							imgui.NewLine()
							imgui.PushFont(font[15])
							imgui.Text(u8'Параметры')
							imgui.PopFont()
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Авто-проверка обновлений', auto_update_box) then
								AshSettings.MainSettings.autoupdate = auto_update_box[0]
								inicfg.save(AS_Settings,'AS Helper')
							end
							imgui.SetCursorPosX(30)
							if imgui.ToggleButton(u8'Получать бета релизы', get_beta_upd_box) then
								AshSettings.MainSettings.getbetaupd = get_beta_upd_box[0]
								checkUpdates('https://raw.githubusercontent.com/Just-Mini/ASHelper/main/Jsons/update.json')
								inicfg.save(AS_Settings,'AS Helper')
							end
							imgui.SameLine()
							imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
							imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
							imgui.Hint('betareleaseshint', 'После включения данной функции Вы будете получать\nобновления раньше других людей для тестирования и\nсообщения о багах разработчику.\n{FF1010}Работа этих версий не будет гарантирована.')
							imgui.SetCursorPosY(imgui.GetCursorPosY() - 1)
						imgui.EndGroup()
					elseif infowindow[0] == 2 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
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
							imgui.SetCursorPos(imgui.ImVec2(imgui.GetCursorPosX() + 190, imgui.GetCursorPosY() - 25))
							if imgui.Button('BTC') then
								imgui.SetClipboardText('bc1q9s2p2y475gfhqcfch7m9decs8e83aq5pc8kcv7')
								ASHelperMessage('Адрес Bitcoin кошелька был\nскопирован в буфер обмена')
								thanksAlpha[0] = clock()
							end
							imgui.SameLine()
							if imgui.Button('ETH') then
								imgui.SetClipboardText('0x512A5DD70fcB8b765CDA44faf53c67E66fc49b4c')
								ASHelperMessage('Адрес Ethereum кошелька был\nскопирован в буфер обмена')
								thanksAlpha[0] = clock()
							end
							imgui.SameLine()
							if imgui.Button('SOL') then
								imgui.SetClipboardText('2Jc1BRPMZbm3KYC7WdMC6toE625hDcV7qAbYCuWeYDt2')
								ASHelperMessage('Адрес Solana кошелька был\nскопирован в буфер обмена')
								thanksAlpha[0] = clock()
							end

							imgui.PushFont(font[25])
							local p = imgui.GetCursorScreenPos()
							imgui.GetWindowDrawList():AddText(
								imgui.ImVec2(p.x + 150, p.y),
								imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0, 0, ImSaturate(1.5 - 1 / (1 / (clock() - thanksAlpha[0]))))),
								fa.ICON_FA_HEART
							)
							imgui.PopFont()
							
						imgui.EndGroup()
					elseif infowindow[0] == 3 then
						imgui.SetCursorPos(imgui.ImVec2(15,15))
						imgui.BeginGroup()
							imgui.PushFont(font[16])
							imgui.TextColoredRGB('autoschool/helper',1)
							imgui.PopFont()
							imgui.TextColoredRGB('Версия скрипта - {MC}'..thisScript().version)
							if imgui.Button(u8'Список изменений') then
								windows.imgui_changelog[0] = true
							end
							imgui.Link('https://www.blast.hk/threads/87533/', u8'Тема на Blast Hack')
							imgui.SameLine(nil, 0)
							imgui.Text(u8'; ')
							imgui.SameLine(nil, 0)
							imgui.Link('https://github.com/Just-Mini/ASHelper', u8'репозиторий на GitHub')
							imgui.SameLine(nil, 0)
							imgui.Text(u8'; ')
							imgui.SameLine(nil, 0)
							if imgui.Link(nil, u8'ссылка на донат') then
								infowindow[0] = 2
							end
							imgui.Separator()
							imgui.TextWrapped(u8[[
	* autoschool/helper - удобный помощник, который облегчит Вам работу в Автошколе. Скрипт был разработан специально для проекта Arizona RP. Скрипт имеет открытый код для ознакомления, любое выставление скрипта без указания авторства запрещено! Обновления скрипта происходят безопасно для Вас, автообновления нет, установку должны подтверждать Вы.

	* Меню взаимодействия - Прицелившись на игрока с помощью ПКМ и нажав кнопку E (по умолчанию), откроется Меню взаимодействия. В данном меню есть все нужные функции, а именно: приветствие, озвучивание прайс листа, продажа лицензий, возможность выгнать человека из автошколы, приглашение в организацию, увольнение из организации, изменение должности, занесение в ЧС, удаление из ЧС, выдача выговоров, удаление выговоров, выдача организационного мута, удаление организационного мута, автоматизированное проведение собеседования со всеми нужными отыгровками.

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
		player.HideCursor = isKeyDown(0x02)
		imgui.SetNextWindowSize(imgui.ImVec2(650, 370), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Биндер', windows.imgui_binder, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
		imgui.Image(ash_image,imgui.ImVec2(202,25),imgui.ImVec2(0.25, 0.4),imgui.ImVec2(1, 0.5))
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
		imgui.BeginChild('ChildWindow',imgui.ImVec2(175,270), true, imgui.WindowFlags.NoScrollbar)
		imgui.SetCursorPosY(7.5)
		for key, value in pairs(AshSettings.Binder.BindsName) do
			imgui.SetCursorPosX(7.5)
			if imgui.Button(u8(AshSettings.Binder.BindsName[key]..'##'..key),imgui.ImVec2(160,30)) then
				choosedslot = key
				imgui.StrCopy(bindersettings.binderbuff, gsub(u8(AshSettings.Binder.BindsAction[key]), '~', '\n' ) or '')
				imgui.StrCopy(bindersettings.bindername, u8(AshSettings.Binder.BindsName[key] or ''))
				imgui.StrCopy(bindersettings.bindercmd, u8(AshSettings.Binder.BindsCmd[key] or ''))
				imgui.StrCopy(bindersettings.binderdelay, u8(AshSettings.Binder.BindsDelay[key] or ''))
				bindersettings.bindertype[0] = AshSettings.Binder.BindsType[key] or 0
				bindersettings.binderbtn = AshSettings.Binder.BindsKeys[key] or ''
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
						for key, value in pairs(AshSettings.Binder.BindsName) do
							if u8:decode(str(bindersettings.bindername)) == tostring(value) then
								sampUnregisterChatCommand(AshSettings.Binder.BindsCmd[key])
								kei = key
							end
						end
						local refresh_text = gsub(u8:decode(str(bindersettings.binderbuff)), '\n', '~')
						if kei ~= nil then
							AshSettings.Binder.BindsName[kei] = u8:decode(str(bindersettings.bindername))
							AshSettings.Binder.BindsDelay[kei] = str(bindersettings.binderdelay)
							AshSettings.Binder.BindsAction[kei] = refresh_text
							AshSettings.Binder.BindsType[kei]= bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								AshSettings.Binder.BindsCmd[kei] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								AshSettings.Binder.BindsKeys[kei] = bindersettings.binderbtn
							end
							if inicfg.save(AS_Settings, 'AS Helper') then
								ASHelperMessage('Бинд успешно сохранён!')
							end
						else
							AshSettings.Binder.BindsName[#AshSettings.Binder.BindsName + 1] = u8:decode(str(bindersettings.bindername))
							AshSettings.Binder.BindsDelay[#AshSettings.Binder.BindsDelay + 1] = str(bindersettings.binderdelay)
							AshSettings.Binder.BindsAction[#AshSettings.Binder.BindsAction + 1] = refresh_text
							AshSettings.Binder.BindsType[#AshSettings.Binder.BindsType + 1] = bindersettings.bindertype[0]
							if bindersettings.bindertype[0] == 0 then
								AshSettings.Binder.BindsCmd[#AshSettings.Binder.BindsCmd + 1] = u8:decode(str(bindersettings.bindercmd))
							elseif bindersettings.bindertype[0] == 1 then
								AshSettings.Binder.BindsKeys[#AshSettings.Binder.BindsKeys + 1] = bindersettings.binderbtn
							end
							if inicfg.save(AS_Settings, 'AS Helper') then
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
			imgui.SetCursorPos(imgui.ImVec2(255,180))
			imgui.Text(u8'Откройте бинд или создайте новый для редактирования.')
		end
		imgui.SetCursorPos(imgui.ImVec2(14, 330))
		if imgui.Button(u8'Создать',imgui.ImVec2(82,30)) then
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
					for key, value in pairs(AshSettings.Binder.BindsName) do
						local value = tostring(value)
						if u8:decode(str(bindersettings.bindername)) == AshSettings.Binder.BindsName[key] then
							sampUnregisterChatCommand(AshSettings.Binder.BindsCmd[key])
							table.remove(AshSettings.Binder.BindsName,key)
							table.remove(AshSettings.Binder.BindsKeys,key)
							table.remove(AshSettings.Binder.BindsAction,key)
							table.remove(AshSettings.Binder.BindsCmd,key)
							table.remove(AshSettings.Binder.BindsDelay,key)
							table.remove(AshSettings.Binder.BindsType,key)
							if inicfg.save(AS_Settings,'AS Helper') then
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
		player.HideCursor = isKeyDown(0x02)
		imgui.SetNextWindowSize(imgui.ImVec2(435, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Лекции', windows.imgui_lect, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
		imgui.Image(ash_image,imgui.ImVec2(199,25),imgui.ImVec2(0.25, 0.6),imgui.ImVec2(1, 0.7))
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
			AshSettings.MainSettings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(AS_Settings,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/s'), lectionsettings.lection_type, 4) then
			AshSettings.MainSettings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(AS_Settings,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/r'), lectionsettings.lection_type, 2) then
			AshSettings.MainSettings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(AS_Settings,'AS Helper')
		end
		imgui.SameLine()
		if imgui.RadioButtonIntPtr(u8('/rb'), lectionsettings.lection_type, 3) then
			AshSettings.MainSettings.lection_type = lectionsettings.lection_type[0]
			inicfg.save(AS_Settings,'AS Helper')
		end
		imgui.SameLine()
		imgui.SetCursorPosX(245)
		imgui.PushItemWidth(50)
		if imgui.DragInt('##lectionsettings.lection_delay', lectionsettings.lection_delay, 0.1, 1, 30, u8('%d с.')) then
			if lectionsettings.lection_delay[0] < 1 then lectionsettings.lection_delay[0] = 1 end
			if lectionsettings.lection_delay[0] > 30 then lectionsettings.lection_delay[0] = 30 end
			AshSettings.MainSettings.lection_delay = lectionsettings.lection_delay[0]
			inicfg.save(AS_Settings,'AS Helper')
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
		player.HideCursor = isKeyDown(0x02)
		imgui.SetNextWindowSize(imgui.ImVec2(700, 365), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'#depart', windows.imgui_depart, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.Image(ash_image,imgui.ImVec2(266,25),imgui.ImVec2(0, 0),imgui.ImVec2(1, 0.1))
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
				AshSettings.MainSettings.astag = u8:decode(str(departsettings.myorgname))
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
	function() return windows.imgui_changelog[0] and #windows.imgui_first_launch == 0 end,
	function(player)
		player.HideCursor = isKeyDown(0x02)
		imgui.SetNextWindowSize(imgui.ImVec2(850, 600), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin(u8'##changelog', windows.imgui_changelog, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.SetCursorPos(imgui.ImVec2(15,15))
			imgui.Image(ash_image,imgui.ImVec2(238,25),imgui.ImVec2(0.10, 0.201),imgui.ImVec2(1, 0.3))
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
								imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
								imgui.Text(fa.ICON_FA_QUESTION_CIRCLE)
								imgui.SetCursorPosY(imgui.GetCursorPosY() - 1)
								imgui.Hint(line,text)
							else
								imgui.TextWrapped(u8(' - '..line))
							end
						end
						imgui.PopFont()
						if changelog.versions[i].patches then
							imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
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

local imgui_first_launch = imgui.OnFrame(
	function() return #windows.imgui_first_launch > 0 and not ChangePos end,
	function(player)
		imgui.SetNextWindowSize(imgui.ImVec2(400, -1), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenSizeX * 0.5 , ScreenSizeY * 0.5),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Замена конфига##config_replace', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
			imgui.PushFont(font[16])
				imgui.TextColoredRGB('{MC}autoschool/launched', 0)
			imgui.PopFont()

			for k, v in pairs(windows.imgui_first_launch) do
				if v == 1 then
					imgui.Separator()
					imgui.PushFont(font[16])
						imgui.TextColoredRGB('Замена конфига', 0)
					imgui.PopFont()
					imgui.TextColoredRGB('В вашей папке с игрой был найден старый файл конфига AS Helper.\nВы хотите перенести все настройки в новый файл?', 0)
					if imgui.Button(u8'Перенести настройки', imgui.ImVec2(179, 35)) then
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
								fmstyle = 1,
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
								autodoor = true,
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
								mechprice = 450000,
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
								taxi = 0,
								mech = 0
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
								posX = -100,
								posY = -100,
						
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
								show_quests = false,
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
						configuration.main_settings.changelog = true
						if configuration.main_settings.ASChatColor then
							AshSettings.MainSettings.ASChatColor.color = configuration.main_settings.ASChatColor
							AshSettings.MainSettings.ASChatColor.themeBased = configuration.main_settings.ASChatColor == 4281558783 and true or false
							configuration.main_settings.ASChatColor = nil
						end
						for k, v in pairs(AshSettings.MainSettings) do
							if configuration.main_settings[k] ~= nil then
								AshSettings.MainSettings[k] = configuration.main_settings[k]
							end
						end
						for k, v in pairs(AshSettings.ScannedVariables.RankNames) do
							if configuration.RankNames[k] ~= nil then
								AshSettings.ScannedVariables.RankNames[k] = configuration.RankNames[k]
							end
						end
						for k, v in pairs(AshSettings.Checker) do
							if configuration.Checker[k] ~= nil then
								AshSettings.Checker[k] = configuration.Checker[k]
							end
						end
						AshSettings.Checker_Notes = {}
						for k, v in pairs(configuration.Checker_Notes) do
							AshSettings.Checker.Notes[k] = v
						end

						AshSettings.Interview.pass.state = configuration.sobes_settings.pass
						AshSettings.Interview.mc.state = configuration.sobes_settings.medcard
						AshSettings.Interview.licenses.state = configuration.sobes_settings.licenses

						AshSettings.Binder.BindsName = {}
						AshSettings.Binder.BindsDelay = {}
						AshSettings.Binder.BindsType = {}
						AshSettings.Binder.BindsAction = {}
						AshSettings.Binder.BindsCmd = {}
						AshSettings.Binder.BindsKeys = {}
						for k, v in pairs(configuration.BindsName) do
							AshSettings.Binder.BindsName[k] = v
						end
						for k, v in pairs(configuration.BindsDelay) do
							AshSettings.Binder.BindsDelay[k] = v
						end
						for k, v in pairs(configuration.BindsType) do
							AshSettings.Binder.BindsType[k] = v
						end
						for k, v in pairs(configuration.BindsAction) do
							AshSettings.Binder.BindsAction[k] = v
						end
						for k, v in pairs(configuration.BindsCmd) do
							AshSettings.Binder.BindsCmd[k] = v
						end
						for k, v in pairs(configuration.BindsKeys) do
							AshSettings.Binder.BindsKeys[k] = v
						end
						os.remove(getWorkingDirectory()..'\\config\\AS Helper.ini')
						AshSettings()
						NoErrors = true
						thisScript():reload()
					end
					imgui.SameLine()
					if imgui.Button(u8'Восстановить по умолчанию', imgui.ImVec2(179, 35)) then
						os.remove(getWorkingDirectory()..'\\config\\AS Helper.ini')
						AshSettings()
						NoErrors = true
						thisScript():reload()
					end
				end
				if v == 2 then
					if (AshSettings.Checker.posX ~= -100 and not ChangePos) or not AshSettings.Checker.state then
						table.remove(windows.imgui_first_launch, k)
					end

					imgui.Separator()
					imgui.PushFont(font[16])
						imgui.TextColoredRGB('Чекер сотрудников', 0)
					imgui.PopFont()
					imgui.TextColoredRGB('Местоположение чекера сотрудников не установлено. Установите\nего или отключите чекер', 0)
					if imgui.Button(u8'Использовать рекомендованное##checkersetplace', imgui.ImVec2(200, 35)) then
						AshSettings.Checker.align = 0
						AshSettings.Checker.posX = select(1, getScreenResolution()) * 0.02
						AshSettings.Checker.posY = select(2, getScreenResolution()) * 0.46
					end
					imgui.SameLine()
					if imgui.Button(u8'Изменить##checkersetplace', imgui.ImVec2(73, 35)) then
						changePosition(AshSettings.Checker)
					end
					imgui.SameLine()
					if imgui.Button(u8'Отключить##checkersetplace', imgui.ImVec2(73, 35)) then
						AshSettings.Checker.state = false
						inicfg.save()
					end
				end
				if v == 3 then
					if (AshSettings.TaskChecker.posX ~= -100 and not ChangePos) or not AshSettings.TaskChecker.state then
						table.remove(windows.imgui_first_launch, k)
					end

					imgui.Separator()
					imgui.PushFont(font[16])
						imgui.TextColoredRGB('Чекер заданий', 0)
					imgui.PopFont()
					imgui.TextColoredRGB('Местоположение чекера заданий не установлено. Установите его\nили отключите чекер', 0)
					if imgui.Button(u8'Использовать рекомендованное##taskcheckersetplace', imgui.ImVec2(200, 35)) then
						AshSettings.TaskChecker.align = 2
						AshSettings.TaskChecker.posX = select(1, getScreenResolution()) * 0.98
						AshSettings.TaskChecker.posY = select(2, getScreenResolution()) * 0.23
					end
					imgui.SameLine()
					if imgui.Button(u8'Изменить##taskcheckersetplace', imgui.ImVec2(73, 35)) then
						changePosition(AshSettings.TaskChecker)
					end
					imgui.SameLine()
					if imgui.Button(u8'Отключить##taskcheckersetplace', imgui.ImVec2(73, 35)) then
						AshSettings.TaskChecker.state = false
						inicfg.save()
					end
				end
			end

			
		imgui.End()
	end
)

local imgui_tasks = imgui.OnFrame(
	function() return AshSettings.TaskChecker.state and (AshSettings.MainSettings.guiinform ~= true and true or isPlayerInForm()) end,
	function(player)
		player.HideCursor = true
		imgui.SetNextWindowSize(imgui.ImVec2(-1, -1), imgui.Cond.Always)
		imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(1, 1, 1, 0))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0.6))
		imgui.Begin(u8'Задания  ##tasks',_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoInputs)

		local dl = imgui.GetWindowDrawList()

		local ch = task_checker_variables
		local cfgch = AshSettings.TaskChecker
		
		local offset = cfgch.font_offset
		
		local max_size_x = 0

		for k, task in ipairs(ch.tasks) do
			local size_x = imgui.CalcTextSize(u8(task.text)).x
			if size_x > max_size_x and task.completed == 0 then max_size_x = size_x end
		end

		imgui.SetWindowPosVec2(imgui.ImVec2(cfgch.align == 0 and cfgch.posX or cfgch.align == 1 and cfgch.posX - imgui.GetWindowWidth() / 2 or cfgch.posX - imgui.GetWindowWidth(), cfgch.posY))
		
		local completed_tasks = {}

		imgui.PushFont(font[16])
		imgui.TextColoredRGB('Задания ['..ch.tasks.completed..'/'..#ch.tasks..']', 0)
		imgui.PopFont()

		if ch.is_upgrade == 1 then
			imgui.Text(u8'Всё выполнено!')
		elseif ch.is_upgrade == 2 then
			imgui.Text(u8'Откройте вашу трудовую книжку [/wbook]')
			imgui.Text(u8'В дальнейшем писать не потребуется')
		end

		for k, task in ipairs(ch.tasks) do
			local p = imgui.GetCursorScreenPos()

			local text = task.text
			local progress = task.progress
			local max = task.max
			local completed = task.completed

			if completed == 1 then
				completed_tasks[#completed_tasks + 1] = task
			else
				imgui.Spacing()
				imgui.Text(u8(text))
				imgui.SameLine(max_size_x + 30)
				imgui.Text(progress..'/'..max)

				local scale = progress/max

				dl:AddLine(imgui.ImVec2(p.x, p.y + 25), imgui.ImVec2(p.x + max_size_x, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled]), 2)
				dl:AddLine(imgui.ImVec2(p.x, p.y + 25), imgui.ImVec2(p.x + max_size_x * scale, p.y + 25), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]), 2)
			end
		end

		if AshSettings.TaskChecker.completed_tasks then
			imgui.NewLine()
	
			for k, task in ipairs(completed_tasks) do
				local p = imgui.GetCursorScreenPos()
	
	
				local color = imgui.GetStyle().Colors[imgui.Col.Text]
				local r, g, b, a = color.x, color.y, color.z, color.w
	
				local render_color = imgui.ImVec4(r-0.4, g-0.4, b-0.4, a)
				imgui.TextColored(render_color, u8(task.text))
				dl:AddLine(imgui.ImVec2(p.x, p.y + 7), imgui.ImVec2(p.x + imgui.CalcTextSize(u8(task.text)).x, p.y + 7), imgui.ColorConvertFloat4ToU32(render_color))
			end
		end
		
		imgui.End()
		imgui.PopStyleColor(2)
	end
)

local imgui_zametka = imgui.OnFrame(
	function() return windows.imgui_zametka[0] end,
	function(player)
		if not zametki[zametka_window[0]] then return end
		player.HideCursor = isKeyDown(0x02)
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
		imgui.Begin(u8('##admininfo'), _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar)
			imgui.TextColoredRGB('{909090}Действия с сотрудником',1)

			imgui.PushFont(font[20])
			imgui.TextColoredRGB(format('%s (%s)', sub(gsub(data.nickname, '_', ' '), 1, 15), data.id),1)
			imgui.PopFont()
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8('ЛКМ - cкопировать ник'))
				imgui.EndTooltip()
				if imgui.IsMouseReleased(0) then
					setClipboardText(data.nickname)
				end
			end

			imgui.PushFont(font[11])
			imgui.TextColoredRGB(format('{909090}%s%s%s', (data.uniform and 'В форме' or 'Без формы'), (data.mute and ' * MUTED' or ''), (data.demorgan and ' * DEMORGAN' or '')), 1)
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

			if AshSettings.MainSettings.myrankint >= 9 then
				if imgui.Button(u8'Выдать мут', imgui.ImVec2(-1, 20)) then
					local id = data.id
					local mutetime = 30
					local reason = 'Сломанная рация'
					sendchatarray(AshSettings.MainSettings.playcd, {
						{'/me {gender:достал|достала} планшет из кармана'},
						{'/me {gender:включил|включила} планшет'},
						{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы'},
						{'/me {gender:выбрал|выбрала} нужного сотрудника'},
						{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
						{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
						{'/fmute %s %s %s', id, mutetime, reason},
					})
				end
				if imgui.Button(u8'+ WARN', imgui.ImVec2(78, 20)) then
					local id = data.id
					local reason = 'Н. У.'
					sendchatarray(AshSettings.MainSettings.playcd, {
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
					sendchatarray(AshSettings.MainSettings.playcd, {
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
					local reason = 'Н. У.'
					sendchatarray(AshSettings.MainSettings.playcd, {
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
			imgui.TextColoredRGB('{909090}Заметка',1)
			imgui.PushItemWidth(170)
			if imgui.InputText('##specialnoteforadmin', checker_variables.note_input, sizeof(checker_variables.note_input)) then
				AshSettings.Checker.Notes[data.nickname] = #str(checker_variables.note_input) > 0 and u8:decode(str(checker_variables.note_input)) or nil
				inicfg.save(AS_Settings,'AS Helper')
			end
			imgui.PopItemWidth()
			if imgui.Button(u8'Закрыть',imgui.ImVec2(170,25)) then
				checker_variables.temp_player_data = nil
			end
		imgui.End()
	end
)

function updatechatcommands()
	for key, value in pairs(AshSettings.Binder.BindsName) do
		sampUnregisterChatCommand(AshSettings.Binder.BindsCmd[key])
		if AshSettings.Binder.BindsCmd[key] ~= '' and AshSettings.Binder.BindsType[key] == 0 then
			sampRegisterChatCommand(AshSettings.Binder.BindsCmd[key], function()
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for bp in gmatch(tostring(AshSettings.Binder.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end
					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(AshSettings.Binder.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(AshSettings.Binder.BindsDelay[key])
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
					ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
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
	if AshSettings.MainSettings.bodyrank then
		for i, member in ipairs(checker_variables.online) do
			if member.nickname == sampGetPlayerNickname(playerId) then
				sampCreate3dTextEx(i, string.format('%s [%s]', AshSettings.ScannedVariables.RankNames[member.rank], member.rank), 0XFFAAAAAA, 0, 0, -0.5, 10, false, playerId, -1)
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

addEventHandler('onReceivePacket', function (id, bs)
	if id == 220 then
		raknetBitStreamIgnoreBits(bs, 8)
		if (raknetBitStreamReadInt8(bs) == 17) then
			raknetBitStreamIgnoreBits(bs, 32)
			local length = raknetBitStreamReadInt16(bs)
			local encoded = raknetBitStreamReadInt8(bs)
			local str = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
			if str:find('event.employment.updateData') and AshSettings.TaskChecker.state == true then
				local fixedstr = string.sub(str, 54, str:len() - 4)
			
				local taskInfo = decodeJson(fixedstr)

				local tasks = {
					[316] = 'Провести на службе несколько часов',
					[317] = 'Пройти тест на компьютере в организации',
					[318] = 'Простоять на посту несколько минут',
					[319] = 'Продать лицензии на авто',
					[320] = 'Написать несколько сообщение в чат организации',
					[321] = 'Принять участие в Role-Play мероприятии',
					[322] = 'Отстоять испытательный срок на должности',
					[323] = 'Пройти тест на компьютере в организации',
					[326] = 'Продать лицензии на мото',
					[334] = 'Продать лицензии на рыбалку',
					[343] = 'Продать лицензии на плавание',
					[347] = 'Простоять на посту несколько минут',
					[348] = 'Продать лицензии на авто',
					[349] = 'Продать лицензии на мото',
					[350] = 'Продать лицензии на рыбалку',
					[351] = 'Продать лицензии на плавание',
					[352] = 'Продать лицензии на оружие',
					[353] = 'Продать лицензии на охоту',
					[354] = 'Продать лицензии на раскопки',
					[355] = 'Продать лицензии на работу механиком',
					[356] = 'Продать лицензии на полёты',
					[357] = 'Написать несколько сообщение в чат организации',
					[358] =  'Написать несколько сообщение в чат департамента',
					[359] = 'Принять участие в Role-Play мероприятии',
					[360] = 'Провести на службе несколько часов',
					[361] = 'Пройти тест на компьютере в организации',
					[363] = 'Написать несколько сообщение в чат организации',
					[364] = 'Принять участие в Role-Play мероприятии',
					[365] = 'Отстоять испытательный срок на должности',
					[366] = 'Пройти тест на компьютере в организации',
					[626] = 'Выполнить квесты во фракции',
					[632] = 'Установить несколько дорожных знаков',
					[634] = 'Установить несколько дорожных знаков',
				}
				task_checker_variables.tasks = {completed = 0}
				task_checker_variables.is_upgrade = taskInfo.is_upgrade

				if taskInfo.member == 0 then
					send_cef('exit')	
					return
				end

				for k, v in pairs(taskInfo.tasks) do
					if tasks[v.id] == nil then
						tasks[v.id] = 'Неизвестно (сообщите автору)'
						print(v.id)
					end

					task_checker_variables.tasks[#task_checker_variables.tasks + 1] = {
						text = tasks[v.id],
						progress = v.progress,
						max = v.max,
						completed = v.completed,
					}
					if v.completed == 1 then
						task_checker_variables.tasks.completed = task_checker_variables.tasks.completed + 1
					end

					if getmyrank then
						send_cef('exit')
					end
				end
			elseif str:find('event.documents.inititalizeData') then
				if sellList.sellLicense ~= 0 and sellList.checking_medcard.status == 1 then
					local fixedstr = string.sub(str, 58, str:len() - 4)
	
					local personInfo = decodeJson(fixedstr)
	
					if personInfo.name == sampGetPlayerNickname(sellList.sellPerson) then
						if personInfo.type == 1 then
							send_cef('documents.changePage|4')
						elseif personInfo.type == 4 then
							sellList.checking_medcard.status = (personInfo.state == 'Полностью здоровый(ая)' and 2 or 3)
							sellNextLicense()
							send_cef('documents.close')
						end
					end
				elseif Interview.stage == 2 and newwindowtype[0] == 2 and windows.imgui_fm[0] then
					local fixedstr = string.sub(str, 58, str:len() - 4)
	
					local personInfo = decodeJson(fixedstr)

					if personInfo.type == 1 and personInfo.name == sampGetPlayerNickname(fastmenuID) then
						if AshSettings.Interview.pass.state then
							local lvl, law = select(1, personInfo.level:gsub(' лет', '')), select(1, personInfo.zakono:gsub('/.+', ''))
							if tonumber(lvl) < AshSettings.Interview.pass.minLvl then
								Interview.Checking.pass.state = 2
								Interview.Checking.pass.reason = 'Слишком маленький уровень'
								send_cef('documents.changePage|2')
							elseif tonumber(law) < AshSettings.Interview.pass.minLaw then
								Interview.Checking.pass.state = 2
								Interview.Checking.pass.reason = 'Слишком маленькая законопослушность'
								send_cef('documents.changePage|2')
							elseif personInfo.charity ~= 'Нет' then
								Interview.Checking.pass.state = 2
								Interview.Checking.pass.reason = 'Работает в другой организации'
								send_cef('documents.changePage|2')
							else
								Interview.Checking.pass.state = 1
								send_cef('documents.changePage|2')
							end
						else
							Interview.Checking.pass.state = 1
							send_cef('documents.changePage|2')
						end
					elseif personInfo.type == 2 then
						if AshSettings.Interview.licenses.state then
							local auto, moto = personInfo.info[1].available, personInfo.info[1].available
							if not auto and AshSettings.Interview.licenses.auto then
								Interview.Checking.licenses.state = 2
								Interview.Checking.licenses.reason = 'Нету лицензии на авто'
								send_cef('documents.changePage|4')
							elseif not moto and AshSettings.Interview.licenses.moto then
								Interview.Checking.licenses.state = 2
								Interview.Checking.licenses.reason = 'Нету лицензии на мото'
								send_cef('documents.changePage|4')
							else
								Interview.Checking.licenses.state = 1
								send_cef('documents.changePage|4')
							end
						else
							Interview.Checking.licenses.state = 1
							send_cef('documents.changePage|4')
						end
					elseif personInfo.type == 4 then
						if AshSettings.Interview.mc.state then
							local state, addiction = personInfo.state, personInfo.zavisimost
							if state ~= 'Полностью здоровый(ая)' and AshSettings.Interview.mc.healthStatus then
								Interview.Checking.mc.state = 2
								Interview.Checking.mc.reason = 'Не полностью здоровый'
								if state == nil then
									Interview.Checking.mc.reason = 'Нету мед. карты'
								end
							elseif tonumber(addiction) > AshSettings.Interview.mc.maxAddiction then
								Interview.Checking.mc.state = 2
								Interview.Checking.mc.reason = 'Больше '..AshSettings.Interview.mc.maxAddiction..' зависимости'
							else
								Interview.Checking.mc.state = 1
							end
						else
							Interview.Checking.mc.state = 1
						end
						Interview.Checking.state = 2
						send_cef('documents.close')
					end
				end
			end
		end
	end
end)

function send_cef(str)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt8(bs, 220)
	raknetBitStreamWriteInt8(bs, 18)
	raknetBitStreamWriteInt16(bs, #str)
	raknetBitStreamWriteString(bs, str)
	raknetBitStreamWriteInt32(bs, 0)
	raknetSendBitStream(bs)
	raknetDeleteBitStream(bs)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	--print(dialogId, style, title, button1, button2, text)
	if (repair.signs_parcing.in_parcing ~= 0 or repair.signs_parcing.make_path ~= 0) and title:find('{BFBBBA}Дорожные знаки') and style == 5 and text:find('{ffffff}Износ') then

		if repair.signs_parcing.make_path ~= 0 then
			sampSendDialogResponse(dialogId, 1, repair.signs_parcing.showed_signs[repair.signs_parcing.make_path].number - 1, nil)
			repair.signs_parcing.make_path = 0
			repair.signs_parcing.dialogOpened = false
			repair.signs_parcing.signs = {}
			return false
		end

		local city = title:match('{BFBBBA}Дорожные знаки %((.+)%)')

		for DialogLine in gmatch(text, '[^\r\n]+') do
			if not DialogLine:find('%[№%] Название знака') then
				local number, text, distance, wear, status = DialogLine:match('%[(%d+)%](.+)\t(.+)\t(.+)\t(.+)') 
				repair.signs_parcing.signs[#repair.signs_parcing.signs+1] = {
					number = number,
					text = text,
					distance = distance,
					wear = wear == ' ' and '{ff0000}100%' or wear,
					status = status,

					city = city,
				}
			end
		end
		sampSendDialogResponse(dialogId, 0, repair.signs_parcing.in_parcing - 1, nil)
		repair.signs_parcing.in_parcing = repair.signs_parcing.in_parcing == 3 and 0 or repair.signs_parcing.in_parcing + 1
		return false
	end
	if title == '{BFBBBA}Выберите город' and style == 5 and text:find('{ffffff}Установлено знаков') then
		
		if repair.signs_parcing.make_path ~= 0 then
			local city = repair.signs_parcing.showed_signs[repair.signs_parcing.make_path].city
			local citys = {
				['Los Santos'] = 0,
				['San Fierro'] = 1,
				['Lav Venturas'] = 2,
			}
			sampSendDialogResponse(dialogId, 1, citys[city], nil)
			return false
		end

		if repair.signs_parcing.in_parcing ~= 0 then
			sampSendDialogResponse(dialogId, 1, repair.signs_parcing.in_parcing - 1, nil)
			return false
		end

		if #repair.signs_parcing.signs ~= 0 then
			text = '№ Название знака\tРасстояние\tИзнос\tСтатус\n{MC}Отсортировать:\n{'..(repair.signs_parcing.sort_dontshow and 'MC' or 'WC')..'}Не показывать установленные\n{'..(repair.signs_parcing.sort == 1 and 'MC' or 'WC')..'}Расстояние\n{'..(repair.signs_parcing.sort == 2 and 'MC' or 'WC')..'}Износ\n'..(repair.signs_parcing.page ~= 0 and '{WC}<< Предыдущая страница\n' or ' \n')
			repair.signs_parcing.showed_signs = {}

			if repair.signs_parcing.sort == 1 then
				table.sort(repair.signs_parcing.signs, function(a, b)
					local num1 = a.distance:gsub('м', '')
					local num2 = b.distance:gsub('м', '')
					return tonumber(num1) < tonumber(num2) 
				end)
			else
				table.sort(repair.signs_parcing.signs, function(a, b)
					local num1 = a.wear:sub(9, a.wear:len()):gsub('%%', '')
					local num2 = b.wear:sub(9, b.wear:len()):gsub('%%', '')
					return tonumber(num1) > tonumber(num2) 
				end)
			end

			local i = 1 + repair.signs_parcing.page * 40
			local k = 1 + repair.signs_parcing.page * 40
			while i <= 40 + repair.signs_parcing.page * 40 do
				local v = repair.signs_parcing.signs[k]
				repair.signs_parcing.showed_signs[#repair.signs_parcing.showed_signs+1] = v
				if v ~= nil then
					local line = '\n['..i..']'..v.text..'\t'..v.distance..'\t'..v.wear..'\t'..v.status
					if repair.signs_parcing.sort_dontshow then
						local wearNum = v.wear:sub(9, v.wear:len()):gsub('%%', '')
						if tonumber(wearNum) < 30 then
							line = ''
							table.remove(repair.signs_parcing.showed_signs, #repair.signs_parcing.showed_signs)
							i = i - 1
						end
					end
					text = text..line
				end
				i = i + 1
				k = k + 1
			end
			if repair.signs_parcing.signs[k+1] then
				text = text..'\n{WC}>> Следующая страница'
			end

			repair.signs_parcing.max_pages = ceil(len(text)/3600)

			local col = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)
			local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
			text = gsub(text, '{WC}', '{EBEBEB}')
			text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

			return {dialogId, style, 'Отсортированные знаки', 'Выбрать', 'Отмена', text}
		end

		text = text:sub(1, text:find('\n'))..'{MC}[autoschool]\tОтсортировать'..'\n '..text:sub(text:find('\n'), text:len())
		repair.signs_parcing.dialogOpened = true

		local col = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)
		local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
		text = gsub(text, '{WC}', '{EBEBEB}')
		text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

		return{dialogId, style, title, button1, button2, text}
	end
	if title == '{BFBBBA}{73B461}Продажа лицензии' and style == 5 and text:find('$') then
		for DialogLine in gmatch(text, '[^\r\n]+') do
			local i = 0
			local licNum, minRank, oneMonth, twoMonth, threeMonth = DialogLine:match('{%x+}(%d+)%..+%(.+(%d+).+%).+{%x+}(.+){%x+}(.+){%x+}(.+)')
			local price = {oneMonth, twoMonth, threeMonth}
			licNum = tonumber(licNum)
			minRank = tonumber(minRank)

			if licNum and licNum <= #licenses then
				for k, v in pairs(price) do
					v = v:gsub('%$', '')
					v = v:gsub(' ', '')
					price[k] = tonumber(v)
				end
				AshSettings.ScannedVariables.PriceList[licNum].rank = minRank
				AshSettings.ScannedVariables.PriceList[licNum].price = price
			end
		end
		
		if sellList.sellLicense ~= 0 and sellList[sellList.sellLicense].status == 1 then
			sampSendDialogResponse(dialogId, 1, sellList[sellList.sellLicense].licenseNumber-1, nil)
			return false
		elseif sellList.sellLicense ~= 0 and sellList[sellList.sellLicense].status == 8 then
			sampSendDialogResponse(dialogId, 0, sellList[sellList.sellLicense].licenseNumber-1, nil)
			return false
		end
	end

	if title == '{BFBBBA}{73B461}Выбор срока лицензий' and style == 5 then
		
		if sellList.sellLicense ~= 0 and sellList[sellList.sellLicense].status == 1 then
			if sellList[sellList.sellLicense].month > 1 then
				if not text:find('месяца') then
					sellList[sellList.sellLicense].month = 1
					ASHelperMessage('Эта лицензия может быть продана лишь на 1 месяц, у игрока слишком маленький уровень.')
				end
			end
			sampSendDialogResponse(dialogId, 1, sellList[sellList.sellLicense].month-1, nil)
			return false
		end
	end

	if sellList.sellLicense ~= 0 and sellList.checking_medcard.status == 1 and title == '{BFBBBA}Активные предложения' and style == 5 and text:find('Отклонить все предложения') then
		for DialogLine in gmatch(text, '[^\r\n]+') do
			local num, offer, name, time = DialogLine:match('{ff6666}%[(%d+)%]{ffffff} (.+)\t{%x+}(.+)\t{%x+}(.+)')
			if offer == 'Предлагает посмотреть его медицинскую карту..' and sampGetPlayerNickname(sellList.sellPerson) == name then
				sampSendDialogResponse(dialogId, 1, num-1, nil)
				return false
			end
		end

	elseif sellList.sellLicense ~= 0 and sellList.checking_medcard.status == 1 and title == '{BFBBBA}Активные предложения' and style == 2 and text:find('Принять предложение') then
		sampSendDialogResponse(dialogId, 1, 2, nil)
		return false

	elseif sellList.sellLicense ~= 0 and sellList.checking_medcard.status == 1 and title == '{BFBBBA}Подтверждение действия' and style == 0 and text:find('Вы действительно хотите принять следующее предложение?') then
		sampSendDialogResponse(dialogId, 1, 0, nil)
		return false

	elseif Interview.stage == 2 and Interview.Checking.state == 1 and newwindowtype[0] == 2 and windows.imgui_fm[0] and title == '{BFBBBA}Активные предложения' and style == 5 and text:find('Отклонить все предложения') then
		for DialogLine in gmatch(text, '[^\r\n]+') do
			local num, offer, name, time = DialogLine:match('{ff6666}%[(%d+)%]{ffffff} (.+)\t{%x+}(.+)\t{%x+}(.+)')
			if sampGetPlayerNickname(fastmenuID) == name then
				sampSendDialogResponse(dialogId, 1, num-1, nil)
				return false
			end
		end

	elseif Interview.stage == 2 and Interview.Checking.state == 1 and newwindowtype[0] == 2 and windows.imgui_fm[0] and title == '{BFBBBA}Активные предложения' and style == 2 and text:find('Принять предложение') then
		sampSendDialogResponse(dialogId, 1, 2, nil)
		return false

	elseif Interview.stage == 2 and Interview.Checking.state == 1 and newwindowtype[0] == 2 and windows.imgui_fm[0] and title == '{BFBBBA}Подтверждение действия' and style == 0 and text:find('Вы действительно хотите принять следующее предложение?') then
		sampSendDialogResponse(dialogId, 1, 0, nil)
		return false

	elseif dialogId == 235 and getmyrank then
		if find(text, 'Центр лицензирования') then
			for DialogLine in gmatch(text, '[^\r\n]+') do
				local nameRankStats, getStatsRank = DialogLine:match('Должность: {B83434}(.+)%p(%d+)%p')
				if tonumber(getStatsRank) then
					local rangint = tonumber(getStatsRank)
					local rang = tostring(nameRankStats)
					if rangint ~= AshSettings.MainSettings.myrankint then
						ASHelperMessage(format('Ваш ранг был обновлён на %s (%s)',rang,rangint))
					end
					if AshSettings.ScannedVariables.RankNames[rangint] ~= rang then
						ASHelperMessage(format('Название {MC}%s{WC} ранга изменено с {MC}%s{WC} на {MC}%s{WC}', rangint, AshSettings.ScannedVariables.RankNames[rangint], rang))
					end
					AshSettings.ScannedVariables.RankNames[rangint] = rang
					AshSettings.MainSettings.myrankint = rangint
					inicfg.save(AS_Settings,'AS Helper')
				end
			end
		else
			print('{FF0000}Игрок не работает в автошколе. Скрипт был выгружен.')
			ASHelperMessage('Вы не работаете в автошколе, скрипт выгружен! Если это ошибка, то обратитесь к {MC}vk.com/justmini{WC}.')
			NoErrors = true
			if not dev_mode then thisScript():unload() end
		end
		sampSendDialogResponse(235, 0, 0, nil)
		getmyrank = false
		return false

	elseif dialogId == 1234 then
		if find(text, 'Срок действия') then
			if AshSettings.MainSettings.Sobes.medcard and sobes_results and not sobes_results.medcard then
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
		elseif find(text, 'Серия') then
			if AshSettings.MainSettings.Sobes.pass and sobes_results and not sobes_results.pass then
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
			if AshSettings.MainSettings.Sobes.licenses and sobes_results and not sobes_results.licenses then
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
			local nick, rank, warns_afk, quests = string.match(line, '(.+)\t(.+)\t(.+)\t(.+)')

			local name, rank = string.match(rank, '(.+)%((%d+)%)')

			if name and rank then
				name, rank = tostring(name), tonumber(rank)
				if AshSettings.ScannedVariables.RankNames[rank] ~= nil and AshSettings.ScannedVariables.RankNames[rank] ~= name then
					ASHelperMessage(format('Название {MC}%s{WC} ранга изменено с {MC}%s{WC} на {MC}%s{WC}', rank, AshSettings.ScannedVariables.RankNames[rank], name))
					AshSettings.ScannedVariables.RankNames[rank] = name
					inicfg.save(AS_Settings,'AS Helper')
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
    		if not line:find('Ник') and not line:find('страница') then
    			local color = string.match(line, '^{(%x+)}')
				local nick, rank, warns_afk, quests = string.match(line, '(.+)\t(.+)\t(.+)\t(.+)')

	    		local mute = string.find(warns_afk, '| MUTED')
	    		local demorgan = string.find(warns_afk, '| В деморгане')
				if mute then warns_afk = string.gsub(warns_afk, ' | MUTED', '') end
				if demorgan then warns_afk = string.gsub(warns_afk, ' | В деморгане', '') end

				local nick, id = string.match(nick, '([A-z_0-9]+)%((%d+)%)')
				local rank_name, rank_id = string.match(rank, '(.+)%((%d+)%)')
				local warns, spec_warns, afk = string.match(warns_afk, '(%d) %[(%d)%] %/ (%d+)')
				local quests = string.match(quests, '(%d)')


	    		local near = select(1, sampGetCharHandleBySampPlayerId(tonumber(id)))
	    		local uniform = (color == '90EE90')

	    		checker_variables.online[#checker_variables.online + 1] = { 
					nickname = tostring(nick),
					id = id,
					rank = tonumber(rank_id),
					afk = tonumber(afk),
					warns = tonumber(warns),
					specwarns = tonumber(spec_warns),
					quests = tonumber(quests),
					mute = mute,
					demorgan = demorgan,
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
	if AshSettings.MainSettings.replacechat then
		if find(message, 'Используйте: /wbook %[id игрока%]') then
			ASHelperMessage('Вы просмотрели свою трудовую\nкнижку.')
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в гражданскую одежду') then
			ASHelperMessage('Вы закончили рабочий день,\nприятного отдыха!')
			return false
		end
		if find(message, sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в рабочую одежду') then
			ASHelperMessage('Вы начали рабочий день,\nудачной работы!')
			return false
		end
	end
	if sellList.sellLicense ~= 0 then
		if not sellList[sellList.sellLicense] then return {color, message} end
		if sellList[sellList.sellLicense].status == 2 then
			if find(message, 'У игрока уже есть такая лицензия сроком более чем 3 дня.') then
				sellList[sellList.sellLicense].status = 5
			end
			if (find(message, '%[Ошибка%] {ffffff}У игрока недостаточно денежных средств!')) then
				sellList[sellList.sellLicense].status = 6
			end
			if (find(message, 'Игрок отказался от покупки лицензии!')) then
				sellList[sellList.sellLicense].status = 11
			end
			if find(message, '%[Информация%] {FFFFFF}Вы успешно продали лицензию') then
				sellList[sellList.sellLicense].status = 3
				sellList[sellList.sellLicense].changed = clock()
				sellList.sellLicense = sellList.sellLicense + 1
				sellNextLicense()
			end
			if sellList.checking_medcard.status == 1 and (find(message, '%[Новое предложение%]{ffffff} Вам поступило предложение от игрока .+%. Используйте команду: /offer или клавишу X')) then
				local name = message:match('%[Новое предложение%]{ffffff} Вам поступило предложение от игрока (.+)%. Используйте команду: /offer или клавишу X')
				if name == sampGetPlayerNickname(sellList.sellPerson) then
					lua_thread.create(function()
						wait(500) -- Alexander_Lazarov
						sampSendChat('/offer')
					end)
				end
			end
			return {color, message}
		elseif sellList[sellList.sellLicense].status == 1 then
			if (find(message, '%[Информация%] {FFFFFF}Вы предложили (.+) купить лицензию (.+)')) then
				sellList[sellList.sellLicense].status = 2
				sellList[sellList.sellLicense].changed = clock()
			end
			if (find(message, '%[Ошибка%] {ffffff}Вы далеко от игрока')) then
				sellList[sellList.sellLicense].status = 4
			end
			if (find(message, '%[Ошибка%] {ffffff}Вы не на дежурстве')) then
				sellList[sellList.sellLicense].status = 9
			end
			if (find(message, '%[Ошибка%] {ffffff}Вы не можете выдать лицензии сами себе')) then
				sellList[sellList.sellLicense].status = 7
			end
			if (find(message, '%[Ошибка%] {ffffff}Вы не можете продавать лицензии на такой срок!')) then
				sellList[sellList.sellLicense].status = 8
			end
			return {color, message}
		end
		return {color, message}
	end

	if Interview.stage == 2 and Interview.Checking.state == 0 and newwindowtype[0] == 2 and windows.imgui_fm[0] then
		if (find(message, '%[Новое предложение%]{ffffff} Вам поступило предложение от игрока .+%. Используйте команду: /offer или клавишу X')) then
			local name = message:match('%[Новое предложение%]{ffffff} Вам поступило предложение от игрока (.+)%. Используйте команду: /offer или клавишу X')
			if name == sampGetPlayerNickname(fastmenuID) then
				Interview.Checking.state = 1
				lua_thread.create(function()
					wait(500) -- Alexander_Lazarov
					sampSendChat('/offer')
				end)
			end
		end
	end

	if find(message, '%[R%]') and color == 766526463 then
		if AshSettings.MainSettings.chatrank then
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

		local color = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.RChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message}
	end
	
	if find(message, '%[D%]') and color == 865730559 or color == 865665023 then
		if find(message, u8:decode(departsettings.myorgname[0])) then
			local tmsg = gsub(message, '%[D%] ','')
			dephistory[#dephistory + 1] = tmsg
		end
		local color = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.DChatColor)
		local r,g,b,a = color.x*255, color.y*255, color.z*255, color.w*255
		return { join_argb(r, g, b, a), message }
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
		return {color, message}
	end
end

function sampev.onSendDialogResponse(dialogId, button, listboxId, input)
	if repair.signs_parcing.dialogOpened and button == 1 then
		if listboxId == 0 then
			repair.signs_parcing.dialogOpened = false
			repair.signs_parcing.in_parcing = 1
			return {dialogId, button, listboxId, input}
		end
		repair.signs_parcing.dialogOpened = false
		if listboxId == 1 then listboxId = 5 end
		return {dialogId, button, listboxId - 2, input}
	end
	if #repair.signs_parcing.signs ~= 0 then
		if button == 1 then
			if listboxId == 1 then
				repair.signs_parcing.sort_dontshow = not repair.signs_parcing.sort_dontshow
				repair.signs_parcing.page = 0
			elseif listboxId == 2 then
				repair.signs_parcing.sort = 1
			elseif listboxId == 3 then
				repair.signs_parcing.sort = 2
			elseif listboxId == 4 and repair.signs_parcing.page ~= 0 then
				repair.signs_parcing.page = repair.signs_parcing.page - 1
			elseif listboxId > 4 and listboxId < 45 then
				repair.signs_parcing.make_path = listboxId - 4
			elseif listboxId == 45 then
				repair.signs_parcing.page = repair.signs_parcing.page + 1
			end
			return {dialogId, 1, 3, input}
		end
		if button == 0 then
			repair.signs_parcing.signs = {}
			repair.signs_parcing.page = 0
			return {dialogId, 1, 3, input}
		end
	end
	repair.signs_parcing.dialogOpened = false
end

function sampev.onSendChat(message)
	if find(message, '{my_id}') then
		sampSendChat(gsub(message, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(message, '{my_name}') then
		sampSendChat(gsub(message, '{my_name}', (AshSettings.MainSettings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname))))
		return false
	end
	if find(message, '{my_rank}') then
		sampSendChat(gsub(message, '{my_rank}', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint]))
		return false
	end
	if find(message, '{my_score}') then
		sampSendChat(gsub(message, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(message, '{H}') then
		sampSendChat(gsub(message, '{H}', os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)))
		return false
	end
	if find(message, '{HM}') then
		sampSendChat(gsub(message, '{HM}', os.date('%H:%M', os.time(os.date('!*t')) + 2 * 60 * 60)))
		return false
	end
	if find(message, '{HMS}') then
		sampSendChat(gsub(message, '{HMS}', os.date('%H:%M:%S', os.time(os.date('!*t')) + 2 * 60 * 60)))
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
	if find(message, '{interact_id}') then
		if windows.imgui_fm[0] and fastmenuID then
			sampSendChat(gsub(message, '{interact_id}', fastmenuID))
			return false
		end
		ASHelperMessage('Вы ни с кем не взаимодействуете.')
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
		if AshSettings.MainSettings.gender == 0 then
			local gendermsg = gsub(message, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(message, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end

	if #AshSettings.MainSettings.myaccent > 1 then
		if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == 'q' or message == ';)' then
			return{message}
		end
		if find(string.rlower(u8:decode(AshSettings.MainSettings.myaccent)), 'акцент') then
			return{format('[%s]: %s', u8:decode(AshSettings.MainSettings.myaccent),message)}
		else
			return{format('[%s акцент]: %s', u8:decode(AshSettings.MainSettings.myaccent),message)}
		end
	end
end

function sampev.onSendCommand(cmd)
	if find(cmd, '{my_id}') then
		sampSendChat(gsub(cmd, '{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
		return false
	end
	if find(cmd, '{my_name}') then
		sampSendChat(gsub(cmd, '{my_name}', (AshSettings.MainSettings.useservername and gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(AshSettings.MainSettings.myname))))
		return false
	end
	if find(cmd, '{my_rank}') then
		sampSendChat(gsub(cmd, '{my_rank}', AshSettings.ScannedVariables.RankNames[AshSettings.MainSettings.myrankint]))
		return false
	end
	if find(cmd, '{my_score}') then
		sampSendChat(gsub(cmd, '{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
		return false
	end
	if find(cmd, '{H}') then
		sampSendChat(gsub(cmd, '{H}', os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)))
		return false
	end
	if find(cmd, '{HM}') then
		sampSendChat(gsub(cmd, '{HM}', os.date('%H:%M', os.time(os.date('!*t')) + 2 * 60 * 60)))
		return false
	end
	if find(cmd, '{HMS}') then
		sampSendChat(gsub(cmd, '{HMS}', os.date('%H:%M:%S', os.time(os.date('!*t')) + 2 * 60 * 60)))
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
	if find(cmd, '{interact_id}') then
		if windows.imgui_fm[0] and fastmenuID then
			sampSendChat(gsub(cmd, '{interact_id}', fastmenuID))
			return false
		end
		ASHelperMessage('Вы ни с кем не взаимодействуете.')
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
		if AshSettings.MainSettings.gender == 0 then
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', male, 1)
			sampSendChat(tostring(gendermsg))
			return false
		else
			local gendermsg = gsub(cmd, '{gender:%A+|%A+}', female, 1)
			sampSendChat(tostring(gendermsg))
			return false
		end
	end
	if AshSettings.MainSettings.fmtype == 1 then
		com = #cmd > #AshSettings.MainSettings.usefastmenucmd+1 and sub(cmd, 2, #AshSettings.MainSettings.usefastmenucmd+2) or sub(cmd, 2, #AshSettings.MainSettings.usefastmenucmd+1)..' '
		if com == AshSettings.MainSettings.usefastmenucmd..' ' then
			if windows.imgui_fm[0] == false then
				if find(cmd, '/'..AshSettings.MainSettings.usefastmenucmd..' %d+') then
					local param = cmd:match('.+ (%d+)')
					if sampIsPlayerConnected(param) then
						if doesCharExist(select(2,sampGetCharHandleBySampPlayerId(param))) then
							fastmenuID = param
							ASHelperMessage(format('Вы использовали Меню взаимодействия на: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
							windows.imgui_fm[0] = true
						else
							ASHelperMessage('Игрок не находится рядом с вами')
						end
					else
						ASHelperMessage('Игрок не в сети')
					end
				else
					ASHelperMessage('/'..AshSettings.MainSettings.usefastmenucmd..' [id]')
				end
			end
			return false
		end
	end
end

function sampev.onShowTextDraw(textDrawId, textDrawData)
	if AshSettings.MainSettings.autorepair then
		if textDrawId == 2092 then
			if textDrawData.text == 'PEMOHЏ_ѓOPO„HO‚O_€HAKA' then
				local textDraws = {
					2081, 2105, 2104, 2103,
					2082, 2101, 2100, 2102,
					2083, 2099, 2100, 2101, 2102, 2104, 2105,
					2084, 2099, 2100, 2101, 2102, 2104
				}
				for k, v in ipairs(textDraws) do
					sampSendClickTextdraw(v)
				end
			elseif textDrawData.text == 'CЂOPKA_ѓOPO„HO‚O_€HAKA' then
				local textDraws = {
					2081, 2098,
					2082, 2098,
					2083, 2098, 2099, 2100, 2101, 2104, 2105, 2106,
					2084, 2098, 2099, 2100, 2104, 2105, 
				}
				for k, v in ipairs(textDraws) do
					sampSendClickTextdraw(v)
				end
			end
		end
	end
end

function IsPlayerConnected(id)
	return (sampIsPlayerConnected(tonumber(id)) or select(2, sampGetPlayerIdByCharHandle(playerPed)) == tonumber(id))
end

function ASHelperMessage(text)
	local col = imgui.ColorConvertU32ToFloat4(AshSettings.MainSettings.ASChatColor.color)
	local r,g,b,a = col.x*255, col.y*255, col.z*255, col.w*255
	text = gsub(text, '{WC}', '{EBEBEB}')
	text = gsub(text, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))
	sampAddChatMessage(format('[autoschool]{EBEBEB} %s', text),join_argb(a, r, g, b)) -- ff6633 default
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

		sampShowDialog(536472, '{ff6633}autoschool/helper{ffffff} внезапно выгрузился.', [[
{f51111}Если Вы самостоятельно перезагрузили скрипт, то можете закрыть это диалоговое окно.
В ином случае, для начала попытайтесь восстановить работу скрипта сочетанием клавиш CTRL + R.
Если же это не помогло, то следуйте дальнейшим инструкциям.{ff6633}
1. Возможно у Вас установлены конфликтующие LUA файлы и хелперы, попытайтесь удалить их.
2. Возможно Вы не установили некоторые нужные библиотеки, а именно:
 - SAMPFUNCS 5.5.1
 - CLEO 4.1+
 - MoonLoader 0.26+
3. Если данной ошибки не было ранее, попытайтесь сделать следующие действия:
- В папке moonloader > Удаляем папку AS Helper | {f51111}Все настройки скрипта собьются{ff6633}
4. Если даже это не помогло Вам, то отправьте автору {2594CC}(vk.com/justmini){FF6633} скриншот ошибки.{FFFFFF}
 
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

function isPlayerInForm()
	if not scriptInitialized then return end
	return sampGetPlayerColor(select(2,sampGetPlayerIdByCharHandle(playerPed))) == 2164221491
end

function sellNextLicense()
	if #sellList == 0 then return end

	if sellList.sellLicense > #sellList then
		sellList.sellLicense = 0
		sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
		return false
	end

	sellList[sellList.sellLicense].status = 1
	sellList[sellList.sellLicense].changed = clock()

	local chat_array = {}

	local status = sellList.checking_medcard.status
	if status == 1 then
		sellList[sellList.sellLicense].dialogTime = AshSettings.MainSettings.playcd / 1000

		sendchatarray(AshSettings.MainSettings.playcd, {
			{'Для покупки лицензии на %s покажите мне свою мед. карту', sellList.checking_medcard.licenses},
			{'/n /showmc %s', select(2,sampGetPlayerIdByCharHandle(playerPed))},
		}, nil, function() sellList[sellList.sellLicense].status = 2 end)
		return
	end
	if status == 2 then
		chat_array[#chat_array + 1] = {'/me взяв мед.карту в руки {gender:начал|начала} её проверять'}
		chat_array[#chat_array + 1] = {'/do Мед.карта в норме.'}
		chat_array[#chat_array + 1] = {'/todo Всё в порядке* отдавая мед.карту обратно'}

		sellList.checking_medcard.status = 0
	end
	if status == 5 then
		chat_array[#chat_array + 1] = {'Сожалею, но без мед. карты я не продам. Оформите её в любой больнице.'}
		sellList.checking_medcard.status = 0
	end
	if status == 3 then
		sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me взяв мед.карту в руки {gender:начал|начала} её проверять'},
			{'/do Мед.карта не в норме.'},
			{'/todo К сожалению, в мед.карте написано, что у Вас есть отклонения.* отдавая мед.карту обратно'},
			{'Обновите её и приходите снова!'},
		}, nil, function() sellList.checking_medcard.status = 4 end)
		return
	end

	if #sellList == 1 then
		chat_array[#chat_array + 1] = {'Приступаю к оформлению.'}
		chat_array[#chat_array + 1] = {'/me {gender:открыл|открыла} тумбочку, {gender:взял|взяла} оттуда бланк, {gender:положил|положила} на стол'}
		chat_array[#chat_array + 1] = {'/me {gender:заполнил|заполнила} ручкой бланк на получение лицензии на %s', string.rlower(sellList[sellList.sellLicense].chat)}
	elseif #sellList > 1 then
		if sellList.sellLicense == 1 then
			chat_array[#chat_array + 1] = {'Приступаю к оформлению.'}
			chat_array[#chat_array + 1] = {'/me {gender:открыл|открыла} тумбочку, {gender:взял|взяла} оттуда %s бланков, {gender:положил|положила} на стол', #sellList > 2 and 'стопку' or 'пару'}
			chat_array[#chat_array + 1] = {'/me {gender:заполнил|заполнила} ручкой один бланк на получение лицензии на %s', string.rlower(sellList[sellList.sellLicense].chat)}
		else
			chat_array[#chat_array + 1] = {'/me {gender:заполнил|заполнила} ручкой бланк на получение лицензии на %s', string.rlower(sellList[sellList.sellLicense].chat)}
		end
	end

	chat_array[#chat_array + 1] = {'/do Спустя некоторое время бланк на получение лицензии был заполнен.'}
	chat_array[#chat_array + 1] = {'/me распечатав лицензию на %s {gender:передал|передала} её человеку напротив', string.rlower(sellList[sellList.sellLicense].chat)}

	sellList[sellList.sellLicense].dialogTime = (AshSettings.MainSettings.playcd / 1000) * (#chat_array - 1) 

	sendchatarray(AshSettings.MainSettings.playcd, chat_array, nil, function() wait(1000) sampSendChat(format('/givelicense %s', sellList.sellPerson)) end)
end

function sendchatarray(delay, text, start_function, end_function)
	start_function = start_function or function() end
	end_function = end_function or function() end
	if inprocess ~= nil then
		ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
		return false
	end
	inprocess = lua_thread.create(function()
		start_function()
		for i = 1, #text do
			sampSendChat(format(text[i][1], unpack(text[i], 2)))
			if i ~= #text then
				wait(delay)
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
	if doesFileExist(getWorkingDirectory()..'\\config\\AS Helper.ini') then
		windows.imgui_first_launch[#windows.imgui_first_launch + 1] = 1
	end
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
					f:close()
					os.remove(json)
					local updateversion = (AshSettings.MainSettings.getbetaupd and info.beta_upd) and info.beta_version or info.version
					if updateversion ~= thisScript().version then
						ASHelperMessage('Обнаружено обновление на\nверсию {MC}'..updateversion..'{WC}. Подробности:\n{MC}/ashupd')
					else
						if show_notify then
							ASHelperMessage('Обновлений не обнаружено!')
						end
					end
					if (AshSettings.MainSettings.getbetaupd and info.beta_upd) then
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
					inicfg.save(AS_Settings, 'AS Helper.ini')
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

	print('{00FF00}Успешная загрузка')

	if AshSettings.Checker.posX == -100 and AshSettings.Checker.state then
		windows.imgui_first_launch[#windows.imgui_first_launch + 1] = 2
	end
	if AshSettings.TaskChecker.posX == -100 and AshSettings.TaskChecker.state then
		windows.imgui_first_launch[#windows.imgui_first_launch + 1] = 3
	end

	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == 'Carolos_McCandy' then
		AshSettings.MainSettings.myrankint = 10
		sampRegisterChatCommand('debug_menu', function()
			ASHelperMessage('Режим отладки: открыто меню взаимодействия.')
			fastmenuID = select(2,sampGetPlayerIdByCharHandle(playerPed))
			windows.imgui_fm[0] = not windows.imgui_fm[0]
		end)
		sampRegisterChatCommand('debug_rank', function(param)
			ASHelperMessage('Режим отладки: установленный ранг: {MC}'..param..'{WC}.')
			AshSettings.MainSettings.myrankint = tonumber(param)
		end)
		ASHelperMessage('Режим отладки: {33FF33}ВКЛ{WC}. {MC}/debug_menu{WC} - меню взаимодействия с собой. {MC}/debug_rank{WC} - установить ранг.')
		dev_mode = true
	end
	sampRegisterChatCommand('ash', function()
		windows.imgui_settings[0] = not windows.imgui_settings[0]
		alpha[0] = clock()
	end)
	sampRegisterChatCommand('ashbind', function()
		choosedslot = nil
		windows.imgui_binder[0] = not windows.imgui_binder[0]
	end)
	sampRegisterChatCommand('ashlect', function()
		if AshSettings.MainSettings.myrankint < 5 then
			return ASHelperMessage('Данная функция доступна с 5-го\nранга.')
		end
		windows.imgui_lect[0] = not windows.imgui_lect[0]
	end)
	sampRegisterChatCommand('ashdep', function()
		if AshSettings.MainSettings.myrankint < 5 then
			return ASHelperMessage('Данная функция доступна с 5-го\nранга.')
		end
		windows.imgui_depart[0] = not windows.imgui_depart[0]
	end)
	sampRegisterChatCommand('ashupd', function()
		windows.imgui_settings[0] = true
		mainwindow[0] = 3
		infowindow[0] = 1
		alpha[0] = clock()
	end)
	sampRegisterChatCommand('ashlog', function()
		windows.imgui_changelog[0] = true
	end)

	sampRegisterChatCommand('uninvite', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/uninvite %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
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
			return sendchatarray(AshSettings.MainSettings.playcd, {
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
			return sendchatarray(AshSettings.MainSettings.playcd, {
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
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/invite %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/invite [id]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете приглашать в организацию самого себя.')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/do Ключи от шкафчика в кармане.'},
			{'/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика'},
			{'/me {gender:передал|передала} ключ человеку напротив'},
			{'Добро пожаловать! Переодеться вы можете в раздевалке.'},
			{'Со всей информацией Вы можете ознакомиться на оф. портале.'},
			{'/invite %s', id},
		})
	end)

	sampRegisterChatCommand('giverank', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/giverank %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,rank = param:match('(%d+) (%d)')
		if id == nil or rank == nil then
			return ASHelperMessage('/giverank [id] [ранг]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете менять ранг самому себе.')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
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
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/blacklist %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/blacklist [id] [причина]')
		end
		if tonumber(id) == select(2,sampGetPlayerIdByCharHandle(playerPed)) then
			return ASHelperMessage('Вы не можете внести в ЧС самого себя.')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
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
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/unblacklist %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/unblacklist [id]')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
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
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/fwarn %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/fwarn [id] [причина]')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
			{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
			{'/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор'},
			{'/do Выговор был добавлен в личное дело сотрудника.'},
			{'/fwarn %s %s', id, reason},
		})
	end)

	sampRegisterChatCommand('unfwarn', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/unfwarn %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/unfwarn [id]')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\''},
			{'/me {gender:зашёл|зашла} в раздел \'Выговоры\''},
			{'/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор'},
			{'/do Выговор был убран из личного дела сотрудника.'},
			{'/unfwarn %s', id},
		})
	end)
	
	sampRegisterChatCommand('fmute', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/fmute %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id,mutetime,reason = param:match('(%d+) (%d+) (.+)')
		if id == nil or reason == nil or mutetime == nil then
			return ASHelperMessage('/fmute [id] [время] [причина]')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:включил|включила} планшет'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы'},
			{'/me {gender:выбрал|выбрала} нужного сотрудника'},
			{'/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\''},
			{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
			{'/fmute %s %s %s', id, mutetime, reason},
		})
	end)

	sampRegisterChatCommand('funmute', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/funmute %s',param))
		end
		if AshSettings.MainSettings.myrankint < 9 then
			return ASHelperMessage('Данная команда доступна с 9-го ранга.')
		end
		local id = param:match('(%d+)')
		if id == nil then
			return ASHelperMessage('/funmute [id]')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me {gender:достал|достала} планшет из кармана'},
			{'/me {gender:включил|включила} планшет'},
			{'/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками %s\'', AshSettings.MainSettings.replaceash and AshSettings.MainSettings.replaceashto or 'Автошколы'},
			{'/me {gender:выбрал|выбрала} нужного сотрудника'},
			{'/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\''},
			{'/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\''},
			{'/funmute %s', id},
		})
	end)

	sampRegisterChatCommand('expel', function(param)
		if not AshSettings.MainSettings.dorponcmd then
			return sampSendChat(format('/expel %s',param))
		end
		if AshSettings.MainSettings.myrankint < 2 then
			return ASHelperMessage('Данная команда доступна с 2-го ранга.')
		end
		local id,reason = param:match('(%d+) (.+)')
		if id == nil or reason == nil then
			return ASHelperMessage('/expel [id] [причина]')
		end
		if sampIsPlayerPaused(id) then
			return ASHelperMessage('Игрок находится в АФК!')
		end
		return sendchatarray(AshSettings.MainSettings.playcd, {
			{'/me {gender:схватил|свхатила} человека за руку, и {gender:повёл|повела} к выходу'},
			{'/me открыв дверь рукой, {gender:вывел|вывела} человека на улицу'},
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
			wait(1000)
			if AshSettings.MainSettings.changelog then
				ASHelperMessage('Обновление успешно загружено. Список изменений: {MC}/ashlog')
				AshSettings.MainSettings.changelog = false
				inicfg.save(AS_Settings, 'AS Helper.ini')
			end
			ASHelperMessage(format('Успешная загрузка скрипта,\nверсия {MC}%s{WC}.\nНастроить скрипт: {MC}/ash', thisScript().version))
			getmyrank = true
			sampSendChat('/wbook')
			sampSendChat('/stats')
		end
		scriptInitialized = true
	end)

	autodoor = lua_thread.create(function()
		while AshSettings.MainSettings.autodoor do
			for key, hObj in pairs(getAllObjects()) do
				if doesObjectExist(hObj) then
					local objModel = getObjectModel(hObj)
					local res, ox, oy, oz = getObjectCoordinates(hObj)
					local px, py, pz = getCharCoordinates(PLAYER_PED)
					local distance = getDistanceBetweenCoords3d(px, py, pz, ox, oy, oz)
					if objModel == 1808 or objModel == 975 then
						if distance < 4 then
							local data = allocateMemory(68)
							local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
							sampStorePlayerOnfootData(myId, data)
						
							local weaponId = getCurrentCharWeapon(PLAYER_PED)
							setStructElement(data, 36, 1, weaponId + 192, true)
							sampSendOnfootData(data)
							freeMemory(data)
						end
					end
				end
			end
			wait(400)
		end
	end)

	while true do
		if getCharPlayerIsTargeting() then
			if AshSettings.MainSettings.fmtype == 0 then
				if AshSettings.MainSettings.createmarker then
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
				if isKeysDown(AshSettings.MainSettings.usefastmenu) and not sampIsChatInputActive() then
					if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
						setVirtualKeyDown(0x02,false)
						fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
						ASHelperMessage(format('Вы использовали Меню взаимодействия на: %s [%s]',gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
						wait(0)
						windows.imgui_fm[0] = true
					end
				end
			end

			if isKeysDown(AshSettings.MainSettings.fastexpel) and not sampIsChatInputActive() and AshSettings.MainSettings.dofastexpel then
				if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
					if AshSettings.MainSettings.myrankint > 2 then
						local id, reason = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting()))), AshSettings.MainSettings.expelreason
						if #reason > 0 then
							if not sampIsPlayerPaused(id) then
								sendchatarray(AshSettings.MainSettings.playcd, {
									{'/me {gender:схватил|схватила} человека за руку, и {gender:повёл|повела} к выходу'},
									{'/me открыв дверь рукой, {gender:вывел|вывела} человека на улицу'},
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

		if isKeysDown(AshSettings.MainSettings.fastscreen) and AshSettings.MainSettings.dofastscreen and (clock() - tHotKeyData.lasted > 0.1) and not sampIsChatInputActive() then
			sampSendChat('/time')
			wait(500)
			setVirtualKeyDown(0x77, true)
			wait(0)
			setVirtualKeyDown(0x77, false)
		end

		if (inprocess or #sellList > 0) and isKeyDown(0x12) and isKeyJustPressed(0x4B) then
			if inprocess then
				inprocess:terminate()
				inprocess = nil
			end
			if #sellList > 0 then
				sellList = {sellPerson = 0, sellLicense = 0, lastSellTime = 0, checking_medcard = {status = 0, licenses = ''},}
			end
			ASHelperMessage('Отыгровка успешно прервана!')
		end

		if isKeyDown(0x11) and isKeyJustPressed(0x52) then
			NoErrors = true
			print('{FFFF00}Скрипт был перезагружен комбинацией клавиш Ctrl + R')
		end

		if AshSettings.MainSettings.playdubinka then
			local weapon = getCurrentCharWeapon(playerPed)
			if weapon == 3 and not rp_check then 
				sampSendChat('/me сняв дубинку с пояса {gender:взял|взяла} в правую руку')
				rp_check = true
			elseif weapon ~= 3 and rp_check then
				sampSendChat('/me {gender:повесил|повесила} дубинку на пояс')
				rp_check = false
			end
		end

		for key = 1, #AshSettings.Binder.BindsName do
			if isKeysDown(AshSettings.Binder.BindsKeys[key]) and not sampIsChatInputActive() and AshSettings.Binder.BindsType[key] == 1 then
				if not inprocess then
					local temp = 0
					local temp2 = 0
					for _ in gmatch(tostring(AshSettings.Binder.BindsAction[key]), '[^~]+') do
						temp = temp + 1
					end

					inprocess = lua_thread.create(function()
						for bp in gmatch(tostring(AshSettings.Binder.BindsAction[key]), '[^~]+') do
							temp2 = temp2 + 1
							if not find(bp, '%{delay_(%d+)%}') then
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(AshSettings.Binder.BindsDelay[key])
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
					ASHelperMessage('Не торопитесь, Вы уже отыгрываете что-то! Прервать отыгровку: {MC}Alt{WC} + {MC}K{WC}')
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

		if AshSettings.Checker.state and ((scriptInitialized and AshSettings.MainSettings.guiinform ~= true) and true or isPlayerInForm()) then
			local ch = checker_variables
			local cfgch = AshSettings.Checker
			
			local offset = cfgch.font_offset
			
			local col_title = changeColorAlpha(cfgch.col_title, cfgch.font_alpha)
			local col_default = changeColorAlpha(cfgch.col_default, cfgch.font_alpha)
			local col_no_work = changeColorAlpha(cfgch.col_no_work, cfgch.font_alpha)

			if AshSettings.Checker.confirm then
				local render_text = 'Сотрудники онлайн ['..(ch.online.online or 0)..' | AFK: '..(ch.online.afk or 0)..'] {909090}'..(ch.last_check == 0 and '' or '- '..cfgch.delay - (math.floor(clock() - ch.last_check))..' с.')
				local text_lenght = renderGetFontDrawTextLength(ch.font, render_text)
				if renderFontDrawClickableText(true, ch.font, render_text, cfgch.align == 0 and cfgch.posX or cfgch.align == 1 and cfgch.posX - text_lenght / 2 or cfgch.posX - text_lenght, cfgch.posY, col_title, 0x90FFFFFF) then
					if not checker_variables.await.members then
						sampSendChat('/members')
						checker_variables.await.members = true
						checker_variables.dontShowMeMembers = false
						checker_variables.last_check = clock()
					end
				end
				for k, member in ipairs(ch.online) do
					if k <= tonumber(checker_variables.online.online) then
						local render_color = cfgch.show_uniform and (member.uniform and col_default or col_no_work) or col_default

						local rank = cfgch.show_rank and '['..member.rank..'] ' or ''
						local nick = member.nickname
						local id = cfgch.show_id and '('..member.id..')' or ''
						local afk = cfgch.show_afk and getAfk(member.rank, member.afk, render_color) or ''
						local warns = cfgch.show_warn and ' - Warns: '..member.warns or ''
						local specwarns = (cfgch.show_warn and cfgch.show_specwarn) and ' ['..member.specwarns..']' or ''
						local quests = cfgch.show_quests and ' - Quests: '..member.quests or ''
						local mute = cfgch.show_mute and member.mute and ' || Muted' or ''
						local demorgan = cfgch.show_demorgan and member.demorgan and ' || Demorgan' or ''
						local near = cfgch.show_near and (member.near and ' [N]' or '') or ''
						local note = AshSettings.Checker.Notes[nick] and getNote(AshSettings.Checker.Notes[nick], render_color) or ''

						local render_text = format('%s%s%s%s%s%s%s%s%s%s%s', rank, nick, id, afk, warns, specwarns, quests, mute, demorgan, near, note)
						local text_lenght = renderGetFontDrawTextLength(ch.font, render_text)

						if renderFontDrawClickableText(true, ch.font, render_text, cfgch.align == 0 and cfgch.posX or cfgch.align == 1 and cfgch.posX - text_lenght / 2 or cfgch.posX - text_lenght, cfgch.posY + k * offset, render_color, render_color) then
							imgui.StrCopy(ch.note_input, u8(AshSettings.Checker.Notes[nick] or ''))
							checker_variables.temp_player_data = member
						end
					end
				end
			else
				renderFontDrawText(ch.font, '{ff6633}[autoschool]:{ffffff} Использование чекера не подтверждено. Подтвердить можно в:\n{ff6633}/ash - Настройки - Чекер сотрудников', cfgch.posX, cfgch.posY, 0xFFFFFFFF)
			end
		end

		if AshSettings.MainSettings.autoupdate and clock() - autoupd[0] > 600 then
			checkUpdates('https://raw.githubusercontent.com/Just-Mini/ASHelper/main/Jsons/update.json')
			autoupd[0] = clock()
		end

		if clock() - checker_variables.last_check >= AshSettings.Checker.delay and clock() - checker_variables.lastDialogWasActive > 2 then
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
			patches = {
				active = false,
				text = [[
 - Убрано КД в 5 секунд после /do и /todo
 - Исправлен критический баг с крашем]]
			},
		},

		{
			version = '3.2',
			date = '07.08.2022',
			text = {
				'Добавлена функция автооткрытия дверей',
				'Теперь после нажатия кнопки \'Выгнать\' нужно подтверждать причину',
				'Изменена отыгровка /expel',
				'Небольшие косметические изменения в скрипте',
			},
			patches = {
				active = false,
				text = [[
 - Исправлен критический баг с крашем
 - Добавлена лицензия на работу механика
 - Исправлен встроенный чекер]]
			},
		},

		{
			version = '3.3',
			date = '05.03.2023',
			text = {
				'Убрана зависимость от lfs',
				'Убрана зависимость от PNG файлов, теперь они находятся закодированными',
				'Изменена система подгрузки правил сервера',
				'Убраны некоторые ненужные функции',
				'Обновлены все правила серверов на актуальные',
			},
		},

		{
			version = '3.4',
			date = '28.06.2025',
			text = {
				'Полностью изменена окно и система продажи лицензий {HINT:1. Переделан дизайн окна продажи\n2. Добавлены все недостающие лицензии\n3. Прайс-лист сканируется сам, вам не требуется ничего вводить\nНу там еще много всего, разберётесь}',
				'Окно статистики было заменено окном чекера серверных заданий',
				'Изменена система сохранения настроек',
				'Убрана вся система подкачки правил и проверки устава {HINT:Кто бы мог подумать что у аризоны будет столько серверов кек}',
				'Убраны все темы, кроме трёх (оранжевая, фиолетовая, Monet)',
				'Добавлена автопочинка (выкл. по умолчанию) и автосортировка знаков',
				'Убраны все скриптовые уведомления',
				'Добавлена (снова) функция автооткрытия дверей',
				'Убрана зависимость от MoonMonet (теперь это опционально)',
				'Изменено окно собеседований'
			},
			patches = {
				active = false,
				text = [[
 - Доработано меню собеседования]]
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