script_name('AS Helper')
script_description('/ash')
script_author('JustMini')

require "lib.moonloader"
local dlstatus = require "moonloader".download_status
local inicfgcheck, inicfg = pcall(require, "inicfg")
local vkeyscheck, vkeys = pcall(require, "vkeys")
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
		createmarker = true,
		gender = 0
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

local cmdhelp = 'ash'
local cmdbind = "ashbind"
local cmdcmds = "ashcmds"
local cmdupdate = "ashupd"

local ScreenX, ScreenY = getScreenResolution()

local cd = 2000
local cansell = false
local inprocess = false
local idd = nil
local devmaxrankp = false
local scriptvernumb = 2

local u8 = encoding.UTF8
encoding.default = 'CP1251'

local imgui_settings 	= imgui.ImBool(false)
local imgui_fm 			= imgui.ImBool(false)
local imgui_license		= imgui.ImBool(false)
local imgui_expel		= imgui.ImBool(false)
local imgui_uninvite 	= imgui.ImBool(false)
local imgui_giverank 	= imgui.ImBool(false)
local imgui_blacklist	= imgui.ImBool(false)
local imgui_fwarn		= imgui.ImBool(false)
local imgui_fmute 		= imgui.ImBool(false)
local imgui_sobes 		= imgui.ImBool(false)
local imgui_binder 		= imgui.ImBool(false)
local imgui_cmds 		= imgui.ImBool(false)

local useaccent 		= imgui.ImBool(configuration.main_settings.useaccent)
local createmarker 		= imgui.ImBool(configuration.main_settings.createmarker)
local useservername 	= imgui.ImBool(configuration.main_settings.useservername)
local myname 			= imgui.ImBuffer(configuration.main_settings.myname, 256)
local myaccent 			= imgui.ImBuffer(configuration.main_settings.myaccent, 256)

local ComboBox_select 	= imgui.ImInt(0)
local ComboBox_arr 		= {u8"Авто",u8"Мото",u8"Рыболовство",u8"Плавание",u8"Оружие",u8"Охота",u8"Раскопки"}
local avtoprice 		= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7)
local motoprice 		= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7)
local ribaprice 		= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7)
local lodkaprice 		= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7)
local gunaprice 		= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7)
local huntprice 		= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7)
local kladprice			= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7)

local expelbuff 		= imgui.ImBuffer(200)

local uninvitebuf 		= imgui.ImBuffer(256)
local blacklistbuf 		= imgui.ImBuffer(256)
local uninvitebox 		= imgui.ImBool(false)

local blacklistbuff 	= imgui.ImBuffer(256)

local fwarnbuff 		= imgui.ImBuffer(256)

local fmutebuff 		= imgui.ImBuffer(256)
local fmuteint 			= imgui.ImInt(0)

local binderbuff 		= imgui.ImBuffer(4096)
local bindername 		= imgui.ImBuffer(128)
local binderdelay 		= imgui.ImBuffer(7)
local bindertype 		= imgui.ImInt(0)
local bindercmd 		= imgui.ImBuffer(15)

local mcvalue = true
local passvalue = true

local Ranks_select 		= imgui.ImInt(0)
local Ranks_arr 		= {u8"[1] Стажёр",u8"[2] Консультант",u8"[3] Лицензёр",u8"[4] Мл. Инструктор",u8"[5] Инструктор",u8"[6] Менеджер",u8"[7] Ст. Менеджер",u8"[8] Помощник директора",u8"[9] Директор"}

local gender 			= imgui.ImInt(configuration.main_settings.gender)
local gender_arr 		= {u8"Мужской",u8"Женский"}

local sobesdecline_select = imgui.ImInt(0)
local sobesdecline_arr 	= {u8"Плохое РП",u8"Не было РП",u8"Плохая грамматика",u8"Ничего не показал",u8"Другое"}

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
	end
end

--Тема от madrasso: https://www.blast.hk/threads/25442/#post-310168
imgui.SwitchContext()
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local ImVec2 = imgui.ImVec2

style.WindowPadding = ImVec2(15, 15)
style.WindowRounding = 6.0
style.FramePadding = ImVec2(5, 5)
style.FrameRounding = 4.0
style.ItemSpacing = ImVec2(12, 8)
style.ItemInnerSpacing = ImVec2(8, 6)
style.IndentSpacing = 25.0
style.ScrollbarSize = 15.0
style.ScrollbarRounding = 9.0
style.GrabMinSize = 5.0
style.GrabRounding = 3.0

colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.95)
colors[clr.ChildWindowBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
colors[clr.Button] = ImVec4(0.08, 0.07, 0.10, 1.00)
colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
colors[clr.CloseButton] = ImVec4(0.914	, 0.439, 0, 1.00)
colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then
	return end
	while not isSampAvailable() do
		wait(200)
	end
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
			sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Создан файл конфигурации.', 0xff6633)
		end
    end
	sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}AutoSchool Helper успешно загружен. Автор: JustMini.", 0xff6633)
	sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите /"..cmdhelp.." чтобы настроить его.", 0xff6633)
	imgui.Process = false
	sampRegisterChatCommand(cmdhelp, fastmenuopen)
	sampRegisterChatCommand(cmdbind, binder)
	sampRegisterChatCommand(cmdcmds, cmds)
	sampRegisterChatCommand(cmdupdate, updaterank)
	sampRegisterChatCommand("uninvite", uninvitewithcmd)
	sampRegisterChatCommand("invite", invite)
	sampRegisterChatCommand("giverank", giverank)
	sampRegisterChatCommand("blacklist", blacklist)
	sampRegisterChatCommand("unblacklist", unblacklist)
	sampRegisterChatCommand("fwarn", fwarn)
	sampRegisterChatCommand("unfwarn", unfwarn)
	sampRegisterChatCommand("fmute", fmute)
	sampRegisterChatCommand("funmute", funmute)
	sampRegisterChatCommand("expel", expel)
	sampRegisterChatCommand("devmaxrank", devmaxrank)
	updatechatcommands()
	sampRegisterChatCommand('skip', function()
		lua_thread.create(function()
			if skiporcancel == false then
				skiporcancel = true
				cansell = true
				inprocess = false
				sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы пропустили ожидание мед.карты', 0xff6633)
				selllic(tempid..' оружие')
			else
				sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вам нечего пропускать!', 0xff6633)
			end
		end)
	end)
	sampRegisterChatCommand('cancelmc', function()
		if skiporcancel == false then
			skiporcancel = true
			cansell = false
			inprocess = false
			sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы отменили ожидание мед.карты', 0xff6633)
		else
			sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вам нечего отменять!', 0xff6633)
		end
	end)
