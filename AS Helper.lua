script_name('AS Helper')
script_description('/ash')
script_author('JustMini')

require "lib.moonloader"
local dlstatus = require "moonloader".download_status
local inicfg = require "inicfg"
local vkeys = require "vkeys"
local imguicheck, imgui = pcall(require, "imgui")
local sampevcheck, sampev = pcall(require, "lib.samp.events")
local encodingcheck, encoding = pcall(require, "encoding")
local facheck, fa = pcall(require, "fAwesome5")

local configuration = inicfg.load({
	main_settings = {
		myrankint = 0,
		myrank = "",
		myname = '',
		myaccent = '',
		useservername = true,
		useaccent = false,
		avtoprice = 5000,
		motoprice = 10000,
		ribaprice = 30000,
		lodkaprice = 30000,
		gunaprice = 50000,
		huntprice = 100000,
		kladprice = 200000,
		usefastmenu = 'E',
		fastscreen = 'F4',
		dofastscreen = true,
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = 4281558783,
		gender = 0,
		style = 0
	},
	my_stats = {
		avto = 0,
		moto = 0,
		riba = 0,
		lodka = 0,
		guns = 0,
		hunt = 0,
		klad = 0
	},
	binder_settings = {
		totalslots = 50
	},
	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, "AS Helper")

local cmdhelp 				= 'ash'
local cmdbind 				= "ashbind"
local cmdcmds 				= "ashcmds"
local cmdupdate 			= "ashupd"
local cmdstats 				= "ashstats"

local cd 					= 2000

local emptykey1 = {}
local emptykey2 = {}

local cansell 				= false
local inprocess 			= false
local devmaxrankp			= false
local NoErrors				= false
local scriptvernumb 		= 18

if imguicheck and encodingcheck then
	u8 						= encoding.UTF8
	encoding.default 		= 'CP1251'

	imgui_settings 			= imgui.ImBool(false)
	imgui_fm 				= imgui.ImBool(false)
	imgui_sobes				= imgui.ImBool(false)
	imgui_binder 			= imgui.ImBool(false)
	imgui_stats				= imgui.ImBool(false)

	useaccent 				= imgui.ImBool(configuration.main_settings.useaccent)
	createmarker 			= imgui.ImBool(configuration.main_settings.createmarker)
	useservername 			= imgui.ImBool(configuration.main_settings.useservername)
	dorponcmd				= imgui.ImBool(configuration.main_settings.dorponcmd)
	replacechat				= imgui.ImBool(configuration.main_settings.replacechat)
	dofastscreen			= imgui.ImBool(configuration.main_settings.dofastscreen)
	myname 					= imgui.ImBuffer(configuration.main_settings.myname, 256)
	myaccent 				= imgui.ImBuffer(configuration.main_settings.myaccent, 256)

	ComboBox_select 		= imgui.ImInt(0)
	ComboBox_arr 			= {u8"Авто",u8"Мото",u8"Рыболовство",u8"Плавание",u8"Оружие",u8"Охота",u8"Раскопки"}
	avtoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7)
	motoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7)
	ribaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7)
	lodkaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7)
	gunaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7)
	huntprice 				= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7)
	kladprice				= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7)

	StyleBox_select			= imgui.ImInt(configuration.main_settings.style)
	StyleBox_arr			= {u8"Тёмно-оранжевая (transp.)",u8"Тёмно-красная (not transp.)",u8"Светло-синяя (not transp.)",u8"Фиолетовая (not transp.)",u8"Светло-тёмная (not transp.)",u8"Тёмно-зеленая (not transp.)"}
	RChatColor 				= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
	DChatColor 				= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
	ASChatColor 			= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())

	expelbuff 				= imgui.ImBuffer(200)

	uninvitebuf 			= imgui.ImBuffer(256)
	blacklistbuf 			= imgui.ImBuffer(256)
	uninvitebox 			= imgui.ImBool(false)

	blacklistbuff 			= imgui.ImBuffer(256)

	fwarnbuff 				= imgui.ImBuffer(256)

	fmutebuff 				= imgui.ImBuffer(256)
	fmuteint 				= imgui.ImInt(0)

	binderbuff 				= imgui.ImBuffer(4096)
	bindername 				= imgui.ImBuffer(40)
	binderdelay 			= imgui.ImBuffer(7)
	bindertype 				= imgui.ImInt(0)
	bindercmd 				= imgui.ImBuffer(15)

	search_ustav 			= imgui.ImBuffer(256)

	windowtype				= imgui.ImInt(0)
	settingswindow			= imgui.ImInt(0)
	sobesetap				= imgui.ImInt(0)

	waitingaccept 			= false
	getmyrank 				= false
	mcvalue 				= true
	passvalue 				= true
	skiporcancel			= true

	Ranks_select 			= imgui.ImInt(0)
	Ranks_arr 				= {u8"[1] Стажёр",u8"[2] Консультант",u8"[3] Лицензёр",u8"[4] Мл. Инструктор",u8"[5] Инструктор",u8"[6] Менеджер",u8"[7] Ст. Менеджер",u8"[8] Помощник директора",u8"[9] Директор"}

	gender 					= imgui.ImInt(configuration.main_settings.gender)
	gender_arr 				= {u8"Мужской",u8"Женский"}

	sobesdecline_select 	= imgui.ImInt(0)
	sobesdecline_arr 		= {u8"Плохое РП",u8"Не было РП",u8"Плохая грамматика",u8"Ничего не показал",u8"Другое"}

	imgui.SwitchContext()
	local style 						= imgui.GetStyle()
	local colors 						= style.Colors
	local clr 							= imgui.Col
	local ImVec4 						= imgui.ImVec4
	local ImVec2 						= imgui.ImVec2

	style.WindowTitleAlign 				= ImVec2(0.5, 0.5)
	style.WindowPadding 				= ImVec2(15, 15)
	style.WindowRounding 				= 6.0
	style.FramePadding 					= ImVec2(5, 5)
	style.FrameRounding 				= 5.0
	style.ItemSpacing 					= ImVec2(12, 8)
	style.ItemInnerSpacing 				= ImVec2(8, 6)
	style.IndentSpacing 				= 25.0
	style.ScrollbarSize 				= 15.0
	style.ScrollbarRounding 			= 9.0
	style.GrabMinSize 					= 5.0
	style.GrabRounding 					= 3.0
	style.ChildWindowRounding 			= 5.0

	function checkstyle()
		if configuration.main_settings.style == 0 then
			colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
			colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
			colors[clr.ChildWindowBg] 			= ImVec4(0.10, 0.09, 0.12, 0.50)
			colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
			colors[clr.Border] 					= ImVec4(0.40, 0.40, 0.53, 0.18)
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
			colors[clr.ComboBg] 				= ImVec4(0.19, 0.18, 0.21, 1.00)
			colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
			colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
			colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.Header] 					= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.HeaderHovered] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.HeaderActive] 			= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.CloseButton] 			= ImVec4(0.91, 0.44, 0.00, 1.00)
			colors[clr.CloseButtonHovered] 		= ImVec4(0.40, 0.39, 0.38, 0.39)
			colors[clr.CloseButtonActive] 		= ImVec4(0.40, 0.39, 0.38, 1.00)
			colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.00, 0.00, 0.00, 0.30)
			textcolorinhex						= "{ccccd4}"
		elseif configuration.main_settings.style == 1 then
			colors[clr.Text]                   	= ImVec4(0.95, 0.96, 0.98, 1.00)
			colors[clr.TextDisabled]           	= ImVec4(0.29, 0.29, 0.29, 1.00)
			colors[clr.WindowBg]               	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.ChildWindowBg]          	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.PopupBg]                	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.Border]                 	= ImVec4(1.00, 0.28, 0.28, 0.50)
			colors[clr.BorderShadow]           	= ImVec4(1.00, 1.00, 1.00, 0.00)
			colors[clr.FrameBg]                	= ImVec4(0.22, 0.22, 0.22, 1.00)
			colors[clr.FrameBgHovered]         	= ImVec4(0.18, 0.18, 0.18, 1.00)
			colors[clr.FrameBgActive]          	= ImVec4(0.09, 0.12, 0.14, 1.00)
			colors[clr.TitleBg]                	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgActive]          	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgCollapsed]       	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.MenuBarBg]              	= ImVec4(0.20, 0.20, 0.20, 1.00)
			colors[clr.ScrollbarBg]            	= ImVec4(0.02, 0.02, 0.02, 0.39)
			colors[clr.ScrollbarGrab]          	= ImVec4(0.36, 0.36, 0.36, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
			colors[clr.ScrollbarGrabActive]    	= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.ComboBg]                	= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.CheckMark]              	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrab]             	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrabActive]       	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.Button]                 	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.ButtonHovered]          	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ButtonActive]           	= ImVec4(1.00, 0.20, 0.20, 1.00)
			colors[clr.Header]                 	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.HeaderHovered]          	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.HeaderActive]           	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.ResizeGrip]             	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.ResizeGripHovered]      	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.ResizeGripActive]       	= ImVec4(1.00, 0.19, 0.19, 1.00)
			colors[clr.CloseButton]            	= ImVec4(1.00, 0.00, 0.00, 0.50)
			colors[clr.CloseButtonHovered]     	= ImVec4(1.00, 0.00, 0.00, 0.60)
			colors[clr.CloseButtonActive]      	= ImVec4(1.00, 0.00, 0.00, 0.70)
			colors[clr.PlotLines]              	= ImVec4(0.61, 0.61, 0.61, 1.00)
			colors[clr.PlotLinesHovered]       	= ImVec4(1.00, 0.43, 0.35, 1.00)
			colors[clr.PlotHistogram]          	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
			colors[clr.TextSelectedBg]         	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.00, 0.00, 0.00, 0.30)
			textcolorinhex						= "{f2f5fa}"
		elseif configuration.main_settings.style == 2 then
			colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.TextDisabled]   			= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.ChildWindowBg]        	= ImVec4(0.96, 0.96, 0.96, 1.00)
			colors[clr.PopupBg]              	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.Border]               	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.BorderShadow]         	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]              	= ImVec4(0.68, 0.68, 0.68, 0.50)
			colors[clr.FrameBgHovered]       	= ImVec4(0.82, 0.82, 0.82, 1.00)
			colors[clr.FrameBgActive]        	= ImVec4(0.76, 0.76, 0.76, 1.00)
			colors[clr.TitleBg]              	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgCollapsed]     	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgActive]        	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.MenuBarBg]            	= ImVec4(0.00, 0.37, 0.78, 1.00)
			colors[clr.ScrollbarBg]          	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ScrollbarGrab]        	= ImVec4(0.00, 0.35, 1.00, 0.78)
			colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
			colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
			colors[clr.ComboBg]              	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.CheckMark]            	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrab]           	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrabActive]     	= ImVec4(0.00, 0.39, 1.00, 0.71)
			colors[clr.Button]               	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.ButtonHovered]        	= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.ButtonActive]         	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.Header]               	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.HeaderHovered]        	= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.HeaderActive]         	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.ResizeGrip]           	= ImVec4(0.00, 0.39, 1.00, 0.59)
			colors[clr.ResizeGripHovered]    	= ImVec4(0.00, 0.27, 1.00, 0.59)
			colors[clr.ResizeGripActive]     	= ImVec4(0.00, 0.25, 1.00, 0.63)
			colors[clr.CloseButton]          	= ImVec4(0.00, 0.35, 0.96, 0.71)
			colors[clr.CloseButtonHovered]   	= ImVec4(0.00, 0.31, 0.88, 0.69)
			colors[clr.CloseButtonActive]    	= ImVec4(0.00, 0.25, 0.88, 0.67)
			colors[clr.PlotLines]            	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotLinesHovered]     	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogram]        	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.00, 0.35, 0.92, 0.78)
			colors[clr.TextSelectedBg]       	= ImVec4(0.00, 0.47, 1.00, 0.59)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.20, 0.20, 0.20, 0.35)
			textcolorinhex						= "{7d7d7d}"
		elseif configuration.main_settings.style == 3 then
			colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.WindowBg]              	= ImVec4(0.14, 0.12, 0.16, 1.00)
			colors[clr.ChildWindowBg]         	= ImVec4(0.30, 0.20, 0.39, 0.00)
			colors[clr.PopupBg]               	= ImVec4(0.05, 0.05, 0.10, 0.90)
			colors[clr.Border]                	= ImVec4(0.89, 0.85, 0.92, 0.30)
			colors[clr.BorderShadow]          	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]               	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.FrameBgHovered]        	= ImVec4(0.41, 0.19, 0.63, 0.68)
			colors[clr.FrameBgActive]         	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TitleBg]               	= ImVec4(0.41, 0.19, 0.63, 0.45)
			colors[clr.TitleBgCollapsed]      	= ImVec4(0.41, 0.19, 0.63, 0.35)
			colors[clr.TitleBgActive]         	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.MenuBarBg]             	= ImVec4(0.30, 0.20, 0.39, 0.57)
			colors[clr.ScrollbarBg]           	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.ScrollbarGrab]         	= ImVec4(0.41, 0.19, 0.63, 0.31)
			colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ComboBg]               	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.CheckMark]             	= ImVec4(0.56, 0.61, 1.00, 1.00)
			colors[clr.SliderGrab]            	= ImVec4(0.41, 0.19, 0.63, 0.24)
			colors[clr.SliderGrabActive]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.Button]                	= ImVec4(0.41, 0.19, 0.63, 0.44)
			colors[clr.ButtonHovered]         	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.ButtonActive]          	= ImVec4(0.64, 0.33, 0.94, 1.00)
			colors[clr.Header]                	= ImVec4(0.41, 0.19, 0.63, 0.76)
			colors[clr.HeaderHovered]         	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.HeaderActive]          	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ResizeGrip]            	= ImVec4(0.41, 0.19, 0.63, 0.20)
			colors[clr.ResizeGripHovered]     	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ResizeGripActive]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.CloseButton]           	= ImVec4(1.00, 1.00, 1.00, 0.75)
			colors[clr.CloseButtonHovered]    	= ImVec4(0.88, 0.74, 1.00, 0.59)
			colors[clr.CloseButtonActive]     	= ImVec4(0.88, 0.85, 0.92, 1.00)
			colors[clr.PlotLines]             	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotLinesHovered]      	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.PlotHistogram]         	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TextSelectedBg]        	= ImVec4(0.41, 0.19, 0.63, 0.43)
			colors[clr.ModalWindowDarkening]  	= ImVec4(0.20, 0.20, 0.20, 0.35)
			textcolorinhex						= "{ffffff}"
		elseif configuration.main_settings.style == 4 then
			colors[clr.Text]                   	= ImVec4(0.90, 0.90, 0.90, 1.00)
			colors[clr.TextDisabled]           	= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.WindowBg]               	= ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.ChildWindowBg]          	= ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.PopupBg]                	= ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.Border]                 	= ImVec4(0.82, 0.77, 0.78, 1.00)
			colors[clr.BorderShadow]           	= ImVec4(0.35, 0.35, 0.35, 0.66)
			colors[clr.FrameBg]                	= ImVec4(1.00, 1.00, 1.00, 0.28)
			colors[clr.FrameBgHovered]         	= ImVec4(0.68, 0.68, 0.68, 0.67)
			colors[clr.FrameBgActive]          	= ImVec4(0.79, 0.73, 0.73, 0.62)
			colors[clr.TitleBg]                	= ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.TitleBgActive]          	= ImVec4(0.46, 0.46, 0.46, 1.00)
			colors[clr.TitleBgCollapsed]       	= ImVec4(0.00, 0.00, 0.00, 1.00)
			colors[clr.MenuBarBg]              	= ImVec4(0.00, 0.00, 0.00, 0.80)
			colors[clr.ScrollbarBg]            	= ImVec4(0.00, 0.00, 0.00, 0.60)
			colors[clr.ScrollbarGrab]          	= ImVec4(1.00, 1.00, 1.00, 0.87)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(1.00, 1.00, 1.00, 0.79)
			colors[clr.ScrollbarGrabActive]    	= ImVec4(0.80, 0.50, 0.50, 0.40)
			colors[clr.ComboBg]                	= ImVec4(0.24, 0.24, 0.24, 0.99)
			colors[clr.CheckMark]              	= ImVec4(0.99, 0.99, 0.99, 0.52)
			colors[clr.SliderGrab]             	= ImVec4(1.00, 1.00, 1.00, 0.42)
			colors[clr.SliderGrabActive]       	= ImVec4(0.76, 0.76, 0.76, 1.00)
			colors[clr.Button]                 	= ImVec4(0.51, 0.51, 0.51, 0.60)
			colors[clr.ButtonHovered]          	= ImVec4(0.68, 0.68, 0.68, 1.00)
			colors[clr.ButtonActive]           	= ImVec4(0.67, 0.67, 0.67, 1.00)
			colors[clr.Header]                 	= ImVec4(0.72, 0.72, 0.72, 0.54)
			colors[clr.HeaderHovered]          	= ImVec4(0.92, 0.92, 0.95, 0.77)
			colors[clr.HeaderActive]           	= ImVec4(0.82, 0.82, 0.82, 0.80)
			colors[clr.Separator]              	= ImVec4(0.73, 0.73, 0.73, 1.00)
			colors[clr.SeparatorHovered]       	= ImVec4(0.81, 0.81, 0.81, 1.00)
			colors[clr.SeparatorActive]        	= ImVec4(0.74, 0.74, 0.74, 1.00)
			colors[clr.ResizeGrip]             	= ImVec4(0.80, 0.80, 0.80, 0.30)
			colors[clr.ResizeGripHovered]      	= ImVec4(0.95, 0.95, 0.95, 0.60)
			colors[clr.ResizeGripActive]       	= ImVec4(1.00, 1.00, 1.00, 0.90)
			colors[clr.CloseButton]            	= ImVec4(0.45, 0.45, 0.45, 0.50)
			colors[clr.CloseButtonHovered]     	= ImVec4(0.70, 0.70, 0.90, 0.60)
			colors[clr.CloseButtonActive]      	= ImVec4(0.70, 0.70, 0.70, 1.00)
			colors[clr.PlotLines]              	= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.PlotLinesHovered]       	= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.PlotHistogram]          	= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.TextSelectedBg]         	= ImVec4(1.00, 1.00, 1.00, 0.35)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.88, 0.88, 0.88, 0.35)
			textcolorinhex						= "{e5e5e5}"
		elseif configuration.main_settings.style == 5 then
			colors[clr.Text]                   	= ImVec4(0.90, 0.90, 0.90, 1.00)
			colors[clr.TextDisabled]           	= ImVec4(0.60, 0.60, 0.60, 1.00)
			colors[clr.WindowBg]               	= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.ChildWindowBg]          	= ImVec4(0.10, 0.10, 0.10, 1.00)
			colors[clr.PopupBg]                	= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.Border]                 	= ImVec4(0.70, 0.70, 0.70, 0.40)
			colors[clr.BorderShadow]           	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]                	= ImVec4(0.15, 0.15, 0.15, 1.00)
			colors[clr.FrameBgHovered]         	= ImVec4(0.19, 0.19, 0.19, 0.71)
			colors[clr.FrameBgActive]          	= ImVec4(0.34, 0.34, 0.34, 0.79)
			colors[clr.TitleBg]                	= ImVec4(0.00, 0.69, 0.33, 0.80)
			colors[clr.TitleBgActive]          	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.TitleBgCollapsed]       	= ImVec4(0.00, 0.69, 0.33, 0.50)
			colors[clr.MenuBarBg]              	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.ScrollbarBg]            	= ImVec4(0.16, 0.16, 0.16, 1.00)
			colors[clr.ScrollbarGrab]          	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ScrollbarGrabActive]    	= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.ComboBg]                	= ImVec4(0.20, 0.20, 0.20, 0.99)
			colors[clr.CheckMark]              	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrab]             	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrabActive]       	= ImVec4(0.00, 0.77, 0.37, 1.00)
			colors[clr.Button]                 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ButtonHovered]          	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ButtonActive]           	= ImVec4(0.00, 0.87, 0.42, 1.00)
			colors[clr.Header]                 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.HeaderHovered]          	= ImVec4(0.00, 0.76, 0.37, 0.57)
			colors[clr.HeaderActive]           	= ImVec4(0.00, 0.88, 0.42, 0.89)
			colors[clr.Separator]              	= ImVec4(1.00, 1.00, 1.00, 0.40)
			colors[clr.SeparatorHovered]       	= ImVec4(1.00, 1.00, 1.00, 0.60)
			colors[clr.SeparatorActive]        	= ImVec4(1.00, 1.00, 1.00, 0.80)
			colors[clr.ResizeGrip]             	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ResizeGripHovered]      	= ImVec4(0.00, 0.76, 0.37, 1.00)
			colors[clr.ResizeGripActive]       	= ImVec4(0.00, 0.86, 0.41, 1.00)
			colors[clr.CloseButton]            	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.CloseButtonHovered]     	= ImVec4(0.00, 0.88, 0.42, 1.00)
			colors[clr.CloseButtonActive]      	= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.PlotLines]              	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotLinesHovered]       	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.PlotHistogram]          	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.TextSelectedBg]         	= ImVec4(0.00, 0.69, 0.33, 0.72)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.17, 0.17, 0.17, 0.48)
			textcolorinhex						= "{e5e5e5}"
		end
	end

	function imgui.LockedButton(text, size)
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		imgui.Button(text, size)
		imgui.PopStyleColor(4)
	end

	function imgui.GreenButton(text, size)
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
		local button = imgui.Button(text, size)
		imgui.PopStyleColor(3)
		return button
	end

	function imgui.CenterTextColoredRGB(text)
		local width = imgui.GetWindowWidth()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local ImVec4 = imgui.ImVec4
	
		local explode_argb = function(argb)
			local a = bit.band(bit.rshift(argb, 24), 0xFF)
			local r = bit.band(bit.rshift(argb, 16), 0xFF)
			local g = bit.band(bit.rshift(argb, 8), 0xFF)
			local b = bit.band(argb, 0xFF)
			return a, r, g, b
		end
	
		local getcolor = function(color)
			if color:sub(1, 6):upper() == 'SSSSSS' then
				local r, g, b = colors[1].x, colors[1].y, colors[1].z
				local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
				return ImVec4(r, g, b, a / 255)
			end
			local color = type(color) == 'string' and tonumber(color, 16) or color
			if type(color) ~= 'number' then return end
			local r, g, b, a = explode_argb(color)
			return imgui.ImColor(r, g, b, a):GetVec4()
		end
	
		local render_text = function(text_)
			for w in text_:gmatch('[^\r\n]+') do
				local textsize = w:gsub('{.-}', '')
				local text_width = imgui.CalcTextSize(u8(textsize))
				imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
				local text, colors_, m = {}, {}, 1
				w = w:gsub('{(......)}', '{%1FF}')
				while w:find('{........}') do
					local n, k = w:find('{........}')
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
						imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
						imgui.SameLine(nil, 0)
					end
					imgui.NewLine()
				else
					imgui.Text(u8(w))
				end
			end
		end
		render_text(text)
	end

	function imgui.Hint(text, delay, action)
		if imgui.IsItemHovered() then
			if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
			local alpha = (os.clock() - go_hint) * 5
			if os.clock() >= go_hint then
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
				imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
					imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.80))
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(450)
						imgui.CenterTextColoredRGB('{FFFFFF}Подсказка')
						imgui.CenterTextColoredRGB("{FFFFFF}"..text)
						if action ~= nil then
							imgui.Text('\n '..action)
						end
						if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					imgui.PopStyleColor()
				imgui.PopStyleVar(2)
			end
		end
	end

	function changelog()
		if imgui.BeginPopupModal(u8("Список изменений"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.CenterTextColoredRGB("Версия скрипта: 2.0")
			imgui.BeginChild("##ChangeLog", imgui.ImVec2(700, 330), false)
			imgui.InputTextMultiline("Read",imgui.ImBuffer(u8([[
Версия 2.0
 - Добавлен список изменений
 - Исправлена проверка обновлений через /ash
 - Кардинально изменено главное меню /ash
 - Добавлены разные стили окон
 - Добавлены настройки цветов /r чата и /d чата
 - Добавлена функция просмотра правил
 - Добавлена функция быстрого /time + скрин
 - Добавлено автоопределение пола
 - Исправлен баг с ударом при принятии человека в организацию
 - Добавлена функция удаления конфига

Версия 1.1 - 1.9
 - Добавлены подсказки в биндере
 - Изменена система собеседований
 - На ESC теперь закрываются окна
 - Сделано более удобное изменение ранга
 - Исправлен баг с непродающимися лицензиями
 - Теперь скрипт вне зависимости от вашего времени на системе подстраивается под МСК часовой пояс.
 - Добавлена функция принятие на должность Консультанта
 - При зажатом ALT пропадает курсор во время открытых око
 - Добавлена статистика проданных лицензий (/ashstats)
 - Добавлены замены на серверные сообщения
 - Добавлена функция проверки устава
 - Исправлены баги

Версия 1.0
 - Релиз]])),imgui.ImVec2(-1, -1), imgui.InputTextFlags.ReadOnly)
		imgui.EndChild()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
		if imgui.Button(u8"Закрыть",imgui.ImVec2(200,25)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
		end
	end

	function ustav()
		if imgui.BeginPopupModal(u8("Устав автошколы"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			imgui.PushItemWidth(200)
			imgui.PushAllowKeyboardFocus(false)
			imgui.InputText("##search_ustav", search_ustav, imgui.InputTextFlags.EnterReturnsTrue)
			imgui.PopAllowKeyboardFocus()
			imgui.PopItemWidth()
			if not imgui.IsItemActive() and #search_ustav.v == 0 then
				imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' Поиск по уставу')).x) / 2)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' Поиск по уставу'))
			end
			imgui.CenterTextColoredRGB('{868686}Двойной клик по строке, выведет её в поле ввода в чате')
			imgui.BeginChild("##Ustav", imgui.ImVec2(800, 400), true)
			local ustav = {
"Глава I. Общее положение",
"1.1. Данный документ обязан знать и соблюдать каждый сотрудник Автошколы.",
"1.2. За нарушения одного из пунктов данного документа последует наказание.",
"1.3. Незнание устава не освобождает от ответственности.",
"1.4. Сотрудники старшего состава [5-9] должны следить за порядком и дисциплиной в Автошколе.",
"1.5. Каждый сотрудник должен знать свои рабочие обязанности на каждой должности.",
"1.6.Каждый сотрудник обязан соблюдать субординацию.",
"1.7. Решение Управляющего является окончательным и обжалованию не подлежит.",
"1.8. Устав может исправляться/дополняться Управляющим автошколы.",
"1.9 Сотрудники Автошколы обязаны отвечать на задаваемые посетителями вопросы.",
"1.10 Курирующим составом являются Управляющий и Директора.",
"",
"Глава II. Этикет и субординация.",
"",
"2.1 Правила этикета - это свод правил поведения, принятых в определенных социальных кругах.",
"2.2 Субординация - это правила общения между сотрудниками, разными по должности.",
"2.3 Все сотрудники должны уважительно относиться ко всем окружающим их людям.",
"2.4 Сотрудник обязан уважать людей, которые ниже его по должности.",
"2.5 Допускаются обращение по должности, имени, 'сэр', 'коллега'.",
"2.6 Каждый работник автошколы обязан представиться перед клиентом.",
"2.7 Любой сотрудник автошколы обязан быть вежливым несмотря на поведение клиента.",
"",
"Глава III. Правила пользования т/с Автошколы.",
"",
"3.1 Правила пользования т/с должны соблюдать все сотрудники Автошколы.",
"3.2 Т/с разрешено брать по следующему принципу:",
"а) Лицензер[3] - мотоцикл;",
"б) 4-7 ранги - автомобиль;",
"в) Зам. Директора и выше - вертолет.",
"3.3 Запрещено использовать служебный транспорт в своих целях.",
"3.4 Запрещено использовать служебный транспорт вне рабочего дня, исключение: можно использовать для тренировок и т.п.",
"3.5 Запрещено использовать служебный транспорт, не предупредив об этом руководство.",
"",
"Глава IV. Рабочий график.",
"",
"4.1 Рабочее время (Понедельник-Пятница):",
"4.1.1 Дневная смена с 09:00 до 19:00",
"4.1.2 Перерыв на обед - с 13:00 до 14:00",
"4.1.3 Рабочее время (Суббота-Воскресенье):",
"4.1.4 Дневная смена с 10:00 до 18:00",
"4.1.5 Перерыв на обед - с 13:00 до 14:00",
"4.2 Каждый сотрудник Автошколы должен находиться в Автошколе во время рабочего времени.",
"4.3 Покидать здание разрешено только с разрешением старших. ( если их нет в штате - доложить по рации и сделать*screenshot + /time* )",
"4.4 За прогулы в рабочее время сотрудник получит выговор, либо же будет уволен.",
"4.5 По окончанию дневной смены все сотрудники должны сдать форму и дубинки кроме тех, кто остается на ночную смену.",
"4.6 Посещение ночной смены не является обязательным, но оно будет поощряться.",
"",
"Глава V. Обязанности сотрудников Автошколы.",
"",
"5.1 Каждый сотрудник обязан соблюдать и знать устав Автошколы.",
"5.2 Каждый сотрудник должен соблюдать субординацию в общении.",
"5.3 Каждый сотрудник обязан слушаться своего непосредственного руководителя.",
"5.4 Каждый сотрудник должен знать руководящий состав в лицо и по имени.",
"5.5 Директора и их заместители обязаны отчитываются о своей недельной работе при желании Управляющего.",
"5.6 Каждый сотрудник обязан соблюдать законодательство Штата.",
"5.7 Каждый сотрудник Автошколы обязан качественно выполнять свою поставленную работу.",
"5.8 Сотрудники обязаны подчиниться сотрудникам правоохранительной власти, при теракте или ограблении.",
"5.9 Сотрудники должны содействовать органам правоохранительной власти.",
"5.10 Сотрудники Автошколы, начиная с должности 'Консультант'[2] обязаны иметь спец. рацию 'Discord'.",
"5.11 Сотрудники старшего состава обязаны обучать и помогать сотрудникам, младше их по должности.",
"5.12 Сотрудники старшего состава должны посещать еженедельные собрания, неявка карается выговором.",
"",
"Глава VI. Отпуск и неактив.",
"",
"6.1 Отпуск разрешено брать с должности 'Инструктор[5]'.",
"6.2 Сотрудник имеет право подать заявку на получение отпуска за проделанные отчёты за неделю.",
"6.3 Отпуск возможно взять максимум на 7 календарных дней.",
"6.4 Если сотрудник не вернулся с отпуска в назначенное время, он будет уволен, без права восстановления не зависимо от занимаемой должности.",
"6.5 Во время неактива разрешено не заходить в игру.",
"6.6 Неактив можно брать максимум на 5 дней ( для заместителей 3 дня ).",
"6.7 Дни неактива не будут браться в учет в рассмотрении отчета.",
"6.8 Неактив можно взять два раза за срок Управляющего.",
"6.9 Несвоевременный выход из неактива без предупреждения может караться выговором и увольнением.",
"",
"Глава VII. Запреты и права для сотрудников Автошколы.",
"7.1 Сотрудник не имеет право нарушать устав и законодательство Штата.",
"7.2 Сотрудникам разрешено носить очки на лице.",
"7.3 Сотрудникам запрещено во время раб. дня носить яркие и неуместные аксесуары ( маски, шлемы, банданы ).",
"7.4 Запрещено спать вне раздевалки более 5-и минут. ( Искл.: 10 минут для Зама / Директора )",
"7.5 Сотрудники не имеют право уходить на обед, пока не обслужат людей, которые стоят в очереди.",
"7.6 Сотрудники не имеют право во время рабочего дня носить одежду не по дресс-коду.",
"7.7 Сотрудникам запрещено курить, пить, есть во время рабочего дня.",
"7.8 Запрещено неадекватное поведение в здании автошколы.",
"7.9 Сотруднику категорически запрещено хранить/употреблять/переносить психотропные вещества.",
"7.10 Сотрудникам запрещено ловить дома в рабочее время.",
"7.11 Сотруднику автошколы запрещено намекать/выпрашивать повышение.",
"7.12 Сотрудникам старшего состава запрещено проводить тренировки и лекции чаще, чем раз в 30 минут.",
"7.13 Запрещено подкидывать диалоги выдачи лицензий клиентам.",
"7.14 Носить огнестрельное оружие на территории автошколы - выговор.",
"7.15 Запрещено иметь связи с нелегальными организациями - увольнение.",
"",
"Примечание: Управляющий и его Директора могут выдавать наказание на свое усмотрение, от устного предупреждения до Черного Списка Автошколы.",
"",
"Глава VIII. Прочие правила.",
"",
"8.1 Выговоры снимаются только за выполнение заданий, а так же за штрафную выплату на счет организации.",
"8.2 Халатное оформление лицензий - наказуемо.",
"8.3 Нажатие на кнопку вызова полиции без особой причины - выговор.",
"8.4 Если сотрудника Автошколы нет в штате более 5 дней, то он будет уволен без дальнейшего восстановления.",
"",
"Глава IX. Обязанности и права директора.",
"9.1 Директор является официальной правой рукой Управляющего.",
"9.2 Директор имеет право выступать на мероприятиях от имени Управляющего.",
"9.3 Директор - главное руководящее лицо в автошколе, пока Управляющего не в Штате.",
"9.4 Директор является куратором всех отделов, то есть имеет полное право снимать глав отделов и назначать новых.",
"9.5 Директор имеет право на выдачу выговоров Заместителям Директора.",
"9.6 Директор имеет право выдвинуть Заместителя Директора на процедуру снятия со своей должности. Окончательное решение принимает Директор.",
"9.7 Директор обязан подчиняться только указам Управляющего и Сенаторов Штата, а так же ФБР и Губернатору.",
"",
"Глава X. OOC (Out Of Character).",
"",
"10.1 Запрещено нарушать действующие правила сервера.",
"10.2 Сотрудник автошколы обязан соблюдать RolePlay режим, в зависимости от ситуации.",
"10.3 Запрещено стоять AFK без Esc на сердечке около кулера.",
"10.4 Запрещена NonRP работа с клиентами.",
"10.5 Запрещен flood, offtop, MG, DM.",
"10.6 Запрещены оскорбления в NonRP чатах."}
			for _,line in ipairs(ustav) do
				if #search_ustav.v < 1 then
					imgui.TextWrapped(u8(line))
					imgui.Hint('Кликните дважды, что бы скопировать строку в чат', 2)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line)
					end
				else
					if string.rlower(line):find(string.rlower(u8:decode(search_ustav.v)):gsub("%[","%%[")) then
						imgui.TextWrapped(u8(line))
						imgui.Hint('Кликните дважды, что бы скопировать строку в чат', 2)
						if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
							sampSetChatInputEnabled(true)
							sampSetChatInputText(line)
						end
					end
				end
			end
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Закрыть",imgui.ImVec2(200,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end
	
	function confirmdelete()
		if imgui.BeginPopupModal(u8("Подтверждение действия"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.CenterTextColoredRGB([[Вы уверены в том, что хотите удалить свой конфиг?
{ff0000}После подтверждения все ваши бинды, настройки и цены на лицензии будут сброшены.]])
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
			imgui.BeginChild("##Confirm", imgui.ImVec2(520, 1), false)
			imgui.EndChild()
			imgui.PopStyleColor()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Подтвердить",imgui.ImVec2(100,25)) then
				disableallimgui()
				os.remove("moonloader/config/AS Helper.ini")
				configuration = inicfg.load({
					main_settings = {
						myrankint = 0,
						myrank = "",
						myname = '',
						myaccent = '',
						useservername = true,
						useaccent = false,
						avtoprice = 5000,
						motoprice = 10000,
						ribaprice = 30000,
						lodkaprice = 30000,
						gunaprice = 50000,
						huntprice = 100000,
						kladprice = 200000,
						usefastmenu = 'E',
						fastscreen = 'F4',
						dofastscreen = true,
						createmarker = false,
						dorponcmd = true,
						replacechat = true,
						RChatColor = 4282626093,
						DChatColor = 4294940723,
						ASChatColor = 4281558783,
						gender = 0,
						style = 0
					},
					my_stats = {
						avto = 0,
						moto = 0,
						riba = 0,
						lodka = 0,
						guns = 0,
						hunt = 0,
						klad = 0
					},
					binder_settings = {
						totalslots = 50
					},
					BindsName = {},
					BindsDelay = {},
					BindsType = {},
					BindsAction = {},
					BindsCmd = {},
					BindsKeys = {}
				}, "AS Helper")
				if inicfg.save(configuration,"AS Helper") then
					ASHelperMessage("Конфиг был успешно удалён! Скрипт перезагружен.")
				end
				NoErrors = true
				thisScript():reload()
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Отменить",imgui.ImVec2(100,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end

	function rules()
		if imgui.BeginPopupModal(u8("Правила гос. структур"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##ChangeLog", imgui.ImVec2(700, 330), true)
			imgui.CenterTextColoredRGB([[
{FF0000}Кадровая система
[1 - 4 Ранги] - [{00FF00}Отсутствует]]..textcolorinhex..[[]
[5 Ранг] - [{FF9900}3 Суток]]..textcolorinhex..[[]
[6 Ранг] - [{FF9900}4 Суток]]..textcolorinhex..[[]
[7 Ранг] - [{FF5500}6 Дней]]..textcolorinhex..[[]
[8 Ранг] - [{FF5500}8 Дней]]..textcolorinhex..[[]
[9 Ранг] - [{FF1100}15 Дней]]..textcolorinhex..[[]
{FF1100}Если человек не отстоял исполнительный срок и был уволен/ушел ПСЖ - Занесение в ЧС красной степени.
 
{FF0000}Норма АФК
Норма АФК для Министра/Лидера/Заместителя составляет 10 минут [{FF5500}600 секунд]]..textcolorinhex..[[] | Наказание: устное/строгое
предупреждение и кик.
Норма АФК для Ст.состава [5-8 ранг] составляет 15 минут [{FF5500}900 секунд]]..textcolorinhex..[[] | Наказание: Выговор в личное дело/кик.
Норма АФК для Мл.состава [1-4 ранг] составляет 30 минут [{FF5500}1800 секунд]]..textcolorinhex..[[] | Наказание: Увольнение.
 
{FF0000}Ограничение по рангам
9 ранг - 3 человека
8 ранг - 4 человека
 
{FF0000}Тэги в /d чат и /gov
Центральный Банк г. Лос-Сантос - [Банк]
Правительство Штата - [Правительство]
Государственная АвтоШкола г. Сан-Фиерро - [Автошкола]
 
Федеральное Бюро Расследований - [ФБР]
Полиция г. Лос-Сантос - [Полиция ЛС]
Полиция г. Сан-Фиерро - [Полиция СФ]
Полиция округа Ред Каунти - [Областная Полиция]
Полиция г. Лас-Вентурас - [Полиция ЛВ]
 
Армия г. Лос-Сантос - [Армия ЛС]
Армия г. Сан-Фиерро - [ВМС]
 
Тюрьма Строгого Режима
Тюрьма Строгого Режима г.Las-Venturas - [Тюрьма ЛВ]
 
Больница г. Лос-Сантос - [Больница ЛС]
Больница г. Сан-Фиерро - [Больница СФ]
Больница г. Лас-Вентурас - [Больница ЛВ]
 
Страховая компания - [СК]
]])
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Закрыть",imgui.ImVec2(200,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end

	function ranksystem()
		if imgui.BeginPopupModal(u8("Система повышения"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##RankSystem", imgui.ImVec2(800, 600), true)
			imgui.CenterTextColoredRGB([[
{ff6633}Стажёр [1] - Консультант [2]
- Сдать устав сотруднику старшего/руководящего состава.
- Иметь спец. рацию "Discord".
 
{ff6633}Консультант [2] - Лицензёр [3]
- Сдать речь сотруднику старшего/руководящего состава. (РП отыгровка при выдаче лицензий)
- Сдать знание прайс листа сотруднику старшего/руководящего состава.
- Прослушать одну лекцию (Скриншот начала, середины и конца)
 
{ff6633}Лицензёр [3] - Мл. Инструктор [4]
- Выполнить два RolePlay поручения. (минимум 10 отыгровок)
- Прослушать 2 лекции. (Скриншот начала, середины и конца)
- Продать 25 лицензий.
 
{ff6633}Мл. Инструктор [4] - Инструктор [5]
- Набрать 50 баллов.
- Выполнить одно RolePlay задание, связанное с работой Автошколы.
 
{ff6633}Инструктор [5] - Менеджер [6]
- Набрать 60 баллов.
- Выполнить одно RolePlay задание, связанное с работой Автошколы.
 
{ff6633}Менеджер [6] - Ст. Менеджер [7]
- Набрать 70 баллов
- Выполнить два RolePlay задания, связанных с работой Автошколы.
 
{ff6633}Ст. Менеджер [7] - Помощник Директора [8]
- Набрать 80 баллов
- Выполнить три RolePlay задания, связанных с работой Автошколы.
 
Балловая таблица:
Выдача лицензий | {ff9900}2 балла]]..textcolorinhex..[[ за одну лицензию | {ff1100}Не более 5-ти проданных лицензий за отчёт.
Прослушивание лекции от Ст. состава | {ff9900}4 балла]]..textcolorinhex..[[ за одну лекцию | {ff1100}Не более 3-ёх прослушанных лекций за отчёт.
Выполнение поручения от Ст. состава | {ff9900}5 баллов]]..textcolorinhex..[[ за одно поручение | {ff1100}Не более 2-ух выполненных поручений за отчёт.
Выполнение поручения от Упр. состава | {ff9900}10 баллов]]..textcolorinhex..[[ за одно поручение | {ff1100}Не более 1-ого выполненного поручения за отчёт.
Свободная RP ситуация (минимум 20 отыгровок) | {ff9900}10 баллов]]..textcolorinhex..[[ за одну RP ситуацию | {ff1100}Не более 1-ой ситуации за отчёт.
Участие в проверке другой организации | {ff9900}5 баллов]]..textcolorinhex..[[ за одно участие в проверке | {ff1100}Не более 2-ух проверок за отчёт.
Присутствовать на проверке от другой фракции | {ff9900}3 балла]]..textcolorinhex..[[ за одно присутствие на проверке | {ff1100}Не более 3-ёх проверок за отчёт.
Участие в RP процессе от ст. состава | {ff9900}4 балла]]..textcolorinhex..[[ за одно участие в RP процессе | {ff1100}Не более 2-ух участий в RP процессе за отчёт.
Быть определённое время на посту | {ff9900}0.5 балла]]..textcolorinhex..[[ за 1 минуту простоя | {ff1100}Не более 30-ти минут за отчёт.
Проведение лекций для состава | {ff9900}4 балла]]..textcolorinhex..[[ за одну проведённую лекцию | {ff1100}Не более 3-ёх проведённых лекций за отчёт.
Проведение RP процесса для состава | {ff9900}5 баллов]]..textcolorinhex..[[ за один проведённый RP процесс | {ff1100}Не более 2-ух RP процессов за отчёт.
Проверка устава/прайс листа/речи у мл. состава | {ff9900}3 балла]]..textcolorinhex..[[ за одну проверку | {ff1100}Не более 5-ти проверок за отчёт.
Проведение МП для состава | {ff9900}3 - 5 баллов]]..textcolorinhex..[[ | {ff1100}Не более 3-ёх проведённых МП за отчёт.
Присутствие на МП | Победа на МП - {ff9900}2 - 4 балла]]..textcolorinhex..[[ | {ff1100}Не более 5-ти участий в МП за отчёт.
]])
		imgui.EndChild()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
		if imgui.Button(u8"Закрыть",imgui.ImVec2(200,25)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
		end
	end

	local fa_glyph_ranges	= imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
	function imgui.BeforeDrawFrame()
		if fa_font == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
		end
		if fontsize16 == nil then
			fontsize16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		end
	end

	function imgui.OnDrawFrame()
		local ScreenX, ScreenY = getScreenResolution()

		if imgui_fm.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"Меню быстрого доступа ["..fastmenuID.."]", imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)

			if windowtype.v == 0 then -- ГЛАВНОЕ МЕНЮ  ГЛАВНОЕ МЕНЮ  ГЛАВНОЕ МЕНЮ  ГЛАВНОЕ МЕНЮ  ГЛАВНОЕ МЕНЮ  ГЛАВНОЕ МЕНЮ  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1 then
							disableallimgui()
							hello()
						else
							ASHelperMessage("Данная команда доступна с 1-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1  then
							disableallimgui()
							pricelist()
						else
							ASHelperMessage("Данная команда доступна с 1-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 3 then
						imgui.SetScrollY(0)
						ComboBox_select.v = 0
						windowtype.v = 1
					else
						ASHelperMessage("Данная команда доступна с 3-го ранга.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 5 then
						imgui.SetScrollY(0)
						windowtype.v = 2
						expelbuff.v = ""
					else
						ASHelperMessage("Данная команда доступна с 5-го ранга.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								if imgui.IsMouseReleased(0) then
									disableallimgui()
									invite(tostring(fastmenuID))
								end
								if imgui.IsMouseReleased(1) then
									lua_thread.create(function()
										disableallimgui()
										sampSendChat('/do Ключи от шкафчика в кармане.')
										wait(cd)
										sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
										wait(cd)
										sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
										wait(cd)
										sampSendChat('Добро пожаловать! Раздевалка за дверью.')
										wait(cd)
										sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
										sampSendChat("/invite "..fastmenuID)
										waitingaccept = fastmenuID
									end)
								end
							else
								ASHelperMessage("Данная команда доступна с 9-го ранга.")
							end
						else
							ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
						end
					end
					
				end
				imgui.Hint("ЛКМ для принятия человека в организацию\n{FFFFFF}ПКМ для принятия на должность Консультанта",0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 3
							uninvitebuf.v = ""
							blacklistbuf.v = ""
							uninvitebox.v = false
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							Ranks_select.v = 0
							windowtype.v = 4
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 5
							blacklistbuff.v = ""
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unblacklist(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fwarnbuff.v = ""
							windowtype.v = 6
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unfwarn(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fmutebuff.v = ""
							fmuteint.v = 0
							windowtype.v = 7
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							funmute(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Данная команда доступна с 9-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Проверка устава '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							windowtype.v = 8
						else
							ASHelperMessage("Данное действие доступно с 5-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Собеседование '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							passvalue = false
							mcvalue = false
							passverdict = ""
							mcverdict = ""
							sobesetap.v = 0
							sobesdecline_select.v = 0
							imgui_fm.v = false
							imgui_sobes.v = true
						else
							ASHelperMessage("Данное действие доступно с 5-го ранга.")
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end

			elseif windowtype.v == 8 then -- ПРОВЕРИТЬ УСТАВ  ПРОВЕРИТЬ УСТАВ  ПРОВЕРИТЬ УСТАВ  ПРОВЕРИТЬ УСТАВ  ПРОВЕРИТЬ УСТАВ  ПРОВЕРИТЬ УСТАВ  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Рабочее время в будние дни', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: 09:00 - 19:00")
						sampSendChat("Назовите время дневной смены в будние дни.")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Рабочее время в выходные дни', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: 10:00 - 18:00")
						sampSendChat("Назовите время дневной смены в выходные дни.")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Кнопка вызова полиции без причины', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: выговор")
						sampSendChat("Какое наказание получает сотрудник за ложное нажатие кнопки вызова полиции?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Использование транспорта', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: (3+) Лицензёр - мото, (4+) Мл.Инструктор - авто, (8+) Зам. директора - вертолёт")
						sampSendChat("С какой должности разрешено брать автомобили, мотоциклы и вертолёт?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Должность для отпуска', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: (5+) Инструктор")
						sampSendChat("Скажите, с какой должности разрешено брать отпуск?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Время сна вне раздвелки', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: 5 минут максимально, за этим последует выговор.")
						sampSendChat("Максимально допустимое время сна вне раздевалки?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Что такое субординация', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: cубординация - это правила общения между сотрудниками, разными по должности.")
						sampSendChat("Что по вашему мнению означает слово 'Субординация'?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Обращения к другим сотрудникам', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Подсказка: по должности, по имени, 'Сэр' и 'Коллега'.")
						sampSendChat("Такой вопрос, какие обращения допускаются к другим сотрудникам автошколы?")
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Одобрить', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("Поздравляю, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", вы сдали устав!")
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
    			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отказать', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("Очень жаль, но вы не смогли сдать устав. Подучите и приходите в следующий раз.")
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 1 then -- ПРОДАТЬ ЛИЦ  ПРОДАТЬ ЛИЦ  ПРОДАТЬ ЛИЦ  ПРОДАТЬ ЛИЦ  ПРОДАТЬ ЛИЦ  ПРОДАТЬ ЛИЦ  
				imgui.Text(u8"Лицензия: ", imgui.ImVec2(75,30))
				imgui.SameLine()
				imgui.Combo(' ', ComboBox_select, ComboBox_arr, #ComboBox_arr)
				imgui.NewLine()
				if ComboBox_select.v == 0 then
					whichlic = "авто"
				elseif ComboBox_select.v == 1 then
					whichlic = "мото"
				elseif ComboBox_select.v == 2 then
					whichlic = "рыболовство"
				elseif ComboBox_select.v == 3 then
					whichlic = "плавание"
				elseif ComboBox_select.v == 4 then
					whichlic = "оружие"
				elseif ComboBox_select.v == 5 then
					whichlic = "охоту"
				elseif ComboBox_select.v == 6 then
					whichlic = "раскопки"
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Продать лицензию на '..u8(whichlic), imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID.." "..whichlic))
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Лицензия на полёты', imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID).." полёты")
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 2 then -- EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  
				imgui.CenterTextColoredRGB("Причина expel:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"     ",expelbuff)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.Button(u8'Выгнать '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(250,30)) then
					if expelbuff.v == nil or expelbuff.v == "" then
						ASHelperMessage("Введите причину expel!")
					else
						expel(tostring(fastmenuID.." "..u8:decode(expelbuff.v)))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 3 then -- УВОЛИТЬ  УВОЛИТЬ  УВОЛИТЬ  УВОЛИТЬ  УВОЛИТЬ  УВОЛИТЬ  
				imgui.CenterTextColoredRGB("Причина увольнения:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"    ", uninvitebuf)
				if uninvitebox.v then
					imgui.CenterTextColoredRGB("Причина ЧС:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
					imgui.InputText(u8" ", blacklistbuf)
				end
				imgui.Checkbox(u8"Уволить с ЧС", uninvitebox)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if uninvitebuf.v == nil or uninvitebuf.v == '' then
						ASHelperMessage("Введите причину увольнения!")
					else
						if uninvitebox.v then
							if blacklistbuf.v == nil or blacklistbuf.v == '' then
								ASHelperMessage("Введите причину занесения в ЧС!")
							else
								uninvite(fastmenuID.." 1")
								disableallimgui()
							end
						else
							uninvite(fastmenuID.." 0")
							disableallimgui()
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 4 then -- ДАТЬ РАНГ  ДАТЬ РАНГ  ДАТЬ РАНГ  ДАТЬ РАНГ  ДАТЬ РАНГ  ДАТЬ РАНГ  
				imgui.PushItemWidth(270)
				imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				if imgui.GreenButton(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
					giverank(fastmenuID.." "..(Ranks_select.v+1))
					disableallimgui()
				end
				if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
					disableallimgui()
					lua_thread.create(function ()
						sampSendChat('/me {gender:включил|включила} КПК')
						wait(cd)
						sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками"')
						wait(cd)
						sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
						wait(cd)
						sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
						wait(cd)
						sampSendChat('/do Информация о сотруднике была изменена.')
						sampSendChat("/giverank "..fastmenuID.." "..Ranks_select.v+1)
					end)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 5 then -- ДАТЬ ЧС  ДАТЬ ЧС  ДАТЬ ЧС  ДАТЬ ЧС  ДАТЬ ЧС  ДАТЬ ЧС  
				imgui.CenterTextColoredRGB("Причина занесения в ЧС:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"                   ", blacklistbuff)
				imgui.NewLine()
				if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if blacklistbuff.v == nil or blacklistbuff.v == '' then
						ASHelperMessage("Введите причину занесения в ЧС!")
					else
						blacklist(fastmenuID.." "..u8:decode(blacklistbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end

			elseif windowtype.v == 6 then -- ВЫГОВОР  ВЫГОВОР  ВЫГОВОР  ВЫГОВОР  ВЫГОВОР  ВЫГОВОР
				imgui.CenterTextColoredRGB("Причина выговора:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"", fwarnbuff)
				imgui.NewLine()
				if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fwarnbuff.v == nil or fwarnbuff.v == '' then
						ASHelperMessage("Введите причину выдачи выговора!")
					else
						fwarn(fastmenuID.." "..u8:decode(fwarnbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end

			elseif windowtype.v == 7 then -- ВЫДАТЬ МУТ  ВЫДАТЬ МУТ  ВЫДАТЬ МУТ  ВЫДАТЬ МУТ  ВЫДАТЬ МУТ  ВЫДАТЬ МУТ  
				imgui.CenterTextColoredRGB("Причина мута:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"         ", fmutebuff)
				imgui.CenterTextColoredRGB("Время мута:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
				imgui.InputInt(u8" ", fmuteint)
				imgui.NewLine()
				if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fmutebuff.v == nil or fmutebuff.v == '' then
						ASHelperMessage("Введите причину выдачи мута!")
					else
						if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find("-") then
							ASHelperMessage("Введите корректное время мута!")
						else
							fmute(fastmenuID.." "..u8:decode(fmuteint.v).." "..u8:decode(fmutebuff.v))
							disableallimgui()
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
			imgui.End()

		elseif imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"Меню быстрого доступа ["..fastmenuID.."]", imgui_sobes, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			if sobesetap.v == 1 then
				imgui.CenterTextColoredRGB("Собеседование: Этап 2")
				imgui.Separator()
				if not mcvalue then
					imgui.CenterTextColoredRGB("Мед.карта - не показана")
				else
					imgui.CenterTextColoredRGB("Мед.карта - показана ("..mcverdict..")")
				end
				if not passvalue then
					imgui.CenterTextColoredRGB("Паспорт - не показан")
				else
					imgui.CenterTextColoredRGB("Паспорт - показан ("..passverdict..")")
				end
				if mcvalue and mcverdict == ("в порядке") and passvalue and passverdict == ("в порядке") then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'Продолжить >', imgui.ImVec2(285,30)) then
						sobesaccept1()
					end
				end
			end

			if sobesetap.v == 7 then
				imgui.CenterTextColoredRGB("Собеседование: Отклонение")
				imgui.Separator()
				imgui.PushItemWidth(270)
				imgui.Combo(" ",sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobesetap.v = 0
						if sobesdecline_select.v == 0 then
							sobesdecline("проф. непригодность2")
						elseif sobesdecline_select.v == 1 then
							sobesdecline("проф. непригодность3")
						elseif sobesdecline_select.v == 2 then
							sobesdecline("проф. непригодность4")
						elseif sobesdecline_select.v == 3 then
							sobesdecline("проф. непригодность1")
						elseif sobesdecline_select.v == 4 then
							sobesdecline("проф. непригодность5")
						end
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap.v == 0 then
				imgui.CenterTextColoredRGB("Собеседование: Этап 1")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Поприветствовать', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobes1()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Попросить документы >', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobes2()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
			end

			if sobesetap.v == 2 then
				imgui.CenterTextColoredRGB("Собеседование: Этап 3")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Расскажите немного о себе.', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
						else
							inprocess = true
							sampSendChat("Расскажите немного о себе.")
							inprocess = false
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Почему выбрали именно нас?', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
						else
							inprocess = true
							sampSendChat("Почему вы выбрали именно нас?")
							inprocess = false
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8"Работали вы уже в организациях ЦА? >", imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
						else
							inprocess = true
							sampSendChat("Работали вы уже в организациях ЦА? Если да, то расскажите подробнее")
							sampSendChat("/n ЦА - Центральный аппарат [Автошкола, Правительство, Банк]")
							lua_thread.create(function()
								wait(50)
								sobesetap.v = 3
							end)
							inprocess = false
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
			end

			if sobesetap.v == 3 then
				imgui.CenterTextColoredRGB("Собеседование: Решение")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Принять', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobesaccept2()
						sobesetap.v = 0
						disableallimgui()
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						lastsobesetap = sobesetap.v
						sobesetap.v = 7
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
			end
			if sobesetap.v ~= 3 and sobesetap.v ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						if mcvalue or passvalue then
							if mcverdict == ("наркозависимость") then
								sobesdecline("наркозависимость")
								disableallimgui()
							elseif mcverdict == ("не полностью здоровый") then
								sobesdecline("не полностью здоровый")
								disableallimgui()
							elseif passverdict == ("меньше 3 лет в штате") then
								sobesdecline("меньше 3 лет в штате")
								disableallimgui()
							elseif passverdict == ("не законопослушный") then
								sobesdecline("не законопослушный")
								disableallimgui()
							elseif passverdict == ("игрок в организации") then
								sobesdecline("игрок в организации")
								disableallimgui()
							elseif passverdict == ("был в деморгане") then
								sobesdecline("был в деморгане")
								disableallimgui()
							elseif passverdict == ("в чс автошколы") then
								sobesdecline("в чс автошколы")
								disableallimgui()
							else
								lastsobesetap = sobesetap.v
								sobesetap.v = 7
							end
						else
							lastsobesetap = sobesetap.v
							sobesetap.v = 7
						end
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(137,30)) then
				if sobesetap.v == 7 then
					sobesetap.v = lastsobesetap
				elseif sobesetap.v ~= 0 then
					sobesetap.v = sobesetap.v - 1
				else
					imgui_sobes.v = false
					imgui_fm.v = true
					windowtype.v = 0
				end
			end
			imgui.SameLine()
			if sobesetap.v ~= 3 and sobesetap.v ~= 7 then
				if imgui.Button(u8'Пропустить этап', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap.v = sobesetap.v + 1
					else
						ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
					end
				end
			end
			imgui.End()
		end

		if imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"Биндер", imgui_binder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetScrollY(0)
			imgui.BeginChild("ChildWindow",imgui.ImVec2(175,270),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
			for key, value in pairs(configuration.BindsName) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
				if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
					choosedslot = key
					binderbuff.v = u8(configuration.BindsAction[key]):gsub("~", "\n")
					bindername.v = u8(configuration.BindsName[key])
					bindertype.v = u8(configuration.BindsType[key])
					bindercmd.v = u8(configuration.BindsCmd[key])
					binderkeystatus = configuration.BindsKeys[key]
					binderdelay.v = tostring(configuration.BindsDelay[key])
				end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= configuration.binder_settings.totalslots then
				imgui.SameLine()
				imgui.BeginChild("ChildWindow2",imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8"",binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').y - 135) / 2)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then
					imgui.InputText("##bindername", bindername,imgui.InputTextFlags.ReadOnly)
				else
					imgui.InputText("##bindername", bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(" ",bindertype, u8"Использовать команду\0Использовать клавиши\0\0", 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Задержка между строками (ms):').y - 70) / 2)
				imgui.Text(u8'Задержка между строками (ms):'); imgui.SameLine()
				imgui.Hint('Указывайте значение в миллисекундах\n{FFFFFF}1 секунда = 1.000 миллисекунд')
				imgui.PushItemWidth(58)
				imgui.InputText("##binderdelay", binderdelay, imgui.InputTextFlags.CharsDecimal)
				imgui.PopItemWidth()
				imgui.SameLine()
				if bindertype.v == 0 then
					imgui.Text("/")
					imgui.SameLine()
					imgui.PushItemWidth(147)
					imgui.InputText("##bindercmd",bindercmd,imgui.InputTextFlags.CharsNoBlank)
					imgui.PopItemWidth()
				end
				if bindertype.v == 1 then
					if binderkeystatus == nil or binderkeystatus == "" then
						binderkeystatus = u8"Нажмите чтобы поменять"
					end
					if imgui.Button(binderkeystatus) then
						if binderkeystatus == u8"Нажмите чтобы поменять" then
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"Нажмите любую клавишу"
							setbinderkey = true
						elseif binderkeystatus == u8"Нажмите любую клавишу" then
							setbinderkey = false
							binderkeystatus = u8"Нажмите чтобы поменять"
						elseif string.find(binderkeystatus, u8"Применить") then
							setbinderkey = false
							binderkeystatus = string.match(binderkeystatus,u8"Применить (.+)")
						else
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"Нажмите любую клавишу"
							keyname = nil
							keyname2 = nil
							setbinderkey = true
						end
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 429) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
				local kei
				local doreplace = false
				if binderbuff.v ~= "" and bindername.v ~= "" and binderdelay.v ~= "" and bindertype.v ~= nil then
					if imgui.Button(u8"Сохранить",imgui.ImVec2(100,30)) then
						if not inprocess then
								if bindertype.v == 0 then
									if bindercmd.v ~= "" and bindercmd.v ~= nil then
										for key, value in pairs(configuration.BindsName) do
											if tostring(u8:decode(bindername.v)) == tostring(value) then
												doreplace = true
												kei = key
											end
										end
										if doreplace then
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											configuration.BindsName[kei] = u8:decode(bindername.v)
											configuration.BindsAction[kei] = refresh_text
											configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
											configuration.BindsType[kei]= u8:decode(bindertype.v)
											configuration.BindsCmd[kei] = u8:decode(bindercmd.v)
											configuration.BindsKeys[kei] = ""
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("Бинд успешно сохранён!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										else
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											table.insert(configuration.BindsName, u8:decode(bindername.v))
											table.insert(configuration.BindsAction, refresh_text)
											table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
											table.insert(configuration.BindsType, u8:decode(bindertype.v))
											table.insert(configuration.BindsCmd, u8:decode(bindercmd.v))
											table.insert(configuration.BindsKeys, "")
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("Бинд успешно создан!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										end
									else
										ASHelperMessage("Вы неправильно указали команду бинда!")
									end
								elseif bindertype.v == 1 then
									if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= "Нажмите чтобы поменять" and not string.find((u8:decode(binderkeystatus)), "Применить ") and (u8:decode(binderkeystatus)) ~= "Нажмите любую клавишу" then
										for key, value in pairs(configuration.BindsName) do
											if tostring(u8:decode(bindername.v)) == tostring(value) then
												doreplace = true
												kei = key
											end
										end
										if doreplace then
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											configuration.BindsName[kei] = u8:decode(bindername.v)
											configuration.BindsAction[kei] = refresh_text
											configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
											configuration.BindsType[kei]= u8:decode(bindertype.v)
											configuration.BindsCmd[kei] = ""
											configuration.BindsKeys[kei] = u8(binderkeystatus)
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("Бинд успешно сохранён!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										else
											local refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
											table.insert(configuration.BindsName, u8:decode(bindername.v))
											table.insert(configuration.BindsAction, refresh_text)
											table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
											table.insert(configuration.BindsType, u8:decode(bindertype.v))
											table.insert(configuration.BindsKeys, u8(binderkeystatus))
											table.insert(configuration.BindsCmd, "")
											if inicfg.save(configuration, "AS Helper") then
												ASHelperMessage("Бинд успешно создан!")
												setbinderkey = false
												keyname = nil
												keyname2 = nil
												table.remove(emptykey1)
												table.remove(emptykey2)
												bindercmd.v = ""
												binderbuff.v = ""
												bindername.v = ""
												bindertype.v = 0
												binderdelay.v = ""
												bindercmd.v = ""
												binderkeystatus = nil
												choosedslot = nil
											end
										end
									else
										ASHelperMessage("Вы неправильно указали клавишу бинда!")
									end
								end
							updatechatcommands()
						else
							ASHelperMessage("Вы не можете взаимодействовать с биндером во время любой отыгровки!")
						end	
					end
				else
					imgui.LockedButton(u8"Сохранить",imgui.ImVec2(100,30))
					imgui.Hint("Вы ввели не все параметры. Перепроверьте всё.")
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8"Отменить",imgui.ImVec2(100,30)) then
					setbinderkey = false
					keyname = nil
					keyname2 = nil
					table.remove(emptykey1)
					table.remove(emptykey2)
					bindercmd.v = ""
					binderbuff.v = ""
					bindername.v = ""
					bindertype.v = 0
					binderdelay.v = ""
					bindercmd.v = ""
					binderkeystatus = nil
					updatechatcommands()
					choosedslot = nil
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230,180))
				imgui.Text(u8"Откройте бинд или создайте новый для меню редактирования.")
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
			if imgui.Button(u8"Добавить",imgui.ImVec2(82,30)) then
				choosedslot = 50
				binderbuff.v = ''
				bindername.v = ''
				bindertype.v = 0
				bindercmd.v = ''
				binderkeystatus = nil
				binderdelay.v = ''
				updatechatcommands()
			end
			imgui.SameLine()
			if choosedslot ~= nil and choosedslot ~= 50 then
				if imgui.Button(u8"Удалить",imgui.ImVec2(82,30)) then
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							value = tostring(value)
							if u8:decode(bindername.v) == tostring(configuration.BindsName[key]) then
								table.remove(configuration.BindsName,key)
								table.remove(configuration.BindsKeys,key)
								table.remove(configuration.BindsAction,key)
								table.remove(configuration.BindsCmd,key)
								table.remove(configuration.BindsDelay,key)
								table.remove(configuration.BindsType,key)
								if inicfg.save(configuration,"AS Helper") then
									setbinderkey = false
									keyname = nil
									keyname2 = nil
									table.remove(emptykey1)
									table.remove(emptykey2)
									bindercmd.v = ""
									binderbuff.v = ""
									bindername.v = ""
									bindertype.v = 0
									binderdelay.v = ""
									bindercmd.v = ""
									binderkeystatus = nil
									choosedslot = nil
									ASHelperMessage("Бинд успешно удалён!")
								end
							end
						end
					updatechatcommands()
					else
						ASHelperMessage("Вы не можете удалять бинд во время любой отыгровки!")
					end
				end
			else
				imgui.LockedButton(u8"Удалить",imgui.ImVec2(82,30))
				imgui.Hint("Выберите бинд который хотите удалить",0)
			end
			imgui.End()
		end
	
		if imgui_settings.v then
			imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"AS Helper", imgui_settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.BeginChild("##Buttons",imgui.ImVec2(230,240),true,imgui.WindowFlags.NoScrollbar,imgui.WindowFlags.AlwaysAutoResize)
			imgui.SetCursorPosY(10)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_USER_COG..u8' Настройки пользователя', imgui.ImVec2(220,30)) then
				settingswindow.v = 1
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Ценовая политика', imgui.ImVec2(220,30)) then
				settingswindow.v = 2
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_KEYBOARD..u8' Горячие клавиши', imgui.ImVec2(220,30)) then
				settingswindow.v = 3
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_PALETTE..u8' Настройки цветов', imgui.ImVec2(220,30)) then
				settingswindow.v = 6
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_BOOK_OPEN..u8' Правила автошколы', imgui.ImVec2(220,30)) then
				settingswindow.v = 4
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_INFO_CIRCLE..u8' Информация о скрипте', imgui.ImVec2(220,30)) then
				settingswindow.v = 5
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##Settings",imgui.ImVec2(325,240),true,imgui.WindowFlags.NoScrollbar,imgui.WindowFlags.AlwaysAutoResize)
			if settingswindow.v == 1 then
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Использовать мой ник из таба",useservername) then
					if configuration.main_settings.myname == '' then
						local result,myid = sampGetPlayerIdByCharHandle(playerPed)
						myname.v = string.gsub(sampGetPlayerNickname(myid), "_", " ")
						configuration.main_settings.myname = sampGetPlayerNickname(myid)
					end
					configuration.main_settings.useservername = useservername.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if not useservername.v then
					imgui.SetCursorPosX(10)
					if imgui.InputText(u8" ", myname) then
						configuration.main_settings.myname = myname.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Использовать акцент",useaccent) then
					configuration.main_settings.useaccent = useaccent.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if useaccent.v then
					imgui.PushItemWidth(150)
					imgui.SetCursorPosX(20)
					if imgui.InputText(u8"   ", myaccent) then
						configuration.main_settings.myaccent = myaccent.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX(10)
					imgui.Text("[")
					imgui.SameLine()
					imgui.SetCursorPosX(175)
					imgui.Text("]")
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Создавать маркер при выделении",createmarker) then
					if marker ~= nil then
						removeBlip(marker)
					end
					marker = nil
					oldtargettingped = 0
					configuration.main_settings.createmarker = createmarker.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Начинать отыгровки после команд", dorponcmd) then
					configuration.main_settings.dorponcmd = dorponcmd.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Заменять серверные сообщения", replacechat) then
					configuration.main_settings.replacechat = replacechat.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Быстрый скрин на "..configuration.main_settings.fastscreen, dofastscreen) then
					configuration.main_settings.dofastscreen = dofastscreen.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Button(u8'Обновить', imgui.ImVec2(85,25)) then
					getmyrank = true
					sampSendChat("/stats")
				end
				imgui.SameLine()
				imgui.Text(u8"Ваш ранг: "..u8(configuration.main_settings.myrank).." ("..u8(configuration.main_settings.myrankint)..")")
				imgui.PushItemWidth(85)
				imgui.SetCursorPosX(10)
				if imgui.Combo(u8"",gender, gender_arr, #gender_arr) then
					configuration.main_settings.gender = gender.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.Text(u8"Пол выбран")
				imgui.SameLine()
				imgui.SetCursorPosX(107.5)
				imgui.Text("__________")
				imgui.Hint("ЛКМ для автоматического определения.")
				if imgui.IsItemClicked() then
					autoGetSelfGender()
				end

			elseif settingswindow.v == 2 then
				imgui.CenterTextColoredRGB("Ценовая политика")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Авто", avtoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.avtoprice = avtoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 29) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Мото", motoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.motoprice = motoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Рыбалка", ribaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.ribaprice = ribaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Плавание", lodkaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.lodkaprice = lodkaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Оружие", gunaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.gunaprice = gunaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Охота", huntprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.huntprice = huntprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Раскопки", kladprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.kladprice = kladprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
			elseif settingswindow.v == 3 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Изменить кнопку быстрого меню', imgui.ImVec2(230,40)) then
					getbindkey = true
					configuration.main_settings.usefastmenu = ""
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if getbindkey then
					imgui.Hint("Нажмите любую клавишу")
				else
					imgui.Hint("ПКМ + "..configuration.main_settings.usefastmenu)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Изменить кнопку быстрого скрина', imgui.ImVec2(230,40)) then
					getscreenkey = true
					configuration.main_settings.fastscreen = ""
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if getscreenkey then
					imgui.Hint("Нажмите любую клавишу")
				else
					imgui.Hint(configuration.main_settings.fastscreen)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Открыть биндер', imgui.ImVec2(230,40)) then
					binder()
				end
				imgui.SameLine()
			elseif settingswindow.v == 4 then
				if imgui.Button(u8'Устав автошколы', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Устав автошколы"))
				end
				ustav()
				if imgui.Button(u8'Правила гос. структур', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Правила гос. структур"))
				end
				rules()
				if imgui.Button(u8'Система повышения', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Система повышения"))
				end
				ranksystem()
				imgui.CenterTextColoredRGB[[
{FF1100}Важно!{FFFFFF}
Данные правила были взяты с форума Glendale.
На вашем сервере они могут отличаться.]]
			elseif settingswindow.v == 5 then
				imgui.CenterTextColoredRGB('Автор: {ff6633}JustMini')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Change Log '..(fa.ICON_FA_TERMINAL), imgui.ImVec2(137,30)) then
					imgui.OpenPopup(u8("Список изменений"))
				end
				changelog()
				imgui.SameLine()
				if imgui.Button(u8'Check Updates '..(fa.ICON_FA_SPINNER), imgui.ImVec2(137,30)) then
					local checking = false
					lua_thread.create(function ()
						checking = checkbibl()
						while not checking do
							wait(200)
						end
					end)
				end
				imgui.SetCursorPos(imgui.ImVec2(186,200))
				if imgui.Button(u8'Удалить конфиг '..(fa.ICON_FA_TRASH), imgui.ImVec2(120,25)) then
					imgui.OpenPopup(u8('Подтверждение действия'))
				end
				confirmdelete()
			elseif settingswindow.v == 0 then
				imgui.PushFont(fontsize16)
				imgui.CenterTextColoredRGB('Что я умею?')
				imgui.PopFont()
				imgui.TextWrapped(u8([[
• Меню быстрого доступа: Прицелившись на игрока с помощью ПКМ и нажав кнопку E (по умолчанию), откроется меню быстрого доступа. В данном меню есть все нужные функции, а именно: приветствие, озвучивание прайс листа, продажа лицензий, возможность выгнать человека из автошколы, приглашение в организацию, увольнение из организации, изменение должности, занесение в ЧС, удаление из ЧС, выдача выговоров, удаление выговоров, выдача организационного мута, удаление организационного мута, автоматизированное проведение собеседования со всеми нужными отыгровками.

• Команды сервера с отыгровками: /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. Введя любую из этих команд начнётся РП отыгровка, лишь после неё будет активирована сама команда.

• Команды: /ash - настройки хелпера, /ashbind - биндер хелпера, /ashupd - обновление должности в хелпере, /ashstats - статистика проданных лицензий.

• Настройки: Введя команду /ash откроются настройки в которых можно изменять никнейм в приветствии, акцент, создание маркера при выделении, пол, цены на лицензии, горячую клавишу быстрого меню и узнать информацию о скрипте.

• Биндер: Введя команду /ashbind откроется полностью работоспособный биндер, в котором вы можете создать абсолютно любой бинд.]]
	))
			elseif settingswindow.v == 6 then
				imgui.PushItemWidth(200)
				if imgui.Combo(u8'Выбор темы', StyleBox_select, StyleBox_arr, #StyleBox_arr) then
					configuration.main_settings.style = StyleBox_select.v
					if inicfg.save(configuration,"AS Helper") then
						checkstyle()
					end
				end
				imgui.PopItemWidth()
				if imgui.ColorEdit4(u8'Цвет чата организации /r##RSet', RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(RChatColor.v[1], RChatColor.v[2], RChatColor.v[3], RChatColor.v[4]):GetU32()
		            configuration.main_settings.RChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Сбросить##RCol",imgui.ImVec2(90,25)) then
					configuration.main_settings.RChatColor = 4282626093
		            if inicfg.save(configuration, 'AS Helper.ini') then
						RChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
					end
				end
				if imgui.ColorEdit4(u8'Цвет чата департамента /d##DSet', DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(DChatColor.v[1], DChatColor.v[2], DChatColor.v[3], DChatColor.v[4]):GetU32()
		            configuration.main_settings.DChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Сбросить##DCol",imgui.ImVec2(90,25)) then
					configuration.main_settings.DChatColor = 4294940723
		            if inicfg.save(configuration, 'AS Helper.ini') then
						DChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
					end
				end
				if imgui.ColorEdit4(u8'Цвет AS Helper в чате##SSet', ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(ASChatColor.v[1], ASChatColor.v[2], ASChatColor.v[3], ASChatColor.v[4]):GetU32()
					configuration.main_settings.ASChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Сбросить##SCol",imgui.ImVec2(90,25)) then
					configuration.main_settings.ASChatColor = 4281558783
		            if inicfg.save(configuration, 'AS Helper.ini') then
						ASChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
					end
				end
			end
			imgui.EndChild()
			imgui.End()
		end
		
		if imgui_stats.v then
			imgui.SetNextWindowSize(imgui.ImVec2(150, 195), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.05))
			imgui.Begin(u8"Ваша статистика", imgui_stats, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.Text(u8"Авто - "..configuration.my_stats.avto)
			imgui.Text(u8"Мото - "..configuration.my_stats.moto)
			imgui.Text(u8"Рыболовство - "..configuration.my_stats.riba)
			imgui.Text(u8"Плавание - "..configuration.my_stats.lodka)
			imgui.Text(u8"Оружие - "..configuration.my_stats.guns)
			imgui.Text(u8"Охота - "..configuration.my_stats.hunt)
			imgui.Text(u8"Раскопки - "..configuration.my_stats.klad)
			imgui.End()
		end
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then
	return end
	while not isSampAvailable() do
		wait(200)
	end
	local checking = false
	checking = checkbibl()
	while not checking do
		wait(200)
	end
	while not string.find(sampGetCurrentServerName(), "Arizona") do
		wait(200)
	end
	while not sampIsLocalPlayerSpawned() do
		wait(200)
	end
	if not doesFileExist('moonloader/config/AS Helper.ini') then
        if inicfg.save(configuration, 'AS Helper.ini') then
			ASHelperMessage('Создан файл конфигурации.')
		end
    end
	getmyrank = true
	sampSendChat("/stats")
	ASHelperMessage('AS Helper успешно загружен. Автор: JustMini')
	ASHelperMessage("Введите /"..cmdhelp.." чтобы открыть настройки.")
	checkstyle()
	imgui.Process = false
	sampRegisterChatCommand(cmdhelp, fastmenuopen)
	sampRegisterChatCommand(cmdbind, binder)
	sampRegisterChatCommand(cmdupdate, updaterank)
	sampRegisterChatCommand(cmdstats, checkmystats)
	sampRegisterChatCommand("uninvite", function(param)
		if configuration.main_settings.dorponcmd then
			uninvitewithcmd(param)
		else
			sampSendChat("/uninvite "..param)
		end
	end)
	sampRegisterChatCommand("invite", function(param)
		if configuration.main_settings.dorponcmd then
			invite(param)
		else
			sampSendChat("/invite "..param)
		end
	end)
	sampRegisterChatCommand("giverank", function(param)
		if configuration.main_settings.dorponcmd then
			giverank(param)
		else
			sampSendChat("/giverank "..param)
		end
	end)
	sampRegisterChatCommand("blacklist", function(param)
		if configuration.main_settings.dorponcmd then
			blacklist(param)
		else
			sampSendChat("/blacklist "..param)
		end
	end)
	sampRegisterChatCommand("unblacklist", function(param)
		if configuration.main_settings.dorponcmd then
			unblacklist(param)
		else
			sampSendChat("/unblacklist "..param)
		end
	end)
	sampRegisterChatCommand("fwarn", function(param)
		if configuration.main_settings.dorponcmd then
			fwarn(param)
		else
			sampSendChat("/fwarn "..param)
		end
	end)
	sampRegisterChatCommand("unfwarn", function(param)
		if configuration.main_settings.dorponcmd then
			unfwarn(param)
		else
			sampSendChat("/unfwarn "..param)
		end
	end)
	sampRegisterChatCommand("fmute", function(param)
		if configuration.main_settings.dorponcmd then
			fmute(param)
		else
			sampSendChat("/fmute "..param)
		end
	end)
	sampRegisterChatCommand("funmute", function(param)
		if configuration.main_settings.dorponcmd then
			funmute(param)
		else
			sampSendChat("/funmute "..param)
		end
	end)
	sampRegisterChatCommand("expel", function(param)
		if configuration.main_settings.dorponcmd then
			expel(param)
		else
			sampSendChat("/expel "..param)
		end
	end)
	sampRegisterChatCommand("devmaxrank", devmaxrank)
	sampRegisterChatCommand("goodverdict", goodverdict)
	updatechatcommands()

	while true do
		if not imgui.Process then
			if getCharPlayerIsTargeting() then
				local result, targettingped = getCharPlayerIsTargeting()
				if configuration.main_settings.createmarker then
					if sampGetPlayerIdByCharHandle(targettingped) then
						if marker ~= nil and oldtargettingped ~= targettingped then
							removeBlip(marker)
							marker = nil
							marker = addBlipForChar(targettingped)
						elseif marker == nil and oldtargettingped ~= targettingped then
							marker = addBlipForChar(targettingped)
						end
					end
				end
				oldtargettingped = targettingped
				if wasKeyPressed(vkeys.name_to_id(configuration.main_settings.usefastmenu,true)) then
					if not sampIsChatInputActive() then
						local result, targettingid = sampGetPlayerIdByCharHandle(targettingped)
						if targettingid ~= -1 then
							if not imgui_fm.v then
								local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
								fastmenuID = targettingid
								ASHelperMessage("Вы использовали меню быстрого доступа на: "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").."["..fastmenuID.."]")
								ASHelperMessage("Зажмите {"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)).."}ALT{FFFFFF} для того, чтобы скрыть курсор. {"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)).."}ESC{FFFFFF} для того, чтобы закрыть меню.")
								windowtype.v = 0
								imgui_fm.v = true
							end
						end
					end
				end
			end
		end
		if wasKeyPressed(vkeys.name_to_id(configuration.main_settings.fastscreen,true)) and not getscreenkey and configuration.main_settings.dofastscreen then
			sampSendChat('/time')
			wait(500)
			setVirtualKeyDown(VK_F8, true)
			wait(0)
			setVirtualKeyDown(VK_F8, false)
		end
		if imgui_settings.v or imgui_fm.v or imgui_binder.v or imgui_stats.v or imgui_sobes.v then
			imgui.Process = true
			imgui.ShowCursor = true
			if isKeyDown(0x12) then
				imgui.ShowCursor = false
			else
				imgui.ShowCursor = true
			end
			if wasKeyPressed(0x1B) then
				while isKeyDown(0x1B) do
					wait(0)
				end
				disableallimgui()
				imgui_binder.v = false
				imgui_stats.v = false
				imgui.ShowCursor = false
			end
		else
			imgui.ShowCursor = false
			imgui.Process = false
		end
		for key, value in pairs(configuration.BindsName) do
			if tostring(value) == tostring(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= "" then
					if configuration.BindsKeys[key]:match("(.+) %p (.+)") then
						local fkey = configuration.BindsKeys[key]:match("(.+) %p")
						local skey = configuration.BindsKeys[key]:match("%p (.+)")
						if isKeyDown(vkeys.name_to_id(fkey,true)) and wasKeyPressed(vkeys.name_to_id(skey,true)) then
							if not imgui.Process then
								if not inprocess then
									inprocess = true
									for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
										sampSendChat(tostring(bp))
										wait(configuration.BindsDelay[key])
									end
									inprocess = false
								else
									ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
								end
							else
								ASHelperMessage("Закройте все окна для активации бинда.")
							end
						end
					elseif configuration.BindsKeys[key]:match("(.+)") then
						local fkey = configuration.BindsKeys[key]:match("(.+)")
						if wasKeyPressed(vkeys.name_to_id(fkey,true)) then
							if not imgui.Process then
								if not inprocess then
									inprocess = true
									for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
										sampSendChat(tostring(bp))
										wait(configuration.BindsDelay[key])
									end
									inprocess = false
								else
									ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
								end
							else
								ASHelperMessage("Закройте все окна для активации бинда.")
							end
						end
					end
				end
			end
		end
		wait(0)
	end
end

function fastmenuopen()
	disableallimgui()
	imgui_settings.v = not imgui_settings.v
	settingswindow.v = 0
	userset = false
	licset = false
	keysset = false
	otherset = false
	scriptinfo = false
end

function binder()
	choosedslot = nil
	imgui_binder.v = not imgui_binder.v
end

function updaterank()
	getmyrank = true
	sampSendChat("/stats")
end

function checkmystats()
	imgui_stats.v = not imgui_stats.v
end

function hello()
	lua_thread.create(function()
		if inprocess ~= true then
			getmyrank = true
			sampSendChat("/stats")
			local hour = tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60))
			if configuration.main_settings.useservername then
				local result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
			else
				name = u8:decode(myname.v)
				if name == '' or name == nil then
					ASHelperMessage('Введите своё имя в /'..cmdhelp..' ')
					local result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
				end
			end
			local rang = configuration.main_settings.myrank
			inprocess = true
			if hour > 4 and hour < 13 then
				sampSendChat("Доброе утро, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
			elseif hour > 12 and hour < 17 then
				sampSendChat("Добрый день, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
			elseif hour > 16 and hour < 24 then
				sampSendChat("Добрый вечер, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
			elseif hour < 5 then
				sampSendChat("Доброй ночи, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
			end
			wait(cd)
			sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name..".")
			inprocess = false
		else
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		end
	end)
end

function pricelist()
	lua_thread.create(function()
		if inprocess ~= true then
			inprocess = true
			sampSendChat('/do В кармане брюк лежит прайс лист на лицензии.')
			wait(cd)
			sampSendChat('/me {gender:достал|достала} прайс лист из кармана брюк и передал его клиенту')
			wait(cd)
			sampSendChat('/do В прайс листе написано:')
			wait(cd)
			sampSendChat('/do Лицензия на вождение автомобилей - '..separator(tostring(configuration.main_settings.avtoprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на вождение мотоциклов - '..separator(tostring(configuration.main_settings.motoprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на рыболовство - '..separator(tostring(configuration.main_settings.ribaprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на водный транспорт - '..separator(tostring(configuration.main_settings.lodkaprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на оружие - '..separator(tostring(configuration.main_settings.gunaprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на охоту - '..separator(tostring(configuration.main_settings.huntprice)..'$.'))
			wait(cd)
			sampSendChat('/do Лицензия на раскопки - '..separator(tostring(configuration.main_settings.kladprice)..'$.'))
			inprocess = false
		else
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		end
	end)
end

function selllic(param)
	lua_thread.create(function()
		sellto, lictype = param:match('(.+) (.+)')
		local sellto = tonumber(sellto)
		local result, myid = sampGetPlayerIdByCharHandle(playerPed)
		if lictype ~= nil and sellto ~= nil then
			if inprocess ~= true then
				inprocess = true
					if lictype == 'полеты' or lictype == 'полёты' then
						sampSendChat('Получить лицензию на '..lictype..' вы можете в авиашколе г. Лас-Вентурас')
						sampSendChat('/n /gps -> Важные места -> Следующая страница -> [LV] Авиашкола (9)')
					elseif lictype == 'оружие' then
						if not cansell then
							result, myid = sampGetPlayerIdByCharHandle(playerPed)
							if sampIsPlayerConnected(sellto) or sellto == myid then
								sampSendChat('Хорошо, для покупки лицензии на оружие покажите мне свою мед.карту')
								sampSendChat('/n /showmc '..myid)
								ASHelperMessage('Началось ожидание показа мед.карты.')
								skiporcancel = false
								choosedname = sampGetPlayerNickname(fastmenuID)
								tempid = fastmenuID
							else
								ASHelperMessage('Такого игрока нет на сервере')
							end
						else
							inprocess = true
							sampSendChat('/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на '..lictype)
							wait(cd)
							sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
							wait(cd)
							sampSendChat('/me распечатав лицензию на '..lictype.." {gender:передал|передала} её человеку напротив")
							givelic = true
							cansell = false
							wait(100)
							sampSendChat('/givelicense '..sellto)
						end
					else
						sampSendChat('/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на '..lictype)
						wait(cd)
						sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
						wait(cd)
						sampSendChat('/me распечатав лицензию на '..lictype.." {gender:передал|передала} её человеку напротив")
						givelic = true
						wait(100)
						sampSendChat('/givelicense '..sellto)
					end
				inprocess = false
			else
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			end
		end
	end)
end

function invite(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				if id == nil then
					ASHelperMessage('/invite [id]')
				else
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('Вы не можете приглашать в организацию самого себя.')
					else
						inprocess = true
						sampSendChat('/do Ключи от шкафчика в кармане.')
						wait(cd)
						sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
						wait(cd)
						sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
						wait(cd)
						sampSendChat('Добро пожаловать! Раздевалка за дверью.')
						wait(cd)
						sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
						sampSendChat("/invite "..id)
						inprocess = false
					end
				end
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function uninvite(param)
	local id, withbl = param:match("(%d+) (%d)")
	local id = tonumber(id)
	local withbl = tonumber(withbl)
	lua_thread.create(function()
		inprocess = true
		if withbl == 0 then
			sampSendChat('/me {gender:достал|достала} КПК из кармана')
			wait(cd)
			sampSendChat('/me {gender:перешёл|перешла} в раздел "Увольнение"')
			wait(cd)
			sampSendChat('/do Раздел открыт.')
			wait(cd)
			sampSendChat('/me {gender:внёс|внесла} человека в раздел "Увольнение"')
			wait(cd)
			sampSendChat('/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} КПК и {gender:положил|положила} его обратно в карман')
			wait(cd)
			sampSendChat("/uninvite "..id..' '..u8:decode(uninvitebuf.v))
		elseif withbl == 1 then
			sampSendChat('/me {gender:достал|достала} КПК из кармана')
			wait(cd)
			sampSendChat('/me {gender:перешёл|перешла} в раздел "Увольнение"')
			wait(cd)
			sampSendChat('/do Раздел открыт.')
			wait(cd)
			sampSendChat('/me {gender:внёс|внесла} человека в раздел "Увольнение"')
			wait(cd)
			sampSendChat('/me {gender:перешёл|перешла} в раздел "Чёрный список"')
			wait(cd)
			sampSendChat('/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения')
			wait(cd)
			sampSendChat('/do Изменения были сохранены.')
			wait(cd)
			sampSendChat("/uninvite "..id..' '..u8:decode(uninvitebuf.v))
			wait(100)
			sampSendChat("/blacklist "..id..' '..u8:decode(blacklistbuf.v))
		end
		inprocess = false
	end)
end

function uninvitewithcmd(param)
	local uvalid,reason = param:match("(%d+) (.+)")
	local uvalid = tonumber(uvalid)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if uvalid == nil or uvalid == '' or reason == nil or reason == '' then
					ASHelperMessage('/uninvite [id] [причина]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if uvalid == myid then
						ASHelperMessage('Вы не можете увольнять из организации самого себя.')
					else
						sampSendChat('/me {gender:достал|достала} КПК из кармана')
						wait(cd)
						sampSendChat('/me {gender:перешёл|перешла} в раздел "Увольнение"')
						wait(cd)
						sampSendChat('/do Раздел открыт.')
						wait(cd)
						sampSendChat('/me {gender:внёс|внесла} человека в раздел "Увольнение"')
						wait(cd)
						sampSendChat('/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} КПК и {gender:положил|положила} его обратно в карман')
						sampSendChat("/uninvite "..uvalid..' '..reason)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function giverank(param)
	local id,rank = param:match("(%d+) (%d)")
	local id = tonumber(id)
	local rank = tonumber(rank)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if id == nil or id == '' or rank == nil or rank == '' then
					ASHelperMessage('/giverank [id] [ранг]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('Вы не можете менять ранг самому себе.')
					else
						sampSendChat('/me {gender:включил|включила} КПК')
						wait(cd)
						sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками"')
						wait(cd)
						sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
						wait(cd)
						sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
						wait(cd)
						sampSendChat('/do Информация о сотруднике была изменена.')
						wait(cd)
						sampSendChat('Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.')
						sampSendChat("/giverank "..id.." "..rank)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function blacklist(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/blacklist [id] [причина]')
				else
					sampSendChat("/me {gender:достал|достала} КПК из кармана")
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Чёрный список"')
					wait(cd)
					sampSendChat("/me {gender:ввёл|ввела} имя нарушителя")
					wait(cd)
					sampSendChat('/me {gender:внёс|внесла} нарушителя в раздел "Чёрный список"')
					wait(cd)
					sampSendChat("/me {gender:подтведрдил|подтвердила} изменения")
					wait(cd)
					sampSendChat("/do Изменения были сохранены.")
					sampSendChat("/blacklist "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function unblacklist(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
			inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unblacklist [id]')
				else
					sampSendChat("/me {gender:достал|достала} КПК из кармана")
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Чёрный список"')
					wait(cd)
					sampSendChat("/me {gender:ввёл|ввела} имя гражданина в поиск")
					wait(cd)
					sampSendChat('/me {gender:убрал|убрала} гражданина из раздела "Чёрный список"')
					wait(cd)
					sampSendChat("/me {gender:подтведрдил|подтвердила} изменения")
					wait(cd)
					sampSendChat("/do Изменения были сохранены.")
					sampSendChat("/unblacklist "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function fwarn(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fwarn [id] [причина]')
				else
					sampSendChat('/me {gender:достал|достала} КПК из кармана')
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками"')
					wait(cd)
					sampSendChat('/me {gender:зашёл|зашла} в раздел "Выговоры"')
					wait(cd)
					sampSendChat('/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор')
					wait(cd)
					sampSendChat('/do Выговор был добавлен в личное дело сотрудника.')
					wait(cd)
					sampSendChat("/fwarn "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function unfwarn(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unfwarn [id]')
				else
					sampSendChat("/me {gender:достал|достала} КПК из кармана")
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками"')
					wait(cd)
					sampSendChat('/me {gender:зашёл|зашла} в раздел "Выговоры"')
					wait(cd)
					sampSendChat("/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор")
					wait(cd)
					sampSendChat('/do Выговор был убран из личного дела сотрудника.')
					sampSendChat("/unfwarn "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function fmute(param)
	local id,mutetime,reason = param:match("(%d+) (%d+) (.+)")
	local id = tonumber(id)
	local mutetime = tonumber(mutetime)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fmute [id] [время] [причина]')
				else
					sampSendChat('/me {gender:достал|достала} КПК из кармана')
					wait(cd)
					sampSendChat('/me {gender:включил|включила} КПК')
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками Автошколы"')
					wait(cd)
					sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
					wait(cd)
					sampSendChat('/me {gender:выбрал|выбрала} пункт "Отключить рацию сотрудника"')
					wait(cd)
					sampSendChat('/me {gender:нажал|нажала} на кнопку "Сохранить изменения"')
					sampSendChat("/fmute "..id.." "..mutetime.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function funmute(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/funmute [id]')
				else
					sampSendChat('/me {gender:достал|достала} КПК из кармана')
					wait(cd)
					sampSendChat('/me {gender:включил|включила} КПК')
					wait(cd)
					sampSendChat('/me {gender:перешёл|перешла} в раздел "Управление сотрудниками Автошколы"')
					wait(cd)
					sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
					wait(cd)
					sampSendChat('/me {gender:выбрал|выбрала} пункт "Включить рацию сотрудника"')
					wait(cd)
					sampSendChat('/me {gender:нажал|нажала} на кнопку "Сохранить изменения"')
					sampSendChat("/funmute "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 9-го ранга.")
		end
	end)
end

function expel(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 5 then
			if inprocess then
				ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/expel [id] [причина]')
				else
					sampSendChat('/do Рация свисает на поясе.')
					wait(cd)
					sampSendChat('/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней')
					wait(cd)
					sampSendChat('/do Охрана выводит нарушителя из холла.')
					sampSendChat("/expel "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Данная команда доступна с 5-го ранга.")
		end
	end)
end

function sobes1()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		else
			inprocess = true
			if configuration.main_settings.useservername then
				local result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
			else
				name = u8:decode(configuration.main_settings.myname)
				if name == '' or name == nil then
					ASHelperMessage('Введите своё имя в /'..cmdhelp..' ')
					local result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
				end
			end
			local rang = configuration.main_settings.myrank
			sampSendChat("Здравствуйте, вы на собеседование?")
			wait(cd)
			sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			inprocess = false
		end
	end)
end

function sobes2()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		else
			inprocess = true
			sampSendChat("Хорошо, для этого покажите мне ваши документы, а именно: паспорт и мед.карту")
			sampSendChat("/n ОБЯЗАТЕЛЬНО по рп!")
			wait(50)
			sobesetap.v = 1
			inprocess = false
		end
	end)
end

function sobesaccept1()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		else
			inprocess = true
			wait(50)
			sobesetap.v = 2
			sampSendChat("/me взяв документы из рук человека напротив {gender:начал|начала} их проверять")
			wait(cd)
			sampSendChat("/todo Хорошо...* отдавая документы обратно")
			wait(cd)
			sampSendChat("Сейчас я задам вам несколько вопросов, вы готовы на них отвечать?")
			inprocess = false
		end
	end)
end

function sobesaccept2()
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		else
			inprocess = true
			if configuration.main_settings.myrankint >= 9 then
				sampSendChat("Отлично, я думаю вы нам подходите!")
				wait(cd)
				inprocess = false
				invite(tostring(fastmenuID))
			else
				sampSendChat("Отлично, я думаю вы нам подходите!")
				wait(cd)
				sampSendChat("/r "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").." успешно прошёл собеседование! Он ждёт старших около стойки чтобы вы его приняли.")
				wait(cd)
				sampSendChat("/rb "..fastmenuID.." id")
			end
			inprocess = false
		end
	end)
end

function sobesdecline(param)
	local reason = param:match("(.+)")
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
		else
			inprocess = true
			if reason ~= "проф. непригодность1" and reason ~= "проф. непригодность3" and reason ~= "проф. непригодность5" then
				sampSendChat("/me взяв документы из рук человека напротив {gender:начал|начала} их проверять")
				wait(cd)
				sampSendChat("/todo Очень грустно...* отдавая документы обратно")
				wait(cd)
			end
			if reason == ("наркозависимость") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы слишком наркозависимый.")
			elseif reason == ("не полностью здоровый") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы не полностью здоровый.")
			elseif reason == ("не законопослушный") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы недостаточно законопослушный.")
			elseif reason == ("меньше 3 лет в штате") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы не проживаете в штате 3 года.")
			elseif reason == ("игрок в организации") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы уже работаете в другой организации.")
			elseif reason == ("был в деморгане") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы лечились в псих. больнице.")
			elseif reason == ("в чс автошколы") then
				sampSendChat("К сожалению я не могу продолжить собеседование. Вы находитесь в ЧС АШ.")
			elseif reason == ("проф. непригодность1") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы проф. непригодны.")
				sampSendChat("/b Ничего не показал")
			elseif reason == ("проф. непригодность2") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы проф. непригодны.")
				sampSendChat("/b Ужасное РП")
			elseif reason == ("проф. непригодность3") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы проф. непригодны.")
				sampSendChat("/b Не было РП")
			elseif reason == ("проф. непригодность4") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы проф. непригодны.")
				sampSendChat("/b Плохая грамматика")
			elseif reason == ("проф. непригодность5") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы проф. непригодны.")
			end
			inprocess = false
		end
	end)
end

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		if tostring(value) == tostring(configuration.BindsName[key]) then
			if configuration.BindsCmd[key] ~= "" then
				sampUnregisterChatCommand(configuration.BindsCmd[key])
				sampRegisterChatCommand(configuration.BindsCmd[key], function()
					lua_thread.create(function()
						if not inprocess then
							for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
								inprocess = true
								sampSendChat(tostring(bp))
								wait(configuration.BindsDelay[key])
								inprocess = false
							end
						else
							ASHelperMessage("Не торопитесь, вы уже отыгрываете что-то!")
						end
					end)
				end)
			end
		end
	end
end

if sampevcheck then
	--Отдельное спасибо Bank Helper от Cosmo. Оттуда взял несколько интересных идей.
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 235 and getmyrank then
			if text:find('Инструкторы') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('Должность: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						rangint = tonumber(getStatsRank)
						rang = nameRankStats
						configuration.main_settings.myrank = rang
						configuration.main_settings.myrankint = rangint
						if nameRankStats:find('Упраляющий') or devmaxrankp then
							getStatsRank = 10
							configuration.main_settings.myrank = "Упраляющий"
							configuration.main_settings.myrankint = 10
						end
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
			else
				ASHelperMessage('Вы не работаете в автошколе, скрипт выгружен!')
				NoErrors = true
				thisScript():unload()
			end
			getmyrank = false
			return false
		end

		if dialogId == 6 and givelic then
			if lictype == "авто" then
				sampSendDialogResponse(dialogId, 1, 0, nil)
			end
			if lictype == "мото" then
				sampSendDialogResponse(dialogId, 1, 1, nil)
			end
			if lictype == "рыболовство" then
				sampSendDialogResponse(dialogId, 1, 3, nil)
			end
			if lictype == "плавание" then
				sampSendDialogResponse(dialogId, 1, 4, nil)
			end
			if lictype == "оружие" then
				sampSendDialogResponse(dialogId, 1, 5, nil)
			end
			if lictype == "охоту" then
				sampSendDialogResponse(dialogId, 1, 6, nil)
			end
			if lictype == "раскопки" then
				sampSendDialogResponse(dialogId, 1, 7, nil)
			end
			givelic = false
			return false
		end

		if dialogId == 1234 then
			if text:find('Срок действия') then
				if not mcvalue then
					if text:find("Имя: "..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find("Полностью здоровый") then
							local statusint = DialogLine:match('{CEAD2A}Наркозависимость: (%d+)')
								if tonumber(statusint) then
									statusint = tonumber(statusint)
									if statusint <= 5 then
										mcvalue = true
										mcverdict = ("в порядке")
									else
										mcvalue = true
										mcverdict = ("наркозависимость")
									end
								end
							else
								mcvalue = true
								mcverdict = ("не полностью здоровый")
							end
						end
					end
				elseif not skiporcancel then
					if text:find("Имя: "..choosedname) then
						if text:find("Полностью здоровый") then
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								inprocess = true
								sampSendChat("/me взяв мед.карту в руки начал её проверять")
								wait(cd)
								sampSendChat("/do Мед.карта в норме.")
								wait(cd)
								sampSendChat("/todo Всё в порядке* отдавая мед.карту обратно")
								wait(cd)
								skiporcancel = true
								cansell = true
								inprocess = false
								selllic(tempid..' оружие')
							end)
						else
							lua_thread.create(function()
								inprocess = true
								ASHelperMessage('Человек не полностью здоровый, требуется поменять мед.карту!')
								sampSendChat("/me взяв мед.карту в руки начал её проверять")
								wait(cd)
								sampSendChat("/do Мед.карта не в норме.")
								wait(cd)
								sampSendChat("/todo К сожалению, в мед.карте написано, что у вас есть отклонения.* отдавая мед.карту обратно")
								wait(cd)
								sampSendChat("Обновите её и приходите снова!")
								skiporcancel = true
								cansell = false
								inprocess = false
							end)
						end
						return false
					end
				end
			elseif text:find('Серия') then
				if not passvalue then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("Имя: {FFD700}"..sampGetPlayerNickname(fastmenuID)) then
							if not text:find('{FFFFFF}Организация:') then
								for DialogLine in text:gmatch('[^\r\n]+') do
									local passstatusint = DialogLine:match('{FFFFFF}Лет в штате: {FFD700}(%d+)')
									if tonumber(passstatusint) then
										if tonumber(passstatusint) >= 3 then
											for DialogLine in text:gmatch('[^\r\n]+') do
												local zakonstatusint = DialogLine:match('{FFFFFF}Законопослушность: {FFD700}(%d+)')
												if tonumber(zakonstatusint) then
													if tonumber(zakonstatusint) >= 35 then
														if not text:find('Лечился в Психиатрической больнице') then
															if not text:find('Состоит в ЧС{FF6200} Инструкторы') then
																passvalue = true
																passverdict = ("в порядке")
															else
																passvalue = true
																passverdict = ("в чс автошколы")
															end
														else
															passvalue = true
															passverdict = ("был в деморгане")
														end
													else
														passvalue = true
														passverdict = ("не законопослушный")
													end
												end
											end
										else
											passvalue = true
											passverdict = ("меньше 3 лет в штате")
										end
									end
								end
							else
								passvalue = true
								passverdict = ("игрок в организации")
							end
						end
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
			if message:find('Используйте: /jobprogress %[ ID игрока %]') then
				ASHelperMessage("Вы просмотрели свою рабочую успеваемость.")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в гражданскую одежду') then
				ASHelperMessage("Вы закончили рабочий день, удачного отдыха!")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в рабочую одежду') then
				ASHelperMessage("Вы начали рабочий день, удачной работы!")
				return false
			end
			if message:find('%[Информация%] {FFFFFF}Вы покинули пост!') then
				ASHelperMessage('Вы покинули пост.')
				return false
			end
		end
		if message:find('%[R%]') and not message:find('%[Объявление%]') and color == 766526463 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message}
		end
		if message:find('%[D%]') and color == 865730559 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message }
		end
		if message:find('повысил до') then
			getmyrank = true
			sampSendChat("/stats")
		end
		if message:find("%[Информация%] {FFFFFF}Вы успешно продали лицензию") then
			typeddd, toddd = message:match("%[Информация%] {FFFFFF}Вы успешно продали лицензию на (.+) игроку (.+).")
			if typeddd == "авто" then
				configuration.my_stats.avto = configuration.my_stats.avto + 1
			elseif typeddd == "мото" then
				configuration.my_stats.moto = configuration.my_stats.moto + 1
			elseif typeddd == "рыбалку" then
				configuration.my_stats.riba = configuration.my_stats.riba + 1
			elseif typeddd == "плавание" then
				configuration.my_stats.lodka = configuration.my_stats.lodka + 1
			elseif typeddd == "оружие" then
				configuration.my_stats.guns = configuration.my_stats.guns + 1
			elseif typeddd == "охоту" then
				configuration.my_stats.hunt = configuration.my_stats.hunt + 1
			elseif typeddd == "раскопки" then
				configuration.my_stats.klad = configuration.my_stats.klad + 1
			else
				if configuration.main_settings.replacechat then
					ASHelperMessage("Вы успешно продали лицензию на "..typeddd.." игроку "..toddd:gsub("_"," ")..".")
					return false
				end
			end
			if inicfg.save(configuration,"AS Helper") then
				if configuration.main_settings.replacechat then
					ASHelperMessage("Вы успешно продали лицензию на "..typeddd.." игроку "..toddd:gsub("_"," ")..". Она была засчитана в вашу статистику.")
					return false
				else
				end
			end
		end
		if message:find("Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)") then
			local result,myid = sampGetPlayerIdByCharHandle(playerPed)
			local invited,inviting = message:match("Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)%[")
			if inviting == sampGetPlayerNickname(myid) then
				if invited == sampGetPlayerNickname(waitingaccept) then
					sampSendChat("/giverank "..waitingaccept.." 2")
					waitingaccept = false
					ASHelperMessage(string.gsub(sampGetPlayerNickname(waitingaccept), "_", " ").." принял ваше предложение вступить в Автошколу и был повышен до должности Консультанта.")
					return false
				end
			end
		end
	end
	
	function sampev.onSendChat(message)
		if message:find('{gender:%A+|%A+}') then
			local male, female = message:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = message:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = message:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
		--Скрипт акцента Raymond: https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == "q" then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), "акцент") or string.find(u8:decode(configuration.main_settings.myaccent), "Акцент") then
				return{'['..u8:decode(configuration.main_settings.myaccent)..']: '..message}
			else
				return{'['..u8:decode(configuration.main_settings.myaccent)..' акцент]: '..message}
			end
		end
	end
	
	function sampev.onSendCommand(cmd)
		if cmd:find('{gender:%A+|%A+}') then
			local male, female = cmd:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
	end
end

function autoGetSelfGender()
	local skins = {
		[0] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 149, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 304, 305, 310, 311}, 
		[1] = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307, 308, 309}
	}
	for k, v in pairs(skins) do
		for _, skin in pairs(v) do
			if skin == getCharModel(playerPed) then
				gender.v = k
				configuration.main_settings.gender = gender.v
				if inicfg.save(configuration,"AS Helper") then
				end
				return k
			end
		end
	end
	return nil
end

local russian_characters = {
    [155] = '[', [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}

function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function devmaxrank()
	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
		devmaxrankp = not devmaxrankp
		sampAddChatMessage("{ff6633}[Режим разработчика] {FFFFFF}Имитировать максимальный ранг: " ..(devmaxrankp and "{00FF00}Включено" or "{FF0000}Выключено"), 0xff6633)
		getmyrank = true
		sampSendChat("/stats")
	else
		sampAddChatMessage("{ff6347}[Ошибка] {FFFFFF}Неизвестная команда! Введите /help для просмотра доступных функций.",0xff6347)
	end
end

function goodverdict()
	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
		sampAddChatMessage("{ff6633}[Режим разработчика] {FFFFFF}Вы имитировали одобренный вердикт паспорта и мед.карты в собеседовании.", 0xff6633)
		mcvalue = true
		passvalue = true
		mcverdict = ("в порядке")
		passverdict = ("в порядке")
	else
		sampAddChatMessage("{ff6347}[Ошибка] {FFFFFF}Неизвестная команда! Введите /help для просмотра доступных функций.",0xff6347)
	end
end

function ASHelperMessage(value)
	local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
	sampAddChatMessage("[ASHelper] {EBEBEB}"..value,"0x"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)))
end

--Разделение денежных сумм на точки от Royan_Millans: https://www.blast.hk/threads/39380/
function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function separator(text)
	if text:find("$") then
	    for S in string.gmatch(text, "%$%d+") do
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	    for S in string.gmatch(text, "%d+%$") do
	    	S = string.sub(S, 0, #S-1)
	    	local replace = comma_value(S)
	    	text = string.gsub(text, S, replace)
	    end
	end
	return text
end

addEventHandler('onWindowMessage', function(msg, wparam, lparam)
	if imgui.Process then
    	if wparam == 0x1B then
			consumeWindowMessage(true, false)
		end
	end
	if getbindkey or getscreenkey or setbinderkey then
		if getbindkey then
			if msg == 0x100 or msg == 0x104 then
				local keyname = vkeys.id_to_name(wparam)
				configuration.main_settings.usefastmenu = keyname
				if inicfg.save(configuration,"AS Helper") then
				end
				getbindkey = false
			end
		end
		if getscreenkey then
			if msg == 0x100 or msg == 0x104 then
				local keyname = vkeys.id_to_name(wparam)
				configuration.main_settings.fastscreen = keyname
				if inicfg.save(configuration,"AS Helper") then
				end
				lua_thread.create(function ()
					wait(100)
					getscreenkey = false
				end)
			end
		end
		if setbinderkey then
			if msg == 0x100 or msg == 0x104 then
				if not emptykey1[1] then
					emptykey1[1] = vkeys.id_to_name(wparam)
					keyname = vkeys.id_to_name(wparam)
					binderkeystatus = u8"Применить "..keyname
				elseif not emptykey2[1] and vkeys.id_to_name(wparam) ~= keyname then
					emptykey2[1] = vkeys.id_to_name(wparam)
					keyname2 = vkeys.id_to_name(wparam)
					if keyname2 == "Shift" or keyname2 == "Alt" or keyname2 == "Ctrl" or keyname2 == "Space" then
						binderkeystatus = keyname2.." + "..keyname
						setbinderkey = false
					else
						binderkeystatus = keyname.." + "..keyname2
						setbinderkey = false
					end
				end
			end
		end
	end
end)

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function onQuitGame()
	if inicfg.save(configuration, 'AS Helper.ini') then 
	end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        if not sampIsDialogActive() then
            showCursor(false, false)
        end
        if inicfg.save(configuration, 'AS Helper.ini') then 
        end
		if NoErrors then
			return false
		end
    	sampShowDialog(1313, "{ff6633}[AS Helper]{ffffff} Скрипт был выгружен сам по себе.", [[
{ffffff}                                                                             Что делать в таких случаях?{f51111}

Если вы самостоятельно перезагрузили скрипт, то можете закрыть это диалоговое окно.
В ином случае, для начала попытайтесь восстановить работу скрипта сочетанием клавиш CTRL + R.
Если же это не помогло, то читайте следующие пункты.{ff6633}

1. Возможно у вас установлены другие LUA файлы и хелперы, попытайтесь удалить их.

2. Возможно вы не доустановили некоторые дополнения, а именно:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26

3. Если данной ошибки не было ранее, попытайтесь сделать следующие действия:
- В папке moonloader > config > Удаляем файл AS Helper.ini

4. Если ничего из вышеперечисленного не исправило ошибку, то следует установить скрипт на другую сборку.

5. Если у вас скрипт вылетает по нажатию на какую-то кнопку, то можете отправить (JustMini#6291) эту ошибку.]], "ОК", nil, 0)
	end
end

function disableallimgui()
	imgui_settings.v = false
	imgui_fm.v = false
	imgui_sobes.v = false
	mcvalue = true
	passvalue = true
end

if imguicheck then
end

function checkbibl()
	if not sampevcheck then
		ASHelperMessage("Отсутствует библиотека samp events. Пытаюсь её установить.")
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events.lua', 'moonloader/lib/samp/events.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/raknet.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/synchronization.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/bitstream_io.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/core.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/extra_types.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/handlers.lua') then
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/utils.lua') then
					ASHelperMessage("Библиотека samp events была успешно установлена.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not encodingcheck then
		ASHelperMessage("Отсутствует библиотека encoding. Пытаюсь её установить.")
		if doesFileExist('moonloader/lib/encoding.lua') then
			os.remove('moonloader/lib/encoding.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/encoding.lua') then
					ASHelperMessage("Библиотека encoding была успешно установлена.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not imguicheck then
		ASHelperMessage("Отсутствует библиотека imgui. Пытаюсь её установить.")
		if doesFileExist('moonloader/lib/imgui.lua') then
			os.remove('moonloader/lib/imgui.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/imgui.lua') then
					ASHelperMessage("Библиотека imgui была успешно установлена.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not facheck then
		ASHelperMessage("Отсутствует библиотека fAwesome5. Пытаюсь её установить.")
		if doesFileExist('moonloader/lib/fAwesome5.lua') then
			os.remove('moonloader/lib/fAwesome5.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/fAwesome5.lua', 'moonloader/lib/fAwesome5.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/fAwesome5.lua') then
					ASHelperMessage("Библиотека fAwesome5 была успешно установлена.")
					fa = require"fAwesome5"
					fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage("Отсутствует файл шрифта. Пытаюсь его установить.")
		createDirectory('moonloader/resource/fonts')
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
					ASHelperMessage("Файл шрифта был успешно установлен.")
				else
					ASHelperMessage("Произошла ошибка во время установки.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if doesFileExist('moonloader/config/updateashelper.ini') then
		os.remove('moonloader/config/updateashelper.ini')
	end
	createDirectory('moonloader/config')
	downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/update.ini', 'moonloader/config/updateashelper.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/config/updateashelper.ini') then
				updates = io.open('moonloader/config/updateashelper.ini','r')
				local tempdata = {}
				for line in updates:lines() do
					table.insert(tempdata, line)
				end
				io.close(updates)
				if tonumber(tempdata[1]) > scriptvernumb then
					ASHelperMessage("Найдено обновление. Пытаюсь установить его.")
					doupdate = true
				else
					ASHelperMessage("Обновлений не найдено.")
					doupdate = false
				end
				os.remove('moonloader/config/updateashelper.ini')
			else
				ASHelperMessage("Произошла ошибка во время проверки обновлений.")
				thisScript():unload()
			end
		end
	end)
	while doupdate == nil do
		wait(300)
	end
	if doupdate then
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/AS%20Helper.lua', thisScript().path,function(id3, status1)
			if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
				NoErrors = true
				ASHelperMessage("Обновление успешно установлено.")
			end
		end)
		return false
	end
	return true
end