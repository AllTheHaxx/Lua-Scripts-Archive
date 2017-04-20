g_ScriptTitle = "Snake"
g_ScriptInfo = "Snake from the K-Client.\nUsage: Arrowkeys"

-- global vars
Size = 15

-- arena vars
MainQuad = {}
Quads = {}
QuadPos = {}
QuadSize = 50
LineSize = 5

-- snake vars
SnakeSize = 4
SnakePos = {}
Posx = 128
Posy = 128
Snake = {}
Mode = 1 -- 1 = right, 2 = left, 3 = up and 4 = down
SnakeTime = Game.Client.LocalTime+0.2
Apple = {}
ApplePos = {}

IsFullscreen = false -- Actually dont use this var ;)

function OnScriptInit()
		EnterFullscreen()
		CreateArena()
		CreateSnake()
		CreateApple()
		-- if not IsFullscreen then error("Snake is only playable in the fullscreen mode!") end
	return true
end

function OnEnterFullscreen()
	IsFullscreen = true
	print("enter fullscreen")
end

function OnExitFullscreen()
	IsFullscreen = false
	print("exit fullscreen")
end

function CreateArena()
	local x = 0-Size/2
	local y = 1-Size/2
	while (true) do
		if x < Size/2 then
			table.insert(Quads,QuadItem(Engine.Graphics.ScreenWidth/2+(x*QuadSize)+LineSize*x,Engine.Graphics.ScreenHeight/2+(y*QuadSize)+LineSize*y,QuadSize,QuadSize))
			table.insert(QuadPos,vec2f(Engine.Graphics.ScreenWidth/2+(x*QuadSize)+LineSize*x,Engine.Graphics.ScreenHeight/2+(y*QuadSize)+LineSize*y))
			x = x+1
		else
			if y < Size/2 then
				y=y+1
				x = 0-Size/2
			else
				table.insert(MainQuad,QuadItem(Engine.Graphics.ScreenWidth/2-QuadSize/2-LineSize/2,Engine.Graphics.ScreenHeight/2+QuadSize/2+LineSize/2,QuadSize*(Size+1)-Size/2+LineSize*Size/2,QuadSize*(Size+1)+Size/2+LineSize/2*Size/2))
				break
			end
		end
	end
end

