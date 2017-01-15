--[[#!
	#io
]]--#

g_ScriptTitle = "Graphicstest."
g_ScriptInfo = "Has no sense, but is epic. | (c) 2016 Henritees"

Import("config")
_ConfigSet("NumRects", 5)
_ConfigSet("RectOffset", 41)
_ConfigLoad()
_ConfigSave()

--Config = {}
--Config.NumRects = 5
--Config.RectOffset = 42

BCs = {} -- button containers

function DrawFunnyRect(i)
	t = Game.Client.LocalTime+i*OFFSET
	v = (math.sin(t*1.5)+1)/2
	x = (math.sin(t)+1)/2
	y = (math.cos(t)+1)/2
	Engine.Graphics:SetColor(v, x, y, 0.6)
	Game.RenderTools:DrawSprite(v*1500*x+130, v*800*y+150, (v+0.3)*100)
end

function Render()
	NUM_RECTS = _ConfigGet("NumRects")
	OFFSET = _ConfigGet("RectOffset") / 10

	Engine.Graphics:TextureSet(-1)
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:MapScreen(0, 0, 1600, 900)
		for i = 0, NUM_RECTS do
			DrawFunnyRect(i)
		end
	Engine.Graphics:QuadsEnd()
end

---------------------------------------------------------------------------

function RenderPlayerBg(CID, PX, PY, DX, DY, T)
	--print(Game.Players(CID).Name .. " @ (" .. PX .. " " .. PY .. ")")
	Engine.Graphics:TextureSet(-1)
	--Engine.Graphics:MapScreen(0, 0, 1600, 400)
	Engine.Graphics:QuadsBegin()
	Engine.Graphics:SetColor(0.8, 0.2, 0.2, 0.7)
		ScreenX = PX-Game.LocalTee.Pos.x
		ScreenY = PY-Game.LocalTee.Pos.y
		q = QuadItem(PX+12*math.cos(Game.Client.LocalTime*2), PY+12*math.sin(Game.Client.LocalTime*2), 32*2, 32*2)
		Engine.Graphics:QuadsDraw(q, 1)
		--print(ScreenX .. " " .. ScreenY)
	Engine.Graphics:QuadsEnd()
end

---------------------------------------------------------------------------

function OnScriptInit()
	for i = 0, 6 do
		BCs[i] = ButtonContainer()
	end
	--Import("graphicstest.config")
	return true
end

function OnScriptRenderSettings(MainView)
	-- just a red rect, much lame ._.
	--_ui.SetUiColor(1,0,0,0.3)
	--Game.RenderTools:DrawUiRect(x, y, w, h, 15, 3.0)
	
	ButtonBar, Button = UIRect(0,0,0,0), UIRect(0,0,0,0)
	MainView:HSplitTop(10, nil, MainView)
	MainView:HSplitTop(35, ButtonBar, MainView)
	
	ButtonBar:VSplitLeft(20, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if _ConfigGet("NumRects") > 1 then
		if Game.Menus:DoButton_Menu(BCs[0], "←", 0, Button, "decrease", 15, vec4f(1,1,1,0.5)) ~= 0 then
			_ConfigSet("NumRects", _ConfigGet("NumRects") - 1)
		--	if Config.NumRects < 1 then
		--		Config.NumRects = 1
		--	end
		end
	end
	
	ButtonBar:VSplitLeft(5, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if Game.Menus:DoButton_Menu(BCs[1], _ConfigGet("NumRects"), 0, Button, "decrease", 15, vec4f(1,1,1,0.5)) ~= 0 then
		_ConfigSet("NumRects", 5)
	end

	ButtonBar:VSplitLeft(5, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if Game.Menus:DoButton_Menu(BCs[2], "→", 0, Button, "increase", 15, vec4f(1,1,1,0.5)) ~= 0 then
		_ConfigSet("NumRects", _ConfigGet("NumRects") + 1)
	end
	
	---------------------------------------------------------------------------
	
	MainView:HSplitTop(10, nil, MainView)
	MainView:HSplitTop(35, ButtonBar, MainView)
	
	ButtonBar:VSplitLeft(20, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if _ConfigGet("RectOffset") > 2 then
		if Game.Menus:DoButton_Menu(BCs[3], "←", 0, Button, "decrease", 15, vec4f(1,1,1,0.5)) ~= 0 then
			_ConfigSet("RectOffset", _ConfigGet("RectOffset")-2)
		--	if Config.RectOffset < 1 then
		--		Config.RectOffset = 1
		--	end
		end
	end
	
	ButtonBar:VSplitLeft(5, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if Game.Menus:DoButton_Menu(BCs[4], _ConfigGet("RectOffset"), 0, Button, "reset", 15, vec4f(1,1,1,0.5)) ~= 0 then
		_ConfigSet("RectOffset", 41)
	end

	ButtonBar:VSplitLeft(5, nil, ButtonBar)
	ButtonBar:VSplitLeft(35, Button, ButtonBar)
	if Game.Menus:DoButton_Menu(BCs[5], "→", 0, Button, "increase", 15, vec4f(1,1,1,0.5)) ~= 0 then
		_ConfigSet("RectOffset", _ConfigGet("RectOffset")+2)
	end
end

RegisterEvent("PreRenderPlayer", "RenderPlayerBg")
RegisterEvent("OnRenderLevel14", "Render")
