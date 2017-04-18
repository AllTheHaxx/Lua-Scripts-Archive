--[[#!
	#os
]]--#

Import("ui")
Import("config")
Import("containers")

_ConfigSet("ShowSecondHand", 1)
_ConfigSet("ShowDigitalClock", 1)
_ConfigSet("ClockPosOffsX", 0)
_ConfigSet("ClockPosOffsY", 0)
_ConfigLoad()
_ConfigSave()

function OnScriptRenderSettings(MainView)
	ContainersStart()

	Button = UIRect(0,0,0,0)

	MainView:HSplitTop(25, Button, MainView)
	Game.Ui:DoLabelScaled(Button, "Analog Clock Settings", 20, 0, -1, nil, 0)

	MainView:HSplitTop(5, Button, MainView)
	MainView:HSplitTop(20, Button, MainView)
	if Game.Menus:DoButton_CheckBox(NextBC(), "Show seconds hand", _ConfigGet("ShowSecondHand"), Button, nil, 15) ~= 0 then
		_ConfigSet("ShowSecondHand", 1-_ConfigGet("ShowSecondHand"))
	end

	MainView:HSplitTop(5, Button, MainView)
	MainView:HSplitTop(20, Button, MainView)
	if Game.Menus:DoButton_CheckBox(NextBC(), "Show digital clock", _ConfigGet("ShowDigitalClock"), Button, nil, 15) ~= 0 then
		_ConfigSet("ShowDigitalClock", 1-_ConfigGet("ShowDigitalClock"))
	end
end

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

	Bg = Rect:copy()

	if _ConfigGet("ShowDigitalClock") == 1 then Bg.h = Bg.h + 15+3 end
	Game.RenderTools:DrawUIRect(Bg, vec4f(0,0,0,0.5), 15, 5)

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
	second_offset = 0--(time.sec/60) * ((1/60) * 2*math.pi)
	len = (DIM-2*MARGIN)/2
	point = CENTER+vec2f(len*math.sin(angle+second_offset), -len*math.cos(angle+second_offset))
	Engine.Graphics:LinesBegin()
	Engine.Graphics:SetColor(1,1,1,0.9)
	Engine.Graphics:LinesDraw({ LineItem(CENTER.x, CENTER.y, point.x, point.y) })
	Engine.Graphics:LinesEnd()

	-- seconds
	if _ConfigGet("ShowSecondHand") == 1 then
		angle = time.sec/60 * (2*math.pi)
		len = (DIM*0.9-2*MARGIN)/2
		point = CENTER+vec2f(len*math.sin(angle), -len*math.cos(angle))
		Engine.Graphics:LinesBegin()
		Engine.Graphics:SetColor(1,1,1,0.7)
		Engine.Graphics:LinesDraw({ LineItem(CENTER.x, CENTER.y, point.x, point.y) })
		Engine.Graphics:LinesEnd()
	end

	-- digital clock
	if _ConfigGet("ShowDigitalClock") == 1 then
		Bg:HSplitBottom(15, nil, Rect)
		Game.RenderTools:DrawUIRect(Rect, vec4f(1,1,1,0.3), _CUI.CORNER_B, 5)
		Rect.y = Rect.y - 1
		TimeStr = ("%02d:%02d:%02d"):format(time.hour, time.min, time.sec)
		Game.Ui:DoLabelScaled(Rect, TimeStr, 13, 0, -1, nil, 0)
	end
end

RegisterEvent("OnRenderLevel18", "Render")
