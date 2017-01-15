g_ScriptTitle = "[DEBUGGING SCRIPT] Maptile ID Getter"
g_ScriptInfo = "Find out what ID the tile at your mousepointer has"


function OnRenderLevel(Level)
	if Level ~= 14 then return end
	Engine.Graphics:MapScreen(0, 0, Game.Ui:Screen().w, Game.Ui:Screen().h)
	
	local TileID = Game.Collision:GetTile(Game.LocalTee.Pos.x + Game.Input.MouseX, Game.LocalTee.Pos.y + Game.Input.MouseY)
	
	local Rect = UIRect(Game.Input.MouseX*0.72+Game.Ui:Screen().w/2.0, Game.Input.MouseY*0.72+Game.Ui:Screen().h/2.0, 3+Engine.TextRender:TextWidth(nil, 20.0, tostring(TileID), -1), 27)
	Game.RenderTools:DrawUIRect(Rect, vec4f(0,0,0.13,0.35), 15, 3)
	Game.Ui:DoLabelScaled(Rect, tostring(TileID), 20.0, -1, -1, "")
end
