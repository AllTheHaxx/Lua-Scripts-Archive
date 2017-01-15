g_ScriptTitle = "Skin Copy Cat"
g_ScriptInfo = "Write '!skin name' in the chat to copy the skin of 'name'. | by the AllTheHaxx-Team"

function GetPlayerID(Name)
	for i = 0, 64 do
		if Game.Players(i).Name == Name then
			return i
		end
	end
end

function Skin(ID, Team, Msg)
	if ID ~= Game.LocalCID then return end -- only you can use it

	if Msg:find("!skin") then -- does the message contain "!skin"?
		local Name = Msg:gsub("!skin ", "") -- remove "!skin" from the message

		Name = string.gsub(Name, " ", "") -- remove all spaces from string

		-- get all the player's info
		local SkinName = Game.Players(GetPlayerID(Name)).SkinName
		local UseCColor = Game.Players(GetPlayerID(Name)).UseCustomColor
		local ColorBody = Game.Players(GetPlayerID(Name)).ColorBody
		local ColorFeet = Game.Players(GetPlayerID(Name)).ColorFeet

		-- set the config vars
		Config.Skin = SkinName
		Config.PlayerUseCustomColor = UseCColor
		Config.PlayerColorBody = ColorBody
		Config.PlayerColorFeet = ColorFeet
		Game.Client:SendInfo(false) -- send the updated info to the server
	end
end

RegisterEvent("OnChat", "Skin")
