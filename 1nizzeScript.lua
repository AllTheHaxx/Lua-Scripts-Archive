g_ScriptTitle = "1 nizze script"
g_ScriptInfo = "german lolkids only"

q ={}

function OnChat(ID, Team, Msg)
	local New = Msg:gsub("einen", "1"):gsub("eins", "1"):gsub("eine", "1"):gsub("ein", "1")
	Game.Chat:Print(ID, Team, New, false) -- add the modified line and...
	return true -- ...hide the original one
end

function OnChatSend(Team, Msg)
	if Msg:sub(-1, -1) == " " then return end

	local New = Msg:gsub("einen", "1"):gsub("eins", "1"):gsub("eine", "1"):gsub("ein", "1")
	table.insert(q, Team..New)
	
	return true -- don't send
end

Last = 0
function OnTick() -- queue worker
	if Game.Client.LocalTime < Last + 3 or #q == 0 then return end
	Last = Game.Client.LocalTime
	--print(q[1])
	Game.Chat:Say(tonumber(q[1]:sub(1,1)), q[1]:sub(2,-1).." ")
	table.remove(q, 1)
end
