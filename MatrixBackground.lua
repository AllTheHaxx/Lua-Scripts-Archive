g_ScriptTitle = "Matrix"
g_ScriptInfo = "Shows an epic matrix in the menu screen"

--Global Vars
MaxMatrixes = Engine.Graphics.ScreenWidth/25
Speed = 5
MaxTime = 400/Speed -- in seconds
Matrixes = {}
MaxtrixStartPos = {}
MatrixTime = {}
MatrixSize = {}
MatrixText = {}
Textes = {"0\n","1\n"}
math.randomseed(Game.Client.Tick)
Time = Game.Client.LocalTime

function OnTick()
	if Game.ServerInfo.Name == "" then
		if (Game.Client.LocalTime > Time+0.001) then
			for i=1,#MatrixTime do
				Time = Game.Client.LocalTime
				MatrixTime[i] = MatrixTime[i]+1
			end
		end
	end
end


function RenderMatrix()
	if Game.ServerInfo.Name == "" then
		Engine.Graphics:TextureSet(-1)
		Engine.Graphics:MapScreen(0,0,Engine.Graphics.ScreenWidth,Engine.Graphics.ScreenHeight)
		if #Matrixes > 0 then
			Engine.Graphics:QuadsBegin()
				Engine.Graphics:SetColor(0, 0, 0, 1)
				Engine.Graphics:QuadsDraw({QuadItem(0,0,Engine.Graphics.ScreenWidth*2,Engine.Graphics.ScreenHeight*2)})
			Engine.Graphics:QuadsEnd()
			for i = 1, #Matrixes do
				if MatrixTime[i] >= MaxTime then
					if string.len(MatrixText[i]) <= MatrixSize[i] then
						MatrixText[i] = Textes[math.random(1,#Textes)]..MatrixText[i]
						MatrixTime[i] = Speed
					elseif string.len(MatrixText[i]) >= MatrixSize[i] and string.len(MatrixText[i]) <= MatrixSize[i]+2 then
						MatrixText[i] = MatrixText[i]:sub(1, -3)
						MatrixText[i] = Textes[math.random(1,#Textes)]..MatrixText[i]
						MatrixTime[i] = Speed
						local rand = math.random(1,20) -- chance 1 to 20 to renew!
						if (rand == 15) then -- Dont must be 15 can be any other number between 1 and 20
							RenewMatrix(i)
						end
					else
						MatrixText[i] = MatrixText[i]:sub(1, -3)
					end
				end
				Engine.TextRender:TextColor(0.2,0.7,0.3,1)
				Engine.TextRender:Text(nil, MaxtrixStartPos[i].x, MaxtrixStartPos[i].y, 25.0, MatrixText[i], 0)
			end
		else -- one time create matrixes!
			CreateMatrix()
		end
	end
end

function CreateMatrix()
	if #Matrixes >= MaxMatrixes then return end	
	for i=1, MaxMatrixes do
		if (Matrixes[i] == nil) then
			table.insert(Matrixes,#Matrixes)
			table.insert(MaxtrixStartPos, vec2f(0+25*#Matrixes,0))
			table.insert(MatrixSize,math.random(1,Engine.Graphics.ScreenHeight*2/25)) -- without *2 the random must be at 100% to draw till the bottom!
			table.insert(MatrixTime,math.random(0,MaxTime/3))
			table.insert(MatrixText,"")
		end
	end
end

function RenewMatrix(i)
	MatrixSize[i]= math.random(1,Engine.Graphics.ScreenHeight*2/25)
end


RegisterEvent("OnRenderLevel14","RenderMatrix")
RegisterEvent("OnTick","OnTick")