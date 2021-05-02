script_name('AS Helper')
script_description('������� �������� ��� ���������.')
script_author('JustMini')
script_version_number(22)
script_version('2.1')
script_dependencies('imgui; samp events; fontAwesome5')

require "moonloader"
local dlstatus 					= require "moonloader".download_status
local inicfg 					= require "inicfg"
local vkeys 					= require "vkeys"
local imguicheck, imgui 		= pcall(require, "imgui")
local sampevcheck, sampev 		= pcall(require, "lib.samp.events")
local encodingcheck, encoding 	= pcall(require, "encoding")
local facheck, fa 				= pcall(require, "fAwesome5")
local rkeyscheck, rkeys			= pcall(require, "rkeys")

local ScreenX, ScreenY 			= getScreenResolution()

local mcvalue 					= true
local passvalue 				= true
local skiporcancel				= true
local inprocess					= false

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
		klad = 0
	},
	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, "AS Helper")

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then
	return end
	while not isSampAvailable() do
		wait(200)
	end
	local checking = checkbibl()
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
			ASHelperMessage('������ ���� ������������.')
		end
    end
	getmyrank = true
	sampSendChat("/stats")
	ASHelperMessage('AS Helper '..thisScript().version..' ������� ��������. �����: JustMini')
	ASHelperMessage("������� /ash ����� ������� ���������.")
	checkstyle()
	imgui.Process = false
	sampRegisterChatCommand('ash', function()
		windows.imgui_settings.v = false
		windows.imgui_fm.v = false
		windows.imgui_sobes.v = false
		mcvalue = true
		passvalue = true
		windows.imgui_settings.v = not windows.imgui_settings.v
		settingswindow = 0
	end)
	sampRegisterChatCommand("ashbind", function()
		choosedslot = nil
		windows.imgui_binder.v = not windows.imgui_binder.v
	end)
	sampRegisterChatCommand("ashstats", function()
		windows.imgui_stats.v = not windows.imgui_stats.v
		if windows.imgui_stats.v then
			ASHelperMessage("������� ���� �������� �������������� ����.")		
		end
	end)

	sampRegisterChatCommand("uninvite", function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if inprocess then
					ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
				else
					local uvalid,reason = param:match("(%d+) (.+)")
					local uvalid = tonumber(uvalid)
					inprocess = true
					if uvalid == nil or uvalid == '' or reason == nil or reason == '' then
						ASHelperMessage('/uninvite [id] [�������]')
					else
						local result, myid = sampGetPlayerIdByCharHandle(playerPed)
						if uvalid == myid then
							ASHelperMessage('�� �� ������ ��������� �� ����������� ������ ����.')
						else
							lua_thread.create(function()
								sampSendChat("/time")
								sampSendChat('/me {gender:������|�������} ��� �� �������')
								wait(2000)
								sampSendChat('/me {gender:�������|�������} � ������ "����������"')
								wait(2000)
								sampSendChat('/do ������ ������.')
								wait(2000)
								sampSendChat('/me {gender:���|������} �������� � ������ "����������"')
								wait(2000)
								sampSendChat('/me {gender:�����������|�����������} ���������, ����� {gender:��������|���������} ��� � {gender:�������|��������} ��� ������� � ������')
								sampSendChat("/uninvite "..uvalid..' '..reason)
								sampSendChat("/time")
							end)
						end
					end
				inprocess = false
				end
			else
				ASHelperMessage("������ ������� �������� � 9-�� �����.")
			end
		else
			sampSendChat("/uninvite "..param)
		end
	end)

	sampRegisterChatCommand("invite", function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if inprocess then
					ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
				else
					local id = param:match("(%d+)")
					local id = tonumber(id)
					if id == nil then
						ASHelperMessage('/invite [id]')
					else
						local result, myid = sampGetPlayerIdByCharHandle(playerPed)
						if id == myid then
							ASHelperMessage('�� �� ������ ���������� � ����������� ������ ����.')
						else
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do ����� �� �������� � �������.')
								wait(2000)
								sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
								wait(2000)
								sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
								wait(2000)
								sampSendChat('����� ����������! ���������� �� ������.')
								wait(2000)
								sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
								sampSendChat("/invite "..id)
								inprocess = false
							end)
						end
					end
				end
			else
				ASHelperMessage("������ ������� �������� � 9-�� �����.")
			end
		else
			sampSendChat("/invite "..param)
		end
	end)

	sampRegisterChatCommand("giverank", function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if inprocess then
					ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
				else
					local id,rank = param:match("(%d+) (%d)")
					local id = tonumber(id)
					local rank = tonumber(rank)
					inprocess = true
					if id == nil or id == '' or rank == nil or rank == '' then
						ASHelperMessage('/giverank [id] [����]')
					else
						local result, myid = sampGetPlayerIdByCharHandle(playerPed)
						if id == myid then
							ASHelperMessage('�� �� ������ ������ ���� ������ ����.')
						else
							lua_thread.create(function()
								sampSendChat('/me {gender:�������|��������} ���')
								wait(2000)
								sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
								wait(2000)
								sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
								wait(2000)
								sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
								wait(2000)
								sampSendChat('/do ���������� � ���������� ���� ��������.')
								wait(2000)
								sampSendChat('���������� � ����������. ����� ������� �� ������ ����� � ����������.')
								sampSendChat("/giverank "..id.." "..rank)
							end)
						end
					end
					inprocess = false
				end
			else
				ASHelperMessage("������ ������� �������� � 9-�� �����.")
			end
		else
			sampSendChat("/giverank "..param)
		end
	end)

	sampRegisterChatCommand("blacklist", function(param)
		if configuration.main_settings.dorponcmd then
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id,reason = param:match("(%d+) (.+)")
						local id = tonumber(id)
						inprocess = true
						if id == nil or id == '' or reason == nil or reason == '' then
							ASHelperMessage('/blacklist [id] [�������]')
						else
							sampSendChat("/time")
							sampSendChat("/me {gender:������|�������} ��� �� �������")
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
							wait(2000)
							sampSendChat("/me {gender:���|�����} ��� ����������")
							wait(2000)
							sampSendChat('/me {gender:���|������} ���������� � ������ "׸���� ������"')
							wait(2000)
							sampSendChat("/me {gender:�����������|�����������} ���������")
							wait(2000)
							sampSendChat("/do ��������� ���� ���������.")
							sampSendChat("/blacklist "..id.." "..reason)
							sampSendChat("/time")
						end
						inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/blacklist "..param)
		end
	end)

	sampRegisterChatCommand("unblacklist", function(param)
		if configuration.main_settings.dorponcmd then
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id = param:match("(%d+)")
						local id = tonumber(id)
						inprocess = true
						if id == nil or id == '' then
							ASHelperMessage('/unblacklist [id]')
						else
							sampSendChat("/me {gender:������|�������} ��� �� �������")
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
							wait(2000)
							sampSendChat("/me {gender:���|�����} ��� ���������� � �����")
							wait(2000)
							sampSendChat('/me {gender:�����|������} ���������� �� ������� "׸���� ������"')
							wait(2000)
							sampSendChat("/me {gender:�����������|�����������} ���������")
							wait(2000)
							sampSendChat("/do ��������� ���� ���������.")
							sampSendChat("/unblacklist "..id)
						end
						inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/unblacklist "..param)
		end
	end)

	sampRegisterChatCommand("fwarn", function(param)
		if configuration.main_settings.dorponcmd then
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
					local id,reason = param:match("(%d+) (.+)")
					local id = tonumber(id)
					inprocess = true
						if id == nil or id == '' or reason == nil or reason == '' then
							ASHelperMessage('/fwarn [id] [�������]')
						else
							sampSendChat('/me {gender:������|�������} ��� �� �������')
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
							wait(2000)
							sampSendChat('/me {gender:�����|�����} � ������ "��������"')
							wait(2000)
							sampSendChat('/me ����� � ������� ������� ����������, {gender:�������|��������} � ��� ������ ���� �������')
							wait(2000)
							sampSendChat('/do ������� ��� �������� � ������ ���� ����������.')
							wait(2000)
							sampSendChat("/fwarn "..id.." "..reason)
						end
					inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/fwarn "..param)
		end
	end)

	sampRegisterChatCommand("unfwarn", function(param)
		if configuration.main_settings.dorponcmd then	
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id = param:match("(%d+)")
						local id = tonumber(id)
						inprocess = true
						if id == nil or id == '' then
							ASHelperMessage('/unfwarn [id]')
						else
							sampSendChat("/me {gender:������|�������} ��� �� �������")
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
							wait(2000)
							sampSendChat('/me {gender:�����|�����} � ������ "��������"')
							wait(2000)
							sampSendChat("/me ����� � ������� ������� ����������, {gender:�����|������} �� ��� ������� ���� ���� �������")
							wait(2000)
							sampSendChat('/do ������� ��� ����� �� ������� ���� ����������.')
							sampSendChat("/unfwarn "..id)
						end
						inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/unfwarn "..param)
		end
	end)

	sampRegisterChatCommand("fmute", function(param)
		if configuration.main_settings.dorponcmd then
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id,mutetime,reason = param:match("(%d+) (%d+) (.+)")
						local id = tonumber(id)
						local mutetime = tonumber(mutetime)	
						inprocess = true
						if id == nil or id == '' or reason == nil or reason == '' then
							ASHelperMessage('/fmute [id] [�����] [�������]')
						else
							sampSendChat('/me {gender:������|�������} ��� �� �������')
							wait(2000)
							sampSendChat('/me {gender:�������|��������} ���')
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
							wait(2000)
							sampSendChat('/me {gender:������|�������} ������� ����������')
							wait(2000)
							sampSendChat('/me {gender:������|�������} ����� "��������� ����� ����������"')
							wait(2000)
							sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
							sampSendChat("/fmute "..id.." "..mutetime.." "..reason)
						end
						inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/fmute "..param)
		end
	end)

	sampRegisterChatCommand("funmute", function(param)
		if configuration.main_settings.dorponcmd then		
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 9 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id = param:match("(%d+)")
						local id = tonumber(id)
						inprocess = true
						if id == nil or id == '' then
							ASHelperMessage('/funmute [id]')
						else
							sampSendChat('/me {gender:������|�������} ��� �� �������')
							wait(2000)
							sampSendChat('/me {gender:�������|��������} ���')
							wait(2000)
							sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
							wait(2000)
							sampSendChat('/me {gender:������|�������} ������� ����������')
							wait(2000)
							sampSendChat('/me {gender:������|�������} ����� "�������� ����� ����������"')
							wait(2000)
							sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
							sampSendChat("/funmute "..id)
						end
						inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 9-�� �����.")
				end
			end)
		else
			sampSendChat("/funmute "..param)
		end
	end)

	sampRegisterChatCommand("expel", function(param)
		if configuration.main_settings.dorponcmd then
			lua_thread.create(function()
				if configuration.main_settings.myrankint >= 5 then
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						local id,reason = param:match("(%d+) (.+)")
						local id = tonumber(id)
						inprocess = true
						if id == nil or id == '' or reason == nil or reason == '' then
							ASHelperMessage('/expel [id] [�������]')
						else
							if not sampIsPlayerPaused(id) then
								sampSendChat('/do ����� ������� �� �����.')
								wait(2000)
								sampSendChat('/me ���� ����� � �����, {gender:������|�������} ������ �� ���')
								wait(2000)
								sampSendChat('/do ������ ������� ���������� �� �����.')
								sampSendChat("/expel "..id.." "..reason)
							else
								ASHelperMessage("����� ��������� � ���!")
							end
						end
					inprocess = false
					end
				else
					ASHelperMessage("������ ������� �������� � 5-�� �����.")
				end
			end)
		else
			sampSendChat("/expel "..param)
		end
	end)

	sampRegisterChatCommand("devmaxrank", function()
		if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
			devmaxrankp = not devmaxrankp
			sampAddChatMessage("{ff6633}[����� ������������] {FFFFFF}����������� ������������ ����: " ..(devmaxrankp and "{00FF00}��������" or "{FF0000}���������"), 0xff6633)
			getmyrank = true
			sampSendChat("/stats")
		else
			sampAddChatMessage("{ff6347}[������] {FFFFFF}����������� �������! ������� /help ��� ��������� ��������� �������.",0xff6347)
		end
	end)
	sampRegisterChatCommand("goodverdict", function()
		if sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) == "Carolos_McCandy" then
			sampAddChatMessage("{ff6633}[����� ������������] {FFFFFF}�� ����������� ���������� ������� �������� � ���.����� � �������������.", 0xff6633)
			mcvalue = true
			passvalue = true
			mcverdict = ("� �������")
			passverdict = ("� �������")
		else
			sampAddChatMessage("{ff6347}[������] {FFFFFF}����������� �������! ������� /help ��� ��������� ��������� �������.",0xff6347)
		end
	end)
	updatechatcommands()
	updatechatkeys()

	while true do
		if not windows.imgui_settings.v and not windows.imgui_fm.v and not windows.imgui_binder.v and not windows.imgui_sobes.v then
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
							setVirtualKeyDown(0x02,false)
							fastmenuID = targettingid
							local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
							ASHelperMessage("�� ������������ ���� �������� ������� ��: "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").." ["..fastmenuID.."]")
							ASHelperMessage(string.format("������� {%06X}ALT{FFFFFF} ��� ����, ����� ������ ������. {%06X}ESC{FFFFFF} ��� ����, ����� ������� ����.", join_rgb(r, g, b), join_rgb(r, g, b)))
							wait(0)
							windowtype = 0
							windows.imgui_fm.v = true
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
		if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v then
			if not isKeyDown(VK_MENU) then
				imgui.ShowCursor = true
			else
				imgui.ShowCursor = false
			end
			imgui.Process = true
		elseif windows.imgui_stats.v then
			imgui.Process = true
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = false
			imgui.Process = false
		end
		wait(0)
	end
end

function selllic(param)
	lua_thread.create(function()
		sellto, lictype = param:match('(.+) (.+)')
		local sellto = tonumber(sellto)
		if lictype ~= nil and sellto ~= nil then
			if inprocess ~= true then
				inprocess = true
					if lictype == '������' or lictype == '�����' then
						sampSendChat('�������� �������� �� '..lictype..' �� ������ � ��������� �. ���-��������')
						sampSendChat('/n /gps -> ������ ����� -> ��������� �������� -> [LV] ��������� (9)')
					elseif lictype == '������' then
						if not cansell then
							local result, myid = sampGetPlayerIdByCharHandle(playerPed)
							if sampIsPlayerConnected(sellto) or sellto == myid then
								sampSendChat('������, ��� ������� �������� �� ������ �������� ��� ���� ���.�����')
								sampSendChat('/n /showmc '..myid)
								ASHelperMessage('�������� �������� ������ ���.�����.')
								skiporcancel = false
								tempid = fastmenuID
							else
								ASHelperMessage('������ ������ ��� �� �������')
							end
						else
							inprocess = true
							sampSendChat('/me {gender:����|�����} �� ����� ����� � {gender:��������|���������} ������ ����� �� ��������� �������� �� '..lictype)
							wait(2000)
							sampSendChat('/do ������ ��������� ����� ����� �� ��������� �������� ��� ��������.')
							wait(2000)
							sampSendChat('/me ���������� �������� �� '..lictype.." {gender:�������|��������} � �������� ��������")
							givelic = true
							cansell = false
							sampSendChat('/givelicense '..sellto)
						end
					else
						sampSendChat('/me {gender:����|�����} �� ����� ����� � {gender:��������|���������} ������ ����� �� ��������� �������� �� '..lictype)
						wait(2000)
						sampSendChat('/do ������ ��������� ����� ����� �� ��������� �������� ��� ��������.')
						wait(2000)
						sampSendChat('/me ���������� �������� �� '..lictype.." {gender:�������|��������} � �������� ��������")
						givelic = true
						sampSendChat('/givelicense '..sellto)
					end
				inprocess = false
			else
				ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
			end
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
							local temp = 0
							local temp2 = 0
							for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
								temp = temp + 1
							end
							inprocess = true
							for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
								temp2 = temp2 + 1
								sampSendChat(tostring(bp))
								if temp2 ~= temp then
									wait(configuration.BindsDelay[key])
								end
							end
							inprocess = false
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end)
				end)
			end
		end
	end
