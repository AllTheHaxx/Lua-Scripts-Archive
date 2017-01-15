-------------------- COMMON FUNCTIONS FOR TEEWORLDS --------------------

-- returns the ID of the player closest to you, -1 on failure.
function GetClosestID()
	ClosestID = -1
	ClosestDist = 1337*1337
	for i = 0, 64 do
		if Game.Players(i).Active == true then
			if i ~= Game.LocalCID then
				if Game.Collision:Distance(Game.LocalTee.Pos, Game.Players(i).Tee.Pos) < 650 then
					if ClosestID == -1 or Game.Collision:Distance(Game.LocalTee.Pos, Game.Players(i).Tee.Pos) < ClosestDist then
						if Game.Collision:IntersectLine(Game.LocalTee.Pos, Game.Players(i).Tee.Pos, nil, nil, false) == 0 then
							ClosestID = i
							ClosestDist = Game.Collision:Distance(Game.LocalTee.Pos, Game.Players(i).Tee.Pos);
						end
					end
				end
			end
		end
	end
	return ClosestID
end

-- checks whether you are on the ground.
function IsGrounded()
	c = Game.Collision:GetTile(Game.LocalTee.Pos.x, Game.LocalTee.Pos.y+16)
	if (c == 1 or c == 5) then
		return true
	end
	return false
end

-- finds the ID of the player with the given name
function GetPlayerID(Name)
	for i = 0, 64 do
		if Game.Players(i).Name == Name then
			return i
		end
	end
end
