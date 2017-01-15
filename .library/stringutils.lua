-------------------- COMMON FUNCTIONS FOR PROCESSING STRINGS --------------------


function _StringStartsWith(str, find)
	if str:sub(1, find:len()) == find then return true else return false end
end

function _StringSplit(str, char)
	if type(str) ~= "string" or type(char) ~= "string" then return "", "" end
	local a, b = string.find(str, char)
	if (a == nil or b == nil) then return "","" end
	return string.sub(str, 0, a-1), string.sub(str, b+1, -1)
end

function _StringUnpackArgs(str, delim) -- splits a string by spaces into a table
	delim = delim or " "
	local tbl = {}
	str = _StringRTrim(str)
	index = str:find(delim)
	while true do
		if index == nil then
			table.insert(tbl, str)
			break
		end
		table.insert(tbl, str:sub(0, index-1))
		str = str:sub(index+1, -1)
		index = str:find(delim)
	end
	return tbl
end

function _StringRTrim(str)
	local n = #str
	while n > 0 and str:find("^%s", n) do n = n - 1 end
	return str:sub(1, n)
end