end

function updatechatkeys()
	if rkeyscheck then
		for key, value in pairs(configuration.BindsName) do
			if tostring(value) == tostring(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= "" then
					if tostring(configuration.BindsKeys[key]):match("(.+) %p (.+)") then
						local fkey = tostring(configuration.BindsKeys[key]):match("(.+) %p")
						local skey = tostring(configuration.BindsKeys[key]):match("%p (.+)")
						rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true), vkeys.name_to_id(skey,true)})
						rkeys.registerHotKey({vkeys.name_to_id(fkey,true), vkeys.name_to_id(skey,true)}, true, function()
							if not inprocess then
								local temp = 0
								local temp2 = 0
								for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
									temp = temp + 1
								end
								inprocess = true
								for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
									temp2 = temp2 + 1
									sampSendChat(tostring(bp))
									if temp2 ~= temp then
										wait(configuration.BindsDelay[key])
									end
								end
								inprocess = false
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end)
					elseif tostring(configuration.BindsKeys[key]):match("(.+)") then
						local fkey = tostring(configuration.BindsKeys[key]):match("(.+)")
						rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true)})
						rkeys.registerHotKey({vkeys.name_to_id(fkey,true)}, true, function()
							if not inprocess then
								local temp = 0
								local temp2 = 0
								for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
									temp = temp + 1
								end
								inprocess = true
								for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
									temp2 = temp2 + 1
									sampSendChat(tostring(bp))
									if temp2 ~= temp then
										wait(configuration.BindsDelay[key])
									end
								end
								inprocess = false
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end)
					end
				end
			end
		end
	end
end

if sampevcheck then
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 6 and givelic then
			if lictype == "����" then
				givelic = false
				sampSendDialogResponse(6, 1, 0, nil)
			elseif lictype == "����" then
				givelic = false
				sampSendDialogResponse(6, 1, 1, nil)
			elseif lictype == "�����������" then
				givelic = false
				sampSendDialogResponse(6, 1, 3, nil)
			elseif lictype == "��������" then
				givelic = false
				sampSendDialogResponse(6, 1, 4, nil)
			elseif lictype == "������" then
				givelic = false
				sampSendDialogResponse(6, 1, 5, nil)
			elseif lictype == "�����" then
				givelic = false
				sampSendDialogResponse(6, 1, 6, nil)
			elseif lictype == "��������" then
				sampSendDialogResponse(6, 1, 7, nil)
				givelic = false
			end
			return false

		elseif dialogId == 235 and getmyrank then
			if text:find('�����������') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('���������: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						local rangint = tonumber(getStatsRank)
						local rang = nameRankStats
						configuration.main_settings.myrank = rang
						configuration.main_settings.myrankint = rangint
						if nameRankStats:find('����������') or devmaxrankp then
							getStatsRank = 10
							configuration.main_settings.myrank = "����������"
							configuration.main_settings.myrankint = 10
						end
						if inicfg.save(configuration,"AS Helper") then
						end
					end
				end
			else
				ASHelperMessage('�� �� ��������� � ���������, ������ ��������!')
				NoErrors = true
				thisScript():unload()
			end
			getmyrank = false
			return false

		elseif dialogId == 1234 then
			if text:find('���� ��������') then
				if not mcvalue then
					if text:find("���: "..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find("��������� ��������") then
							local statusint = DialogLine:match('{CEAD2A}����������������: (%d+)')
								if tonumber(statusint) then
									statusint = tonumber(statusint)
									if statusint <= 5 then
										mcvalue = true
										mcverdict = ("� �������")
									else
										mcvalue = true
										mcverdict = ("����������������")
									end
								end
							else
								mcvalue = true
								mcverdict = ("�� ��������� ��������")
							end
						end
					end
				elseif not skiporcancel then
					if text:find("���: "..sampGetPlayerNickname(tempid)) then
						if text:find("��������� ��������") then
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								inprocess = true
								sampSendChat("/me ���� ���.����� � ���� ����� � ���������")
								wait(2000)
								sampSendChat("/do ���.����� � �����.")
								wait(2000)
								sampSendChat("/todo �� � �������* ������� ���.����� �������")
								wait(2000)
								skiporcancel = true
								cansell = true
								inprocess = false
								selllic(tempid..' ������')
							end)
						else
							lua_thread.create(function()
								inprocess = true
								ASHelperMessage('������� �� ��������� ��������, ��������� �������� ���.�����!')
								sampSendChat("/me ���� ���.����� � ���� ����� � ���������")
								wait(2000)
								sampSendChat("/do ���.����� �� � �����.")
								wait(2000)
								sampSendChat("/todo � ���������, � ���.����� ��������, ��� � ��� ���� ����������.* ������� ���.����� �������")
								wait(2000)
								sampSendChat("�������� � � ��������� �����!")
								skiporcancel = true
								cansell = false
								inprocess = false
							end)
						end
						return false
					end
				end
			elseif text:find('�����') then
				if not passvalue then
					for DialogLine in text:gmatch('[^\r\n]+') do
						if text:find("���: {FFD700}"..sampGetPlayerNickname(fastmenuID)) then
							if not text:find('{FFFFFF}�����������:') then
								for DialogLine in text:gmatch('[^\r\n]+') do
									local passstatusint = DialogLine:match('{FFFFFF}��� � �����: {FFD700}(%d+)')
									if tonumber(passstatusint) then
										if tonumber(passstatusint) >= 3 then
											for DialogLine in text:gmatch('[^\r\n]+') do
												local zakonstatusint = DialogLine:match('{FFFFFF}�����������������: {FFD700}(%d+)')
												if tonumber(zakonstatusint) then
													if tonumber(zakonstatusint) >= 35 then
														if not text:find('������� � ��������������� ��������') then
															if not text:find('������� � ��{FF6200} �����������') then
																if not text:find("Warns") then
																	passvalue = true
																	passverdict = ("� �������")
																else
																	passvalue = true
																	passverdict = ("���� �����")
																end
															else
																passvalue = true
																passverdict = ("� �� ���������")
															end
														else
															passvalue = true
															passverdict = ("��� � ���������")
														end
													else
														passvalue = true
														passverdict = ("�� ���������������")
													end
												end
											end
										else
											passvalue = true
											passverdict = ("������ 3 ��� � �����")
										end
									end
								end
							else
								passvalue = true
								passverdict = ("����� � �����������")
							end
						end
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
			if message:find('�����������: /jobprogress %[ ID ������ %]') then
				ASHelperMessage("�� ����������� ���� ������� ������������.")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ������������� � ����������� ������') then
				ASHelperMessage("�� ��������� ������� ����, �������� ������!")
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' ������������� � ������� ������') then
				ASHelperMessage("�� ������ ������� ����, ������� ������!")
				return false
			end
			if message:find('%[����������%] {FFFFFF}�� �������� ����!') then
				ASHelperMessage('�� �������� ����.')
				return false
			end
		end
		if message == ("�����������: /jobprogress(��� ���������)") and color == -1104335361 then
			sampSendChat("/jobprogress")
			return false
		end
		if message:find('%[R%]') and not message:find('%[����������%]') and color == 766526463 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message}
		end
		if message:find('%[D%]') and color == 865730559 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message }
		end
		if message:find('������� ��') then
			getmyrank = true
			sampSendChat("/stats")
		end
		if message:find("%[����������%] {FFFFFF}�� ������� ������� ��������") then
			local typeddd, toddd = message:match("%[����������%] {FFFFFF}�� ������� ������� �������� �� (.+) ������ (.+).")
			if typeddd == "����" then
				configuration.my_stats.avto = configuration.my_stats.avto + 1
			elseif typeddd == "����" then
				configuration.my_stats.moto = configuration.my_stats.moto + 1
			elseif typeddd == "�������" then
				configuration.my_stats.riba = configuration.my_stats.riba + 1
			elseif typeddd == "��������" then
				configuration.my_stats.lodka = configuration.my_stats.lodka + 1
			elseif typeddd == "������" then
				configuration.my_stats.guns = configuration.my_stats.guns + 1
			elseif typeddd == "�����" then
				configuration.my_stats.hunt = configuration.my_stats.hunt + 1
			elseif typeddd == "��������" then
				configuration.my_stats.klad = configuration.my_stats.klad + 1
			else
				if configuration.main_settings.replacechat then
					ASHelperMessage("�� ������� ������� �������� �� "..typeddd.." ������ "..toddd:gsub("_"," ")..".")
					return false
				end
			end
			if inicfg.save(configuration,"AS Helper") then
				if configuration.main_settings.replacechat then
					ASHelperMessage("�� ������� ������� �������� �� "..typeddd.." ������ "..toddd:gsub("_"," ")..". ��� ���� ��������� � ���� ����������.")
					return false
				end
			end
		end
		if message:find("������������ ������ ����� ����� ����������� (.+), �������� ���������: (.+)") then
			local result,myid = sampGetPlayerIdByCharHandle(playerPed)
			local invited,inviting = message:match("������������ ������ ����� ����� ����������� (.+), �������� ���������: (.+)%[")
			if inviting == sampGetPlayerNickname(myid) then
				if invited == sampGetPlayerNickname(waitingaccept) then
					sampSendChat("/giverank "..waitingaccept.." 2")
					waitingaccept = false
					return {color,message}
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
		--������ ������� Raymond: https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == "q" then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), "������") or string.find(u8:decode(configuration.main_settings.myaccent), "������") then
				return{'['..u8:decode(configuration.main_settings.myaccent)..']: '..message}
			else
				return{'['..u8:decode(configuration.main_settings.myaccent)..' ������]: '..message}
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

function ASHelperMessage(value)
	if imguicheck then
		local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
		sampAddChatMessage("[ASHelper] {EBEBEB}"..value,join_rgb(r, g, b))
	else
		sampAddChatMessage("[ASHelper] {EBEBEB}"..value,0xff6633)
	end
end

