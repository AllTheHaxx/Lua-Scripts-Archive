g_ScriptTitle = "PacMan"
g_ScriptInfo = "PacMan in Teewords? Yes here you go! Without enemys, but you get cakes.\n\n\n...The cake is not a lie!"

-- global variables
Cakes = {}
CakePos = {}
CakeMax = 10
LastPos = Game.LocalTee.Pos
LastTime = Game.Client.LocalTime
CakeSize = 48
Collected = 0

Cake = 0
function OnScriptInit()
	CakePath = ScriptPath():sub(1, -ScriptPath():reverse():find("/")-1).."/data/cake.png"
	Cake = Engine.Graphics:LoadTexture(CakePath, -1, -1, 1)
	print("Loading cake texture from '" .. CakePath .. "' -> ID=" .. Cake)
	if Cake <= 0 then
		error("Failed to load Cake texture from '" .. CakePath .. "'")
		return false -- will actually never be reached since 'error' does a longjmp
	end
	return true
end

function OnScriptUnload()
	-- unload the texture to not leak memory!
	if Cake > 0 then
		Engine.Graphics:UnloadTexture(Cake)
	end
end

function OnTick()
	if (#Cakes <= CakeMax) then -- check if there is already the max amount of cakes on the map, if not we will create the one
		MakeCake()
	end
	if not (LastPos == Game.LocalTee.Pos) then -- only check Collision if the player has moved
		if (LastTime+0.01 <= Game.Client.LocalTime) then -- and a time delay has been exceeded, reduce lags for weak computer :)
			LastTime = Game.Client.LocalTime
			LastPos = Game.LocalTee.Pos
			CheckCollision()
		end
	end
end

function MakeCake()
	local xx = math.random(0,Game.Collision.GetMapWidth*32) -- create random positions for the new cake
	local yy = math.random(0,Game.Collision.GetMapHeight*32)
	local tile = Game.Collision:GetTile(xx,yy) -- don't overlap solid tiles
	if (tile == 0) then
		tile = Game.Collision:GetTile(xx+CakeSize,yy)
		if (tile == 0) then
			tile = Game.Collision:GetTile(xx,yy+CakeSize)
			if (tile == 0) then
				tile = Game.Collision:GetTile(xx-CakeSize,yy)
				if (tile == 0) then
					tile = Game.Collision:GetTile(xx,yy-CakeSize)
					if (tile == 0) then
						table.insert(Cakes, QuadItem(xx,yy,CakeSize,CakeSize))
						table.insert(CakePos, vec2f(xx,yy))
						math.randomseed(math.random(0,1+Game.Client.Tick))
					end
				end
			end
		end
	end
end

function CheckCollision()
	for i = 1, #Cakes do
		local distance = Game.Collision:Distance(Game.LocalTee.Pos, CakePos[i]) -- accurate enough
		if distance < 28 + CakeSize/2 then
			table.remove(Cakes,i)
			table.remove(CakePos,i)
			Collected = Collected+1
			break
		end
	end
end

function DrawCake()
	Engine.Graphics:TextureSet(Cake) -- draw all cakes
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(1,1,1,1)
		Engine.Graphics:QuadsDraw(Cakes)
	Engine.Graphics:QuadsEnd()
end

function DrawScore()
	Engine.Graphics:MapScreen(0,0,Engine.Graphics.ScreenWidth,Engine.Graphics.ScreenHeight) -- simple scrore screen
	Engine.TextRender:Text(nil, 25+CakeSize, 200, 25.0, "Collected = " .. tostring(Collected), 0)
	Engine.Graphics:TextureSet(Cake)
	Engine.Graphics:QuadsBegin()
		Engine.Graphics:SetColor(1,1,1,1)
		Engine.Graphics:QuadsDraw({QuadItem(25+CakeSize/2,200+CakeSize/2.5,CakeSize,CakeSize)})
	Engine.Graphics:QuadsEnd()
end

RegisterEvent("OnTick","OnTick")
RegisterEvent("OnRenderLevel12","DrawCake")
RegisterEvent("OnRenderLevel14","DrawScore")
