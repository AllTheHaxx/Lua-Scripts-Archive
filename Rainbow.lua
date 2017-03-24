g_ScriptTitle = "Caleidoscope"
g_ScriptInfo = "Much rainbow"


function OnScriptInit()
    return Import("ui")
end
 
function DrawHud()
    local Screen = Game.Ui:Screen()
    Engine.Graphics:MapScreen(0,0, Screen.w, Screen.h)
 
    -- prepare the screen
    local MainView = Screen
    local Rect = UIRect(0,0,0,0)
 
 	-- render psychadelic rainbow
	max = 275
	for i = 0, max, 5 do
		MainView:Margin(i, Rect)
		local x = 2 * math.pi * Game.Client.LocalTime * (i/max)
		local Red = 1/2 * math.cos(x + math.pi/3)+1/2
		local Green = 1/2 * math.cos(x - math.pi/3)+1/2
		local Blue = 1/2 * math.sin(x - math.pi/2) + 1/2
		local Color = vec4f(Red, Green, Blue, 0.3)
    	Game.RenderTools:DrawUIRect(Rect, Color, 15, 5)
	end
end

RegisterEvent("OnRenderLevel14","DrawHud")