function CreateSnake()
	for i = 1, SnakeSize do
		Posx = Posx+1
		table.insert(SnakePos,vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
		table.insert(Snake,QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
	end
end

function SnakeMove()
	
	if Mode == 1 then
		Posx = Posx+1
		if Posx == 15 or Posx == 30 or Posx == 45 or Posx == 60 or Posx == 75 or Posx == 90 or Posx == 105 or Posx == 120 or Posx == 135 or Posx == 150 or Posx == 165 or Posx == 180 or Posx == 210 or Posx == 225 then
			Posx = Posx-15
		end
		table.remove(SnakePos,1)
		table.insert(SnakePos,vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
		table.remove(Snake,1)
		table.insert(Snake,QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
	elseif Mode == 2 then
		Posx = Posx-1
		if Posx == 1 or Posx == 16 or Posx == 31 or Posx == 46 or Posx == 61 or Posx == 76 or Posx == 91 or Posx == 106 or Posx == 121 or Posx == 136 or Posx == 151 or Posx == 166 or Posx == 181 or Posx == 211 or Posx == 226 then
			Posx = Posx+15
		end
		table.remove(SnakePos,1)
		table.insert(SnakePos,vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
		table.remove(Snake,1)
		table.insert(Snake,QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
	elseif Mode == 3 then
		Posy = Posy-15
		if Posy <= 1 then
			Posy = Posy+15*15
		end
		table.remove(SnakePos,1)
		table.insert(SnakePos,vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
		table.remove(Snake,1)
		table.insert(Snake,QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
	else
		Posy = Posy+15
		if Posy >= 15*15-1 then
			Posy = Posy-15*15
		end
		table.remove(SnakePos,1)
		table.insert(SnakePos,vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
		table.remove(Snake,1)
		table.insert(Snake,QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
	end
	for i=1,#SnakePos-1 do
		if SnakePos[#SnakePos] == SnakePos[i] then
			RestartSnake()
		end
	end
	if SnakePos[#SnakePos] == ApplePos[1] then
		table.remove(Apple,1)
		table.remove(ApplePos,1)
		CreateApple()
		AddScore(1)
	end
end

function DrawArena()
	if not IsFullscreen then return end
	if Game.Client.LocalTime > SnakeTime then
		SnakeMove()
		SnakeTime = Game.Client.LocalTime+0.2
	end
	Engine.Graphics:TextureSet(-1)
	Engine.Graphics:MapScreen(0,0,Engine.Graphics.ScreenWidth,Engine.Graphics.ScreenHeight)
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(0.9,0.4,0,1)
		Engine.Graphics:QuadsDraw(MainQuad)
	Engine.Graphics:QuadsEnd()
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(0.8,0.3,0,1)
		Engine.Graphics:QuadsDraw(Quads)
	Engine.Graphics:QuadsEnd()
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(1,0.9,0.8,1)
		Engine.Graphics:QuadsDraw(Snake)
	Engine.Graphics:QuadsEnd()
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(0.7,0.9,0.4,1)
		Engine.Graphics:QuadsDraw(Apple)
	Engine.Graphics:QuadsEnd()
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(0.9,0.2,0.2,0.4)
		Engine.Graphics:QuadsDraw({Snake[#Snake]})
	Engine.Graphics:QuadsEnd()
	local d = ""
	if Mode == 1 then -- right
		d = "→"
	elseif Mode == 2 then -- left
		d = "←"
	elseif Mode == 3 then -- up
		d = "↑"
	elseif Mode == 4 then -- down
		d = "↓"
	end
	Game.Ui:DoLabelScaled(UIRect(SnakePos[#SnakePos].x-QuadSize/2,SnakePos[#SnakePos].y-12,QuadSize,QuadSize), d, 20, 0, -1, nil, 0)
end

function CreateApple()
	local CanApple = true
	if #Apple < 1 then
		local rand = math.random(1,#QuadPos)
		for i=1, #SnakePos do
			if SnakePos[i].x == QuadPos[rand].x and SnakePos[i].y == QuadPos[rand].y then
				CanApple = false
			end
		end
		if CanApple then
			table.insert(Apple,QuadItem(QuadPos[rand].x,QuadPos[rand].y,QuadSize,QuadSize))
			table.insert(ApplePos,vec2f(QuadPos[rand].x,QuadPos[rand].y))
		else
			CreateApple()
		end
	end
end

function OnKeyPress(Key)
	if Key == "right" or Key == "d" then
		if Mode ~= 2 then
			Mode = 1
		end
	elseif Key == "left" or Key == "a" then
		if Mode ~= 1 then
			Mode = 2 
		end
	elseif Key == "up" or Key == "w" and Mode ~= 4 then
		if Mode ~= 4 then
			Mode = 3
		end
	elseif Key == "down" or Key == "s" and Mode ~= 3 then
		if Mode ~= 3 then
			Mode = 4
		end
	end
end

function AddScore(num)
	SnakeSize = SnakeSize+1
	AddSnake()
end

function RestartSnake()
	SnakeSize = 4
	SnakePos = {}
	Posx = 128
	Posy = 128
	Snake = {}
	Mode = 1 -- 1 = right, 2 = left, 3 = up and 4 = down
	SnakeTime = Game.Client.LocalTime+0.2
	Apple = {}
	ApplePos = {}
	CreateSnake()
	CreateApple()
end

function AddSnake()
	table.insert(SnakePos, 1, vec2f(QuadPos[Posx].x,QuadPos[Posy].y))
	table.insert(Snake, 1, QuadItem(SnakePos[#SnakePos].x,SnakePos[#SnakePos].y,QuadSize,QuadSize))
end

RegisterEvent("OnRenderLevel22","DrawArena")