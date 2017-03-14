--[[#!
	#io
	#os
]]--#

g_ScriptTitle = "Chat Logger"
g_ScriptInfo = "Archive your chatlogs. | By The AllTheHaxx-Team\n\n\nThanks to Nibiru for updating it for 0.30"

File = io.open("chatlog.txt", "a")
File:write("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
File:write(os.date("~~~~~ STARTED LOGGER AT %d-%m-%y %H:%M:%S ~~~~~\n"))
File:write("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
File:flush()

function Logger(ID, Team, Msg)
	local Date = os.date("[%d-%m-%y %H:%M:%S]")
	local Name = Game.Players(ID).Name
	local Line = ""
	if Game.Client.State == 3 then
		if ID ~= -1 then
			Line = Date.." "..Name..": "..Msg.."\n"
		else
			Line = Date.." ".."***".." "..Msg.."\n"
		end
		if string.len (Msg) > 0 then
			File:write(Line)
			File:flush()
		end
	end
end

function OnScriptUnload()
	File:close()
	print("script unload, closing file")
end

RegisterEvent("OnChat", "Logger")
