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
local scriptvernumb 		= 19

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
	ComboBox_arr 			= {u8"Àâòî",u8"Ìîòî",u8"Ðûáîëîâñòâî",u8"Ïëàâàíèå",u8"Îðóæèå",u8"Îõîòà",u8"Ðàñêîïêè"}
	avtoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7)
	motoprice 				= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7)
	ribaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7)
	lodkaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7)
	gunaprice 				= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7)
	huntprice 				= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7)
	kladprice				= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7)

	StyleBox_select			= imgui.ImInt(configuration.main_settings.style)
	StyleBox_arr			= {u8"Ò¸ìíî-îðàíæåâàÿ (transp.)",u8"Ò¸ìíî-êðàñíàÿ (not transp.)",u8"Ñâåòëî-ñèíÿÿ (not transp.)",u8"Ôèîëåòîâàÿ (not transp.)",u8"Ñâåòëî-ò¸ìíàÿ (not transp.)",u8"Ò¸ìíî-çåëåíàÿ (not transp.)"}
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
	Ranks_arr 				= {u8"[1] Ñòàæ¸ð",u8"[2] Êîíñóëüòàíò",u8"[3] Ëèöåíç¸ð",u8"[4] Ìë. Èíñòðóêòîð",u8"[5] Èíñòðóêòîð",u8"[6] Ìåíåäæåð",u8"[7] Ñò. Ìåíåäæåð",u8"[8] Ïîìîùíèê äèðåêòîðà",u8"[9] Äèðåêòîð"}

	gender 					= imgui.ImInt(configuration.main_settings.gender)
	gender_arr 				= {u8"Ìóæñêîé",u8"Æåíñêèé"}

	sobesdecline_select 	= imgui.ImInt(0)
	sobesdecline_arr 		= {u8"Ïëîõîå ÐÏ",u8"Íå áûëî ÐÏ",u8"Ïëîõàÿ ãðàììàòèêà",u8"Íè÷åãî íå ïîêàçàë",u8"Äðóãîå"}

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
						imgui.CenterTextColoredRGB('{FFFFFF}Ïîäñêàçêà')
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
		if imgui.BeginPopupModal(u8("Ñïèñîê èçìåíåíèé"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.CenterTextColoredRGB("Âåðñèÿ ñêðèïòà: 2.0b")
			imgui.BeginChild("##ChangeLog", imgui.ImVec2(700, 330), false)
			imgui.InputTextMultiline("Read",imgui.ImBuffer(u8([[
Âåðñèÿ 2.0
 - Äîáàâëåí ñïèñîê èçìåíåíèé
 - Èñïðàâëåíà ïðîâåðêà îáíîâëåíèé ÷åðåç /ash
 - Êàðäèíàëüíî èçìåíåíî ãëàâíîå ìåíþ /ash
 - Äîáàâëåíû ðàçíûå ñòèëè îêîí
 - Äîáàâëåíû íàñòðîéêè öâåòîâ /r ÷àòà è /d ÷àòà
 - Äîáàâëåíà ôóíêöèÿ ïðîñìîòðà ïðàâèë
 - Äîáàâëåíà ôóíêöèÿ áûñòðîãî /time + ñêðèí
 - Äîáàâëåíî àâòîîïðåäåëåíèå ïîëà
 - Èñïðàâëåí áàã ñ óäàðîì ïðè ïðèíÿòèè ÷åëîâåêà â îðãàíèçàöèþ
 - Äîáàâëåíà ôóíêöèÿ óäàëåíèÿ êîíôèãà

Âåðñèÿ 1.1 - 1.9
 - Äîáàâëåíû ïîäñêàçêè â áèíäåðå
 - Èçìåíåíà ñèñòåìà ñîáåñåäîâàíèé
 - Íà ESC òåïåðü çàêðûâàþòñÿ îêíà
 - Ñäåëàíî áîëåå óäîáíîå èçìåíåíèå ðàíãà
 - Èñïðàâëåí áàã ñ íåïðîäàþùèìèñÿ ëèöåíçèÿìè
 - Òåïåðü ñêðèïò âíå çàâèñèìîñòè îò âàøåãî âðåìåíè íà ñèñòåìå ïîäñòðàèâàåòñÿ ïîä ÌÑÊ ÷àñîâîé ïîÿñ.
 - Äîáàâëåíà ôóíêöèÿ ïðèíÿòèå íà äîëæíîñòü Êîíñóëüòàíòà
 - Ïðè çàæàòîì ALT ïðîïàäàåò êóðñîð âî âðåìÿ îòêðûòûõ îêî
 - Äîáàâëåíà ñòàòèñòèêà ïðîäàííûõ ëèöåíçèé (/ashstats)
 - Äîáàâëåíû çàìåíû íà ñåðâåðíûå ñîîáùåíèÿ
 - Äîáàâëåíà ôóíêöèÿ ïðîâåðêè óñòàâà
 - Èñïðàâëåíû áàãè

Âåðñèÿ 1.0
 - Ðåëèç]])),imgui.ImVec2(-1, -1), imgui.InputTextFlags.ReadOnly)
		imgui.EndChild()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
		if imgui.Button(u8"Çàêðûòü",imgui.ImVec2(200,25)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
		end
	end

	function ustav()
		if imgui.BeginPopupModal(u8("Óñòàâ àâòîøêîëû"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			imgui.PushItemWidth(200)
			imgui.PushAllowKeyboardFocus(false)
			imgui.InputText("##search_ustav", search_ustav, imgui.InputTextFlags.EnterReturnsTrue)
			imgui.PopAllowKeyboardFocus()
			imgui.PopItemWidth()
			if not imgui.IsItemActive() and #search_ustav.v == 0 then
				imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' Ïîèñê ïî óñòàâó')).x) / 2)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' Ïîèñê ïî óñòàâó'))
			end
			imgui.CenterTextColoredRGB('{868686}Äâîéíîé êëèê ïî ñòðîêå, âûâåäåò å¸ â ïîëå ââîäà â ÷àòå')
			imgui.BeginChild("##Ustav", imgui.ImVec2(800, 400), true)
			local ustav = {
"Ãëàâà I. Îáùåå ïîëîæåíèå",
"1.1. Äàííûé äîêóìåíò îáÿçàí çíàòü è ñîáëþäàòü êàæäûé ñîòðóäíèê Àâòîøêîëû.",
"1.2. Çà íàðóøåíèÿ îäíîãî èç ïóíêòîâ äàííîãî äîêóìåíòà ïîñëåäóåò íàêàçàíèå.",
"1.3. Íåçíàíèå óñòàâà íå îñâîáîæäàåò îò îòâåòñòâåííîñòè.",
"1.4. Ñîòðóäíèêè ñòàðøåãî ñîñòàâà [5-9] äîëæíû ñëåäèòü çà ïîðÿäêîì è äèñöèïëèíîé â Àâòîøêîëå.",
"1.5. Êàæäûé ñîòðóäíèê äîëæåí çíàòü ñâîè ðàáî÷èå îáÿçàííîñòè íà êàæäîé äîëæíîñòè.",
"1.6.Êàæäûé ñîòðóäíèê îáÿçàí ñîáëþäàòü ñóáîðäèíàöèþ.",
"1.7. Ðåøåíèå Óïðàâëÿþùåãî ÿâëÿåòñÿ îêîí÷àòåëüíûì è îáæàëîâàíèþ íå ïîäëåæèò.",
"1.8. Óñòàâ ìîæåò èñïðàâëÿòüñÿ/äîïîëíÿòüñÿ Óïðàâëÿþùèì àâòîøêîëû.",
"1.9 Ñîòðóäíèêè Àâòîøêîëû îáÿçàíû îòâå÷àòü íà çàäàâàåìûå ïîñåòèòåëÿìè âîïðîñû.",
"1.10 Êóðèðóþùèì ñîñòàâîì ÿâëÿþòñÿ Óïðàâëÿþùèé è Äèðåêòîðà.",
"",
"Ãëàâà II. Ýòèêåò è ñóáîðäèíàöèÿ.",
"",
"2.1 Ïðàâèëà ýòèêåòà - ýòî ñâîä ïðàâèë ïîâåäåíèÿ, ïðèíÿòûõ â îïðåäåëåííûõ ñîöèàëüíûõ êðóãàõ.",
"2.2 Ñóáîðäèíàöèÿ - ýòî ïðàâèëà îáùåíèÿ ìåæäó ñîòðóäíèêàìè, ðàçíûìè ïî äîëæíîñòè.",
"2.3 Âñå ñîòðóäíèêè äîëæíû óâàæèòåëüíî îòíîñèòüñÿ êî âñåì îêðóæàþùèì èõ ëþäÿì.",
"2.4 Ñîòðóäíèê îáÿçàí óâàæàòü ëþäåé, êîòîðûå íèæå åãî ïî äîëæíîñòè.",
"2.5 Äîïóñêàþòñÿ îáðàùåíèå ïî äîëæíîñòè, èìåíè, 'ñýð', 'êîëëåãà'.",
"2.6 Êàæäûé ðàáîòíèê àâòîøêîëû îáÿçàí ïðåäñòàâèòüñÿ ïåðåä êëèåíòîì.",
"2.7 Ëþáîé ñîòðóäíèê àâòîøêîëû îáÿçàí áûòü âåæëèâûì íåñìîòðÿ íà ïîâåäåíèå êëèåíòà.",
"",
"Ãëàâà III. Ïðàâèëà ïîëüçîâàíèÿ ò/ñ Àâòîøêîëû.",
"",
"3.1 Ïðàâèëà ïîëüçîâàíèÿ ò/ñ äîëæíû ñîáëþäàòü âñå ñîòðóäíèêè Àâòîøêîëû.",
"3.2 Ò/ñ ðàçðåøåíî áðàòü ïî ñëåäóþùåìó ïðèíöèïó:",
"à) Ëèöåíçåð[3] - ìîòîöèêë;",
"á) 4-7 ðàíãè - àâòîìîáèëü;",
"â) Çàì. Äèðåêòîðà è âûøå - âåðòîëåò.",
"3.3 Çàïðåùåíî èñïîëüçîâàòü ñëóæåáíûé òðàíñïîðò â ñâîèõ öåëÿõ.",
"3.4 Çàïðåùåíî èñïîëüçîâàòü ñëóæåáíûé òðàíñïîðò âíå ðàáî÷åãî äíÿ, èñêëþ÷åíèå: ìîæíî èñïîëüçîâàòü äëÿ òðåíèðîâîê è ò.ï.",
"3.5 Çàïðåùåíî èñïîëüçîâàòü ñëóæåáíûé òðàíñïîðò, íå ïðåäóïðåäèâ îá ýòîì ðóêîâîäñòâî.",
"",
"Ãëàâà IV. Ðàáî÷èé ãðàôèê.",
"",
"4.1 Ðàáî÷åå âðåìÿ (Ïîíåäåëüíèê-Ïÿòíèöà):",
"4.1.1 Äíåâíàÿ ñìåíà ñ 09:00 äî 19:00",
"4.1.2 Ïåðåðûâ íà îáåä - ñ 13:00 äî 14:00",
"4.1.3 Ðàáî÷åå âðåìÿ (Ñóááîòà-Âîñêðåñåíüå):",
"4.1.4 Äíåâíàÿ ñìåíà ñ 10:00 äî 18:00",
"4.1.5 Ïåðåðûâ íà îáåä - ñ 13:00 äî 14:00",
"4.2 Êàæäûé ñîòðóäíèê Àâòîøêîëû äîëæåí íàõîäèòüñÿ â Àâòîøêîëå âî âðåìÿ ðàáî÷åãî âðåìåíè.",
"4.3 Ïîêèäàòü çäàíèå ðàçðåøåíî òîëüêî ñ ðàçðåøåíèåì ñòàðøèõ. ( åñëè èõ íåò â øòàòå - äîëîæèòü ïî ðàöèè è ñäåëàòü*screenshot + /time* )",
"4.4 Çà ïðîãóëû â ðàáî÷åå âðåìÿ ñîòðóäíèê ïîëó÷èò âûãîâîð, ëèáî æå áóäåò óâîëåí.",
"4.5 Ïî îêîí÷àíèþ äíåâíîé ñìåíû âñå ñîòðóäíèêè äîëæíû ñäàòü ôîðìó è äóáèíêè êðîìå òåõ, êòî îñòàåòñÿ íà íî÷íóþ ñìåíó.",
"4.6 Ïîñåùåíèå íî÷íîé ñìåíû íå ÿâëÿåòñÿ îáÿçàòåëüíûì, íî îíî áóäåò ïîîùðÿòüñÿ.",
"",
"Ãëàâà V. Îáÿçàííîñòè ñîòðóäíèêîâ Àâòîøêîëû.",
"",
"5.1 Êàæäûé ñîòðóäíèê îáÿçàí ñîáëþäàòü è çíàòü óñòàâ Àâòîøêîëû.",
"5.2 Êàæäûé ñîòðóäíèê äîëæåí ñîáëþäàòü ñóáîðäèíàöèþ â îáùåíèè.",
"5.3 Êàæäûé ñîòðóäíèê îáÿçàí ñëóøàòüñÿ ñâîåãî íåïîñðåäñòâåííîãî ðóêîâîäèòåëÿ.",
"5.4 Êàæäûé ñîòðóäíèê äîëæåí çíàòü ðóêîâîäÿùèé ñîñòàâ â ëèöî è ïî èìåíè.",
"5.5 Äèðåêòîðà è èõ çàìåñòèòåëè îáÿçàíû îò÷èòûâàþòñÿ î ñâîåé íåäåëüíîé ðàáîòå ïðè æåëàíèè Óïðàâëÿþùåãî.",
"5.6 Êàæäûé ñîòðóäíèê îáÿçàí ñîáëþäàòü çàêîíîäàòåëüñòâî Øòàòà.",
"5.7 Êàæäûé ñîòðóäíèê Àâòîøêîëû îáÿçàí êà÷åñòâåííî âûïîëíÿòü ñâîþ ïîñòàâëåííóþ ðàáîòó.",
"5.8 Ñîòðóäíèêè îáÿçàíû ïîä÷èíèòüñÿ ñîòðóäíèêàì ïðàâîîõðàíèòåëüíîé âëàñòè, ïðè òåðàêòå èëè îãðàáëåíèè.",
"5.9 Ñîòðóäíèêè äîëæíû ñîäåéñòâîâàòü îðãàíàì ïðàâîîõðàíèòåëüíîé âëàñòè.",
"5.10 Ñîòðóäíèêè Àâòîøêîëû, íà÷èíàÿ ñ äîëæíîñòè 'Êîíñóëüòàíò'[2] îáÿçàíû èìåòü ñïåö. ðàöèþ 'Discord'.",
"5.11 Ñîòðóäíèêè ñòàðøåãî ñîñòàâà îáÿçàíû îáó÷àòü è ïîìîãàòü ñîòðóäíèêàì, ìëàäøå èõ ïî äîëæíîñòè.",
"5.12 Ñîòðóäíèêè ñòàðøåãî ñîñòàâà äîëæíû ïîñåùàòü åæåíåäåëüíûå ñîáðàíèÿ, íåÿâêà êàðàåòñÿ âûãîâîðîì.",
"",
"Ãëàâà VI. Îòïóñê è íåàêòèâ.",
"",
"6.1 Îòïóñê ðàçðåøåíî áðàòü ñ äîëæíîñòè 'Èíñòðóêòîð[5]'.",
"6.2 Ñîòðóäíèê èìååò ïðàâî ïîäàòü çàÿâêó íà ïîëó÷åíèå îòïóñêà çà ïðîäåëàííûå îò÷¸òû çà íåäåëþ.",
"6.3 Îòïóñê âîçìîæíî âçÿòü ìàêñèìóì íà 7 êàëåíäàðíûõ äíåé.",
"6.4 Åñëè ñîòðóäíèê íå âåðíóëñÿ ñ îòïóñêà â íàçíà÷åííîå âðåìÿ, îí áóäåò óâîëåí, áåç ïðàâà âîññòàíîâëåíèÿ íå çàâèñèìî îò çàíèìàåìîé äîëæíîñòè.",
"6.5 Âî âðåìÿ íåàêòèâà ðàçðåøåíî íå çàõîäèòü â èãðó.",
"6.6 Íåàêòèâ ìîæíî áðàòü ìàêñèìóì íà 5 äíåé ( äëÿ çàìåñòèòåëåé 3 äíÿ ).",
"6.7 Äíè íåàêòèâà íå áóäóò áðàòüñÿ â ó÷åò â ðàññìîòðåíèè îò÷åòà.",
"6.8 Íåàêòèâ ìîæíî âçÿòü äâà ðàçà çà ñðîê Óïðàâëÿþùåãî.",
"6.9 Íåñâîåâðåìåííûé âûõîä èç íåàêòèâà áåç ïðåäóïðåæäåíèÿ ìîæåò êàðàòüñÿ âûãîâîðîì è óâîëüíåíèåì.",
"",
"Ãëàâà VII. Çàïðåòû è ïðàâà äëÿ ñîòðóäíèêîâ Àâòîøêîëû.",
"7.1 Ñîòðóäíèê íå èìååò ïðàâî íàðóøàòü óñòàâ è çàêîíîäàòåëüñòâî Øòàòà.",
"7.2 Ñîòðóäíèêàì ðàçðåøåíî íîñèòü î÷êè íà ëèöå.",
"7.3 Ñîòðóäíèêàì çàïðåùåíî âî âðåìÿ ðàá. äíÿ íîñèòü ÿðêèå è íåóìåñòíûå àêñåñóàðû ( ìàñêè, øëåìû, áàíäàíû ).",
"7.4 Çàïðåùåíî ñïàòü âíå ðàçäåâàëêè áîëåå 5-è ìèíóò. ( Èñêë.: 10 ìèíóò äëÿ Çàìà / Äèðåêòîðà )",
"7.5 Ñîòðóäíèêè íå èìåþò ïðàâî óõîäèòü íà îáåä, ïîêà íå îáñëóæàò ëþäåé, êîòîðûå ñòîÿò â î÷åðåäè.",
"7.6 Ñîòðóäíèêè íå èìåþò ïðàâî âî âðåìÿ ðàáî÷åãî äíÿ íîñèòü îäåæäó íå ïî äðåññ-êîäó.",
"7.7 Ñîòðóäíèêàì çàïðåùåíî êóðèòü, ïèòü, åñòü âî âðåìÿ ðàáî÷åãî äíÿ.",
"7.8 Çàïðåùåíî íåàäåêâàòíîå ïîâåäåíèå â çäàíèè àâòîøêîëû.",
"7.9 Ñîòðóäíèêó êàòåãîðè÷åñêè çàïðåùåíî õðàíèòü/óïîòðåáëÿòü/ïåðåíîñèòü ïñèõîòðîïíûå âåùåñòâà.",
"7.10 Ñîòðóäíèêàì çàïðåùåíî ëîâèòü äîìà â ðàáî÷åå âðåìÿ.",
"7.11 Ñîòðóäíèêó àâòîøêîëû çàïðåùåíî íàìåêàòü/âûïðàøèâàòü ïîâûøåíèå.",
"7.12 Ñîòðóäíèêàì ñòàðøåãî ñîñòàâà çàïðåùåíî ïðîâîäèòü òðåíèðîâêè è ëåêöèè ÷àùå, ÷åì ðàç â 30 ìèíóò.",
"7.13 Çàïðåùåíî ïîäêèäûâàòü äèàëîãè âûäà÷è ëèöåíçèé êëèåíòàì.",
"7.14 Íîñèòü îãíåñòðåëüíîå îðóæèå íà òåððèòîðèè àâòîøêîëû - âûãîâîð.",
"7.15 Çàïðåùåíî èìåòü ñâÿçè ñ íåëåãàëüíûìè îðãàíèçàöèÿìè - óâîëüíåíèå.",
"",
"Ïðèìå÷àíèå: Óïðàâëÿþùèé è åãî Äèðåêòîðà ìîãóò âûäàâàòü íàêàçàíèå íà ñâîå óñìîòðåíèå, îò óñòíîãî ïðåäóïðåæäåíèÿ äî ×åðíîãî Ñïèñêà Àâòîøêîëû.",
"",
"Ãëàâà VIII. Ïðî÷èå ïðàâèëà.",
"",
"8.1 Âûãîâîðû ñíèìàþòñÿ òîëüêî çà âûïîëíåíèå çàäàíèé, à òàê æå çà øòðàôíóþ âûïëàòó íà ñ÷åò îðãàíèçàöèè.",
"8.2 Õàëàòíîå îôîðìëåíèå ëèöåíçèé - íàêàçóåìî.",
"8.3 Íàæàòèå íà êíîïêó âûçîâà ïîëèöèè áåç îñîáîé ïðè÷èíû - âûãîâîð.",
"8.4 Åñëè ñîòðóäíèêà Àâòîøêîëû íåò â øòàòå áîëåå 5 äíåé, òî îí áóäåò óâîëåí áåç äàëüíåéøåãî âîññòàíîâëåíèÿ.",
"",
"Ãëàâà IX. Îáÿçàííîñòè è ïðàâà äèðåêòîðà.",
"9.1 Äèðåêòîð ÿâëÿåòñÿ îôèöèàëüíîé ïðàâîé ðóêîé Óïðàâëÿþùåãî.",
"9.2 Äèðåêòîð èìååò ïðàâî âûñòóïàòü íà ìåðîïðèÿòèÿõ îò èìåíè Óïðàâëÿþùåãî.",
"9.3 Äèðåêòîð - ãëàâíîå ðóêîâîäÿùåå ëèöî â àâòîøêîëå, ïîêà Óïðàâëÿþùåãî íå â Øòàòå.",
"9.4 Äèðåêòîð ÿâëÿåòñÿ êóðàòîðîì âñåõ îòäåëîâ, òî åñòü èìååò ïîëíîå ïðàâî ñíèìàòü ãëàâ îòäåëîâ è íàçíà÷àòü íîâûõ.",
"9.5 Äèðåêòîð èìååò ïðàâî íà âûäà÷ó âûãîâîðîâ Çàìåñòèòåëÿì Äèðåêòîðà.",
"9.6 Äèðåêòîð èìååò ïðàâî âûäâèíóòü Çàìåñòèòåëÿ Äèðåêòîðà íà ïðîöåäóðó ñíÿòèÿ ñî ñâîåé äîëæíîñòè. Îêîí÷àòåëüíîå ðåøåíèå ïðèíèìàåò Äèðåêòîð.",
"9.7 Äèðåêòîð îáÿçàí ïîä÷èíÿòüñÿ òîëüêî óêàçàì Óïðàâëÿþùåãî è Ñåíàòîðîâ Øòàòà, à òàê æå ÔÁÐ è Ãóáåðíàòîðó.",
"",
"Ãëàâà X. OOC (Out Of Character).",
"",
"10.1 Çàïðåùåíî íàðóøàòü äåéñòâóþùèå ïðàâèëà ñåðâåðà.",
"10.2 Ñîòðóäíèê àâòîøêîëû îáÿçàí ñîáëþäàòü RolePlay ðåæèì, â çàâèñèìîñòè îò ñèòóàöèè.",
"10.3 Çàïðåùåíî ñòîÿòü AFK áåç Esc íà ñåðäå÷êå îêîëî êóëåðà.",
"10.4 Çàïðåùåíà NonRP ðàáîòà ñ êëèåíòàìè.",
"10.5 Çàïðåùåí flood, offtop, MG, DM.",
"10.6 Çàïðåùåíû îñêîðáëåíèÿ â NonRP ÷àòàõ."}
			for _,line in ipairs(ustav) do
				if #search_ustav.v < 1 then
					imgui.TextWrapped(u8(line))
					imgui.Hint('Êëèêíèòå äâàæäû, ÷òî áû ñêîïèðîâàòü ñòðîêó â ÷àò', 2)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line)
					end
				else
					if string.rlower(line):find(string.rlower(u8:decode(search_ustav.v)):gsub("%[","%%[")) then
						imgui.TextWrapped(u8(line))
						imgui.Hint('Êëèêíèòå äâàæäû, ÷òî áû ñêîïèðîâàòü ñòðîêó â ÷àò', 2)
						if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
							sampSetChatInputEnabled(true)
							sampSetChatInputText(line)
						end
					end
				end
			end
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Çàêðûòü",imgui.ImVec2(200,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end
	
	function confirmdelete()
		if imgui.BeginPopupModal(u8("Ïîäòâåðæäåíèå äåéñòâèÿ"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.CenterTextColoredRGB([[Âû óâåðåíû â òîì, ÷òî õîòèòå óäàëèòü ñâîé êîíôèã?
{ff0000}Ïîñëå ïîäòâåðæäåíèÿ âñå âàøè áèíäû, íàñòðîéêè è öåíû íà ëèöåíçèè áóäóò ñáðîøåíû.]])
			imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
			imgui.BeginChild("##Confirm", imgui.ImVec2(520, 1), false)
			imgui.EndChild()
			imgui.PopStyleColor()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Ïîäòâåðäèòü",imgui.ImVec2(100,25)) then
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
					ASHelperMessage("Êîíôèã áûë óñïåøíî óäàë¸í! Ñêðèïò ïåðåçàãðóæåí.")
				end
				NoErrors = true
				thisScript():reload()
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8"Îòìåíèòü",imgui.ImVec2(100,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end

	function rules()
		if imgui.BeginPopupModal(u8("Ïðàâèëà ãîñ. ñòðóêòóð"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##ChangeLog", imgui.ImVec2(700, 330), true)
			imgui.CenterTextColoredRGB([[
{FF0000}Êàäðîâàÿ ñèñòåìà
[1 - 4 Ðàíãè] - [{00FF00}Îòñóòñòâóåò]]..textcolorinhex..[[]
[5 Ðàíã] - [{FF9900}3 Ñóòîê]]..textcolorinhex..[[]
[6 Ðàíã] - [{FF9900}4 Ñóòîê]]..textcolorinhex..[[]
[7 Ðàíã] - [{FF5500}6 Äíåé]]..textcolorinhex..[[]
[8 Ðàíã] - [{FF5500}8 Äíåé]]..textcolorinhex..[[]
[9 Ðàíã] - [{FF1100}15 Äíåé]]..textcolorinhex..[[]
{FF1100}Åñëè ÷åëîâåê íå îòñòîÿë èñïîëíèòåëüíûé ñðîê è áûë óâîëåí/óøåë ÏÑÆ - Çàíåñåíèå â ×Ñ êðàñíîé ñòåïåíè.
 
{FF0000}Íîðìà ÀÔÊ
Íîðìà ÀÔÊ äëÿ Ìèíèñòðà/Ëèäåðà/Çàìåñòèòåëÿ ñîñòàâëÿåò 10 ìèíóò [{FF5500}600 ñåêóíä]]..textcolorinhex..[[] | Íàêàçàíèå: óñòíîå/ñòðîãîå
ïðåäóïðåæäåíèå è êèê.
Íîðìà ÀÔÊ äëÿ Ñò.ñîñòàâà [5-8 ðàíã] ñîñòàâëÿåò 15 ìèíóò [{FF5500}900 ñåêóíä]]..textcolorinhex..[[] | Íàêàçàíèå: Âûãîâîð â ëè÷íîå äåëî/êèê.
Íîðìà ÀÔÊ äëÿ Ìë.ñîñòàâà [1-4 ðàíã] ñîñòàâëÿåò 30 ìèíóò [{FF5500}1800 ñåêóíä]]..textcolorinhex..[[] | Íàêàçàíèå: Óâîëüíåíèå.
 
{FF0000}Îãðàíè÷åíèå ïî ðàíãàì
9 ðàíã - 3 ÷åëîâåêà
8 ðàíã - 4 ÷åëîâåêà
 
{FF0000}Òýãè â /d ÷àò è /gov
Öåíòðàëüíûé Áàíê ã. Ëîñ-Ñàíòîñ - [Áàíê]
Ïðàâèòåëüñòâî Øòàòà - [Ïðàâèòåëüñòâî]
Ãîñóäàðñòâåííàÿ ÀâòîØêîëà ã. Ñàí-Ôèåððî - [Àâòîøêîëà]
 
Ôåäåðàëüíîå Áþðî Ðàññëåäîâàíèé - [ÔÁÐ]
Ïîëèöèÿ ã. Ëîñ-Ñàíòîñ - [Ïîëèöèÿ ËÑ]
Ïîëèöèÿ ã. Ñàí-Ôèåððî - [Ïîëèöèÿ ÑÔ]
Ïîëèöèÿ îêðóãà Ðåä Êàóíòè - [Îáëàñòíàÿ Ïîëèöèÿ]
Ïîëèöèÿ ã. Ëàñ-Âåíòóðàñ - [Ïîëèöèÿ ËÂ]
 
Àðìèÿ ã. Ëîñ-Ñàíòîñ - [Àðìèÿ ËÑ]
Àðìèÿ ã. Ñàí-Ôèåððî - [ÂÌÑ]
 
Òþðüìà Ñòðîãîãî Ðåæèìà
Òþðüìà Ñòðîãîãî Ðåæèìà ã.Las-Venturas - [Òþðüìà ËÂ]
 
Áîëüíèöà ã. Ëîñ-Ñàíòîñ - [Áîëüíèöà ËÑ]
Áîëüíèöà ã. Ñàí-Ôèåððî - [Áîëüíèöà ÑÔ]
Áîëüíèöà ã. Ëàñ-Âåíòóðàñ - [Áîëüíèöà ËÂ]
 
Ñòðàõîâàÿ êîìïàíèÿ - [ÑÊ]
]])
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8"Çàêðûòü",imgui.ImVec2(200,25)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
	end

	function ranksystem()
		if imgui.BeginPopupModal(u8("Ñèñòåìà ïîâûøåíèÿ"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##RankSystem", imgui.ImVec2(800, 600), true)
			imgui.CenterTextColoredRGB([[
{ff6633}Ñòàæ¸ð [1] - Êîíñóëüòàíò [2]
- Ñäàòü óñòàâ ñîòðóäíèêó ñòàðøåãî/ðóêîâîäÿùåãî ñîñòàâà.
- Èìåòü ñïåö. ðàöèþ "Discord".
 
{ff6633}Êîíñóëüòàíò [2] - Ëèöåíç¸ð [3]
- Ñäàòü ðå÷ü ñîòðóäíèêó ñòàðøåãî/ðóêîâîäÿùåãî ñîñòàâà. (ÐÏ îòûãðîâêà ïðè âûäà÷å ëèöåíçèé)
- Ñäàòü çíàíèå ïðàéñ ëèñòà ñîòðóäíèêó ñòàðøåãî/ðóêîâîäÿùåãî ñîñòàâà.
- Ïðîñëóøàòü îäíó ëåêöèþ (Ñêðèíøîò íà÷àëà, ñåðåäèíû è êîíöà)
 
{ff6633}Ëèöåíç¸ð [3] - Ìë. Èíñòðóêòîð [4]
- Âûïîëíèòü äâà RolePlay ïîðó÷åíèÿ. (ìèíèìóì 10 îòûãðîâîê)
- Ïðîñëóøàòü 2 ëåêöèè. (Ñêðèíøîò íà÷àëà, ñåðåäèíû è êîíöà)
- Ïðîäàòü 25 ëèöåíçèé.
 
{ff6633}Ìë. Èíñòðóêòîð [4] - Èíñòðóêòîð [5]
- Íàáðàòü 50 áàëëîâ.
- Âûïîëíèòü îäíî RolePlay çàäàíèå, ñâÿçàííîå ñ ðàáîòîé Àâòîøêîëû.
 
{ff6633}Èíñòðóêòîð [5] - Ìåíåäæåð [6]
- Íàáðàòü 60 áàëëîâ.
- Âûïîëíèòü îäíî RolePlay çàäàíèå, ñâÿçàííîå ñ ðàáîòîé Àâòîøêîëû.
 
{ff6633}Ìåíåäæåð [6] - Ñò. Ìåíåäæåð [7]
- Íàáðàòü 70 áàëëîâ
- Âûïîëíèòü äâà RolePlay çàäàíèÿ, ñâÿçàííûõ ñ ðàáîòîé Àâòîøêîëû.
 
{ff6633}Ñò. Ìåíåäæåð [7] - Ïîìîùíèê Äèðåêòîðà [8]
- Íàáðàòü 80 áàëëîâ
- Âûïîëíèòü òðè RolePlay çàäàíèÿ, ñâÿçàííûõ ñ ðàáîòîé Àâòîøêîëû.
 
Áàëëîâàÿ òàáëèöà:
Âûäà÷à ëèöåíçèé | {ff9900}2 áàëëà]]..textcolorinhex..[[ çà îäíó ëèöåíçèþ | {ff1100}Íå áîëåå 5-òè ïðîäàííûõ ëèöåíçèé çà îò÷¸ò.
Ïðîñëóøèâàíèå ëåêöèè îò Ñò. ñîñòàâà | {ff9900}4 áàëëà]]..textcolorinhex..[[ çà îäíó ëåêöèþ | {ff1100}Íå áîëåå 3-¸õ ïðîñëóøàííûõ ëåêöèé çà îò÷¸ò.
Âûïîëíåíèå ïîðó÷åíèÿ îò Ñò. ñîñòàâà | {ff9900}5 áàëëîâ]]..textcolorinhex..[[ çà îäíî ïîðó÷åíèå | {ff1100}Íå áîëåå 2-óõ âûïîëíåííûõ ïîðó÷åíèé çà îò÷¸ò.
Âûïîëíåíèå ïîðó÷åíèÿ îò Óïð. ñîñòàâà | {ff9900}10 áàëëîâ]]..textcolorinhex..[[ çà îäíî ïîðó÷åíèå | {ff1100}Íå áîëåå 1-îãî âûïîëíåííîãî ïîðó÷åíèÿ çà îò÷¸ò.
Ñâîáîäíàÿ RP ñèòóàöèÿ (ìèíèìóì 20 îòûãðîâîê) | {ff9900}10 áàëëîâ]]..textcolorinhex..[[ çà îäíó RP ñèòóàöèþ | {ff1100}Íå áîëåå 1-îé ñèòóàöèè çà îò÷¸ò.
Ó÷àñòèå â ïðîâåðêå äðóãîé îðãàíèçàöèè | {ff9900}5 áàëëîâ]]..textcolorinhex..[[ çà îäíî ó÷àñòèå â ïðîâåðêå | {ff1100}Íå áîëåå 2-óõ ïðîâåðîê çà îò÷¸ò.
Ïðèñóòñòâîâàòü íà ïðîâåðêå îò äðóãîé ôðàêöèè | {ff9900}3 áàëëà]]..textcolorinhex..[[ çà îäíî ïðèñóòñòâèå íà ïðîâåðêå | {ff1100}Íå áîëåå 3-¸õ ïðîâåðîê çà îò÷¸ò.
Ó÷àñòèå â RP ïðîöåññå îò ñò. ñîñòàâà | {ff9900}4 áàëëà]]..textcolorinhex..[[ çà îäíî ó÷àñòèå â RP ïðîöåññå | {ff1100}Íå áîëåå 2-óõ ó÷àñòèé â RP ïðîöåññå çà îò÷¸ò.
Áûòü îïðåäåë¸ííîå âðåìÿ íà ïîñòó | {ff9900}0.5 áàëëà]]..textcolorinhex..[[ çà 1 ìèíóòó ïðîñòîÿ | {ff1100}Íå áîëåå 30-òè ìèíóò çà îò÷¸ò.
Ïðîâåäåíèå ëåêöèé äëÿ ñîñòàâà | {ff9900}4 áàëëà]]..textcolorinhex..[[ çà îäíó ïðîâåä¸ííóþ ëåêöèþ | {ff1100}Íå áîëåå 3-¸õ ïðîâåä¸ííûõ ëåêöèé çà îò÷¸ò.
Ïðîâåäåíèå RP ïðîöåññà äëÿ ñîñòàâà | {ff9900}5 áàëëîâ]]..textcolorinhex..[[ çà îäèí ïðîâåä¸ííûé RP ïðîöåññ | {ff1100}Íå áîëåå 2-óõ RP ïðîöåññîâ çà îò÷¸ò.
Ïðîâåðêà óñòàâà/ïðàéñ ëèñòà/ðå÷è ó ìë. ñîñòàâà | {ff9900}3 áàëëà]]..textcolorinhex..[[ çà îäíó ïðîâåðêó | {ff1100}Íå áîëåå 5-òè ïðîâåðîê çà îò÷¸ò.
Ïðîâåäåíèå ÌÏ äëÿ ñîñòàâà | {ff9900}3 - 5 áàëëîâ]]..textcolorinhex..[[ | {ff1100}Íå áîëåå 3-¸õ ïðîâåä¸ííûõ ÌÏ çà îò÷¸ò.
Ïðèñóòñòâèå íà ÌÏ | Ïîáåäà íà ÌÏ - {ff9900}2 - 4 áàëëà]]..textcolorinhex..[[ | {ff1100}Íå áîëåå 5-òè ó÷àñòèé â ÌÏ çà îò÷¸ò.
]])
		imgui.EndChild()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
		if imgui.Button(u8"Çàêðûòü",imgui.ImVec2(200,25)) then
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
			imgui.Begin(u8"Ìåíþ áûñòðîãî äîñòóïà ["..fastmenuID.."]", imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)

			if windowtype.v == 0 then -- ÃËÀÂÍÎÅ ÌÅÍÞ  ÃËÀÂÍÎÅ ÌÅÍÞ  ÃËÀÂÍÎÅ ÌÅÍÞ  ÃËÀÂÍÎÅ ÌÅÍÞ  ÃËÀÂÍÎÅ ÌÅÍÞ  ÃËÀÂÍÎÅ ÌÅÍÞ  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Ïîïðèâåòñòâîâàòü èãðîêà', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1 then
							disableallimgui()
							lua_thread.create(function()
								getmyrank = true
								sampSendChat("/stats")
								local hour = tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60))
								if configuration.main_settings.useservername then
									local result,myid = sampGetPlayerIdByCharHandle(playerPed)
									name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
								else
									name = u8:decode(myname.v)
									if name == '' or name == nil then
										ASHelperMessage('Ââåäèòå ñâî¸ èìÿ â /'..cmdhelp..' ')
										local result,myid = sampGetPlayerIdByCharHandle(playerPed)
										name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
									end
								end
								local rang = configuration.main_settings.myrank
								inprocess = true
								if hour > 4 and hour < 13 then
									sampSendChat("Äîáðîå óòðî, ÿ {gender:ñîòðóäíèê|ñîòðóäíèöà} Àâòîøêîëû ã. Ñàí-Ôèåððî, ÷åì ìîãó âàì ïîìî÷ü?")
								elseif hour > 12 and hour < 17 then
									sampSendChat("Äîáðûé äåíü, ÿ {gender:ñîòðóäíèê|ñîòðóäíèöà} Àâòîøêîëû ã. Ñàí-Ôèåððî, ÷åì ìîãó âàì ïîìî÷ü?")
								elseif hour > 16 and hour < 24 then
									sampSendChat("Äîáðûé âå÷åð, ÿ {gender:ñîòðóäíèê|ñîòðóäíèöà} Àâòîøêîëû ã. Ñàí-Ôèåððî, ÷åì ìîãó âàì ïîìî÷ü?")
								elseif hour < 5 then
									sampSendChat("Äîáðîé íî÷è, ÿ {gender:ñîòðóäíèê|ñîòðóäíèöà} Àâòîøêîëû ã. Ñàí-Ôèåððî, ÷åì ìîãó âàì ïîìî÷ü?")
								end
								wait(cd)
								sampSendChat('/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ '..rang..' '..name..".")
								inprocess = false
							end)
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 1-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Îçâó÷èòü ïðàéñ ëèñò', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1  then
							disableallimgui()
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do Â êàðìàíå áðþê ëåæèò ïðàéñ ëèñò íà ëèöåíçèè.')
								wait(cd)
								sampSendChat('/me {gender:äîñòàë|äîñòàëà} ïðàéñ ëèñò èç êàðìàíà áðþê è ïåðåäàë åãî êëèåíòó')
								wait(cd)
								sampSendChat('/do Â ïðàéñ ëèñòå íàïèñàíî:')
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà âîæäåíèå àâòîìîáèëåé - '..separator(tostring(configuration.main_settings.avtoprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà âîæäåíèå ìîòîöèêëîâ - '..separator(tostring(configuration.main_settings.motoprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà ðûáîëîâñòâî - '..separator(tostring(configuration.main_settings.ribaprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà âîäíûé òðàíñïîðò - '..separator(tostring(configuration.main_settings.lodkaprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà îðóæèå - '..separator(tostring(configuration.main_settings.gunaprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà îõîòó - '..separator(tostring(configuration.main_settings.huntprice)..'$.'))
								wait(cd)
								sampSendChat('/do Ëèöåíçèÿ íà ðàñêîïêè - '..separator(tostring(configuration.main_settings.kladprice)..'$.'))
								inprocess = false
							end)
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 1-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Ïðîäàòü ëèöåíçèþ èãðîêó', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 3 then
						imgui.SetScrollY(0)
						ComboBox_select.v = 0
						windowtype.v = 1
					else
						ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 3-ãî ðàíãà.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_REPLY..u8' Âûãíàòü èç àâòîøêîëû', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 5 then
						imgui.SetScrollY(0)
						windowtype.v = 2
						expelbuff.v = ""
					else
						ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 5-ãî ðàíãà.")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Ïðèíÿòü â îðãàíèçàöèþ', imgui.ImVec2(285,30))
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
										sampSendChat('/do Êëþ÷è îò øêàô÷èêà â êàðìàíå.')
										wait(cd)
										sampSendChat('/me âñóíóâ ðóêó â êàðìàí áðþê, {gender:äîñòàë|äîñòàëà} îòòóäà êëþ÷ îò øêàô÷èêà')
										wait(cd)
										sampSendChat('/me {gender:ïåðåäàë|ïåðåäàëà} êëþ÷ ÷åëîâåêó íàïðîòèâ')
										wait(cd)
										sampSendChat('Äîáðî ïîæàëîâàòü! Ðàçäåâàëêà çà äâåðüþ.')
										wait(cd)
										sampSendChat('Ñî âñåé èíôîðìàöèåé Âû ìîæåòå îçíàêîìèòüñÿ íà îô. ïîðòàëå.')
										sampSendChat("/invite "..fastmenuID)
										waitingaccept = fastmenuID
									end)
								end
							else
								ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
							end
						else
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						end
					end
					
				end
				imgui.Hint("ËÊÌ äëÿ ïðèíÿòèÿ ÷åëîâåêà â îðãàíèçàöèþ\n{FFFFFF}ÏÊÌ äëÿ ïðèíÿòèÿ íà äîëæíîñòü Êîíñóëüòàíòà",0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Óâîëèòü èç îðãàíèçàöèè', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 3
							uninvitebuf.v = ""
							blacklistbuf.v = ""
							uninvitebox.v = false
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Èçìåíèòü äîëæíîñòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							Ranks_select.v = 0
							windowtype.v = 4
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Çàíåñòè â ÷¸ðíûé ñïèñîê', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype.v = 5
							blacklistbuff.v = ""
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER..u8' Óáðàòü èç ÷¸ðíîãî ñïèñêà', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unblacklist(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FROWN..u8' Âûäàòü âûãîâîð ñîòðóäíèêó', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fwarnbuff.v = ""
							windowtype.v = 6
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_SMILE..u8' Ñíÿòü âûãîâîð ñîòðóäíèêó', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							unfwarn(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Âûäàòü ìóò ñîòðóäíèêó', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fmutebuff.v = ""
							fmuteint.v = 0
							windowtype.v = 7
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Ñíÿòü ìóò ñîòðóäíèêó', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							funmute(tostring(fastmenuID))
							disableallimgui()
						else
							ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ïðîâåðêà óñòàâà '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							windowtype.v = 8
						else
							ASHelperMessage("Äàííîå äåéñòâèå äîñòóïíî ñ 5-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ñîáåñåäîâàíèå '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
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
							ASHelperMessage("Äàííîå äåéñòâèå äîñòóïíî ñ 5-ãî ðàíãà.")
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end

			elseif windowtype.v == 8 then -- ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  ÏÐÎÂÅÐÈÒÜ ÓÑÒÀÂ  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ðàáî÷åå âðåìÿ â áóäíèå äíè', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: 09:00 - 19:00")
						sampSendChat("Íàçîâèòå âðåìÿ äíåâíîé ñìåíû â áóäíèå äíè.")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ðàáî÷åå âðåìÿ â âûõîäíûå äíè', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: 10:00 - 18:00")
						sampSendChat("Íàçîâèòå âðåìÿ äíåâíîé ñìåíû â âûõîäíûå äíè.")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Êíîïêà âûçîâà ïîëèöèè áåç ïðè÷èíû', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: âûãîâîð")
						sampSendChat("Êàêîå íàêàçàíèå ïîëó÷àåò ñîòðóäíèê çà ëîæíîå íàæàòèå êíîïêè âûçîâà ïîëèöèè?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Èñïîëüçîâàíèå òðàíñïîðòà', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: (3+) Ëèöåíç¸ð - ìîòî, (4+) Ìë.Èíñòðóêòîð - àâòî, (8+) Çàì. äèðåêòîðà - âåðòîë¸ò")
						sampSendChat("Ñ êàêîé äîëæíîñòè ðàçðåøåíî áðàòü àâòîìîáèëè, ìîòîöèêëû è âåðòîë¸ò?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Äîëæíîñòü äëÿ îòïóñêà', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: (5+) Èíñòðóêòîð")
						sampSendChat("Ñêàæèòå, ñ êàêîé äîëæíîñòè ðàçðåøåíî áðàòü îòïóñê?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Âðåìÿ ñíà âíå ðàçäâåëêè', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: 5 ìèíóò ìàêñèìàëüíî, çà ýòèì ïîñëåäóåò âûãîâîð.")
						sampSendChat("Ìàêñèìàëüíî äîïóñòèìîå âðåìÿ ñíà âíå ðàçäåâàëêè?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'×òî òàêîå ñóáîðäèíàöèÿ', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: cóáîðäèíàöèÿ - ýòî ïðàâèëà îáùåíèÿ ìåæäó ñîòðóäíèêàìè, ðàçíûìè ïî äîëæíîñòè.")
						sampSendChat("×òî ïî âàøåìó ìíåíèþ îçíà÷àåò ñëîâî 'Ñóáîðäèíàöèÿ'?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Îáðàùåíèÿ ê äðóãèì ñîòðóäíèêàì', imgui.ImVec2(285,30)) then
					if not inprocess then
						ASHelperMessage("Ïîäñêàçêà: ïî äîëæíîñòè, ïî èìåíè, 'Ñýð' è 'Êîëëåãà'.")
						sampSendChat("Òàêîé âîïðîñ, êàêèå îáðàùåíèÿ äîïóñêàþòñÿ ê äðóãèì ñîòðóäíèêàì àâòîøêîëû?")
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Îäîáðèòü', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("Ïîçäðàâëÿþ, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", âû ñäàëè óñòàâ!")
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
    			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Îòêàçàòü', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat("Î÷åíü æàëü, íî âû íå ñìîãëè ñäàòü óñòàâ. Ïîäó÷èòå è ïðèõîäèòå â ñëåäóþùèé ðàç.")
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 1 then -- ÏÐÎÄÀÒÜ ËÈÖ  ÏÐÎÄÀÒÜ ËÈÖ  ÏÐÎÄÀÒÜ ËÈÖ  ÏÐÎÄÀÒÜ ËÈÖ  ÏÐÎÄÀÒÜ ËÈÖ  ÏÐÎÄÀÒÜ ËÈÖ  
				imgui.Text(u8"Ëèöåíçèÿ: ", imgui.ImVec2(75,30))
				imgui.SameLine()
				imgui.Combo(' ', ComboBox_select, ComboBox_arr, #ComboBox_arr)
				imgui.NewLine()
				if ComboBox_select.v == 0 then
					whichlic = "àâòî"
				elseif ComboBox_select.v == 1 then
					whichlic = "ìîòî"
				elseif ComboBox_select.v == 2 then
					whichlic = "ðûáîëîâñòâî"
				elseif ComboBox_select.v == 3 then
					whichlic = "ïëàâàíèå"
				elseif ComboBox_select.v == 4 then
					whichlic = "îðóæèå"
				elseif ComboBox_select.v == 5 then
					whichlic = "îõîòó"
				elseif ComboBox_select.v == 6 then
					whichlic = "ðàñêîïêè"
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ïðîäàòü ëèöåíçèþ íà '..u8(whichlic), imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID.." "..whichlic))
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ëèöåíçèÿ íà ïîë¸òû', imgui.ImVec2(285,30)) then
					if not inprocess then
						selllic(tostring(fastmenuID).." ïîë¸òû")
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 2 then -- EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  EXPEL  
				imgui.CenterTextColoredRGB("Ïðè÷èíà expel:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"     ",expelbuff)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.Button(u8'Âûãíàòü '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(250,30)) then
					if expelbuff.v == nil or expelbuff.v == "" then
						ASHelperMessage("Ââåäèòå ïðè÷èíó expel!")
					else
						expel(tostring(fastmenuID.." "..u8:decode(expelbuff.v)))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 3 then -- ÓÂÎËÈÒÜ  ÓÂÎËÈÒÜ  ÓÂÎËÈÒÜ  ÓÂÎËÈÒÜ  ÓÂÎËÈÒÜ  ÓÂÎËÈÒÜ  
				imgui.CenterTextColoredRGB("Ïðè÷èíà óâîëüíåíèÿ:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"    ", uninvitebuf)
				if uninvitebox.v then
					imgui.CenterTextColoredRGB("Ïðè÷èíà ×Ñ:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
					imgui.InputText(u8" ", blacklistbuf)
				end
				imgui.Checkbox(u8"Óâîëèòü ñ ×Ñ", uninvitebox)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Óâîëèòü '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if uninvitebuf.v == nil or uninvitebuf.v == '' then
						ASHelperMessage("Ââåäèòå ïðè÷èíó óâîëüíåíèÿ!")
					else
						if uninvitebox.v then
							if blacklistbuf.v == nil or blacklistbuf.v == '' then
								ASHelperMessage("Ââåäèòå ïðè÷èíó çàíåñåíèÿ â ×Ñ!")
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
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 4 then -- ÄÀÒÜ ÐÀÍÃ  ÄÀÒÜ ÐÀÍÃ  ÄÀÒÜ ÐÀÍÃ  ÄÀÒÜ ÐÀÍÃ  ÄÀÒÜ ÐÀÍÃ  ÄÀÒÜ ÐÀÍÃ  
				imgui.PushItemWidth(270)
				imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				if imgui.GreenButton(u8'Ïîâûñèòü ñîòðóäíèêà '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
					giverank(fastmenuID.." "..(Ranks_select.v+1))
					disableallimgui()
				end
				if imgui.Button(u8'Ïîíèçèòü ñîòðóäíèêà '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
					disableallimgui()
					lua_thread.create(function ()
						sampSendChat('/me {gender:âêëþ÷èë|âêëþ÷èëà} ÊÏÊ')
						wait(cd)
						sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè"')
						wait(cd)
						sampSendChat('/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà')
						wait(cd)
						sampSendChat('/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ')
						wait(cd)
						sampSendChat('/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.')
						sampSendChat("/giverank "..fastmenuID.." "..Ranks_select.v+1)
					end)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
		
			elseif windowtype.v == 5 then -- ÄÀÒÜ ×Ñ  ÄÀÒÜ ×Ñ  ÄÀÒÜ ×Ñ  ÄÀÒÜ ×Ñ  ÄÀÒÜ ×Ñ  ÄÀÒÜ ×Ñ  
				imgui.CenterTextColoredRGB("Ïðè÷èíà çàíåñåíèÿ â ×Ñ:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"                   ", blacklistbuff)
				imgui.NewLine()
				if imgui.Button(u8'Çàíåñòè â ×Ñ '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if blacklistbuff.v == nil or blacklistbuff.v == '' then
						ASHelperMessage("Ââåäèòå ïðè÷èíó çàíåñåíèÿ â ×Ñ!")
					else
						blacklist(fastmenuID.." "..u8:decode(blacklistbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end

			elseif windowtype.v == 6 then -- ÂÛÃÎÂÎÐ  ÂÛÃÎÂÎÐ  ÂÛÃÎÂÎÐ  ÂÛÃÎÂÎÐ  ÂÛÃÎÂÎÐ  ÂÛÃÎÂÎÐ
				imgui.CenterTextColoredRGB("Ïðè÷èíà âûãîâîðà:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"", fwarnbuff)
				imgui.NewLine()
				if imgui.Button(u8'Âûäàòü âûãîâîð '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fwarnbuff.v == nil or fwarnbuff.v == '' then
						ASHelperMessage("Ââåäèòå ïðè÷èíó âûäà÷è âûãîâîðà!")
					else
						fwarn(fastmenuID.." "..u8:decode(fwarnbuff.v))
						disableallimgui()
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end

			elseif windowtype.v == 7 then -- ÂÛÄÀÒÜ ÌÓÒ  ÂÛÄÀÒÜ ÌÓÒ  ÂÛÄÀÒÜ ÌÓÒ  ÂÛÄÀÒÜ ÌÓÒ  ÂÛÄÀÒÜ ÌÓÒ  ÂÛÄÀÒÜ ÌÓÒ  
				imgui.CenterTextColoredRGB("Ïðè÷èíà ìóòà:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
				imgui.InputText(u8"         ", fmutebuff)
				imgui.CenterTextColoredRGB("Âðåìÿ ìóòà:")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
				imgui.InputInt(u8" ", fmuteint)
				imgui.NewLine()
				if imgui.Button(u8'Âûäàòü ìóò '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if fmutebuff.v == nil or fmutebuff.v == '' then
						ASHelperMessage("Ââåäèòå ïðè÷èíó âûäà÷è ìóòà!")
					else
						if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find("-") then
							ASHelperMessage("Ââåäèòå êîððåêòíîå âðåìÿ ìóòà!")
						else
							fmute(fastmenuID.." "..u8:decode(fmuteint.v).." "..u8:decode(fmutebuff.v))
							disableallimgui()
						end
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Íàçàä', imgui.ImVec2(142.5,30)) then
					windowtype.v = 0
				end
			end
			imgui.End()

		elseif imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"Ìåíþ áûñòðîãî äîñòóïà ["..fastmenuID.."]", imgui_sobes, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			if sobesetap.v == 1 then
				imgui.CenterTextColoredRGB("Ñîáåñåäîâàíèå: Ýòàï 2")
				imgui.Separator()
				if not mcvalue then
					imgui.CenterTextColoredRGB("Ìåä.êàðòà - íå ïîêàçàíà")
				else
					imgui.CenterTextColoredRGB("Ìåä.êàðòà - ïîêàçàíà ("..mcverdict..")")
				end
				if not passvalue then
					imgui.CenterTextColoredRGB("Ïàñïîðò - íå ïîêàçàí")
				else
					imgui.CenterTextColoredRGB("Ïàñïîðò - ïîêàçàí ("..passverdict..")")
				end
				if mcvalue and mcverdict == ("â ïîðÿäêå") and passvalue and passverdict == ("â ïîðÿäêå") then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'Ïðîäîëæèòü '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
						if not inprocess then
							lua_thread.create(function()
								inprocess = true
								wait(50)
								sobesetap.v = 2
								sampSendChat("/me âçÿâ äîêóìåíòû èç ðóê ÷åëîâåêà íàïðîòèâ {gender:íà÷àë|íà÷àëà} èõ ïðîâåðÿòü")
								wait(cd)
								sampSendChat("/todo Õîðîøî...* îòäàâàÿ äîêóìåíòû îáðàòíî")
								wait(cd)
								sampSendChat("Ñåé÷àñ ÿ çàäàì âàì íåñêîëüêî âîïðîñîâ, âû ãîòîâû íà íèõ îòâå÷àòü?")
								inprocess = false
							end)
						else
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						end
					end
				end
			end

			if sobesetap.v == 7 then
				imgui.CenterTextColoredRGB("Ñîáåñåäîâàíèå: Îòêëîíåíèå")
				imgui.Separator()
				imgui.PushItemWidth(270)
				imgui.Combo(" ",sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						sobesetap.v = 0
						if sobesdecline_select.v == 0 then
							sobesdecline("ïðîô. íåïðèãîäíîñòü2")
						elseif sobesdecline_select.v == 1 then
							sobesdecline("ïðîô. íåïðèãîäíîñòü3")
						elseif sobesdecline_select.v == 2 then
							sobesdecline("ïðîô. íåïðèãîäíîñòü4")
						elseif sobesdecline_select.v == 3 then
							sobesdecline("ïðîô. íåïðèãîäíîñòü1")
						elseif sobesdecline_select.v == 4 then
							sobesdecline("ïðîô. íåïðèãîäíîñòü5")
						end
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap.v == 0 then
				imgui.CenterTextColoredRGB("Ñîáåñåäîâàíèå: Ýòàï 1")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ïîïðèâåòñòâîâàòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							if configuration.main_settings.useservername then
								local result,myid = sampGetPlayerIdByCharHandle(playerPed)
								name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
							else
								name = u8:decode(configuration.main_settings.myname)
								if name == '' or name == nil then
									ASHelperMessage('Ââåäèòå ñâî¸ èìÿ â /'..cmdhelp..' ')
									local result,myid = sampGetPlayerIdByCharHandle(playerPed)
									name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
								end
							end
							local rang = configuration.main_settings.myrank
							sampSendChat("Çäðàâñòâóéòå, âû íà ñîáåñåäîâàíèå?")
							wait(cd)
							sampSendChat('/do Íà ãðóäè âèñèò áåéäæèê ñ íàäïèñüþ '..rang..' '..name)
							inprocess = false
						end)
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ïîïðîñèòü äîêóìåíòû '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat("Õîðîøî, äëÿ ýòîãî ïîêàæèòå ìíå âàøè äîêóìåíòû, à èìåííî: ïàñïîðò è ìåä.êàðòó")
							sampSendChat("/n ÎÁßÇÀÒÅËÜÍÎ ïî ðï!")
							wait(50)
							sobesetap.v = 1
							inprocess = false
						end)
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
			end

			if sobesetap.v == 2 then
				imgui.CenterTextColoredRGB("Ñîáåñåäîâàíèå: Ýòàï 3")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ðàññêàæèòå íåìíîãî î ñåáå.', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						else
							inprocess = true
							sampSendChat("Ðàññêàæèòå íåìíîãî î ñåáå.")
							inprocess = false
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Ïî÷åìó âûáðàëè èìåííî íàñ?', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						else
							inprocess = true
							sampSendChat("Ïî÷åìó âû âûáðàëè èìåííî íàñ?")
							inprocess = false
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8"Ðàáîòàëè âû óæå â îðãàíèçàöèÿõ ÖÀ? "..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						else
							inprocess = true
							sampSendChat("Ðàáîòàëè âû óæå â îðãàíèçàöèÿõ ÖÀ? Åñëè äà, òî ðàññêàæèòå ïîäðîáíåå")
							sampSendChat("/n ÖÀ - Öåíòðàëüíûé àïïàðàò [Àâòîøêîëà, Ïðàâèòåëüñòâî, Áàíê]")
							lua_thread.create(function()
								wait(50)
								sobesetap.v = 3
							end)
							inprocess = false
						end
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
			end

			if sobesetap.v == 3 then
				imgui.CenterTextColoredRGB("Ñîáåñåäîâàíèå: Ðåøåíèå")
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Ïðèíÿòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							if configuration.main_settings.myrankint >= 9 then
								sampSendChat("Îòëè÷íî, ÿ äóìàþ âû íàì ïîäõîäèòå!")
								wait(cd)
								inprocess = false
								invite(tostring(fastmenuID))
							else
								sampSendChat("Îòëè÷íî, ÿ äóìàþ âû íàì ïîäõîäèòå!")
								wait(cd)
								sampSendChat("/r "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").." óñïåøíî ïðîø¸ë ñîáåñåäîâàíèå! Îí æä¸ò ñòàðøèõ îêîëî ñòîéêè ÷òîáû âû åãî ïðèíÿëè.")
								wait(cd)
								sampSendChat("/rb "..fastmenuID.." id")
							end
							inprocess = false
						end)
						sobesetap.v = 0
						disableallimgui()
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						lastsobesetap = sobesetap.v
						sobesetap.v = 7
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
			end
			if sobesetap.v ~= 3 and sobesetap.v ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Îòêëîíèòü', imgui.ImVec2(285,30)) then
					if not inprocess then
						if mcvalue or passvalue then
							if mcverdict == ("íàðêîçàâèñèìîñòü") then
								sobesdecline("íàðêîçàâèñèìîñòü")
								disableallimgui()
							elseif mcverdict == ("íå ïîëíîñòüþ çäîðîâûé") then
								sobesdecline("íå ïîëíîñòüþ çäîðîâûé")
								disableallimgui()
							elseif passverdict == ("ìåíüøå 3 ëåò â øòàòå") then
								sobesdecline("ìåíüøå 3 ëåò â øòàòå")
								disableallimgui()
							elseif passverdict == ("íå çàêîíîïîñëóøíûé") then
								sobesdecline("íå çàêîíîïîñëóøíûé")
								disableallimgui()
							elseif passverdict == ("èãðîê â îðãàíèçàöèè") then
								sobesdecline("èãðîê â îðãàíèçàöèè")
								disableallimgui()
							elseif passverdict == ("áûë â äåìîðãàíå") then
								sobesdecline("áûë â äåìîðãàíå")
								disableallimgui()
							elseif passverdict == ("â ÷ñ àâòîøêîëû") then
								sobesdecline("â ÷ñ àâòîøêîëû")
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
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Íàçàä', imgui.ImVec2(137,30)) then
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
				if imgui.Button(u8'Ïðîïóñòèòü ýòàï', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap.v = sobesetap.v + 1
					else
						ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
					end
				end
			end
			imgui.End()
		end

		if imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"Áèíäåð", imgui_binder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
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
					binderkeystatus = u8(configuration.BindsKeys[key])
					binderdelay.v = u8(configuration.BindsDelay[key])
				end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= configuration.binder_settings.totalslots then
				imgui.SameLine()
				imgui.BeginChild("ChildWindow2",imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8"",binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Íàçâàíèå áèíäà:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Íàçâàíèå áèíäà:').y - 135) / 2)
				imgui.Text(u8'Íàçâàíèå áèíäà:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then
					imgui.InputText("##bindername", bindername,imgui.InputTextFlags.ReadOnly)
				else
					imgui.InputText("##bindername", bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(" ",bindertype, u8"Èñïîëüçîâàòü êîìàíäó\0Èñïîëüçîâàòü êëàâèøè\0\0", 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Íàçâàíèå áèíäà:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Çàäåðæêà ìåæäó ñòðîêàìè (ms):').y - 70) / 2)
				imgui.Text(u8'Çàäåðæêà ìåæäó ñòðîêàìè (ms):'); imgui.SameLine()
				imgui.Hint('Óêàçûâàéòå çíà÷åíèå â ìèëëèñåêóíäàõ\n{FFFFFF}1 ñåêóíäà = 1.000 ìèëëèñåêóíä')
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
						binderkeystatus = u8"Íàæìèòå ÷òîáû ïîìåíÿòü"
					end
					if imgui.Button(binderkeystatus) then
						if binderkeystatus == u8"Íàæìèòå ÷òîáû ïîìåíÿòü" then
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"Íàæìèòå ëþáóþ êëàâèøó"
							setbinderkey = true
						elseif binderkeystatus == u8"Íàæìèòå ëþáóþ êëàâèøó" then
							setbinderkey = false
							binderkeystatus = u8"Íàæìèòå ÷òîáû ïîìåíÿòü"
						elseif string.find(binderkeystatus, u8"Ïðèìåíèòü") then
							setbinderkey = false
							binderkeystatus = string.match(binderkeystatus,u8"Ïðèìåíèòü (.+)")
						else
							table.remove(emptykey1)
							table.remove(emptykey2)
							binderkeystatus = u8"Íàæìèòå ëþáóþ êëàâèøó"
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
					if imgui.Button(u8"Ñîõðàíèòü",imgui.ImVec2(100,30)) then
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
												ASHelperMessage("Áèíä óñïåøíî ñîõðàí¸í!")
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
												ASHelperMessage("Áèíä óñïåøíî ñîçäàí!")
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
										ASHelperMessage("Âû íåïðàâèëüíî óêàçàëè êîìàíäó áèíäà!")
									end
								elseif bindertype.v == 1 then
									if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= "Íàæìèòå ÷òîáû ïîìåíÿòü" and not string.find((u8:decode(binderkeystatus)), "Ïðèìåíèòü ") and (u8:decode(binderkeystatus)) ~= "Íàæìèòå ëþáóþ êëàâèøó" then
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
												ASHelperMessage("Áèíä óñïåøíî ñîõðàí¸í!")
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
												ASHelperMessage("Áèíä óñïåøíî ñîçäàí!")
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
										ASHelperMessage("Âû íåïðàâèëüíî óêàçàëè êëàâèøó áèíäà!")
									end
								end
							updatechatcommands()
						else
							ASHelperMessage("Âû íå ìîæåòå âçàèìîäåéñòâîâàòü ñ áèíäåðîì âî âðåìÿ ëþáîé îòûãðîâêè!")
						end	
					end
				else
					imgui.LockedButton(u8"Ñîõðàíèòü",imgui.ImVec2(100,30))
					imgui.Hint("Âû ââåëè íå âñå ïàðàìåòðû. Ïåðåïðîâåðüòå âñ¸.")
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8"Îòìåíèòü",imgui.ImVec2(100,30)) then
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
				imgui.Text(u8"Îòêðîéòå áèíä èëè ñîçäàéòå íîâûé äëÿ ìåíþ ðåäàêòèðîâàíèÿ.")
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
			if imgui.Button(u8"Äîáàâèòü",imgui.ImVec2(82,30)) then
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
				if imgui.Button(u8"Óäàëèòü",imgui.ImVec2(82,30)) then
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
									ASHelperMessage("Áèíä óñïåøíî óäàë¸í!")
								end
							end
						end
					updatechatcommands()
					else
						ASHelperMessage("Âû íå ìîæåòå óäàëÿòü áèíä âî âðåìÿ ëþáîé îòûãðîâêè!")
					end
				end
			else
				imgui.LockedButton(u8"Óäàëèòü",imgui.ImVec2(82,30))
				imgui.Hint("Âûáåðèòå áèíä êîòîðûé õîòèòå óäàëèòü",0)
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
			if imgui.Button(fa.ICON_FA_USER_COG..u8' Íàñòðîéêè ïîëüçîâàòåëÿ', imgui.ImVec2(220,30)) then
				settingswindow.v = 1
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Öåíîâàÿ ïîëèòèêà', imgui.ImVec2(220,30)) then
				settingswindow.v = 2
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_KEYBOARD..u8' Ãîðÿ÷èå êëàâèøè', imgui.ImVec2(220,30)) then
				settingswindow.v = 3
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_PALETTE..u8' Íàñòðîéêè öâåòîâ', imgui.ImVec2(220,30)) then
				settingswindow.v = 6
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_BOOK_OPEN..u8' Ïðàâèëà àâòîøêîëû', imgui.ImVec2(220,30)) then
				settingswindow.v = 4
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
			if imgui.Button(fa.ICON_FA_INFO_CIRCLE..u8' Èíôîðìàöèÿ î ñêðèïòå', imgui.ImVec2(220,30)) then
				settingswindow.v = 5
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##Settings",imgui.ImVec2(325,240),true,imgui.WindowFlags.NoScrollbar,imgui.WindowFlags.AlwaysAutoResize)
			if settingswindow.v == 1 then
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Èñïîëüçîâàòü ìîé íèê èç òàáà",useservername) then
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
				if imgui.Checkbox(u8"Èñïîëüçîâàòü àêöåíò",useaccent) then
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
				if imgui.Checkbox(u8"Ñîçäàâàòü ìàðêåð ïðè âûäåëåíèè",createmarker) then
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
				if imgui.Checkbox(u8"Íà÷èíàòü îòûãðîâêè ïîñëå êîìàíä", dorponcmd) then
					configuration.main_settings.dorponcmd = dorponcmd.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Çàìåíÿòü ñåðâåðíûå ñîîáùåíèÿ", replacechat) then
					configuration.main_settings.replacechat = replacechat.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8"Áûñòðûé ñêðèí íà "..configuration.main_settings.fastscreen, dofastscreen) then
					configuration.main_settings.dofastscreen = dofastscreen.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Button(u8'Îáíîâèòü', imgui.ImVec2(85,25)) then
					getmyrank = true
					sampSendChat("/stats")
				end
				imgui.SameLine()
				imgui.Text(u8"Âàø ðàíã: "..u8(configuration.main_settings.myrank).." ("..u8(configuration.main_settings.myrankint)..")")
				imgui.PushItemWidth(85)
				imgui.SetCursorPosX(10)
				if imgui.Combo(u8"",gender, gender_arr, #gender_arr) then
					configuration.main_settings.gender = gender.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.Text(u8"Ïîë âûáðàí")
				imgui.SameLine()
				imgui.SetCursorPosX(107.5)
				imgui.Text("__________")
				imgui.Hint("ËÊÌ äëÿ àâòîìàòè÷åñêîãî îïðåäåëåíèÿ.")
				if imgui.IsItemClicked() then
					autoGetSelfGender()
				end

			elseif settingswindow.v == 2 then
				imgui.CenterTextColoredRGB("Öåíîâàÿ ïîëèòèêà")
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Àâòî", avtoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.avtoprice = avtoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 29) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Ìîòî", motoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.motoprice = motoprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Ðûáàëêà", ribaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.ribaprice = ribaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Ïëàâàíèå", lodkaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.lodkaprice = lodkaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Îðóæèå", gunaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.gunaprice = gunaprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Îõîòà", huntprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.huntprice = huntprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8"Ðàñêîïêè", kladprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.kladprice = kladprice.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
			elseif settingswindow.v == 3 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Èçìåíèòü êíîïêó áûñòðîãî ìåíþ', imgui.ImVec2(230,40)) then
					getbindkey = true
					configuration.main_settings.usefastmenu = ""
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if getbindkey then
					imgui.Hint("Íàæìèòå ëþáóþ êëàâèøó")
				else
					imgui.Hint("ÏÊÌ + "..configuration.main_settings.usefastmenu)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Èçìåíèòü êíîïêó áûñòðîãî ñêðèíà', imgui.ImVec2(230,40)) then
					getscreenkey = true
					configuration.main_settings.fastscreen = ""
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				if getscreenkey then
					imgui.Hint("Íàæìèòå ëþáóþ êëàâèøó")
				else
					imgui.Hint(configuration.main_settings.fastscreen)
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				if imgui.Button(u8'Îòêðûòü áèíäåð', imgui.ImVec2(230,40)) then
					binder()
				end
				imgui.SameLine()
			elseif settingswindow.v == 4 then
				if imgui.Button(u8'Óñòàâ àâòîøêîëû', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Óñòàâ àâòîøêîëû"))
				end
				ustav()
				if imgui.Button(u8'Ïðàâèëà ãîñ. ñòðóêòóð', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Ïðàâèëà ãîñ. ñòðóêòóð"))
				end
				rules()
				if imgui.Button(u8'Ñèñòåìà ïîâûøåíèÿ', imgui.ImVec2(-1,35)) then
					imgui.OpenPopup(u8("Ñèñòåìà ïîâûøåíèÿ"))
				end
				ranksystem()
				imgui.CenterTextColoredRGB[[
{FF1100}Âàæíî!{FFFFFF}
Äàííûå ïðàâèëà áûëè âçÿòû ñ ôîðóìà Glendale.
Íà âàøåì ñåðâåðå îíè ìîãóò îòëè÷àòüñÿ.]]
			elseif settingswindow.v == 5 then
				imgui.CenterTextColoredRGB('Àâòîð: {ff6633}JustMini')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Change Log '..(fa.ICON_FA_TERMINAL), imgui.ImVec2(137,30)) then
					imgui.OpenPopup(u8("Ñïèñîê èçìåíåíèé"))
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
				if imgui.Button(u8'Óäàëèòü êîíôèã '..(fa.ICON_FA_TRASH), imgui.ImVec2(120,25)) then
					imgui.OpenPopup(u8('Ïîäòâåðæäåíèå äåéñòâèÿ'))
				end
				confirmdelete()
			elseif settingswindow.v == 0 then
				imgui.PushFont(fontsize16)
				imgui.CenterTextColoredRGB('×òî ÿ óìåþ?')
				imgui.PopFont()
				imgui.TextWrapped(u8([[
 Ìåíþ áûñòðîãî äîñòóïà: Ïðèöåëèâøèñü íà èãðîêà ñ ïîìîùüþ ÏÊÌ è íàæàâ êíîïêó E (ïî óìîë÷àíèþ), îòêðîåòñÿ ìåíþ áûñòðîãî äîñòóïà. Â äàííîì ìåíþ åñòü âñå íóæíûå ôóíêöèè, à èìåííî: ïðèâåòñòâèå, îçâó÷èâàíèå ïðàéñ ëèñòà, ïðîäàæà ëèöåíçèé, âîçìîæíîñòü âûãíàòü ÷åëîâåêà èç àâòîøêîëû, ïðèãëàøåíèå â îðãàíèçàöèþ, óâîëüíåíèå èç îðãàíèçàöèè, èçìåíåíèå äîëæíîñòè, çàíåñåíèå â ×Ñ, óäàëåíèå èç ×Ñ, âûäà÷à âûãîâîðîâ, óäàëåíèå âûãîâîðîâ, âûäà÷à îðãàíèçàöèîííîãî ìóòà, óäàëåíèå îðãàíèçàöèîííîãî ìóòà, àâòîìàòèçèðîâàííîå ïðîâåäåíèå ñîáåñåäîâàíèÿ ñî âñåìè íóæíûìè îòûãðîâêàìè.

 Êîìàíäû ñåðâåðà ñ îòûãðîâêàìè: /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. Ââåäÿ ëþáóþ èç ýòèõ êîìàíä íà÷í¸òñÿ ÐÏ îòûãðîâêà, ëèøü ïîñëå íå¸ áóäåò àêòèâèðîâàíà ñàìà êîìàíäà.

 Êîìàíäû: /ash - íàñòðîéêè õåëïåðà, /ashbind - áèíäåð õåëïåðà, /ashupd - îáíîâëåíèå äîëæíîñòè â õåëïåðå, /ashstats - ñòàòèñòèêà ïðîäàííûõ ëèöåíçèé.

 Íàñòðîéêè: Ââåäÿ êîìàíäó /ash îòêðîþòñÿ íàñòðîéêè â êîòîðûõ ìîæíî èçìåíÿòü íèêíåéì â ïðèâåòñòâèè, àêöåíò, ñîçäàíèå ìàðêåðà ïðè âûäåëåíèè, ïîë, öåíû íà ëèöåíçèè, ãîðÿ÷óþ êëàâèøó áûñòðîãî ìåíþ è óçíàòü èíôîðìàöèþ î ñêðèïòå.

 Áèíäåð: Ââåäÿ êîìàíäó /ashbind îòêðîåòñÿ ïîëíîñòüþ ðàáîòîñïîñîáíûé áèíäåð, â êîòîðîì âû ìîæåòå ñîçäàòü àáñîëþòíî ëþáîé áèíä.]]
	))
			elseif settingswindow.v == 6 then
				imgui.PushItemWidth(200)
				if imgui.Combo(u8'Âûáîð òåìû', StyleBox_select, StyleBox_arr, #StyleBox_arr) then
					configuration.main_settings.style = StyleBox_select.v
					if inicfg.save(configuration,"AS Helper") then
						checkstyle()
					end
				end
				imgui.PopItemWidth()
				if imgui.ColorEdit4(u8'Öâåò ÷àòà îðãàíèçàöèè /r##RSet', RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(RChatColor.v[1], RChatColor.v[2], RChatColor.v[3], RChatColor.v[4]):GetU32()
		            configuration.main_settings.RChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Ñáðîñèòü##RCol",imgui.ImVec2(90,25)) then
					configuration.main_settings.RChatColor = 4282626093
		            if inicfg.save(configuration, 'AS Helper.ini') then
						RChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
					end
				end
				if imgui.ColorEdit4(u8'Öâåò ÷àòà äåïàðòàìåíòà /d##DSet', DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(DChatColor.v[1], DChatColor.v[2], DChatColor.v[3], DChatColor.v[4]):GetU32()
		            configuration.main_settings.DChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Ñáðîñèòü##DCol",imgui.ImVec2(90,25)) then
					configuration.main_settings.DChatColor = 4294940723
		            if inicfg.save(configuration, 'AS Helper.ini') then
						DChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
					end
				end
				if imgui.ColorEdit4(u8'Öâåò AS Helper â ÷àòå##SSet', ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
		            local clr = imgui.ImColor.FromFloat4(ASChatColor.v[1], ASChatColor.v[2], ASChatColor.v[3], ASChatColor.v[4]):GetU32()
					configuration.main_settings.ASChatColor = clr
		            inicfg.save(configuration, 'AS Helper.ini')
		        end
				imgui.SameLine(imgui.GetWindowWidth() - 110)
				if imgui.Button(u8"Ñáðîñèòü##SCol",imgui.ImVec2(90,25)) then
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
			imgui.Begin(u8"Âàøà ñòàòèñòèêà", imgui_stats, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.Text(u8"Àâòî - "..configuration.my_stats.avto)
			imgui.Text(u8"Ìîòî - "..configuration.my_stats.moto)
			imgui.Text(u8"Ðûáîëîâñòâî - "..configuration.my_stats.riba)
			imgui.Text(u8"Ïëàâàíèå - "..configuration.my_stats.lodka)
			imgui.Text(u8"Îðóæèå - "..configuration.my_stats.guns)
			imgui.Text(u8"Îõîòà - "..configuration.my_stats.hunt)
			imgui.Text(u8"Ðàñêîïêè - "..configuration.my_stats.klad)
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
			ASHelperMessage('Ñîçäàí ôàéë êîíôèãóðàöèè.')
		end
    end
	getmyrank = true
	sampSendChat("/stats")
	ASHelperMessage('AS Helper óñïåøíî çàãðóæåí. Àâòîð: JustMini')
	ASHelperMessage("Ââåäèòå /"..cmdhelp.." ÷òîáû îòêðûòü íàñòðîéêè.")
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
								ASHelperMessage("Âû èñïîëüçîâàëè ìåíþ áûñòðîãî äîñòóïà íà: "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").."["..fastmenuID.."]")
								ASHelperMessage("Çàæìèòå {"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)).."}ALT{FFFFFF} äëÿ òîãî, ÷òîáû ñêðûòü êóðñîð. {"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)).."}ESC{FFFFFF} äëÿ òîãî, ÷òîáû çàêðûòü ìåíþ.")
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
					if tostring(configuration.BindsKeys[key]):match("(.+) %p (.+)") then
						local fkey = tostring(configuration.BindsKeys[key]):match("(.+) %p")
						local skey = tostring(configuration.BindsKeys[key]):match("%p (.+)")
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
									ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
								end
							else
								ASHelperMessage("Çàêðîéòå âñå îêíà äëÿ àêòèâàöèè áèíäà.")
							end
						end
					elseif tostring(configuration.BindsKeys[key]):match("(.+)") then
						local fkey = tostring(configuration.BindsKeys[key]):match("(.+)")
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
									ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
								end
							else
								ASHelperMessage("Çàêðîéòå âñå îêíà äëÿ àêòèâàöèè áèíäà.")
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

function pricelist()
	
end

function selllic(param)
	lua_thread.create(function()
		sellto, lictype = param:match('(.+) (.+)')
		local sellto = tonumber(sellto)
		local result, myid = sampGetPlayerIdByCharHandle(playerPed)
		if lictype ~= nil and sellto ~= nil then
			if inprocess ~= true then
				inprocess = true
					if lictype == 'ïîëåòû' or lictype == 'ïîë¸òû' then
						sampSendChat('Ïîëó÷èòü ëèöåíçèþ íà '..lictype..' âû ìîæåòå â àâèàøêîëå ã. Ëàñ-Âåíòóðàñ')
						sampSendChat('/n /gps -> Âàæíûå ìåñòà -> Ñëåäóþùàÿ ñòðàíèöà -> [LV] Àâèàøêîëà (9)')
					elseif lictype == 'îðóæèå' then
						if not cansell then
							result, myid = sampGetPlayerIdByCharHandle(playerPed)
							if sampIsPlayerConnected(sellto) or sellto == myid then
								sampSendChat('Õîðîøî, äëÿ ïîêóïêè ëèöåíçèè íà îðóæèå ïîêàæèòå ìíå ñâîþ ìåä.êàðòó')
								sampSendChat('/n /showmc '..myid)
								ASHelperMessage('Íà÷àëîñü îæèäàíèå ïîêàçà ìåä.êàðòû.')
								skiporcancel = false
								choosedname = sampGetPlayerNickname(fastmenuID)
								tempid = fastmenuID
							else
								ASHelperMessage('Òàêîãî èãðîêà íåò íà ñåðâåðå')
							end
						else
							inprocess = true
							sampSendChat('/me {gender:âçÿë|âçÿëà} ñî ñòîëà áëàíê è {gender:çàïîëíèë|çàïîëíèëà} ðó÷êîé áëàíê íà ïîëó÷åíèå ëèöåíçèè íà '..lictype)
							wait(cd)
							sampSendChat('/do Ñïóñòÿ íåêîòîðîå âðåìÿ áëàíê íà ïîëó÷åíèå ëèöåíçèè áûë çàïîëíåí.')
							wait(cd)
							sampSendChat('/me ðàñïå÷àòàâ ëèöåíçèþ íà '..lictype.." {gender:ïåðåäàë|ïåðåäàëà} å¸ ÷åëîâåêó íàïðîòèâ")
							givelic = true
							cansell = false
							wait(100)
							sampSendChat('/givelicense '..sellto)
						end
					else
						sampSendChat('/me {gender:âçÿë|âçÿëà} ñî ñòîëà áëàíê è {gender:çàïîëíèë|çàïîëíèëà} ðó÷êîé áëàíê íà ïîëó÷åíèå ëèöåíçèè íà '..lictype)
						wait(cd)
						sampSendChat('/do Ñïóñòÿ íåêîòîðîå âðåìÿ áëàíê íà ïîëó÷åíèå ëèöåíçèè áûë çàïîëíåí.')
						wait(cd)
						sampSendChat('/me ðàñïå÷àòàâ ëèöåíçèþ íà '..lictype.." {gender:ïåðåäàë|ïåðåäàëà} å¸ ÷åëîâåêó íàïðîòèâ")
						givelic = true
						wait(100)
						sampSendChat('/givelicense '..sellto)
					end
				inprocess = false
			else
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
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
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				if id == nil then
					ASHelperMessage('/invite [id]')
				else
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('Âû íå ìîæåòå ïðèãëàøàòü â îðãàíèçàöèþ ñàìîãî ñåáÿ.')
					else
						inprocess = true
						sampSendChat('/do Êëþ÷è îò øêàô÷èêà â êàðìàíå.')
						wait(cd)
						sampSendChat('/me âñóíóâ ðóêó â êàðìàí áðþê, {gender:äîñòàë|äîñòàëà} îòòóäà êëþ÷ îò øêàô÷èêà')
						wait(cd)
						sampSendChat('/me {gender:ïåðåäàë|ïåðåäàëà} êëþ÷ ÷åëîâåêó íàïðîòèâ')
						wait(cd)
						sampSendChat('Äîáðî ïîæàëîâàòü! Ðàçäåâàëêà çà äâåðüþ.')
						wait(cd)
						sampSendChat('Ñî âñåé èíôîðìàöèåé Âû ìîæåòå îçíàêîìèòüñÿ íà îô. ïîðòàëå.')
						sampSendChat("/invite "..id)
						inprocess = false
					end
				end
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
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
			sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
			wait(cd)
			sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óâîëüíåíèå"')
			wait(cd)
			sampSendChat('/do Ðàçäåë îòêðûò.')
			wait(cd)
			sampSendChat('/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë "Óâîëüíåíèå"')
			wait(cd)
			sampSendChat('/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ, çàòåì {gender:âûêëþ÷èë|âûêëþ÷èëà} ÊÏÊ è {gender:ïîëîæèë|ïîëîæèëà} åãî îáðàòíî â êàðìàí')
			wait(cd)
			sampSendChat("/uninvite "..id..' '..u8:decode(uninvitebuf.v))
		elseif withbl == 1 then
			sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
			wait(cd)
			sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óâîëüíåíèå"')
			wait(cd)
			sampSendChat('/do Ðàçäåë îòêðûò.')
			wait(cd)
			sampSendChat('/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë "Óâîëüíåíèå"')
			wait(cd)
			sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "×¸ðíûé ñïèñîê"')
			wait(cd)
			sampSendChat('/me {gender:çàí¸ñ|çàíåñëà} ñîòðóäíèêà â ðàçäåë, ïîñëå ÷åãî {gender:ïîäòâåðäèë|ïîäòâåðäèëà} èçìåíåíèÿ')
			wait(cd)
			sampSendChat('/do Èçìåíåíèÿ áûëè ñîõðàíåíû.')
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
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if uvalid == nil or uvalid == '' or reason == nil or reason == '' then
					ASHelperMessage('/uninvite [id] [ïðè÷èíà]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if uvalid == myid then
						ASHelperMessage('Âû íå ìîæåòå óâîëüíÿòü èç îðãàíèçàöèè ñàìîãî ñåáÿ.')
					else
						sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
						wait(cd)
						sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óâîëüíåíèå"')
						wait(cd)
						sampSendChat('/do Ðàçäåë îòêðûò.')
						wait(cd)
						sampSendChat('/me {gender:âí¸ñ|âíåñëà} ÷åëîâåêà â ðàçäåë "Óâîëüíåíèå"')
						wait(cd)
						sampSendChat('/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ, çàòåì {gender:âûêëþ÷èë|âûêëþ÷èëà} ÊÏÊ è {gender:ïîëîæèë|ïîëîæèëà} åãî îáðàòíî â êàðìàí')
						sampSendChat("/uninvite "..uvalid..' '..reason)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
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
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if id == nil or id == '' or rank == nil or rank == '' then
					ASHelperMessage('/giverank [id] [ðàíã]')
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						ASHelperMessage('Âû íå ìîæåòå ìåíÿòü ðàíã ñàìîìó ñåáå.')
					else
						sampSendChat('/me {gender:âêëþ÷èë|âêëþ÷èëà} ÊÏÊ')
						wait(cd)
						sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè"')
						wait(cd)
						sampSendChat('/me {gender:âûáðàë|âûáðàëà} â ðàçäåëå íóæíîãî ñîòðóäíèêà')
						wait(cd)
						sampSendChat('/me {gender:èçìåíèë|èçìåíèëà} èíôîðìàöèþ î äîëæíîñòè ñîòðóäíèêà, ïîñëå ÷åãî {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ')
						wait(cd)
						sampSendChat('/do Èíôîðìàöèÿ î ñîòðóäíèêå áûëà èçìåíåíà.')
						wait(cd)
						sampSendChat('Ïîçäðàâëÿþ ñ ïîâûøåíèåì. Íîâûé áåéäæèê Âû ìîæåòå âçÿòü â ðàçäåâàëêå.')
						sampSendChat("/giverank "..id.." "..rank)
					end
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function blacklist(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/blacklist [id] [ïðè÷èíà]')
				else
					sampSendChat("/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà")
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "×¸ðíûé ñïèñîê"')
					wait(cd)
					sampSendChat("/me {gender:ââ¸ë|ââåëà} èìÿ íàðóøèòåëÿ")
					wait(cd)
					sampSendChat('/me {gender:âí¸ñ|âíåñëà} íàðóøèòåëÿ â ðàçäåë "×¸ðíûé ñïèñîê"')
					wait(cd)
					sampSendChat("/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ")
					wait(cd)
					sampSendChat("/do Èçìåíåíèÿ áûëè ñîõðàíåíû.")
					sampSendChat("/blacklist "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function unblacklist(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
			inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unblacklist [id]')
				else
					sampSendChat("/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà")
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "×¸ðíûé ñïèñîê"')
					wait(cd)
					sampSendChat("/me {gender:ââ¸ë|ââåëà} èìÿ ãðàæäàíèíà â ïîèñê")
					wait(cd)
					sampSendChat('/me {gender:óáðàë|óáðàëà} ãðàæäàíèíà èç ðàçäåëà "×¸ðíûé ñïèñîê"')
					wait(cd)
					sampSendChat("/me {gender:ïîäòâåäðäèë|ïîäòâåðäèëà} èçìåíåíèÿ")
					wait(cd)
					sampSendChat("/do Èçìåíåíèÿ áûëè ñîõðàíåíû.")
					sampSendChat("/unblacklist "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function fwarn(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fwarn [id] [ïðè÷èíà]')
				else
					sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè"')
					wait(cd)
					sampSendChat('/me {gender:çàø¸ë|çàøëà} â ðàçäåë "Âûãîâîðû"')
					wait(cd)
					sampSendChat('/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:äîáàâèë|äîáàâèëà} â åãî ëè÷íîå äåëî âûãîâîð')
					wait(cd)
					sampSendChat('/do Âûãîâîð áûë äîáàâëåí â ëè÷íîå äåëî ñîòðóäíèêà.')
					wait(cd)
					sampSendChat("/fwarn "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function unfwarn(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/unfwarn [id]')
				else
					sampSendChat("/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà")
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè"')
					wait(cd)
					sampSendChat('/me {gender:çàø¸ë|çàøëà} â ðàçäåë "Âûãîâîðû"')
					wait(cd)
					sampSendChat("/me íàéäÿ â ðàçäåëå íóæíîãî ñîòðóäíèêà, {gender:óáðàë|óáðàëà} èç åãî ëè÷íîãî äåëà îäèí âûãîâîð")
					wait(cd)
					sampSendChat('/do Âûãîâîð áûë óáðàí èç ëè÷íîãî äåëà ñîòðóäíèêà.')
					sampSendChat("/unfwarn "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
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
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/fmute [id] [âðåìÿ] [ïðè÷èíà]')
				else
					sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
					wait(cd)
					sampSendChat('/me {gender:âêëþ÷èë|âêëþ÷èëà} ÊÏÊ')
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè Àâòîøêîëû"')
					wait(cd)
					sampSendChat('/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà')
					wait(cd)
					sampSendChat('/me {gender:âûáðàë|âûáðàëà} ïóíêò "Îòêëþ÷èòü ðàöèþ ñîòðóäíèêà"')
					wait(cd)
					sampSendChat('/me {gender:íàæàë|íàæàëà} íà êíîïêó "Ñîõðàíèòü èçìåíåíèÿ"')
					sampSendChat("/fmute "..id.." "..mutetime.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function funmute(param)
	local id = param:match("(%d+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if id == nil or id == '' then
					ASHelperMessage('/funmute [id]')
				else
					sampSendChat('/me {gender:äîñòàë|äîñòàëà} ÊÏÊ èç êàðìàíà')
					wait(cd)
					sampSendChat('/me {gender:âêëþ÷èë|âêëþ÷èëà} ÊÏÊ')
					wait(cd)
					sampSendChat('/me {gender:ïåðåø¸ë|ïåðåøëà} â ðàçäåë "Óïðàâëåíèå ñîòðóäíèêàìè Àâòîøêîëû"')
					wait(cd)
					sampSendChat('/me {gender:âûáðàë|âûáðàëà} íóæíîãî ñîòðóäíèêà')
					wait(cd)
					sampSendChat('/me {gender:âûáðàë|âûáðàëà} ïóíêò "Âêëþ÷èòü ðàöèþ ñîòðóäíèêà"')
					wait(cd)
					sampSendChat('/me {gender:íàæàë|íàæàëà} íà êíîïêó "Ñîõðàíèòü èçìåíåíèÿ"')
					sampSendChat("/funmute "..id)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 9-ãî ðàíãà.")
		end
	end)
end

function expel(param)
	local id,reason = param:match("(%d+) (.+)")
	local id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 5 then
			if inprocess then
				ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					ASHelperMessage('/expel [id] [ïðè÷èíà]')
				else
					sampSendChat('/do Ðàöèÿ ñâèñàåò íà ïîÿñå.')
					wait(cd)
					sampSendChat('/me ñíÿâ ðàöèþ ñ ïîÿñà, {gender:âûçâàë|âûçâàëà} îõðàíó ïî íåé')
					wait(cd)
					sampSendChat('/do Îõðàíà âûâîäèò íàðóøèòåëÿ èç õîëëà.')
					sampSendChat("/expel "..id.." "..reason)
				end
			inprocess = false
			end
		else
			ASHelperMessage("Äàííàÿ êîìàíäà äîñòóïíà ñ 5-ãî ðàíãà.")
		end
	end)
end

function sobesdecline(param)
	local reason = param:match("(.+)")
	lua_thread.create(function()
		if inprocess then
			ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
		else
			inprocess = true
			if reason ~= "ïðîô. íåïðèãîäíîñòü1" and reason ~= "ïðîô. íåïðèãîäíîñòü3" and reason ~= "ïðîô. íåïðèãîäíîñòü5" then
				sampSendChat("/me âçÿâ äîêóìåíòû èç ðóê ÷åëîâåêà íàïðîòèâ {gender:íà÷àë|íà÷àëà} èõ ïðîâåðÿòü")
				wait(cd)
				sampSendChat("/todo Î÷åíü ãðóñòíî...* îòäàâàÿ äîêóìåíòû îáðàòíî")
				wait(cd)
			end
			if reason == ("íàðêîçàâèñèìîñòü") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû ñëèøêîì íàðêîçàâèñèìûé.")
			elseif reason == ("íå ïîëíîñòüþ çäîðîâûé") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íå ïîëíîñòüþ çäîðîâûé.")
			elseif reason == ("íå çàêîíîïîñëóøíûé") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íåäîñòàòî÷íî çàêîíîïîñëóøíûé.")
			elseif reason == ("ìåíüøå 3 ëåò â øòàòå") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íå ïðîæèâàåòå â øòàòå 3 ãîäà.")
			elseif reason == ("èãðîê â îðãàíèçàöèè") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû óæå ðàáîòàåòå â äðóãîé îðãàíèçàöèè.")
			elseif reason == ("áûë â äåìîðãàíå") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû ëå÷èëèñü â ïñèõ. áîëüíèöå.")
				sampSendChat("/n Ïîìåíÿé ìåä. êàðòó")
			elseif reason == ("â ÷ñ àâòîøêîëû") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðîäîëæèòü ñîáåñåäîâàíèå. Âû íàõîäèòåñü â ×Ñ ÀØ.")
			elseif reason == ("ïðîô. íåïðèãîäíîñòü1") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü âàñ èç-çà òîãî, ÷òî âû ïðîô. íåïðèãîäíû.")
				sampSendChat("/b Íè÷åãî íå ïîêàçàë")
			elseif reason == ("ïðîô. íåïðèãîäíîñòü2") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü âàñ èç-çà òîãî, ÷òî âû ïðîô. íåïðèãîäíû.")
				sampSendChat("/b Óæàñíîå ÐÏ")
			elseif reason == ("ïðîô. íåïðèãîäíîñòü3") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü âàñ èç-çà òîãî, ÷òî âû ïðîô. íåïðèãîäíû.")
				sampSendChat("/b Íå áûëî ÐÏ")
			elseif reason == ("ïðîô. íåïðèãîäíîñòü4") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü âàñ èç-çà òîãî, ÷òî âû ïðîô. íåïðèãîäíû.")
				sampSendChat("/b Ïëîõàÿ ãðàììàòèêà")
			elseif reason == ("ïðîô. íåïðèãîäíîñòü5") then
				sampSendChat("Ê ñîæàëåíèþ ÿ íå ìîãó ïðèíÿòü âàñ èç-çà òîãî, ÷òî âû ïðîô. íåïðèãîäíû.")
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
							ASHelperMessage("Íå òîðîïèòåñü, âû óæå îòûãðûâàåòå ÷òî-òî!")
						end
					end)
				end)
			end
		end
	end
end

if sampevcheck then
	--Îòäåëüíîå ñïàñèáî Bank Helper îò Cosmo. Îòòóäà âçÿë íåñêîëüêî èíòåðåñíûõ èäåé.
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 235 and getmyrank then
			if text:find('Èíñòðóêòîðû') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('Äîëæíîñòü: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						rangint = tonumber(getStatsRank)
						rang = nameRankStats
						configuration.main_settings.myrank = rang
						configuration.main_settings.myrankint = rangint
						if nameRankStats:find('Óïðàëÿþùèé') or devmaxrankp then
							getStatsRank = 10
							configuration.main_settings.myrank = "Óïðàëÿþùèé"
							configuration.main_settings.myrankint = 10
						end
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
			else
				ASHelperMessage('Âû íå ðàáîòàåòå â àâòîøêîëå, ñêðèïò âûãðóæåí!')
				NoErrors = true
				thisScript():unload()
			end
			getmyrank = false
			return false
		end

		if dialogId == 6 and givelic then
			if lictype == "àâòî" then
				sampSendDialogResponse(dialogId, 1, 0, nil)
			end
			if lictype == "ìîòî" then
				sampSendDialogResponse(dialogId, 1, 1, nil)
			end
			if lictype == "ðûáîëîâñòâî" then
				sampSendDialogResponse(dialogId, 1, 3, nil)
			end
			if lictype == "ïëàâàíèå" then
				sampSendDialogResponse(dialogId, 1, 4, nil)
			end
			if lictype == "îðóæèå" then
				sampSendDialogResponse(dialogId, 1, 5, nil)
			end
			if lictype == "îõîòó" then
				sampSendDialogResponse(dialogId, 1, 6, nil)
			end
			if lictype == "ðàñêîïêè" then
				sampSendDialogResponse(dialogId, 1, 7, nil)
			end
			givelic = false
			return false
		end

		if dialogId == 1234 then
			if text:find('Ñðîê äåéñòâèÿ') then
				if not mcvalue then
					if text:find("Èìÿ: "..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find("Ïîëíîñòüþ çäîðîâûé") then
							local statusint = DialogLine:match('{CEAD2A}Íàðêîçàâèñèìîñòü: (%d+)')
								if tonumber(statusint) then
									statusint = tonumber(statusint)
									if statusint <= 5 then
										mcvalue = true
										mcverdict = ("â ïîðÿäêå")
									else
										mcvalue = true
										mcverdict = ("íàðêîçàâèñèìîñòü")
									end
								end
							else
								mcvalue = true
								mcverdict = ("íå ïîëíîñòüþ çäîðîâûé")
							end
						end
					end
				elseif not skiporcancel then
					if text:find("Èìÿ: "..choosedname) then
						if text:find("Ïîëíîñòüþ çäîðîâûé") then
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								inprocess = true
								sampSendChat("/me âçÿâ ìåä.êàðòó â ðóêè íà÷àë å¸ ïðîâåðÿòü")
								wait(cd)
								sampSendChat("/do Ìåä.êàðòà â íîðìå.")
								wait(cd)
								sampSendChat("/todo Âñ¸ â ïîðÿäêå* îòäàâàÿ ìåä.êàðòó îáðàòíî")
								wait(cd)
								skiporcancel = true
								cansell = true
								inprocess = false
								selllic(tempid..' îðóæèå')
							end)
						else
							lua_thread.create(function()
								inprocess = true
								ASHelperMessage('×åëîâåê íå ïîëíîñòüþ çäîðîâûé, òðåáóåòñÿ ïîìåíÿòü ìåä.êàðòó!')
								sampSendChat("/me âçÿâ ìåä.êàðòó â ðóêè íà÷àë å¸ ïðîâåðÿòü")
								wait(cd)
								sampSendChat("/do Ìåä.êàðòà íå â íîðìå.")
								wait(cd)
								sampSendChat("/todo Ê ñîæàëåíèþ, â ìåä.êàðòå íàïèñàíî, ÷òî ó âàñ åñòü îòêëîíåíèÿ.* îòäàâàÿ ìåä.êàðòó îáðàòíî")
								wait(cd)
								sampSendChat("Îáíîâèòå å¸ è ïðèõîäèòå ñíîâà!")
								skiporcancel = true
								cansell = false
								inprocess = false
							end)
						end
						return false
					end
				end
			elseif text:find('Ñåðèÿ') then
				if not passvalue then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("Èìÿ: {FFD700}"..sampGetPlayerNickname(fastmenuID)) then
							if not text:find('{FFFFFF}Îðãàíèçàöèÿ:') then
								for DialogLine in text:gmatch('[^\r\n]+') do
									local passstatusint = DialogLine:match('{FFFFFF}Ëåò â øòàòå: {FFD700}(%d+)')
									if tonumber(passstatusint) then
										if tonumber(passstatusint) >= 3 then
											for DialogLine in text:gmatch('[^\r\n]+') do
												local zakonstatusint = DialogLine:match('{FFFFFF}Çàêîíîïîñëóøíîñòü: {FFD700}(%d+)')
												if tonumber(zakonstatusint) then
													if tonumber(zakonstatusint) >= 35 then
														if not text:find('Ëå÷èëñÿ â Ïñèõèàòðè÷åñêîé áîëüíèöå') then
															if not text:find('Ñîñòîèò â ×Ñ{FF6200} Èíñòðóêòîðû') then
																passvalue = true
																passverdict = ("â ïîðÿäêå")
															else
																passvalue = true
																passverdict = ("â ÷ñ àâòîøêîëû")
															end
														else
															passvalue = true
															passverdict = ("áûë â äåìîðãàíå")
														end
													else
														passvalue = true
														passverdict = ("íå çàêîíîïîñëóøíûé")
													end
												end
											end
										else
											passvalue = true
											passverdict = ("ìåíüøå 3 ëåò â øòàòå")
										end
									end
								end
							else
								passvalue = true
								passverdict = ("èãðîê â îðãàíèçàöèè")
							end
						end
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
			if message:find('Èñïîëüçóéòå: /jobprogress %[ ID èãðîêà %]') then
				ASHelperMessage("Âû ïðîñìîòðåëè ñâîþ ðàáî÷óþ óñïåâàåìîñòü.")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ïåðåîäåâàåòñÿ â ãðàæäàíñêóþ îäåæäó') then
				ASHelperMessage("Âû çàêîí÷èëè ðàáî÷èé äåíü, óäà÷íîãî îòäûõà!")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ïåðåîäåâàåòñÿ â ðàáî÷óþ îäåæäó') then
				ASHelperMessage("Âû íà÷àëè ðàáî÷èé äåíü, óäà÷íîé ðàáîòû!")
				return false
			end
			if message:find('%[Èíôîðìàöèÿ%] {FFFFFF}Âû ïîêèíóëè ïîñò!') then
				ASHelperMessage('Âû ïîêèíóëè ïîñò.')
				return false
			end
		end
		if message:find('%[R%]') and not message:find('%[Îáúÿâëåíèå%]') and color == 766526463 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message}
		end
		if message:find('%[D%]') and color == 865730559 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message }
		end
		if message:find('ïîâûñèë äî') then
			getmyrank = true
			sampSendChat("/stats")
		end
		if message:find("%[Èíôîðìàöèÿ%] {FFFFFF}Âû óñïåøíî ïðîäàëè ëèöåíçèþ") then
			typeddd, toddd = message:match("%[Èíôîðìàöèÿ%] {FFFFFF}Âû óñïåøíî ïðîäàëè ëèöåíçèþ íà (.+) èãðîêó (.+).")
			if typeddd == "àâòî" then
				configuration.my_stats.avto = configuration.my_stats.avto + 1
			elseif typeddd == "ìîòî" then
				configuration.my_stats.moto = configuration.my_stats.moto + 1
			elseif typeddd == "ðûáàëêó" then
				configuration.my_stats.riba = configuration.my_stats.riba + 1
			elseif typeddd == "ïëàâàíèå" then
				configuration.my_stats.lodka = configuration.my_stats.lodka + 1
			elseif typeddd == "îðóæèå" then
				configuration.my_stats.guns = configuration.my_stats.guns + 1
			elseif typeddd == "îõîòó" then
				configuration.my_stats.hunt = configuration.my_stats.hunt + 1
			elseif typeddd == "ðàñêîïêè" then
				configuration.my_stats.klad = configuration.my_stats.klad + 1
			else
				if configuration.main_settings.replacechat then
					ASHelperMessage("Âû óñïåøíî ïðîäàëè ëèöåíçèþ íà "..typeddd.." èãðîêó "..toddd:gsub("_"," ")..".")
					return false
				end
			end
			if inicfg.save(configuration,"AS Helper") then
				if configuration.main_settings.replacechat then
					ASHelperMessage("Âû óñïåøíî ïðîäàëè ëèöåíçèþ íà "..typeddd.." èãðîêó "..toddd:gsub("_"," ")..". Îíà áûëà çàñ÷èòàíà â âàøó ñòàòèñòèêó.")
					return false
				else
				end
			end
		end
		if message:find("Ïðèâåòñòâóåì íîâîãî ÷ëåíà íàøåé îðãàíèçàöèè (.+), êîòîðîãî ïðèãëàñèë: (.+)") then
			local result,myid = sampGetPlayerIdByCharHandle(playerPed)
			local invited,inviting = message:match("Ïðèâåòñòâóåì íîâîãî ÷ëåíà íàøåé îðãàíèçàöèè (.+), êîòîðîãî ïðèãëàñèë: (.+)%[")
			if inviting == sampGetPlayerNickname(myid) then
				if invited == sampGetPlayerNickname(waitingaccept) then
					sampSendChat("/giverank "..waitingaccept.." 2")
					waitingaccept = false
					ASHelperMessage(string.gsub(sampGetPlayerNickname(waitingaccept), "_", " ").." ïðèíÿë âàøå ïðåäëîæåíèå âñòóïèòü â Àâòîøêîëó è áûë ïîâûøåí äî äîëæíîñòè Êîíñóëüòàíòà.")
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
		--Ñêðèïò àêöåíòà Raymond: https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == "q" then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), "àêöåíò") or string.find(u8:decode(configuration.main_settings.myaccent), "Àêöåíò") then
				return{'['..u8:decode(configuration.main_settings.myaccent)..']: '..message}
			else
				return{'['..u8:decode(configuration.main_settings.myaccent)..' àêöåíò]: '..message}
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
    [155] = '[', [168] = '¨', [184] = '¸', [192] = 'À', [193] = 'Á', [194] = 'Â', [195] = 'Ã', [196] = 'Ä', [197] = 'Å', [198] = 'Æ', [199] = 'Ç', [200] = 'È', [201] = 'É', [202] = 'Ê', [203] = 'Ë', [204] = 'Ì', [205] = 'Í', [206] = 'Î', [207] = 'Ï', [208] = 'Ð', [209] = 'Ñ', [210] = 'Ò', [211] = 'Ó', [212] = 'Ô', [213] = 'Õ', [214] = 'Ö', [215] = '×', [216] = 'Ø', [217] = 'Ù', [218] = 'Ú', [219] = 'Û', [220] = 'Ü', [221] = 'Ý', [222] = 'Þ', [223] = 'ß', [224] = 'à', [225] = 'á', [226] = 'â', [227] = 'ã', [228] = 'ä', [229] = 'å', [230] = 'æ', [231] = 'ç', [232] = 'è', [233] = 'é', [234] = 'ê', [235] = 'ë', [236] = 'ì', [237] = 'í', [238] = 'î', [239] = 'ï', [240] = 'ð', [241] = 'ñ', [242] = 'ò', [243] = 'ó', [244] = 'ô', [245] = 'õ', [246] = 'ö', [247] = '÷', [248] = 'ø', [249] = 'ù', [250] = 'ú', [251] = 'û', [252] = 'ü', [253] = 'ý', [254] = 'þ', [255] = 'ÿ',
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
		sampAddChatMessage("{ff6633}[Ðåæèì ðàçðàáîò÷èêà] {FFFFFF}Èìèòèðîâàòü ìàêñèìàëüíûé ðàíã: " ..(devmaxrankp and "{00FF00}Âêëþ÷åíî" or "{FF0000}Âûêëþ÷åíî"), 0xff6633)
		getmyrank = true
		sampSendChat("/stats")
	else
		sampAddChatMessage("{ff6347}[Îøèáêà] {FFFFFF}Íåèçâåñòíàÿ êîìàíäà! Ââåäèòå /help äëÿ ïðîñìîòðà äîñòóïíûõ ôóíêöèé.",0xff6347)
	end
end

function goodverdict()
	if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
		sampAddChatMessage("{ff6633}[Ðåæèì ðàçðàáîò÷èêà] {FFFFFF}Âû èìèòèðîâàëè îäîáðåííûé âåðäèêò ïàñïîðòà è ìåä.êàðòû â ñîáåñåäîâàíèè.", 0xff6633)
		mcvalue = true
		passvalue = true
		mcverdict = ("â ïîðÿäêå")
		passverdict = ("â ïîðÿäêå")
	else
		sampAddChatMessage("{ff6347}[Îøèáêà] {FFFFFF}Íåèçâåñòíàÿ êîìàíäà! Ââåäèòå /help äëÿ ïðîñìîòðà äîñòóïíûõ ôóíêöèé.",0xff6347)
	end
end

function ASHelperMessage(value)
	local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
	sampAddChatMessage("[ASHelper] {EBEBEB}"..value,"0x"..string.format('%06X', bit.band(join_argb(a, r, g, b), 0xFFFFFF)))
end

--Ðàçäåëåíèå äåíåæíûõ ñóìì íà òî÷êè îò Royan_Millans: https://www.blast.hk/threads/39380/
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
					binderkeystatus = u8"Ïðèìåíèòü "..keyname
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
    	sampShowDialog(1313, "{ff6633}[AS Helper]{ffffff} Ñêðèïò áûë âûãðóæåí ñàì ïî ñåáå.", [[
{ffffff}                                                                             ×òî äåëàòü â òàêèõ ñëó÷àÿõ?{f51111}

Åñëè âû ñàìîñòîÿòåëüíî ïåðåçàãðóçèëè ñêðèïò, òî ìîæåòå çàêðûòü ýòî äèàëîãîâîå îêíî.
Â èíîì ñëó÷àå, äëÿ íà÷àëà ïîïûòàéòåñü âîññòàíîâèòü ðàáîòó ñêðèïòà ñî÷åòàíèåì êëàâèø CTRL + R.
Åñëè æå ýòî íå ïîìîãëî, òî ÷èòàéòå ñëåäóþùèå ïóíêòû.{ff6633}

1. Âîçìîæíî ó âàñ óñòàíîâëåíû äðóãèå LUA ôàéëû è õåëïåðû, ïîïûòàéòåñü óäàëèòü èõ.

2. Âîçìîæíî âû íå äîóñòàíîâèëè íåêîòîðûå äîïîëíåíèÿ, à èìåííî:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26

3. Åñëè äàííîé îøèáêè íå áûëî ðàíåå, ïîïûòàéòåñü ñäåëàòü ñëåäóþùèå äåéñòâèÿ:
- Â ïàïêå moonloader > config > Óäàëÿåì ôàéë AS Helper.ini

4. Åñëè íè÷åãî èç âûøåïåðå÷èñëåííîãî íå èñïðàâèëî îøèáêó, òî ñëåäóåò óñòàíîâèòü ñêðèïò íà äðóãóþ ñáîðêó.

5. Åñëè ó âàñ ñêðèïò âûëåòàåò ïî íàæàòèþ íà êàêóþ-òî êíîïêó, òî ìîæåòå îòïðàâèòü (JustMini#6291) ýòó îøèáêó.]], "ÎÊ", nil, 0)
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
		ASHelperMessage("Îòñóòñòâóåò áèáëèîòåêà samp events. Ïûòàþñü å¸ óñòàíîâèòü.")
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events.lua', 'moonloader/lib/samp/events.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/raknet.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/synchronization.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/bitstream_io.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/core.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/extra_types.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/handlers.lua') then
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/utils.lua') then
					ASHelperMessage("Áèáëèîòåêà samp events áûëà óñïåøíî óñòàíîâëåíà.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not encodingcheck then
		ASHelperMessage("Îòñóòñòâóåò áèáëèîòåêà encoding. Ïûòàþñü å¸ óñòàíîâèòü.")
		if doesFileExist('moonloader/lib/encoding.lua') then
			os.remove('moonloader/lib/encoding.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/encoding.lua') then
					ASHelperMessage("Áèáëèîòåêà encoding áûëà óñïåøíî óñòàíîâëåíà.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not imguicheck then
		ASHelperMessage("Îòñóòñòâóåò áèáëèîòåêà imgui. Ïûòàþñü å¸ óñòàíîâèòü.")
		if doesFileExist('moonloader/lib/imgui.lua') then
			os.remove('moonloader/lib/imgui.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/imgui.lua') then
					ASHelperMessage("Áèáëèîòåêà imgui áûëà óñïåøíî óñòàíîâëåíà.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not facheck then
		ASHelperMessage("Îòñóòñòâóåò áèáëèîòåêà fAwesome5. Ïûòàþñü å¸ óñòàíîâèòü.")
		if doesFileExist('moonloader/lib/fAwesome5.lua') then
			os.remove('moonloader/lib/fAwesome5.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/fAwesome5.lua', 'moonloader/lib/fAwesome5.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/fAwesome5.lua') then
					ASHelperMessage("Áèáëèîòåêà fAwesome5 áûëà óñïåøíî óñòàíîâëåíà.")
					fa = require"fAwesome5"
					fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage("Îòñóòñòâóåò ôàéë øðèôòà. Ïûòàþñü åãî óñòàíîâèòü.")
		createDirectory('moonloader/resource/fonts')
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
					ASHelperMessage("Ôàéë øðèôòà áûë óñïåøíî óñòàíîâëåí.")
				else
					ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ óñòàíîâêè.")
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
					ASHelperMessage("Íàéäåíî îáíîâëåíèå. Ïûòàþñü óñòàíîâèòü åãî.")
					doupdate = true
				else
					ASHelperMessage("Îáíîâëåíèé íå íàéäåíî.")
					doupdate = false
				end
				os.remove('moonloader/config/updateashelper.ini')
			else
				ASHelperMessage("Ïðîèçîøëà îøèáêà âî âðåìÿ ïðîâåðêè îáíîâëåíèé.")
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
				ASHelperMessage("Îáíîâëåíèå óñïåøíî óñòàíîâëåíî.")
			end
		end)
		return false
	end
	return true
end