if imguicheck and rkeyscheck and facheck then
	function onWindowMessage(msg, wparam, lparam)
		if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v then
			if wparam == VK_ESCAPE and not isPauseMenuActive() then
				consumeWindowMessage(true, false)
				if(msg == 0x101)then
					windows.imgui_settings.v = false
					windows.imgui_fm.v = false
					windows.imgui_sobes.v = false
					mcvalue = true
					passvalue = true
					windows.imgui_binder.v = false
					imgui.ShowCursor = false
				end
			end
			if getbindkey then
				if msg == 0x100 or msg == 0x104 then
					local keyname = vkeys.id_to_name(wparam)
					configuration.main_settings.usefastmenu = keyname
					if inicfg.save(configuration,"AS Helper") then
					end
					getbindkey = false
				end
			elseif getscreenkey then
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
			elseif setbinderkey then
				if msg == 0x100 or msg == 0x104 then
					if not keyname then
						keyname = vkeys.id_to_name(wparam)
						binderkeystatus = u8"��������� "..keyname
					elseif not keyname2 and vkeys.id_to_name(wparam) ~= keyname then
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
	end

	function rkeys.onHotKey(id, data)	
		if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then
			return false
		end
	end
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function join_rgb(rr, gg, bb)
	return bit.bor(bit.bor(bb, bit.lshift(gg, 8)), bit.lshift(rr, 16))
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
		if marker ~= nil then
			removeBlip(marker)
		end
        if inicfg.save(configuration, 'AS Helper.ini') then 
        end
		if NoErrors then
			return false
		end
    	sampShowDialog(1313, "{ff6633}[AS Helper]{ffffff} ������ ��� �������� ��� �� ����.", [[
{ffffff}                                                                             ��� ������ � ����� �������?{f51111}

���� �� �������������� ������������� ������, �� ������ ������� ��� ���������� ����.
� ���� ������, ��� ������ ����������� ������������ ������ ������� ���������� ������ CTRL + R.
���� �� ��� �� �������, �� ������� ��������� ������.{ff6633}

1. �������� � ��� ����������� ������ LUA ����� � �������, ����������� ������� ��.

2. �������� �� �� ������������ ��������� ����������, � ������:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26

3. ���� ������ ������ �� ���� �����, ����������� ������� ��������� ��������:
- � ����� moonloader > config > ������� ���� AS Helper.ini

4. ���� ������ �� ������������������ �� ��������� ������, �� ������� ���������� ������ �� ������ ������.

5. ���� � ��� ������ �������� �� ������� �� �����-�� ������, �� ������ ��������� (JustMini#6291) ��� ������.]], "��", nil, 0)
	end
end

--��������� ������� Bank Helper �� Cosmo. ������ ���� ����� ���������� ����.
if imguicheck and encodingcheck and facheck then
	u8 									= encoding.UTF8
	encoding.default 					= 'CP1251'

	local bindersettings = {
		binderbuff 						= imgui.ImBuffer(4096),
		bindername 						= imgui.ImBuffer(40),
		binderdelay 					= imgui.ImBuffer(7),
		bindertype 						= imgui.ImInt(0),
		bindercmd 						= imgui.ImBuffer(15)
	}

	windows = {
		imgui_settings 					= imgui.ImBool(false),
		imgui_fm 						= imgui.ImBool(false),
		imgui_sobes						= imgui.ImBool(false),
		imgui_binder 					= imgui.ImBool(false),
		imgui_stats						= imgui.ImBool(false)
	}

	local ComboBox_select 				= imgui.ImInt(0)

	RChatColor 							= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
	DChatColor 							= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
	ASChatColor 						= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
	
	gender 								= imgui.ImInt(configuration.main_settings.gender)

	local uninvitebuf 					= imgui.ImBuffer(256)
	local blacklistbuf 					= imgui.ImBuffer(256)
	local uninvitebox 					= imgui.ImBool(false)

	local blacklistbuff 				= imgui.ImBuffer(256)

	local fwarnbuff 					= imgui.ImBuffer(256)
	local fmutebuff 					= imgui.ImBuffer(256)
	local fmuteint 						= imgui.ImInt(0)

	local Ranks_select 					= imgui.ImInt(0)

	local sobesdecline_select 			= imgui.ImInt(0)
	local lastsobesetap

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

	function checkstyle()
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

	local LockedButton = function(text, size)
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		imgui.Button(text, size)
		imgui.PopStyleColor(4)
	end

	local CenterTextColoredRGB = function(text)
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

	local imgui_Hint = function(text, delay, action)
		if imgui.IsItemHovered() then
			if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
			local alpha = (os.clock() - go_hint) * 5
			if os.clock() >= go_hint then
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
				imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
					imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.80))
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(450)
						imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(fa.ICON_FA_INFO_CIRCLE..u8' ���������:').x / 2 )
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_FA_INFO_CIRCLE..u8' ���������')
						CenterTextColoredRGB("{FFFFFF}"..text)
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

	function imgui.OnDrawFrame()
		if windows.imgui_fm.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"���� �������� ������� ["..fastmenuID.."]", _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			local SomeFunc = function(bool, name, wide)
				local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetRGBA()
				local hex = string.format('%06X', bit.band(join_argb(a, b, g, r), 0xFFFFFF))
				local button = imgui.InvisibleButton(name, imgui.ImVec2(wide, 0))
				imgui.SetCursorPosY(39)
				return button
			end
			local Empty = {"","","","","","","","","","","","","","","","","","","",""}
			for number, Nil in pairs(Empty) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 0) / 2)
				SomeFunc(settingswindow == number, Nil, 0)
			end
			if not sampIsPlayerConnected(actionId) then
	        	windows.imgui_fm.v = false
	        	ASHelperMessage("�����, � ������� �� ����������������� ����� �� ����!")
	        end
			local fastmenu = {
				[0] = function()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' ���������������� ������', imgui.ImVec2(285,30)) then
							if not inprocess then
								if configuration.main_settings.myrankint >= 1 then
									lua_thread.create(function()
										getmyrank = true
										sampSendChat("/stats")
										local name
										local hour = tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60))
										if configuration.main_settings.useservername then
											local result,myid = sampGetPlayerIdByCharHandle(playerPed)
											name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
										else
											name = u8:decode(usersettings.myname.v)
											if name == '' or name == nil then
												ASHelperMessage('������� ��� ��� � /ash')
												local result,myid = sampGetPlayerIdByCharHandle(playerPed)
												name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
											end
										end
										local rang = configuration.main_settings.myrank
										inprocess = true
										if hour > 4 and hour < 13 then
											sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
										elseif hour > 12 and hour < 17 then
											sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
										elseif hour > 16 and hour < 24 then
											sampSendChat("������ �����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
										elseif hour < 5 then
											sampSendChat("������ ����, � {gender:���������|����������} ��������� �. ���-������, ��� ���� ��� ������?")
										end
										wait(2000)
										sampSendChat('/do �� ����� ����� ������� � �������� '..rang..' '..name..".")
										inprocess = false
									end)
								else
									ASHelperMessage("������ ������� �������� � 1-�� �����.")
								end
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_FILE_ALT..u8' �������� ����� ����', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 1  then
								--���������� �������� ���� �� ����� �� Royan_Millans: https://www.blast.hk/threads/39380/
								function separator(text)
									local comma_value = function(n)
										local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
										return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
									end
									
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
								lua_thread.create(function()
									inprocess = true
									sampSendChat('/do � ������� ���� ����� ����� ���� �� ��������.')
									wait(2000)
									sampSendChat('/me {gender:������|�������} ����� ���� �� ������� ���� � ������� ��� �������')
									wait(2000)
									sampSendChat('/do � ����� ����� ��������:')
									wait(2000)
									sampSendChat('/do �������� �� �������� ����������� - '..separator(tostring(configuration.main_settings.avtoprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� �������� ���������� - '..separator(tostring(configuration.main_settings.motoprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� ����������� - '..separator(tostring(configuration.main_settings.ribaprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� ������ ��������� - '..separator(tostring(configuration.main_settings.lodkaprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� ������ - '..separator(tostring(configuration.main_settings.gunaprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� ����� - '..separator(tostring(configuration.main_settings.huntprice)..'$.'))
									wait(2000)
									sampSendChat('/do �������� �� �������� - '..separator(tostring(configuration.main_settings.kladprice)..'$.'))
									inprocess = false
								end)
							else
								ASHelperMessage("������ ������� �������� � 1-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' ������� �������� ������', imgui.ImVec2(285,30)) then
						if configuration.main_settings.myrankint >= 3 then
							imgui.SetScrollY(0)
							ComboBox_select.v = 0
							windowtype = 1
						else
							ASHelperMessage("������ ������� �������� � 3-�� �����.")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_REPLY..u8' ������� �� ���������', imgui.ImVec2(285,30)) then
						if configuration.main_settings.myrankint >= 5 then
							if not inprocess then
								local expel = function(param)
									lua_thread.create(function()
										if configuration.main_settings.myrankint >= 5 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
												local id,reason = param:match("(%d+) (.+)")
												local id = tonumber(id)
												inprocess = true
												if id == nil or id == '' or reason == nil or reason == '' then
													ASHelperMessage('/expel [id] [�������]')
												else
													if not sampIsPlayerPaused(id) then
														windows.imgui_settings.v = false
														windows.imgui_fm.v = false
														windows.imgui_sobes.v = false
														mcvalue = true
														passvalue = true
														sampSendChat('/do ����� ������� �� �����.')
														wait(2000)
														sampSendChat('/me ���� ����� � �����, {gender:������|�������} ������ �� ���')
														wait(2000)
														sampSendChat('/do ������ ������� ���������� �� �����.')
														sampSendChat("/expel "..id.." "..reason)
													else
														ASHelperMessage("����� ��������� � ���!")
													end
												end
											inprocess = false
											end
										else
											ASHelperMessage("������ ������� �������� � 5-�� �����.")
										end
									end)
								end
								expel(tostring(fastmenuID).." �.�.�.")
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						else
							ASHelperMessage("������ ������� �������� � 5-�� �����.")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.Button(fa.ICON_FA_USER_PLUS..u8' ������� � �����������', imgui.ImVec2(285,30))
					if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
						if imgui.IsItemHovered() then
							if not inprocess then
								if configuration.main_settings.myrankint >= 9 then
									if imgui.IsMouseReleased(0) then
										local invite = function(param)
											lua_thread.create(function()
												if configuration.main_settings.myrankint >= 9 then
													if inprocess then
														ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
													else
														local id = param:match("(%d+)")
														local id = tonumber(id)
														if id == nil then
															ASHelperMessage('/invite [id]')
														else
															local result, myid = sampGetPlayerIdByCharHandle(playerPed)
															if id == myid then
																ASHelperMessage('�� �� ������ ���������� � ����������� ������ ����.')
															else
																inprocess = true
																sampSendChat('/do ����� �� �������� � �������.')
																wait(2000)
																sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
																wait(2000)
																sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
																wait(2000)
																sampSendChat('����� ����������! ���������� �� ������.')
																wait(2000)
																sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
																sampSendChat("/invite "..id)
																inprocess = false
															end
														end
													end
												else
													ASHelperMessage("������ ������� �������� � 9-�� �����.")
												end
											end)
										end
										windows.imgui_settings.v = false
										windows.imgui_fm.v = false
										windows.imgui_sobes.v = false
										mcvalue = true
										passvalue = true
										invite(tostring(fastmenuID))
									end
									if imgui.IsMouseReleased(1) then
										local invitetorank = function(param)
											if not inprocess then
												if configuration.main_settings.myrankint >= 9 then
													local id = param:match("(%d+)")
													local id = tonumber(id)
													lua_thread.create(function()
														inprocess = true
														sampSendChat('/do ����� �� �������� � �������.')
														wait(2000)
														sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
														wait(2000)
														sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
														wait(2000)
														sampSendChat('����� ����������! ���������� �� ������.')
														wait(2000)
														sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
														sampSendChat("/invite "..id)
														waitingaccept = id
														inprocess = false
													end)
												else
													ASHelperMessage("������ ������� �������� � 9-�� �����.")
												end
											else
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											end
										end
										windows.imgui_settings.v = false
										windows.imgui_fm.v = false
										windows.imgui_sobes.v = false
										mcvalue = true
										passvalue = true
										invitetorank(tostring(fastmenuID))
									end
								else
									ASHelperMessage("������ ������� �������� � 9-�� �����.")
								end
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end
					end
					imgui_Hint("��� ��� �������� �������� � �����������\n{FFFFFF}��� ��� �������� �� ��������� ������������",0)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_USER_MINUS..u8' ������� �� �����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								windowtype = 3
								uninvitebuf.v = ""
								blacklistbuf.v = ""
								uninvitebox.v = false
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' �������� ���������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								Ranks_select.v = 0
								windowtype = 4
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_USER_SLASH..u8' ������� � ������ ������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								windowtype = 5
								blacklistbuff.v = ""
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_USER..u8' ������ �� ������� ������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								local unblacklist = function(param)
									lua_thread.create(function()
										if configuration.main_settings.myrankint >= 9 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
												local id = param:match("(%d+)")
												local id = tonumber(id)
												inprocess = true
												if id == nil or id == '' then
													ASHelperMessage('/unblacklist [id]')
												else
													sampSendChat("/me {gender:������|�������} ��� �� �������")
													wait(2000)
													sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
													wait(2000)
													sampSendChat("/me {gender:���|�����} ��� ���������� � �����")
													wait(2000)
													sampSendChat('/me {gender:�����|������} ���������� �� ������� "׸���� ������"')
													wait(2000)
													sampSendChat("/me {gender:�����������|�����������} ���������")
													wait(2000)
													sampSendChat("/do ��������� ���� ���������.")
													sampSendChat("/unblacklist "..id)
												end
												inprocess = false
											end
										else
											ASHelperMessage("������ ������� �������� � 9-�� �����.")
										end
									end)
								end
								unblacklist(tostring(fastmenuID))
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_FROWN..u8' ������ ������� ����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								fwarnbuff.v = ""
								windowtype = 6
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_SMILE..u8' ����� ������� ����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								local unfwarn = function(param)
									lua_thread.create(function()
										if configuration.main_settings.myrankint >= 9 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
												local id = param:match("(%d+)")
												local id = tonumber(id)
												inprocess = true
												if id == nil or id == '' then
													ASHelperMessage('/unfwarn [id]')
												else
													sampSendChat("/me {gender:������|�������} ��� �� �������")
													wait(2000)
													sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
													wait(2000)
													sampSendChat('/me {gender:�����|�����} � ������ "��������"')
													wait(2000)
													sampSendChat("/me ����� � ������� ������� ����������, {gender:�����|������} �� ��� ������� ���� ���� �������")
													wait(2000)
													sampSendChat('/do ������� ��� ����� �� ������� ���� ����������.')
													sampSendChat("/unfwarn "..id)
												end
												inprocess = false
											end
										else
											ASHelperMessage("������ ������� �������� � 9-�� �����.")
										end
									end)
								end
								unfwarn(tostring(fastmenuID))
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' ������ ��� ����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								imgui.SetScrollY(0)
								fmutebuff.v = ""
								fmuteint.v = 0
								windowtype = 7
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' ����� ��� ����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								local funmute = function(param)
									lua_thread.create(function()
										if configuration.main_settings.myrankint >= 9 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
												local id = param:match("(%d+)")
												local id = tonumber(id)
												inprocess = true
												if id == nil or id == '' then
													ASHelperMessage('/funmute [id]')
												else
													sampSendChat('/me {gender:������|�������} ��� �� �������')
													wait(2000)
													sampSendChat('/me {gender:�������|��������} ���')
													wait(2000)
													sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
													wait(2000)
													sampSendChat('/me {gender:������|�������} ������� ����������')
													wait(2000)
													sampSendChat('/me {gender:������|�������} ����� "�������� ����� ����������"')
													wait(2000)
													sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
													sampSendChat("/funmute "..id)
												end
												inprocess = false
											end
										else
											ASHelperMessage("������ ������� �������� � 9-�� �����.")
										end
									end)
								end
								funmute(tostring(fastmenuID))
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							else
								ASHelperMessage("������ ������� �������� � 9-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.Separator()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'�������� ������ '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
						if not inprocess then
							if configuration.main_settings.myrankint >= 5 then
								imgui.SetScrollY(0)
								windowtype = 8
							else
								ASHelperMessage("������ �������� �������� � 5-�� �����.")
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������������� '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
							if not inprocess then
								if configuration.main_settings.myrankint >= 5 then
									imgui.SetScrollY(0)
									passvalue = false
									mcvalue = false
									passverdict = ""
									mcverdict = ""
									sobesetap = 0
									sobesdecline_select.v = 0
									windows.imgui_fm.v = false
									windows.imgui_sobes.v = true
								else
									ASHelperMessage("������ �������� �������� � 5-�� �����.")
								end
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
					end
				end,
			
				[1] = function()
					local ComboBox_arr = {u8"����",u8"����",u8"�����������",u8"��������",u8"������",u8"�����",u8"��������"}
					imgui.Text(u8"��������: ", imgui.ImVec2(75,30))
					imgui.SameLine()
					imgui.Combo(' ', ComboBox_select, ComboBox_arr, #ComboBox_arr)
					imgui.NewLine()
					if ComboBox_select.v == 0 then
						whichlic = "����"
					elseif ComboBox_select.v == 1 then
						whichlic = "����"
					elseif ComboBox_select.v == 2 then
						whichlic = "�����������"
					elseif ComboBox_select.v == 3 then
						whichlic = "��������"
					elseif ComboBox_select.v == 4 then
						whichlic = "������"
					elseif ComboBox_select.v == 5 then
						whichlic = "�����"
					elseif ComboBox_select.v == 6 then
						whichlic = "��������"
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������� �������� �� '..u8(whichlic), imgui.ImVec2(285,30)) then
						if not inprocess then
							selllic(tostring(fastmenuID.." "..whichlic))
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'�������� �� �����', imgui.ImVec2(285,30)) then
						if not inprocess then
							selllic(tostring(fastmenuID).." �����")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				[3] = function()
					local uninvite = function(param)
						local id, withbl,unreas, blreas = param:match("(%d+) (%d) (.+) (.+)")
						unreas = (u8:decode(unreas):gsub("_"," "))
						blreas = (u8:decode(blreas):gsub("_"," "))
						local id = tonumber(id)
						local withbl = tonumber(withbl)
						lua_thread.create(function()
							inprocess = true
							if withbl == 0 then
								sampSendChat("/time")
								sampSendChat('/me {gender:������|�������} ��� �� �������')
								wait(2000)
								sampSendChat('/me {gender:�������|�������} � ������ "����������"')
								wait(2000)
								sampSendChat('/do ������ ������.')
								wait(2000)
								sampSendChat('/me {gender:���|������} �������� � ������ "����������"')
								wait(2000)
								sampSendChat('/me {gender:�����������|�����������} ���������, ����� {gender:��������|���������} ��� � {gender:�������|��������} ��� ������� � ������')
								wait(2000)
								sampSendChat("/uninvite "..id..' '..unreas)
								sampSendChat("/time")
							elseif withbl == 1 then
								sampSendChat("/time")
								sampSendChat('/me {gender:������|�������} ��� �� �������')
								wait(2000)
								sampSendChat('/me {gender:�������|�������} � ������ "����������"')
								wait(2000)
								sampSendChat('/do ������ ������.')
								wait(2000)
								sampSendChat('/me {gender:���|������} �������� � ������ "����������"')
								wait(2000)
								sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
								wait(2000)
								sampSendChat('/me {gender:����|�������} ���������� � ������, ����� ���� {gender:����������|�����������} ���������')
								wait(2000)
								sampSendChat('/do ��������� ���� ���������.')
								wait(2000)
								sampSendChat("/uninvite "..id..' '..unreas)
								wait(100)
								sampSendChat("/blacklist "..id..' '..blreas)
								sampSendChat("/time")
							end
							inprocess = false
						end)
					end
					CenterTextColoredRGB("������� ����������:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
					imgui.InputText(u8"    ", uninvitebuf)
					if uninvitebox.v then
						CenterTextColoredRGB("������� ��:")
						imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
						imgui.InputText(u8" ", blacklistbuf)
					end
					imgui.Checkbox(u8"������� � ��", uninvitebox)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if uninvitebuf.v == nil or uninvitebuf.v == '' then
							ASHelperMessage("������� ������� ����������!")
						else
							if uninvitebox.v then
								if blacklistbuf.v == nil or blacklistbuf.v == '' then
									ASHelperMessage("������� ������� ��������� � ��!")
								else
									uninvite(fastmenuID.." 1 "..uninvitebuf.v:gsub(" ","_").." "..blacklistbuf.v:gsub(" ","_"))
									windows.imgui_settings.v = false
									windows.imgui_fm.v = false
									windows.imgui_sobes.v = false
									mcvalue = true
									passvalue = true
								end
							else
								uninvite(fastmenuID.." 0 "..uninvitebuf.v:gsub(" ","_").." 0")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							end
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				[4] = function()
					local Ranks_arr = {u8"[1] �����",u8"[2] �����������",u8"[3] �������",u8"[4] ��. ����������",u8"[5] ����������",u8"[6] ��������",u8"[7] ��. ��������",u8"[8] �������� ���������",u8"[9] ��������"}
					imgui.PushItemWidth(270)
					imgui.Combo(' ', Ranks_select, Ranks_arr, #Ranks_arr)
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
					if imgui.Button(u8'�������� ���������� '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
						local giverank = function(param)
							lua_thread.create(function()
								if configuration.main_settings.myrankint >= 9 then
									if inprocess then
										ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
									else
										local id,rank = param:match("(%d+) (%d)")
										local id = tonumber(id)
										local rank = tonumber(rank)
										inprocess = true
										if id == nil or id == '' or rank == nil or rank == '' then
											ASHelperMessage('/giverank [id] [����]')
										else
											local result, myid = sampGetPlayerIdByCharHandle(playerPed)
											if id == myid then
												ASHelperMessage('�� �� ������ ������ ���� ������ ����.')
											else
												sampSendChat('/me {gender:�������|��������} ���')
												wait(2000)
												sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
												wait(2000)
												sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
												wait(2000)
												sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
												wait(2000)
												sampSendChat('/do ���������� � ���������� ���� ��������.')
												wait(2000)
												sampSendChat('���������� � ����������. ����� ������� �� ������ ����� � ����������.')
												sampSendChat("/giverank "..id.." "..rank)
											end
										end
									inprocess = false
									end
								else
									ASHelperMessage("������ ������� �������� � 9-�� �����.")
								end
							end)
						end
						giverank(fastmenuID.." "..(Ranks_select.v+1))
						windows.imgui_settings.v = false
						windows.imgui_fm.v = false
						windows.imgui_sobes.v = false
						mcvalue = true
						passvalue = true
					end
					imgui.PopStyleColor(3)
					if imgui.Button(u8'�������� ���������� '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
						local giverankdown = function(param)
							lua_thread.create(function()
								if configuration.main_settings.myrankint >= 9 then
									if inprocess then
										ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
									else
										local id,rank = param:match("(%d+) (%d)")
										local id = tonumber(id)
										local rank = tonumber(rank)
										inprocess = true
										if id == nil or id == '' or rank == nil or rank == '' then
											ASHelperMessage('/giverank [id] [����]')
										else
											local result, myid = sampGetPlayerIdByCharHandle(playerPed)
											if id == myid then
												ASHelperMessage('�� �� ������ ������ ���� ������ ����.')
											else
												sampSendChat('/me {gender:�������|��������} ���')
												wait(2000)
												sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
												wait(2000)
												sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
												wait(2000)
												sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
												wait(2000)
												sampSendChat('/do ���������� � ���������� ���� ��������.')
												sampSendChat("/giverank "..id.." "..rank)
											end
										end
									inprocess = false
									end
								else
									ASHelperMessage("������ ������� �������� � 9-�� �����.")
								end
							end)
						end
						windows.imgui_settings.v = false
						windows.imgui_fm.v = false
						windows.imgui_sobes.v = false
						mcvalue = true
						passvalue = true
						giverankdown(fastmenuID.." "..(Ranks_select.v+1))
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				[5] = function()
					CenterTextColoredRGB("������� ��������� � ��:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
					imgui.InputText(u8"                   ", blacklistbuff)
					imgui.NewLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������� � �� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if blacklistbuff.v == nil or blacklistbuff.v == '' then
							ASHelperMessage("������� ������� ��������� � ��!")
						else
							local blacklist = function(param)
								lua_thread.create(function()
									if configuration.main_settings.myrankint >= 9 then
										if inprocess then
											ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
										else
											local id,reason = param:match("(%d+) (.+)")
											local id = tonumber(id)
											inprocess = true
											if id == nil or id == '' or reason == nil or reason == '' then
												ASHelperMessage('/blacklist [id] [�������]')
											else
												sampSendChat("/time")
												sampSendChat("/me {gender:������|�������} ��� �� �������")
												wait(2000)
												sampSendChat('/me {gender:�������|�������} � ������ "׸���� ������"')
												wait(2000)
												sampSendChat("/me {gender:���|�����} ��� ����������")
												wait(2000)
												sampSendChat('/me {gender:���|������} ���������� � ������ "׸���� ������"')
												wait(2000)
												sampSendChat("/me {gender:�����������|�����������} ���������")
												wait(2000)
												sampSendChat("/do ��������� ���� ���������.")
												sampSendChat("/blacklist "..id.." "..reason)
												sampSendChat("/time")
											end
											inprocess = false
										end
									else
										ASHelperMessage("������ ������� �������� � 9-�� �����.")
									end
								end)
							end
							blacklist(fastmenuID.." "..u8:decode(blacklistbuff.v))
							windows.imgui_settings.v = false
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = false
							mcvalue = true
							passvalue = true
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				
				[6] = function()	
					CenterTextColoredRGB("������� ��������:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"   ").x) / 5.7)
					imgui.InputText(u8"   ", fwarnbuff)
					imgui.NewLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������ ������� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
						if fwarnbuff.v == nil or fwarnbuff.v == '' then
							ASHelperMessage("������� ������� ������ ��������!")
						else
							local fwarn = function(param)								
								lua_thread.create(function()
									if configuration.main_settings.myrankint >= 9 then
										if inprocess then
											ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
										else
										local id,reason = param:match("(%d+) (.+)")
										local id = tonumber(id)
										inprocess = true
											if id == nil or id == '' or reason == nil or reason == '' then
												ASHelperMessage('/fwarn [id] [�������]')
											else
												sampSendChat('/me {gender:������|�������} ��� �� �������')
												wait(2000)
												sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
												wait(2000)
												sampSendChat('/me {gender:�����|�����} � ������ "��������"')
												wait(2000)
												sampSendChat('/me ����� � ������� ������� ����������, {gender:�������|��������} � ��� ������ ���� �������')
												wait(2000)
												sampSendChat('/do ������� ��� �������� � ������ ���� ����������.')
												wait(2000)
												sampSendChat("/fwarn "..id.." "..reason)
											end
											inprocess = false
										end
									else
										ASHelperMessage("������ ������� �������� � 9-�� �����.")
									end
								end)
							end
							fwarn(fastmenuID.." "..u8:decode(fwarnbuff.v))
							windows.imgui_settings.v = false
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = false
							mcvalue = true
							passvalue = true
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				[7] = function()
					CenterTextColoredRGB("������� ����:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"").x) / 5.7)
					imgui.InputText(u8"         ", fmutebuff)
					CenterTextColoredRGB("����� ����:")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8" ").x) / 5.7)
					imgui.InputInt(u8" ", fmuteint)
					imgui.NewLine()
					if imgui.Button(u8'������ ��� '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
						if fmutebuff.v == nil or fmutebuff.v == '' then
							ASHelperMessage("������� ������� ������ ����!")
						else
							if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find("-") then
								ASHelperMessage("������� ���������� ����� ����!")
							else
								local fmute = function(param)
									lua_thread.create(function()
										if configuration.main_settings.myrankint >= 9 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
											local id,mutetime,reason = param:match("(%d+) (%d+) (.+)")
											local id = tonumber(id)
											local mutetime = tonumber(mutetime)
											inprocess = true
												if id == nil or id == '' or reason == nil or reason == '' then
													ASHelperMessage('/fmute [id] [�����] [�������]')
												else
													sampSendChat('/me {gender:������|�������} ��� �� �������')
													wait(2000)
													sampSendChat('/me {gender:�������|��������} ���')
													wait(2000)
													sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������ ���������"')
													wait(2000)
													sampSendChat('/me {gender:������|�������} ������� ����������')
													wait(2000)
													sampSendChat('/me {gender:������|�������} ����� "��������� ����� ����������"')
													wait(2000)
													sampSendChat('/me {gender:�����|������} �� ������ "��������� ���������"')
													sampSendChat("/fmute "..id.." "..mutetime.." "..reason)
												end
											inprocess = false
											end
										else
											ASHelperMessage("������ ������� �������� � 9-�� �����.")
										end
									end)
								end
								fmute(fastmenuID.." "..u8:decode(fmuteint.v).." "..u8:decode(fmutebuff.v))
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							end
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end,
				[8] = function()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������� ����� � ������ ���', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: 09:00 - 19:00")
							sampSendChat("�������� ����� ������� ����� � ������ ���.")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������� ����� � �������� ���', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: 10:00 - 18:00")
							sampSendChat("�������� ����� ������� ����� � �������� ���.")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������ ������ ������� ��� �������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: �������")
							sampSendChat("����� ��������� �������� ��������� �� ������ ������� ������ ������ �������?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������������� ����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: (3+) ������� - ����, (4+) ��.���������� - ����, (8+) ���. ��������� - �������")
							sampSendChat("� ����� ��������� ��������� ����� ����������, ��������� � �������?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'��������� ��� �������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: (5+) ����������")
							sampSendChat("�������, � ����� ��������� ��������� ����� ������?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'����� ��� ��� ���������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: 5 ����� �����������, �� ���� ��������� �������.")
							sampSendChat("����������� ���������� ����� ��� ��� ����������?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'��� ����� ������������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: c����������� - ��� ������� ������� ����� ������������, ������� �� ���������.")
							sampSendChat("��� �� ������ ������ �������� ����� '������������'?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'��������� � ������ �����������', imgui.ImVec2(285,30)) then
						if not inprocess then
							ASHelperMessage("���������: �� ���������, �� �����, '���' � '�������'.")
							sampSendChat("����� ������, ����� ��������� ����������� � ������ ����������� ���������?")
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.NewLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
					imgui.Button(u8'��������', imgui.ImVec2(137,35))
					if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
						if imgui.IsItemHovered() then
							if not inprocess then
								if imgui.IsMouseReleased(0) then
									windows.imgui_settings.v = false
									windows.imgui_fm.v = false
									windows.imgui_sobes.v = false
									mcvalue = true
									passvalue = true
									sampSendChat("����������, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", �� ����� �����!")
								end
								if imgui.IsMouseReleased(1) then
									if configuration.main_settings.myrankint >= 9 then
										local giverank = function(param)
											lua_thread.create(function()
												if configuration.main_settings.myrankint >= 9 then
													if inprocess then
														ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
													else
														local id,rank = param:match("(%d+) (%d)")
														local id = tonumber(id)
														local rank = tonumber(rank)
														inprocess = true
														if id == nil or id == '' or rank == nil or rank == '' then
															ASHelperMessage('/giverank [id] [����]')
														else
															local result, myid = sampGetPlayerIdByCharHandle(playerPed)
															if id == myid then
																ASHelperMessage('�� �� ������ ������ ���� ������ ����.')
															else
																sampSendChat('/me {gender:�������|��������} ���')
																wait(2000)
																sampSendChat('/me {gender:�������|�������} � ������ "���������� ������������"')
																wait(2000)
																sampSendChat('/me {gender:������|�������} � ������� ������� ����������')
																wait(2000)
																sampSendChat('/me {gender:�������|��������} ���������� � ��������� ����������, ����� ���� {gender:�����������|�����������} ���������')
																wait(2000)
																sampSendChat('/do ���������� � ���������� ���� ��������.')
																wait(2000)
																sampSendChat('���������� � ����������. ����� ������� �� ������ ����� � ����������.')
																sampSendChat("/giverank "..id.." "..rank)
															end
														end
													inprocess = false
													end
												else
													ASHelperMessage("������ ������� �������� � 9-�� �����.")
												end
											end)
										end
										lua_thread.create(function()
											windows.imgui_settings.v = false
											windows.imgui_fm.v = false
											windows.imgui_sobes.v = false
											mcvalue = true
											passvalue = true
											sampSendChat("����������, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", �� ����� �����!")
											giverank(tostring(fastmenuID).." 2")
										end)
									else
										ASHelperMessage("������ ������� �������� � 9-�� �����.")
									end
								end
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end
					end
					imgui_Hint("��� ��� �������������� � ����� ������\n{FFFFFF}��� ��� ��������� �� ������������",0)
					imgui.PopStyleColor(2)
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
					if imgui.Button(u8'��������', imgui.ImVec2(137,35)) then
						if not inprocess then
							sampSendChat("����� ����, "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ")..", �� �� �� ������ ����� �����. �������� � ��������� � ��������� ���.")
							windows.imgui_settings.v = false
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = false
							mcvalue = true
							passvalue = true
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.PopStyleColor(2)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
					if imgui.Button(u8'�����', imgui.ImVec2(142.5,30)) then
						windowtype = 0
					end
				end
			}
			fastmenu[windowtype]()
			imgui.End()
		end

		if windows.imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"���� �������� ������� ["..fastmenuID.."]", _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			local SomeFunc = function(bool, name, wide)
				local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetRGBA()
				local hex = string.format('%06X', bit.band(join_argb(a, b, g, r), 0xFFFFFF))
				local button = imgui.InvisibleButton(name, imgui.ImVec2(wide, 0))
				imgui.SetCursorPosY(39)
				return button
			end
			local Empty = {"","","","","","","","","","","","","","","","","","","",""}
			for number, Nil in pairs(Empty) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 0) / 2)
				SomeFunc(settingswindow == number, Nil, 0)
			end
			local sobesdecline = function(param)
				local reason = param:match("(.+)")
				lua_thread.create(function()
					if inprocess then
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					else
						inprocess = true
						if reason ~= "����. �������������1" and reason ~= "����. �������������3" and reason ~= "����. �������������5" then
							sampSendChat("/me ���� ��������� �� ��� �������� �������� {gender:�����|������} �� ���������")
							wait(2000)
							sampSendChat("/todo ����� �������...* ������� ��������� �������")
							wait(2000)
						end
						if reason == ("����������������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� ������� ��������������.")
						elseif reason == ("�� ��������� ��������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� �� ��������� ��������.")
						elseif reason == ("�� ���������������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� ������������ ���������������.")
						elseif reason == ("������ 3 ��� � �����") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� �� ���������� � ����� 3 ����.")
						elseif reason == ("����� � �����������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� ��� ��������� � ������ �����������.")
						elseif reason == ("��� � ���������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� �������� � ����. ��������.")
							sampSendChat("/n ������� ���. �����")
						elseif reason == ("� �� ���������") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� ���������� � �� ��.")
						elseif reason == ("���� �����") then
							sampSendChat("� ��������� � �� ���� ���������� �������������. �� ����. ����������.")
							sampSendChat("/n ���� �����")
						elseif reason == ("����. �������������1") then
							sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
							sampSendChat("/b ������ �� �������")
						elseif reason == ("����. �������������2") then
							sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
							sampSendChat("/b ����� ������ ��")
						elseif reason == ("����. �������������3") then
							sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
							sampSendChat("/b �� ���� ��")
						elseif reason == ("����. �������������4") then
							sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
							sampSendChat("/b ������ ����������")
						elseif reason == ("����. �������������5") then
							sampSendChat("� ��������� � �� ���� ������� ��� ��-�� ����, ��� �� ����. ����������.")
						end
						inprocess = false
					end
				end)
			end
			local sobes = {
				[0] = function()
					CenterTextColoredRGB("�������������: ���� 1")
					imgui.Separator()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'����������������', imgui.ImVec2(285,30)) then
						if not inprocess then
							lua_thread.create(function()
								inprocess = true
								local name
								if configuration.main_settings.useservername then
									local result,myid = sampGetPlayerIdByCharHandle(playerPed)
									name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
								else
									name = u8:decode(configuration.main_settings.myname)
									if name == '' or name == nil then
										ASHelperMessage('������� ��� ��� � /ash')
										local result,myid = sampGetPlayerIdByCharHandle(playerPed)
										name = string.gsub(sampGetPlayerNickname(myid), "_", " ")
									end
								end
								local rang = configuration.main_settings.myrank
								sampSendChat("������������, �� �� �������������?")
								wait(2000)
								sampSendChat('/do �� ����� ����� ������� � �������� '..rang..' '..name)
								inprocess = false
							end)
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'��������� ��������� '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
						if not inprocess then
							lua_thread.create(function()
								inprocess = true
								sampSendChat("������, ��� ����� �������� ��� ���� ���������, � ������: ������� � ���.�����")
								sampSendChat("/n ����������� �� ��!")
								wait(50)
								sobesetap = 1
								inprocess = false
							end)
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
				end,
				[1] = function()
					CenterTextColoredRGB("�������������: ���� 2")
					imgui.Separator()
					if not mcvalue then
						CenterTextColoredRGB("���.����� - �� ��������")
					else
						CenterTextColoredRGB("���.����� - �������� ("..mcverdict..")")
					end
					if not passvalue then
						CenterTextColoredRGB("������� - �� �������")
					else
						CenterTextColoredRGB("������� - ������� ("..passverdict..")")
					end
					if mcvalue and mcverdict == ("� �������") and passvalue and passverdict == ("� �������") then
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
						if imgui.Button(u8'���������� '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
							if not inprocess then
								lua_thread.create(function()
									inprocess = true
									wait(50)
									sobesetap = 2
									sampSendChat("/me ���� ��������� �� ��� �������� �������� {gender:�����|������} �� ���������")
									wait(2000)
									sampSendChat("/todo ������...* ������� ��������� �������")
									wait(2000)
									sampSendChat("������ � ����� ��� ��������� ��������, �� ������ �� ��� ��������?")
									inprocess = false
								end)
							else
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							end
						end
					end
				end,
				[2] = function()
					CenterTextColoredRGB("�������������: ���� 3")
					imgui.Separator()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'���������� ������� � ����.', imgui.ImVec2(285,30)) then
						if not inprocess then
							if inprocess then
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							else
								inprocess = true
								sampSendChat("���������� ������� � ����.")
								inprocess = false
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'������ ������� ������ ���?', imgui.ImVec2(285,30)) then
						if not inprocess then
							if inprocess then
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							else
								inprocess = true
								sampSendChat("������ �� ������� ������ ���?")
								inprocess = false
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8"�������� �� ��� � ������������ ��? "..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
						if not inprocess then
							if inprocess then
								ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
							else
								inprocess = true
								sampSendChat("�������� �� ��� � ������������ ��? ���� ��, �� ���������� ���������")
								sampSendChat("/n �� - ����������� ������� [���������, �������������, ����]")
								lua_thread.create(function()
									wait(50)
									sobesetap = 3
								end)
								inprocess = false
							end
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
				end,
				[3] = function()
					CenterTextColoredRGB("�������������: �������")
					imgui.Separator()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
					if imgui.Button(u8'�������', imgui.ImVec2(285,30)) then
						if not inprocess then
							lua_thread.create(function()
								inprocess = true
								if configuration.main_settings.myrankint >= 9 then
									local invite = function(param)
										if configuration.main_settings.myrankint >= 9 then
											if inprocess then
												ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
											else
												local id = param:match("(%d+)")
												local id = tonumber(id)
												if id == nil then
													ASHelperMessage('/invite [id]')
												else
													local result, myid = sampGetPlayerIdByCharHandle(playerPed)
													if id == myid then
														ASHelperMessage('�� �� ������ ���������� � ����������� ������ ����.')
													else
														inprocess = true
														sampSendChat('/do ����� �� �������� � �������.')
														wait(2000)
														sampSendChat('/me ������ ���� � ������ ����, {gender:������|�������} ������ ���� �� ��������')
														wait(2000)
														sampSendChat('/me {gender:�������|��������} ���� �������� ��������')
														wait(2000)
														sampSendChat('����� ����������! ���������� �� ������.')
														wait(2000)
														sampSendChat('�� ���� ����������� �� ������ ������������ �� ��. �������.')
														sampSendChat("/invite "..id)
														inprocess = false
													end
												end
											end
										else
											ASHelperMessage("������ ������� �������� � 9-�� �����.")
										end
									end
									sampSendChat("�������, � ����� �� ��� ���������!")
									wait(2000)
									inprocess = false
									invite(tostring(fastmenuID))
								else
									sampSendChat("�������, � ����� �� ��� ���������!")
									wait(2000)
									sampSendChat("/r "..string.gsub(sampGetPlayerNickname(fastmenuID), "_", " ").." ������� ������ �������������! �� ��� ������� ����� ������ ����� �� ��� �������.")
									wait(2000)
									sampSendChat("/rb "..fastmenuID.." id")
								end
								inprocess = false
							end)
							sobesetap = 0
							windows.imgui_settings.v = false
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = false
							mcvalue = true
							passvalue = true
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.PopStyleColor(2)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
					if imgui.Button(u8'���������', imgui.ImVec2(285,30)) then
						if not inprocess then
							lastsobesetap = sobesetap
							sobesetap = 7
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.PopStyleColor(2)
				end,
				[7] = function()
					local sobesdecline_arr = {u8"������ ��",u8"�� ���� ��",u8"������ ����������",u8"������ �� �������",u8"������"}
					CenterTextColoredRGB("�������������: ����������")
					imgui.Separator()
					imgui.PushItemWidth(270)
					imgui.Combo(" ",sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
					if imgui.Button(u8'���������', imgui.ImVec2(270,30)) then
						if not inprocess then
							sobesetap = 0
							if sobesdecline_select.v == 0 then
								sobesdecline("����. �������������2")
							elseif sobesdecline_select.v == 1 then
								sobesdecline("����. �������������3")
							elseif sobesdecline_select.v == 2 then
								sobesdecline("����. �������������4")
							elseif sobesdecline_select.v == 3 then
								sobesdecline("����. �������������1")
							elseif sobesdecline_select.v == 4 then
								sobesdecline("����. �������������5")
							end
							windows.imgui_settings.v = false
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = false
							mcvalue = true
							passvalue = true
						else
							ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
						end
					end
					imgui.PopStyleColor(2)
				end
			}
			sobes[sobesetap]()
			if sobesetap ~= 3 and sobesetap ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'���������', imgui.ImVec2(285,30)) then
					if not inprocess then
						if mcvalue or passvalue then
							if mcverdict == ("����������������") then
								sobesdecline("����������������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif mcverdict == ("�� ��������� ��������") then
								sobesdecline("�� ��������� ��������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("������ 3 ��� � �����") then
								sobesdecline("������ 3 ��� � �����")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("�� ���������������") then
								sobesdecline("�� ���������������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("����� � �����������") then
								sobesdecline("����� � �����������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("��� � ���������") then
								sobesdecline("��� � ���������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("� �� ���������") then
								sobesdecline("� �� ���������")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							elseif passverdict == ("���� �����") then
								sobesdecline("���� �����")
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
							else
								lastsobesetap = sobesetap
								sobesetap = 7
							end
						else
							lastsobesetap = sobesetap
							sobesetap = 7
						end
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'�����', imgui.ImVec2(137,30)) then
				if sobesetap == 7 then
					sobesetap = lastsobesetap
				elseif sobesetap ~= 0 then
					sobesetap = sobesetap - 1
				else
					windows.imgui_sobes.v = false
					windows.imgui_fm.v = true
					windowtype = 0
				end
			end
			imgui.SameLine()
			if sobesetap ~= 3 and sobesetap ~= 7 then
				if imgui.Button(u8'���������� ����', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap = sobesetap + 1
					else
						ASHelperMessage("�� ����������, �� ��� ����������� ���-��!")
					end
				end
			end
			imgui.End()
		end

		if windows.imgui_settings.v then
			local usersettings = {
				useaccent 						= imgui.ImBool(configuration.main_settings.useaccent),
				createmarker 					= imgui.ImBool(configuration.main_settings.createmarker),
				useservername 					= imgui.ImBool(configuration.main_settings.useservername),
				dorponcmd						= imgui.ImBool(configuration.main_settings.dorponcmd),
				replacechat						= imgui.ImBool(configuration.main_settings.replacechat),
				dofastscreen					= imgui.ImBool(configuration.main_settings.dofastscreen),
				myname 							= imgui.ImBuffer(configuration.main_settings.myname, 256),
				myaccent 						= imgui.ImBuffer(configuration.main_settings.myaccent, 256)
			}

			local pricelist = {
				avtoprice 						= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7),
				motoprice 						= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7),
				ribaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7),
				lodkaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7),
				gunaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7),
				huntprice 						= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7),
				kladprice						= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7)
			}

			local imgui_SmoothButton = function(bool, name, wide)
				local animTime = 0.25
				local drawList = imgui.GetWindowDrawList()
				local p1 = imgui.GetCursorScreenPos()
				local p2 = imgui.GetCursorPos()
				local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetRGBA()
				local hex = string.format('%06X', bit.band(join_argb(a, b, g, r), 0xFFFFFF))
				local button = imgui.InvisibleButton(name, imgui.ImVec2(wide, 30))
				if button and not bool then 
					navigateLast = os.clock()
				end
				local pressed = imgui.IsItemActive()
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 220, p1.y + 30), '0x20'..hex)
				if bool then
					if navigateLast and (os.clock() - navigateLast) < animTime then
						local wide = (os.clock() - navigateLast) * (wide / animTime)
						drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), '0x80'..hex)
						drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 30), '0xFF'..hex)
					else
						drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), '0x80'..hex)
						drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), '0xFF'..hex)
					end
				else
					if imgui.IsItemHovered() then
						drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), '0x10'..hex)
						drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), '0x70'..hex)
					end
				end
				imgui.SameLine(10); imgui.SetCursorPos(imgui.ImVec2((wide - imgui.CalcTextSize(name).x) / 2, p2.y + 8))
				imgui.Text(name)
				imgui.SetCursorPosY(p2.y + 36.7)
				return button
			end

			local buttons 						= {fa.ICON_FA_USER_COG..u8' ��������� ������������',fa.ICON_FA_FILE_ALT..u8' ������� ��������',fa.ICON_FA_KEYBOARD..u8' ������� �������',fa.ICON_FA_PALETTE..u8' ��������� ������',fa.ICON_FA_BOOK_OPEN..u8' ������� ���������',fa.ICON_FA_INFO_CIRCLE..u8' ���������� � �������'}

			local StyleBox_select				= imgui.ImInt(configuration.main_settings.style)
			local StyleBox_arr					= {u8"Ҹ���-��������� (transp.)",u8"Ҹ���-������� (not transp.)",u8"������-����� (not transp.)",u8"���������� (not transp.)",u8"������-����� (not transp.)",u8"Ҹ���-������� (not transp.)"}

			local settings = {
				[0] = function()
					imgui.PushFont(fontsize16)
					CenterTextColoredRGB('��� � ����?')
					imgui.PopFont()
					imgui.TextWrapped(u8([[
	� ���� �������� �������: ������������ �� ������ � ������� ��� � ����� ������ E (�� ���������), ��������� ���� �������� �������. � ������ ���� ���� ��� ������ �������, � ������: �����������, ����������� ����� �����, ������� ��������, ����������� ������� �������� �� ���������, ����������� � �����������, ���������� �� �����������, ��������� ���������, ��������� � ��, �������� �� ��, ������ ���������, �������� ���������, ������ ���������������� ����, �������� ���������������� ����, ������������������ ���������� ������������� �� ����� ������� �����������.
	
	� ������� ������� � �����������: /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. ����� ����� �� ���� ������ ������� �� ���������, ���� ����� �� ����� ������������ ���� �������.
	
	� �������: /ash - ��������� �������, /ashbind - ������ �������, /ashstats - ���������� ��������� ��������.
	
	� ���������: ����� ������� /ash ��������� ��������� � ������� ����� �������� ������� � �����������, ������, �������� ������� ��� ���������, ���, ���� �� ��������, ������� ������� �������� ���� � ������ ���������� � �������.
	
	� ������: ����� ������� /ashbind ��������� ��������� ��������������� ������, � ������� �� ������ ������� ��������� ����� ����.]]
		))
				end,
				[1] = function()
					local TextColoredRGB = function(text)
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
								else imgui.Text(u8(w)) end
							end
						end
						render_text(text)
					end
					local autoGetSelfGender = function()
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
										local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
										ASHelperMessage(string.format("��� ��� ������: {%06X}"..(gender.v and "�������" or "�������"), join_rgb(r, g, b)))
									end
									return k
								end
							end
						end
						return nil
					end
					imgui.SetCursorPosX(10)
					if imgui.Checkbox(u8"������������ ��� ��� �� ����",usersettings.useservername) then
						if configuration.main_settings.myname == '' then
							local result,myid = sampGetPlayerIdByCharHandle(playerPed)
							usersettings.myname.v = string.gsub(sampGetPlayerNickname(myid), "_", " ")
							configuration.main_settings.myname = sampGetPlayerNickname(myid)
						end
						configuration.main_settings.useservername = usersettings.useservername.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					if not usersettings.useservername.v then
						imgui.SetCursorPosX(10)
						if imgui.InputText(u8" ", usersettings.myname) then
							configuration.main_settings.myname = usersettings.myname.v
							if inicfg.save(configuration,"AS Helper") then
							end
						end
					end
					imgui.SetCursorPosX(10)
					if imgui.Checkbox(u8"������������ ������",usersettings.useaccent) then
						configuration.main_settings.useaccent = usersettings.useaccent.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					if usersettings.useaccent.v then
						imgui.PushItemWidth(150)
						imgui.SetCursorPosX(20)
						if imgui.InputText(u8"   ", usersettings.myaccent) then
							configuration.main_settings.myaccent = usersettings.myaccent.v
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
					if imgui.Checkbox(u8"��������� ������ ��� ���������",usersettings.createmarker) then
						if marker ~= nil then
							removeBlip(marker)
						end
						marker = nil
						oldtargettingped = 0
						configuration.main_settings.createmarker = usersettings.createmarker.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.SetCursorPosX(10)
					if imgui.Checkbox(u8"�������� ��������� ����� ������", usersettings.dorponcmd) then
						configuration.main_settings.dorponcmd = usersettings.dorponcmd.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.SetCursorPosX(10)
					if imgui.Checkbox(u8"�������� ��������� ���������", usersettings.replacechat) then
						configuration.main_settings.replacechat = usersettings.replacechat.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.SetCursorPosX(10)
					if imgui.Checkbox(u8"������� ����� �� "..configuration.main_settings.fastscreen, usersettings.dofastscreen) then
						configuration.main_settings.dofastscreen = usersettings.dofastscreen.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.SetCursorPosX(10)
					if imgui.Button(u8'��������', imgui.ImVec2(85,25)) then
						getmyrank = true
						sampSendChat("/stats")
					end
					imgui.SameLine()
					imgui.Text(u8"��� ����: "..u8(configuration.main_settings.myrank).." ("..u8(configuration.main_settings.myrankint)..")")
					imgui.PushItemWidth(85)
					imgui.SetCursorPosX(10)
					if imgui.Combo(u8"",gender, {u8"�������",u8"�������"}, 2) then
						configuration.main_settings.gender = gender.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					TextColoredRGB("��� ������ {808080}(?)")
					if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
						autoGetSelfGender()
					end
					imgui_Hint("��� ��� ��������������� �����������.")
				end,
				[2] = function()
					CenterTextColoredRGB("������� ��������")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"����", pricelist.avtoprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.avtoprice = pricelist.avtoprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() + 29) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"����", pricelist.motoprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.motoprice = pricelist.motoprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"�������", pricelist.ribaprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.ribaprice = pricelist.ribaprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"��������", pricelist.lodkaprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.lodkaprice = pricelist.lodkaprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"������", pricelist.gunaprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.gunaprice = pricelist.gunaprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"�����", pricelist.huntprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.huntprice = pricelist.huntprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
					imgui.PushItemWidth(62)
					if imgui.InputText(u8"��������", pricelist.kladprice, imgui.InputTextFlags.CharsDecimal) then
						configuration.main_settings.kladprice = pricelist.kladprice.v
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					imgui.PopItemWidth()
				end,
				[3] = function()
					if imgui.Button(u8'�������� ������ �������� ����', imgui.ImVec2(-1,40)) then
						getbindkey = true
						configuration.main_settings.usefastmenu = ""
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					if getbindkey then
						imgui_Hint("������� ����� �������")
					else
						imgui_Hint("��� + "..configuration.main_settings.usefastmenu)
					end
					if imgui.Button(u8'�������� ������ �������� ������', imgui.ImVec2(-1,40)) then
						getscreenkey = true
						configuration.main_settings.fastscreen = ""
						if inicfg.save(configuration,"AS Helper") then
						end
					end
					if getscreenkey then
						imgui_Hint("������� ����� �������")
					else
						imgui_Hint(configuration.main_settings.fastscreen)
					end
					if imgui.Button(u8'������� ������', imgui.ImVec2(-1,40)) then
						choosedslot = nil
						windows.imgui_binder.v = not windows.imgui_binder.v
					end
					imgui.SameLine()
				end,
				[4] = function()
					imgui.PushItemWidth(200)
					if imgui.Combo(u8'����� ����', StyleBox_select, StyleBox_arr, #StyleBox_arr) then
						configuration.main_settings.style = StyleBox_select.v
						if inicfg.save(configuration,"AS Helper") then
							checkstyle()
						end
					end
					imgui.PopItemWidth()
					if imgui.ColorEdit4(u8'���� ���� �����������##RSet', RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
						local clr = imgui.ImColor.FromFloat4(RChatColor.v[1], RChatColor.v[2], RChatColor.v[3], RChatColor.v[4]):GetU32()
						configuration.main_settings.RChatColor = clr
						inicfg.save(configuration, 'AS Helper.ini')
					end
					imgui.SameLine(imgui.GetWindowWidth() - 75)
					if imgui.Button(u8"��������##RCol",imgui.ImVec2(65,25)) then
						configuration.main_settings.RChatColor = 4282626093
						if inicfg.save(configuration, 'AS Helper.ini') then
							RChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
						end
					end
					imgui.SameLine(imgui.GetWindowWidth() - 130)
					if imgui.Button(u8"����##RTest",imgui.ImVec2(50,25)) then
						local result, myid = sampGetPlayerIdByCharHandle(playerPed)
						local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
						sampAddChatMessage('[R] '..configuration.main_settings.myrank..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']:(( ��� ��������� ������ ������ ��! ))', join_rgb(r, g, b))
					end
					if imgui.ColorEdit4(u8'���� ���� ������������##DSet', DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
						local clr = imgui.ImColor.FromFloat4(DChatColor.v[1], DChatColor.v[2], DChatColor.v[3], DChatColor.v[4]):GetU32()
						configuration.main_settings.DChatColor = clr
						inicfg.save(configuration, 'AS Helper.ini')
					end
					imgui.SameLine(imgui.GetWindowWidth() - 75)
					if imgui.Button(u8"��������##DCol",imgui.ImVec2(65,25)) then
						configuration.main_settings.DChatColor = 4294940723
						if inicfg.save(configuration, 'AS Helper.ini') then
							DChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
						end
					end
					imgui.SameLine(imgui.GetWindowWidth() - 130)
					if imgui.Button(u8"����##DTest",imgui.ImVec2(50,25)) then
						local result, myid = sampGetPlayerIdByCharHandle(playerPed)
						local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
						sampAddChatMessage('[D] '..configuration.main_settings.myrank..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: ��� ��������� ������ ������ ��!', join_rgb(r, g, b))
					end
					if imgui.ColorEdit4(u8'���� AS Helper � ����##SSet', ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
						local clr = imgui.ImColor.FromFloat4(ASChatColor.v[1], ASChatColor.v[2], ASChatColor.v[3], ASChatColor.v[4]):GetU32()
						configuration.main_settings.ASChatColor = clr
						inicfg.save(configuration, 'AS Helper.ini')
					end
					imgui.SameLine(imgui.GetWindowWidth() - 75)
					if imgui.Button(u8"��������##SCol",imgui.ImVec2(65,25)) then
						configuration.main_settings.ASChatColor = 4281558783
						if inicfg.save(configuration, 'AS Helper.ini') then
							ASChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
						end
					end
					imgui.SameLine(imgui.GetWindowWidth() - 130)
					if imgui.Button(u8"����##ASTest",imgui.ImVec2(50,25)) then
						ASHelperMessage("��� ��������� ������ ������ ��!")
					end
				end,
				[5] = function()
					if imgui.Button(u8'����� ���������', imgui.ImVec2(-1,35)) then
						imgui.OpenPopup(u8("����� ���������"))
					end
					local ustav = function()
						if imgui.BeginPopupModal(u8("����� ���������"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							local search_ustav = imgui.ImBuffer(256)
							local ustavtext = {
								"����� I. ����� ���������",
								"1.1. ������ �������� ������ ����� � ��������� ������ ��������� ���������.",
								"1.2. �� ��������� ������ �� ������� ������� ��������� ��������� ���������.",
								"1.3. �������� ������ �� ����������� �� ���������������.",
								"1.4. ���������� �������� ������� [5-9] ������ ������� �� �������� � ����������� � ���������.",
								"1.5. ������ ��������� ������ ����� ���� ������� ����������� �� ������ ���������.",
								"1.6.������ ��������� ������ ��������� ������������.",
								"1.7. ������� ������������ �������� ������������� � ����������� �� ��������.",
								"1.8. ����� ����� ������������/����������� ����������� ���������.",
								"1.9 ���������� ��������� ������� �������� �� ���������� ������������ �������.",
								"1.10 ���������� �������� �������� ����������� � ���������.",
								"",
								"����� II. ������ � ������������.",
								"",
								"2.1 ������� ������� - ��� ���� ������ ���������, �������� � ������������ ���������� ������.",
								"2.2 ������������ - ��� ������� ������� ����� ������������, ������� �� ���������.",
								"2.3 ��� ���������� ������ ����������� ���������� �� ���� ���������� �� �����.",
								"2.4 ��������� ������ ������� �����, ������� ���� ��� �� ���������.",
								"2.5 ����������� ��������� �� ���������, �����, '���', '�������'.",
								"2.6 ������ �������� ��������� ������ ������������� ����� ��������.",
								"2.7 ����� ��������� ��������� ������ ���� �������� �������� �� ��������� �������.",
								"",
								"����� III. ������� ����������� �/� ���������.",
								"",
								"3.1 ������� ����������� �/� ������ ��������� ��� ���������� ���������.",
								"3.2 �/� ��������� ����� �� ���������� ��������:",
								"�) ��������[3] - ��������;",
								"�) 4-7 ����� - ����������;",
								"�) ���. ��������� � ���� - ��������.",
								"3.3 ��������� ������������ ��������� ��������� � ����� �����.",
								"3.4 ��������� ������������ ��������� ��������� ��� �������� ���, ����������: ����� ������������ ��� ���������� � �.�.",
								"3.5 ��������� ������������ ��������� ���������, �� ����������� �� ���� �����������.",
								"",
								"����� IV. ������� ������.",
								"",
								"4.1 ������� ����� (�����������-�������):",
								"4.1.1 ������� ����� � 09:00 �� 19:00",
								"4.1.2 ������� �� ���� - � 13:00 �� 14:00",
								"4.1.3 ������� ����� (�������-�����������):",
								"4.1.4 ������� ����� � 10:00 �� 18:00",
								"4.1.5 ������� �� ���� - � 13:00 �� 14:00",
								"4.2 ������ ��������� ��������� ������ ���������� � ��������� �� ����� �������� �������.",
								"4.3 �������� ������ ��������� ������ � ����������� �������. ( ���� �� ��� � ����� - �������� �� ����� � �������*screenshot + /time* )",
								"4.4 �� ������� � ������� ����� ��������� ������� �������, ���� �� ����� ������.",
								"4.5 �� ��������� ������� ����� ��� ���������� ������ ����� ����� � ������� ����� ���, ��� �������� �� ������ �����.",
								"4.6 ��������� ������ ����� �� �������� ������������, �� ��� ����� ����������.",
								"",
								"����� V. ����������� ����������� ���������.",
								"",
								"5.1 ������ ��������� ������ ��������� � ����� ����� ���������.",
								"5.2 ������ ��������� ������ ��������� ������������ � �������.",
								"5.3 ������ ��������� ������ ��������� ������ ����������������� ������������.",
								"5.4 ������ ��������� ������ ����� ����������� ������ � ���� � �� �����.",
								"5.5 ��������� � �� ����������� ������� ������������ � ����� ��������� ������ ��� ������� ������������.",
								"5.6 ������ ��������� ������ ��������� ���������������� �����.",
								"5.7 ������ ��������� ��������� ������ ����������� ��������� ���� ������������ ������.",
								"5.8 ���������� ������� ����������� ����������� ������������������ ������, ��� ������� ��� ����������.",
								"5.9 ���������� ������ ������������� ������� ������������������ ������.",
								"5.10 ���������� ���������, ������� � ��������� '�����������'[2] ������� ����� ����. ����� 'Discord'.",
								"5.11 ���������� �������� ������� ������� ������� � �������� �����������, ������ �� �� ���������.",
								"5.12 ���������� �������� ������� ������ �������� ������������ ��������, ������ �������� ���������.",
								"",
								"����� VI. ������ � �������.",
								"",
								"6.1 ������ ��������� ����� � ��������� '����������[5]'.",
								"6.2 ��������� ����� ����� ������ ������ �� ��������� ������� �� ����������� ������ �� ������.",
								"6.3 ������ �������� ����� �������� �� 7 ����������� ����.",
								"6.4 ���� ��������� �� �������� � ������� � ����������� �����, �� ����� ������, ��� ����� �������������� �� �������� �� ���������� ���������.",
								"6.5 �� ����� �������� ��������� �� �������� � ����.",
								"6.6 ������� ����� ����� �������� �� 5 ���� ( ��� ������������ 3 ��� ).",
								"6.7 ��� �������� �� ����� ������� � ���� � ������������ ������.",
								"6.8 ������� ����� ����� ��� ���� �� ���� ������������.",
								"6.9 ��������������� ����� �� �������� ��� �������������� ����� �������� ��������� � �����������.",
								"",
								"����� VII. ������� � ����� ��� ����������� ���������.",
								"7.1 ��������� �� ����� ����� �������� ����� � ���������������� �����.",
								"7.2 ����������� ��������� ������ ���� �� ����.",
								"7.3 ����������� ��������� �� ����� ���. ��� ������ ����� � ���������� ��������� ( �����, �����, ������� ).",
								"7.4 ��������� ����� ��� ���������� ����� 5-� �����. ( ����.: 10 ����� ��� ���� / ��������� )",
								"7.5 ���������� �� ����� ����� ������� �� ����, ���� �� �������� �����, ������� ����� � �������.",
								"7.6 ���������� �� ����� ����� �� ����� �������� ��� ������ ������ �� �� �����-����.",
								"7.7 ����������� ��������� ������, ����, ���� �� ����� �������� ���.",
								"7.8 ��������� ������������ ��������� � ������ ���������.",
								"7.9 ���������� ������������� ��������� �������/�����������/���������� ������������ ��������.",
								"7.10 ����������� ��������� ������ ���� � ������� �����.",
								"7.11 ���������� ��������� ��������� ��������/����������� ���������.",
								"7.12 ����������� �������� ������� ��������� ��������� ���������� � ������ ����, ��� ��� � 30 �����.",
								"7.13 ��������� ����������� ������� ������ �������� ��������.",
								"7.14 ������ ������������� ������ �� ���������� ��������� - �������.",
								"7.15 ��������� ����� ����� � ������������ ������������� - ����������.",
								"",
								"����������: ����������� � ��� ��������� ����� �������� ��������� �� ���� ����������, �� ������� �������������� �� ������� ������ ���������.",
								"",
								"����� VIII. ������ �������.",
								"",
								"8.1 �������� ��������� ������ �� ���������� �������, � ��� �� �� �������� ������� �� ���� �����������.",
								"8.2 �������� ���������� �������� - ���������.",
								"8.3 ������� �� ������ ������ ������� ��� ������ ������� - �������.",
								"8.4 ���� ���������� ��������� ��� � ����� ����� 5 ����, �� �� ����� ������ ��� ����������� ��������������.",
								"",
								"����� IX. ����������� � ����� ���������.",
								"9.1 �������� �������� ����������� ������ ����� ������������.",
								"9.2 �������� ����� ����� ��������� �� ������������ �� ����� ������������.",
								"9.3 �������� - ������� ����������� ���� � ���������, ���� ������������ �� � �����.",
								"9.4 �������� �������� ��������� ���� �������, �� ���� ����� ������ ����� ������� ���� ������� � ��������� �����.",
								"9.5 �������� ����� ����� �� ������ ��������� ������������ ���������.",
								"9.6 �������� ����� ����� ��������� ����������� ��������� �� ��������� ������ �� ����� ���������. ������������� ������� ��������� ��������.",
								"9.7 �������� ������ ����������� ������ ������ ������������ � ��������� �����, � ��� �� ��� � �����������.",
								"",
								"����� X. OOC (Out Of Character).",
								"",
								"10.1 ��������� �������� ����������� ������� �������.",
								"10.2 ��������� ��������� ������ ��������� RolePlay �����, � ����������� �� ��������.",
								"10.3 ��������� ������ AFK ��� Esc �� �������� ����� ������.",
								"10.4 ��������� NonRP ������ � ���������.",
								"10.5 �������� flood, offtop, MG, DM.",
								"10.6 ��������� ����������� � NonRP �����."
							}
							local rlower = function(s)
								local russian_characters = {
									[155] = '[', [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
								}
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
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
							imgui.PushItemWidth(200)
							imgui.PushAllowKeyboardFocus(false)
							imgui.InputText("##search_ustav", search_ustav, imgui.InputTextFlags.EnterReturnsTrue)
							imgui.PopAllowKeyboardFocus()
							imgui.PopItemWidth()
							if not imgui.IsItemActive() and #search_ustav.v == 0 then
								imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' ����� �� ������')).x) / 2)
								imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' ����� �� ������'))
							end
							CenterTextColoredRGB('{868686}������� ���� �� ������, ������� � � ���� ����� � ����')
							imgui.BeginChild("##Ustav", imgui.ImVec2(800, 400), true)
							for _,line in ipairs(ustavtext) do
								if #search_ustav.v < 1 then
									imgui.TextWrapped(u8(line))
									imgui_Hint('�������� ������, ��� �� ����������� ������ � ���', 2)
									if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
										sampSetChatInputEnabled(true)
										sampSetChatInputText(line)
									end
								else
									if rlower(line):find(rlower(u8:decode(search_ustav.v)):gsub("%[","%%[")) then
										imgui.TextWrapped(u8(line))
										imgui_Hint('�������� ������, ��� �� ����������� ������ � ���', 2)
										if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
											sampSetChatInputEnabled(true)
											sampSetChatInputText(line)
										end
									end
								end
							end
							imgui.EndChild()
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
							if imgui.Button(u8"�������",imgui.ImVec2(200,25)) then
								imgui.CloseCurrentPopup()
							end
							imgui.EndPopup()
						end
					end
					ustav()
					if imgui.Button(u8'������� ���. ��������', imgui.ImVec2(-1,35)) then
						imgui.OpenPopup(u8("������� ���. ��������"))
					end
					local rules = function()
						if imgui.BeginPopupModal(u8("������� ���. ��������"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.BeginChild("##Rules", imgui.ImVec2(700, 330), true)
							CenterTextColoredRGB([[
{FF0000}�������� �������
[1 - 4 �����] - [{00FF00}�����������]]..textcolorinhex..[[]
[5 ����] - [{FF9900}3 �����]]..textcolorinhex..[[]
[6 ����] - [{FF9900}4 �����]]..textcolorinhex..[[]
[7 ����] - [{FF5500}6 ����]]..textcolorinhex..[[]
[8 ����] - [{FF5500}8 ����]]..textcolorinhex..[[]
[9 ����] - [{FF1100}15 ����]]..textcolorinhex..[[]
{FF1100}���� ������� �� ������� �������������� ���� � ��� ������/���� ��� - ��������� � �� ������� �������.
 
{FF0000}����� ���
����� ��� ��� ��������/������/����������� ���������� 10 ����� [{FF5500}600 ������]]..textcolorinhex..[[] | ���������: ������/�������
�������������� � ���.
����� ��� ��� ��.������� [5-8 ����] ���������� 15 ����� [{FF5500}900 ������]]..textcolorinhex..[[] | ���������: ������� � ������ ����/���.
����� ��� ��� ��.������� [1-4 ����] ���������� 30 ����� [{FF5500}1800 ������]]..textcolorinhex..[[] | ���������: ����������.
 
{FF0000}����������� �� ������
9 ���� - 3 ��������
8 ���� - 4 ��������
 
{FF0000}���� � /d ��� � /gov
����������� ���� �. ���-������ - [����]
������������� ����� - [�������������]
��������������� ��������� �. ���-������ - [���������]
 
����������� ���� ������������� - [���]
������� �. ���-������ - [������� ��]
������� �. ���-������ - [������� ��]
������� ������ ��� ������ - [��������� �������]
������� �. ���-�������� - [������� ��]
 
����� �. ���-������ - [����� ��]
����� �. ���-������ - [���]
 
������ �������� ������
������ �������� ������ �.Las-Venturas - [������ ��]
 
�������� �. ���-������ - [�������� ��]
�������� �. ���-������ - [�������� ��]
�������� �. ���-�������� - [�������� ��]
 
��������� �������� - [��]
 
{FF0000}������� ���������
�������� ������ ������������ �������� ���������� �� ���� ������� ������� ������������.
����� ����������� �� ������������� � ��������� � �������, �� ��������� � ����������� ���� � �������,
�� ������������ ����� � ������������� � �������.
 
�������� �������������� �� �������:
������� �� ��������� � ������������ ����� � ������������� -2 ����� �� ���������.
������� �� ������������� � ��������� � ����������� ���� -1 ���� �� ���������.
�������� �� ��������� � ����������� ���� � �������� -1 ���� �� ���������.
 
����������� � ����������� ������� �� ������ ����������� � �� ���� � ������ ������������ - ������.
]])
							imgui.EndChild()
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
							if imgui.Button(u8"�������",imgui.ImVec2(200,25)) then
								imgui.CloseCurrentPopup()
							end
							imgui.EndPopup()
						end
					end
					rules()
					if imgui.Button(u8'������� ���������', imgui.ImVec2(-1,35)) then
						imgui.OpenPopup(u8("������� ���������"))
					end
					local ranksystem = function ()
						if imgui.BeginPopupModal(u8("������� ���������"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.BeginChild("##RankSystem", imgui.ImVec2(800, 600), true)
							CenterTextColoredRGB([[
{ff6633}����� [1] - ����������� [2]
- ����� ����� ���������� ��������/������������ �������.
- ����� ����. ����� "Discord".
 
{ff6633}����������� [2] - ������� [3]
- ����� ���� ���������� ��������/������������ �������. (�� ��������� ��� ������ ��������)
- ����� ������ ����� ����� ���������� ��������/������������ �������.
- ���������� ���� ������ (�������� ������, �������� � �����)
 
{ff6633}������� [3] - ��. ���������� [4]
- ��������� ��� RolePlay ���������. (������� 10 ���������)
- ���������� 2 ������. (�������� ������, �������� � �����)
- ������� 25 ��������.
 
{ff6633}��. ���������� [4] - ���������� [5]
- ������� 50 ������.
- ��������� ���� RolePlay �������, ��������� � ������� ���������.
 
{ff6633}���������� [5] - �������� [6]
- ������� 60 ������.
- ��������� ���� RolePlay �������, ��������� � ������� ���������.
 
{ff6633}�������� [6] - ��. �������� [7]
- ������� 70 ������
- ��������� ��� RolePlay �������, ��������� � ������� ���������.
 
{ff6633}��. �������� [7] - �������� ��������� [8]
- ������� 80 ������
- ��������� ��� RolePlay �������, ��������� � ������� ���������.
 
�������� �������:
������ �������� | {ff9900}2 �����]]..textcolorinhex..[[ �� ���� �������� | {ff1100}�� ����� 5-�� ��������� �������� �� �����.
������������� ������ �� ��. ������� | {ff9900}4 �����]]..textcolorinhex..[[ �� ���� ������ | {ff1100}�� ����� 3-�� ������������ ������ �� �����.
���������� ��������� �� ��. ������� | {ff9900}5 ������]]..textcolorinhex..[[ �� ���� ��������� | {ff1100}�� ����� 2-�� ����������� ��������� �� �����.
���������� ��������� �� ���. ������� | {ff9900}10 ������]]..textcolorinhex..[[ �� ���� ��������� | {ff1100}�� ����� 1-��� ������������ ��������� �� �����.
��������� RP �������� (������� 20 ���������) | {ff9900}10 ������]]..textcolorinhex..[[ �� ���� RP �������� | {ff1100}�� ����� 1-�� �������� �� �����.
������� � �������� ������ ����������� | {ff9900}5 ������]]..textcolorinhex..[[ �� ���� ������� � �������� | {ff1100}�� ����� 2-�� �������� �� �����.
�������������� �� �������� �� ������ ������� | {ff9900}3 �����]]..textcolorinhex..[[ �� ���� ����������� �� �������� | {ff1100}�� ����� 3-�� �������� �� �����.
������� � RP �������� �� ��. ������� | {ff9900}4 �����]]..textcolorinhex..[[ �� ���� ������� � RP �������� | {ff1100}�� ����� 2-�� ������� � RP �������� �� �����.
���� ����������� ����� �� ����� | {ff9900}0.5 �����]]..textcolorinhex..[[ �� 1 ������ ������� | {ff1100}�� ����� 30-�� ����� �� �����.
���������� ������ ��� ������� | {ff9900}4 �����]]..textcolorinhex..[[ �� ���� ���������� ������ | {ff1100}�� ����� 3-�� ���������� ������ �� �����.
���������� RP �������� ��� ������� | {ff9900}5 ������]]..textcolorinhex..[[ �� ���� ���������� RP ������� | {ff1100}�� ����� 2-�� RP ��������� �� �����.
�������� ������/����� �����/���� � ��. ������� | {ff9900}3 �����]]..textcolorinhex..[[ �� ���� �������� | {ff1100}�� ����� 5-�� �������� �� �����.
���������� �� ��� ������� | {ff9900}3 - 5 ������]]..textcolorinhex..[[ | {ff1100}�� ����� 3-�� ���������� �� �� �����.
����������� �� �� | ������ �� �� - {ff9900}2 - 4 �����]]..textcolorinhex..[[ | {ff1100}�� ����� 5-�� ������� � �� �� �����.
]])
						imgui.EndChild()
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
						if imgui.Button(u8"�������",imgui.ImVec2(200,25)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
						end
					end				
					ranksystem()
					CenterTextColoredRGB[[
{FF1100}�����!{FFFFFF}
������ ������� ���� ����� � ������ Glendale.
�� ����� ������� ��� ����� ����������.]]
				end,
				[6] = function()
					local changelog = function()
						if imgui.BeginPopupModal(u8("������ ���������"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							CenterTextColoredRGB("������ �������: "..thisScript().version)
							imgui.BeginChild("##ChangeLog", imgui.ImVec2(700, 330), false)
							imgui.InputTextMultiline("Read",imgui.ImBuffer(u8([[
������ 2.1
 - ���� ���������� /ashstats ������� ����� �������
 - ������� ���� �������� �������������� ���������� /ashstats
 - �������� ������ � ������� ���� /ash
 - ������ ����� ����������� ����� � /ash
 - ��������� ��� � ������� �� ������
 - ���������� ������ ������ ����
 - ������ ��� ��������� ����� ��������� ��������� ����� ��� ��������

������ 2.0
 - �������� ������ ���������
 - ���������� �������� ���������� ����� /ash
 - ����������� �������� ������� ���� /ash
 - ��������� ������ ����� ����
 - ��������� ��������� ������ /r ���� � /d ����
 - ��������� ������� ��������� ������
 - ��������� ������� �������� /time + �����
 - ��������� ��������������� ����
 - ��������� ��� � ������ ��� �������� �������� � �����������
 - ��������� ������� �������� �������

������ 1.1 - 1.9
 - ��������� ��������� � �������
 - �������� ������� �������������
 - �� ESC ������ ����������� ����
 - ������� ����� ������� ��������� �����
 - ��������� ��� � �������������� ����������
 - ������ ������ ��� ����������� �� ������ ������� �� ������� �������������� ��� ��� ������� ����
 - ��������� ������� �������� �� ��������� ������������
 - ��� ������� ALT ��������� ������ �� ����� �������� ���
 - ��������� ���������� ��������� �������� (/ashstats)
 - ��������� ������ �� ��������� ���������
 - ��������� ������� �������� ������
 - ���������� ����

������ 1.0
 - �����]])),imgui.ImVec2(-1, -1), imgui.InputTextFlags.ReadOnly)
						imgui.EndChild()
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
						if imgui.Button(u8"�������",imgui.ImVec2(200,25)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
						end
					end
					local otheractions = function()
						if imgui.BeginPopup(u8("���������"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							if imgui.Button(u8'�������� ������ '..(fa.ICON_FA_TRASH), imgui.ImVec2(160,25)) then
								windows.imgui_settings.v = false
								windows.imgui_fm.v = false
								windows.imgui_sobes.v = false
								mcvalue = true
								passvalue = true
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
										klad = 0
									},
									BindsName = {},
									BindsDelay = {},
									BindsType = {},
									BindsAction = {},
									BindsCmd = {},
									BindsKeys = {}
								}, "AS Helper")
								if inicfg.save(configuration,"AS Helper") then
									ASHelperMessage("������ ��� ������� �����! ������ ������������.")
								end
								NoErrors = true
								thisScript():reload()
								imgui.CloseCurrentPopup()
							end
							imgui_Hint('{CC0000}����� ������� ��� ���� �����, ���������\n{CC0000} � ���� �� �������� ����� ��������.')
							if imgui.Button(u8'������������� ������ '..(fa.ICON_FA_REDO_ALT), imgui.ImVec2(160,25)) then
								NoErrors = true
								thisScript():reload()
							end
							if imgui.Button(u8'��������� ������ '..(fa.ICON_FA_LOCK), imgui.ImVec2(160,25)) then
								NoErrors = true
								thisScript():unload()
							end
							if imgui.Button(u8'�������� ��� '..(fa.ICON_FA_COMMENT_ALT), imgui.ImVec2(160,25)) then
								local memory = require "memory"
    							memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    							memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    							memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
							end
							imgui.EndPopup()
						end
					end
					local communicate = function()
						if imgui.BeginPopup(u8("�����"), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.23, 0.49, 0.96, 0.8))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.23, 0.49, 0.96, 0.9))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.23, 0.49, 0.96, 1))
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
							if imgui.Button(u8"���������", imgui.ImVec2(90, 25)) then
								ASHelperMessage('������ ����������� � ����� ������')
								setClipboardText("https://vk.com/id468019660")
							end
							imgui.PopStyleColor(4)
							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.46, 0.51, 0.85, 0.8))
							imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.46, 0.51, 0.85, 0.9))
							imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.46, 0.51, 0.85, 1))
							if imgui.Button("Discord", imgui.ImVec2(90, 25)) then
								ASHelperMessage('������ ����������� � ����� ������')
								setClipboardText("JustMini#6291")
							end
							imgui.PopStyleColor(3)
							imgui.EndPopup()
						end
					end
					CenterTextColoredRGB('�����: {ff6633}JustMini')
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'Change Log '..(fa.ICON_FA_TERMINAL), imgui.ImVec2(137,30)) then
						imgui.OpenPopup(u8("������ ���������"))
					end
					imgui.SameLine()
					if imgui.Button(u8'Check Updates '..(fa.ICON_FA_CLOUD_DOWNLOAD_ALT), imgui.ImVec2(137,30)) then
						lua_thread.create(function ()
							checkbibl()
						end)
					end
					changelog()
					imgui.SetCursorPos(imgui.ImVec2(186,200))
					if imgui.Button(u8'������������� '..(fa.ICON_FA_LAYER_GROUP), imgui.ImVec2(120,25)) then
						imgui.OpenPopup(u8('���������'))
					end
					otheractions()
					imgui.SameLine(18)
					if imgui.Button(fa.ICON_FA_LINK..u8' ����� �� ����', imgui.ImVec2(120,25)) then
						imgui.OpenPopup(u8('�����'))
					end
					imgui_Hint('���� �� ����� ���/������ � �������,\n �� ������ ��������� ��� �.')
					communicate()
				end
			}
			imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"AS Helper", windows.imgui_settings, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.BeginChild("##Buttons",imgui.ImVec2(230,240),true,imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoScrollWithMouse)
			for number, button in pairs(buttons) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
				if imgui_SmoothButton(settingswindow == number, button, 220) then
					settingswindow = number
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##Settings",imgui.ImVec2(325,240),true,imgui.WindowFlags.AlwaysAutoResize)
			settings[settingswindow]()
			imgui.EndChild()
			imgui.End()
		end

		if windows.imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 360), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8"������", windows.imgui_binder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.SetScrollY(0)
			imgui.BeginChild("ChildWindow",imgui.ImVec2(175,270),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
			for key, value in pairs(configuration.BindsName) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
				if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
					choosedslot = key
					bindersettings.binderbuff.v = u8(configuration.BindsAction[key]):gsub("~", "\n")
					bindersettings.bindername.v = u8(configuration.BindsName[key])
					bindersettings.bindertype.v = u8(configuration.BindsType[key])
					bindersettings.bindercmd.v = u8(configuration.BindsCmd[key])
					binderkeystatus = u8(configuration.BindsKeys[key])
					bindersettings.binderdelay.v = u8(configuration.BindsDelay[key])
				end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= 50 then
				imgui.SameLine()
				imgui.BeginChild("ChildWindow2",imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8"",bindersettings.binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').y - 135) / 2)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then
					imgui.InputText("##bindersettings.bindername", bindersettings.bindername,imgui.InputTextFlags.ReadOnly)
				else
					imgui.InputText("##bindersettings.bindername", bindersettings.bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(" ",bindersettings.bindertype, u8"������������ �������\0������������ �������\0\0", 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� �����:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'�������� ����� �������� (ms):').y - 70) / 2)
				imgui.Text(u8'�������� ����� �������� (ms):'); imgui.SameLine()
				imgui_Hint('���������� �������� � �������������\n{FFFFFF}1 ������� = 1.000 �����������')
				imgui.PushItemWidth(58)
				imgui.InputText("##bindersettings.binderdelay", bindersettings.binderdelay, imgui.InputTextFlags.CharsDecimal)
				imgui.PopItemWidth()
				imgui.SameLine()
				if bindersettings.bindertype.v == 0 then
					imgui.Text("/")
					imgui.SameLine()
					imgui.PushItemWidth(147)
					imgui.InputText("##bindersettings.bindercmd",bindersettings.bindercmd,imgui.InputTextFlags.CharsNoBlank)
					imgui.PopItemWidth()
				elseif bindersettings.bindertype.v == 1 then
					if binderkeystatus == nil or binderkeystatus == "" then
						binderkeystatus = u8"������� ����� ��������"
					end
					if imgui.Button(binderkeystatus) then
						if binderkeystatus == u8"������� ����� ��������" then
							binderkeystatus = u8"������� ����� �������"
							setbinderkey = true
						elseif binderkeystatus == u8"������� ����� �������" then
							setbinderkey = false
							binderkeystatus = u8"������� ����� ��������"
						elseif string.find(binderkeystatus, u8"���������") then
							setbinderkey = false
							binderkeystatus = string.match(binderkeystatus,u8"��������� (.+)")
						else
							binderkeystatus = u8"������� ����� �������"
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
				if bindersettings.binderbuff.v ~= "" and bindersettings.bindername.v ~= "" and bindersettings.binderdelay.v ~= "" and bindersettings.bindertype.v ~= nil then
					if imgui.Button(u8"���������",imgui.ImVec2(100,30)) then
						if not inprocess then
							if bindersettings.bindertype.v == 0 then
								if bindersettings.bindercmd.v ~= "" and bindersettings.bindercmd.v ~= nil then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											if tostring(configuration.BindsKeys[key]):match("(.+) %p (.+)") then
												local fkey = tostring(configuration.BindsKeys[key]):match("(.+) %p")
												local skey = tostring(configuration.BindsKeys[key]):match("%p (.+)")
												rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true), vkeys.name_to_id(skey,true)})
											elseif tostring(configuration.BindsKeys[key]):match("(.+)") then
												local fkey = tostring(configuration.BindsKeys[key]):match("(.+)")
												rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true)})
											end
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub("\n", "~")
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = u8:decode(bindersettings.bindercmd.v)
										configuration.BindsKeys[kei] = ""
										if inicfg.save(configuration, "AS Helper") then
											ASHelperMessage("���� ������� �������!")
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ""
											bindersettings.binderbuff.v = ""
											bindersettings.bindername.v = ""
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ""
											bindersettings.bindercmd.v = ""
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub("\n", "~")
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsCmd, u8:decode(bindersettings.bindercmd.v))
										table.insert(configuration.BindsKeys, "")
										if inicfg.save(configuration, "AS Helper") then
											ASHelperMessage("���� ������� ������!")
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ""
											bindersettings.binderbuff.v = ""
											bindersettings.bindername.v = ""
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ""
											bindersettings.bindercmd.v = ""
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage("�� ����������� ������� ������� �����!")
								end
							elseif bindersettings.bindertype.v == 1 then
								if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= "������� ����� ��������" and not string.find((u8:decode(binderkeystatus)), "��������� ") and (u8:decode(binderkeystatus)) ~= "������� ����� �������" then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											if tostring(configuration.BindsKeys[key]):match("(.+) %p (.+)") then
												local fkey = tostring(configuration.BindsKeys[key]):match("(.+) %p")
												local skey = tostring(configuration.BindsKeys[key]):match("%p (.+)")
												rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true), vkeys.name_to_id(skey,true)})
											elseif tostring(configuration.BindsKeys[key]):match("(.+)") then
												local fkey = tostring(configuration.BindsKeys[key]):match("(.+)")
												rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true)})
											end
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub("\n", "~")
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = ""
										configuration.BindsKeys[kei] = u8(binderkeystatus)
										if inicfg.save(configuration, "AS Helper") then
											ASHelperMessage("���� ������� �������!")
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ""
											bindersettings.binderbuff.v = ""
											bindersettings.bindername.v = ""
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ""
											bindersettings.bindercmd.v = ""
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub("\n", "~")
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsKeys, u8(binderkeystatus))
										table.insert(configuration.BindsCmd, "")
										if inicfg.save(configuration, "AS Helper") then
											ASHelperMessage("���� ������� ������!")
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ""
											bindersettings.binderbuff.v = ""
											bindersettings.bindername.v = ""
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ""
											bindersettings.bindercmd.v = ""
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage("�� ����������� ������� ������� �����!")
								end
							end
							updatechatcommands()
							updatechatkeys()
						else
							ASHelperMessage("�� �� ������ ����������������� � �������� �� ����� ����� ���������!")
						end	
					end
				else
					LockedButton(u8"���������",imgui.ImVec2(100,30))
					imgui_Hint("�� ����� �� ��� ���������. ������������� ��.")
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8"��������",imgui.ImVec2(100,30)) then
					setbinderkey = false
					keyname = nil
					keyname2 = nil
					bindersettings.bindercmd.v = ""
					bindersettings.binderbuff.v = ""
					bindersettings.bindername.v = ""
					bindersettings.bindertype.v = 0
					bindersettings.binderdelay.v = ""
					bindersettings.bindercmd.v = ""
					binderkeystatus = nil
					updatechatcommands()
					updatechatkeys()
					choosedslot = nil
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230,180))
				imgui.Text(u8"�������� ���� ��� �������� ����� ��� ���� ��������������.")
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 10) / 2)
			if imgui.Button(u8"��������",imgui.ImVec2(82,30)) then
				choosedslot = 50
				bindersettings.binderbuff.v = ''
				bindersettings.bindername.v = ''
				bindersettings.bindertype.v = 0
				bindersettings.bindercmd.v = ''
				binderkeystatus = nil
				bindersettings.binderdelay.v = ''
				updatechatcommands()
				updatechatkeys()
			end
			imgui.SameLine()
			if choosedslot ~= nil and choosedslot ~= 50 then
				if imgui.Button(u8"�������",imgui.ImVec2(82,30)) then
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							local value = tostring(value)
							if u8:decode(bindersettings.bindername.v) == tostring(configuration.BindsName[key]) then
								sampUnregisterChatCommand(configuration.BindsCmd[key])
								if tostring(configuration.BindsKeys[key]):match("(.+) %p (.+)") then
									local fkey = tostring(configuration.BindsKeys[key]):match("(.+) %p")
									local skey = tostring(configuration.BindsKeys[key]):match("%p (.+)")
									rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true), vkeys.name_to_id(skey,true)})
								elseif tostring(configuration.BindsKeys[key]):match("(.+)") then
									local fkey = tostring(configuration.BindsKeys[key]):match("(.+)")
									rkeys.unRegisterHotKey({vkeys.name_to_id(fkey,true)})
								end
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
									bindersettings.bindercmd.v = ""
									bindersettings.binderbuff.v = ""
									bindersettings.bindername.v = ""
									bindersettings.bindertype.v = 0
									bindersettings.binderdelay.v = ""
									bindersettings.bindercmd.v = ""
									binderkeystatus = nil
									choosedslot = nil
									ASHelperMessage("���� ������� �����!")
								end
							end
						end
					updatechatcommands()
					updatechatkeys()
					else
						ASHelperMessage("�� �� ������ ������� ���� �� ����� ����� ���������!")
					end
				end
			else
				LockedButton(u8"�������",imgui.ImVec2(82,30))
				imgui_Hint("�������� ���� ������� ������ �������",0)
			end
			imgui.End()
		end

		if windows.imgui_stats.v then
			imgui.SetNextWindowSize(imgui.ImVec2(150, 195), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(configuration.imgui_pos.posX,configuration.imgui_pos.posY),imgui.Cond.FirstUseEver)
			imgui.Begin(u8"����������  ##stats",_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize)
			if imgui.IsMouseDoubleClicked(0) then
				local pos = imgui.GetWindowPos()
				configuration.imgui_pos.posX = pos.x
				configuration.imgui_pos.posY = pos.y
				if inicfg.save(configuration, 'AS Helper.ini') then
					ASHelperMessage('������� ���� ���������.')
				end
			end
			imgui.Text(fa.ICON_FA_CAR..u8" ���� - "..configuration.my_stats.avto)
			imgui.Text(fa.ICON_FA_MOTORCYCLE..u8" ���� - "..configuration.my_stats.moto)
			imgui.Text(fa.ICON_FA_FISH..u8" ����������� - "..configuration.my_stats.riba)
			imgui.Text(fa.ICON_FA_SHIP..u8" �������� - "..configuration.my_stats.lodka)
			imgui.Text(fa.ICON_FA_CROSSHAIRS..u8" ������ - "..configuration.my_stats.guns)
			imgui.Text(fa.ICON_FA_SKULL_CROSSBONES..u8" ����� - "..configuration.my_stats.hunt)
			imgui.Text(fa.ICON_FA_ARCHIVE..u8" �������� - "..configuration.my_stats.klad)
			imgui.End()
		end
	end
