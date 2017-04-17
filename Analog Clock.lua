--[[#!
	#os
]]--#

function Render()
	DIM = 100.0
	MARGIN = 7.0
	RIM = 5.0
	Rect = Game.Ui:Screen()
	Engine.Graphics:MapScreen(Rect.x, Rect.y, Rect.w, Rect.h)

	-- Draw background
	Rect:HSplitTop(DIM+MARGIN+RIM, Rect, nil)
	Rect:VSplitRight(DIM+MARGIN+RIM, nil, Rect)
	Rect:VSplitRight(MARGIN, Rect, nil)
	Rect:HSplitTop(MARGIN, nil, Rect)

	Game.RenderTools:DrawUIRect(Rect, vec4f(0,0,0,0.5), 15, 5)

	-- draw pointers
	CENTER = vec2f(Rect.x+Rect.w/2, Rect.y+Rect.h/2)
	time = os.date("*t")
--	time = {
--		hour = 0,
--		min = 59,
--		sec = Game.Client.LocalTime
--	}

	-- minute marks
	for i = 0, 60 do
		angle = i/60 * (2*math.pi)
		if i % 15 == 0 then
			len = 7
		elseif i % 5 == 0 then
			len = 5
		else
			len = 3
		end
		dir = vec2f(math.sin(angle), -math.cos(angle))
		start = CENTER+dir*(DIM/2-len)
		point = CENTER+dir*(DIM/2)
		Engine.Graphics:LinesBegin()
		Engine.Graphics:SetColor(1,1,1,0.5)
		Engine.Graphics:LinesDraw({ LineItem(start.x, start.y, point.x, point.y) })
		Engine.Graphics:LinesEnd()
	end

	-- hour
	angle = (time.hour%12)/12 * (2*math.pi)
	minute_offset = (time.min/60) * ((30/360) * 2*math.pi)
	second_offset = (time.sec/60/60) * ((30/360) * 2*math.pi)
	len = (DIM*0.65-2*MARGIN)/2
	point = CENTER+vec2f(len*math.sin(angle+minute_offset+second_offset), -len*math.cos(angle+minute_offset+second_offset))
	Engine.Graphics:LinesBegin()
	Engine.Graphics:SetColor(1,0.5,0.5,1)
	Engine.Graphics:LinesDraw({ LineItem(CENTER.x, CENTER.y, point.x, point.y) })
	Engine.Graphics:LinesEnd()

	-- minutes
	angle = time.min/60 * (2*math.pi)
	second_offset = (time.sec/60) * ((1/60) * 2*math.pi)
	len = (DIM-2*MARGIN)/2
	point = CENTER+vec2f(len*math.sin(angle+second_offset), -len*math.cos(angle+second_offset))
	Engine.Graphics:LinesBegin()
	Engine.Graphics:SetColor(1,1,1,1)
	Engine.Graphics:LinesDraw({ LineItem(CENTER.x, CENTER.y, point.x, point.y) })
	Engine.Graphics:LinesEnd()

	-- seconds
	angle = time.sec/60 * (2*math.pi)
	len = (DIM*0.9-2*MARGIN)/2
	point = CENTER+vec2f(len*math.sin(angle), -len*math.cos(angle))
	Engine.Graphics:LinesBegin()
	Engine.Graphics:SetColor(1,1,1,0.7)
	Engine.Graphics:LinesDraw({ LineItem(CENTER.x, CENTER.y, point.x, point.y) })
	Engine.Graphics:LinesEnd()

end

RegisterEvent("OnRenderLevel18", "Render")
