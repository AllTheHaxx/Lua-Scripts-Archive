g_ScriptTitle = "KoG|LvL Frontend"
g_ScriptInfo = "Graphical Client Addon for KoG|LvL | © 2016 Henritees / The AllTheHaxx Team" -- you may not remove the copyright notice

DELAY = 2
LoggedIn = false
GStats = {}
GChatQueue = {}
GChatQueue.size = 0
GLastChat = 0

WantStatsUpdate = false

function IsKoGDM()
	return string.lower(Game.ServerInfo.GameMode) == "kog|dm"
end

function IsBuild()
	return string.lower(Game.ServerInfo.GameMode) == "build"
end

function OnStateChange(Old, New)
	-- TODO register/remove events... or not, dunno.
end

function SendChat(Msg)
	if IsBuild() and Msg:lower() == "/stats" then return end -- command not available on build
	table.insert(GChatQueue, Msg) -- insert message into queue
	GChatQueue.size = GChatQueue.size + 1 -- increase counter by one
end

function OnChatSend(Team, Msg)
	if Game.Client.LocalTime < GLastChat + DELAY then
		Game.Chat:AddLine(-2, 0, "Sorry, message has not been sent due to spam protection")
		return true
	end
	GLastChat = Game.Client.LocalTime
end

function QueueWorker()
	if GChatQueue.size == 0 then return end -- nothing left to say...
	if Game.Client.LocalTime < GLastChat + DELAY then return end -- no spam
	Game.Chat:Say(0, GChatQueue[1]) -- add the message to the queue
	GLastChat = Game.Client.LocalTime -- used above for spamprotection
	table.remove(GChatQueue, 1) -- remove the message from the table
	GChatQueue.size = GChatQueue.size - 1 -- substract one from the counter
end


function OnChat(ID, Team, Msg)
	if ID ~= -1 then return false end
	if IsKoGDM() == false and IsBuild() == false then return false end
	
	
	-- logged in
	if Msg == "Login sucessful!" then
		LoggedIn = true
		SendChat("/stats") -- request stats
		return false
	end
	
	-- logged out
	if Msg == "Logout sucessful!" then
		LoggedIn = false
		return false
	end
	
	if Msg == "Level up!" then
		PushBigNumber("Level up!")
		GStats["Exp"] = 0
		GStats["NeedExp"] = GStats["NeedExp"] + 1
		SendChat("~°(LVL UP)°~")
		SendChat("/stats")
	end
	
	-- debug
	--for k,v in next, GStats do
	--	print(k.. "=" ..v)
	--end
	
	-- Exp: |->--------| 4/30
	if string.find(Msg, "Exp: ") ~= nil then
		Extract = Msg:match("%d+/%d+")
		Split = Extract:find("/")
		OldExp = GStats["Exp"]
		GStats["NeedExp"] = tonumber(Extract:sub(Split+1, -1))
		GStats["Exp"] = tonumber(Extract:sub(0, Split-1))
		if Msg:find("|") ~= nil then
			if tonumber(Extract:sub(0, Split-1)) < tonumber(Extract:sub(Split+1, -1)) then
				PushBigNumber("+" .. GStats["Exp"]-OldExp)
			end
			return true
		end
	end
	
	-- Hammer: 0 - Gun: 0 - Shotgun: 0 - Grenade: 0
	StatsParser = Msg:match("%g+: %d+ %- %g+: %d+ %- %g+: %d+ %- %g+: %d+") 
	if StatsParser ~= nil then
		for i = 0, 3 do
			Current = StatsParser:match("%g+: %d+")
			From, To = StatsParser:find(Current)
			GStats[Current:match("%g+"):sub(0, -2)] = tonumber(Current:match("%d+"))
			StatsParser = StatsParser:sub(To+1, -1)
		end
		return true
	end
	
	-- Rifle: 10 - Life: 0 - Handle: 5
	-- Level: 17 - Money: 10 - Exp: 14/17
	StatsParser = Msg:match("%g+: %d+ %- %g+: %d+ %- %g+: %d+")
	if StatsParser ~= nil then
		for i = 0, 2 do
			Current = StatsParser:match("%g+: %d+")
			From, To = StatsParser:find(Current)
			GStats[Current:match("%g+"):sub(0, -2)] = tonumber(Current:match("%d+"))
			StatsParser = StatsParser:sub(To+1, -1)
			WantStatsUpdate = false
			LoggedIn = true
		end
		return true
	end
	
	-- upgrade
	if string.match(Msg, "Upgrade: %g+ is now on level: %d+") ~= nil then
		--SendChat("/stats") -- re-request the stats
		return true
	end
	