end

function checkbibl()
	local doupdate = nil
	if not sampevcheck then
		ASHelperMessage("����������� ���������� samp events. ������� � ����������.")
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events.lua', 'moonloader/lib/samp/events.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/raknet.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/synchronization.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/bitstream_io.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/core.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/extra_types.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/handlers.lua') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/samp/events/utils.lua') then
					ASHelperMessage("���������� samp events ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not encodingcheck then
		ASHelperMessage("����������� ���������� encoding. ������� � ����������.")
		if doesFileExist('moonloader/lib/encoding.lua') then
			os.remove('moonloader/lib/encoding.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/encoding.lua') then
					ASHelperMessage("���������� encoding ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not imguicheck then
		ASHelperMessage("����������� ���������� imgui. ������� � ����������.")
		if doesFileExist('moonloader/lib/imgui.lua') then
			os.remove('moonloader/lib/imgui.lua')
		end
		if doesFileExist('moonloader/lib/MoonImGui.dll') then
			os.remove('moonloader/lib/MoonImGui.dll')
		end
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/MoonImGui.dll', 'moonloader/lib/MoonImGui.dll', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/MoonImGui.dll') then
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		wait(300)
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/imgui.lua') then
					ASHelperMessage("���������� imgui ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not rkeyscheck then
		ASHelperMessage("����������� ���������� rkeys. ������� � ����������.")
		if doesFileExist('moonloader/lib/rkeys.lua') then
			os.remove('moonloader/lib/rkeys.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/rkeys.lua', 'moonloader/lib/rkeys.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/rkeys.lua') then
					ASHelperMessage("���������� rkeys ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not facheck then
		ASHelperMessage("����������� ���������� fAwesome5. ������� � ����������.")
		if doesFileExist('moonloader/lib/fAwesome5.lua') then
			os.remove('moonloader/lib/fAwesome5.lua')
		end
		downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/fAwesome5.lua', 'moonloader/lib/fAwesome5.lua', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/lib/fAwesome5.lua') then
					ASHelperMessage("���������� fAwesome5 ���� ������� �����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage("����������� ���� ������. ������� ��� ����������.")
		createDirectory('moonloader/resource/fonts')
		downloadUrlToFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf', function(id, status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
					ASHelperMessage("���� ������ ��� ������� ����������.")
					NoErrors = true
					thisScript():reload()
				else
					ASHelperMessage("��������� ������ �� ����� ���������.")
					thisScript():unload()
				end
			end
		end)
		return false
	end
	if doesFileExist('moonloader/config/updateashelper.ini') then
		os.remove('moonloader/config/updateashelper.ini')
	end
	createDirectory('moonloader/config')
	downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/update.ini', 'moonloader/config/updateashelper.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/config/updateashelper.ini') then
				local updates = io.open('moonloader/config/updateashelper.ini','r')
				local tempdata = {}
				for line in updates:lines() do
					table.insert(tempdata, line)
				end
				io.close(updates)
				if tonumber(tempdata[1]) > thisScript().version_num then
					ASHelperMessage("������� ����������. ������� ���������� ���.")
					doupdate = true
				else
					ASHelperMessage("���������� �� �������.")
					doupdate = false
				end
				os.remove('moonloader/config/updateashelper.ini')
			else
				ASHelperMessage("��������� ������ �� ����� �������� ����������.")
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
				ASHelperMessage("���������� ������� �����������.")
			end
		end)
		return false
	end
	return true
end