end

function fastmenuopen()
	disableallimgui()
	imgui_settings.v = not imgui_settings.v
	userset = false
	licset = false
	keysset = false
	otherset = false
	scriptinfo = false
end

function faslfak()
	imgui_fm.v = not imgui_fm.v
end

function binder()
	imgui_binder.v = not imgui_binder.v
end

function cmds()
	imgui_cmds.v = not imgui_cmds.v
end

function updaterank()
	getmyrank = true
	sampSendChat("/stats")
end

log = {}

emptykey1 = {}
emptykey2 = {}

lua_thread.create(function()
	while true do
		wait(0)
		if getCharPlayerIsTargeting() then
			result, targettingped = getCharPlayerIsTargeting()
			if configuration.main_settings.createmarker == true then
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
			button = configuration.main_settings.usefastmenu
			if isKeyJustPressed(vkeys.name_to_id(button,true)) then
				if not sampIsChatInputActive() then
					result, targettingid = sampGetPlayerIdByCharHandle(targettingped)
					if targettingid ~= -1 then
						if not imgui_fm.v then
							sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Вы использовали меню быстрого доступа на: "..sampGetPlayerNickname(targettingid).."["..targettingid.."]",0xff6633)
							imgui_fm.v = true
						end
					end
				end
			end
		end
		if imgui_settings.v or imgui_fm.v or imgui_license.v or imgui_expel.v or imgui_uninvite.v or imgui_giverank.v or imgui_blacklist.v or imgui_fwarn.v or imgui_fmute.v or imgui_sobes.v or imgui_binder.v or imgui_cmds.v then
			imgui.Process = true
			imgui.ShowCursor = true
		else
			imgui.Process = false
		end
		for key, value in pairs(configuration.BindsName) do
			if tostring(value):find(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= "" then
					if configuration.BindsKeys[key]:match("(.+) %p (.+)") then
						fkey = configuration.BindsKeys[key]:match("(.+) %p")
						skey = configuration.BindsKeys[key]:match("%p (.+)")
						if isKeyDown(vkeys.name_to_id(fkey,true)) and wasKeyPressed(vkeys.name_to_id(skey,true)) then
							if not inprocess then
								for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
									inprocess = true
									sampSendChat(tostring(bp))
									wait(configuration.BindsDelay[key])
									inprocess = false
								end
							else
								sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
							end
						end
					elseif configuration.BindsKeys[key]:match("(.+)") then
						fkey = configuration.BindsKeys[key]:match("(.+)")
						if wasKeyPressed(vkeys.name_to_id(fkey,true)) then
							if not inprocess then
								for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
									inprocess = true
									sampSendChat(tostring(bp))
									wait(configuration.BindsDelay[key])
									inprocess = false
								end
							else
								sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
							end
						end
					end
				end
			end
		end
	end
end)

function imgui.OnDrawFrame()
	if imgui_settings.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"                  Настройки ASHelper", imgui_settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_USER_COG..u8' Настройки пользователя', imgui.ImVec2(285,30)) then
			userset = not userset
		end
		if userset then
			if imgui.Checkbox(u8"Использовать мой ник из таба",useservername) then
				if configuration.main_settings.myname == '' then
					result,myid = sampGetPlayerIdByCharHandle(playerPed)
					myname.v = sampGetPlayerNickname(myid)
					configuration.main_settings.myname = sampGetPlayerNickname(myid)
				end
				configuration.main_settings.useservername = useservername.v
				if inicfg.save(configuration,"AS Helper") then
				end
			end
			if not useservername.v then
				if imgui.InputText(u8" ", myname) then
					configuration.main_settings.myname = myname.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
			end
			if imgui.Checkbox(u8"Использовать акцент",useaccent) then
				configuration.main_settings.useaccent = useaccent.v
				if inicfg.save(configuration,"AS Helper") then
				end
			end
			if useaccent.v then
				imgui.PushItemWidth(150)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 275))
				if imgui.InputText(u8"", myaccent) then
					configuration.main_settings.myaccent = myaccent.v
					if inicfg.save(configuration,"AS Helper") then
					end
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"[").x) / 18)
				imgui.Text("[")
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"[").x) / 1.65)
				imgui.Text("]")
			end
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
			if imgui.Button(u8'Обновить', imgui.ImVec2(65,25)) then
				getmyrank = true
				sampSendChat("/stats")
			end
			imgui.SameLine()
			imgui.Text(u8"Ваш ранг: "..u8(configuration.main_settings.myrank).." ("..u8(configuration.main_settings.myrankint)..")")
			imgui.PushItemWidth(85)
			if imgui.Combo(u8"Ваш пол",gender, gender_arr, #gender_arr) then
				configuration.main_settings.gender = gender.v
				if inicfg.save(configuration,"AS Helper") then
				end
			end
			imgui.PopItemWidth()
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Настройки лицензий', imgui.ImVec2(285,30)) then
			licset = not licset
		end
		if licset then
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
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_KEYBOARD..u8' Настройки горячих клавиш', imgui.ImVec2(285,30)) then
			keysset = not keysset
		end
		if keysset then
			if imgui.Button(u8'Изменить', imgui.ImVec2(65,25)) then
				table.remove(log)
				getbindkey = true
				getbindkeys()
				configuration.main_settings.usefastmenu = ""
				if inicfg.save(configuration,"AS Helper") then
				end
			end
			imgui.SameLine()
			imgui.Text(u8"Кнопку быстрого меню: ПКМ + "..configuration.main_settings.usefastmenu.."",imgui.ImVec2(80,25))
			if imgui.Button(u8'Биндер', imgui.ImVec2(65,25)) then
				binder()
			end
			imgui.SameLine()
			imgui.Text(u8"Открыть настройки биндера",imgui.ImVec2(80,25))
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_CIRCLE_NOTCH..u8' Остальное', imgui.ImVec2(285,30)) then
			otherset = not otherset
		end
		if otherset then
			if imgui.Button(u8'Узнать', imgui.ImVec2(65,25)) then
				imgui_cmds.v = not imgui_cmds.v
			end
			imgui.SameLine()
			imgui.Text(u8"Все команды биндера",imgui.ImVec2(80,25))
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_INFO_CIRCLE..u8' Информация о скрипте', imgui.ImVec2(285,30)) then
			scriptinfo = not scriptinfo
		end
		if scriptinfo then
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Создатель: JustMini').x) / 2)
			imgui.Text(u8'Создатель: JustMini',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Отдельное спасибо:').x) / 2)
			imgui.Text(u8'Отдельное спасибо:',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Zody').x) / 2)
			imgui.Text(u8'Zody',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'madrasso').x) / 2)
			imgui.Text(u8'madrasso',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Royan_Millans').x) / 2)
			imgui.Text(u8'Royan_Millans',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Raymond').x) / 2)
			imgui.Text(u8'Raymond',imgui.ImVec2(70,20))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Cosmo').x) / 2)
			imgui.Text(u8'Cosmo',imgui.ImVec2(70,20))
			imgui.Separator()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Версия 1.0').x) / 2)
			imgui.Text(u8'Версия 1.0',imgui.ImVec2(70,20))
			imgui.Separator()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Исправлен баг с акцентом').x) / 2)
			imgui.Text(u8'Исправлен баг с акцентом',imgui.ImVec2(70,20))
		end
		imgui.End()
	elseif imgui_fm.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"               Меню быстрого доступа", imgui_fm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы выбрали ID: "..targettingid).x) / 2)
		imgui.Text(u8"Вы выбрали ИД: "..targettingid, imgui.ImVec2(75,30))
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 1 then
					disableallimgui()
					hello()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 1-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 1  then
					disableallimgui()
					pricelist()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 1-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(285,30)) then
			if configuration.main_settings.myrankint >= 3 then
				imgui_license.v = true
				imgui_fm.v = false
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 3-го ранга.", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(285,30)) then
			if configuration.main_settings.myrankint >= 5 then
				imgui_expel.v = true
				imgui_fm.v = false
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 5-го ранга.", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					disableallimgui()
					tosend = tostring(targettingid)
					invite(tosend)
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					imgui_fm.v = false
					imgui_uninvite.v = true
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					imgui_fm.v = false
					imgui_giverank.v = true
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					imgui_fm.v = false
					imgui_blacklist.v = true
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					unblacklist(tostring(targettingid))
					disableallimgui()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					imgui_fwarn.v = true
					imgui_fm.v = false
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					unfwarn(tostring(targettingid))
					disableallimgui()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
			end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					imgui_fmute.v = true
					imgui_fm.v = false
					else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 9 then
					funmute(tostring(targettingid))
					disableallimgui()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
			end
		imgui.Separator()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(u8'Собеседование '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
			if not inprocess then
				if configuration.main_settings.myrankint >= 5 then
					passvalue = false
					mcvalue = false
					passverdict = ""
					mcverdict = ""
					sobesetap = 0
					imgui_sobes.v = true
					imgui_fm.v = false
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данное действие доступно с 5-го ранга.", 0xff6633)
				end
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.End()
	elseif imgui_license.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"               Меню быстрого доступа", imgui_license, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы продаёте лицензию человеку под ID: "..targettingid).x) / 2)
		imgui.Text(u8"Вы продаёте лицензию человеку под ID: "..targettingid, imgui.ImVec2(75,30))
		imgui.NewLine()
		imgui.Text(u8"Лицензия: ", imgui.ImVec2(75,30))
		imgui.SameLine()
		imgui.Combo(' ', ComboBox_select, ComboBox_arr, #ComboBox_arr)
		imgui.NewLine()
		if ComboBox_select.v == 0 then
			givelic = "авто"
		elseif ComboBox_select.v == 1 then
			givelic = "мото"
		elseif ComboBox_select.v == 2 then
			givelic = "рыболовство"
		elseif ComboBox_select.v == 3 then
			givelic = "плавание"
		elseif ComboBox_select.v == 4 then
			givelic = "оружие"
		elseif ComboBox_select.v == 5 then
			givelic = "охоту"
		elseif ComboBox_select.v == 6 then
			givelic = "раскопки"
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(u8'Продать лицензию на '..u8(givelic), imgui.ImVec2(285,30)) then
			if not inprocess then
				ComboBox_select.v = 0
				selltowhostr = tostring(targettingid).." "..tostring(givelic)
				selllic(selltowhostr)
				disableallimgui()
				else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		if imgui.Button(u8'Лицензия на полёты', imgui.ImVec2(285,30)) then
			if not inprocess then
				ComboBox_select.v = 0
				selltowhostr = tostring(targettingid).." полёты"
				selllic(selltowhostr)
				disableallimgui()
				else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
		if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
			imgui_fm.v = true
			imgui_license.v = false
		end
		imgui.End()
	elseif imgui_expel.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"               Меню быстрого доступа", imgui_expel, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы выгоняете человека под ID: "..targettingid).x) / 2)
		imgui.Text(u8"Вы выгоняете человека под ID: "..targettingid, imgui.ImVec2(75,30))
		imgui.NewLine()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина expel:").x) / 2)
		imgui.Text(u8"Причина expel:", imgui.ImVec2(75,30))
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
		imgui.InputText(u8"",expelbuff)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
		if imgui.Button(u8'Выгнать '..sampGetPlayerNickname(targettingid)..'['..targettingid..']', imgui.ImVec2(200,30)) then
			if expelbuff.v == nil or expelbuff.v == "" then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину expel!", 0xff6633)
			else
				expel(tostring(targettingid.." "..u8:decode(expelbuff.v)))
				disableallimgui()
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
		if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
			imgui_fm.v = true
			imgui_expel.v = false
		end
		imgui.End()
	elseif imgui_uninvite.v == true then
		if not inprocess then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"               Меню быстрого доступа", imgui_uninvite, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы увольняете сотрудника под ID: "..targettingid).x) / 2)
			imgui.Text(u8"Вы увольняете сотрудника под ID: "..targettingid, imgui.ImVec2(75,30))
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина увольнения:").x) / 2)
			imgui.Text(u8"Причина увольнения:", imgui.ImVec2(75,30))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
			imgui.InputText(u8"", uninvitebuf)
			if uninvitebox.v then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина ЧС:").x) / 2)
				imgui.Text(u8"Причина ЧС:", imgui.ImVec2(75,30))
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
				imgui.InputText(u8" ", blacklistbuf)
			end
			imgui.Checkbox(u8"Уволить с ЧС", uninvitebox)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Уволить '..sampGetPlayerNickname(targettingid)..'['..targettingid..']', imgui.ImVec2(285,30)) then
				if uninvitebuf.v == nil or uninvitebuf.v == '' then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину увольнения!", 0xff6633)
				else
					if uninvitebox.v then
						if blacklistbuf.v == nil or blacklistbuf.v == '' then
							sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину занесения в ЧС!", 0xff6633)
						else
							uninvite(targettingid.." 1")
							disableallimgui()
						end
					else
						uninvite(targettingid.." 0")
						disableallimgui()
					end
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
				imgui_fm.v = true
				imgui_uninvite.v = false
			end
			imgui.End()
		end
	elseif imgui_giverank.v == true then
		if not inprocess then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"               Меню быстрого доступа", imgui_giverank, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы меняете ранг сотруднику под ID: "..targettingid).x) / 2)
			imgui.Text(u8"Вы меняете ранг сотруднику под ID: "..targettingid, imgui.ImVec2(75,30))
			imgui.PushItemWidth(270)
			imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
			imgui.PopItemWidth()
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
			if imgui.Button(u8'Изменить ранг этому сотруднику', imgui.ImVec2(270,40)) then
				giverank(targettingid.." "..(Ranks_select.v+1))
				disableallimgui()
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
				imgui_fm.v = true
				imgui_giverank.v = false
			end
			imgui.End()
		end
	elseif imgui_blacklist.v == true then
		if not inprocess then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"               Меню быстрого доступа", imgui_blacklist, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы заносите в ЧС человека под ID: "..targettingid).x) / 2)
			imgui.Text(u8"Вы заносите в ЧС человека под ID: "..targettingid, imgui.ImVec2(75,30))
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина занесения в ЧС:").x) / 2)
			imgui.Text(u8"Причина занесения в ЧС:", imgui.ImVec2(75,30))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
			imgui.InputText(u8"", blacklistbuff)
			imgui.NewLine()
			if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(targettingid)..'['..targettingid..']', imgui.ImVec2(270,30)) then
				if blacklistbuff.v == nil or blacklistbuff.v == '' then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину занесения в ЧС!", 0xff6633)
				else
					blacklist(targettingid.." "..u8:decode(blacklistbuff.v))
					disableallimgui()
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
				imgui_fm.v = true
				imgui_blacklist.v = false
			end
			imgui.End()
		end
	elseif imgui_fwarn.v == true then
		if not inprocess then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"               Меню быстрого доступа", imgui_fwarn, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы выдаёте выговор сотруднику под ID: "..targettingid).x) / 2)
			imgui.Text(u8"Вы выдаёте выговор сотруднику под ID: "..targettingid, imgui.ImVec2(75,30))
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина выговора:").x) / 2)
			imgui.Text(u8"Причина выговора:", imgui.ImVec2(75,30))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
			imgui.InputText(u8"", fwarnbuff)
			imgui.NewLine()
			if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(targettingid)..'['..targettingid..']', imgui.ImVec2(270,30)) then
				if fwarnbuff.v == nil or fwarnbuff.v == '' then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину выдачи выговора!", 0xff6633)
				else
					fwarn(targettingid.." "..u8:decode(fwarnbuff.v))
					disableallimgui()
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
				imgui_fm.v = true
				imgui_fwarn.v = false
			end
			imgui.End()
		end
	elseif imgui_fmute.v == true then
		if not inprocess then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"               Меню быстрого доступа", imgui_fmute, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы выдаёте мут сотруднику под ID: "..targettingid).x) / 2)
			imgui.Text(u8"Вы выдаёте мут сотруднику под ID: "..targettingid, imgui.ImVec2(75,30))
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Причина мута:").x) / 2)
			imgui.Text(u8"Причина мута:", imgui.ImVec2(75,30))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
			imgui.InputText(u8"", fmutebuff)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Время мута:").x) / 2)
			imgui.Text(u8"Время мута:", imgui.ImVec2(75,30))
			imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
			imgui.InputInt(u8" ", fmuteint)
			imgui.NewLine()
			if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(targettingid)..'['..targettingid..']', imgui.ImVec2(270,30)) then
				if fmutebuff.v == nil or fmutebuff.v == '' then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите причину выдачи мута!", 0xff6633)
					else
					if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 then
						sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Введите время мута!", 0xff6633)
					else
						fmute(targettingid.." "..u8:decode(fmuteint.v).." "..u8:decode(fmutebuff.v))
						disableallimgui()
					end
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
				imgui_fm.v = true
				imgui_fmute.v = false
			end
			imgui.End()
		end
	elseif imgui_sobes.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"               Меню быстрого доступа", imgui_sobes, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Вы проводите собеседование ID: "..targettingid).x) / 2)
		imgui.Text(u8"Вы проводите собеседование ID: "..targettingid, imgui.ImVec2(75,30))
		imgui.NewLine()
		if sobesetap == 0 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Поприветствовать', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
					sobes1()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 1 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Попросить документы', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
					sobes2()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 2 then
			lastsobesetap = sobesetap
			if mcvalue == false then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Мед.карта - не показана").x) / 2)
				imgui.Text(u8"Мед.карта - не показана", imgui.ImVec2(75,30))
			else
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Мед.карта - показана ("..mcverdict..")").x) / 2)
				imgui.Text(u8"Мед.карта - показана ("..mcverdict..")", imgui.ImVec2(75,30))
			end
			if passvalue == false then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Паспорт - не показан").x) / 2)
				imgui.Text(u8"Паспорт - не показан", imgui.ImVec2(75,30))
			else
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Паспорт - показан ("..passverdict..")").x) / 2)
				imgui.Text(u8"Паспорт - показан ("..passverdict..")", imgui.ImVec2(75,30))
			end
			if mcvalue == true and mcverdict == (u8"в порядке") and passvalue == true and passverdict == (u8"в порядке") then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Продолжить', imgui.ImVec2(285,30)) then
					sobesetap = sobesetap + 1
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					if mcvalue == true or passvalue == true then
						if mcverdict == (u8"наркозависимость") then
							sobesdecline("наркозависимость")
							disableallimgui()
						elseif mcverdict == (u8"не полностью здоровый") then
							sobesdecline("не полностью здоровый")
							disableallimgui()
						elseif passverdict == (u8"меньше 3 лет в штате") then
							sobesdecline("меньше 3 лет в штате")
							disableallimgui()
						elseif passverdict == (u8"не законопослушный") then
							sobesdecline("не законопослушный")
							disableallimgui()
						elseif passverdict == (u8"игрок в организации") then
							sobesdecline("игрок в организации")
							disableallimgui()
						elseif passverdict == (u8"был в деморгане") then
							sobesdecline("был в деморгане")
							disableallimgui()
						else
							lastsobesetap = sobesetap
							sobesetap = 7
						end
					else
						lastsobesetap = sobesetap
						sobesetap = 7
					end
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 3 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Расскажите немного о себе.', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobes3()
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					lastsobesetap = sobesetap
					sobesetap = 7
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 4 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Почему выбрали именно нас?', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobes4()
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					lastsobesetap = sobesetap
					sobesetap = 7
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 5 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8"Работали вы уже в организациях ЦА?", imgui.ImVec2(285,30)) then
				if not inprocess then
					sobes5()
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					lastsobesetap = sobesetap
					sobesetap = 7
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Пропустить этап', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = sobesetap + 1
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 6 then
			lastsobesetap = sobesetap
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Одобрить', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesaccept2()
					sobesetap = nil
					disableallimgui()
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					lastsobesetap = sobesetap
					sobesetap = 7
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		elseif sobesetap == 7 then
			imgui.PushItemWidth(270)
			imgui.Combo(" ",sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
			imgui.PopItemWidth()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			if imgui.Button(u8'Отказать', imgui.ImVec2(285,30)) then
				if not inprocess then
					sobesetap = nil
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
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				end
			end
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
		imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
		if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
			if sobesetap == 7 then
				sobesetap = lastsobesetap
			elseif sobesetap ~= 0 then
				sobesetap = sobesetap - 1
			else
				imgui_fm.v = true
				imgui_sobes.v = false
			end
		end
		imgui.End()
	end
	if imgui_binder.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"                                                                   Настройки биндера", imgui_binder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
			imgui.BeginChild("ChildWindow",imgui.ImVec2(175,270),false,imgui.WindowFlags.NoScrollbar)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
				for key, value in pairs(configuration.BindsName) do
					value = tostring(value)
					if value:find(configuration.BindsName[key]) then
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
						if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
							choosedslot = key
							binderbuff.v = tostring(configuration.BindsAction[key]):gsub("~", "\n")
							binderbuff.v = u8(binderbuff.v)
							bindername.v = u8(configuration.BindsName[key])
							bindertype.v = u8(configuration.BindsType[key])
							bindercmd.v = u8(configuration.BindsCmd[key])
							binderkeystatus = configuration.BindsKeys[key]
							binderdelay.v = tostring(configuration.BindsDelay[key])
						end
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
				elseif bindertype.v == 1 then
					if binderkeystatus == nil or binderkeystatus == "" then
						binderkeystatus = u8"Нажмите чтобы поменять"
					end
					if imgui.Button(binderkeystatus) then
						if binderkeystatus == u8"Нажмите чтобы поменять" then
							table.remove(emptykey1)
							table.remove(emptykey2)
							setbinderkey = true
							getbindkeys()
						elseif string.find(binderkeystatus, u8"Применить") then
							setbinderkey = false
							binderkeystatus = string.match(binderkeystatus,u8"Применить (.+)")
						else
							table.remove(emptykey1)
							table.remove(emptykey2)
							keyname = nil
							keyname2 = nil
							setbinderkey = true
							getbindkeys()
						end
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 429) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
				local kei
				doreplace = false
				if imgui.Button(u8"Сохранить",imgui.ImVec2(100,30)) then
					if not inprocess then
						if binderbuff.v ~= "" and bindername.v ~= "" and binderdelay.v ~= "" and bindertype.v ~= nil then
							if bindertype.v == 0 then
								if bindercmd.v ~= "" and bindercmd.v ~= nil then
									for key, value in pairs(configuration.BindsName) do
									value = tostring(value)
										if u8:decode(bindername.v) == configuration.BindsName[key] then
											doreplace = true
											kei = key
										end
									end
									if doreplace == true then
										refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
										configuration.BindsName[kei] = u8:decode(bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindertype.v)
										configuration.BindsCmd[kei] = u8:decode(bindercmd.v)
										configuration.BindsKeys[kei] = ""
										if inicfg.save(configuration, "AS Helper") then
											sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Бинд успешно сохранён!", 0xff6633)
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
										refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
										table.insert(configuration.BindsName, u8:decode(bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindertype.v))
										table.insert(configuration.BindsCmd, u8:decode(bindercmd.v))
										table.insert(configuration.BindsKeys, "")
										if inicfg.save(configuration, "AS Helper") then
											sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Бинд успешно создан!", 0xff6633)
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
									sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Какой-то из параметров не введён, перепроверьте всё!", 0xff6633)
								end
							elseif bindertype.v == 1 then
								if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= "Нажмите чтобы поменять" and not string.find((u8:decode(binderkeystatus)), "Применить ") then
									for key, value in pairs(configuration.BindsName) do
										if u8:decode(bindername.v) == configuration.BindsName[key] then
											doreplace = true
											kei = key
										end
									end
									if doreplace == true then
										refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
										configuration.BindsName[kei] = u8:decode(bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindertype.v)
										configuration.BindsCmd[kei] = ""
										configuration.BindsKeys[kei] = u8(binderkeystatus)
										if inicfg.save(configuration, "AS Helper") then
											sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Бинд успешно сохранён!", 0xff6633)
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
										refresh_text = u8:decode(binderbuff.v):gsub("\n", "~")
										table.insert(configuration.BindsName, u8:decode(bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindertype.v))
										table.insert(configuration.BindsKeys, u8(binderkeystatus))
										table.insert(configuration.BindsCmd, "")
										if inicfg.save(configuration, "AS Helper") then
											sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Бинд успешно создан!", 0xff6633)
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
									sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Вы неправильно указали клавишу бинда!", 0xff6633)
								end
							end
						else
							sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Какой-то из параметров не введён, перепроверьте всё!", 0xff6633)
						end
						updatechatcommands()
					else
						sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Вы не можете удалять бинд во время любой отыгровки!", 0xff6633)
					end	
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
									sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Бинд успешно удалён!", 0xff6633)
								end
							end
						end
					updatechatcommands()
					else
						sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Вы не можете удалять бинд во время любой отыгровки!", 0xff6633)
					end
				end
			else
				local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
				imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
					imgui.Button(u8"Удалить",imgui.ImVec2(82,30))
				imgui.PopStyleColor()
				imgui.PopStyleColor()
				imgui.PopStyleColor()
				imgui.PopStyleColor()
			end
		imgui.End()
	end
	if imgui_cmds.v == true then
		imgui.SetNextWindowSize(imgui.ImVec2(310, 130), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(1.5, 0.5))
		imgui.Begin(u8"                     Команды хелпера", imgui_cmds, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove)
		imgui.Text("/"..cmdhelp..u8" - открыть меню настроек хелпера")
		imgui.Text("/"..cmdbind..u8" - открыть меню настроек биндера")
		imgui.Text("/"..cmdcmds..u8" - открыть меню команд хелпера")
		imgui.Text("/"..cmdupdate..u8" - команда для обновление ранга")
		imgui.End()
	end