end


function RenderLogin()

	SCREEN = Game.Ui:Screen()
	MainView = UIRect(SCREEN.x, SCREEN.y, SCREEN.w, SCREEN.h)
	
	MainView:HSplitTop(SCREEN.h/4, nil, MainView)
	MainView:HSplitBottom(SCREEN.h/2.7, MainView, nil)
	MainView:VMargin(SCREEN.w/3, MainView)
	MainView:Margin(30.0, MainView)
	
	Game.RenderTools:DrawUIRect(MainView, vec4f(0,0,0,0.5), 15, 5)
	
	MainView:VMargin(10.0, MainView)
	Button = MainView
	MainView:HSplitTop(10, Button, MainView)
	Game.Ui:DoLabelScaled(Button, "KoG|LvL - Login Screen", 20.0, 0, -1, "")
	
	MainView:HSplitTop(25, nil, MainView)
	MainView:HSplitTop(10, Button, MainView)
	Game.Ui:DoLabelScaled(Button, "Unfortunately, nothing here yet :p", 10.0, -1, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(10, Button, MainView)
	Game.Ui:DoLabelScaled(Button, "Please login manually.", 10.0, -1, -1, "")
	
end

function RenderStats()
	SCREEN = Game.Ui:Screen()
	MainView = UIRect(SCREEN.x, SCREEN.y, SCREEN.w, SCREEN.h)
	
	MainView:HSplitTop(SCREEN.h/5, nil, MainView)
	MainView:HSplitBottom(SCREEN.h/5, MainView, nil)
	MainView:VMargin(SCREEN.w/3, MainView)
	MainView:Margin(30.0, MainView)
	
	Game.RenderTools:DrawUIRect(MainView, vec4f(0,0,0,0.5), 15, 5)
	
	Upgr = UIRect(MainView.x, MainView.y, MainView.w, MainView.h)
	RenderStatsUpgr(Upgr)
end

Upgrades = {}
Upgrades.Hammer = 0
Upgrades.Gun = 0
Upgrades.Shotgun = 0
Upgrades.Grenade = 0
Upgrades.Rifle = 0
Upgrades.Handle = 0
Upgrades.Life = 0

GStats.Level = "NaN"
GStats.Exp = -1
GStats.NeedExp = -1
GStats.Money = -1
GStats.Hammer = -1
GStats.Gun = -1
GStats.Shotgun = -1
GStats.Grenade = -1
GStats.Rifle = -1
GStats.Handle = -1
GStats.Life = -1
function RenderStatsUpgr(Screen)
	MainView = UIRect(Screen.x, Screen.y, Screen.w, Screen.h)
	MainView:HSplitTop(17, nil, MainView)
	MainView:VMargin(MainView.w/10, MainView)
	Button = UIRect(MainView.x, MainView.y, MainView.w, MainView.h)
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Level: " .. GStats.Level, 13.0, -1, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Exp: " .. GStats.Exp .. "/" .. GStats.NeedExp .. " = " .. math.floor((GStats.Exp/GStats.NeedExp)*100) .. "%", 13.0, -1, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Money: " .. GStats.Money .. " = " .. GStats.Money/5 .. " Upgrades", 13.0, -1, -1, "")
	
	MainView:HSplitTop(10, nil, MainView)
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Hammer: " .. GStats.Hammer .. " + " .. Upgrades.Hammer, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr hammer")
				Upgrades["Hammer"] = Upgrades["Hammer"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Gun: " .. GStats.Gun .. " + " .. Upgrades.Gun, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr gun")
				Upgrades["Gun"] = Upgrades["Gun"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Shotgun: " .. GStats.Shotgun .. " + " .. Upgrades.Shotgun, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr shotgun")
				Upgrades["Shotgun"] = Upgrades["Shotgun"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Grenade: " .. GStats.Grenade .. " + " .. Upgrades.Grenade, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr grenade")
				Upgrades["Grenade"] = Upgrades["Grenade"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Rifle: " .. GStats.Rifle .. " + " .. Upgrades.Rifle, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr rifle")
				Upgrades["Rifle"] = Upgrades["Rifle"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(10, nil, MainView)
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Life: " .. GStats.Life .. " + " .. Upgrades.Life, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr life")
				Upgrades["Life"] = Upgrades["Life"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Game.Ui:DoLabelScaled(Button, "Handle: " .. GStats.Handle .. " + " .. Upgrades.Handle, 13.0, -1, -1, "")
	Button:VSplitRight(100, nil, Button)
	Color = vec4f(1,0,0,1)
	if Game.Ui:MouseInside(Button) == 1 then
		if Game.Ui:MouseButtonClicked(0) == 1 then
			Color = vec4f(0,0,1,1)
			if GStats["Money"] >= 5 then
				--SendChat("/upgr handle")
				Upgrades["Handle"] = Upgrades["Handle"] + 1
				GStats["Money"] = GStats["Money"] - 5
			end
		else
			Color = vec4f(0,1,0,1)
		end
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, "→ Upgrade", 13.0, 0, -1, "")
	
	MainView:HSplitTop(15, nil, MainView)
	MainView:HSplitTop(5, nil, MainView)
	MainView:HSplitTop(17, Button, MainView)
	Button:VSplitLeft(MainView.w/3, Button, MainView)
	Button.x = Button.x - 10
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Color = vec4f(1,0,0,1)
	Text = "Update Stats"
	if WantStatsUpdate == false then
		if Game.Ui:MouseInside(Button) == 1 then
			if Game.Ui:MouseButtonClicked(0) == 1 then
				Color = vec4f(0,0,1,1)
				SendChat("/stats")
				WantStatsUpdate = true
			else
				Color = vec4f(0,1,0,1)
			end
		end
	else
		Text = "please wait"
		Color = vec4f(1,1,0,1)
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, Text, 13.0, 0, -1, "")
	
	MainView:VSplitLeft(MainView.w/2, Button, MainView)
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Color = vec4f(1,0,0,1)
	Text = "Apply Changes"
	if WantStatsUpdate == false then
		if Game.Ui:MouseInside(Button) == 1 then
			if Game.Ui:MouseButtonClicked(0) == 1 then
				Color = vec4f(0,0,1,1)
				for k, v in next, Upgrades do
					if v > 0 then
						SendChat("/upgr " .. k:lower() .. " " .. v)
						Upgrades[k] = 0
					end
				end
				SendChat("/stats")
				WantStatsUpdate = true
			else
				Color = vec4f(0,1,0,1)
			end
		end
	else
		Text = "please wait"
		Color = vec4f(1,1,0,1)
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, Text, 13.0, 0, -1, "")
	
	MainView:VSplitLeft(MainView.w/1, Button, MainView)
	Button.x = Button.x + 10
	Game.RenderTools:DrawUIRect(Button, vec4f(0.5,0.5,0.5,0.5), 15, 5)
	Color = vec4f(1,0,0,1)
	Text = "Discard Changes"
	if WantStatsUpdate == false then
		if Game.Ui:MouseInside(Button) == 1 then
			if Game.Ui:MouseButtonClicked(0) == 1 then
				Color = vec4f(0,0,1,1)
				for k, v in next, Upgrades do
					GStats.Money = GStats.Money + 5*v
					Upgrades[k] = 0
				end
				--WantStatsUpdate = true
			else
				Color = vec4f(0,1,0,1)
			end
		end
	else
		Text = "please wait"
		Color = vec4f(1,1,0,1)
	end
	Game.RenderTools:DrawUIRect(Button, Color, 15, 5)
	Game.Ui:DoLabelScaled(Button, Text, 13.0, 0, -1, "")	

end



BigNumbers = {}
for i = 0, 10 do
	BigNumbers[i] = {}
	BigNumbers[i].Text = ""
	BigNumbers[i].FadeVal = 0.0
end

function PushBigNumber(str)
	for i, t in next, BigNumbers do
		if t.Text == "" then
			BigNumbers[i].Text = str
			BigNumbers[i].FadeVal = 1.0
			return
		end
	end
end

function RenderBigNumbers(MainView)
	Label = UIRect(MainView.x, MainView.y, MainView.w, MainView.h)
	for i, t in next, BigNumbers do
		if t.Text ~= "" then
			Size = 22
			if t.Text == "Level up!" then Size = Size + 3 end
			Label.y = Label.y + Size * t.FadeVal
			-- TODO: Text color! (alpha)
			Game.Ui:DoLabelScaled(Label, t.Text, Size, 0, -1, "Level up!")
			BigNumbers[i].FadeVal = BigNumbers[i].FadeVal - BigNumbers[i].FadeVal/35
			if BigNumbers[i].FadeVal < 0.1 then BigNumbers[i].Text = "" end
		end
	end
end


function RenderHUD()	
	SCREEN = Game.Ui:Screen()
	MainView = UIRect(SCREEN.x, SCREEN.y, SCREEN.w, SCREEN.h)
	
	MainView:HSplitTop(25, MainView, nil)
	MainView.y = MainView.h+10
	MainView:VMargin(SCREEN.w/2.5, MainView)
	
	Game.RenderTools:DrawUIRect(MainView, vec4f(0,0,0,0.5), 15, 5)

	if GStats["Exp"] ~= nil and GStats["NeedExp"] ~= nil then -- do the green bar only if we have the stats
		Bar = UIRect(MainView.x, MainView.y, MainView.w, MainView.h)
		Bar:Margin(3, Bar)
		Bar.w = 10+(Bar.w-10) * (GStats["Exp"] / GStats["NeedExp"])
		Game.RenderTools:DrawUIRect(Bar, vec4f(0,1,0,0.5), 15, 5)
	end
	
	MainView.y = MainView.y + 3
	Label = "?/?"
	if GStats["Exp"] >= 0 and GStats["NeedExp"] >= 0 then
		Label = GStats["Exp"] .. "/" .. GStats["NeedExp"]
	end
	Game.Ui:DoLabelScaled(MainView, Label, 15.7, 0, -1, "")
	
	MainView.y = MainView.y + MainView.h/4
	RenderBigNumbers(MainView)