end

function hello()
	lua_thread.create(function()
		if inprocess ~= true then
			getmyrank = true
			sampSendChat("/stats")
			hour = (os.date("%H",os.time()))
			hour = tonumber(hour)
			if configuration.main_settings.useservername then
				result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = sampGetPlayerNickname(myid)
			else
				name = u8:decode(myname.v)
				if name == '' or name == nil then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Введите своё имя в /'..cmdhelp..' ', 0xff6633)
					result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = sampGetPlayerNickname(myid)
				end
			end
			rang = configuration.main_settings.myrank
			inprocess = true
			if hour > 4 and hour < 12 then
				sampSendChat("Доброе утро, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
				wait(cd)
				sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			elseif hour > 11 and hour < 17 then
				sampSendChat("Добрый день, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
				wait(cd)
				sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			elseif hour > 16 and hour < 24 then
				sampSendChat("Добрый вечер, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
				wait(cd)
				sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			elseif hour < 5 then
				sampSendChat("Доброй ночи, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?")
				wait(cd)
				sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			end
			inprocess = false
		else
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		end
	end)
end

function selllic(param)
	lua_thread.create(function()
		sellto, lictype = param:match('(.+) (.+)')
		sellto = tonumber(sellto)
		result, myid = sampGetPlayerIdByCharHandle(playerPed)
		if lictype ~= nil and sellto ~= nil then
			if inprocess ~= true then
				inprocess = true
					if lictype == 'полеты' or lictype == 'полёты' then
						sampSendChat('Получить лицензию на '..lictype..' вы можете в авиашколе г. Лас-Вентурас')
						sampSendChat('/n /gps -> Важные места -> Следующая страница -> [LV] Авиашкола (9)')
					elseif lictype == 'оружие' then
						if cansell == false then
							idd = tostring(sellto)
							result, myid = sampGetPlayerIdByCharHandle(playerPed)
							if sampIsPlayerConnected(sellto) or sellto == myid then
								sampSendChat('Хорошо, для покупки лицензии на оружие покажите мне свою мед.карту')
								sampSendChat('/n /showmc '..myid)
								sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Началось ожидание показа мед.карты, чтобы отменить его введите /cancelmc, чтобы пропустить введите /skip', 0xff6633)
								skiporcancel = false
								choosedname = sampGetPlayerNickname(targettingid)
								tempid = targettingid
							else
								sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Такого игрока нет на сервере', 0xff6633)
							end
						else
							inprocess = true
							sampSendChat('/me {gender:взял|взяла} со стола бланк и заполнил ручкой бланк на получение лицензии на '..lictype)
							wait(cd)
							sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
							wait(cd)
							sampSendChat('/me {gender:распечатал|респечатала} лицензию на '..lictype)
							wait(cd)
							sampSendChat('/me {gender:передал|передала} лицензию человеку напротив')
							sampSendChat('/givelicense '..sellto)
							givelic = true
							cansell = false
						end
					else
						sampSendChat('/me {gender:взял|взяла} со стола бланк и заполнил ручкой бланк на получение лицензии на '..lictype)
						wait(cd)
						sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
						wait(cd)
						sampSendChat('/me {gender:распечатал|респечатала} лицензию на '..lictype)
						wait(cd)
						sampSendChat('/me {gender:передал|передала} лицензию человеку напротив')
						sampSendChat('/givelicense '..sellto)
						givelic = true
					end
				inprocess = false
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			end
		end
	end)
end

function invite(param)
	id = param:match("(%d+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				if id == nil then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/invite [id]', 0xff6633)
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы не можете приглашать в организацию самого себя.', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function uninvite(param)
	local id, withbl = param:match("(%d+) (%d)")
	id = tonumber(id)
	withbl = tonumber(withbl)
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
	uvalid = tonumber(uvalid)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				inprocess = true
				if uvalid == nil or uvalid == '' or reason == nil or reason == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/uninvite [id] [причина]', 0xff6633)
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if uvalid == myid then
						sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы не можете увольнять из организации самого себя.', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function giverank(param)
	local id,rank = param:match("(%d+) (%d)")
	id = tonumber(id)
	rank = tonumber(rank)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				inprocess = true
				if id == nil or id == '' or rank == nil or rank == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/giverank [id] [ранг]', 0xff6633)
				else
					result, myid = sampGetPlayerIdByCharHandle(playerPed)
					if id == myid then
						sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы не можете менять ранг самому себе.', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function blacklist(param)
	local id,reason = param:match("(%d+) (.+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/blacklist [id] [причина]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function unblacklist(param)
	local id = param:match("(%d+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
			inprocess = true
				if id == nil or id == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/unblacklist [id]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function fwarn(param)
	local id,reason = param:match("(%d+) (.+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/fwarn [id] [причина]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function unfwarn(param)
	local id = param:match("(%d+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				inprocess = true
				if id == nil or id == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/unfwarn [id]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function fmute(param)
	local id,mutetime,reason = param:match("(%d+) (%d+) (.+)")
	id = tonumber(id)
	mutetime = tonumber(mutetime)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
			inprocess = true
				if id == nil or id == '' or reason == nil or reason == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/fmute [id] [время] [причина]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function funmute(param)
	local id = param:match("(%d+)")
	id = tonumber(id)
	lua_thread.create(function()
		if configuration.main_settings.myrankint >= 9 then
			if inprocess == true then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
			else
				inprocess = true
				if id == nil or id == '' then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/funmute [id]', 0xff6633)
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
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 9-го ранга.", 0xff6633)
		end
	end)
end

function expel(param)
	local id,reason = param:match("(%d+) (.+)")
		id = tonumber(id)
		lua_thread.create(function()
			if configuration.main_settings.myrankint >= 5 then
				if inprocess == true then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
				else
					inprocess = true
					if id == nil or id == '' or reason == nil or reason == '' then
						sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}/expel [id] [причина]', 0xff6633)
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
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Данная команда доступна с 5-го ранга.", 0xff6633)
			end
		end)
end

function sobes1()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			if configuration.main_settings.useservername then
				result,myid = sampGetPlayerIdByCharHandle(playerPed)
				name = sampGetPlayerNickname(myid)
				rang = configuration.main_settings.myrank
			else
				name = u8:decode(configuration.main_settings.myname)
				if name == '' or name == nil then
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Введите своё имя в /'..cmdhelp..' ', 0xff6633)
					result,myid = sampGetPlayerIdByCharHandle(playerPed)
					name = sampGetPlayerNickname(myid)
				end
				rang = configuration.main_settings.myrank
			end
			sampSendChat("Здравствуйте, вы на собеседование?")
			wait(cd)
			sampSendChat('/do На груди висит бейджик с надписью '..rang..' '..name)
			inprocess = false
		end
	end)
end

function sobes2()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			sampSendChat("Хорошо, для этого покажите мне ваши документы, а именно: паспорт и мед.карту")
			sampSendChat("/n ОБЯЗАТЕЛЬНО по рп!")
			inprocess = false
		end
	end)
end

function sobes3()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			sampSendChat("Расскажите немного о себе.")
			inprocess = false
		end
	end)
end

function sobes4()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			sampSendChat("Почему вы выбрали именно нас?")
			inprocess = false
		end
	end)
end

function sobes5()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			sampSendChat("Работали вы уже в организациях ЦА? Если да, то расскажите подробнее")
			inprocess = false
		end
	end)
end

function sobesaccept1()
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
		inprocess = true
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
		rangint = configuration.main_settings.myrankint
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
		inprocess = true
		if rangint >= 9 then
			sampSendChat("Отлично, я думаю вы нам подходите!")
			wait(cd)
			inprocess = false
			invite(tostring(targettingid))
		else
			sampSendChat("Отлично, я думаю вы нам подходите!")
			wait(cd)
			sampSendChat("/r "..sampGetPlayerNickname(targettingid).." успешно прошёл собеседование! Он ждёт старших около стойки чтобы вы его приняли.")
			wait(cd)
			sampSendChat("/rb ("..targettingid..") id")
		end
		inprocess = false
		end
	end)
end

function sobesdecline(param)
	local reason = param:match("(.+)")
	lua_thread.create(function()
		if inprocess == true then
			sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
		else
			inprocess = true
			if reason ~= "проф. непригодность1" and reason ~= "проф. непригодность3" then
				sampSendChat("/me взяв документы из рук человека напротив {gender:начал|начала} их проверять")
				wait(cd)
				sampSendChat("/todo Очень грустно...* отдавая документы обратно")
				wait(cd)
			end
			if reason == ("наркозависимость") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что в мед. карте сказано, что вы наркозависимый.")
			elseif reason == ("не полностью здоровый") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что в мед. карте сказано, что вы не полностью здоровый.")
			elseif reason == ("не законопослушный") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы слишком незаконопослушный.")
			elseif reason == ("меньше 3 лет в штате") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы не проживаете в штате 3 года.")
			elseif reason == ("игрок в организации") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы уже работаете в другой организации.")
			elseif reason == ("был в деморгане") then
				sampSendChat("К сожалению я не могу принять вас из-за того, что вы лечились в псих больнице, поменяйте мед.карту.")
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
		if tostring(value):find(configuration.BindsName[key]) then
			if configuration.BindsCmd[key] ~= "" then
				sampUnregisterChatCommand(configuration.BindsCmd[key])
				sampRegisterChatCommand(configuration.BindsCmd[key], function()
					lua_thread.create(function()
						if not inprocess then
							for bp in configuration.BindsAction[key]:gmatch('[^~]+') do
								inprocess = true
								sampSendChat(tostring(bp))
								wait(configuration.BindsDelay[key])
								inprocess = false
							end
						else
							sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Не торопитесь, вы уже отыгрываете что-то!", 0xff6633)
						end
					end)
				end)
			end
		end
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
			sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вы не работаете в автошколе, скрипт выгружен!', 0xff6633)
			disableallimgui()
			thisScript():unload()
		end
		getmyrank = false
		return false
	elseif dialogId == 6 and givelic then
		if lictype == "авто" then
			sampSendDialogResponse(6, 1, 0, nil)
		elseif lictype == "мото" then
			sampSendDialogResponse(6, 1, 1, nil)
		elseif lictype == "рыболовство" then
			sampSendDialogResponse(6, 1, 3, nil)
		elseif lictype == "плавание" then
			sampSendDialogResponse(6, 1, 4, nil)
		elseif lictype == "оружие" then
			sampSendDialogResponse(6, 1, 5, nil)
		elseif lictype == "охоту" then
			sampSendDialogResponse(6, 1, 6, nil)
		elseif lictype == "раскопки" then
			sampSendDialogResponse(6, 1, 7, nil)
		end
		givelic = false
		return false
	elseif dialogId == 1234 then
		if text:find('Срок действия') then
			if mcvalue == false then
				if text:find("Имя: "..sampGetPlayerNickname(targettingid)) then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("Полностью здоровый") then
						local statusint = DialogLine:match('{CEAD2A}Наркозависимость: (%d+)')
							if tonumber(statusint) then
								statusint = tonumber(statusint)
								if statusint <= 5 then
									mcvalue = true
									mcverdict = (u8"в порядке")
								else
									mcvalue = true
									mcverdict = (u8"наркозависимость")
								end
							end
						else
							mcvalue = true
							mcverdict = (u8"не полностью здоровый")
						end
					end
				return false
				end
			elseif skiporcancel == false then
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
								sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Человек не полностью здоровый, требуется поменять мед.карту!', 0xff6633)
								sampSendChat("/me взяв мед.карту в руки начал её проверять")
								wait(cd)
								sampSendChat("/do Мед.карта не в норме.")
								wait(cd)
								sampSendChat("/todo К сожалению, в мед.карте написано, что у вас есть явные отклонения. Обновите её в больнице и приходите снова* отдавая мед.карту обратно")
								inprocess = false
								skiporcancel = true
								cansell = false
							end)
						end
				else
					sampAddChatMessage('{ff6633}[ASHelper] {EBEBEB}Вам подкинули мед.карту, ожидание началось заново!', 0xff6633)
					sampSendChat('Я просил не вашу мед.карту. Заберите её!')
				end
			end
		elseif text:find('Серия') then
			if passvalue == false then
				for DialogLine in text:gmatch('[^\r\n]+') do
					if text:find("Имя: {FFD700}"..sampGetPlayerNickname(targettingid)) then
						local job = text:find('{FFFFFF}Организация:')
						if not job then
							for DialogLine in text:gmatch('[^\r\n]+') do
								local passstatusint = DialogLine:match('{FFFFFF}Лет в штате: {FFD700}(%d+)')
								if tonumber(passstatusint) then
									if tonumber(passstatusint) >= 3 then
										for DialogLine in text:gmatch('[^\r\n]+') do
											local zakonstatusint = DialogLine:match('{FFFFFF}Законопослушность: {FFD700}(%d+)')
											if tonumber(zakonstatusint) then
												if tonumber(zakonstatusint) >= 35 then
													local demorgan = text:find('Лечился в Психиатрической больнице')
													if not demorgan then
														local chss = text:find('Состоит в ЧС{FF6200} Инструкторы')
														if not chss then
															passvalue = true
															passverdict = (u8"в порядке")
														else
															passvalue = true
															passverdict = (u8"в чс автошколы")
														end
													else
														passvalue = true
														passverdict = (u8"был в деморгане")
													end
												else
													passvalue = true
													passverdict = (u8"не законопослушный")
												end
											end
										end
									else
										passvalue = true
										passverdict = (u8"меньше 3 лет в штате")
									end
								end
							end
						else
							passvalue = true
							passverdict = (u8"игрок в организации")
						end
					return false
					end
				end
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

function devmaxrank()
	result,myid = sampGetPlayerIdByCharHandle(playerPed)
	if sampGetPlayerNickname(myid) == "Carolos_McCandy" then
		devmaxrankp = not devmaxrankp
		sampAddChatMessage("{ff6633}[Режим разработчика] {FFFFFF}Имитировать максимальный ранг: " ..(devmaxrankp and "{00FF00}Включено" or "{FF0000}Выключено"), 0xff6633)
		if devmaxrankp then
			getmyrank = true
			sampSendChat("/stats")
		else
			getmyrank = true
			sampSendChat("/stats")
		end
	end
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

--Логика записи клавиш от Cosmo: https://www.blast.hk/threads/71224/
function getbindkeys()
	lua_thread.create(function()
		while true do
			if getbindkey then
				wait(0)
				for i, key in ipairs(log) do
					local keyname = vkeys.id_to_name(key)
					bind = keyname
					configuration.main_settings.usefastmenu = keyname
					if inicfg.save(configuration,"AS Helper") then
					end
					getbindkey = false
				end
			elseif setbinderkey then
				wait(0)
				if emptykey1[1] ~= nil and keyname == nil then
					keyname = vkeys.id_to_name(emptykey1[1])
					binderkeystatus = u8"Применить "..keyname
				elseif emptykey2[1] ~= nil and keyname2 == nil then
					keyname2 = vkeys.id_to_name(emptykey2[1])
					if keyname2 == "Shift" or keyname2 == "Alt" or keyname2 == "Ctrl" or keyname2 == "Space" then
						binderkeystatus = keyname2.." + "..keyname
						setbinderkey = false
					else
						binderkeystatus = keyname.." + "..keyname2
						setbinderkey = false
					end
				end
			else
				break
			end
		end
	end)
end

function checkbibl()
	if not facheck then
		sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Отсутствует библиотека fAwesome5. Пытаюсь её установить.", 0xff6633)
		if doesFileExist('moonloader/lib/fAwesome5.lua') then
			os.remove('moonloader/lib/fAwesome5.lua')
		end
		local fawesomelua = io.open('moonloader/lib/fAwesome5.lua','w')
		fawesomelua:close()
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/fAwesome5.lua', 'moonloader/lib/fAwesome5.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/fAwesome5.lua') then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Библиотека fAwesome5 была успешно установлена.", 0xff6633)
					fa = require"fAwesome5"
					fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Произошла ошибка во время установки, обратитесь к разработчику за помощью. JustMini#6291", 0xff6633)
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Отсутствует файл шрифта. Пытаюсь его установить.", 0xff6633)
		createDirectory('moonloader/resource/fonts')
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Файл шрифта был успешно установлен.", 0xff6633)
				else
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Произошла ошибка во время установки, обратитесь к разработчику за помощью. JustMini#6291", 0xff6633)
					thisScript():unload()
				end
			end
		end)
		wait(300)
	end
	if doesFileExist('moonloader/config/updateashelper.ini') then
		os.remove('moonloader/config/updateashelper.ini')
	end
	createDirectory('moonloader/config/')
	updates = io.open('moonloader/config/updateashelper.ini','w')
	io.close(updates)
	downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/update.ini', 'moonloader/config/updateashelper.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/config/updateashelper.ini') then
				updates = io.open('moonloader/config/updateashelper.ini','r')
				local data = {}
				for line in updates:lines() do
					table.insert(data, line)
				end
				io.close(updates)
				if tonumber(data[1]) > scriptvernumb then
					sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Найдено обновление. Пытаюсь установить его.", 0xff6633)
					doupdate = true
				end
				os.remove('moonloader/config/updateashelper.ini')
			else
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Произошла ошибка во время проверки обновлений, обратитесь к разработчику за помощью. JustMini#6291", 0xff6633)
				thisScript():unload()
			end
		end
	end)
	wait(300)
	if doupdate then
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/AS%20Helper.lua', thisScript().path,function(id3, status1)
			if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
				sampAddChatMessage("{ff6633}[ASHelper] {EBEBEB}Обновление успешно установлено.", 0xff6633)
			end
		end)
		wait(300)
	end
	return true
end

function onWindowMessage(msg, wparam, lparam)
    if wparam == 0x1B then -- ESC
    	if imgui_settings.v or imgui_fm.v or imgui_license.v or imgui_expel.v or imgui_uninvite.v or imgui_giverank.v or imgui_blacklist.v or imgui_fwarn.v or imgui_fmute.v or imgui_sobes.v or imgui_cmds.v then
        	consumeWindowMessage(true, false)
        end
	elseif msg == 0x100 or msg == 0x104 then
		if getbindkey then
			if not log[1] then
				table.insert(log, 1, wparam)
			end
		elseif setbinderkey then
			if not emptykey1[1] then
				table.insert(emptykey1, 1, wparam)
			elseif not emptykey2[1] and wparam ~= emptykey1[1] then
				table.insert(emptykey2, 1, wparam)
			end
		end
	end
end

function disableallimgui()
	imgui_settings.v = false
	imgui_fm.v = false
	imgui_license.v = false
	imgui_expel.v = false
	imgui_uninvite.v = false
	imgui_giverank.v = false
	imgui_blacklist.v = false
	imgui_fwarn.v = false
	imgui_fmute.v = false
	imgui_sobes.v = false
	mcvalue = true
	passvalue = true
end