end

function OnRender()
	if IsKoGDM() == false and IsBuild() == false then return end
	Engine.Graphics:MapScreen(0, 0, Game.Ui:Screen().w, Game.Ui:Screen().h)
	
	-- we are there if we are there!
	if LoggedIn == false and Game.Players(Game.LocalCID).Team ~= -1 and string.sub(Game.Players(Game.LocalCID).Name, 0, 7) ~= "[Guest]" or (Game.Players(Game.LocalCID).Name ~= Config.PlayerName and string.sub(Game.Players(Game.LocalCID).Name, 0, 3) ~= "[N]") then
		LoggedIn = true
		SendChat("/stats")
	end
	

	if Game.Menus.Active and Game.Menus.ActivePage == 3 then
		if LoggedIn == false then
			RenderLogin()
		else
			if string.lower(Game.ServerInfo.GameMode) == "kog|dm" then RenderStats() end
		end
	else
		if not Game.Menus.Active then RenderHUD() end
	end
	
	--Game.Ui:DoLabelScaled(Rect, "Testlabel! KATZE! :3", 20.0, 0, -1, "")
	--Game.RenderTools:DrawUIRect(Game.Ui:Screen(), vec4f(math.sin(Game.Client.LocalTime+3.1415), math.sin(Game.Client.LocalTime), 1.0, math.sin(Game.Client.LocalTime)), 15, 5)
end

RegisterEvent("OnChat", "OnChat")
RegisterEvent("OnTick", "QueueWorker")
RegisterEvent("OnRenderLevel23", "OnRender")

