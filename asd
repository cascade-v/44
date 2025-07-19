--vader haxx
-- 12 october 2022???? around then!?
--credits :
--[[
	ANCHOR credits
	Integer = esp, heap lib, mathematics lib and bfs pathfinding
	Gas 	= exploits, gun mods, hooking libs, janitor lib, most of the playerinfo lib, legit silent aim, weapon wrapper, game module resolver and future proofing
    Invaded = everything else
]]

local startLoad = tick()
local disableImageLoading = true
local oldWatermark = true

getgenv().vaderhaxx = {}
getgenv().vaderhaxx.loaded = false

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local mainActor
--[[
local run = function(s)
	return mainActor and syn.run_on_actor(mainActor, s) or loadstring(s)()
end

if syn then
	local tried = tick()
	repeat -- shit actor resolver
		local id, event = syn.create_comm_channel()
		local actors = getactors()
		event:Connect(function(...)
			local data, actor = ...
			if mainActor then
				return
			end
			for i, v in next, data do
				if tostring(v) == "ClientLoader" then
					mainActor = actors[actor]
				end
			end
		end)
		for i, v in next, actors do -- fuck you 3dsboy08 smd faggot
			syn.run_on_actor(v, "local actorId = " .. tostring(i) .. "\n" .. [ [
                local id, actor = ...
                local event = syn.get_comm_channel(id)
                
                event:Fire(getscripts(), actorId)
            ] ], id)
		end 
		task.wait(2)
	until mainActor ~= nil or tick() - tried >= 20
end

run([ [

] ]) -- replace with code below if u actually wanna run the cheat or smth (and u have synapse) xD
]]
local tick                              = tick
local unpack                            = unpack
local Drawing                           = Drawing

local utilities                         = {}
local drawings                          = {}
local uilibrary                         = {}
local encryption                        = {}
local base64                            = {}
local json								= {}

do -- base 64 lib
	local function extract( v, from, width )
		local w = 0
		local flag = 2^from
		for i = 0, width-1 do
			local flag2 = flag + flag
			if v % flag2 >= flag then
				w = w + 2^i
			end
			flag = flag2
		end
		return w
	end
	function base64.makeencoder( s62, s63, spad )
		local encoder = {}
		for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
			'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
			'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
			'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
			'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
			encoder[b64code] = char:byte()
		end
		return encoder
	end

	function base64.makedecoder( s62, s63, spad )
		local decoder = {}
		for b64code, charcode in pairs( base64.makeencoder( s62, s63, spad )) do
			decoder[charcode] = b64code
		end
		return decoder
	end

	local DEFAULT_ENCODER = base64.makeencoder()
	local DEFAULT_DECODER = base64.makedecoder()

	local char, concat = schar, tconcat

	function base64.encode( str, encoder, usecaching )
		encoder = encoder or DEFAULT_ENCODER
		local t, k, n = {}, 1, #str
		local lastn = n % 3
		local cache = {}
		for i = 1, n-lastn, 3 do
			local a, b, c = str:byte( i, i+2 )
			local v = a*0x10000 + b*0x100 + c
			local s
			if usecaching then
				s = cache[v]
				if not s then
					s = string.char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
					cache[v] = s
				end
			else
				s = string.char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
			end
			t[k] = s
			k = k + 1
		end
		if lastn == 2 then
			local a, b = str:byte( n-1, n )
			local v = a*0x10000 + b*0x100
			t[k] = string.char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
		elseif lastn == 1 then
			local v = str:byte( n )*0x10000
			t[k] = string.char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
		end
		return table.concat( t )
	end

	function base64.decode( b64, decoder, usecaching )
		local decoder = decoder or DEFAULT_DECODER
		local pattern = '[^%w%+%/%=]'
		if decoder then
			local s62, s63
			for charcode, b64code in pairs( decoder ) do
				if b64code == 62 then s62 = charcode
				elseif b64code == 63 then s63 = charcode
				end
			end
			pattern = ('[^%%w%%%s%%%s%%=]'):format( string.char(s62), string.char(s63) )
		end
		b64 = b64:gsub( pattern, '' )
		local cache = usecaching and {}
		local t, k = {}, 1
		local n = #b64
		local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
		for i = 1, padding > 0 and n-4 or n, 4 do
			local a, b, c, d = b64:byte( i, i+3 )
			local s
			if usecaching then
				local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
				s = cache[v0]
				if not s then
					local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
					s = string.char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
					cache[v0] = s
				end
			else
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = string.char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
			end
			t[k] = s
			k = k + 1
		end
		if padding == 1 then
			local a, b, c = b64:byte( n-3, n-1 )
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
			t[k] = string.char( extract(v,16,8), extract(v,8,8))
		elseif padding == 2 then
			local a, b = b64:byte( n-3, n-2 )
			local v = decoder[a]*0x40000 + decoder[b]*0x1000
			t[k] = string.char( extract(v,16,8))
		end
		return table.concat( t )
	end
end

do -- json lib
	local encode

	local escape_char_map = {
		[ "\\" ] = "\\",
		[ "\"" ] = "\"",
		[ "\b" ] = "b",
		[ "\f" ] = "f",
		[ "\n" ] = "n",
		[ "\r" ] = "r",
		[ "\t" ] = "t",
	}

	local escape_char_map_inv = { [ "/" ] = "/" }
	for k, v in pairs(escape_char_map) do
		escape_char_map_inv[v] = k
	end


	local function escape_char(c)
		return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
	end


	local function encode_nil(val)
		return "null"
	end


	local function encode_table(val, stack)
		local res = {}
		stack = stack or {}

		-- Circular reference?
		if stack[val] then error("circular reference") end

		stack[val] = true

		if rawget(val, 1) ~= nil or next(val) == nil then
			-- Treat as array -- check keys are valid and it is not sparse
			local n = 0
			for k in pairs(val) do
				if type(k) ~= "number" then
					error("invalid table: mixed or invalid key types")
				end
				n = n + 1
			end
			if n ~= #val then
				error("invalid table: sparse array")
			end
			-- Encode
			for i, v in ipairs(val) do
				table.insert(res, encode(v, stack))
			end
			stack[val] = nil
			return "[" .. table.concat(res, ",") .. "]"

		else
			-- Treat as an object
			for k, v in pairs(val) do
				if type(k) ~= "string" then
					error("invalid table: mixed or invalid key types")
				end
				table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
			end
			stack[val] = nil
			return "{" .. table.concat(res, ",") .. "}"
		end
	end


	local function encode_string(val)
		return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
	end


	local function encode_number(val)
		-- Check for NaN, -inf and inf
		if val ~= val or val <= -math.huge or val >= math.huge then
			error("unexpected number value '" .. tostring(val) .. "'")
		end
		return string.format("%.14g", val)
	end


	local type_func_map = {
		[ "nil"     ] = encode_nil,
		[ "table"   ] = encode_table,
		[ "string"  ] = encode_string,
		[ "number"  ] = encode_number,
		[ "boolean" ] = tostring,
	}


	encode = function(val, stack)
		local t = type(val)
		local f = type_func_map[t]
		if f then
			return f(val, stack)
		end
		error("unexpected type '" .. t .. "'")
	end


	function json.encode(val)
		return ( encode(val) )
	end

	local parse

	local function create_set(...)
		local res = {}
		for i = 1, select("#", ...) do
			res[ select(i, ...) ] = true
		end
		return res
	end

	local space_chars   = create_set(" ", "\t", "\r", "\n")
	local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
	local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
	local literals      = create_set("true", "false", "null")

	local literal_map = {
		[ "true"  ] = true,
		[ "false" ] = false,
		[ "null"  ] = nil,
	}


	local function next_char(str, idx, set, negate)
		for i = idx, #str do
			if set[str:sub(i, i)] ~= negate then
				return i
			end
		end
		return #str + 1
	end


	local function decode_error(str, idx, msg)
		local line_count = 1
		local col_count = 1
		for i = 1, idx - 1 do
			col_count = col_count + 1
			if str:sub(i, i) == "\n" then
				line_count = line_count + 1
				col_count = 1
			end
		end
		error( string.format("%s at line %d col %d", msg, line_count, col_count) )
	end


	local function codepoint_to_utf8(n)
		-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
		local f = mfloor
		if n <= 0x7f then
			return string.char(n)
		elseif n <= 0x7ff then
			return string.char(f(n / 64) + 192, n % 64 + 128)
		elseif n <= 0xffff then
			return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
		elseif n <= 0x10ffff then
			return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
				f(n % 4096 / 64) + 128, n % 64 + 128)
		end
		error( sformat("invalid unicode codepoint '%x'", n) )
	end


	local function parse_unicode_escape(s)
		local n1 = tonumber( s:sub(1, 4),  16 )
		local n2 = tonumber( s:sub(7, 10), 16 )
		-- Surrogate pair?
		if n2 then
			return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
		else
			return codepoint_to_utf8(n1)
		end
	end


	local function parse_string(str, i)
		local res = ""
		local j = i + 1
		local k = j

		while j <= #str do
			local x = str:byte(j)

			if x < 32 then
				decode_error(str, j, "control character in string")

			elseif x == 92 then -- `\`: Escape
				res = res .. str:sub(k, j - 1)
				j = j + 1
				local c = str:sub(j, j)
				if c == "u" then
					local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
						or str:match("^%x%x%x%x", j + 1)
						or decode_error(str, j - 1, "invalid unicode escape in string")
					res = res .. parse_unicode_escape(hex)
					j = j + #hex
				else
					if not escape_chars[c] then
						decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
					end
					res = res .. escape_char_map_inv[c]
				end
				k = j + 1

			elseif x == 34 then -- `"`: End of string
				res = res .. str:sub(k, j - 1)
				return res, j + 1
			end

			j = j + 1
		end

		decode_error(str, i, "expected closing quote for string")
	end


	local function parse_number(str, i)
		local x = next_char(str, i, delim_chars)
		local s = str:sub(i, x - 1)
		local n = tonumber(s)
		if not n then
			decode_error(str, i, "invalid number '" .. s .. "'")
		end
		return n, x
	end


	local function parse_literal(str, i)
		local x = next_char(str, i, delim_chars)
		local word = str:sub(i, x - 1)
		if not literals[word] then
			decode_error(str, i, "invalid literal '" .. word .. "'")
		end
		return literal_map[word], x
	end


	local function parse_array(str, i)
		local res = {}
		local n = 1
		i = i + 1
		while 1 do
			local x
			i = next_char(str, i, space_chars, true)
			-- Empty / end of array?
			if str:sub(i, i) == "]" then
				i = i + 1
				break
			end
			-- Read token
			x, i = parse(str, i)
			res[n] = x
			n = n + 1
			-- Next token
			i = next_char(str, i, space_chars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "]" then break end
			if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
		end
		return res, i
	end


	local function parse_object(str, i)
		local res = {}
		i = i + 1
		while 1 do
			local key, val
			i = next_char(str, i, space_chars, true)
			-- Empty / end of object?
			if str:sub(i, i) == "}" then
				i = i + 1
				break
			end
			-- Read key
			if str:sub(i, i) ~= '"' then
				decode_error(str, i, "expected string for key")
			end
			key, i = parse(str, i)
			-- Read ':' delimiter
			i = next_char(str, i, space_chars, true)
			if str:sub(i, i) ~= ":" then
				decode_error(str, i, "expected ':' after key")
			end
			i = next_char(str, i + 1, space_chars, true)
			-- Read value
			val, i = parse(str, i)
			-- Set
			res[key] = val
			-- Next token
			i = next_char(str, i, space_chars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "}" then break end
			if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
		end
		return res, i
	end


	local char_func_map = {
		[ '"' ] = parse_string,
		[ "0" ] = parse_number,
		[ "1" ] = parse_number,
		[ "2" ] = parse_number,
		[ "3" ] = parse_number,
		[ "4" ] = parse_number,
		[ "5" ] = parse_number,
		[ "6" ] = parse_number,
		[ "7" ] = parse_number,
		[ "8" ] = parse_number,
		[ "9" ] = parse_number,
		[ "-" ] = parse_number,
		[ "t" ] = parse_literal,
		[ "f" ] = parse_literal,
		[ "n" ] = parse_literal,
		[ "[" ] = parse_array,
		[ "{" ] = parse_object,
	}

	parse = function(str, idx)
		local chr = str:sub(idx, idx)
		local f = char_func_map[chr]
		if f then
			return f(str, idx)
		end
		decode_error(str, idx, "unexpected character '" .. chr .. "'")
	end


	function json.decode(str)
		if type(str) ~= "string" then
			error("expected argument of type string, got " .. type(str))
		end
		local res, idx = parse(str, next_char(str, 1, space_chars, true))
		idx = next_char(str, idx, space_chars, true)
		if idx <= #str then
			decode_error(str, idx, "trailing garbage")
		end
		return res
	end
end

do -- pasted to avoid using synapse encryption due to compatability issues

	-- ADVANCED ENCRYPTION STANDARD (AES)

	-- Implementation of secure symmetric-key encryption specifically in Luau
	-- Includes ECB, CBC, PCBC, CFB, OFB and CTR modes without padding.
	-- Made by @RobloxGamerPro200007 (verify the original asset)

	-- MORE INFORMATION: https://devforum.roblox.com/t/advanced-encryption-standard-in-luau/2009120


	-- SUBSTITUTION BOXES
	local s_box 	= { 99, 124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, 254, 215, 171, 118, 202,
		130, 201, 125, 250,  89,  71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147,  38,  54,
		63, 247, 204,  52, 165, 229, 241, 113, 216,  49,  21,   4, 199,  35, 195,  24, 150,   5, 154,   7,
		18, 128, 226, 235,  39, 178, 117,   9, 131,  44,  26,  27, 110,  90, 160,  82,  59, 214, 179,  41,
		227,  47, 132,  83, 209,   0, 237,  32, 252, 177,  91, 106, 203, 190,  57,  74,  76,  88, 207, 208,
		239, 170, 251,  67,  77,  51, 133,  69, 249,   2, 127,  80,  60, 159, 168,  81, 163,  64, 143, 146,
		157,  56, 245, 188, 182, 218,  33,  16, 255, 243, 210, 205,  12,  19, 236,  95, 151,  68,  23, 196,
		167, 126,  61, 100,  93,  25, 115,  96, 129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20, 222,
		94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, 194, 211, 172,  98, 145, 149, 228, 121, 231,
		200,  55, 109, 141, 213,  78, 169, 108,  86, 244, 234, 101, 122, 174,   8, 186, 120,  37,  46,  28,
		166, 180, 198, 232, 221, 116,  31,  75, 189, 139, 138, 112,  62, 181, 102,  72,   3, 246,  14,  97,
		53,  87, 185, 134, 193,  29, 158, 225, 248, 152,  17, 105, 217, 142, 148, 155,  30, 135, 233, 206,
		85,  40, 223, 140, 161, 137,  13, 191, 230,  66, 104,  65, 153,  45,  15, 176,  84, 187,  22}
	local inv_s_box	= { 82,   9, 106, 213,  48,  54, 165,  56, 191,  64, 163, 158, 129, 243, 215, 251, 124,
		227,  57, 130, 155,  47, 255, 135,  52, 142,  67,  68, 196, 222, 233, 203,  84, 123, 148,  50, 166,
		194,  35,  61, 238,  76, 149,  11,  66, 250, 195,  78,   8,  46, 161, 102,  40, 217,  36, 178, 118,
		91, 162,  73, 109, 139, 209,  37, 114, 248, 246, 100, 134, 104, 152,  22, 212, 164,  92, 204,  93,
		101, 182, 146, 108, 112,  72,  80, 253, 237, 185, 218,  94,  21,  70,  87, 167, 141, 157, 132, 144,
		216, 171,   0, 140, 188, 211,  10, 247, 228,  88,   5, 184, 179,  69,   6, 208,  44,  30, 143, 202,
		63,  15,   2, 193, 175, 189,   3,   1,  19, 138, 107,  58, 145,  17,  65,  79, 103, 220, 234, 151,
		242, 207, 206, 240, 180, 230, 115, 150, 172, 116,  34, 231, 173,  53, 133, 226, 249,  55, 232,  28,
		117, 223, 110,  71, 241,  26, 113,  29,  41, 197, 137, 111, 183,  98,  14, 170,  24, 190,  27, 252,
		86,  62,  75, 198, 210, 121,  32, 154, 219, 192, 254, 120, 205,  90, 244,  31, 221, 168,  51, 136,
		7, 199,  49, 177,  18,  16,  89,  39, 128, 236,  95,  96,  81, 127, 169,  25, 181,  74,  13,  45,
		229, 122, 159, 147, 201, 156, 239, 160, 224,  59,  77, 174,  42, 245, 176, 200, 235, 187,  60, 131,
		83, 153,  97,  23,  43,   4, 126, 186, 119, 214,  38, 225, 105,  20,  99,  85,  33,  12, 125}

	-- ROUND CONSTANTS ARRAY
	local rcon = {  0,   1,   2,   4,   8,  16,  32,  64, 128,  27,  54, 108, 216, 171,  77, 154,  47,  94,
		188,  99, 198, 151,  53, 106, 212, 179, 125, 250, 239, 197, 145,  57}
	-- MULTIPLICATION OF BINARY POLYNOMIAL
	local function xtime(x)
		local i = bit32.lshift(x, 1)
		return if bit32.band(x, 128) == 0 then i else bit32.bxor(i, 27) % 256
	end

	-- TRANSFORMATION FUNCTIONS
	local function subBytes		(s, inv) 		-- Processes State using the S-box
		inv = if inv then inv_s_box else s_box
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = inv[s[i][j] + 1]
			end
		end
	end
	local function shiftRows		(s, inv) 	-- Processes State by circularly shifting rows
		s[1][3], s[2][3], s[3][3], s[4][3] = s[3][3], s[4][3], s[1][3], s[2][3]
		if inv then
			s[1][2], s[2][2], s[3][2], s[4][2] = s[4][2], s[1][2], s[2][2], s[3][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[2][4], s[3][4], s[4][4], s[1][4]
		else
			s[1][2], s[2][2], s[3][2], s[4][2] = s[2][2], s[3][2], s[4][2], s[1][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[4][4], s[1][4], s[2][4], s[3][4]
		end
	end
	local function addRoundKey	(s, k) 			-- Processes Cipher by adding a round key to the State
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = bit32.bxor(s[i][j], k[i][j])
			end
		end
	end
	local function mixColumns	(s, inv) 		-- Processes Cipher by taking and mixing State columns
		local t, u
		if inv then
			for i = 1, 4 do
				t = xtime(xtime(bit32.bxor(s[i][1], s[i][3])))
				u = xtime(xtime(bit32.bxor(s[i][2], s[i][4])))
				s[i][1], s[i][2] = bit32.bxor(s[i][1], t), bit32.bxor(s[i][2], u)
				s[i][3], s[i][4] = bit32.bxor(s[i][3], t), bit32.bxor(s[i][4], u)
			end
		end

		local i
		for j = 1, 4 do
			i = s[j]
			t, u = bit32.bxor		(i[1], i[2], i[3], i[4]), i[1]
			for k = 1, 4 do
				i[k] = bit32.bxor	(i[k], t, xtime(bit32.bxor(i[k], i[k + 1] or u)))
			end
		end
	end

	-- BYTE ARRAY UTILITIES
	local function bytesToMatrix	(t, c, inv) -- Converts a byte array to a 4x4 matrix
		if inv then
			table.move		(c[1], 1, 4, 1, t)
			table.move		(c[2], 1, 4, 5, t)
			table.move		(c[3], 1, 4, 9, t)
			table.move		(c[4], 1, 4, 13, t)
		else
			for i = 1, #c / 4 do
				table.clear	(t[i])
				table.move	(c, i * 4 - 3, i * 4, 1, t[i])
			end
		end

		return t
	end
	local function xorBytes		(t, a, b) 		-- Returns bitwise XOR of all their bytes
		table.clear		(t)

		for i = 1, math.min(#a, #b) do
			table.insert(t, bit32.bxor(a[i], b[i]))
		end
		return t
	end
	local function incBytes		(a, inv)		-- Increment byte array by one
		local o = true
		for i = if inv then 1 else #a, if inv then #a else 1, if inv then 1 else - 1 do
			if a[i] == 255 then
				a[i] = 0
			else
				a[i] += 1
				o = false
				break
			end
		end

		return o, a
	end

	-- MAIN ALGORITHM
	local function expandKey	(key) 				-- Key expansion
		local kc = bytesToMatrix(if #key == 16 then {{}, {}, {}, {}} elseif #key == 24 then {{}, {}, {}, {}
			, {}, {}} else {{}, {}, {}, {}, {}, {}, {}, {}}, key)
		local is = #key / 4
		local i, t, w = 2, {}, nil

		while #kc < (#key / 4 + 7) * 4 do
			w = table.clone	(kc[#kc])
			if #kc % is == 0 then
				table.insert(w, table.remove(w, 1))
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
				w[1]	 = bit32.bxor(w[1], rcon[i])
				i 	+= 1
			elseif #key == 32 and #kc % is == 4 then
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
			end

			table.clear	(t)
			xorBytes	(w, table.move(w, 1, 4, 1, t), kc[#kc - is + 1])
			table.insert(kc, w)
		end

		table.clear		(t)
		for i = 1, #kc / 4 do
			table.insert(t, {})
			table.move	(kc, i * 4 - 3, i * 4, 1, t[#t])
		end
		return t
	end
	local function encrypt	(key, km, pt, ps, r) 	-- Block cipher encryption
		bytesToMatrix	(ps, pt)
		addRoundKey		(ps, km[1])

		for i = 2, #key / 4 + 6 do
			subBytes	(ps)
			shiftRows	(ps)
			mixColumns	(ps)
			addRoundKey	(ps, km[i])
		end
		subBytes		(ps)
		shiftRows		(ps)
		addRoundKey		(ps, km[#km])

		return bytesToMatrix(r, ps, true)
	end
	local function decrypt	(key, km, ct, cs, r) 	-- Block cipher decryption
		bytesToMatrix	(cs, ct)

		addRoundKey		(cs, km[#km])
		shiftRows		(cs, true)
		subBytes		(cs, true)
		for i = #key / 4 + 6, 2, - 1 do
			addRoundKey	(cs, km[i])
			mixColumns	(cs, true)
			shiftRows	(cs, true)
			subBytes	(cs, true)
		end

		addRoundKey		(cs, km[1])
		return bytesToMatrix(r, cs, true)
	end

	-- INITIALIZATION FUNCTIONS
	local function convertType	(a) 					-- Converts data to bytes if possible
		if type(a) == "string" then
			local r = {}

			for i = 1, string.len(a), 7997 do
				table.move({string.byte(a, i, i + 7996)}, 1, 7997, i, r)
			end
			return r
		elseif type(a) == "table" then
			for _, i in ipairs(a) do
				assert(type(i) == "number" and math.floor(i) == i and 0 <= i and i < 256,
					"Unable to cast value to bytes")
			end
			return a
		else
			error("Unable to cast value to bytes")
		end
	end
	local function init			(key, txt, m, iv, s) 	-- Initializes functions if possible
		key = convertType(key)
		assert(#key == 16 or #key == 24 or #key == 32, "Key must be either 16, 24 or 32 bytes long")
		txt = convertType(txt)
		assert(#txt % (s or 16) == 0, "Input must be a multiple of " .. (if s then "segment size " .. s
			else "16") .. " bytes in length")
		if m then
			if type(iv) == "table" then
				iv = table.clone(iv)
				local l, e 		= iv.Length, iv.LittleEndian
				assert(type(l) == "number" and 0 < l and l <= 16,
					"Counter value length must be between 1 and 16 bytes")
				iv.Prefix 		= convertType(iv.Prefix or {})
				iv.Suffix 		= convertType(iv.Suffix or {})
				assert(#iv.Prefix + #iv.Suffix + l == 16, "Counter must be 16 bytes long")
				iv.InitValue 	= if iv.InitValue == nil then {1} else table.clone(convertType(iv.InitValue
				))
				assert(#iv.InitValue <= l, "Initial value length must be of the counter value")
				iv.InitOverflow = if iv.InitOverflow == nil then table.create(l, 0) else table.clone(
				convertType(iv.InitOverflow))
				assert(#iv.InitOverflow <= l,
					"Initial overflow value length must be of the counter value")
				for _ = 1, l - #iv.InitValue do
					table.insert(iv.InitValue, 1 + if e then #iv.InitValue else 0, 0)
				end
				for _ = 1, l - #iv.InitOverflow do
					table.insert(iv.InitOverflow, 1 + if e then #iv.InitOverflow else 0, 0)
				end
			elseif type(iv) ~= "function" then
				local i, t = if iv then convertType(iv) else table.create(16, 0), {}
				assert(#i == 16, "Counter must be 16 bytes long")
				iv = {Length = 16, Prefix = t, Suffix = t, InitValue = i,
					InitOverflow = table.create(16, 0)}
			end
		elseif m == false then
			iv 	= if iv == nil then  table.create(16, 0) else convertType(iv)
			assert(#iv == 16, "Initialization vector must be 16 bytes long")
		end
		if s then
			s = math.floor(tonumber(s) or 1)
			assert(type(s) == "number" and 0 < s and s <= 16, "Segment size must be between 1 and 16 bytes"
			)
		end

		return key, txt, expandKey(key), iv, s
	end
	type bytes = {number} -- Type instance of a valid bytes object

	-- CIPHER MODES OF OPERATION
	encryption = {
		-- Electronic codebook (ECB)
		encrypt_ECB = function(key : bytes, plainText : bytes) 									: bytes
			local km
			key, plainText, km = init(key, plainText)

			local b, k, s, t = {}, {}, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, k, s, t), 1, 16, i, b)
			end

			return b
		end,
		decrypt_ECB = function(key : bytes, cipherText : bytes) 								: bytes
			local km
			key, cipherText, km = init(key, cipherText)

			local b, k, s, t = {}, {}, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(decrypt(key, km, k, s, t), 1, 16, i, b)
			end

			return b
		end,
		-- Cipher block chaining (CBC)
		encrypt_CBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)

			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(t, k, p), s, p), 1, 16, i, b)
			end

			return b
		end,
		decrypt_CBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)

			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(k, decrypt(key, km, k, s, t), p), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, p)
			end

			return b
		end,
		-- Propagating cipher block chaining (PCBC)
		encrypt_PCBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)

			local b, k, c, p, s, t = {}, {}, initVector, table.create(16, 0), {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(k, xorBytes(t, c, k), p), s, c), 1, 16, i, b)
				table.move(plainText, i, i + 15, 1, p)
			end

			return b
		end,
		decrypt_PCBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)

			local b, k, c, p, s, t = {}, {}, initVector, table.create(16, 0), {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(p, decrypt(key, km, k, s, t), xorBytes(k, c, p)), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, c)
			end

			return b
		end,
		-- Cipher feedback (CFB)
		encrypt_CFB = function(key : bytes, plainText : bytes, initVector : bytes?, segmentSize : number?)
			: bytes
			local km
			key, plainText, km, initVector, segmentSize = init(key, plainText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)

			local b, k, p, q, s, t = {}, {}, initVector, {}, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, segmentSize do
				table.move(plainText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(q, 1, p[j])
				end
				table.move(q, 1, 16, 1, p)
			end

			return b
		end,
		decrypt_CFB = function(key : bytes, cipherText : bytes, initVector : bytes, segmentSize : number?)
			: bytes
			local km
			key, cipherText, km, initVector, segmentSize = init(key, cipherText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)

			local b, k, p, q, s, t = {}, {}, initVector, {}, {{}, {}, {}, {}}, {}
			for i = 1, #cipherText, segmentSize do
				table.move(cipherText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(k, 1, p[j])
				end
				table.move(k, 1, 16, 1, p)
			end

			return b
		end,
		-- Output feedback (OFB)
		encrypt_OFB = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)

			local b, k, p, s, t = {}, {}, initVector, {{}, {}, {}, {}}, {}
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, p, s, t), 1, 16, 1, p)
				table.move(xorBytes(t, k, p), 1, 16, i, b)
			end

			return b
		end,
		-- Counter (CTR)
		encrypt_CTR = function(key : bytes, plainText : bytes, counter : ((bytes) -> bytes) | bytes | { [
			string]: any }?) : bytes
			local km
			key, plainText, km, counter = init(key, plainText, true, counter)

			local b, k, c, s, t, r, n = {}, {}, {}, {{}, {}, {}, {}}, {}, type(counter) == "table", nil
			for i = 1, #plainText, 16 do
				if r then
					if i > 1 and incBytes(counter.InitValue, counter.LittleEndian) then
						table.move(counter.InitOverflow, 1, 16, 1, counter.InitValue)
					end
					table.clear	(c)
					table.move	(counter.Prefix, 1, #counter.Prefix, 1, c)
					table.move	(counter.InitValue, 1, counter.Length, #c + 1, c)
					table.move	(counter.Suffix, 1, #counter.Suffix, #c + 1, c)
				else
					n = convertType(counter(c, (i + 15) / 16))
					assert		(#n == 16, "Counter must be 16 bytes long")
					table.move	(n, 1, 16, 1, c)
				end
				table.move(plainText, i, i + 15, 1, k)
				table.move(xorBytes(c, encrypt(key, km, c, s, t), k), 1, 16, i, b)
			end

			return b
		end,
		pkcs7_padding = function(data, block_size)
			local pad_size = block_size - #data % block_size
			local padding = string.char(pad_size):rep(pad_size)
			return data .. padding
		end,
		pkcs7_unpadding = function(data)
			local pad_size = string.byte(data:sub(-1))
			return data:sub(1, -pad_size - 1)
		end
	}
end

-- ui library
do
	local workspace                     = game:GetService("Workspace")
	local camera                        = workspace.CurrentCamera
	local runservice                    = game:GetService("RunService")
	local userinputservice              = game:GetService("UserInputService")
	local tweenservice                  = game:GetService("TweenService")
	local players                       = game:GetService("Players")
	local localplayer                   = players.LocalPlayer
	local mouse                         = localplayer:GetMouse()
	local newvec2                       = Vector2.new
	local newudim2                      = UDim2.new
	local math                          = math
	local floor                         = math.floor
	local clamp                         = math.clamp
	local abs                           = math.abs
	local string                        = string
	local table                         = table

	do
		local HttpService = game:GetService("HttpService")

		local ENABLE_TRACEBACK = false

		local Signal = {}
		Signal.__index = Signal
		Signal.ClassName = "Signal"

		--- Constructs a new signal.
		-- @constructor Signal.new()
		-- @treturn Signal
		function Signal.new()
			local self = setmetatable({}, Signal)

			self._bindableEvent = Instance.new("BindableEvent")
			self._argMap = {}
			self._source = ENABLE_TRACEBACK and traceback() or ""

			-- Events in Roblox execute in reverse order as they are stored in a linked list and
			-- new connections are added at the head. This event will be at the tail of the list to
			-- clean up memory.
			self._bindableEvent.Event:Connect(function(key)
				self._argMap[key] = nil

				-- We've been destroyed here and there's nothing left in flight.
				-- Let's remove the argmap too.
				-- This code may be slower than leaving this table allocated.
				if (not self._bindableEvent) and (not next(self._argMap)) then
					self._argMap = nil
				end
			end)

			return self
		end

		--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
		-- Roblox signal conventions.
		-- @param ... Variable arguments to pass to handler
		-- @treturn nil
		function Signal:Fire(...)
			if not self._bindableEvent then
				--warn(("Signal is already destroyed. %s"):format(self._source))
				return
			end

			local args = {...}

			-- TODO: Replace with a less memory/computationally expensive key generation scheme
			local key = 1 + #self._argMap
			self._argMap[key] = args

			-- Queues each handler onto the queue.
			self._bindableEvent:Fire(key)
		end

		--- Connect a new handler to the event. Returns a connection object that can be disconnected.
		-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
		-- @treturn Connection Connection object that can be disconnected
		function Signal:Connect(handler)
			if not (type(handler) == "function") then
				error(("connect(%s)"):format(typeof(handler)), 2)
			end

			return self._bindableEvent.Event:Connect(function(key)
				-- note we could queue multiple events here, but we'll do this just as Roblox events expect
				-- to behave.
				handler(unpack(self._argMap[key]))
			end)
		end

		--- Wait for fire to be called, and return the arguments it was given.
		-- @treturn ... Variable arguments from connection
		function Signal:Wait()
			local key = self._bindableEvent.Event:Wait()
			local args = self._argMap[key]
			if args then
				return unpack(args)
			else
				error("Missing arg data, probably due to reentrance.")
				return nil
			end
		end

		--- Disconnects all connected events to the signal. Voids the signal as unusable.
		-- @treturn nil
		function Signal:Destroy()
			if self._bindableEvent then
				-- This should disconnect all events, but in-flight events should still be
				-- executed.

				self._bindableEvent:Destroy()
				self._bindableEvent = nil
			end

			-- Do not remove the argmap. It will be cleaned up by the cleanup connection.

			setmetatable(self, nil)
		end

		utilities.signal = Signal
	end

	utilities.blockmouseevents = false -- local ones get blocked at certain times
	utilities.nextidentifier = 0
	function utilities.getnextidentifier() -- look man, i couldnt do parenting properly so i had to do this (yes i tried v == val, didnt work), (update: wasnt the issue, no longer needed but cba to remove this now)
		utilities.nextidentifier = utilities.nextidentifier + 1
		local bullshit = tostring(utilities.nextidentifier)
		return bullshit
	end
	-- not smth im proud of but itll work

	function utilities.map(x, a, b, c, d)
		return (x - a) / (b - a) * (d - c) + c
	end

	utilities.base = { -- this is sorta like our camera, we have a defined size n sh so we can parent things to this
		children = {},
		absolutesize = camera.ViewportSize,
		drawingobject = {
			Size = camera.ViewportSize,
			Position = newvec2(),
			Visible = true
		},
		absoluteposition = newvec2(),
		class = "frame",
		name = "startergui", -- x3
		identifier = utilities.getnextidentifier(),
		visible = true,
		getpropertychangedsignal = utilities.signal.new(),
		updatechildsignal = utilities.signal.new(),
	}

	utilities.base.getpropertychangedsignal:Connect(function(event, val) -- p10000000000000000 parenting fix
		local ident = val.identifier
		local thesechildren = utilities.base.children
		if event == "childadded" then
			thesechildren[ident] = val
		elseif event == "childremoved" then
			thesechildren[ident] = nil
		end
	end)

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		task.wait()
		utilities.base.absolutesize = camera.ViewportSize
		utilities.base.drawingobject.Size = camera.ViewportSize
		utilities.base.visible = false
		utilities.base.updatechildsignal:Fire("visible", false)
		utilities.base.visible = true
		utilities.base.updatechildsignal:Fire("visible", true)
	end)

	utilities.mouse = { -- would rather this than every drawing object go mouse.move:connect(function() -- bullshit end)
		position = newvec2(mouse.x, mouse.y),
		oldposition = newvec2(),
		mouse1held = false,
		mouse2held = false,
		moved = utilities.signal.new(),
		mousebutton1down = utilities.signal.new(),
		mousebutton2down = utilities.signal.new(),
		mousebutton1up = utilities.signal.new(),
		mousebutton2up = utilities.signal.new(),
		scrollup = utilities.signal.new(),
		scrolldown = utilities.signal.new(),
	}

	userinputservice.InputChanged:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if utilities.blockmouseevents then return end
			utilities.mouse.oldposition = utilities.mouse.position
			utilities.mouse.moved:Fire()
			local xy = userinputservice:GetMouseLocation()
			utilities.mouse.position = newvec2(xy.x, xy.y)
		end
	end)

	userinputservice.InputBegan:Connect(function(input, gameProcessed)
		if utilities.blockmouseevents then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			utilities.mouse.mouse1held = true
			utilities.mouse.mousebutton1down:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			utilities.mouse.mouse2held = true
			utilities.mouse.mousebutton2down:Fire()
		end
	end)

	userinputservice.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			utilities.mouse.mouse1held = false
			utilities.mouse.mousebutton1up:Fire()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			utilities.mouse.mouse2held = false
			utilities.mouse.mousebutton2up:Fire()
		end
	end)

	userinputservice.InputChanged:Connect(function(input)
		if utilities.blockmouseevents then return end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if input.Position.Z > 0 then
				utilities.mouse.scrollup:Fire(input.Position.Z)
			else
				utilities.mouse.scrolldown:Fire(input.Position.Z)
			end
		end
	end)

	function utilities.copyarray(original)
		local copied = {}
		for i, v in next, (original) do
			if type(v) == "table" then
				v = utilities.copyarray(v)
			end
			copied[i] = v
		end
		return copied
	end

	function utilities.getclipboard()
		local screen = Instance.new("ScreenGui",game.CoreGui)
		local tb = Instance.new("TextBox",screen)
		tb.TextTransparency = 1

		tb:CaptureFocus()
		keypress(0x11)  
		keypress(0x56)
		task.wait()
		keyrelease(0x11)
		keyrelease(0x56)
		tb:ReleaseFocus()

		local captured = tb.Text

		tb:Destroy()
		screen:Destroy()

		return captured
	end

	utilities.types = {
		frame = "Square",
		text = "Text",
		image = "Image",
	}

	utilities.writeableproperties = {
		anchorpoint = newvec2(),
		parent = utilities.base,
		zindex = 0,
		name = "",
		visible = true,
	}

	utilities.readonlyproperties = {
		drawing = nil,
		children = {},
		activated = false,
		class = "",
		identifier = "",
		updater = connection,
		absolutesize = newvec2(),
		absoluteposition = newvec2(),
	}

	utilities.events = {
		getpropertychangedsignal = utilities.signal.new(),
		updatechildsignal = utilities.signal.new(), -- time to tell the children to update !
	}

	utilities.activations = {
		hovering = false,
		holding = false,
		clicked = utilities.signal.new(),
		mouseenter = utilities.signal.new(),
		mouseleave = utilities.signal.new()
	}

	utilities.specificproperties = {
		frame = {
			thickness = 0,
			transparency = 0,
			size = newudim2(),
			color = Color3.new(),
			filled = false,
			position = newudim2()
		},
		text = {
			text = "",
			size = 0,
			outline = false,
			color = Color3.new(),
			outlinecolor = Color3.new(),
			position = newudim2(),
			font = Drawing.Fonts.Plex
		},
		image = {
			data = "",
			size = newudim2(),
			position = newudim2(),
			rounding = 0,
		},
	}

	utilities.operationorder = {
		"name",
		"parent",
		"anchorpoint",
		"size",
		"position"
	}

	utilities.updatechildren = {
		position = true,
		size = true,
		visible = true
	}

	utilities.childupdate = { -- the new arg isnt the new pos or anything its what the parent is about to be because this is based off of the parent updating
		absoluteposition = function(obj, parentnew) -- basically think of this as "oo my parent updated this property and my ... property is dependant on that so i need to update it"
			local parent = obj.parent
			local scalex = obj.position.X.Scale
			local scaley = obj.position.Y.Scale
			local offsetx = obj.position.X.Offset
			local offsety = obj.position.Y.Offset

			local anchorx = obj.anchorpoint.x
			local anchory = obj.anchorpoint.y

			local x, y = parent.absolutesize.x * scalex + offsetx, parent.absolutesize.y * scaley + offsety
			x = parentnew.x + x - (obj.absolutesize.x * anchorx)
			y = parentnew.y + y - (obj.absolutesize.y * anchory) -- anchorpoints !!!!!
			x = floor(x + 0.5)
			y = floor(y + 0.5)
			local result = newvec2(x, y)

			obj.getpropertychangedsignal:Fire("absoluteposition", result)
			obj.drawingobject.Position = result
			obj.absoluteposition = result
		end,
		absolutesize = function(obj, parentnew) -- really awful but it worked
			if obj.class == "text" then return end
			local parent = obj.parent

			local old = obj.absolutesize
			local x, y, result

			local scalex = obj.size.X.Scale
			local scaley = obj.size.Y.Scale
			local offsetx = obj.size.X.Offset
			local offsety = obj.size.Y.Offset
			x, y = parentnew.x * scalex + offsetx, parentnew.y * scaley + offsety
			x = floor(x + 0.5)
			y = floor(y + 0.5)
			result = newvec2(x, y)

			-- since dn (this proeprty is dependant on its actual size so it will have to be updated)
			local anchorx = obj.anchorpoint.x
			local anchory = obj.anchorpoint.y

			local scalex2 = obj.position.X.Scale
			local scaley2 = obj.position.Y.Scale
			local offsetx2 = obj.position.X.Offset
			local offsety2 = obj.position.Y.Offset

			local nut = newvec2(parent.absolutesize.x * scaley2 + offsety2, parent.absolutesize.x * scalex2 + offsetx2)
			local x2 = parent.absoluteposition.x + nut.x - (result.x * anchorx)
			local y2 = parent.absoluteposition.y + nut.y - (result.y * anchory) -- as u can see, we are reusing the previous result
			x2 = floor(x2 + 0.5)
			y2 = floor(y2 + 0.5)
			local result2 = newvec2(x2, y2)

			obj.drawingobject.Size = result
			obj.absolutesize = result
			obj.getpropertychangedsignal:Fire("absolutesize", result)

			obj.drawingobject.Position = result2
			obj.absoluteposition = result2
			obj.getpropertychangedsignal:Fire("absoluteposition", result2)
		end,
		visible = function(obj, parentnew)
			local parent = obj.parent
			obj.drawingobject.Visible = parent.drawingobject.Visible and obj.visible or false
			utilities.setproperty.shared.activated(obj, obj.activated)
			obj.getpropertychangedsignal:Fire("visible", parent.drawingobject.Visible and obj.visible or false)
		end,
	}

	utilities.setproperty = { -- so i couldve gone to the __newindex and done if i == "position" then elseif i == "size" and so on but this feels a lot better to do
		shared = { -- how to fix stack overflow 2022
			activated = function(obj, new) -- mildly homosexual (done so that when ur thing isnt visible, it doesnt try to pass mouse related objects) (this also ended up being a lot better for fps than as i was previously doing if thing.visible == false then return end)
				for i, v in next, (obj.mouseconnections) do
					v:Disconnect()
					obj.mouseconnections[i] = v
				end
				if new and obj.drawingobject.Visible then
					local oldhover = false
					obj.mouseconnections.moved = utilities.mouse.moved:Connect(function()
						obj.hovering = utilities.mousechecks.inbounds(obj, utilities.mouse.position)
						if obj.hovering and oldhover == false then
							obj.mouseenter:Fire()
						end
						if obj.hovering == false and oldhover then
							obj.mouseleave:Fire()
						end
						oldhover = obj.hovering
					end)
					obj.mouseconnections.mouse1down = utilities.mouse.mousebutton1down:Connect(function()
						if obj.hovering then
							obj.clicked:Fire()
							obj.holding = true
						end
					end)
					obj.mouseconnections.mouse2down = utilities.mouse.mousebutton2down:Connect(function()
						if obj.hovering then
							obj.clicked2:Fire()
							obj.holding2 = true
						end
					end)
					obj.mouseconnections.mouse1up = utilities.mouse.mousebutton1up:Connect(function()
						obj.holding = false
					end)
					obj.mouseconnections.mouse2up = utilities.mouse.mousebutton2up:Connect(function()
						obj.holding2 = false
					end)
				end
			end,
			parent = function(obj, new)
				local oldparent = obj.parent

				oldparent.getpropertychangedsignal:Fire("childremoved", obj) -- fuck this, its this things problem now
				table.clear(obj.childupdatespool) -- get rid of the old pool


				local drawingobj = obj.drawingobject
				local inque = {} -- minor issue !!

				if obj.updater then
					obj.updater:Disconnect()
				end

				new.getpropertychangedsignal:Fire("childadded", obj)

				for i, v in next, (utilities.childupdate) do
					obj.childupdatespool[i] = v -- save it for ourselves !
					obj.childupdatespool[i](obj, new[i])
					obj.updatechildsignal:Fire(i, obj[i])
				end

				obj.updater = new.updatechildsignal:Connect(function(event, val)
					local isnowvisible = drawingobj.Visible == false and event == "visible" and val == true
					if obj.childupdatespool[event] then
						obj.childupdatespool[event](obj, new[event])
					end
					if drawingobj.Visible or isnowvisible or event == "visible" then -- only update if the thing is visible
						obj.updatechildsignal:Fire(event, val) -- how 2 inherit
					else
						inque[event] = val -- ok we missed out on this property
					end
					if isnowvisible then -- we comin' back baby
						for i, v in next, (inque) do -- update the shit we "missed out"
							obj.childupdatespool[i](obj, new[i])
							obj.updatechildsignal:Fire(i, obj[i])
						end
						inque = {}
					end
				end)
			end,
			anchorpoint = function(obj, new) -- kinda fucked but stfu
				local old = obj.absoluteposition

				local parent = obj.parent
				local scalex = obj.position.X.Scale
				local scaley = obj.position.Y.Scale
				local offsetx = obj.position.X.Offset
				local offsety = obj.position.Y.Offset
				local anchorx = new.x
				local anchory = new.y
				local x, y = parent.absolutesize.x * scalex + offsetx, parent.absolutesize.y * scaley + offsety
				x = x - (x * anchorx)
				y = y - (y * anchory) -- anchorpoints !!!!!
				x = floor(x + 0.5) -- floored cuz dn!!!!!!!!
				y = floor(y + 0.5)
				local result = newvec2(x, y)

				obj.drawingobject.Position = result
				obj.absoluteposition = obj.drawingobject.Position
				obj.getpropertychangedsignal:Fire("anchorpoint", new)
				obj.getpropertychangedsignal:Fire("absoluteposition", obj.drawingobject.Position)
				obj.updatechildsignal:Fire("absoluteposition", result)
			end,
			position = function(obj, new)
				local old = obj.absoluteposition
				local parent = obj.parent
				local scalex = new.X.Scale
				local scaley = new.Y.Scale
				local offsetx = new.X.Offset
				local offsety = new.Y.Offset
				local anchorx = obj.anchorpoint.x
				local anchory = obj.anchorpoint.y
				local x, y = parent.absolutesize.x * scalex + offsetx, parent.absolutesize.y * scaley + offsety
				x = parent.absoluteposition.x + x - (obj.absolutesize.x * anchorx)
				y = parent.absoluteposition.y + y - (obj.absolutesize.y * anchory) -- anchorpoints !!!!!
				x = floor(x + 0.5)
				y = floor(y + 0.5)
				local result = newvec2(x, y)
				obj.drawingobject.Position = result
				obj.absoluteposition = obj.drawingobject.Position

				obj.getpropertychangedsignal:Fire("position", new)
				obj.getpropertychangedsignal:Fire("absoluteposition", obj.drawingobject.Position)
				obj.updatechildsignal:Fire("absoluteposition", obj.drawingobject.Position)
			end,
			zindex = function(obj, new)
				obj.drawingobject.ZIndex = new
				obj.getpropertychangedsignal:Fire("zindex", new)
			end,
			visible = function(obj, new)
				local parent = obj.parent
				obj.drawingobject.Visible = (parent.drawingobject.Visible and parent.visible and new == true) and true or false
				obj.getpropertychangedsignal:Fire("visible", obj.drawingobject.Visible)
				obj.updatechildsignal:Fire("visible", obj.drawingobject.Visible)
				utilities.setproperty.shared.activated(obj, obj.activated)
			end,
			transparency = function(obj, new)
				obj.drawingobject.Transparency = new
				obj.getpropertychangedsignal:Fire("transparency", new)
			end,
		},
		frame = { -- ok this fucked up a bit but stfu
			color = function(obj, new)
				obj.drawingobject.Color = new
				obj.getpropertychangedsignal:Fire("color", new)
			end,
			thickness = function(obj, new)
				obj.drawingobject.Thickness = new
				obj.getpropertychangedsignal:Fire("thickness", new)
			end,
			filled = function(obj, new)
				obj.drawingobject.Filled = new
				obj.getpropertychangedsignal:Fire("filled", new)
			end,
			size = function(obj, new) -- this couldve been done for each class like it shouldve but i had too many stack overflows so ripbozo
				local parent = obj.parent

				local old = obj.absolutesize
				local x, y, result

				local scalex = new.X.Scale
				local scaley = new.Y.Scale
				local offsetx = new.X.Offset
				local offsety = new.Y.Offset
				x, y = parent.absolutesize.x * scalex + offsetx, parent.absolutesize.y * scaley + offsety
				x = floor(x + 0.5)
				y = floor(y + 0.5)
				result = newvec2(x, y)

				obj.drawingobject.Size = result
				obj.absolutesize = obj.drawingobject.Size

				obj.getpropertychangedsignal:Fire("size", new)
				obj.getpropertychangedsignal:Fire("absolutesize", obj.drawingobject.Size)
				obj.updatechildsignal:Fire("absolutesize", obj.drawingobject.Size)

				utilities.setproperty.shared.position(obj, obj.position)
			end,
		},
		text = {
			color = function(obj, new)
				obj.drawingobject.Color = new
				obj.getpropertychangedsignal:Fire("color", new)
			end,
			text = function(obj, new)
				obj.drawingobject.Text = new
				obj.getpropertychangedsignal:Fire("text", new)
				utilities.setproperty.text.size(obj, obj.size)
			end,
			size = function(obj, new) -- this couldve been done for each class like it shouldve but i had too many stack overflows so ripbozo
				local parent = obj.parent

				local old = obj.absolutesize
				local x, y, result

				obj.drawingobject.Size = new -- a bit fucked
				result = obj.drawingobject.TextBounds
				x = floor(result.x)
				y = floor(result.y)
				result = newvec2(x, y)

				obj.absolutesize = result

				obj.getpropertychangedsignal:Fire("size", new)
				obj.getpropertychangedsignal:Fire("absolutesize", obj.absolutesize)
				obj.updatechildsignal:Fire("absolutesize", result)
				utilities.setproperty.shared.position(obj, obj.position)
			end,
			font = function(obj, new)
				obj.drawingobject.Font = new
				obj.getpropertychangedsignal:Fire("font", new)
			end,
			outline = function(obj, new)
				obj.drawingobject.Outline = new
				obj.getpropertychangedsignal:Fire("outline", new)
			end,
			outlinecolor = function(obj, new)
				obj.drawingobject.OutlineColor = new
				obj.getpropertychangedsignal:Fire("outlinecolor", new)
			end,
		},
		image = {
			data = function(obj, new)
				obj.drawingobject.Data = new
				obj.getpropertychangedsignal:Fire("data", new)
			end,
			rounding = function(obj, new)
				obj.drawingobject.Rounding = new
				obj.getpropertychangedsignal:Fire("rounding", new)
			end,
			size = function(obj, new) -- this couldve been done for each class like it shouldve but i had too many stack overflows so ripbozo
				local parent = obj.parent

				local old = obj.absolutesize
				local x, y, result

				local scalex = new.X.Scale
				local scaley = new.Y.Scale
				local offsetx = new.X.Offset
				local offsety = new.Y.Offset
				x, y = parent.absolutesize.x * scalex + offsetx, parent.absolutesize.y * scaley + offsety
				x = floor(x + 0.5)
				y = floor(y + 0.5)
				result = newvec2(x, y)

				obj.drawingobject.Size = result
				obj.absolutesize = result

				obj.getpropertychangedsignal:Fire("size", new)
				obj.getpropertychangedsignal:Fire("absolutesize", obj.drawingobject.Size)
				obj.updatechildsignal:Fire("absolutesize", result)
				utilities.setproperty.shared.position(obj, obj.position)
			end,
		},
	}

	utilities.mousechecks = { -- uhhhhh these r things to help with ur mouse related shit
		inbounds = function(obj, pos)
			if obj.drawingobject.Visible == false then return false end
			local lowx = obj.absoluteposition.x
			local highx = lowx + obj.absolutesize.x
			local lowy = obj.absoluteposition.y
			local highy = lowy + obj.absolutesize.y
			local mousex = pos.x
			local mousey = pos.y

			if mousex > lowx and mousex < highx and mousey > lowy and mousey < highy then
				return true
			else
				return false
			end
		end,
	}

	function utilities.createproperties(obj, active) -- ugh
		local properties = {}
		local writeableproperties = {
			anchorpoint = newvec2(),
			parent = utilities.base,
			zindex = 0,
			name = "",
			visible = true,
		}

		local readonlyproperties = {
			drawing = nil,
			children = {},
			activated = false,
			class = "",
			identifier = "",
			updater = connection,
			childupdatespool = {},
			absolutesize = newvec2(),
			absoluteposition = newvec2(),
		}

		local events = {
			getpropertychangedsignal = utilities.signal.new(),
			updatechildsignal = utilities.signal.new(), -- time to tell the children to update !
		}

		local activations = {
			hovering = false,
			holding = false,
			holding2 = false,
			clicked = utilities.signal.new(),
			clicked2 = utilities.signal.new(),
			mouseenter = utilities.signal.new(),
			mouseleave = utilities.signal.new()
		}

		local specificproperties = {
			frame = {
				thickness = 0,
				transparency = 1,
				size = newudim2(),
				color = Color3.new(),
				filled = false,
				position = newudim2()
			},
			text = {
				text = "",
				size = 0,
				outline = false,
				color = Color3.new(),
				transparency = 1,
				outlinecolor = Color3.new(),
				position = newudim2(),
				font = Drawing.Fonts.Plex
			},
			image = {
				data = "",
				size = newudim2(),
				color = Color3.new(),
				transparency = 1,
				position = newudim2(),
				rounding = 0,
			},
		}

		for i, v in next, ({writeableproperties, readonlyproperties, events, activations, specificproperties[obj]}) do
			for i2, v2 in next, (v) do
				properties[i2] = v2 
				v2 = nil
			end
			table.clear(v) -- get rid of it
		end
		return properties
	end


	function utilities:draw(object, properties) -- basically, updating the properties table will update the actual drawing object
		local kind = utilities.types[object]
		local drawingobject = Drawing.new(kind)

		local drawing = {}
		drawing.__index = drawing

		local propertylist = utilities.createproperties(object, properties.activated)
		for i, v in next, (propertylist) do
			drawing[i] = v
		end

		drawing.identifier = utilities.getnextidentifier() -- increment$per$drawing$$
		drawing.class = object
		drawing.drawingobject = drawingobject
		drawing.activated = properties.activated
		drawing.mouseconnections = {}

		local proxy = drawing -- proxy for metatable stuff

		local newindexpool = {} -- this is our pool of corresponding newindex funcs
		for i, v in next, (utilities.setproperty[object]) do -- specific funcs
			newindexpool[i] = v
		end
		for i, v in next, (utilities.setproperty.shared) do -- add shared funcs
			newindexpool[i] = v
		end

		drawing = setmetatable({}, { -- set the mt
			__index = function(self, i)
				return proxy[i]
			end,
			__newindex = function(self, i, v)
				if newindexpool[i] then -- is there a special way to update this property or na
					newindexpool[i](self, v) -- update the property how it should be
				end
				proxy[i] = v
			end
		})

		function drawing:destroy() -- errors a bit but itll do
			drawing.parent.getpropertychangedsignal:Fire("childremoved", drawing) -- no more parent :sad:
			drawing.visible = false -- :wave:
			drawing.drawingobject:Remove()
			drawing.drawingobject = nil
			drawing.getpropertychangedsignal:Fire("parentdestroyed") -- get rid of the chain of shit
			table.clear(drawing)
			drawing = nil
		end

		drawing.getpropertychangedsignal:Connect(function(event, val) -- p10000000000000000 parenting fix
			local drawingChildren = drawing.children
			local ident = val and type(val) == "table" and val.identifier
			if event == "childadded" then
				drawingChildren[ident] = val
			elseif event == "childremoved" then -- although its kinda dumb, id say its not too bad becuz its faster than iterating thru god knows how many children and comparing tables
				drawingChildren[ident] = nil
			elseif event == "parentdestroyed" then
				drawing:destroy()
			end
		end)

		-- i had to.. sorry!!!!
		local propertiesinque = {}
		for i, v in ipairs(utilities.operationorder) do
			if properties[v] then
				propertiesinque[1 + #propertiesinque] = {
					key = v,
					value = properties[v]
				}
				properties[v] = nil
			end
		end

		for i, v in next, (properties) do
			propertiesinque[1 + #propertiesinque] = {
				key = i,
				value = v
			}
		end

		for i, v in ipairs(propertiesinque) do
			local property = v.key
			local value = v.value
			drawing[property] = value
		end

		drawings[1 + #drawings] = drawing -- keep a record of it just in case
		return drawing
	end

	local uilib = {}
	uilib.__index = uilib
	function uilib:start(parameters)
		-- okay actual design starts
		local httpservice = game:GetService("HttpService")
		local menu = {}
		menu.__index = menu
		menu.basezindex = parameters.basezindex or 69420 -- haha funny
		menu.startingParameters = parameters
		menu.uiopen = true
		menu.dragging = false
		menu.objects = {}
		menu.username = "developer"
		menu.flags = {}
		menu.isadropdownopen = false -- shitty fix but itll work
		menu.isacolorpickeropen = false
		menu.tabs = {}
		menu.subsections = {}
		menu.subtabs = {}
		menu.directory = {}
		menu.openclose = {} -- things that are to have the open and close animation
		menu.elements = {}
		menu.activations = {}
		menu.accent = parameters.accent
		menu.cheatname = parameters.name
		menu.accents = {}
		menu.imagecache = {}

		menu.validkeys = {
			"A",
			"B",
			"C",
			"D",
			"E",
			"F",
			"G",
			"H",
			"I",
			"J",
			"K",
			"L",
			"M",
			"N",
			"O",
			"P",
			"Q",
			"R",
			"S",
			"T",
			"U",
			"V",
			"W",
			"X",
			"Y",
			"Z",
		}

		menu.validnumberkeys = {
			One = "1",
			Two = "2",
			Three = "3",
			Four = "4",
			Five = "5",
			Six = "6",
			Seven = "7",
			Eight = "8",
			Nine = "9",
			Zero = "0",
			LeftBracket = "[",
			RightBracket = "]",
			Semicolon = "",
			BackSlash = "\\",
			Slash = "/",
			Minus = "-",
			Equals = "=",
			Backquote = "`",
			Plus = "+",
			Comma = ",",
			Period = ".",
		}

		local colorpickerClipBoard
		local menucolors = parameters.colors
		local colorGroups = {}
		for i, v in next, parameters.colors do
			colorGroups[i] = {}
		end

		local drawingFunction = function(object, props)
			local thisDrawing = utilities:draw(object, props)
			for i, v in next, parameters.colors do
				if props.color == v then
					local nextIndex = 1 + #colorGroups[i]
					colorGroups[i][nextIndex] = thisDrawing
				end
			end
			return thisDrawing
		end
		menu.colorGroups = colorGroups
		menu.drawingFunction = drawingFunction

		menu.objects.backborder = drawingFunction("frame", {
			parent = utilities.base,
			anchorpoint = newvec2(0, 0),
			size = newudim2(0, parameters.size.x, 0, parameters.size.y),
			position = newudim2(0, (utilities.base.absolutesize.x / 2) + (-parameters.size.x / 2), 0, (utilities.base.absolutesize.y / 2) + (-parameters.size.y / 2)), -- sex
			zindex = menu.basezindex + -3,
			color = parameters.colors.a,
			visible = false,
			thickness = 1,
			transparency = 1,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.backborder

		local fuck = Instance.new("ScreenGui", game.CoreGui) -- not something im happy about but this is so that clicking on the ui blocks every other click
		local bitch = Instance.new("Frame", fuck)
		bitch.Size = newudim2(0, 0, 0, 0)
		bitch.Active = true
		bitch.Selectable = true
		bitch.Transparency = 1
		bitch.Position = newudim2(0, 0, 0, 0)

		menu.objects.backborder.getpropertychangedsignal:Connect(function(prop, val)
			if prop == "visible" then
				bitch.Visible = val
			end
		end)

		menu.objects.dragdetection = drawingFunction("frame", { -- uh dn
			parent = menu.objects.backborder,
			anchorpoint = newvec2(0.5, 0),
			size = newudim2(1, 0, 0, 14),
			position = newudim2(0.5, 0, 0, 0),
			zindex = menu.basezindex + 12,
			color = Color3.fromRGB(255, 255, 255),
			visible = true,
			thickness = 0,
			transparency = 0,
			filled = true,
			activated = true,
			name = "okay 2",
		})

		menu.objects.resizedetection = drawingFunction("frame", { -- yes, this is a thing
			parent = menu.objects.backborder,
			anchorpoint = newvec2(1, 1),
			size = newudim2(0, 8, 0, 8),
			position = newudim2(1, 0, 1, 0),
			zindex = menu.basezindex + 12,
			color = Color3.fromRGB(255, 255, 255),
			visible = true,
			thickness = 0,
			transparency = 0,
			filled = true,
			activated = true,
			name = "okay 2",
		})

		function menu:setsize(size)
			menu.objects.backborder.size = newudim2(0, math.min(size.x, parameters.size.x), 0, math.min(size.y, parameters.size.y))
		end

		local outerTransparency = 0.75
		local outerTransparency2 = 0.65

		menu.objects.outerfirst = drawingFunction("frame", {
			parent = menu.objects.backborder,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.b,
			visible = true,
			thickness = 1,
			transparency = outerTransparency,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.outerfirst

		menu.objects.outersecond1 = drawingFunction("frame", {
			parent = menu.objects.outerfirst,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.c,
			visible = true,
			thickness = 1,
			transparency = outerTransparency,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.outersecond1

		menu.objects.outersecond = drawingFunction("frame", {
			parent = menu.objects.outersecond1,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.c,
			visible = true,
			thickness = 1,
			transparency = outerTransparency,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.outersecond

		menu.objects.outerthird = drawingFunction("frame", {
			parent = menu.objects.outersecond,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.b,
			visible = true,
			thickness = 1,
			transparency = outerTransparency,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.outerthird

		menu.objects.innerfirst = drawingFunction("frame", {
			parent = menu.objects.outerthird,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.a,
			visible = true,
			thickness = 0,
			transparency = outerTransparency2,
			filled = true,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.innerfirst

		menu.objects.tabsholder = drawingFunction("frame", {
			parent = menu.objects.outerthird,
			anchorpoint = newvec2(0.5, 0),
			size = newudim2(1, -38, 0, 18),
			position = newudim2(0.5, 0, 0, 8), -- sex
			zindex = menu.basezindex + -2,
			color = Color3.new(1, 1, 1),
			visible = true,
			thickness = 0,
			transparency = 0,
			filled = true,
			name = "okay",
		})

		menu.objects.containerfirst = drawingFunction("frame", {
			parent = menu.objects.outerthird,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -36, 1, -48),
			position = newudim2(0.5, 0, 0.5, 8), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.a,
			visible = true,
			thickness = 1,
			transparency = 1,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.containerfirst

		menu.objects.containersecond = drawingFunction("frame", {
			parent = menu.objects.containerfirst,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.c,
			visible = true,
			thickness = 1,
			transparency = 1,
			filled = false,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.containersecond

		menu.objects.maincontainer = drawingFunction("frame", {
			parent = menu.objects.containersecond,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0), -- sex
			zindex = menu.basezindex + -2,
			color = parameters.colors.e,
			visible = true,
			thickness = 0,
			transparency = 1,
			filled = true,
			name = "okay",
		})
		menu.openclose[1 + #menu.openclose] = menu.objects.maincontainer

		menu.objects.tabs = {}

		local function openedtab(tab) -- fuck u fuck u fuck u
			if menu.uiopen == false then return end
			for i, v in next, (menu.objects.tabs) do
				local this = v
				if i ~= tab then -- not us
					if this.maincontainer.visible ~= false then
						this.maincontainer.visible = false
						for i2, v2 in next, (this.toggle) do
							v2.visible = false
						end
					end
				else
					if this.maincontainer.visible ~= true then
						this.maincontainer.visible = true
						this.maincontainer.position = this.maincontainer.position
						this.maincontainer.size = this.maincontainer.size
						for i2, v2 in next, (this.toggle) do
							v2.visible = true
						end
					end
				end
			end
		end

		for i, v in next, (parameters.tabs) do
			local this = {}
			local tab = v
			this.maincontainer = drawingFunction("frame", { -- thing
				parent = menu.objects.maincontainer,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, -32, 1, -32),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 1,
				color = Color3.fromRGB(46, 46, 46),
				visible = false,
				thickness = 0,
				transparency = 0,
				filled = true,
				name = "okay",
			})

			this.elementbox = drawingFunction("frame", { -- actually holds buttons n shit
				parent = this.maincontainer,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 0, 1, 0),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 2,
				color = Color3.new(1, 1, 1),
				visible = true,
				thickness = 0,
				transparency = 0,
				filled = true,
				name = "okay",
			})

			this.titleback = drawingFunction("frame", {
				parent = menu.objects.tabsholder,
				anchorpoint = newvec2(0, 0.5),
				size = newudim2(1 / #parameters.tabs, 0, 1, 0),
				position = newudim2((i - 1) * (1 / #parameters.tabs), 0, 0.5, 0),
				zindex = menu.basezindex + 2,
				color = Color3.fromRGB(46, 46, 46),
				visible = true,
				thickness = 0,
				transparency = 0,
				filled = true,
				activated = true,
				name = "okay",
			})

			this.title = drawingFunction("text", {
				parent = this.titleback,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0.5, -((#tab * 7)/2), 0.5, -8),
				zindex = menu.basezindex + 4,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				text = tab,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title

			this.toggleback = {}
			this.toggle = {}
			for i2 = 1, 2 do -- what the fuck??
				this.toggleback[i2] = drawingFunction("frame", {
					parent = this.titleback,
					anchorpoint = newvec2(0.5, 0),
					size = newudim2(1, -4, 0, 2),
					position = newudim2(0.5, 0, 0, 15 + (i2 * 2)),
					zindex = menu.basezindex + 2,
					color = parameters.colors.f:lerp(parameters.colors.g, (i2 - 1) / 1),
					visible = true,
					thickness = 0,
					transparency = 1,
					filled = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = this.toggleback[i2]

				this.toggle[i2] = drawingFunction("frame", {
					parent = this.titleback,
					anchorpoint = newvec2(0.5, 0),
					size = newudim2(1, -4, 0, 2),
					position = newudim2(0.5, 0, 0, 15 + (i2 * 2)),
					zindex = menu.basezindex + 2,
					color = parameters.accent:lerp(Color3.fromRGB(math.clamp((parameters.accent.r * 255) - 100, 0, 255), math.clamp((parameters.accent.g * 255) - 100, 0, 255), math.clamp((parameters.accent.b * 255) - 100, 0, 255)), ((i2 - 1) / 1)),
					visible = i == 1,
					thickness = 0,
					transparency = 1,
					filled = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = this.toggle[i2]
			end
			menu.accents[1 + #menu.accents] = {this.toggle, "tabs"}

			menu.objects.tabs[tab] = this
			menu.subsections[tab] = {}
			menu.subtabs[tab] = {}
			menu.subsections[tab][1] = {}
			menu.subsections[tab][2] = {}
			menu.tabs[tab] = this.elementbox
			menu.directory[tab] = {}
			menu.elements[tab] = {}

			this.titleback.clicked:Connect(function()
				openedtab(tab)
			end)
		end

		openedtab(parameters.tabs[1])

		function menu:createsubsection(param) -- hiii gassy wassy <3
			local tab = param.tab
			local targettab = menu.tabs[tab]
			local name = param.name
			local side = param.side
			--local length = floor((parameters.length * targettab.absolutesize.y) + 0.5)
			local this = {}

			local xoffset = 0
			local yoffset = 0

			-- check the bounds
			local lastid = 0
			for i, v in next, (menu.subsections[tab][side]) do
				yoffset = yoffset + v.bounds.y
				if v.id > lastid then
					lastid = v.id
				end
			end
			this.id = lastid + 1
			xoffset = (side - 1) * targettab.absolutesize.x / 2
			yoffset = yoffset / targettab.absolutesize.y

			this.maincontainer = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targettab,
				anchorpoint = newvec2(0, 0),
				size = newudim2(0.5, 0, param.length, 0),
				position = newudim2((side - 1) / 2, 0, yoffset, 0),
				zindex = menu.basezindex + 5,
				color = Color3.fromRGB(0, 0, 0),
				visible = true,
				thickness = 0,
				transparency = 0,
				activated = true,
				filled = true,
				name = "okay",
			})
			this.container = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.maincontainer,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, -16, 1, -16),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 6,
				color = parameters.colors.e,
				visible = true,
				thickness = 0,
				transparency = 1,
				filled = true,
				activated = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.container

			do
				local scrollBar = {}
				scrollBar.maincontainer = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = this.container,
					anchorpoint = newvec2(0, 0.5),
					size = newudim2(0, 3, 1, 0),
					position = newudim2(1, -3, 0.5, 0),
					zindex = menu.basezindex + 7,
					color = parameters.colors.c,
					visible = false,
					thickness = 0,
					filled = true,
					activated = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = scrollBar.maincontainer
				scrollBar.scroller = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = scrollBar.maincontainer,
					anchorpoint = newvec2(1, 0),
					size = newudim2(0, 2, 0.5, 0),
					position = newudim2(1, 0, 0, 1),
					zindex = menu.basezindex + 8,
					--color = parameters.colors.f,
					color = menu.accent,
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = scrollBar.scroller
				menu.accents[1 + #menu.accents] = scrollBar.scroller

				if not param.ignoreScrolling then
					utilities.mouse.scrollup:Connect(function(d)
						if menu.isadropdownopen  or menu.isacolorpickeropen or menu.uiopen == false then return end
						if utilities.mousechecks.inbounds(this.container, utilities.mouse.position) and this.container.drawingobject.Visible and scrollBar.maincontainer.drawingobject.Visible then
							local currentY = scrollBar.scroller.position.Y.Offset - (d * 10)
							currentY = math.clamp(currentY, 1, scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)
							scrollBar.scroller.position = newudim2(1, 0, 0, currentY)

							local scrolledBy = (currentY - 1) / (scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)

							local shitInPanel = 8
							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									shitInPanel = shitInPanel + v.bounds.y
								end
							end
							shitInPanel = shitInPanel + 24

							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									local theFlag = v.myflag

									if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
										v.hitbox.position = newudim2(v.hitbox.position.X.Scale, v.hitbox.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.hitbox.position.Y.Offset)
										if v.hitbox.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.hitbox.absoluteposition.y < this.container.absoluteposition.y then
											v.hitbox.visible = false
										else
											v.hitbox.visible = true

											v.hitbox.size = v.hitbox.size + newudim2(0, 1, 0, 1)
											v.hitbox.size = v.hitbox.size - newudim2(0, 1, 0, 1)
										end
									elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
										v.holder.position = newudim2(v.holder.position.X.Scale, v.holder.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.holder.position.Y.Offset)
										if v.holder.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.holder.absoluteposition.y < this.container.absoluteposition.y then
											v.holder.visible = false
										else
											v.holder.visible = true

											v.holder.size = v.holder.size + newudim2(0, 1, 0, 1)
											v.holder.size = v.holder.size - newudim2(0, 1, 0, 1)
										end
									end
								end
							end
						end
					end)
					utilities.mouse.scrolldown:Connect(function(d)
						if menu.isadropdownopen  or menu.isacolorpickeropen or menu.uiopen == false then return end
						if utilities.mousechecks.inbounds(this.container, utilities.mouse.position) and this.container.drawingobject.Visible and scrollBar.maincontainer.drawingobject.Visible then
							local currentY = scrollBar.scroller.position.Y.Offset - (d * 10)
							currentY = math.clamp(currentY, 1, scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)
							scrollBar.scroller.position = newudim2(1, 0, 0, currentY)

							local scrolledBy = (currentY - 1) / (scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)

							local shitInPanel = 8
							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									shitInPanel = shitInPanel + v.bounds.y
								end
							end
							shitInPanel = shitInPanel + 24

							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									local theFlag = v.myflag

									if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
										v.hitbox.position = newudim2(v.hitbox.position.X.Scale, v.hitbox.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.hitbox.position.Y.Offset)
										if v.hitbox.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.hitbox.absoluteposition.y < this.container.absoluteposition.y then
											v.hitbox.visible = false
										else
											v.hitbox.visible = true

											v.hitbox.size = v.hitbox.size + newudim2(0, 1, 0, 1)
											v.hitbox.size = v.hitbox.size - newudim2(0, 1, 0, 1)
										end
									elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
										v.holder.position = newudim2(v.holder.position.X.Scale, v.holder.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.holder.position.Y.Offset)
										if v.holder.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.holder.absoluteposition.y < this.container.absoluteposition.y then
											v.holder.visible = false
										else
											v.holder.visible = true

											v.holder.size = v.holder.size + newudim2(0, 1, 0, 1)
											v.holder.size = v.holder.size - newudim2(0, 1, 0, 1)
										end
									end
								end
							end
						end
					end)
				end

				if not param.ignoreScrolling then
					scrollBar.maincontainer.clicked:Connect(function()
						if menu.isadropdownopen  or menu.isacolorpickeropen or menu.uiopen == false then return end
						scrollBar.updaterConn = utilities.mouse.moved:Connect(function()
							local currentY = utilities.mouse.position.y - scrollBar.maincontainer.absoluteposition.y - math.floor(scrollBar.scroller.absolutesize.y / 2)
							currentY = math.clamp(currentY, 1, scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)
							scrollBar.scroller.position = newudim2(1, 0, 0, currentY)

							local scrolledBy = (currentY - 1) / (scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)

							local shitInPanel = 8
							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									shitInPanel = shitInPanel + v.bounds.y
								end
							end
							shitInPanel = shitInPanel + 24

							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									local theFlag = v.myflag

									if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
										v.hitbox.position = newudim2(v.hitbox.position.X.Scale, v.hitbox.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.hitbox.position.Y.Offset)
										if v.hitbox.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.hitbox.absoluteposition.y < this.container.absoluteposition.y then
											v.hitbox.visible = false
										else
											v.hitbox.visible = true

											v.hitbox.size = v.hitbox.size + newudim2(0, 1, 0, 1)
											v.hitbox.size = v.hitbox.size - newudim2(0, 1, 0, 1)
										end
									elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
										v.holder.position = newudim2(v.holder.position.X.Scale, v.holder.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.holder.position.Y.Offset)
										if v.holder.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.holder.absoluteposition.y < this.container.absoluteposition.y then
											v.holder.visible = false
										else
											v.holder.visible = true

											v.holder.size = v.holder.size + newudim2(0, 1, 0, 1)
											v.holder.size = v.holder.size - newudim2(0, 1, 0, 1)
										end
									end
								end
							end
						end)
					end)

					utilities.mouse.mousebutton1up:Connect(function()
						if scrollBar.updaterConn then 
							scrollBar.updaterConn:Disconnect()
						end
					end)
					this.scrollBar = scrollBar
				end
			end

			this.containeroutline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.container,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 5,
				color = parameters.colors.c,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.containeroutline

			this.containeroutline2 = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.containeroutline,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 4,
				color = parameters.colors.a,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.containeroutline2

			this.title = drawingFunction("text", {
				parent = this.container,
				anchorpoint = newvec2(0, 0.5),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 18, 0, -2),
				zindex = menu.basezindex + 12,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title

			do
				local dragConn
				this.maincontainer.clicked:Connect(function()
					if menu.isadropdownopen  or menu.isacolorpickeropen or menu.uiopen == false then return end
					if utilities.mouse.position.y > (this.container.absoluteposition.y + this.container.absolutesize.y) and not param.ignoreResizing then
						dragConn = runservice.RenderStepped:Connect(function()
							this.title.color = menu.accent
							this.containeroutline.color = menu.accent
							local real = utilities.mouse.position.y - this.container.absoluteposition.y
							local nextPanel = nil
							for i, v in next, menu.subsections[tab][side] do
								if v.id == this.id + 1 then
									nextPanel = v
									break
								end
							end

							local emptySpace = targettab.absolutesize.y
							for i, v in next, menu.subsections[tab][side] do
								if v ~= this then
									emptySpace = emptySpace - v.maincontainer.absolutesize.y
								end
							end
							local canExtendUpTo = emptySpace / targettab.absolutesize.y

							this.maincontainer.size = newudim2(0.5, 0, math.clamp(real / (targettab.absolutesize.y), 0.1, canExtendUpTo), 0)

							local positions = {}
							for i, v in next, (menu.subsections[tab][side]) do
								positions[1 + #positions] = {
									yPos = v.maincontainer.absoluteposition.y,
									ref = v
								}
							end

							table.sort(positions, function(a, b) return a.yPos < b.yPos end)

							local yoffset = 0
							local real = 0
							for i, v in next, (positions) do
								real = real + 1
								v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
								v.ref.id = real
								yoffset = yoffset + v.ref.bounds.y
							end  
						end)
					elseif utilities.mouse.position.y < this.container.absoluteposition.y and not param.ignoreMoving then
						local clickedWhere = utilities.mouse.position - this.maincontainer.absoluteposition
						dragConn = runservice.RenderStepped:Connect(function()
							this.title.color = menu.accent
							this.containeroutline.color = menu.accent
							this.maincontainer.position = newudim2(this.maincontainer.position.X.Scale, utilities.mouse.position.x - clickedWhere.x - ((this.maincontainer.position.X.Scale * targettab.absolutesize.X) + targettab.absoluteposition.X), this.maincontainer.position.Y.Scale, utilities.mouse.position.y - clickedWhere.y - ((this.maincontainer.position.Y.Scale * targettab.absolutesize.y) + targettab.absoluteposition.y))

							local prevside = side
							if this.maincontainer.absoluteposition.x < targettab.absoluteposition.x then
								if menu.subsections[tab][side - 1] then
									menu.subsections[tab][side][name] = nil
									side = side - 1
								end
							elseif this.maincontainer.absoluteposition.x > targettab.absoluteposition.x + targettab.absolutesize.x then
								if menu.subsections[tab][side + 1] then
									menu.subsections[tab][side][name] = nil
									side = side + 1
								end
							end

							if side ~= prevside then
								menu.subsections[tab][side][name] = this
								do
									local totalBoundsOfShit = 0
									local things = 0
									for i, v in next, (menu.subsections[tab][prevside]) do
										v.maincontainer.size = v.panelResize.originalSize

										totalBoundsOfShit = totalBoundsOfShit + v.maincontainer.absolutesize.y
										things = things + 1
									end
									if totalBoundsOfShit > targettab.absolutesize.y then
										totalBoundsOfShit = 0
										for i, v in next, (menu.subsections[tab][prevside]) do
											local shitInPanel = 8
											for i2, v2 in next, (menu.elements[tab][i]) do
												if type(v2) == "table" then
													shitInPanel = shitInPanel + v2.bounds.y
												end
											end

											-- nigeh u dont need THAT much space xD
											if v.container.absolutesize.y > shitInPanel then
												v.maincontainer.size = newudim2(v.maincontainer.size.X.Scale, v.maincontainer.size.X.Offset, (shitInPanel + 24) / targettab.absolutesize.y, 0)
											end
											totalBoundsOfShit = totalBoundsOfShit + v.maincontainer.absolutesize.y
										end
									end
									if totalBoundsOfShit > targettab.absolutesize.y then
										local howMuchBiggerIsThisBullshit = (totalBoundsOfShit - targettab.absolutesize.y) / targettab.absolutesize.y
										local eachSmallerBy = howMuchBiggerIsThisBullshit / things

										for i, v in next, (menu.subsections[tab][prevside]) do
											v.maincontainer.size = newudim2(v.maincontainer.size.X.Scale, v.maincontainer.size.X.Offset, v.maincontainer.size.Y.Scale - eachSmallerBy, v.maincontainer.size.Y.Offset)
										end
									end
								end
								do
									local totalBoundsOfShit = 0
									local things = 0
									for i, v in next, (menu.subsections[tab][side]) do
										v.maincontainer.size = v.panelResize.originalSize

										totalBoundsOfShit = totalBoundsOfShit + v.maincontainer.absolutesize.y
										things = things + 1
									end
									if totalBoundsOfShit > targettab.absolutesize.y then
										totalBoundsOfShit = 0
										for i, v in next, (menu.subsections[tab][side]) do
											local shitInPanel = 8
											for i2, v2 in next, (menu.elements[tab][i]) do
												if type(v2) == "table" then
													shitInPanel = shitInPanel + v2.bounds.y
												end
											end

											-- nigeh u dont need THAT much space xD
											if v.container.absolutesize.y > shitInPanel then
												v.maincontainer.size = newudim2(v.maincontainer.size.X.Scale, v.maincontainer.size.X.Offset, (shitInPanel + 24) / targettab.absolutesize.y, 0)
											end
											totalBoundsOfShit = totalBoundsOfShit + v.maincontainer.absolutesize.y
										end
									end
									if totalBoundsOfShit > targettab.absolutesize.y then
										local howMuchBiggerIsThisBullshit = (totalBoundsOfShit - targettab.absolutesize.y) / targettab.absolutesize.y
										local eachSmallerBy = howMuchBiggerIsThisBullshit / things

										for i, v in next, (menu.subsections[tab][side]) do
											v.maincontainer.size = newudim2(v.maincontainer.size.X.Scale, v.maincontainer.size.X.Offset, v.maincontainer.size.Y.Scale - eachSmallerBy, v.maincontainer.size.Y.Offset)
										end
									end
								end
							end

							do  
								local positions = {}
								for i, v in next, (menu.subsections[tab][side]) do
									positions[1 + #positions] = {
										yPos = v.maincontainer.absoluteposition.y,
										ref = v
									}
								end

								table.sort(positions, function(a, b) return a.yPos < b.yPos end)

								local yoffset = 0
								local real = 0
								for i, v in next, (positions) do
									real = real + 1
									if v.ref ~= this then
										v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
									end
									v.ref.id = real
									yoffset = yoffset + v.ref.bounds.y
								end  
								if side ~= prevside then
									local positions = {}
									for i, v in next, (menu.subsections[tab][prevside]) do
										positions[1 + #positions] = {
											yPos = v.maincontainer.absoluteposition.y,
											ref = v
										}
									end

									table.sort(positions, function(a, b) return a.yPos < b.yPos end)

									local yoffset = 0
									local real = 0
									for i, v in next, (positions) do
										real = real + 1
										v.ref.maincontainer.position = newudim2((prevside - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
										v.ref.id = real
										yoffset = yoffset + v.ref.bounds.y
									end  
								end
							end                                
						end)
					end
				end)

				utilities.mouse.mousebutton1up:Connect(function()
					if dragConn then
						this.title.color = Color3.fromRGB(255, 255, 255)
						this.containeroutline.color = parameters.colors.c
						dragConn:Disconnect()

						local positions = {}
						for i, v in next, (menu.subsections[tab][side]) do
							positions[1 + #positions] = {
								yPos = v.maincontainer.absoluteposition.y,
								ref = v
							}
						end

						table.sort(positions, function(a, b) return a.yPos < b.yPos end)

						local yoffset = 0
						local real = 0
						for i, v in next, (positions) do
							real = real + 1
							v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
							v.ref.id = real
							yoffset = yoffset + v.ref.bounds.y
						end                                        
					end
				end)
			end


			this.block = drawingFunction("frame", {
				parent = this.title,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 8, 0, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 5,
				color = parameters.colors.e,
				visible = false,
				thickness = 0,
				filled = true,
				name = "okay",
			})

			menu.openclose[1 + #menu.openclose] = this.block
			this.bounds = this.maincontainer.absolutesize
			menu.directory[tab][name] = this.container
			menu.elements[tab][name] = {}
			if not param.ignoreScrolling then
				menu.elements[tab][name].updateScrollBarLength = function()
					local shitInPanel = 8
					for i, v in next, (menu.elements[tab][name]) do
						if type(v) == "table" then
							shitInPanel = shitInPanel + v.bounds.y
						end
					end
					if shitInPanel > this.container.absolutesize.y then
						shitInPanel = shitInPanel + 24
						this.scrollBar.maincontainer.visible = true
						this.scrollBar.scroller.visible = true
						this.scrollBar.scroller.size = newudim2(0, 2, (this.container.absolutesize.y / shitInPanel), 0)

						local scrollBar = this.scrollBar

						local currentY = scrollBar.scroller.position.Y.Offset
						currentY = (currentY < 1) and 1 or (currentY > scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1) and scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1 or currentY 

						scrollBar.scroller.position = newudim2(1, 0, 0, currentY)

						local scrolledBy = (currentY - 1) / (scrollBar.maincontainer.absolutesize.y - scrollBar.scroller.absolutesize.y - 1)
						local posAt = (-scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y))
						if posAt == 1/0 or posAt == -1/0 or posAt ~= posAt then
							this.scrollBar.maincontainer.visible = false
							this.scrollBar.scroller.visible = false

							for i, v in next, (menu.elements[tab][name]) do
								if type(v) == "table" then
									local theFlag = v.myflag
									if theFlag then
										if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
											v.hitbox.visible = true

											v.hitbox.size = v.hitbox.size + newudim2(0, 0, 0, 1)
											v.hitbox.size = v.hitbox.size - newudim2(0, 0, 0, 1)
										elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
											v.holder.visible = true

											v.holder.size = v.holder.size + newudim2(0, 0, 0, 1)
											v.holder.size = v.holder.size - newudim2(0, 0, 0, 1)
										end
									end
								end
							end
							return
						end
						for i, v in next, (menu.elements[tab][name]) do
							if type(v) == "table" then
								local theFlag = v.myflag
								if theFlag then
									if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
										v.hitbox.position = newudim2(v.hitbox.position.X.Scale, v.hitbox.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.hitbox.position.Y.Offset)
										if v.hitbox.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.hitbox.absoluteposition.y < this.container.absoluteposition.y then
											v.hitbox.visible = false
										else
											v.hitbox.visible = true
										end
										v.hitbox.size = v.hitbox.size + newudim2(0, 1, 0, 1)
										v.hitbox.size = v.hitbox.size - newudim2(0, 1, 0, 1)
									elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
										v.holder.position = newudim2(v.holder.position.X.Scale, v.holder.position.X.Offset, -scrolledBy * ((shitInPanel - this.container.absolutesize.y) / this.container.absolutesize.y), v.holder.position.Y.Offset)
										if v.holder.absoluteposition.y + v.bounds.y > ((this.container.absolutesize.y + this.container.absoluteposition.y) - 8) or v.holder.absoluteposition.y < this.container.absoluteposition.y then
											v.holder.visible = false
										else
											v.holder.visible = true
										end
										v.holder.size = v.holder.size + newudim2(0, 1, 0, 1)
										v.holder.size = v.holder.size - newudim2(0, 1, 0, 1)
									end
								end
							end
						end
					else
						this.scrollBar.maincontainer.visible = false
						this.scrollBar.scroller.visible = false

						for i, v in next, (menu.elements[tab][name]) do
							if type(v) == "table" then
								local theFlag = v.myflag
								if theFlag then
									if theFlag.type == "toggle" or theFlag.type == "button" or theFlag.type == "textbox" then
										v.hitbox.visible = true
										v.hitbox.position = newudim2(v.hitbox.position.X.Scale, v.hitbox.position.X.Offset, 0, v.hitbox.position.Y.Offset)

										v.hitbox.size = v.hitbox.size + newudim2(0, 0, 0, 1)
										v.hitbox.size = v.hitbox.size - newudim2(0, 0, 0, 1)

										v.hitbox.position = v.hitbox.position + newudim2(0, 0, 0, 1)
										v.hitbox.position = v.hitbox.position - newudim2(0, 0, 0, 1)
									elseif theFlag.type == "slider" or theFlag.type == "dropdown" then
										v.holder.visible = true
										v.holder.position = newudim2(v.holder.position.X.Scale, v.holder.position.X.Offset, 0, v.holder.position.Y.Offset)

										v.holder.size = v.holder.size + newudim2(0, 0, 0, 1)
										v.holder.size = v.holder.size - newudim2(0, 0, 0, 1)

										v.holder.position = v.holder.position + newudim2(0, 0, 0, 1)
										v.holder.position = v.holder.position - newudim2(0, 0, 0, 1)
									end
								end
							end
						end
					end
				end

				this.container.getpropertychangedsignal:Connect(function(prop, val) 
					if prop == "absolutesize" then
						menu.elements[tab][name].updateScrollBarLength()
						this.bounds = this.maincontainer.absolutesize
					end
				end)
			else
				menu.elements[tab][name].updateScrollBarLength = function()

				end
			end

			this.panelResize = {
				originalSize = this.maincontainer.size,
				resetSize = function()
					this.maincontainer.size = this.panelResize.originalSize
					this.maincontainer.size = this.maincontainer.size + newudim2(0, 1, 0, 1)
					this.maincontainer.size = this.maincontainer.size - newudim2(0, 1, 0, 1)

					local positions = {}
					for i, v in next, (menu.subsections[tab][side]) do
						positions[1 + #positions] = {
							yPos = v.maincontainer.absoluteposition.y,
							ref = v
						}
					end

					table.sort(positions, function(a, b) return a.yPos < b.yPos end)

					local yoffset = 0
					local real = 0
					for i, v in next, (positions) do
						real = real + 1
						v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
						v.ref.id = real
						yoffset = yoffset + v.ref.bounds.y
					end     
				end,
				getSize = function()
					return this.maincontainer.size
				end,
				setSize = function(new)
					this.maincontainer.size = new
				end,
			}

			this.panelReposition = {
				originalPosition = this.maincontainer.position,
				originalSide = param.side,
				resetPosition = function()
					this.maincontainer.position = this.panelReposition.originalPosition
					this.maincontainer.size = this.maincontainer.size + newudim2(0, 1, 0, 1)
					this.maincontainer.size = this.maincontainer.size - newudim2(0, 1, 0, 1)

					local positions = {}
					for i, v in next, (menu.subsections[tab][side]) do
						positions[1 + #positions] = {
							yPos = v.maincontainer.absoluteposition.y,
							ref = v
						}
					end

					table.sort(positions, function(a, b) return a.yPos < b.yPos end)

					local yoffset = 0
					local real = 0
					for i, v in next, (positions) do
						real = real + 1
						v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
						v.ref.id = real
						yoffset = yoffset + v.ref.bounds.y
					end
				end,
				getPosition = function()
					return this.maincontainer.position
				end,
				resetSide = function()
					menu.subsections[tab][side][name] = nil
					side = this.panelReposition.originalSide
					menu.subsections[tab][this.panelReposition.originalSide][name] = this
				end,
				getSide = function()
					return side
				end,
				setSide = function(new)
					menu.subsections[tab][side][name] = nil
					side = new
					menu.subsections[tab][new][name] = this
				end,
				setPosition = function(new)
					this.maincontainer.position = new

					local positions = {}
					for i, v in next, (menu.subsections[tab][side]) do
						positions[1 + #positions] = {
							yPos = v.maincontainer.absoluteposition.y,
							ref = v
						}
					end

					table.sort(positions, function(a, b) return a.yPos < b.yPos end)

					local yoffset = 0
					local real = 0
					for i, v in next, (positions) do
						real = real + 1
						v.ref.maincontainer.position = newudim2((side - 1) / 2, 0, yoffset / targettab.absolutesize.y, 0)
						v.ref.id = real
						yoffset = yoffset + v.ref.bounds.y
					end
				end,
			}

			menu.subtabs[tab][name] = {}
			menu.subsections[tab][side][name] = this
		end

		menu.tooltip = {}
		menu.tooltip.open = false

		menu.tooltip.backoutline = drawingFunction("frame", { -- for getting the bounds of the thing
			parent = utilities.base,
			anchorpoint = newvec2(0, 0),
			size = newudim2(0, 128, 0, 48),
			position = newudim2(0, 100, 0, 100),
			zindex = menu.basezindex + 23,
			color = menucolors.a,
			visible = true,
			thickness = 0,
			filled = true,
			transparency = 0,
			name = "okay",
		})

		menu.tooltip.container = drawingFunction("frame", { -- for getting the bounds of the thing
			parent = menu.tooltip.backoutline,
			anchorpoint = newvec2(0.5, 0.5),
			size = newudim2(1, -2, 1, -2),
			position = newudim2(0.5, 0, 0.5, 0),
			zindex = menu.basezindex + 24,
			color = menucolors.b,
			visible = true,
			thickness = 0,
			filled = true,
			transparency = 0,
			name = "okay",
		})

		menu.tooltip.title = drawingFunction("text", {
			parent = menu.tooltip.container,
			anchorpoint = newvec2(0, 0),
			size = 13, -- x3
			font = Drawing.Fonts.Plex,
			position = newudim2(0, 4, 0, 2),
			zindex = menu.basezindex + 25,
			color = Color3.fromRGB(255, 255, 255),
			visible = true,
			outline = false,
			outlinecolor = Color3.fromRGB(12, 12, 12),
			text = "Example of a tooltip",
			transparency = 0,
			name = "okay",
		})

		menu.tooltip.currenttrans = 0
		menu.tooltip.hoveredfor = 0
		function menu:calltooltip(text, object, offset)
			if menu.tooltip.connection then
				menu.tooltip.connection:Disconnect()
				menu.tooltip.connection = nil
			end
			menu.tooltip.hoveredfor = 0
			menu.tooltip.currenttrans = 0
			menu.tooltip.backoutline.transparency = menu.tooltip.currenttrans
			menu.tooltip.container.transparency = menu.tooltip.currenttrans
			menu.tooltip.title.transparency = menu.tooltip.currenttrans

			menu.tooltip.backoutline.position = newudim2(0, object.absoluteposition.x + 4 + offset.x, 0, object.absoluteposition.y + object.absolutesize.y + offset.y)

			local splitText = {}
			local charInline = 0
			for i, v in next, text:split("") do
				charInline = charInline + 1
				if v == " " then
					splitText.lastSpaceIdx = i
				end
				if charInline >= math.floor((menu.objects.backborder.absolutesize.x * 0.5) / 6) then
					splitText.lastSpaceIdx = splitText.lastSpaceIdx or i
					splitText.lastSpaceIdx = i
					v = "\n"
					charInline = 0
				end
				table.insert(splitText, v)
			end
			text = table.concat(splitText)

			local split = text:split("\n")
			local textLineLength = {}
			local yLength = 0
			for i, v in next, split do
				local textBound = Drawing.new("Text")
				textBound.Visible = true
				textBound.Font = Drawing.Fonts.Plex
				textBound.Size = 13
				textBound.Text = v
				local textBounds = textBound.TextBounds
				textBound.Visible = false
				textBound:Remove()
				textBound = nil

				textLineLength[i] = textBounds.x
				yLength = yLength + textBounds.y
			end

			table.sort(textLineLength, function(a, b) return a > b end)
			local longestThing = textLineLength[1]

			menu.tooltip.backoutline.size = newudim2(0, longestThing + 8, 0, yLength + 8)
			menu.tooltip.title.text = text

			local createdPos = object.absoluteposition
			menu.tooltip.connection = runservice.Stepped:Connect(function(u, dt)
				if object.hovering then
					menu.tooltip.hoveredfor = menu.tooltip.hoveredfor + dt
					if menu.tooltip.hoveredfor > 1 then
						menu.tooltip.currenttrans = menu.tooltip.currenttrans + (dt * 4)
					end
				else
					menu.tooltip.currenttrans = menu.tooltip.currenttrans - (dt * 4)
				end

				menu.tooltip.currenttrans = clamp(menu.tooltip.currenttrans, 0, 1)
				menu.tooltip.backoutline.transparency = menu.tooltip.currenttrans
				menu.tooltip.container.transparency = menu.tooltip.currenttrans
				menu.tooltip.title.transparency = menu.tooltip.currenttrans

				if menu.uiopen == false or createdPos ~= object.absoluteposition then
					menu.tooltip.connection:Disconnect()
					menu.tooltip.connection = nil
					menu.tooltip.currenttrans = 0
					menu.tooltip.hoveredfor = 0
					menu.tooltip.backoutline.transparency = menu.tooltip.currenttrans
					menu.tooltip.container.transparency = menu.tooltip.currenttrans
					menu.tooltip.title.transparency = menu.tooltip.currenttrans
				end
			end)
		end        

		local baseoffset = 0
		local boundoffset = 0
		function menu:createtoggle(parameters)
			local tab = parameters.tab
			local subsection = parameters.subsection
			local targetsection = menu.directory[tab][subsection]
			local name = parameters.name
			local flag = parameters.flag
			local tooltip = parameters.tooltip
			local this = {}
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag -- mypenis
			myflag.__index = menu.flags[flag]
			myflag.type = "toggle"
			myflag.name = name
			myflag.value = parameters.value
			myflag.changed = utilities.signal.new()
			myflag.element = this

			local offset = baseoffset + 8

			for i, v in next, (menu.elements[tab][subsection]) do
				if type(v) == "table" then
					offset = offset + v.bounds.y
				end
			end

			this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetsection,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, 0, 0, 14),
				position = newudim2(0.5, 0, 0, offset),
				zindex = menu.basezindex + 6,
				color = Color3.fromRGB(0, 0, 0),
				visible = true,
				thickness = 0,
				filled = true,
				transparency = 0,
				name = "okay",
			})

			this.toggle = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.hitbox,
				anchorpoint = newvec2(0, 0.5),
				size = newudim2(0, 8, 0, 8),
				position = newudim2(0, 8, 0.5, 0),
				zindex = menu.basezindex + 7,
				color =  menu.startingParameters.colors.f,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.toggle

			this.toggleoutline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.toggle,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 6,
				color = Color3.fromRGB(12, 12, 12),
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.toggleoutline

			this.toggled = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.toggle,
				anchorpoint = newvec2(0, 0),
				size = newudim2(1, 0, 1, 0),
				position = newudim2(0, 0, 0, 0),
				zindex = menu.basezindex + 7,
				color = menu.accent,
				visible = false,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			this.toggled.visible = myflag.value
			menu.openclose[1 + #menu.openclose] = this.toggled
			menu.accents[1 + #menu.accents] = this.toggled

			this.title = drawingFunction("text", {
				parent = this.hitbox,
				anchorpoint = newvec2(0, 0.5),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 24, 0.5, -1),
				zindex = menu.basezindex + 6,
				color = parameters.detected and Color3.fromRGB(255, 106, 79) or Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title
			this.realhitbox = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.hitbox,
				anchorpoint = newvec2(0, 0.5),
				size = newudim2(0, 32 + this.title.absolutesize.x, 1, 0),
				position = newudim2(0, 0, 0.5, 0),
				zindex = menu.basezindex + 8,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				thickness = 0,
				filled = true,
				transparency = 0,
				activated = true,
				name = "okay",
			})
			menu.activations[1 + #menu.activations] = this.realhitbox
			function myflag:setvalue(new) -- how 2 config in 5 seconds
				myflag.value = new
				this.toggled.visible = new
				myflag.changed:Fire()
			end

			this.realhitbox.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				myflag:setvalue(not myflag.value)
			end)

			if tooltip then
				this.realhitbox.mouseenter:Connect(function()
					if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
					menu:calltooltip(tooltip, this.realhitbox, newvec2(0, 0))
				end)
			end

			this.bounds = newvec2(0, 14 + boundoffset)
			this.accessories = {} -- color pickers and what not
			menu.elements[tab][subsection][name] = this -- keep a record of this fuck
			menu.elements[tab][subsection].updateScrollBarLength()
		end

		function menu:createcolorpicker(parameters)
			local targetobj = menu.elements[parameters.tab][parameters.subsection][parameters.object]
			if not targetobj.accessories then
				return
			end
			local name = parameters.name
			local flag = parameters.flag
			local this = {}
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag
			myflag.__index = menu.flags[flag]
			myflag.type = "color"
			myflag.name = name
			myflag.color = parameters.color
			myflag.animation = {
				none = true,
				rainbow = false,
				linear = false,
				oscillating = false, 
				sawtooth = false,
				strobe = false
			}
			myflag.animationKeyFrames = {
				linear = {
					["keyframe 1"] = {
						color = parameters.color,
						transparency = parameters.transparency
					},
					["keyframe 2"] = {
						color = parameters.color,
						transparency = parameters.transparency
					}
				},
				oscillating = {
					["keyframe 1"] = {
						color = parameters.color,
						transparency = parameters.transparency
					},
					["keyframe 2"] = {
						color = parameters.color,
						transparency = parameters.transparency
					}
				},
				sawtooth = {
					["keyframe 1"] = {
						color = parameters.color,
						transparency = parameters.transparency
					},
					["keyframe 2"] = {
						color = parameters.color,
						transparency = parameters.transparency
					}
				},
				strobe = {
					["keyframe 1"] = {
						color = parameters.color,
						transparency = parameters.transparency
					},
					["keyframe 2"] = {
						color = parameters.color,
						transparency = parameters.transparency
					}
				},
			} -- color and transparency
			myflag.animationSpeed = {
				rainbow = 100,
				linear = 100,
				oscillating = 100,
				sawtooth = 100,
				strobe = 100
			}
			myflag.transparency = parameters.transparency
			myflag.changed = utilities.signal.new()

			local offset = baseoffset + 12

			for i, v in next, (targetobj.accessories) do
				offset = offset + v.bounds.x -- get the bounds of the current accessories in the thing
			end

			this.outline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetobj.hitbox,
				anchorpoint = newvec2(1, 0.5),
				size = newudim2(0, 24, 0, 12),
				position = newudim2(1, -offset, 0.5, 0),
				zindex = menu.basezindex + 8,
				color = Color3.fromRGB(12, 12, 12),
				visible = true,
				thickness = 0,
				activated = true,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.outline

			this.color = {}
			for i = 1, 5 do
				this.color[i] = utilities:draw("frame", { -- for getting the bounds of the thing, also not using drawingFunction because the gradient isnt part of the ui accents
					parent = this.outline,
					anchorpoint = newvec2(0.5, 0),
					size = newudim2(1, -2, 0, 2),
					position = newudim2(0.5, 0, 0, ((i - 1) * 2) + 1),
					zindex = menu.basezindex + 10,
					color = parameters.color:lerp(Color3.fromRGB(math.clamp(parameters.color.r * 255 - 33, 0, 255), math.clamp(parameters.color.g * 255 - 33, 0, 255), math.clamp(parameters.color.b * 255 - 33, 0, 255)), i / 5),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = this.color[i]
			end

			function myflag:setcolor(new)
				myflag.color = new
				for i = 1, 5 do
					local segment = this.color[i]
					segment.color = new:lerp(Color3.fromRGB(math.clamp(new.r * 255 - 20, 0, 255), math.clamp(new.g * 255 - 20, 0, 255), math.clamp(new.b * 255 - 20, 0, 255)), (i - 1) / 5)
				end
				myflag.changed:Fire()
			end

			function myflag:settransparency(new)
				myflag.transparency = new
				myflag.changed:Fire()
			end

			function myflag:setAnimation(new)
				myflag.animation = new

				if this.animationLoop then
					this.animationLoop:Disconnect()
					this.animationLoop = nil
				end

				-- hard coded cuz FUCK you
				-- funny how evie legit did animations like this better than me x3
				if myflag.animation.rainbow then
					this.animationLoop = runservice.Stepped:Connect(function()
						local oldhue, oldsat, oldval = Color3.toHSV(myflag.color)
						myflag:setcolor(Color3.fromHSV((tick() * (myflag.animationSpeed.rainbow / 100) - math.floor(tick() * (myflag.animationSpeed.rainbow / 100))), oldsat, oldval))
					end)
				elseif myflag.animation.linear then
					this.animationLoop = runservice.Stepped:Connect(function()
						local percentage = (tick() * (myflag.animationSpeed.linear / 100) - math.floor(tick() * (myflag.animationSpeed.linear / 100))) 
						if percentage > 0.5 then
							percentage = percentage - 0.5
							percentage = percentage * 2
							myflag:setcolor(myflag.animationKeyFrames.linear["keyframe 2"].color:Lerp(myflag.animationKeyFrames.linear["keyframe 1"].color, percentage))
							if myflag.transparency then
								local a = myflag.animationKeyFrames.linear["keyframe 2"].transparency
								local b = myflag.animationKeyFrames.linear["keyframe 1"].transparency
								local c = percentage
								myflag:settransparency(a + (b - a)*c)
							end
						else
							percentage = percentage * 2
							myflag:setcolor(myflag.animationKeyFrames.linear["keyframe 1"].color:Lerp(myflag.animationKeyFrames.linear["keyframe 2"].color, percentage))
							if myflag.transparency then
								local a = myflag.animationKeyFrames.linear["keyframe 1"].transparency
								local b = myflag.animationKeyFrames.linear["keyframe 2"].transparency
								local c = percentage
								myflag:settransparency(a + (b - a)*c)
							end
						end
					end)
				elseif myflag.animation.oscillating then
					this.animationLoop = runservice.Stepped:Connect(function()
						local percentage = (tick() * (myflag.animationSpeed.oscillating / 100) - math.floor(tick() * (myflag.animationSpeed.oscillating / 100)))
						if percentage > 0.5 then
							percentage = percentage - 0.5
							myflag:setcolor(myflag.animationKeyFrames.oscillating["keyframe 2"].color:Lerp(myflag.animationKeyFrames.oscillating["keyframe 1"].color, math.sin(percentage * math.pi)))
							if myflag.transparency then
								local a = myflag.animationKeyFrames.oscillating["keyframe 2"].transparency
								local b = myflag.animationKeyFrames.oscillating["keyframe 1"].transparency
								local c = math.sin(percentage * math.pi)
								myflag:settransparency(a + (b - a)*c)
							end
						else
							myflag:setcolor(myflag.animationKeyFrames.oscillating["keyframe 1"].color:Lerp(myflag.animationKeyFrames.oscillating["keyframe 2"].color, math.sin(percentage * math.pi)))
							if myflag.transparency then
								local a = myflag.animationKeyFrames.oscillating["keyframe 1"].transparency
								local b = myflag.animationKeyFrames.oscillating["keyframe 2"].transparency
								local c = math.sin(percentage * math.pi)

								myflag:settransparency(a + (b - a)*c)
							end
						end
					end)
				elseif myflag.animation.strobe then
					this.animationLoop = runservice.Stepped:Connect(function()
						local percentage = (tick() * (myflag.animationSpeed.strobe / 100) - math.floor(tick() * (myflag.animationSpeed.strobe / 100)))
						if percentage > 0.5 then
							myflag:setcolor(myflag.animationKeyFrames.strobe["keyframe 2"].color)
							if myflag.transparency then
								myflag:settransparency(myflag.animationKeyFrames.strobe["keyframe 2"].transparency)
							end
						else
							myflag:setcolor(myflag.animationKeyFrames.strobe["keyframe 1"].color)
							if myflag.transparency then
								myflag:settransparency(myflag.animationKeyFrames.strobe["keyframe 1"].transparency)
							end
						end
					end)
				elseif myflag.animation.sawtooth then
					this.animationLoop = runservice.Stepped:Connect(function()
						local percentage = (tick() * (myflag.animationSpeed.sawtooth / 100) - math.floor(tick() * (myflag.animationSpeed.sawtooth / 100)))
						myflag:setcolor(myflag.animationKeyFrames.sawtooth["keyframe 1"].color:Lerp(myflag.animationKeyFrames.sawtooth["keyframe 2"].color, percentage))
						if myflag.transparency then
							local a = myflag.animationKeyFrames.sawtooth["keyframe 1"].transparency
							local b = myflag.animationKeyFrames.sawtooth["keyframe 2"].transparency
							local c = percentage
							myflag:settransparency(a + (b - a)*c)
						end
					end)
				end
			end

			function myflag:setAnimationKeyFrames(new)
				for t, kf in next, new do
					myflag.animationKeyFrames[t] = kf
				end
			end

			function myflag:setAnimationSpeed(new)
				for t, s in next, new do
					myflag.animationSpeed[t] = s
				end
			end

			myflag:setcolor(parameters.color)
			if myflag.transparency then
				myflag:settransparency(parameters.transparency)
			end

			this.outline.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				menu:callcolorpicker(name, myflag, utilities.mouse.position, myflag.transparency)
			end)

			this.outline.clicked2:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				menu:callcolorcopypaste(myflag, utilities.mouse.position)
			end)

			this.bounds = newvec2(28, 0)
			targetobj.accessories[name] = this
		end

		function menu:createkeybind(parameters)
			local targetobj = menu.elements[parameters.tab][parameters.subsection][parameters.object]
			if not targetobj.accessories then
				return
			end
			local name = parameters.name
			local flag = parameters.flag
			local this = {}
			this.dropdown = {}
			this.dropdownopened = false
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag
			myflag.__index = menu.flags[flag]
			myflag.type = "keybind"
			myflag.value = parameters.value
			myflag.tab = parameters.tab
			myflag.name = name
			myflag.section = parameters.subsection
			myflag.object = parameters.object
			myflag.parentflag = parameters.parentflag
			myflag.activation = "always"
			myflag.key = nil
			myflag.changed = utilities.signal.new()

			local offset = baseoffset + 16

			for i, v in next, (targetobj.accessories) do
				offset = offset + v.bounds.x -- get the bounds of the current accessories in the thing
			end

			this.outline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetobj.hitbox,
				anchorpoint = newvec2(1, 0.5),
				size = newudim2(0, 40, 0, 16),
				position = newudim2(1, -offset, 0.5, 0),
				zindex = menu.basezindex + 7,
				color = menucolors.a,
				visible = true,
				thickness = 1,
				activated = true,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.outline
			menu.activations[1 + #menu.activations] = this.outline
			this.updating = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.outline,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 0, 1, 0),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 8,
				color = menu.accent,
				visible = false,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.accents[1 + #menu.accents] = this.updating

			this.container = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.outline,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, -2, 1, -2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 9,
				color = menucolors.c,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.container
			this.title = drawingFunction("text", {
				parent = this.outline,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0.5, -((7)/2), 0.5, -7),
				zindex = menu.basezindex + 10,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "E",
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title
			for i, v in next, ({"hold", "toggle", "hold off", "always"}) do
				this.dropdown[v] = {}
				this.dropdown[v].outline = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = this.outline,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 64, 0, 22),
					position = newudim2(-1, 16, 1, ((i - 1) * 20) + 2),
					zindex = menu.basezindex + 11,
					color = menucolors.a,
					visible = false,
					thickness = 0,
					filled = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = this.dropdown[v].outline
				this.dropdown[v].container = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = this.dropdown[v].outline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 12,
					color = menucolors.c,
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				this.dropdown[v].title = drawingFunction("text", {
					parent = this.dropdown[v].outline,
					anchorpoint = newvec2(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 4, 0.5, 0),
					zindex = menu.basezindex + 13,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = v,
					name = "okay",
				})

				this.dropdown[v].outline.clicked:Connect(function()
					myflag:setactivation(v)
					for i, v in next, (this.dropdown) do
						v.outline.visible = false
					end
					menu.isadropdownopen = false
				end)
			end

			this.singleupdate = function()
				if not myflag.key then 
					myflag.value = false
				end -- we dont even have a key.....
				if myflag.activation == "always" then
					myflag.value = true
				else
					myflag.value = false
				end
			end

			function myflag:setkey(new)
				if not new or new == "NONE" then -- no key !
					myflag.key = nil
					this.title.text = "NONE"
					this.title.position = newudim2(0.5, -((4*7)/2), 0.5, -7)
				else
					local key = tostring(new)
					myflag.key = key
					this.title.text = string.sub(string.upper(key:sub(14)), 1, 5)
				end
				this.singleupdate()
			end

			function myflag:setactivation(new)
				myflag.activation = new
				for i, v in next, (this.dropdown) do
					v.title.color = (myflag.activation == v.title.text) and menu.accent or Color3.fromRGB(255, 255, 255)
				end
				this.singleupdate()
			end
			myflag:setactivation("always")

			function myflag:setvalue(new)
				myflag.value = new
				this.singleupdate()
			end

			this.outline.clicked2:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				this.dropdownopened = not this.dropdownopened
				menu.isadropdownopen = this.dropdownopened
				for i, v in next, (this.dropdown) do
					v.outline.visible = this.dropdownopened
					v.title.color = (myflag.activation == v.title.text) and menu.accent or Color3.fromRGB(255, 255, 255)
					v.outline.position = v.outline.position
				end
			end)

			local keyupdater
			this.outline.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				this.updating.visible = true
				keyupdater = userinputservice.InputBegan:Connect(function(Input, gameProcessed)
					if userinputservice:GetFocusedTextBox() then return end
					if Input.UserInputType == Enum.UserInputType.Keyboard then
						if Input.KeyCode.Value == 27 or Input.KeyCode.Value == 8 then 
							myflag:setkey(nil)
						else
							myflag:setkey(Input.KeyCode)
						end
						this.updating.visible = false
						if keyupdater then
							keyupdater:Disconnect()
							keyupdater = nil
						end
					end
				end)
			end)
			myflag:setkey(parameters.value)

			userinputservice.InputBegan:Connect(function(Input, gameProcessed)
				if userinputservice:GetFocusedTextBox() then return end
				if not myflag.key then 
					myflag.value = false
				end -- we dont even have a key.....
				if myflag.activation == "always" then
					myflag.value = true
				end
				if myflag.activation == "always" or not myflag.key then
					return 
				end
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					if tostring(Input.KeyCode) == myflag.key then
						if myflag.activation == "toggle" then
							myflag.value = not myflag.value
							myflag.changed:Fire()
						end
						if myflag.activation == "hold" then
							myflag.value = true
							myflag.changed:Fire()
						end
						if myflag.activation == "hold off" then
							myflag.value = false
							myflag.changed:Fire()
						end
					end
				end
			end)

			userinputservice.InputEnded:Connect(function(Input, gameProcessed)
				if userinputservice:GetFocusedTextBox() then return end
				if not myflag.key then 
					myflag.value = false
				end -- we dont even have a key.....
				if myflag.activation == "always" then
					myflag.value = true
				end
				if myflag.activation == "always" or not myflag.key then
					return 
				end
				if myflag.activation == "always" then
					myflag.value = true
				end
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					if tostring(Input.KeyCode) == myflag.key then
						if myflag.activation == "hold" then
							myflag.value = false
							myflag.changed:Fire()
						end
						if myflag.activation == "hold off" then
							myflag.value = true
							myflag.changed:Fire()
						end
					end
				end
			end)


			this.bounds = newvec2(44, 0)
			targetobj.accessories[name] = this
		end

		function menu:createslider(parameters)
			local tab = parameters.tab
			local subsection = parameters.subsection
			local targetsection = menu.directory[tab][subsection]
			local name = parameters.name
			local flag = parameters.flag
			local minimum = parameters.minimum
			local tooltip = parameters.tooltip
			local maximum = parameters.maximum
			local suffix = parameters.suffix ~= nil and parameters.suffix or ""
			local customtext = parameters.custom ~= nil and parameters.custom or {}

			local this = {}
			local offset = baseoffset + 0
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag -- mypenis
			myflag.__index = menu.flags[flag]
			myflag.type = "slider"
			myflag.name = name
			myflag.value = parameters.value
			myflag.element = this
			myflag.changed = utilities.signal.new()

			for i, v in next, (menu.elements[tab][subsection]) do
				if type(v) == "table" then
					offset = offset + v.bounds.y
				end
			end

			this.holder = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetsection,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, 0, 0, 24),
				position = newudim2(0.5, 0, 0, offset),
				zindex = menu.basezindex + 6,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				thickness = 0,
				filled = true,
				transparency = 0,
				name = "okay",
			})

			this.title = drawingFunction("text", {
				parent = this.holder,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 16, 0, 8),
				zindex = menu.basezindex + 7,
				color = parameters.detected and Color3.fromRGB(255, 106, 79) or Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title
			this.sliderback = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.holder,
				anchorpoint = newvec2(0, 0),
				size = newudim2(1, -32, 0, 6),
				position = newudim2(0, 16, 0, 24),
				zindex = menu.basezindex + 7,
				color = menucolors.b,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.sliderback
			this.sliderbackoutline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.sliderback,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 6,
				color = menucolors.d,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.sliderbackoutline

			this.slider = {}
			for i = 1, 6 do
				this.slider[i] = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = this.sliderback,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 6, 0, 1),
					position = newudim2(0, 0, 0, i),
					zindex = menu.basezindex + 9,
					color = menu.accent:lerp(Color3.fromRGB(math.clamp((menu.accent.r * 255) - 5, 0, 255), math.clamp((menu.accent.g * 255) - 5, 0, 255), math.clamp((menu.accent.b * 255) - 5, 0, 255)), (i - 1) / 5),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				menu.openclose[1 + #menu.openclose] = this.slider[i]
			end

			menu.accents[1 + #menu.accents] = this.slider

			this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.sliderback,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 0, 1, 10),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 7,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				thickness = 0,
				transparency = 0,
				activated = true,
				filled = true,
				name = "okay",
			})
			menu.activations[1 + #menu.activations] = this.hitbox

			this.valuetitle = drawingFunction("text", {
				parent = this.sliderback,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(1, -((2 * 7)/2), 0, 0),
				zindex = menu.basezindex + 9,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "0°",
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.valuetitle

			this.addtext = drawingFunction("text", {
				parent = this.sliderback,
				anchorpoint = newvec2(1, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(1, 3, 0.5, -7),
				zindex = menu.basezindex + 9,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				activated = true,
				text = "+",
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.addtext

			this.subtext = drawingFunction("text", {
				parent = this.sliderback,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, -10, 0.5, -7),
				zindex = menu.basezindex + 9,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "-",
				activated = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.subtext

			local textupdateconnection -- so u can click on the value text and manually enter a number
			function myflag:setvalue(new)
				if new == nil then
					new = 0
				end
				local newtext = tostring(new)
				if textupdateconnection then -- we r typing
					newtext = newtext .. "|"
				else
					new = clamp(new, minimum, maximum)
				end
				newtext = tostring(new)
				if customtext[newtext] then
					this.valuetitle.text = customtext[newtext]
				else
					this.valuetitle.text = newtext .. suffix
				end
				for i, v in next, this.slider do
					v.position = newudim2((((clamp(new, minimum, maximum) - minimum)) / (maximum - minimum)), 0, 0, i - 1) -- s3x
					local tostart = v.absoluteposition.x - this.sliderback.absoluteposition.x
					local scalederrr = -tostart / this.sliderback.absolutesize.x
					v.size = newudim2(scalederrr, 0, 0, 1)
				end
				this.valuetitle.position = this.slider[#this.slider].position + newudim2(0, -((#this.valuetitle.text * 7)/2), 0, 0)
				myflag.value = new
				myflag.changed:Fire()
			end

			function myflag:setMax(new)
				maximum = new
			end

			function myflag:setMin(new)
				minimum = new
			end

			local connection
			this.hitbox.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				connection = runservice.Stepped:Connect(function()
					local relative = utilities.mouse.position.x
					local mousebound = utilities.mouse.position.x - this.hitbox.absoluteposition.x - 1
					mousebound = clamp(mousebound, 0, this.hitbox.absolutesize.x)
					local result = mousebound
					result = clamp(result, 0, this.hitbox.absolutesize.x)
					result = floor(0.5 + (((maximum - minimum) / this.hitbox.absolutesize.x) * mousebound) + minimum)
					myflag:setvalue(result)
					if this.hitbox.holding == false or menu.uiopen == false then
						connection:Disconnect()
						connection = nil
						return
					end
				end)
			end)

			this.addtext.mouseenter:Connect(function()
				this.addtext.color = menu.accent
			end)

			this.addtext.mouseleave:Connect(function()
				this.addtext.color = Color3.fromRGB(255, 255, 255)
			end)

			this.subtext.mouseenter:Connect(function()
				this.subtext.color = menu.accent
			end)

			this.subtext.mouseleave:Connect(function()
				this.subtext.color = Color3.fromRGB(255, 255, 255)
			end)

			this.addtext.clicked:Connect(function()
				myflag:setvalue(myflag.value + 1)
			end)

			this.subtext.clicked:Connect(function()
				myflag:setvalue(myflag.value - 1)
			end)

			myflag:setvalue(parameters.value)

			if tooltip then
				this.hitbox.mouseenter:Connect(function()
					menu:calltooltip(tooltip, this.hitbox, newvec2(-4, 2))
				end)
			end

			this.bounds = newvec2(0, 36 + boundoffset)
			menu.elements[tab][subsection][name] = this
			menu.elements[tab][subsection].updateScrollBarLength()
		end

		function menu:createdropdown(parameters)
			local tab = parameters.tab
			local subsection = parameters.subsection
			local targetsection = menu.directory[tab][subsection]
			local name = parameters.name
			local flag = parameters.flag
			local tooltip = parameters.tooltip
			local multichoice = parameters.multichoice

			local this = {}
			this.dropdownopened = false
			this.valuecontainer = {}
			local offset = baseoffset + 0
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag -- mypenis
			myflag.__index = menu.flags[flag]
			myflag.type = "dropdown"
			myflag.value = {}
			myflag.name = name
			myflag.changed = utilities.signal.new()

			for i, v in next, (menu.elements[tab][subsection]) do
				if type(v) == "table" then
					offset = offset + v.bounds.y
				end
			end

			for i, v in next, (parameters.values) do
				local name = v[1]
				local state = v[2]
				myflag.value[name] = state
			end

			this.holder = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetsection,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, 0, 0, 24),
				position = newudim2(0.5, 0, 0, offset),
				zindex = menu.basezindex + 6,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				thickness = 0,
				filled = true,
				transparency = 0,
				name = "okay",
			})

			this.title = drawingFunction("text", {
				parent = this.holder,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 16, 0, 8),
				zindex = menu.basezindex + 7,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title
			this.selection = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.holder,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, -30, 0, 16),
				position = newudim2(0.5, 0, 0, 24),
				zindex = menu.basezindex + 7,
				color = menucolors.c,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.selection
			this.selectiontext = drawingFunction("text", {
				parent = this.selection,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 2, 0.5, -7),
				zindex = menu.basezindex + 8,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "",
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.selectiontext
			this.icon = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.selection,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 7,
				color = menucolors.c,
				visible = true,
				thickness = 0,
				filled = true,
				transparency = 0,
				activated = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.icon
			menu.activations[1 + #menu.activations] = this.icon

			this.icontext = drawingFunction("text", {
				parent = this.icon,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(1, -10, 0.5, -7),
				zindex = menu.basezindex + 8,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "+",
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.icontext
			this.selectionoutline = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.selection,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 6,
				color = menucolors.d,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.selectionoutline

			this.scrollerBar = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.selection,
				anchorpoint = newvec2(0, 0),
				size = newudim2(0, 3, 8 / #parameters.values, 0),
				position = newudim2(1, -3, 0, 20),
				zindex = menu.basezindex + 18,
				color = menu.accent,
				visible = false,
				filled = true,
				name = "okay",
			})
			menu.accents[1 + #menu.accents] = this.scrollerBar

			function myflag:setvalue(new)
				myflag.value = new
				local maximumchars = floor(this.selection.absolutesize.x / 6.5) - 4 - 2 -- suck
				local selected = ""
				local selections = 0
				for i, v in next, (myflag.value) do
					if v then
						if selections > 0 then
							selected = selected .. ", "
						end
						selected = selected .. i
						selections = selections + 1
					end
				end
				for i, v in next, this.valuecontainer do
					v.selectiontext.color = myflag.value[v.selectiontext.text] and menu.accent or Color3.new(1, 1, 1)
				end

				local needsdotdotdot = false
				if string.len(selected) > maximumchars then
					needsdotdotdot = true
				end
				selected = string.sub(selected, 0, maximumchars) .. (needsdotdotdot and "..." or "" )
				if selections == 0 then
					this.selectiontext.text = "none"
				else
					this.selectiontext.text = selected
				end 
				myflag.changed:Fire()
			end

			this.selection.getpropertychangedsignal:Connect(function(prop, val)
				if prop == "absolutesize" then
					myflag:setvalue(myflag.value)
				end
			end)
			
			local numCreated = 0
			for val, v in next, (parameters.values) do
				if numCreated >= 8 then
					break
				end
				local temporary = {}
				local val = v[1] -- so that its in order
				temporary.value = val
				temporary.selectionoutline = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = this.selection,
					anchorpoint = newvec2(0.5, 0),
					size = newudim2(1, 2, 0, 22),
					position = newudim2(0.5, 0, 0, ((1 + #this.valuecontainer) * 20) -2),
					zindex = menu.basezindex + 14,
					color = menucolors.d,
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				temporary.selection = drawingFunction("frame", { -- for getting the bounds of the thing
					parent = temporary.selectionoutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 15,
					color = menucolors.c,
					visible = true,
					thickness = 0,
					filled = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = temporary.selection
				temporary.selectiontext = drawingFunction("text", {
					parent = temporary.selection,
					anchorpoint = newvec2(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 2, 0.5, 0),
					zindex = menu.basezindex + 16,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = val,
					name = "okay",
				})
				temporary.selection.clicked:Connect(function()
					local thisVal = temporary.selectiontext.text
					if parameters.multichoice == false then
						for i, v in next, (myflag.value) do
							myflag.value[i] = (thisVal == i) -- suck my nutz
						end
					else
						if not myflag.value then
							myflag.value[thisVal] = false
						end
						myflag.value[thisVal] = not myflag.value[thisVal] -- suck my nutz
					end
					myflag:setvalue(myflag.value)
				end)
				this.valuecontainer[1 + #this.valuecontainer] = temporary
				numCreated = numCreated + 1
			end
			local currentScrollLevel = 0
			if #parameters.values > 8 then
				local scrollUpConnection
				local scrollDownConnection
				local function updateScroll()
					this.scrollerBar.size = newudim2(0, 3, 8 / #parameters.values, 0)
					local currentY = math.floor(currentScrollLevel / #parameters.values * 170)
					currentY = math.clamp(currentY, 1, (170) - this.scrollerBar.absolutesize.y - 1)
					this.scrollerBar.position = newudim2(1, -3, 0, currentY + 20)

					for i = 1, 8 do
						local pointStartVis = currentScrollLevel + i
						local ref = this.valuecontainer[i]
						local flagRef = parameters.values[pointStartVis]
						
						ref.selectiontext.text = flagRef[1]
						ref.selectiontext.color = myflag.value[flagRef[1]] and menu.accent or Color3.new(1, 1, 1)
					end
				end

				scrollUpConnection = utilities.mouse.scrollup:Connect(function(d)
					if (menu.isadropdownopen and this.dropdownopened == false) or menu.isacolorpickeropen or menu.uiopen == false then return end
					currentScrollLevel = math.clamp(currentScrollLevel - d, 0, #parameters.values - 8)
					updateScroll()
				end)
				scrollDownConnection = utilities.mouse.scrolldown:Connect(function(d)
					if (menu.isadropdownopen and this.dropdownopened == false) or menu.isacolorpickeropen or menu.uiopen == false then return end
					currentScrollLevel = math.clamp(currentScrollLevel - d, 0, #parameters.values - 8)
					updateScroll()
				end)
			end

			this.icon.clicked:Connect(function()
				if (menu.isadropdownopen and this.dropdownopened == false) or menu.isacolorpickeropen or menu.uiopen == false then return end
				this.dropdownopened = not this.dropdownopened
				this.icontext.text = (this.dropdownopened == true) and "-" or "+"
				menu.isadropdownopen = this.dropdownopened

				for i, v in next, (this.valuecontainer) do
					v.selectionoutline.visible = this.dropdownopened
					v.selectionoutline.position = v.selectionoutline.position
					v.selectionoutline.size = v.selectionoutline.size
				end
				for i = 1, 8 do
					local pointStartVis = currentScrollLevel + i
					local ref = this.valuecontainer[i]
					local flagRef = parameters.values[pointStartVis]
					
					ref.selectiontext.text = flagRef[1]
					ref.selectiontext.color = myflag.value[flagRef[1]] and menu.accent or Color3.new(1, 1, 1)
				end
				if #parameters.values > 8 then
					this.scrollerBar.visible = this.dropdownopened
				end
			end)

			if tooltip then
				this.icon.mouseenter:Connect(function()
					if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen or menu.uiopen == false then return end
					menu:calltooltip(tooltip, this.icon, newvec2(-4, 2))
				end)
			end

			local vals = {}
			for i, v in next, (parameters.values) do
				local name = v[1]
				local state = v[2]
				vals[name] = state
			end

			myflag:setvalue(vals)

			this.bounds = newvec2(0, 38 + boundoffset)
			menu.elements[tab][subsection][name] = this
			menu.elements[tab][subsection].updateScrollBarLength()
		end

		function menu:createbutton(parameters)
			local tab = parameters.tab
			local subsection = parameters.subsection
			local targetsection = menu.directory[tab][subsection]
			local confirmation = parameters.confirmation ~= nil and parameters.confirmation or nil
			local name = parameters.name
			local flag = parameters.flag
			local this = {}
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag -- mypenis
			myflag.__index = menu.flags[flag]
			myflag.type = "button"
			myflag.name = name
			myflag.pressed = utilities.signal.new()

			local offset = baseoffset + 10

			for i, v in next, (menu.elements[tab][subsection]) do
				if type(v) == "table" then
					offset = offset + v.bounds.y
				end
			end

			this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetsection,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, -28, 0, 20),
				position = newudim2(0.5, 0, 0, offset),
				zindex = menu.basezindex + 7,
				color = menucolors.d,
				visible = true,
				thickness = 1,
				filled = false,
				activated = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.hitbox
			menu.activations[1 + #menu.activations] = this.hitbox
			this.container = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.hitbox,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, -2, 1, -2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 8,
				color = menucolors.c,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.container

			this.title = drawingFunction("text", {
				parent = this.container,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0.5, -((#name * 7)/2), 0.5, -7),
				zindex = menu.basezindex + 9,
				color = parameters.detected and Color3.fromRGB(255, 106, 79) or Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title

			local lastactivation
			local connection
			this.hitbox.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end
				if confirmation then
					if this.title.text ~= "confirm?" then
						this.title.text = "confirm?"
						this.title.position = newudim2(0.5, -((#this.title.text * 7)/2), 0.5, -7)
						this.title.color = menu.accent
						lastactivation = tick()
						connection = runservice.Stepped:Connect(function()
							if tick() - lastactivation > 2 then
								this.title.text = name
								this.title.color = Color3.new(1, 1, 1)
								lastactivation = tick()
								connection:Disconnect()
								connection = nil
							end
						end)
					else
						myflag.pressed:Fire()
						this.title.text = name
						this.title.color = Color3.new(1, 1, 1)
						lastactivation = tick()
						connection:Disconnect()
						connection = nil
						lastactivation = tick()
					end
				else
					myflag.pressed:Fire()
				end
				this.container.color = menucolors.a
				task.wait(0.05)
				this.container.color = menucolors.c
			end)

			this.bounds = newvec2(0, 24 + boundoffset)
			menu.elements[tab][subsection][name] = this -- keep a record of this fuck
			menu.elements[tab][subsection].updateScrollBarLength()
		end

		function menu:createtextbox(parameters)
			local tab = parameters.tab
			local subsection = parameters.subsection
			local targetsection = menu.directory[tab][subsection]
			local name = parameters.text
			local flag = parameters.flag
			local this = {}
			menu.flags[flag] = {}
			local myflag = menu.flags[flag]
			this.myflag = myflag -- mypenis
			myflag.__index = menu.flags[flag]
			myflag.type = "textbox"
			myflag.value = name
			myflag.name = name
			myflag.changed = utilities.signal.new()

			local offset = baseoffset + 10

			for i, v in next, (menu.elements[tab][subsection]) do
				if type(v) == "table" then
					offset = offset + v.bounds.y
				end
			end
			this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = targetsection,
				anchorpoint = newvec2(0.5, 0),
				size = newudim2(1, -28, 0, 20),
				position = newudim2(0.5, 0, 0, offset),
				zindex = menu.basezindex + 7,
				color = menucolors.d,
				visible = true,
				thickness = 0,
				filled = true,
				activated = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.hitbox
			menu.activations[1 + #menu.activations] = this.hitbox
			this.container = drawingFunction("frame", { -- for getting the bounds of the thing
				parent = this.hitbox,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, -2, 1, -2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 8,
				color = menucolors.b,
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.container
			this.title = drawingFunction("text", {
				parent = this.container,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 4, 0.5, -7),
				zindex = menu.basezindex + 9,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = menucolors.d,
				text = name,
				name = "okay",
			})
			menu.openclose[1 + #menu.openclose] = this.title
			local textupdateconnection

			function myflag:setvalue(new)
				myflag.value = new
				this.title.text = myflag.value
				if textupdateconnection then -- currently typing...
					this.title.color = menu.accent
					this.title.text = this.title.text .. "|"
				end
				myflag.changed:Fire()
			end

			this.hitbox.clicked:Connect(function()
				if menu.uiopen == false or menu.isadropdownopen or menu.isacolorpickeropen then return end

				if textupdateconnection then
					textupdateconnection:Disconnect()
					textupdateconnection = nil
					this.title.text = this.title.text:gsub("|", "")
					this.title.color = Color3.new(1, 1, 1)
				end

				this.title.color = menu.accent
				this.title.text = this.title.text .. "|"
				textupdateconnection = userinputservice.InputBegan:Connect(function(Input, gameProcessed)
					if Input.UserInputType == Enum.UserInputType.Keyboard then
						if Input.KeyCode.Value == 27 or Input.KeyCode.Value == 13 then -- escape or enter pressed -> close the thing
							textupdateconnection:Disconnect()
							textupdateconnection = nil
							this.title.text = this.title.text:gsub("|", "")
							this.title.color = Color3.new(1, 1, 1)
						elseif Input.KeyCode.Value == 8 then -- backspace -> subtract the text by 1
							if userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) or userinputservice:IsKeyDown(Enum.KeyCode.RightControl) then
								myflag:setvalue("")
							else
								myflag:setvalue(myflag.value:sub(0, -2)) -- remove the last char
							end
						elseif Input.KeyCode.Value == 32 then -- spacebar
							myflag:setvalue(myflag.value .. " ") -- remove the last char
						elseif Input.KeyCode.Value == 118 and (userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) or userinputservice:IsKeyDown(Enum.KeyCode.RightControl)) then -- the v key
							this.title.text = this.title.text:gsub("|", "")
							this.title.color = Color3.new(1, 1, 1)
							textupdateconnection:Disconnect()
							textupdateconnection = nil
							myflag:setvalue(utilities.getclipboard())
						else
							local key = tostring(Input.KeyCode):sub(14)
							if table.find(menu.validkeys, key) or menu.validnumberkeys[key] then
								if menu.validnumberkeys[key] then
									key = menu.validnumberkeys[key]
								end
								if userinputservice:IsKeyDown(Enum.KeyCode.LeftShift) or userinputservice:IsKeyDown(Enum.KeyCode.RightShift) then
									key = string.upper(key)
								else
									key = string.lower(key)
								end
								myflag:setvalue(myflag.value .. key)
							end
						end
					end
				end)
			end)

			this.bounds = newvec2(0, 24 + boundoffset)
			menu.elements[tab][subsection][name] = this -- keep a record of this fuck
			menu.elements[tab][subsection].updateScrollBarLength()
		end

		local baseOffsetX = 16
		local baseOffsetY = 16

		menu.currentnotifications = {}
		menu.notificationmanagement = runservice.RenderStepped:Connect(function(dt)
			local sorted = {}
			local prioritiesgroups = {}

			-- sort the fucker

			table.sort(menu.currentnotifications, function(a, b) return a.priority > b.priority end)

			for i, v in next, menu.currentnotifications do
				if v.ignoreanimations then
				else
					if not prioritiesgroups[v.priority] then
						prioritiesgroups[v.priority] = {}
					end
					local thisGroup = prioritiesgroups[v.priority]
					thisGroup[1 + #thisGroup] = v
				end
			end

			for priority, notifs in next, prioritiesgroups do
				table.sort(notifs, function(a, b) return a.created < b.created end)
			end

			for priority, notifs in next, prioritiesgroups do
				for lifepriority, notif in next, notifs do
					sorted[1 + #sorted] = notif
				end
			end

			-- this positions it accordingly
			local currentLevel = 0
			for i = 1, #sorted do
				local notification = sorted[i]

				if notification.alivetime > notification.lifetime then -- manage removing the notif once its lifetime has expired
					notification.container.visible = false

					notification.container.drawingobject:Remove()
					notification.outline1.drawingobject:Remove()
					notification.outline2.drawingobject:Remove()

					notification.container.drawingobject = nil
					notification.outline1.drawingobject = nil
					notification.outline2.drawingobject = nil

					table.clear(notification.container)
					table.clear(notification.outline1)
					table.clear(notification.outline2)

					notification.container.drawingobject = {}
					notification.outline1.drawingobject = {}
					notification.outline2.drawingobject = {}

					for k, n in next, menu.currentnotifications do
						if notification == n then
							table.clear(notification)
							table.remove(menu.currentnotifications, k)
						end
					end
				else
					notification.container.visible = true
					-- manage x position
					if notification.alivetime < 1 then -- manage x position coming out of the closet
						local percentageMoved = notification.alivetime / 1
						local projectedMovePercentage = (1 / (-2.71828 ^ (percentageMoved * 8))) + 1
						notification.container.position = newudim2(0, -240 + (projectedMovePercentage * 240) + baseOffsetX, 0, 0)
					elseif notification.alivetime > notification.lifetime - 0.5 then  -- manage x position going back into the closet
						local percentageMoved = 2 * (notification.alivetime - (notification.lifetime - 0.5))
						local projectedMovePercentage = (1 / (-2.71828 ^ (percentageMoved * 1))) + 1
						notification.container.position = newudim2(0, baseOffsetX - (projectedMovePercentage * 120), 0, 0)
					else
						notification.container.position = newudim2(0, baseOffsetX, 0, 0)
					end

					-- manage y position
					notification.container.position = notification.container.position + newudim2(0, 0, 0, baseOffsetY + currentLevel)
					currentLevel = currentLevel + 8 + notification.container.absolutesize.y

					-- manage fade
					if notification.alivetime < 1 then -- manage fade coming out of the closet
						local fade = notification.alivetime / 1

						notification.container.transparency = fade
						notification.outline1.transparency = fade
						notification.outline2.transparency = fade
						notification.title.transparency = fade

					elseif notification.alivetime > notification.lifetime - 0.5 then -- manage fade going back into the closet
						local fade = 1 - (2 * (notification.alivetime - (notification.lifetime - 0.5)))

						notification.container.transparency = fade
						notification.outline1.transparency = fade
						notification.outline2.transparency = fade
						notification.title.transparency = fade
					else
						notification.container.transparency = 1
						notification.outline1.transparency = 1
						notification.outline2.transparency = 1
						notification.title.transparency = 1
					end

					notification.alivetime = notification.alivetime + dt
				end
			end
		end)

		function menu:createnotification(param)
			local this = {}
			this.container = drawingFunction("frame", {
				parent = utilities.base,
				anchorpoint = newvec2(0, 0),
				size = newudim2(0, 100, 0, 100),
				position = newudim2(32, 0, 32, 0),
				zindex = menu.basezindex + -4,
				color = parameters.colors.a,
				visible = false,
				thickness = 1,
				transparency = 1,
				filled = true,
				name = "okay",
			})
			this.outline1 = drawingFunction("frame", {
				parent = this.container,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 5,
				color = parameters.colors.c,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			this.outline2 = drawingFunction("frame", {
				parent = this.containeroutline,
				anchorpoint = newvec2(0.5, 0.5),
				size = newudim2(1, 2, 1, 2),
				position = newudim2(0.5, 0, 0.5, 0),
				zindex = menu.basezindex + 4,
				color = parameters.colors.a,
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			this.title = drawingFunction("text", {
				parent = this.container,
				anchorpoint = newvec2(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = newudim2(0, 8, 0, 4),
				zindex = menu.basezindex + 20,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "example notif",
				name = "okay",
			})

			-- text editing stuffs (copied from tooltip)
			local maxWidth = 36
			local text = param.text
			do -- WARNING !! ALAN CODE AHEAD!!
				local split = text:split("")
				local lastspaceidx = 0 -- the text idx that the last space is
				local charinline = 0
				for i, v in next, (split) do
					charinline = charinline + 1
					if v == " " then
						lastspaceidx = i
					end
					if charinline >= maxWidth then
						split[lastspaceidx] = "\n" -- insert a thing
						charinline = 0
					end
				end
				text = ""
				for i, v in next, (split) do
					text = text .. v
				end
			end
			local split = text:split("\n")
			local textlinelength = {}
			local yLeng = 0
			for i, v in next, (split) do
				local textBound = Vector2.new()
				do -- FATAL !
					local getTextBoundsOfBullshit = Drawing.new("Text")
					getTextBoundsOfBullshit.Visible = true
					getTextBoundsOfBullshit.Font = Drawing.Fonts.Plex
					getTextBoundsOfBullshit.Size = 13
					getTextBoundsOfBullshit.Text = v
					textBound = getTextBoundsOfBullshit.TextBounds
					getTextBoundsOfBullshit.Visible = false
					getTextBoundsOfBullshit:Remove()
					getTextBoundsOfBullshit = nil
				end

				textlinelength[i] = textBound.x -- getting the number of characters each line and getting the biggest one to properly size the thing
				yLeng = yLeng + textBound.y
			end
			table.sort(textlinelength, function(a, b) return a > b end)
			local longestthing = textlinelength[1]

			this.container.size = newudim2(0, longestthing + 16, 0, yLeng + 8)
			this.title.text = text
			this.alivetime = 0
			this.lifetime = param.lifetime
			this.priority = param.priority
			this.ignoreanimations = param.ignoreanimations
			this.created = tick()

			menu.currentnotifications[1 + #menu.currentnotifications] = this

			return this
		end

		local colorPickerType = 2
		do
			do
				local copyPasteMenu = {}
				copyPasteMenu.outline = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 42, 0, 32),
					position = newudim2(0, 100, 0, 100),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				copyPasteMenu.container = drawingFunction("frame", {
					parent = copyPasteMenu.outline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				copyPasteMenu.copyTitle = drawingFunction("text", {
					parent = copyPasteMenu.container,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 2, 0, 0),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "copy",
					name = "okay",
				})

				copyPasteMenu.pasteTitle = drawingFunction("text", {
					parent = copyPasteMenu.container,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 2, 0, copyPasteMenu.copyTitle.absolutesize.y + 2),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "paste",
					name = "okay",
				})

				copyPasteMenu.copyDetection = drawingFunction("frame", {
					parent = copyPasteMenu.container,
					anchorpoint = newvec2(0, 0),
					size = newudim2(1, 0, 0.5, 0),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					activated = true,
					transparency = 0,
					filled = true,
					name = "okay",
				})

				copyPasteMenu.pasteDetection = drawingFunction("frame", {
					parent = copyPasteMenu.container,
					anchorpoint = newvec2(0, 0),
					size = newudim2(1, 0, 0.5, 0),
					position = newudim2(0, 0, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					activated = true,
					transparency = 0,
					filled = true,
					name = "okay",
				})

				copyPasteMenu.copyDetection.clicked:Connect(function()
					if copyPasteMenu.focusedon then
						local v = copyPasteMenu.focusedon
						local val = {v.color.r, v.color.g, v.color.b, v.transparency}
						local keyFrameFix = {}
						for n, kfs in next, v.animationKeyFrames do
							keyFrameFix[n] = {}
							for idx, d in next, kfs do
								keyFrameFix[n][idx] =  {d.color.r, d.color.g, d.color.b, d.transparency}
							end
						end
						local animations = {
							animation = v.animation,
							animationKeyFrames = keyFrameFix,
							speeds = v.animationSpeed
						}
						local comp = {val, animations}
						local result = json.encode(comp)
						colorpickerClipBoard = result
					end
					copyPasteMenu.outline.visible = false
					if copyPasteMenu.outofboundscloseconnection then
						copyPasteMenu.outofboundscloseconnection:Disconnect()
						copyPasteMenu.outofboundscloseconnection = nil
					end
					menu.isacolorpickeropen = false
				end)
				copyPasteMenu.pasteDetection.clicked:Connect(function()
					local clipboard = colorpickerClipBoard
					if copyPasteMenu.focusedon and colorpickerClipBoard then
						local ff = copyPasteMenu.focusedon
						local value = json.decode(clipboard)
						ff:setcolor(Color3.new(value[1][1], value[1][2], value[1][3]))

						if value[1][4] then
							ff:settransparency(value[1][4])
						end
						local keyFrameFix = {}
						for n, kfs in next, value[2].animationKeyFrames do
							keyFrameFix[n] = {}
							for idx, d in next, kfs do
								keyFrameFix[n][idx] = {
									color = Color3.new(d[1], d[2], d[3]),
									transparency = d[4],
								}
							end
						end
						ff:setAnimation(value[2].animation)
						ff:setAnimationSpeed(value[2].speeds)
						ff:setAnimationKeyFrames(keyFrameFix)
					end
					copyPasteMenu.outline.visible = false
					if copyPasteMenu.outofboundscloseconnection then
						copyPasteMenu.outofboundscloseconnection:Disconnect()
						copyPasteMenu.outofboundscloseconnection = nil
					end
					menu.isacolorpickeropen = false
				end)

				function menu:callcolorcopypaste(flag, position)
					if not flag then return end

					copyPasteMenu.outline.visible = true
					copyPasteMenu.outline.position = newudim2(0, position.x - 1, 0, position.y - 1)
					copyPasteMenu.outline.position = newudim2(0, position.x, 0, position.y)

					copyPasteMenu.focusedon = flag

					menu.isacolorpickeropen = true

					copyPasteMenu.outofboundscloseconnection = utilities.mouse.mousebutton1down:Connect(function()
						if utilities.mousechecks.inbounds(copyPasteMenu.outline, utilities.mouse.position) == false then -- uh oh..

							copyPasteMenu.outline.visible = false
							menu.isacolorpickeropen = false

							if copyPasteMenu.outofboundscloseconnection then
								copyPasteMenu.outofboundscloseconnection:Disconnect()
								copyPasteMenu.outofboundscloseconnection = nil
							end
						end
					end)
				end
			end
			if colorPickerType == 1 then
				menu.colorpicker = {} -- would rather make 1 that moves around instead of do this for EVERY color picker, probably shouldve done this with dropdowns and what not but i got lazy

				menu.colorpicker.outline = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 194, 0, 208),
					position = newudim2(0, 100, 0, 100),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.container = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.title = drawingFunction("text", {
					parent = menu.colorpicker.container,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 4, 0, 2),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "Color Picker",
					name = "okay",
				})

				menu.colorpicker.pickeroutline = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 172, 0, 172),
					position = newudim2(0, 4, 0, 18),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.pickercontainer = drawingFunction("frame", {
					parent = menu.colorpicker.pickeroutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.new(1, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.picker = drawingFunction("frame", {
					parent = menu.colorpicker.pickercontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					color = Color3.new(1, 1, 1),
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.picker

				do
					local parentedTo = menu.colorpicker.picker
					local smoothGradient = {}
					local xRes = 6
					local yRes = 6
					for xDim = 1, parentedTo.absolutesize.x / xRes do
						smoothGradient[xDim] = {}
						for yDim = 1, parentedTo.absolutesize.y / yRes do
							smoothGradient[xDim][yDim] = utilities:draw("frame", {
								parent = parentedTo,
								anchorpoint = newvec2(0, 0),
								size = newudim2(0, xRes, 0, yRes),
								position = newudim2(0, (xDim - 1) * xRes, 0, (yDim - 1) * yRes),
								zindex = parentedTo.zindex + 1,
								color = Color3.fromHSV(0, 0, 1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y),
								transparency = 1 - ((xDim - 1) * xRes) / parentedTo.absolutesize.x,
								visible = true,
								name = "okay",
							})
						end
					end
				end

				menu.colorpicker.pickerselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 1, 0, 1),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.pickerselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.pickerselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hueoutline = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 12, 0, 172),
					position = newudim2(0, 178, 0, 18),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.huecontainer = drawingFunction("frame", {
					parent = menu.colorpicker.hueoutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hue = drawingFunction("frame", {
					parent = menu.colorpicker.huecontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.hue

				do
					local parentedTo = colorReference.hue
					local smoothGradient = {}
					local yRes = 6
					for yDim = 1, parentedTo.absolutesize.y / yRes do
						smoothGradient[yDim] = utilities:draw("frame", {
							parent = parentedTo,
							anchorpoint = newvec2(0, 0),
							size = newudim2(1, 0, 0, yRes),
							position = newudim2(0, 0, 0, (yDim - 1) * yRes),
							zindex = parentedTo.zindex + 1,
							color = Color3.fromHSV(1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y, 1, 1),
							visible = true,
							name = "okay",
						})
					end
				end

				menu.colorpicker.hueselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 14, 0, 2),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hueselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.hueselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencyoutline = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 172, 0, 12),
					position = newudim2(0, 4, 0, 192),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencycontainer = drawingFunction("frame", {
					parent = menu.colorpicker.transparencyoutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.new(1, 1, 1),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencypicker = drawingFunction("frame", {
					parent = menu.colorpicker.transparencycontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.transparencypicker

				do
					local parentedTo = menu.colorpicker.transparencypicker
					local smoothGradient = {}
					local xRes = 6
					for xDim = 1, parentedTo.absolutesize.x / xRes do
						smoothGradient[xDim] = utilities:draw("frame", {
							parent = parentedTo,
							anchorpoint = newvec2(0, 0),
							size = newudim2(0, xRes, 1, 0),
							position = newudim2(0, (xDim - 1) * xRes, 0, 0),
							zindex = parentedTo.zindex + 1,
							color = Color3.fromHSV(0, 0, ((xDim - 1) * xRes) / parentedTo.absolutesize.x),
							visible = true,
							name = "okay",
						})                      
					end
				end

				menu.colorpicker.transparencyselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 2, 0, 14),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencyselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.transparencyselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.outline.visible = false

				menu.colorpicker.focusedon = nil

				-- how 2 pick color
				menu.colorpicker.picker.clicked:Connect(function()
					local oldhue = abs(1 - (clamp(menu.colorpicker.hueselection.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y) - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.picker.absoluteposition.x, menu.colorpicker.picker.absoluteposition.x + menu.colorpicker.picker.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.picker.absoluteposition.y, menu.colorpicker.picker.absoluteposition.y + menu.colorpicker.picker.absolutesize.y)
					menu.colorpicker.pickerselection.position = newudim2(0, xpos, 0, ypos)
					-- quick maths

					local sat = clamp((xpos - menu.colorpicker.picker.absoluteposition.x) / menu.colorpicker.picker.absolutesize.x, 0, 1)
					local val = clamp(abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y), 0, 1)

					menu.colorpicker.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.picker.absoluteposition.x, menu.colorpicker.picker.absoluteposition.x + menu.colorpicker.picker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.picker.absoluteposition.y, menu.colorpicker.picker.absoluteposition.y + menu.colorpicker.picker.absolutesize.y)
						menu.colorpicker.pickerselection.position = newudim2(0, xpos, 0, ypos)
						-- quick maths

						local sat = clamp((xpos - menu.colorpicker.picker.absoluteposition.x) / menu.colorpicker.picker.absolutesize.x, 0, 1)
						local val = clamp(abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y), 0, 1)

						menu.colorpicker.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))
					end)
				end)

				menu.colorpicker.hue.clicked:Connect(function()
					local old = menu.colorpicker.focusedon.color
					local oldhue, oldsat, oldval = Color3.toHSV(old)

					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.hue.absoluteposition.x, menu.colorpicker.hue.absoluteposition.x + menu.colorpicker.hue.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y)
					menu.colorpicker.hueselection.position = newudim2(0, menu.colorpicker.hue.absoluteposition.x - 2, 0, ypos)

					local hue = abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

					menu.colorpicker.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
					menu.colorpicker.pickercontainer.color = Color3.fromHSV(hue, 1, 1)

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.hue.absoluteposition.x, menu.colorpicker.hue.absoluteposition.x + menu.colorpicker.hue.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y)
						menu.colorpicker.hueselection.position = newudim2(0, menu.colorpicker.hue.absoluteposition.x - 2, 0, ypos)

						local hue = abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

						menu.colorpicker.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
						menu.colorpicker.pickercontainer.color = Color3.fromHSV(hue, 1, 1)
					end)
				end)

				menu.colorpicker.transparencypicker.clicked:Connect(function()
					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.transparencypicker.absoluteposition.x, menu.colorpicker.transparencypicker.absoluteposition.x + menu.colorpicker.transparencypicker.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.transparencypicker.absoluteposition.y, menu.colorpicker.transparencypicker.absoluteposition.y + menu.colorpicker.transparencypicker.absolutesize.y)
					menu.colorpicker.transparencyselection.position = newudim2(0, xpos, 0, menu.colorpicker.transparencypicker.absoluteposition.y - 1)

					local transparency = (xpos - menu.colorpicker.transparencypicker.absoluteposition.x) / menu.colorpicker.transparencypicker.absolutesize.x
					menu.colorpicker.focusedon:settransparency(transparency)

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.transparencypicker.absoluteposition.x, menu.colorpicker.transparencypicker.absoluteposition.x + menu.colorpicker.transparencypicker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.transparencypicker.absoluteposition.y, menu.colorpicker.transparencypicker.absoluteposition.y + menu.colorpicker.transparencypicker.absolutesize.y)
						menu.colorpicker.transparencyselection.position = newudim2(0, xpos, 0, menu.colorpicker.transparencypicker.absoluteposition.y - 1)

						local transparency = (xpos - menu.colorpicker.transparencypicker.absoluteposition.x) / menu.colorpicker.transparencypicker.absolutesize.x
						menu.colorpicker.focusedon:settransparency(transparency)
					end)
				end)

				utilities.mouse.mousebutton1up:Connect(function()
					if menu.colorpicker.updater then 
						menu.colorpicker.updater:Disconnect()
					end
				end)

				function menu:callcolorpicker(name, flag, position, transparency)
					if not flag then return end
					local old = flag.color
					local oldhue, oldsat, oldval = Color3.toHSV(old)

					menu.colorpicker.outline.visible = true
					menu.isacolorpickeropen = true
					menu.colorpicker.outline.position = newudim2(0, position.x, 0, position.y)
					menu.colorpicker.title.text = name
					menu.colorpicker.pickercontainer.color = Color3.fromHSV(oldhue, 1, 1)

					if transparency then
						menu.colorpicker.outline.size = newudim2(0, 194, 0, 208)
					else
						menu.colorpicker.outline.size = newudim2(0, 194, 0, 196)
					end

					menu.colorpicker.hueselection.visible = true
					menu.colorpicker.pickerselection.visible = true

					menu.colorpicker.transparencyoutline.visible = transparency ~= nil and true or false
					menu.colorpicker.transparencyselection.visible = transparency ~= nil and true or false

					menu.colorpicker.hueselection.position = newudim2(0, -2, 0, abs(1 - oldhue) * menu.colorpicker.hue.absolutesize.y) + newudim2(0, menu.colorpicker.hue.absoluteposition.x, 0, menu.colorpicker.hue.absoluteposition.y)
					menu.colorpicker.pickerselection.position = newudim2(0, oldsat * menu.colorpicker.picker.absolutesize.x, 0, abs(oldval - 1) * menu.colorpicker.picker.absolutesize.y) + newudim2(0, menu.colorpicker.picker.absoluteposition.x, 0, menu.colorpicker.picker.absoluteposition.y)

					menu.colorpicker.transparencypicker.position = menu.colorpicker.transparencypicker.position
					menu.colorpicker.transparencycontainer.position = menu.colorpicker.transparencycontainer.position

					if transparency then
						menu.colorpicker.transparencyselection.position = newudim2(0, transparency * menu.colorpicker.transparencypicker.absolutesize.x, 0, -1) + newudim2(0, menu.colorpicker.transparencypicker.absoluteposition.x, 0, menu.colorpicker.transparencypicker.absoluteposition.y)
					end

					menu.colorpicker.focusedon = flag

					if transparency then
						menu.colorpicker.transparencyselection.position = newudim2(0, transparency * menu.colorpicker.transparencypicker.absolutesize.x, 0, -1) + newudim2(0, menu.colorpicker.transparencypicker.absoluteposition.x, 0, menu.colorpicker.transparencypicker.absoluteposition.y)
					end
					-- thing
					menu.colorpicker.outofboundscloseconnection = utilities.mouse.mousebutton1down:Connect(function()
						if utilities.mousechecks.inbounds(menu.colorpicker.outline, utilities.mouse.position) == false then -- uh oh..
							if menu.colorpicker.updater then
								menu.colorpicker.updater:Disconnect()
							end

							menu.colorpicker.outline.visible = false
							menu.colorpicker.transparencyselection.visible = false
							menu.colorpicker.hueselection.visible = false
							menu.colorpicker.pickerselection.visible = false
							menu.isacolorpickeropen = false

							if menu.colorpicker.outofboundscloseconnection then
								menu.colorpicker.outofboundscloseconnection:Disconnect()
								menu.colorpicker.outofboundscloseconnection = nil
							end
						end
					end)
				end
			else
				do
					local colorReference = {} -- would rather make 1 that moves around instead of do this for EVERY color picker, probably shouldve done this with dropdowns and what not but i got lazy

					colorReference.outline = drawingFunction("frame", {
						parent = utilities.base,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 194, 0, 208),
						position = newudim2(0, 100, 0, 100),
						zindex = menu.basezindex + 18 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = false,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.container = drawingFunction("frame", {
						parent = colorReference.outline,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, -2, 1, -2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 18 + 13,
						color = Color3.fromRGB(46, 46, 46),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.title = drawingFunction("text", {
						parent = colorReference.container,
						anchorpoint = newvec2(0, 0),
						size = 13, -- x3
						font = Drawing.Fonts.Plex,
						position = newudim2(0, 4, 0, 2),
						zindex = menu.basezindex + 19 + 13,
						color = Color3.fromRGB(255, 255, 255),
						visible = true,
						outline = false,
						outlinecolor = Color3.fromRGB(12, 12, 12),
						text = "Color Picker",
						name = "okay",
					})

					colorReference.pickeroutline = drawingFunction("frame", {
						parent = colorReference.outline,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 172, 0, 172),
						position = newudim2(0, 4, 0, 18),
						zindex = menu.basezindex + 18 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.pickercontainer = drawingFunction("frame", {
						parent = colorReference.pickeroutline,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, -2, 1, -2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 19 + 13,
						color = Color3.new(1, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.picker = drawingFunction("frame", {
						parent = colorReference.pickercontainer,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 0, 1, 0),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 20 + 13,
						transparency = 0,
						color = Color3.new(1, 1, 1),
						visible = true,
						activated = true,
						name = "okay",
					})
					menu.activations[1 + #menu.activations] = colorReference.picker

					do
						local parentedTo = colorReference.picker
						local smoothGradient = {}
						local xRes = 6
						local yRes = 6
						for xDim = 1, parentedTo.absolutesize.x / xRes do
							smoothGradient[xDim] = {}
							for yDim = 1, parentedTo.absolutesize.y / yRes do
								smoothGradient[xDim][yDim] = utilities:draw("frame", {
									parent = parentedTo,
									anchorpoint = newvec2(0, 0),
									size = newudim2(0, xRes, 0, yRes),
									position = newudim2(0, (xDim - 1) * xRes, 0, (yDim - 1) * yRes),
									zindex = parentedTo.zindex + 1,
									color = Color3.fromHSV(0, 0, 1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y),
									transparency = 1 - ((xDim - 1) * xRes) / parentedTo.absolutesize.x,
									visible = true,
									name = "okay",
								})
							end
						end
					end

					colorReference.pickerselection = drawingFunction("frame", {
						parent = utilities.base,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 1, 0, 1),
						position = newudim2(0, 0, 0, 0),
						zindex = menu.basezindex + 22 + 13,
						color = Color3.new(1, 1, 1),
						visible = false,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.pickerselectionoutline = drawingFunction("frame", {
						parent = colorReference.pickerselection,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 2, 1, 2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 21 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.hueoutline = drawingFunction("frame", {
						parent = colorReference.outline,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 12, 0, 172),
						position = newudim2(0, 178, 0, 18),
						zindex = menu.basezindex + 18 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.huecontainer = drawingFunction("frame", {
						parent = colorReference.hueoutline,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, -2, 1, -2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 19 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.hue = drawingFunction("frame", {
						parent = colorReference.huecontainer,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 0, 1, 0),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 20 + 13,
						transparency = 0,
						visible = true,
						activated = true,
						name = "okay",
					})
					menu.activations[1 + #menu.activations] = colorReference.hue

					do
						local parentedTo = colorReference.hue
						local smoothGradient = {}
						local yRes = 6
						for yDim = 1, parentedTo.absolutesize.y / yRes do
							smoothGradient[yDim] = utilities:draw("frame", {
								parent = parentedTo,
								anchorpoint = newvec2(0, 0),
								size = newudim2(1, 0, 0, yRes),
								position = newudim2(0, 0, 0, (yDim - 1) * yRes),
								zindex = parentedTo.zindex + 1,
								color = Color3.fromHSV(1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y, 1, 1),
								visible = true,
								name = "okay",
							})
						end
					end

					colorReference.hueselection = drawingFunction("frame", {
						parent = utilities.base,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 14, 0, 2),
						position = newudim2(0, 0, 0, 0),
						zindex = menu.basezindex + 22 + 13,
						color = Color3.new(1, 1, 1),
						visible = false,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.hueselectionoutline = drawingFunction("frame", {
						parent = colorReference.hueselection,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 2, 1, 2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 21 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.transparencyoutline = drawingFunction("frame", {
						parent = colorReference.outline,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 172, 0, 12),
						position = newudim2(0, 4, 0, 192),
						zindex = menu.basezindex + 18 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.transparencycontainer = drawingFunction("frame", {
						parent = colorReference.transparencyoutline,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 0, 1, 0),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 19 + 13,
						color = Color3.new(1, 1, 1),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.transparencypicker = drawingFunction("frame", {
						parent = colorReference.transparencycontainer,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 0, 1, 0),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 20 + 13,
						transparency = 0,
						visible = true,
						activated = true,
						name = "okay",
					})
					menu.activations[1 + #menu.activations] = colorReference.transparencypicker

					do
						local parentedTo = colorReference.transparencypicker
						local smoothGradient = {}
						local xRes = 6
						for xDim = 1, parentedTo.absolutesize.x / xRes do
							smoothGradient[xDim] = utilities:draw("frame", {
								parent = parentedTo,
								anchorpoint = newvec2(0, 0),
								size = newudim2(0, xRes, 1, 0),
								position = newudim2(0, (xDim - 1) * xRes, 0, 0),
								zindex = parentedTo.zindex + 1,
								color = Color3.fromHSV(0, 0, ((xDim - 1) * xRes) / parentedTo.absolutesize.x),
								visible = true,
								name = "okay",
							})                      
						end
					end

					colorReference.transparencyselection = drawingFunction("frame", {
						parent = utilities.base,
						anchorpoint = newvec2(0, 0),
						size = newudim2(0, 2, 0, 14),
						position = newudim2(0, 0, 0, 0),
						zindex = menu.basezindex + 22 + 13,
						color = Color3.new(1, 1, 1),
						visible = false,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.transparencyselectionoutline = drawingFunction("frame", {
						parent = colorReference.transparencyselection,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 2, 1, 2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 21 + 13,
						color = Color3.fromRGB(0, 0, 0),
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					colorReference.outline.visible = false

					colorReference.focusedon = nil

					-- how 2 pick color
					colorReference.picker.clicked:Connect(function()
						local oldhue = abs(1 - (clamp(colorReference.hueselection.absoluteposition.y, colorReference.hue.absoluteposition.y, colorReference.hue.absoluteposition.y + colorReference.hue.absolutesize.y) - colorReference.picker.absoluteposition.y) / colorReference.picker.absolutesize.y)

						local xpos = clamp(utilities.mouse.position.x, colorReference.picker.absoluteposition.x, colorReference.picker.absoluteposition.x + colorReference.picker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, colorReference.picker.absoluteposition.y, colorReference.picker.absoluteposition.y + colorReference.picker.absolutesize.y)
						colorReference.pickerselection.position = newudim2(0, xpos, 0, ypos)
						-- quick maths

						local sat = clamp((xpos - colorReference.picker.absoluteposition.x) / colorReference.picker.absolutesize.x, 0, 1)
						local val = clamp(abs(1 - (ypos - colorReference.picker.absoluteposition.y) / colorReference.picker.absolutesize.y), 0, 1)

						colorReference.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))                            

						colorReference.updater = utilities.mouse.moved:Connect(function()
							local xpos = clamp(utilities.mouse.position.x, colorReference.picker.absoluteposition.x, colorReference.picker.absoluteposition.x + colorReference.picker.absolutesize.x)
							local ypos = clamp(utilities.mouse.position.y, colorReference.picker.absoluteposition.y, colorReference.picker.absoluteposition.y + colorReference.picker.absolutesize.y)
							colorReference.pickerselection.position = newudim2(0, xpos, 0, ypos)
							-- quick maths

							local sat = clamp((xpos - colorReference.picker.absoluteposition.x) / colorReference.picker.absolutesize.x, 0, 1)
							local val = clamp(abs(1 - (ypos - colorReference.picker.absoluteposition.y) / colorReference.picker.absolutesize.y), 0, 1)

							colorReference.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))
						end)
					end)

					colorReference.hue.clicked:Connect(function()
						local old = colorReference.focusedon.color
						local oldhue, oldsat, oldval = Color3.toHSV(old)

						local xpos = clamp(utilities.mouse.position.x, colorReference.hue.absoluteposition.x, colorReference.hue.absoluteposition.x + colorReference.hue.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, colorReference.hue.absoluteposition.y, colorReference.hue.absoluteposition.y + colorReference.hue.absolutesize.y)
						colorReference.hueselection.position = newudim2(0, colorReference.hue.absoluteposition.x - 2, 0, ypos)

						local hue = abs(1 - (ypos - colorReference.picker.absoluteposition.y) / colorReference.picker.absolutesize.y)

						colorReference.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
						colorReference.pickercontainer.color = Color3.fromHSV(hue, 1, 1)

						colorReference.updater = utilities.mouse.moved:Connect(function()
							local xpos = clamp(utilities.mouse.position.x, colorReference.hue.absoluteposition.x, colorReference.hue.absoluteposition.x + colorReference.hue.absolutesize.x)
							local ypos = clamp(utilities.mouse.position.y, colorReference.hue.absoluteposition.y, colorReference.hue.absoluteposition.y + colorReference.hue.absolutesize.y)
							colorReference.hueselection.position = newudim2(0, colorReference.hue.absoluteposition.x - 2, 0, ypos)

							local hue = abs(1 - (ypos - colorReference.picker.absoluteposition.y) / colorReference.picker.absolutesize.y)

							colorReference.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
							colorReference.pickercontainer.color = Color3.fromHSV(hue, 1, 1)
						end)
					end)

					colorReference.transparencypicker.clicked:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, colorReference.transparencypicker.absoluteposition.x, colorReference.transparencypicker.absoluteposition.x + colorReference.transparencypicker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, colorReference.transparencypicker.absoluteposition.y, colorReference.transparencypicker.absoluteposition.y + colorReference.transparencypicker.absolutesize.y)
						colorReference.transparencyselection.position = newudim2(0, xpos, 0, colorReference.transparencypicker.absoluteposition.y - 1)

						local transparency = (xpos - colorReference.transparencypicker.absoluteposition.x) / colorReference.transparencypicker.absolutesize.x
						colorReference.focusedon:settransparency(transparency)                           
						colorReference.updater = utilities.mouse.moved:Connect(function()
							local xpos = clamp(utilities.mouse.position.x, colorReference.transparencypicker.absoluteposition.x, colorReference.transparencypicker.absoluteposition.x + colorReference.transparencypicker.absolutesize.x)
							local ypos = clamp(utilities.mouse.position.y, colorReference.transparencypicker.absoluteposition.y, colorReference.transparencypicker.absoluteposition.y + colorReference.transparencypicker.absolutesize.y)
							colorReference.transparencyselection.position = newudim2(0, xpos, 0, colorReference.transparencypicker.absoluteposition.y - 1)

							local transparency = (xpos - colorReference.transparencypicker.absoluteposition.x) / colorReference.transparencypicker.absolutesize.x
							colorReference.focusedon:settransparency(transparency)
						end)
					end)

					utilities.mouse.mousebutton1up:Connect(function()
						if colorReference.updater then 
							colorReference.updater:Disconnect()
						end
					end)

					function menu:oldcallcolorpicker(name, flag, position, transparency)
						if not flag then return end
						local old = flag.color
						local oldhue, oldsat, oldval = Color3.toHSV(old)

						colorReference.outline.visible = true
						colorReference.outline.position = newudim2(0, position.x, 0, position.y)
						colorReference.title.text = name
						colorReference.pickercontainer.color = Color3.fromHSV(oldhue, 1, 1)

						if transparency then
							colorReference.outline.size = newudim2(0, 194, 0, 208)
						else
							colorReference.outline.size = newudim2(0, 194, 0, 196)
						end

						colorReference.hueselection.visible = true
						colorReference.pickerselection.visible = true

						colorReference.transparencyoutline.visible = transparency ~= nil and true or false
						colorReference.transparencyselection.visible = transparency ~= nil and true or false

						colorReference.hueselection.position = newudim2(0, -2, 0, abs(1 - oldhue) * colorReference.hue.absolutesize.y) + newudim2(0, colorReference.hue.absoluteposition.x, 0, colorReference.hue.absoluteposition.y)
						colorReference.pickerselection.position = newudim2(0, oldsat * colorReference.picker.absolutesize.x, 0, abs(oldval - 1) * colorReference.picker.absolutesize.y) + newudim2(0, colorReference.picker.absoluteposition.x, 0, colorReference.picker.absoluteposition.y)

						colorReference.transparencypicker.position = colorReference.transparencypicker.position
						colorReference.transparencycontainer.position = colorReference.transparencycontainer.position

						if transparency then
							colorReference.transparencyselection.position = newudim2(0, transparency * colorReference.transparencypicker.absolutesize.x, 0, -1) + newudim2(0, colorReference.transparencypicker.absoluteposition.x, 0, colorReference.transparencypicker.absoluteposition.y)
						end

						colorReference.focusedon = flag

						if transparency then
							colorReference.transparencyselection.position = newudim2(0, transparency * colorReference.transparencypicker.absolutesize.x, 0, -1) + newudim2(0, colorReference.transparencypicker.absoluteposition.x, 0, colorReference.transparencypicker.absoluteposition.y)
						end
						-- thing
						colorReference.outofboundscloseconnection = utilities.mouse.mousebutton1down:Connect(function()
							if utilities.mousechecks.inbounds(colorReference.outline, utilities.mouse.position) == false then -- uh oh..
								if colorReference.updater then
									colorReference.updater:Disconnect()
								end

								colorReference.outline.visible = false
								colorReference.transparencyselection.visible = false
								colorReference.hueselection.visible = false
								colorReference.pickerselection.visible = false

								if colorReference.outofboundscloseconnection then
									colorReference.outofboundscloseconnection:Disconnect()
									colorReference.outofboundscloseconnection = nil
								end
							end
						end)
					end
					menu.oldcolorpicker = colorReference
				end


				menu.colorpicker = {} -- would rather make 1 that moves around instead of do this for EVERY color picker, probably shouldve done this with dropdowns and what not but i got lazy

				menu.colorpicker.proportions = {
					mainSize = {x = 240, y = 240},
					secondaryBarWidth = 14,
				}

				menu.colorpicker.outline = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, menu.colorpicker.proportions.mainSize.x, 0, menu.colorpicker.proportions.mainSize.y),
					position = newudim2(0, 100, 0, 100),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.title = drawingFunction("text", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 4, 0, 2),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "Color Picker",
					name = "okay",
				})

				menu.colorpicker.titleBack = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0, 0),
					size = newudim2(1, 0, 0, 18),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.titleFront = drawingFunction("frame", {
					parent = menu.colorpicker.titleBack,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.secondTabBack = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(1, 0),
					size = newudim2(0, 68, 0, 18),
					position = newudim2(1, 0, 0, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					activated = true,
					name = "okay",
				})

				menu.colorpicker.secondTabFront = drawingFunction("frame", {
					parent = menu.colorpicker.secondTabBack,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 22,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.secondTabTitle = drawingFunction("text", {
					parent = menu.colorpicker.secondTabFront,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 2, 0, 1),
					zindex = menu.basezindex + 23,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "animation",
					name = "okay",
				})

				menu.colorpicker.firstTabBack = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(1, 0),
					size = newudim2(0, 40, 0, 18),
					position = newudim2(1, -menu.colorpicker.secondTabBack.absolutesize.x + 1, 0, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					activated = true,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.firstTabFront = drawingFunction("frame", {
					parent = menu.colorpicker.firstTabBack,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 22,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.firstTabTitle = drawingFunction("text", {
					parent = menu.colorpicker.firstTabFront,
					anchorpoint = newvec2(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = newudim2(0, 2, 0, 1),
					zindex = menu.basezindex + 23,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "color",
					name = "okay",
				})

				menu.colorpicker.container = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.pickeroutline = drawingFunction("frame", {
					parent = menu.colorpicker.container,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 212, 0, 212),
					position = newudim2(0, 4, 0, 22),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.pickercontainer = drawingFunction("frame", {
					parent = menu.colorpicker.pickeroutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.new(1, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.picker = drawingFunction("frame", {
					parent = menu.colorpicker.pickercontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					color = Color3.new(1, 1, 1),
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.picker

				do
					local parentedTo = menu.colorpicker.picker
					local smoothGradient = {}
					local xRes = 6
					local yRes = 6
					for xDim = 1, parentedTo.absolutesize.x / xRes do
						smoothGradient[xDim] = {}
						for yDim = 1, parentedTo.absolutesize.y / yRes do
							smoothGradient[xDim][yDim] = utilities:draw("frame", {
								parent = parentedTo,
								anchorpoint = newvec2(0, 0),
								size = newudim2(0, xRes, 0, yRes),
								position = newudim2(0, (xDim - 1) * xRes, 0, (yDim - 1) * yRes),
								zindex = parentedTo.zindex + 1,
								color = Color3.fromHSV(0, 0, 1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y),
								transparency = 1 - ((xDim - 1) * xRes) / parentedTo.absolutesize.x,
								visible = true,
								name = "okay",
							})
						end
					end
				end


				menu.colorpicker.pickerselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 1, 0, 1),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.pickerselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.pickerselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hueoutline = drawingFunction("frame", {
					parent = menu.colorpicker.pickeroutline,
					anchorpoint = newvec2(0, 0.5),
					size = newudim2(0, menu.colorpicker.proportions.secondaryBarWidth, 1, 0),
					position = newudim2(1, 4, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.huecontainer = drawingFunction("frame", {
					parent = menu.colorpicker.hueoutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hue = drawingFunction("frame", {
					parent = menu.colorpicker.huecontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.hue

				do
					local parentedTo = menu.colorpicker.hue
					local smoothGradient = {}
					local yRes = 6
					for yDim = 1, parentedTo.absolutesize.y / yRes do
						smoothGradient[yDim] = utilities:draw("frame", {
							parent = parentedTo,
							anchorpoint = newvec2(0, 0),
							size = newudim2(1, 0, 0, yRes),
							position = newudim2(0, 0, 0, (yDim - 1) * yRes),
							zindex = parentedTo.zindex + 1,
							color = Color3.fromHSV(1 - ((yDim - 1) * yRes) / parentedTo.absolutesize.y, 1, 1),
							visible = true,
							name = "okay",
						})
					end
				end

				menu.colorpicker.hueselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, menu.colorpicker.proportions.secondaryBarWidth + 2, 0, 2),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.hueselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.hueselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencyoutline = drawingFunction("frame", {
					parent = menu.colorpicker.pickeroutline,
					anchorpoint = newvec2(0.5, 0),
					size = newudim2(1, 0, 0, menu.colorpicker.proportions.secondaryBarWidth),
					position = newudim2(0.5, 0, 1, 4),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencycontainer = drawingFunction("frame", {
					parent = menu.colorpicker.transparencyoutline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 19,
					color = Color3.new(1, 1, 1),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencypicker = drawingFunction("frame", {
					parent = menu.colorpicker.transparencycontainer,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 0, 1, 0),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 20,
					transparency = 0,
					visible = true,
					activated = true,
					name = "okay",
				})
				menu.activations[1 + #menu.activations] = menu.colorpicker.transparencypicker

				do
					local parentedTo = menu.colorpicker.transparencypicker
					local smoothGradient = {}
					local xRes = 6
					for xDim = 1, parentedTo.absolutesize.x / xRes do
						smoothGradient[xDim] = utilities:draw("frame", {
							parent = parentedTo,
							anchorpoint = newvec2(0, 0),
							size = newudim2(0, xRes, 1, 0),
							position = newudim2(0, (xDim - 1) * xRes, 0, 0),
							zindex = parentedTo.zindex + 1,
							color = Color3.fromHSV(0, 0, ((xDim - 1) * xRes) / parentedTo.absolutesize.x),
							visible = true,
							name = "okay",
						})                      
					end
				end

				menu.colorpicker.transparencyselection = drawingFunction("frame", {
					parent = utilities.base,
					anchorpoint = newvec2(0, 0),
					size = newudim2(0, 2, 0, menu.colorpicker.proportions.secondaryBarWidth + 2),
					position = newudim2(0, 0, 0, 0),
					zindex = menu.basezindex + 22,
					color = Color3.new(1, 1, 1),
					visible = false,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				menu.colorpicker.transparencyselectionoutline = drawingFunction("frame", {
					parent = menu.colorpicker.transparencyselection,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, 2, 1, 2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 21,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				menu.colorpicker.outline.visible = false

				menu.colorpicker.focusedon = nil

				-- animation tab fuckin thingy (FUCK CREAM)
				menu.colorpicker.secondContainer = drawingFunction("frame", {
					parent = menu.colorpicker.outline,
					anchorpoint = newvec2(0.5, 0.5),
					size = newudim2(1, -2, 1, -2),
					position = newudim2(0.5, 0, 0.5, 0),
					zindex = menu.basezindex + 18,
					color = Color3.fromRGB(46, 46, 46),
					visible = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})

				-- fuck me dead :c
				menu.colorpicker.animationSelection = {}
				menu.colorpicker.fakeDropdown = nil
				menu.colorpicker.fakeDropdownFlag = nil
				menu.colorpicker.fakeVals = {{"none", true}, {"rainbow", false}, {"linear", false}, {"oscillating", false}, {"sawtooth", false}, {"strobe", false}}
				do
					local targetsection = menu.colorpicker.secondContainer
					local name = "animation"
					local multichoice = false

					local this = {}
					this.dropdownopened = false
					this.valuecontainer = {}
					this.textrecord = {}

					local myflag = menu.colorpicker.animationSelection
					myflag.__index = myflag
					myflag.type = "dropdown"
					myflag.name = name
					myflag.value = {}
					myflag.changed = utilities.signal.new()

					for i, v in next, (menu.colorpicker.fakeVals) do
						local name = v[1]
						local state = v[2]
						myflag.value[name] = state
					end

					this.holder = drawingFunction("frame", { -- for getting the bounds of the thing
						parent = targetsection,
						anchorpoint = newvec2(0, 0),
						size = newudim2(1, 0, 0, 24), -- WHAT THE FUCL<K>!?#?!#?!@?#!?#?!@?#$!@?H$???
						position = newudim2(0, 0, 0, 12),
						zindex = menu.basezindex + 19,
						color = Color3.fromRGB(255, 255, 255),
						visible = true,
						thickness = 0,
						filled = true,
						transparency = 0,
						name = "okay",
					})
					--hey guys vader here, today we're in need of emotional support

					this.title = drawingFunction("text", {
						parent = this.holder,
						anchorpoint = newvec2(0, 0),
						size = 13, -- x3
						font = Drawing.Fonts.Plex,
						position = newudim2(0, 16, 0, 8),
						zindex = menu.basezindex + 20,
						color = Color3.fromRGB(255, 255, 255),
						visible = true,
						outline = false,
						outlinecolor = Color3.fromRGB(12, 12, 12),
						text = name,
						name = "okay",
					})

					this.selection = drawingFunction("frame", { -- for getting the bounds of the thing
						parent = this.holder,
						anchorpoint = newvec2(0.5, 0),
						size = newudim2(1, -30, 0, 16),
						position = newudim2(0.5, 0, 0, 24),
						zindex = menu.basezindex + 20,
						color = menucolors.c,
						visible = true,
						thickness = 0,
						filled = true,
						name = "okay",
					})

					this.selectiontext = drawingFunction("text", {
						parent = this.selection,
						anchorpoint = newvec2(0, 0.5),
						size = 13, -- x3
						font = Drawing.Fonts.Plex,
						position = newudim2(0, 2, 0.5, -1),
						zindex = menu.basezindex + 21,
						color = Color3.fromRGB(255, 255, 255),
						visible = true,
						outline = false,
						outlinecolor = Color3.fromRGB(12, 12, 12),
						text = "",
						name = "okay",
					})

					this.icon = drawingFunction("frame", { -- for getting the bounds of the thing
						parent = this.selection,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 2, 1, 2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 20,
						color = menucolors.c,
						visible = true,
						thickness = 0,
						filled = true,
						transparency = 0,
						activated = true,
						name = "okay",
					})
					menu.activations[1 + #menu.activations] = this.icon

					this.icontext = drawingFunction("text", {
						parent = this.icon,
						anchorpoint = newvec2(0, 0.5),
						size = 13, -- x3
						font = Drawing.Fonts.Plex,
						position = newudim2(1, -10, 0.5, -2),
						zindex = menu.basezindex + 21,
						color = Color3.fromRGB(255, 255, 255),
						visible = true,
						outline = false,
						outlinecolor = Color3.fromRGB(12, 12, 12),
						text = "+",
						name = "okay",
					})

					this.selectionoutline = drawingFunction("frame", { -- for getting the bounds of the thing
						parent = this.selection,
						anchorpoint = newvec2(0.5, 0.5),
						size = newudim2(1, 2, 1, 2),
						position = newudim2(0.5, 0, 0.5, 0),
						zindex = menu.basezindex + 19,
						color = menucolors.d,
						visible = true,
						thickness = 1,
						filled = false,
						name = "okay",
					})

					local maximumchars = floor(this.selection.absolutesize.x / 6.5) - 4 -- suck

					function myflag:setvalue(new)
						myflag.value = new
						local selected = ""
						local selections = 0
						for idx, vals in next, (this.valuecontainer) do
							local i = vals.value
							local v = myflag.value[i]
							if not v then
								myflag.value[i] = false
							end
							if v then
								if selections > 0 then
									selected = selected .. ", "
								end
								selected = selected .. i
								selections = selections + 1
								this.textrecord[i].color = menu.accent
							else
								this.textrecord[i].color = Color3.new(255, 255, 255)
							end
						end
						selected = string.sub(selected, 0, maximumchars)
						if selections == 0 then
							this.selectiontext.text = "none"
						else
							this.selectiontext.text = selected
						end 
						myflag.changed:Fire()

						-- ok so when this shit updates, update the flag thats focused
						if menu.colorpicker.focusedon and menu.colorpicker.focusedon.setAnimation then
							menu.colorpicker.focusedon:setAnimation(new)
						end
					end

					for val, v in next, (menu.colorpicker.fakeVals) do
						local temporary = {}
						local val = v[1] -- so that its in order
						temporary.value = val
						temporary.selectionoutline = drawingFunction("frame", { -- for getting the bounds of the thing
							parent = this.selection,
							anchorpoint = newvec2(0.5, 0),
							size = newudim2(1, 2, 0, 22),
							position = newudim2(0.5, 0, 0, ((1 + #this.valuecontainer) * 20) -2),
							zindex = menu.basezindex + 27,
							color = menucolors.d,
							visible = false,
							thickness = 0,
							filled = true,
							name = "okay",
						})
						temporary.selection = drawingFunction("frame", { -- for getting the bounds of the thing
							parent = temporary.selectionoutline,
							anchorpoint = newvec2(0.5, 0.5),
							size = newudim2(1, -2, 1, -2),
							position = newudim2(0.5, 0, 0.5, 0),
							zindex = menu.basezindex + 28,
							color = menucolors.c,
							visible = true,
							thickness = 0,
							filled = true,
							activated = true,
							name = "okay",
						})
						menu.activations[1 + #menu.activations] = temporary.selection
						temporary.selectiontext = drawingFunction("text", {
							parent = temporary.selection,
							anchorpoint = newvec2(0, 0.5),
							size = 13, -- x3
							font = Drawing.Fonts.Plex,
							position = newudim2(0, 2, 0.5, 0),
							zindex = menu.basezindex + 29,
							color = Color3.fromRGB(255, 255, 255),
							visible = true,
							outline = false,
							outlinecolor = Color3.fromRGB(12, 12, 12),
							text = val,
							name = "okay",
						})
						this.textrecord[val] = temporary.selectiontext
						temporary.selection.clicked:Connect(function()
							if menu.uiopen == false then return end
							for i, v in next, (myflag.value) do
								myflag.value[i] = (val == i) -- suck my nutz
							end
							myflag:setvalue(myflag.value)
						end)
						this.valuecontainer[1 + #this.valuecontainer] = temporary
					end

					this.icon.clicked:Connect(function()
						if menu.uiopen == false then return end
						this.dropdownopened = not this.dropdownopened
						this.icontext.text = (this.dropdownopened == true) and "-" or "+"
						menu.isadropdownopen = this.dropdownopened
						for i, v in next, (this.valuecontainer) do
							v.selectionoutline.visible = this.dropdownopened
							v.selectionoutline.position = v.selectionoutline.position
							v.selectionoutline.size = v.selectionoutline.size
							if v.value and myflag.value[v.value] then
								local val = myflag.value[v.value]
								this.textrecord[v.value].color = (val == true) and menu.accent or Color3.fromRGB(255, 255, 255)
							end
						end
					end)

					local vals = {}
					for i, v in next, (menu.colorpicker.fakeVals) do
						local name = v[1]
						local state = v[2]
						vals[name] = state
					end

					myflag:setvalue(vals)
					menu.colorpicker.fakeDropdown = this
					menu.colorpicker.fakeDropdownFlag = myflag
				end

				menu.colorpicker.animationPanels = {}
				-- switch out the panels based on what is selected
				local first = true
				for i, v in next, menu.colorpicker.fakeVals do
					local name = v[1]
					local state = v[2]

					menu.colorpicker.animationPanels[name] = {}
					menu.colorpicker.animationPanels[name].offset = 54
					menu.colorpicker.animationPanels[name].panel = drawingFunction("frame", {
						parent = menu.colorpicker.secondContainer,
						anchorpoint = newvec2(0, 0),
						size = newudim2(1, 0, 1, 0),
						position = newudim2(0, 0, 0, 0),
						zindex = menu.basezindex + 18,
						color = Color3.fromRGB(0, 0, 0),
						visible = false,
						transparency = 0, -- hide it
						thickness = 0,
						filled = true,
						name = "okay",
					})

					if first then
						menu.colorpicker.animationPanels[name].panel.visible = true
						first = false
					end

					menu.colorpicker.animationSelection.changed:Connect(function()
						for i2, v2 in next, menu.colorpicker.animationSelection.value do
							if name == i2 then
								menu.colorpicker.animationPanels[name].panel.visible = v2
								menu.colorpicker.animationPanels[name].panel.position = menu.colorpicker.animationPanels[name].panel.position + newudim2(0, 1, 0, 1)
								menu.colorpicker.animationPanels[name].panel.position = menu.colorpicker.animationPanels[name].panel.position - newudim2(0, 1, 0, 1)
							end
						end
					end)
				end
				-- hey guys vader here, today we're becoming alan
				menu.colorpicker.animationPanelElements = {
					none = {},
					rainbow = {
						{
							type = "slider",
							name = "speed",
							max = 1000,
							min = 1,
							suffix = "%"
						}
					},
					linear = {
						{
							type = "color",
							name = "keyframe 1"
						},
						{
							type = "color",
							name = "keyframe 2"
						},
						{
							type = "slider",
							name = "speed",
							max = 1000,
							min = 1,
							suffix = "%"
						}
					},
					oscillating = {
						{
							type = "color",
							name = "keyframe 1"
						},
						{
							type = "color",
							name = "keyframe 2"
						},
						{
							type = "slider",
							name = "speed",
							max = 1000,
							min = 1,
							suffix = "%"
						}
					},
					sawtooth = {
						{
							type = "color",
							name = "keyframe 1"
						},
						{
							type = "color",
							name = "keyframe 2"
						},
						{
							type = "slider",
							name = "speed",
							max = 1000,
							min = 1,
							suffix = "%"
						}
					},
					strobe = {
						{
							type = "color",
							name = "keyframe 1"
						},
						{
							type = "color",
							name = "keyframe 2"
						},
						{
							type = "slider",
							name = "speed",
							max = 1000,
							min = 1,
							suffix = "%"
						}
					}
				}
				menu.colorpicker.elementReference = {}
				menu.colorpicker.flagReference = {}
				for name, elements in next, menu.colorpicker.animationPanelElements do

					menu.colorpicker.elementReference[name] = {}
					menu.colorpicker.flagReference[name] = {}
					local sectionReference = menu.colorpicker.elementReference[name]

					local section = menu.colorpicker.animationPanels[name]
					local targetsection = section.panel
					local currentOffset = section.offset

					for i, data in next, elements do
						menu.colorpicker.elementReference[name][data.name] = {}

						local fakeFlag = {}

						if data.type == "slider" then
							local flag = fakeFlag
							local minimum = data.min
							local maximum = data.max
							local suffix = data.suffix ~= nil and data.suffix or ""
							local customtext = {}

							local this = {}
							local offset = currentOffset - 10
							local myflag = fakeFlag -- mypenis

							myflag.__index = fakeFlag
							myflag.type = "slider"
							myflag.value = data.min
							myflag.changed = utilities.signal.new()

							this.holder = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = targetsection,
								anchorpoint = newvec2(0, 0),
								size = newudim2(1, 0, 0, 24),
								position = newudim2(0, 0, 0, offset),
								zindex = menu.basezindex + 6 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								thickness = 0,
								filled = true,
								transparency = 0,
								name = "okay",
							})

							targetsection.getpropertychangedsignal:Connect(function(prop, val)
								if prop == "visible" then
									this.holder.position = newudim2(0, 0, 0, offset)
								end
							end)

							this.title = drawingFunction("text", {
								parent = this.holder,
								anchorpoint = newvec2(0, 0),
								size = 13, -- x3
								font = Drawing.Fonts.Plex,
								position = newudim2(0, 16, 0, 8),
								zindex = menu.basezindex + 7 + 12,
								color = parameters.detected and Color3.fromRGB(255, 106, 79) or Color3.fromRGB(255, 255, 255),
								visible = true,
								outline = false,
								outlinecolor = Color3.fromRGB(12, 12, 12),
								text = data.name,
								name = "okay",
							})

							this.sliderback = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.holder,
								anchorpoint = newvec2(0, 0),
								size = newudim2(1, -32, 0, 6),
								position = newudim2(0, 16, 0, 24),
								zindex = menu.basezindex + 7 + 12,
								color = menucolors.b,
								visible = true,
								thickness = 0,
								filled = true,
								name = "okay",
							})

							this.sliderbackoutline = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.sliderback,
								anchorpoint = newvec2(0.5, 0.5),
								size = newudim2(1, 2, 1, 2),
								position = newudim2(0.5, 0, 0.5, 0),
								zindex = menu.basezindex + 6 + 12,
								color = menucolors.d,
								visible = true,
								thickness = 1,
								filled = false,
								name = "okay",
							})

							this.slider = {}
							for i = 1, 6 do
								this.slider[i] = drawingFunction("frame", { -- for getting the bounds of the thing
									parent = this.sliderback,
									anchorpoint = newvec2(0, 0),
									size = newudim2(0, 6, 0, 1),
									position = newudim2(0, 0, 0, i),
									zindex = menu.basezindex + 9 + 12,
									color = menu.accent:lerp(Color3.fromRGB(math.clamp((menu.accent.r * 255) - 5, 0, 255), math.clamp((menu.accent.g * 255) - 5, 0, 255), math.clamp((menu.accent.b * 255) - 5, 0, 255)), (i - 1) / 5),
									visible = true,
									thickness = 0,
									filled = true,
									name = "okay",
								})
							end

							menu.accents[1 + #menu.accents] = this.slider

							this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.sliderback,
								anchorpoint = newvec2(0.5, 0.5),
								size = newudim2(1, 0, 1, 10),
								position = newudim2(0.5, 0, 0.5, 0),
								zindex = menu.basezindex + 7 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								thickness = 0,
								transparency = 0,
								activated = true,
								filled = true,
								name = "okay",
							})
							menu.activations[1 + #menu.activations] = this.hitbox

							this.valuetitle = drawingFunction("text", {
								parent = this.sliderback,
								anchorpoint = newvec2(0.5, 0),
								size = 13, -- x3
								font = Drawing.Fonts.Plex,
								position = newudim2(1, 0, 0, 0),
								zindex = menu.basezindex + 9 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								outline = false,
								outlinecolor = Color3.fromRGB(12, 12, 12),
								text = "0°",
								name = "okay",
							})

							this.addtext = drawingFunction("text", {
								parent = this.sliderback,
								anchorpoint = newvec2(1, 0.5),
								size = 13, -- x3
								font = Drawing.Fonts.Plex,
								position = newudim2(1, 10, 0.5, -2),
								zindex = menu.basezindex + 9 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								outline = false,
								outlinecolor = Color3.fromRGB(12, 12, 12),
								activated = true,
								text = "+",
								name = "okay",
							})

							this.subtext = drawingFunction("text", {
								parent = this.sliderback,
								anchorpoint = newvec2(0, 0.5),
								size = 13, -- x3
								font = Drawing.Fonts.Plex,
								position = newudim2(0, -10, 0.5, -2),
								zindex = menu.basezindex + 9 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								outline = false,
								outlinecolor = Color3.fromRGB(12, 12, 12),
								text = "-",
								activated = true,
								name = "okay",
							})

							local textupdateconnection -- so u can click on the value text and manually enter a number
							function myflag:setvalue(new)
								if new == nil then
									new = 0
								end
								local newtext = tostring(new)
								if textupdateconnection then -- we r typing
									newtext = newtext .. "|"
								else
									new = clamp(new, minimum, maximum)
								end
								newtext = tostring(new)
								if customtext[newtext] then
									this.valuetitle.text = customtext[newtext]
								else
									this.valuetitle.text = newtext .. suffix
								end
								for i, v in next, this.slider do
									v.position = newudim2((((clamp(new, minimum, maximum) - minimum)) / (maximum - minimum)), 0, 0, i - 1) -- s3x
									local tostart = v.absoluteposition.x - this.sliderback.absoluteposition.x
									local scalederrr = -tostart / this.sliderback.absolutesize.x
									v.size = newudim2(scalederrr, 0, 0, 1)
								end
								this.valuetitle.position = this.slider[#this.slider].position + newudim2(0, 0, 0, 0)
								myflag.value = new
								myflag.changed:Fire()

								if menu.colorpicker.focusedon then
									menu.colorpicker.focusedon.animationSpeed[name] = new
								end
							end

							local connection
							this.hitbox.clicked:Connect(function()
								if menu.uiopen == false or menu.isadropdownopen then return end
								connection = runservice.Stepped:Connect(function()
									local relative = utilities.mouse.position.x
									local mousebound = utilities.mouse.position.x - this.hitbox.absoluteposition.x - 1
									mousebound = clamp(mousebound, 0, this.hitbox.absolutesize.x)
									local result = mousebound
									result = clamp(result, 0, this.hitbox.absolutesize.x)
									result = floor(0.5 + (((maximum - minimum) / this.hitbox.absolutesize.x) * mousebound) + minimum)
									myflag:setvalue(result)
									if this.hitbox.holding == false or menu.uiopen == false then
										connection:Disconnect()
										connection = nil
										return
									end
								end)
							end)

							this.addtext.mouseenter:Connect(function()
								this.addtext.color = menu.accent
							end)

							this.addtext.mouseleave:Connect(function()
								this.addtext.color = Color3.fromRGB(255, 255, 255)
							end)

							this.subtext.mouseenter:Connect(function()
								this.subtext.color = menu.accent
							end)

							this.subtext.mouseleave:Connect(function()
								this.subtext.color = Color3.fromRGB(255, 255, 255)
							end)

							this.addtext.clicked:Connect(function()
								myflag:setvalue(myflag.value + 1)
							end)

							this.subtext.clicked:Connect(function()
								myflag:setvalue(myflag.value - 1)
							end)

							myflag:setvalue(parameters.value)

							this.offsetted = currentOffset

							currentOffset = currentOffset + 36

							sectionReference[name] = this
						elseif data.type == "color" then
							local this = {}
							local dn = {}
							local myflag = dn

							currentOffset = currentOffset

							myflag.__index = dn
							myflag.type = "toggle"
							myflag.value = false
							myflag.changed = utilities.signal.new()

							this.hitbox = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = targetsection,
								anchorpoint = newvec2(0, 0),
								size = newudim2(1, 0, 0, 14),
								position = newudim2(0, 0, 0, currentOffset),
								zindex = menu.basezindex + 6 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								thickness = 0,
								filled = true,
								transparency = 0,
								name = "okay",
							})

							this.toggle = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.hitbox,
								anchorpoint = newvec2(0, 0.5),
								size = newudim2(0, 8, 0, 8),
								position = newudim2(0, 8, 0.5, 0),
								zindex = menu.basezindex + 7 + 12,
								color = Color3.fromRGB(76, 76, 76),
								visible = false,
								thickness = 0,
								filled = true,
								name = "okay",
							})

							this.toggleoutline = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.toggle,
								anchorpoint = newvec2(0.5, 0.5),
								size = newudim2(1, 2, 1, 2),
								position = newudim2(0.5, 0, 0.5, 0),
								zindex = menu.basezindex + 6 + 12,
								color = Color3.fromRGB(0, 0, 0),
								visible = false,
								thickness = 1,
								filled = false,
								name = "okay",
							})

							this.toggled = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.toggle,
								anchorpoint = newvec2(0, 0),
								size = newudim2(1, 0, 1, 0),
								position = newudim2(0, 0, 0, 0),
								zindex = menu.basezindex + 7 + 12,
								color = menu.accent,
								visible = false,
								thickness = 0,
								filled = true,
								name = "okay",
							})

							this.title = drawingFunction("text", {
								parent = this.hitbox,
								anchorpoint = newvec2(0, 0.5),
								size = 13, -- x3
								font = Drawing.Fonts.Plex,
								position = newudim2(0, 16, 0.5, -1),
								zindex = menu.basezindex + 6 + 12,   
								color = parameters.detected and Color3.fromRGB(255, 106, 79) or Color3.fromRGB(255, 255, 255),
								visible = true,
								outline = false,
								outlinecolor = Color3.fromRGB(12, 12, 12),
								text = data.name,
								name = "okay",
							})

							this.realhitbox = drawingFunction("frame", { -- for getting the bounds of the thing
								parent = this.hitbox,
								anchorpoint = newvec2(0, 0.5),
								size = newudim2(0, 32 + this.title.absolutesize.x, 1, 0),
								position = newudim2(0, 0, 0.5, 0),
								zindex = menu.basezindex + 8 + 12,
								color = Color3.fromRGB(255, 255, 255),
								visible = true,
								thickness = 0,
								filled = true,
								transparency = 0,
								name = "okay",
							})

							this.accessories = {} -- color pickers and what not

							currentOffset = currentOffset + 14

							do
								local parameters = {
									name = data.name,
									flag = fakeFlag,
									color = Color3.new(1, 1, 1),
									transparency = 0
								}
								local targetobj = this
								if not targetobj.accessories then
									return
								end
								local flag = parameters.flag
								local colorThis = {}

								local myflag = fakeFlag
								myflag.__index = fakeFlag
								myflag.type = "color"
								myflag.color = parameters.color
								myflag.transparency = parameters.transparency
								myflag.changed = utilities.signal.new()

								colorThis.outline = drawingFunction("frame", { -- for getting the bounds of the thing
									parent = this.hitbox,
									anchorpoint = newvec2(1, 0.5),
									size = newudim2(0, 24, 0, 12),
									position = newudim2(1, -14, 0.5, 0),
									zindex = menu.basezindex + 8 + 12,
									color = Color3.fromRGB(12, 12, 12),
									visible = true,
									thickness = 0,
									activated = true,
									filled = true,
									name = "okay",
								})

								colorThis.color = {}
								for i = 1, 5 do
									colorThis.color[i] = drawingFunction("frame", { -- for getting the bounds of the thing
										parent = colorThis.outline,
										anchorpoint = newvec2(0.5, 0),
										size = newudim2(1, -2, 0, 2),
										position = newudim2(0.5, 0, 0, (i - 1) * 2 + 1),
										zindex = menu.basezindex + 10 + 12,
										color = parameters.color:lerp(Color3.fromRGB(math.clamp(parameters.color.r * 255 - 33, 0, 255), math.clamp(parameters.color.g * 255 - 33, 0, 255), math.clamp(parameters.color.b * 255 - 33, 0, 255)), i / 5),
										visible = true,
										thickness = 0,
										filled = true,
										name = "okay",
									}) 
								end

								function myflag:setcolor(new)
									myflag.color = new
									for i = 1, 5 do
										local segment = colorThis.color[i]
										segment.color = new:lerp(Color3.fromRGB(math.clamp(new.r * 255 - 20, 0, 255), math.clamp(new.g * 255 - 20, 0, 255), math.clamp(new.b * 255 - 20, 0, 255)), (i - 1) / 5)
									end
									myflag.changed:Fire()

									if menu.colorpicker.focusedon then
										menu.colorpicker.focusedon.animationKeyFrames[name][data.name].color = new
									end
								end

								function myflag:settransparency(new)
									myflag.transparency = new
									myflag.changed:Fire()

									if menu.colorpicker.focusedon then
										menu.colorpicker.focusedon.animationKeyFrames[name][data.name].transparency = new
									end
								end

								myflag:setcolor(parameters.color)
								if myflag.transparency then
									myflag:settransparency(parameters.transparency)
								end

								colorThis.outline.clicked:Connect(function()
									if menu.uiopen == false or menu.isadropdownopen then return end
									menu:oldcallcolorpicker(data.name, fakeFlag, utilities.mouse.position, menu.colorpicker.focusedon.transparency and fakeFlag.transparency or nil)
								end)

								colorThis.bounds = newvec2(28, 0)

								colorThis.outline.visible = true

								sectionReference[data.name] = colorThis
							end
						end

						menu.colorpicker.flagReference[name][data.name] = fakeFlag
					end
				end

				menu.colorpicker.firstTabBack.clicked:Connect(function()
					if not menu.colorpicker.focusedon then return end
					menu.colorpicker.container.visible = true
					menu.colorpicker.secondContainer.visible = false

					local transparency = menu.colorpicker.focusedon.transparency
					if transparency then
						menu.colorpicker.transparencyoutline.visible = true
						menu.colorpicker.transparencyselection.visible = true
						menu.colorpicker.transparencyoutline.position = menu.colorpicker.transparencyoutline.position
						menu.colorpicker.transparencyselection.position = newudim2(0, transparency * menu.colorpicker.transparencypicker.absolutesize.x, 0, -2) + newudim2(0, menu.colorpicker.transparencypicker.absoluteposition.x, 0, menu.colorpicker.transparencypicker.absoluteposition.y)
					else
						menu.colorpicker.transparencyoutline.visible = false
						menu.colorpicker.transparencyselection.visible = false
					end

					menu.colorpicker.hueselection.visible = true
					menu.colorpicker.pickerselection.visible = true

					menu.colorpicker.firstTabFront.color = Color3.new(0, 0, 0)
					menu.colorpicker.secondTabFront.color = Color3.fromRGB(46, 46, 46)
				end)

				menu.colorpicker.secondTabBack.clicked:Connect(function()
					if not menu.colorpicker.focusedon then return end
					menu.colorpicker.container.visible = false
					menu.colorpicker.secondContainer.visible = true
					menu.colorpicker.secondContainer.position = menu.colorpicker.secondContainer.position + newudim2(0, -1, 0, 0)
					menu.colorpicker.secondContainer.position = menu.colorpicker.secondContainer.position + newudim2(0, 1, 0, 0)

					menu.colorpicker.transparencyselection.visible = false

					menu.colorpicker.hueselection.visible = false
					menu.colorpicker.pickerselection.visible = false

					menu.colorpicker.firstTabFront.color = Color3.fromRGB(46, 46, 46)
					menu.colorpicker.secondTabFront.color = Color3.new(0, 0, 0)

					menu.colorpicker.fakeDropdown.holder.position = newudim2(0, 0, 0, 12)

					for i, v in next,  menu.colorpicker.animationPanels do
						v.panel.position = v.panel.position + newudim2(0, 0, 0, 1)
						v.panel.position = v.panel.position - newudim2(0, 0, 0, 1)
					end
				end)

				-- how 2 pick color
				menu.colorpicker.picker.clicked:Connect(function()
					local oldhue = abs(1 - (clamp(menu.colorpicker.hueselection.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y) - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.picker.absoluteposition.x, menu.colorpicker.picker.absoluteposition.x + menu.colorpicker.picker.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.picker.absoluteposition.y, menu.colorpicker.picker.absoluteposition.y + menu.colorpicker.picker.absolutesize.y)
					menu.colorpicker.pickerselection.position = newudim2(0, xpos, 0, ypos)
					-- quick maths

					local sat = clamp((xpos - menu.colorpicker.picker.absoluteposition.x) / menu.colorpicker.picker.absolutesize.x, 0, 1)
					local val = clamp(abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y), 0, 1)

					menu.colorpicker.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))  

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.picker.absoluteposition.x, menu.colorpicker.picker.absoluteposition.x + menu.colorpicker.picker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.picker.absoluteposition.y, menu.colorpicker.picker.absoluteposition.y + menu.colorpicker.picker.absolutesize.y)
						menu.colorpicker.pickerselection.position = newudim2(0, xpos, 0, ypos)
						-- quick maths

						local sat = clamp((xpos - menu.colorpicker.picker.absoluteposition.x) / menu.colorpicker.picker.absolutesize.x, 0, 1)
						local val = clamp(abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y), 0, 1)

						menu.colorpicker.focusedon:setcolor(Color3.fromHSV(oldhue, sat, val))
					end)
				end)

				menu.colorpicker.hue.clicked:Connect(function()
					local old = menu.colorpicker.focusedon.color
					local oldhue, oldsat, oldval = Color3.toHSV(old)

					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.hue.absoluteposition.x, menu.colorpicker.hue.absoluteposition.x + menu.colorpicker.hue.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y)
					menu.colorpicker.hueselection.position = newudim2(0, menu.colorpicker.hue.absoluteposition.x - 2, 0, ypos)

					local hue = abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

					menu.colorpicker.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
					menu.colorpicker.pickercontainer.color = Color3.fromHSV(hue, 1, 1)

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.hue.absoluteposition.x, menu.colorpicker.hue.absoluteposition.x + menu.colorpicker.hue.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.hue.absoluteposition.y, menu.colorpicker.hue.absoluteposition.y + menu.colorpicker.hue.absolutesize.y)
						menu.colorpicker.hueselection.position = newudim2(0, menu.colorpicker.hue.absoluteposition.x - 2, 0, ypos)

						local hue = abs(1 - (ypos - menu.colorpicker.picker.absoluteposition.y) / menu.colorpicker.picker.absolutesize.y)

						menu.colorpicker.focusedon:setcolor(Color3.fromHSV(hue, oldsat, oldval))
						menu.colorpicker.pickercontainer.color = Color3.fromHSV(hue, 1, 1)
					end)
				end)

				menu.colorpicker.transparencypicker.clicked:Connect(function()
					local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.transparencypicker.absoluteposition.x, menu.colorpicker.transparencypicker.absoluteposition.x + menu.colorpicker.transparencypicker.absolutesize.x)
					local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.transparencypicker.absoluteposition.y, menu.colorpicker.transparencypicker.absoluteposition.y + menu.colorpicker.transparencypicker.absolutesize.y)
					menu.colorpicker.transparencyselection.position = newudim2(0, xpos, 0, menu.colorpicker.transparencypicker.absoluteposition.y - 2)

					local transparency = (xpos - menu.colorpicker.transparencypicker.absoluteposition.x) / menu.colorpicker.transparencypicker.absolutesize.x
					menu.colorpicker.focusedon:settransparency(transparency)

					menu.colorpicker.updater = utilities.mouse.moved:Connect(function()
						local xpos = clamp(utilities.mouse.position.x, menu.colorpicker.transparencypicker.absoluteposition.x, menu.colorpicker.transparencypicker.absoluteposition.x + menu.colorpicker.transparencypicker.absolutesize.x)
						local ypos = clamp(utilities.mouse.position.y, menu.colorpicker.transparencypicker.absoluteposition.y, menu.colorpicker.transparencypicker.absoluteposition.y + menu.colorpicker.transparencypicker.absolutesize.y)
						menu.colorpicker.transparencyselection.position = newudim2(0, xpos, 0, menu.colorpicker.transparencypicker.absoluteposition.y - 2)

						local transparency = (xpos - menu.colorpicker.transparencypicker.absoluteposition.x) / menu.colorpicker.transparencypicker.absolutesize.x
						menu.colorpicker.focusedon:settransparency(transparency)
					end)
				end)

				utilities.mouse.mousebutton1up:Connect(function()
					if menu.colorpicker.updater then 
						menu.colorpicker.updater:Disconnect()
					end
				end)

				function menu:callcolorpicker(name, flag, position, transparency)
					if not flag then return end
					local old = flag.color
					local oldhue, oldsat, oldval = Color3.toHSV(old)

					menu.colorpicker.container.visible = true
					menu.colorpicker.secondContainer.visible = false
					menu.colorpicker.transparencyselection.visible = true
					menu.colorpicker.hueselection.visible = true
					menu.colorpicker.pickerselection.visible = true

					menu.colorpicker.firstTabFront.color = Color3.new(0, 0, 0)
					menu.colorpicker.secondTabFront.color = Color3.fromRGB(46, 46, 46)

					menu.colorpicker.outline.visible = true
					menu.isacolorpickeropen = true
					menu.colorpicker.outline.position = newudim2(0, position.x, 0, position.y)
					menu.colorpicker.title.text = name
					menu.colorpicker.pickercontainer.color = Color3.fromHSV(oldhue, 1, 1)

					if transparency then
						menu.colorpicker.outline.size = newudim2(0, menu.colorpicker.proportions.mainSize.x, 0, menu.colorpicker.proportions.mainSize.y + menu.colorpicker.proportions.secondaryBarWidth + 2)
					else
						menu.colorpicker.outline.size = newudim2(0, menu.colorpicker.proportions.mainSize.x, 0, menu.colorpicker.proportions.mainSize.y)
					end

					menu.colorpicker.hueselection.visible = true
					menu.colorpicker.pickerselection.visible = true

					menu.colorpicker.transparencyoutline.visible = transparency ~= nil and true or false
					menu.colorpicker.transparencyselection.visible = transparency ~= nil and true or false

					menu.colorpicker.hueselection.position = newudim2(0, -2, 0, abs(1 - oldhue) * menu.colorpicker.hue.absolutesize.y) + newudim2(0, menu.colorpicker.hue.absoluteposition.x, 0, menu.colorpicker.hue.absoluteposition.y)
					menu.colorpicker.pickerselection.position = newudim2(0, oldsat * menu.colorpicker.picker.absolutesize.x, 0, abs(oldval - 1) * menu.colorpicker.picker.absolutesize.y) + newudim2(0, menu.colorpicker.picker.absoluteposition.x, 0, menu.colorpicker.picker.absoluteposition.y)

					menu.colorpicker.focusedon = flag

					if transparency then
						menu.colorpicker.transparencyoutline.position = menu.colorpicker.transparencyoutline.position
						menu.colorpicker.transparencyselection.position = newudim2(0, transparency * menu.colorpicker.transparencypicker.absolutesize.x, 0, -2) + newudim2(0, menu.colorpicker.transparencypicker.absoluteposition.x, 0, menu.colorpicker.transparencypicker.absoluteposition.y)
					end
					-- thing
					menu.colorpicker.outofboundscloseconnection = utilities.mouse.mousebutton1down:Connect(function()
						if utilities.mousechecks.inbounds(menu.oldcolorpicker.outline, utilities.mouse.position) == false and utilities.mousechecks.inbounds(menu.colorpicker.outline, utilities.mouse.position) == false then -- uh oh..
							if menu.colorpicker.updater then
								menu.colorpicker.updater:Disconnect()
							end

							menu.colorpicker.outline.visible = false
							menu.colorpicker.transparencyselection.visible = false
							menu.colorpicker.hueselection.visible = false
							menu.colorpicker.pickerselection.visible = false
							menu.isacolorpickeropen = false

							if menu.colorpicker.outofboundscloseconnection then
								menu.colorpicker.outofboundscloseconnection:Disconnect()
								menu.colorpicker.outofboundscloseconnection = nil
							end

							do
								local myflag = menu.colorpicker.animationSelection
								local this = menu.colorpicker.fakeDropdown
								this.dropdownopened = false
								this.icontext.text = (this.dropdownopened == true) and "-" or "+"
								menu.isadropdownopen = false
								for i, v in next, (this.valuecontainer) do
									v.selectionoutline.visible = this.dropdownopened
									v.selectionoutline.position = v.selectionoutline.position
									v.selectionoutline.size = v.selectionoutline.size
									if v.value and myflag.value[v.value] then
										local val = myflag.value[v.value]
										this.textrecord[v.value].color = (val == true) and menu.accent or Color3.fromRGB(255, 255, 255)
									end
								end
							end
						end
					end)

					-- animation section fix
					menu.colorpicker.fakeDropdownFlag:setvalue(flag.animation)

					-- keyframe fix
					for element, keyframes in next, flag.animationKeyFrames do
						for keyindex, data in next, keyframes do
							menu.colorpicker.flagReference[element][keyindex]:setcolor(data.color)
							if data.transparency then
								menu.colorpicker.flagReference[element][keyindex]:settransparency(data.transparency)
							end
						end
					end

					-- slider fix
					for element, value in next, flag.animationSpeed do
						menu.colorpicker.flagReference[element]["speed"]:setvalue(value)
					end
				end

				menu:callcolorpicker(
					"Evie <3", 
					{
						color = Color3.new(1, 1, 1),
						animation = {
							none = true,
							rainbow = false,
							linear = false,
							oscillating = false, 
							strobe = false
						},
						animationKeyFrames = {
							linear = {
								["keyframe 1"] = {
									color = Color3.new(),
									transparency = 1
								},
								["keyframe 2"] = {
									color = Color3.new(),
									transparency = 1
								}
							},
							oscillating = {
								["keyframe 1"] = {
									color = Color3.new(),
									transparency = 1
								},
								["keyframe 2"] = {
									color = Color3.new(),
									transparency = 1
								}
							},
							strobe = {
								["keyframe 1"] = {
									color = Color3.new(),
									transparency = 1
								},
								["keyframe 2"] = {
									color = Color3.new(),
									transparency = 1
								}
							},
						}, -- color and transparency
						animationSpeed = {
							rainbow = 100,
							linear = 100,
							oscillating = 100,
							strobe = 100
						},
					}, 
					newvec2(), 
					nil
				)
				do
					if menu.colorpicker.updater then
						menu.colorpicker.updater:Disconnect()
					end

					menu.colorpicker.outline.visible = false
					menu.colorpicker.transparencyselection.visible = false
					menu.colorpicker.hueselection.visible = false
					menu.colorpicker.pickerselection.visible = false
					menu.isacolorpickeropen = false

					if menu.colorpicker.outofboundscloseconnection then
						menu.colorpicker.outofboundscloseconnection:Disconnect()
						menu.colorpicker.outofboundscloseconnection = nil
					end

					do
						local myflag = menu.colorpicker.animationSelection
						local this = menu.colorpicker.fakeDropdown
						this.dropdownopened = false
						this.icontext.text = (this.dropdownopened == true) and "-" or "+"
						menu.isadropdownopen = false
						for i, v in next, (this.valuecontainer) do
							v.selectionoutline.visible = this.dropdownopened
							v.selectionoutline.position = v.selectionoutline.position
							v.selectionoutline.size = v.selectionoutline.size
							if v.value and myflag.value[v.value] then
								local val = myflag.value[v.value]
								this.textrecord[v.value].color = (val == true) and menu.accent or Color3.fromRGB(255, 255, 255)
							end
						end
					end
				end
			end
		end

		function menu:setsize(size)
			menu.objects.backborder.size = newudim2(0, math.clamp(size.x, parameters.size.x, 1/0), 0, math.clamp(size.y, parameters.size.y, 1/0))
		end

		function menu:savestate() -- configs!!
			local state = {}
			for i, v in next, (menu.flags) do
				if i:match("config") or i:match("playerlist") then -- ignore the configs!!
				else
					local kind = v.type
					if kind == "toggle" or kind == "slider" or kind == "textbox" then
						local val = {v.value}
						state[i] = {kind, val}
					elseif kind == "color" then
						local val = {v.color.r, v.color.g, v.color.b, v.transparency}
						local keyFrameFix = {}
						for n, kfs in next, v.animationKeyFrames do
							keyFrameFix[n] = {}
							for idx, d in next, kfs do
								keyFrameFix[n][idx] =  {d.color.r, d.color.g, d.color.b, d.transparency}
							end
						end
						local animations = {
							animation = v.animation,
							animationKeyFrames = keyFrameFix,
							speeds = v.animationSpeed
						}
						state[i] = {kind, {val, animations}}
					elseif kind == "dropdown" then
						local val = {}
						for i, v in next, (v.value) do
							val[i] = v
						end
						state[i] = {kind, val}
					elseif kind == "keybind" then
						local val = {v.key ~= "NONE" and v.key or "NONE", v.activation}
						state[i] = {kind, val}
					end
				end
			end
			state.menusize = {x = menu.objects.backborder.absolutesize.x, y = menu.objects.backborder.absolutesize.y}
			state.panelsize = {}
			for tab, columns in next, menu.subsections do
				if tab ~= "players" then
					state.panelsize[tab] = {}
					for column, panels in next, columns do
						for panel, data in next, panels do
							local sz = data.panelResize.getSize()
							local ps = data.panelReposition.getPosition()

							state.panelsize[tab][panel] = {
								size = {
									scalex = sz.X.Scale,
									scaley = sz.Y.Scale,
									offsetx = sz.X.Offset,
									offsety = sz.Y.Offset
								},
								position = {
									scalex = ps.X.Scale,
									scaley = ps.Y.Scale,
									offsetx = ps.X.Offset,
									offsety = ps.Y.Offset,
									side = data.panelReposition.getSide()
								}
							}
						end
					end
				end
			end

			return json.encode(state)
		end

		function menu:loadstate(state)
			local state = json.decode(state)
			for i, v in next, (state) do
				if i == "menusize" then
					menu:setsize(Vector2.new(v.x, v.y))
				elseif i == "panelsize" then
					for tab, columns in next, menu.subsections do
						if tab ~= "players" then
							for column, panels in next, columns do
								for panel, data in next, panels do
									if v[tab] and v[tab][panel] then
										local configData = v[tab][panel]
										local menuPanel = data
										if menuPanel then
											menuPanel.panelReposition.setSide(configData.position.side)
										end
									end
								end
							end
						end
					end
					for tab, columns in next, menu.subsections do
						if tab ~= "players" then
							for column, panels in next, columns do
								for panel, data in next, panels do
									if v[tab] and v[tab][panel] then
										local configData = v[tab][panel]
										local menuPanel = data
										if menuPanel then
											menuPanel.panelReposition.setPosition(newudim2(configData.position.scalex, configData.position.offsetx, configData.position.scaley, configData.position.offsety))
										end
									end
								end
							end
						end
					end
					for tab, columns in next, menu.subsections do
						if tab ~= "players" then
							for column, panels in next, columns do
								for panel, data in next, panels do
									if v[tab] and v[tab][panel] then
										local configData = v[tab][panel]
										local menuPanel = data
										if menuPanel then
											menuPanel.panelResize.setSize(newudim2(configData.size.scalex, configData.size.offsetx, configData.size.scaley, configData.size.offsety))
										end
									end
								end
							end
						end
					end
				else
					local ff = menu.flags[i]
					if ff then
						local kind = v[1]
						local value = v[2]
						if kind == "toggle" or kind == "slider" or kind == "textbox" then
							ff:setvalue(value[1])
						elseif kind == "dropdown" then
							ff:setvalue(value)
						elseif kind == "color" then
							ff:setcolor(Color3.new(value[1][1], value[1][2], value[1][3]))
							if value[1][4] then
								ff:settransparency(value[1][4])
							end
							local keyFrameFix = {}
							for n, kfs in next, value[2].animationKeyFrames do
								keyFrameFix[n] = {}
								for idx, d in next, kfs do
									keyFrameFix[n][idx] = {
										color = Color3.new(d[1], d[2], d[3]),
										transparency = d[4],
									}
								end
							end
							ff:setAnimation(value[2].animation)
							ff:setAnimationSpeed(value[2].speeds)
							ff:setAnimationKeyFrames(keyFrameFix)
						elseif kind == "keybind" then
							ff:setkey(value[1])
							ff:setactivation(value[2])
						end
					end                        
				end               
			end
		end

		menu.uiopen = true

		menu.animations = {}
		menu.targetrans = Instance.new("NumberValue")
		menu.targetrans.Value = 1
		function menu:updatemenuanimations() -- thing
			for i, v in next, menu.animations do
				v:Disconnect()
			end
			table.clear(menu.animations)
			for i, v in next, (menu.openclose) do
				if v.transparency and v.transparency > 0 then
					if v.transparency == 1 then
						menu.animations[1 + #menu.animations] = menu.targetrans.Changed:Connect(function()
							v.drawingobject.Transparency = menu.targetrans.Value
						end)
					else
						menu.animations[1 + #menu.animations] = menu.targetrans.Changed:Connect(function()
							v.drawingobject.Transparency = v.transparency * menu.targetrans.Value
						end)
					end
				end
			end
		end

		menu.uiopen = false

		local openereses = tweenservice:Create(menu.targetrans, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Value = 1})
		local closeereses = tweenservice:Create(menu.targetrans, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = 0})

		function menu:openui()
			menu.uiopen = true
			menu.objects.backborder.position = newudim2(0, menu.objects.backborder.absoluteposition.x, 0, menu.objects.backborder.absoluteposition.y) -- ez fix
			openereses:Play()
		end

		function menu:closeui()
			menu.uiopen = false

			do
				if menu.colorpicker.updater then
					menu.colorpicker.updater:Disconnect()
				end

				menu.colorpicker.outline.visible = false
				menu.colorpicker.transparencyselection.visible = false
				menu.colorpicker.hueselection.visible = false
				menu.colorpicker.pickerselection.visible = false
				menu.isacolorpickeropen = false

				if menu.colorpicker.outofboundscloseconnection then
					menu.colorpicker.outofboundscloseconnection:Disconnect()
					menu.colorpicker.outofboundscloseconnection = nil
				end

				do
					local myflag = menu.colorpicker.animationSelection
					local this = menu.colorpicker.fakeDropdown
					this.dropdownopened = false
					this.icontext.text = (this.dropdownopened == true) and "-" or "+"
					menu.isadropdownopen = false
					for i, v in next, (this.valuecontainer) do
						v.selectionoutline.visible = this.dropdownopened
						v.selectionoutline.position = v.selectionoutline.position
						v.selectionoutline.size = v.selectionoutline.size
						if v.value and myflag.value[v.value] then
							local val = myflag.value[v.value]
							this.textrecord[v.value].color = (val == true) and menu.accent or Color3.fromRGB(255, 255, 255)
						end
					end
				end
			end

			closeereses:Play()
		end

		menu:closeui()

		return menu
	end
	uilibrary = uilib
end

-- services
local workspace			        = game:GetService("Workspace")
local soundService			    = game:GetService("SoundService")
local lighting			        = game:GetService("Lighting")
local players			        = game:GetService("Players")
local runService		        = game:GetService("RunService")
local virtualUser               = game:service("VirtualUser")
local userInputService	        = game:GetService("UserInputService")
local httpService		        = game:GetService("HttpService")
local replicatedStorage	        = game:GetService("ReplicatedStorage")
local userSettings		        = UserSettings():GetService("UserGameSettings")
local tweenService 		        = game:GetService("TweenService")
local physicsService	        = game:GetService("PhysicsService")
local proximityPromptService    = game:GetService("ProximityPromptService")
local networkClient		        = game:GetService("NetworkClient")

-- common objects
local math                      = math
local string                    = string
local table                     = table
local Rect                      = Rect
local camera			        = workspace.CurrentCamera
local viewportSize		        = camera.ViewportSize
local localPlayer		        = players.LocalPlayer
local mouse				        = localPlayer:GetMouse()
local newVec3                   = Vector3.new
local emptyVec3			        = newVec3()
local vector3Zero               = Vector3.zero
local dot3d                     = vector3Zero.Dot
local xz				        = Vector3.one - Vector3.yAxis
local newVec2                   = Vector2.new
local emptyVec2			        = newVec2()
local newCframe                 = CFrame.new
local emptyCf			        = newCframe()
local pointToObjectSpace        = newCframe().PointToObjectSpace
local rayCast                   = workspace.Raycast
local next                      = next
local localPing                 = game:GetService("Stats").PerformanceStats.Ping:GetValue()
local localPingUpdate; localPingUpdate = runService.RenderStepped:Connect(function() 
	localPing = game:GetService("Stats").PerformanceStats.Ping:GetValue()
end)

-- constants
local nan				        = math.sqrt(-1)
local inf				        = 1/0
local smallestNumber	        = -1.7*10^308
local highestNumber		        = -smallestNumber
local pi				        = math.pi
local tau				        = 2*pi
local toDeg				        = 180/pi
local toRad				        = pi/180

-- third party modules
local janitor                   = nil

-- modules
local pfModules                 = {} -- cache for all of pf's modules
local playerInfo                = {} -- pinfo module, similar to bloxsense
local currentInfo               = {} -- our info, firerate, gun name etc
local hooks                     = {} -- ur idea assah
local tickbase                  = {} -- tickbase module, i wanna be able to do shit like tickbase:GetTick(), tickbase:Shift()
local networking                = {} -- easier network hooking
local heap                      = {} -- self explanatory
local pathfinding               = {} -- self explanatory
local mathematics               = {} -- mathmodule
local rayCaster                 = {} -- kinda skidded from pf but not really
local spring                    = {} -- spring module
local signal                    = {} -- signal module
local gunHandler                = {} -- handle gun stat requests & modify them

-- cheat funcs
local legit                     = {} -- legitbot
local rage                      = {} -- ragebot
local esp                       = {} -- esp
local visuals                   = {} -- visuals
local esp                       = {} -- esp
local misc                      = {} -- misc
local sharedHooks               = {} -- misc hooks needed for different cheat funcs (e.g. network hook)
local scriptLib                 = {}

-- variables relating to resolution
local gc                        = getgc(false) -- since pf updated we only need one function
local pfImport                  = nil

-- cache
local cache = {
	images = {
		grenade = "",
		exclamation = ""
	}
}

do
	coroutine.wrap(function() local a = crypt.base64.decode("iVBORw0KGgoAAAANSUhEUgAAACEAAAApCAYAAAC7t0ACAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAOGSURBVFhH7ZjPSxRhHMa32NAs+oEGBVGyhGghHhQMEgLpJxgF1aHIOgSeyjxEdQgK8lBRQYeipD8gIugghEEHoR9UaEkHlc0WraAiQ7FDWkp9npnXbWdmd2dG14jwgWef7/tj3nne77wz78xGZvEvYY7RaSORSDwaHx8vnJiYqC8rK+s01YEQ2ERPT09lXl7edsJFdo0DIxg4h7bD5yUlJaes2oAIZEKzRFbCN5zsq1XpxBI4HI1GR9E9sCIWiyXUEAS+JkwG7hLetmt8UQMfYKLZLvpjrtGMwMAQEiUDSvFRqzI7OuAJOwyGUAszHo//IuXnTTEjMLyVfjfIRoupygrfTKSCgb+Z0A+fYb0d+iOUCRA3mhWY7dLtyoLea6qyIqyJeUaDYAA22mF2hDURM+oLk40istFgqjIilAkGXYjk2yUnaFvvop4d7egZu0dmhF2Yl5Equ/QHnKiYtjWwLYUH4Cgc9MtG2MvRBr/boQcD3JIXJkn5JqzFYDc8ZvXIAN/nBLPQOtAq3wFXMeBbZvdMbZMwmSgnbBobGxua3MA49jFtX2iroNiAuYeqdyOjCQY4yQCNDBClGCf+oHqK/dI0qKFPIe1aM0XE94iVhSbKvfAdG9shdXTDY4KTL0W0G2qGTxloWHFI5HNsKcfK2E+0Ay1HN5ANz8aWbk1cgj/g/SkaELQgu9BbcAgDm9F+9Ioa3XCYIAubkDqY9tpNAdraXyjAVAFSrV1Z5VQ4TOD0CHxpijkBJ9ca+gS1wHvZlTVRBxwmOKAWahHlFIzZx+T0oNMDzIOkCXMrDkKlMNfo0w9mspsAMdzOhAFBl0OXe7lVcsF9ObpNOBP4CNPuO+6FudaEfxUOEzOMFUY9SJrQc53Lodf6nIMMa28ZMUUP3Jl4DdMunmmiGCPWJwM636pJgdtEK51KTZwraDGuJhPWUxjVk9MBt4kWOq3DSNr7eYqoYszrqL5flInF0lQ4TLAu1PEirIZpb6cw4ITFiHjNqgCapAmTcGdCRprp+IpwN5yOEa2tjbzk7DKTywiPCYGDDiN34H4YdqHKeCVZ0FfYwSB/E6Q1IWDkOKJddQtah06+QXugtJv2nRQ1gfdKO2MkXwlou4p8Qj2mAn2LmveMbQywj8HHUJ2kAF1AfRnxE7QVdqaeOBWMcZr+y+h71n15Qn0QC+avAr0CRlJfamfxnyAS+Q0Lj2qxxRaW/gAAAABJRU5ErkJggg==") cache.images.grenade = a end)()
	coroutine.wrap(function() local b = crypt.base64.decode("iVBORw0KGgoAAAANSUhEUgAAALIAAAGrCAYAAABkJM2PAAANI0lEQVR4nO3d22pc1x2A8W25xJVqrBgCuakhJXUDfYi8QG9DrtIHCaEUTAN5gt6WlBIHjENk4pDEyI6dRI6FLUeUIIuxZR3GkuXRqCNpRrM1h73LRDvIOms0o1n/w/e7yp1WzKfRWnutWTuKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4MCp0APohddff73vo48++tvp06ffDD2WTtVqtZn333//H4VCYSP0WNBDr7zySt/PP//8zzRNk9SGZHx8/N+vvfZaX+h/W/TQwMDAQOjyTsJ77713LvS/rST8VuvlYlp4VIQMEwgZJhAyTCBkmEDIMIGQYQIhwwRChgmEDBMIGSYQMkwgZJhAyDCBkGECIcMEQoYJhAwTCBkmEDJMIGSYQMgwgZBhAiHDBEKGCYQMEwgZJhAyTCBkmEDIMIGQYQIhwwRChgmEDBMIGSYQMkwgZJhAyDCBkGECIcMEQoYJhAwTCBkmEDJMIGSYQMgwgZBhAiHDBEKGCYQMEwgZJhAyTCBkmEDIMIGQYQIhwwRChgmEDBMIGSYQMkwgZJhAyDCBkGECIcMEQoYJhAwTCBkmEDJMIGSYQMgwgZBhAiHDBEJWqlwuJ6HHIMmp0AM4aQMDA/2VSmWp9Z+hx9JNfX19fWmapqHHIYWHT+TWJ9dy6EF02XroAUjjIeRmFEVLoQfRZSuhByCNl5ALoQfRZYtRFDGteIn5kKvVanrjxo1K6HF02XzoAUhjPuTWeqhcLldDj6Obvv766zXWeduZDzljao5cLBbj0GOQxkvIz0MPoMusTZU65iXkhdAD6LJ86AFI4yLkoaGhtdBj6LLF0AOQxkXIlUoltvS4amJiohR6DNK4CLm1PrIU8tjYGIu9HbyE/CLbqrYgYbG3GyHrU7f2OLEbXIR8/fr1cq1WszK1aERR9L/Qg5DGRcitbeo0TTdCj6MbkiRpxnHMYm8H8+eRfxXH8dSZM2f+EHocnSqVSqXz58+fDz0OaVx8Imes7O5xFnkPnkK2cmKsGHoAErkJ+bPPPlsNPYYusXa2uivchFytVq1sIlj5y9JVbkK28uz1m2++KYceg0SeQjax2CsUClb+snSVp5CtHOW0MtfvKjchX7161UoAVn4hu8pNyHEc14yctyDkPbgJOYqitezAjWqTk5NW/rJ0laeQWwdtaqEH0an79++z2NuDp5BbGwnaI2j9RTF1tUG3uAn5zp071cXFxWbocXSoynVZe3MTcqPRaB3l1P6JHGdzfezgJuSM6gPpzWZzo16vs7O3B28hq97dm5mZqbPY25u3kLVfbMJCbx+uQh4dHdX+Z9naheVd4yrkXC6n/dsV3DC0D1chG3h09Sz0AKTyFrLqT7Th4WHtU6MT4y3kmdAD6MTi4qKJKw1OgquQ7927p/0TjQND+3AV8uPHj2vZy3G04gjnPlyFnD2H1byhwBdP9+Et5LLmC05yuRxTi314C7mkeZ45OjrKYm8frkKenZ3dmJ+f13q4PrbwDZeT4irkYrGYlkolrSGvZlMj7MFVyBmtu3tlDg3tz2PIKlf+zWaz0mw2NT9xOVEeQ1Z5lPOnn36q5XI55sj7cBfy3bt3tT61UPvYsBfchTw1NaX1zzP3Ih/AXcjZs2SNuBf5AB5D1npegbPIB/AYssrF3q1bt3iGfAB3IY+MjKh8a+j8/Dzb0wdwF/L09PSG0qOcWp+29IS7kBXfn6Z1bt8THkNeV/q1epU7kr3iMeSqxquzpqammFocwF3IhUKhMTk5qW1qkd69e5fF3gHchVypVJKlpSVtUVSVLlB7xl3IGW1HOVu7etp++XrKa8jadslKfDvkYF5DVvUoK0mSVUI+mMuQv/vuO1VTi5s3b268ePHCwqvVTozLkGdnZ7Ud5VS5rd5LLkNWuNgz8UL4k+Q1ZG2LPc4iH8JryNq2e1UtTkNwGfLt27dVTS1u377NK8kO4TLkfD5f17RTls/n2Qw5hMuQs4g1fcpxYOgQXkNuKFtAaZvT9xwh68Bi7xAuQ67X68mzZ8/U/Lmenp5WtTgNwWXI1Wo1ffjwoZbdveSHH37gnMUhXIbckqaplk/k1vZ0GnoQ0rkNWdECaoGQD0fI8i0R8uHchjw9Pa3iDrg0TZcJ+XBuQx4ZGVHxBdQrV66s1+t1Qj6E25CznT0NgXAv8hF4DlnLJgNnkY/Ac8jPlXwiL4YegAZuQ3769GkpTVPxIadp+jz0GDRwG/K9e/dqSZKI/0Ln5cuXNZ3SC8ZtyBnpkaTKXwLfM95Dln57fcLbTo/Ge8jSn1w0lR03DcZ1yE+ePJF+vWzr3PSL0IPQwHXIP/74o+j5ZxzHyejoKFOLI3AdsvTFXqPRaCwsLDRCj0MD7yFLX+zxaXxE3kOWPv+UvhgVw3XIuVxO+mKP7ekjch3y6Oio6KOcMzMzGt8+FYTrkLMjkmJvHPr+++9F/6JJ4j3kReHv5hD9VEUS7yEvC3+lQTH0ALRwHfLc3NxatVqV/JyW7ekjch3yxMRErfXevdDjOABnkY/IdcgZsfPQTz75RMslMsERchTNhR7APpppmkqev4tCyHLnoY3s1b04AvchP3r0SOqTgdbJPOk7j2K4D/nBgwdSj3JWCfno3Ics9bUGxWKx8ejRIy5nOSJCFvrOvUqlUi8UCmK3z6UhZLknzMQ+FpTIfcgTExNSF3tarr0VwX3IY2NjUhd7Uv9SiOQ+5OwxVy30IHbK5/Mq7m+WgpCjqJS9p0OUO3fusBnSBkLe/IKnxGhY7LXBfci1Wq3caDQkzpOlfzFWFPchj4+P16empiSeSeaC7za4DzkjcXePT+Q2EPImcfdHfPrppxJ/ucQi5E3Sntk2ms2mxOmOWIS8ea5B2nw05oLv9hByFEWff/65tMdvZYnPtiUj5E3SntmuChyTaIS8SdQBnbm5uVo+n+f7em0g5E2i5sjLy8u1UqnEWeQ2EHJrQlouS3tmy7SiTYQcRdG1a9ekLfZETXU0IORNdWGXGUp7ri0eIW9qfclzJfQgfjU/P89Z5DYR8qaqpJBv3brFt6fbRMibRznjOI4lvXhG0lhUIOQoimZnZxvj4+OS5shSr/ESi5C3SNoSJuQ2EfIWSUc5JY1FBULeIuZT8MqVK5L+OqhAyJmVlRUpIdfq9Trb020i5MwXX3wh5UlBWfgLekQi5C1S/pyvSLwwRjpC3iLlxTMFofdsiEbIW0Scb5icnIw5wtk+Qs6USiURi72FhYXWK9PS0OPQhpAz169fl7LY4yzyMRDylkTI3FTkDfrSEfKWhpCXz4iYq2tDyFvqEl5i/vz5c84iHwMhZ5rNZn11dXU59DiGh4clTG/UIeTMyspKMjIyIiEiKRszqhDydhIiYo58DIS8nYRrAUQ8z9aGkLeTsE3NJ/IxEPJLisVi8IiuXr0qYXqjDiG/5Kuvvgod0UYcx0ngMahEyNuFDrl1hJNzFsdAyNuFvsywmG2Vo02EvF3oOXI+2ypHmwh5u6DfXh4fH1+v1+tMLY6BkF9y7dq1oEc5nzx5Ums0+EA+DkJ+ydraL0eBQy74pJyJVoeQdwu54MsH/NmqEfJ2aeAFHzcMHRMh7xZsm7pQKHAW+ZgI+SVpmkZDQ0PB5sg3btyQdCOoKoS8Q6VSCbXgSgXsLKpFyLuF+t5eIuQYqUqEvFuoOXIi4TuDWhHybqFeDZYIOOsBK955552/pAHEcVzt7+8P/b+vFp/IO6yvr8chTqClaVqtViV891UnQt6t9Sw3xCWCwa8i0IyQd1sKdNE2XzrtACHvVgh0JphzFh0g5B2Gh4fXW5e19Prnjo2NcQtnBwh5h42NjV8WXr3+uRMTE7xuoQOEvLcQCy/OIneAkPcWYndvLsDPNOM3oQcg0cLCwrevvvrqb3v8M//by59nzanQA5Do7Nmzff39/T39tymVSglfPAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOOHqfuS33nrr4uXLly8NDg5qfMVofOnSpb9//PHHk6EHgoAuXLjw+6dPn+ZCvJ63W+I4fvzuu+9eCP1vKZGbd4hcvHjxT2+88cYfQ4+jE2fOnHnz7bff/nPocUjkJmTYRsgwgZBhAiHDBEKGCYQMEwgZJhAyTCBkmEDIMIGQYQIhwwRChgmEDBMIGSYQMkwgZJhAyDCBkGECIcMEQoYJhAwTCBkmEDJMIGSYQMgwgZBhAiHDBEKGCYQMEwgZJhAyTCBkmEDIMIGQYQIhwwRChgmEDBMIGSYQMkwgZJhAyDCBkGECIcMETyE3oyhKQw+iU2tra0noMSCgc+fO9Q8PD/8nTdMkVerLL78cOnv27O9C/1tKdCr0AHqpFfOHH37418HBwcHQY2nX8vLy+gcffPCvSqWyHnosAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQCD/BxTbdEHAKPlOAAAAAElFTkSuQmCC") cache.images.exclamation = b end)()
end

do
	networkClient:SetOutgoingKBPSLimit(0)
	for i, v in next, getconnections(localPlayer.Idled) do 
		v:Disable()
	end
end

local skyBoxes = {
	["purple clouds"] = {
		SkyboxLf = "rbxassetid://151165191",
		SkyboxBk = "rbxassetid://151165214",
		SkyboxDn = "rbxassetid://151165197",
		SkyboxFt = "rbxassetid://151165224",
		SkyboxRt = "rbxassetid://151165206",
		SkyboxUp = "rbxassetid://151165227",
	},
	["cloudy skies"] = {
		SkyboxLf = "rbxassetid://151165191",
		SkyboxBk = "rbxassetid://151165214",
		SkyboxDn = "rbxassetid://151165197",
		SkyboxFt = "rbxassetid://151165224",
		SkyboxRt = "rbxassetid://151165206",
		SkyboxUp = "rbxassetid://151165227",
	},
	["purple nebula"] = {
		SkyboxLf = "rbxassetid://159454286",
		SkyboxBk = "rbxassetid://159454299",
		SkyboxDn = "rbxassetid://159454296",
		SkyboxFt = "rbxassetid://159454293",
		SkyboxRt = "rbxassetid://159454300",
		SkyboxUp = "rbxassetid://159454288",
	},
	["purple and blue"] = {
		SkyboxLf = "rbxassetid://149397684",
		SkyboxBk = "rbxassetid://149397692",
		SkyboxDn = "rbxassetid://149397686",
		SkyboxFt = "rbxassetid://149397697",
		SkyboxRt = "rbxassetid://149397688",
		SkyboxUp = "rbxassetid://149397702",
	},
	["vivid Skies"] = {
		SkyboxLf = "rbxassetid://271042310",
		SkyboxBk = "rbxassetid://271042516",
		SkyboxDn = "rbxassetid://271077243",
		SkyboxFt = "rbxassetid://271042556",
		SkyboxRt = "rbxassetid://271042467",
		SkyboxUp = "rbxassetid://271077958",
	},
	["twighlight"] = {
		SkyboxLf = "rbxassetid://264909758",
		SkyboxBk = "rbxassetid://264908339",
		SkyboxDn = "rbxassetid://264907909",
		SkyboxFt = "rbxassetid://264909420",
		SkyboxRt = "rbxassetid://264908886",
		SkyboxUp = "rbxassetid://264907379",
	},
	["vaporwave"] = {
		SkyboxLf = "rbxassetid://1417494402",
		SkyboxBk = "rbxassetid://1417494030",
		SkyboxDn = "rbxassetid://1417494146",
		SkyboxFt = "rbxassetid://1417494253",
		SkyboxLf = "rbxassetid://1417494402",
		SkyboxRt = "rbxassetid://1417494499",
		SkyboxUp = "rbxassetid://1417494643",
	},
	["clouds"] = {
		SkyboxLf = "rbxassetid://570557620",
		SkyboxBk = "rbxassetid://570557514",
		SkyboxDn = "rbxassetid://570557775",
		SkyboxFt = "rbxassetid://570557559",
		SkyboxLf = "rbxassetid://570557620",
		SkyboxRt = "rbxassetid://570557672",
		SkyboxUp = "rbxassetid://570557727",
	},
	["night sky"] = {
		SkyboxBk = "rbxassetid://12064107",
		SkyboxDn = "rbxassetid://12064152",
		SkyboxFt = "rbxassetid://12064121",
		SkyboxLf = "rbxassetid://12063984",
		SkyboxRt = "rbxassetid://12064115",
		SkyboxUp = "rbxassetid://12064131"
	},
	["setting sun"] = {
		SkyboxBk = "rbxassetid://626460377",
		SkyboxDn = "rbxassetid://626460216",
		SkyboxFt = "rbxassetid://626460513",
		SkyboxLf = "rbxassetid://626473032",
		SkyboxRt = "rbxassetid://626458639",
		SkyboxUp = "rbxassetid://626460625"
	},
	["fade blue"] = {
		SkyboxBk = "rbxassetid://153695414",
		SkyboxDn = "rbxassetid://153695352",
		SkyboxFt = "rbxassetid://153695452",
		SkyboxLf = "rbxassetid://153695320",
		SkyboxRt = "rbxassetid://153695383",
		SkyboxUp = "rbxassetid://153695471"
	},
	["elegant morning"] = {
		SkyboxBk = "rbxassetid://153767241",
		SkyboxDn = "rbxassetid://153767216",
		SkyboxFt = "rbxassetid://153767266",
		SkyboxLf = "rbxassetid://153767200",
		SkyboxRt = "rbxassetid://153767231",
		SkyboxUp = "rbxassetid://153767288"
	},
	["neptune"] = {
		SkyboxBk = "rbxassetid://218955819",
		SkyboxDn = "rbxassetid://218953419",
		SkyboxFt = "rbxassetid://218954524",
		SkyboxLf = "rbxassetid://218958493",
		SkyboxRt = "rbxassetid://218957134",
		SkyboxUp = "rbxassetid://218950090"
	},
	["redshift"] = {
		SkyboxBk = "rbxassetid://401664839",
		SkyboxDn = "rbxassetid://401664862",
		SkyboxFt = "rbxassetid://401664960",
		SkyboxLf = "rbxassetid://401664881",
		SkyboxRt = "rbxassetid://401664901",
		SkyboxUp = "rbxassetid://401664936"
	},
	["aesthetic night"] = {
		SkyboxBk = "rbxassetid://1045964490",
		SkyboxDn = "rbxassetid://1045964368",
		SkyboxFt = "rbxassetid://1045964655",
		SkyboxLf = "rbxassetid://1045964655",
		SkyboxRt = "rbxassetid://1045964655",
		SkyboxUp = "rbxassetid://1045962969"
	}
}
local skyboxDropDown = {}
for i, v in next, (skyBoxes) do
	local okay = {i, i == "purple clouds" and true or false}
	skyboxDropDown[1 + #skyboxDropDown] = okay
end

local forcefieldanimations = {
    ["off"] = "rbxassetid://0",
    ["web"] = "rbxassetid://301464986",
    ["webbed"] = "rbxassetid://2179243880",
    ["scanning"] = "rbxassetid://5843010904",
	["pixelated"] = "rbxassetid://140652787",
    ["swirl"] = "rbxassetid://8133639623",
    ["checkerboard"] = "rbxassetid://5790215150",
    ["christmas"] = "rbxassetid://6853532738",
    ["player"] = "rbxassetid://4494641460",
    ["shield"] = "rbxassetid://361073795",
    ["dots"] = "rbxassetid://5830615971",
    ["bubbles"] = "rbxassetid://1461576423",
    ["matrix"] = "rbxassetid://10713189068",
    ["honeycomb"] = "rbxassetid://179898251",
    ["groove"] = "rbxassetid://10785404176",
    ["cloud"] = "rbxassetid://5176277457",
    ["sky"] = "rbxassetid://1494603972",
    ["smudge"] = "rbxassetid://6096634060",
    ["scrapes"] = "rbxassetid://6248583558",
    ["galaxy"] = "rbxassetid://1120738433",
    ["galaxies"] = "rbxassetid://5101923607",
    ["stars"] = "rbxassetid://598201818",
    ["rainbow"] = "rbxassetid://10037165803",
    ["wires"] = "rbxassetid://14127933",
    ["camo"] = "rbxassetid://3280937154",
    ["hexagon"] = "rbxassetid://6175083785",
    ["particles"] = "rbxassetid://1133822388",
    ["triangular"] = "rbxassetid://4504368932",
    ["wall"] = "rbxassetid://4271279"
}

local forcefieldAnimationsDropDown = {}
for i, v in next, (forcefieldanimations) do
	local okay = {i, i == "off" and true or false}
	forcefieldAnimationsDropDown[1 + #forcefieldAnimationsDropDown] = okay
end

local rawHitSounds = {
    ["AR2 Head"] = "2062016772",
    ["AR2 Body"] = "2062015952",
    ["AR2 Limb"] = "6659353525",
    ["BB HitM"] = "4645745735",
    ["BB Kill"] = "2636743632",
    ["PD Head"] = "4585351098",
    ["PD Body"] = "4585364605",
    ["Neverlose"] = "8726881116",
    ["Gamesense"] = "4817809188",
    ["Baimware"] = "3124331820",
    ["Steve"] = "4965083997",
    ["Skeet"] = "4753603610",
    ["Body"] = "3213738472",
    ["Ding"] = "7149516994",
    ["Mario"] = "2815207981",
    ["Mario 2"] = "5709456554",
    ["Minecraft"] = "6361963422",
    ["Among Us"] = "5700183626",
    ["Button"] = "12221967",
    ["Oof"] = "4792539171",
    ["Osu"] = "7149919358",
    ["Osu Combobreak"] = "3547118594",
    ["Bambi"] = "8437203821",
    ["Click"] = "8053704437",
    ["Snow"] = "6455527632",
    ["Stone"] = "3581383408",
    ["Rust"] = "1255040462",
    ["Splat"] = "12222152",
    ["Bell"] = "6534947240",
    ["Slime"] = "6916371803",
    ["Saber"] = "8415678813",
    ["Bat"] = "3333907347",
    ["Bubble"] = "6534947588",
    ["Pick"] = "1347140027",
    ["Pop"] = "198598793",
    ["EmptyGun"] = "203691822",
    ["Bamboo"] = "3769434519",
    ["Stomp"] = "200632875",
    ["Bag"]  = "364942410",
    ["HitMarker"] = "8543972310",
    ["LaserSlash"] = "199145497",
    ["RailGunF"] = "199145534",
    ["Bruh"] = "4275842574", 
    ["Crit"] = "296102734",
    ["Bonk"] = "3765689841",
    ["Clink"] = "711751971",
    ["CoD"] = "160432334",
    ["Lazer Beam"] = "130791043",
    ["Windows XP Error"] = "160715357",
    ["Windows XP Ding"] = "489390072",
    ["HL Med Kit"] = "4720445506",
    ["HL Door"] = "4996094887",
    ["HL Crowbar"] = "546410481",
    ["HL Revolver"] = "1678424590",
    ["HL Elevator"] = "237877850",
    ["TF2 HitSound"] = "3455144981",
    ["TF2 Squasher"] = "3466981613",
    ["TF2 Retro"] = "3466984142",
    ["TF2 Space"] = "3466982899",
    ["TF2 Vortex"] = "3466980212",
    ["TF2 Beepo"] = "3466987025",
    ["TF2 Bat"] = "3333907347",
    ["TF2 Pow"] = "679798995",
    ["TF2 You Suck"] = "1058417264",
    ["Quake Hitsound"] = "4868633804",
    ["Fart"] = "131314452",
    ["Fart2"] = "6367774932",
    ["FortniteGuns"] = "3008769599",
    ["Crickets"] = "2101148",
    ["ScreamingKid"] = "5980352978",
    ["BitchBot"] = "5709456554",
    ["BitchBot Head"] = "5043539486",
    ["BitchBot Body"] = "3744371342",
    ["Minecraft Experience "] = "1053296915",
    ["BameWare"] = "7898991882",
    ["Fatality"] = "7347423703",
    ["Fatality MKX"] = "6721975770",
    ["Fatality Original"] = "158012252",
    ["Doublekill 1"] = "1950547222",
    ["Doublekill 2"] = "130819307",
    ["Killing Spree 1"] = "723054723",
    ["Killing Spree 2"] = "937898383",
    ["Sit Dog"] = "7349055654",
    ["Csgo"] = "7269900245",
    ["Bop"] = "8829676038",
    ["Grenade Hit"] = "5684745272",
    ["KillTrocity"] = "6818544945",
    ["Double Kill"] = "6818527307",
    ["Triple kill"] = "6818526855",
    ["Over Kill"] = "6818526995",
    ["Kill Tacular"] = "6818527070",
    ["Kill Imanjaro"] = "6818527258",
    ["Kill Tastrophe"] = "6818526916",
    ["Kill Pocalypse"] = "6818527144",
    ["Kill Ionaire"] = "6818527200",
    ["Killing Spree"] = "6822465178",
    ["Killing Frenzy"] = "6822465319",
    ["Carrier Kill"] = "7139067012",
    ["Clutch Kill"] = "7379106527",
    ["Taco Bell"] = "5689199277",
    ["Kombat"] = "8527433497",
    ["Headshot"] = "8418469749",
    ["Elevator"] = "8322227967"
}

local cheatHitSounds = {}
for i, v in next, rawHitSounds do
	cheatHitSounds[string.lower(i)] = v
end

local cheatHitSoundsDropDown = {{"custom", true}}
for i, v in next, cheatHitSounds do
	cheatHitSoundsDropDown[1 + #cheatHitSoundsDropDown] = {i, false}
end

-- main ui setup
local ui
local uiflags
-- filesystem setup
local cheat_path                        = "vader haxx"
local game_path                         = "phantom forces"
local config_path                       = "configurations"
local scripts_path                      = "scripts"

do
	local workspace                     = game:GetService("Workspace")
	local camera			            = workspace.CurrentCamera
	local stats                         = game:GetService("Stats")
	local runservice                    = game:GetService("RunService")
	local players                       = game:GetService("Players")
	local localplayer                   = players.LocalPlayer
	local mouse                         = localplayer:GetMouse()
	local httpservice                   = game:GetService("HttpService")

	-- initiate ui
	do
		ui = uilibrary:start({
			size = Vector2.new(560, 740),
			name = "vader haxx",
			accent = Color3.fromRGB(255, 200, 69),
			colors = {
				a = Color3.fromRGB(0, 0, 0),
				b = Color3.fromRGB(56, 56, 56),
				c = Color3.fromRGB(46, 46, 46),
				d = Color3.fromRGB(12, 12, 12),
				e = Color3.fromRGB(21, 21, 21),
				f = Color3.fromRGB(84, 84, 84),
				g = Color3.fromRGB(54, 54, 54),
			},
			tabs = {
				"legit",
				"rage",
				"esp",
				"visuals",
				"misc",
				"players",
				"config",
			}
		})
		ui:createnotification({text = "initializing...", lifetime = 3, priority = 0})
	end

	do
		if not isfolder(cheat_path) then
			makefolder(cheat_path)
		end

		if not isfolder(cheat_path .. "/" .. game_path) then
			makefolder(cheat_path .. "/" .. game_path)
		end

		if not isfolder(cheat_path .. "/" .. game_path .. "/" .. config_path) then
			makefolder(cheat_path .. "/" .. game_path .. "/" .. config_path)
		end

		if not isfolder(cheat_path .. "/" .. game_path .. "/" .. scripts_path) then
			makefolder(cheat_path .. "/" .. game_path .. "/" .. scripts_path)
		end

		if not isfile(cheat_path .. "/" .. game_path .. "/" .. "custom chat spammer messages.txt") then
			writefile(cheat_path .. "/" .. game_path .. "/" .. "custom chat spammer messages.txt", "hey user, edit your custom messages or dont use it at all\ndear user, set up your custom messages or dont use it")
		end

		if not isfile(cheat_path .. "/" .. game_path .. "/" .. "custom kill messages.txt") then
			writefile(cheat_path .. "/" .. game_path .. "/" .. "custom kill messages.txt", "hey user, edit your custom kill messages or dont use it at all\ndear user, set up your custom kill messages or dont use it")
		end

		if not isfile(cheat_path .. "/" .. game_path .. "/" .. "relations.json") then
			writefile(cheat_path .. "/" .. game_path .. "/" .. "relations.json", json.encode({}))
		end

		function ui.getconfigs()
			local Configs = {}
			local CfgFolder = cheat_path .. "/" .. game_path .. "/" .. config_path
			for i, v in next, (listfiles(CfgFolder)) do
				Configs[1 + #Configs] = {string.sub(v, #CfgFolder + 2, 256):sub(0, -5), (#Configs == 0) and true or false}
			end
			return Configs
		end
	end
	
	-- sub panel setup
	do
		ui:createsubsection({tab = "legit", name = "aim assist", length = 1, side = 1})
		ui:createsubsection({tab = "legit", name = "trigger bot", length = 0.5, side = 2})
		ui:createsubsection({tab = "legit", name = "bullet redirection", length = 0.5, side = 2}) 
		
		ui:createsubsection({tab = "rage", name = "aimbot", length = 0.315, side = 1})
		ui:createsubsection({tab = "rage", name = "hack vs. hack", length = 0.685, side = 1})
		ui:createsubsection({tab = "rage", name = "anti aimbot", length = 0.64, side = 2})
		ui:createsubsection({tab = "rage", name = "misc", length = 0.36, side = 2})

		ui:createsubsection({tab = "esp", name = "enemy", length = 0.7, side = 1})
		ui:createsubsection({tab = "esp", name = "dropped", length = 0.3, side = 1})
		ui:createsubsection({tab = "esp", name = "team", length = 0.45, side = 2})
		ui:createsubsection({tab = "esp", name = "esp settings", length = 0.55, side = 2})

		ui:createsubsection({tab = "visuals", name = "local", length = 0.6, side = 1})
		ui:createsubsection({tab = "visuals", name = "viewmodel", length = 0.4, side = 1})
		ui:createsubsection({tab = "visuals", name = "camera", length = 0.43, side = 2})
		ui:createsubsection({tab = "visuals", name = "world", length = 0.57, side = 2})

		ui:createsubsection({tab = "misc", name = "movement", length = 0.6, side = 1})
		ui:createsubsection({tab = "misc", name = "weapon modifications", length = 0.4, side = 1})
		ui:createsubsection({tab = "misc", name = "extra", length = 1, side = 2})

		ui:createsubsection({tab = "config", name = "other", length = 0.26, side = 1})
		ui:createsubsection({tab = "config", name = "ui", length = 0.48, side = 1})
		ui:createsubsection({tab = "config", name = "extra", length = 0.26, side = 1})
		ui:createsubsection({tab = "config", name = "scripts", length = 1, side = 2})
	end

	-- feature set up
	do
		-- legit features
		do
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "enabled", flag = "legit_aimassist", value = false, tooltip = "master switch for aim assist, helps with aiming by moving your mouse for you based on the below settings"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "fov", suffix = "°", flag = "legit_aimassistfov", value = 20, minimum = 0, maximum = 90, tooltip = "the maximum fov of the aim assist, enemies within this fov will be considered to be aimed at by the aim assist"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "speed", suffix = "%", flag = "legit_aimassistsmoothing", value = 50, minimum = 1, maximum = 100, custom = {["100"] = "inst."}, tooltip = "how fast the assist will help aim at the target"})
			ui:createdropdown({tab = "legit", subsection = "aim assist", name = "smoothing", flag = "legit_aimassistsmoothingtype", values = {{"linear", true}, {"exponential", false}}, multichoice = false, tooltip = "the type of smoothing of the aim aim assist"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "randomisation", flag = "legit_aimassistrandomisation", value = 5, minimum = 0, maximum = 20, custom = {["0"] = "off"}, tooltip = "the randomisation of where the aim assist will be trying to aim at"})
			--ui:createslider({tab = "legit", subsection = "aim assist", name = "deadzone fov", suffix = "/10°", flag = "legit_aimassistdeadzonefov", value = 1, minimum = 0, maximum = 50, custom = {["0"] = "off"}, tooltip = "the deadzone of the aim assist"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "enemy switching delay", suffix = "ms", flag = "legit_aimassistswitchdelay", value = 100, minimum = 0, maximum = 2000, custom = {["0"] = "off"}, tooltip = "how long the aim assist will wait before locking onto a new player"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "maximum lock-on time", suffix = "ms", flag = "legit_aimassistlockontime", value = 1000, minimum = 1, maximum = 2001, custom = {["2001"] = "inf"}, tooltip = "how long the aim assist will aim at a single target"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "accuracy", suffix = "%", flag = "legit_aimassistaccuracy", value = 90, minimum = 0, maximum = 100, tooltip = "the chance that the hitscan priority will be considered before anything else"})
			ui:createdropdown({tab = "legit", subsection = "aim assist", name = "activation", flag = "legit_aimassistactivation", values = {{"mouse 1", true}, {"mouse 2", false}, {"always", false}}, multichoice = false, tooltip = "the aim assist will be actively aiming whilst this action is performed"})
			ui:createdropdown({tab = "legit", subsection = "aim assist", name = "target priority", flag = "legit_aimassisttargpriority", values = {{"closest", true}, {"enemy look direction", false}}, multichoice = false, tooltip = "the player that the aim assist will consider aiming at first"})
			ui:createdropdown({tab = "legit", subsection = "aim assist", name = "hitscan priority", flag = "legit_aimassistpriority", values = {{"closest", true}, {"head", false}, {"body", false}}, multichoice = false, tooltip = "the hitbox that the aim assist will consider aiming at first"})
			ui:createdropdown({tab = "legit", subsection = "aim assist", name = "hitscan points", flag = "legit_aimassistpoints", values = {{"head", true}, {"body", true}, {"arms", false}, {"legs", false}}, multichoice = true, tooltip = "the hitboxes that the aim assist will consider at all"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "require mouse movement", flag = "legit_aimonmousemove", value = false, tooltip = "requires you to be moving your mouse for the aim assist to assist your aim"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "require mouse nearing enemy", flag = "legit_aimonmousemoveatenemy", value = false, tooltip = "requires you to be moving your mouse towards the enemy for the aim assist to assist your aim"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "use barrel fov", flag = "legit_aimassistbarrelfov", value = false, tooltip = "bases fov from your barrel direction instead of camera direction"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "adjust for bullet drop", flag = "legit_bulletcompensation", value = false, tooltip = "will predict the bullet drop to a target once found and will compensate for it"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "drop prediction inaccuracy", suffix = "%", flag = "legit_bulletdropaccuracy", value = 90, minimum = 0, maximum = 100, tooltip = "how accurate the bullet drop adjustment is"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "adjust for target movement", flag = "legit_movementcompensation", value = false, tooltip = "will predict the movement of the target and will compensate for it"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "target prediction inaccuracy", suffix = "%", flag = "legit_movementtaccuracy", value = 80, minimum = 0, maximum = 100, tooltip = "how accurate the movement prediction adjustment is"})
			ui:createtoggle({tab = "legit", subsection = "aim assist", name = "adjust for barrel angle", flag = "legit_barrelcompensation", value = false, tooltip = "will predict where the bullet will be based off of your barrel and will assist you in pointing your barrel towards the enemy, helps with quickscoping and recoil control"})
			ui:createslider({tab = "legit", subsection = "aim assist", name = "barrel adjustment inaccuracy", suffix = "%", flag = "legit_barrelaccuracy", value = 60, minimum = 0, maximum = 100, tooltip = "how accurate the barrel angle adjustment is"})

			ui:createtoggle({tab = "legit", subsection = "bullet redirection", name = "silent aim", flag = "legit_bulletredirection", value = false, tooltip = "master switch for silent aim, helps with aiming by automatically redirecting bullets based on the below settings"})
			ui:createslider({tab = "legit", subsection = "bullet redirection", name = "silent aim fov", suffix = "°", flag = "legit_bulletredirectionfov", value = 15, minimum = 0, maximum = 90, tooltip = "the maximum fov of the silent aim, enemies within this fov will be considered and aimed at by the silent aim"})
			ui:createslider({tab = "legit", subsection = "bullet redirection", name = "spread", suffix = "/10st", flag = "legit_bulletredirectiondeviation", value = 8, minimum = 0, maximum = 80, custom = {["0"] = "off"}, tooltip = "shoots around your enemy rather than the direct center of the hitbox to prevent shooting in a perfect line every time which can look blatant. the slider will determine (in studs) how much spread there will be at exactly 100 studs, scales linearly with distance. at 200 studs the amount of spread doubles and at 50 studs the amount is halved"})
			ui:createslider({tab = "legit", subsection = "bullet redirection", name = "hit chance", suffix = "%", flag = "legit_bulletredirectionhitchance", value = 30, minimum = 0, maximum = 100, tooltip = "the chance that the silent aim will attempt to redirect a bullet"})
			ui:createslider({tab = "legit", subsection = "bullet redirection", name = "accuracy", suffix = "%", flag = "legit_bulletredirectionaccuracy", value = 70, minimum = 0, maximum = 100, tooltip = "the chance that the hitscan priority will be considered before anything else"})
			ui:createdropdown({tab = "legit", subsection = "bullet redirection", name = "hitscan priority", flag = "legit_bulletredirectionpriority", values = {{"closest", false}, {"head", false}, {"body", false}}, multichoice = false, tooltip = "the hitbox that the silent aim will consider aiming at first"})
			ui:createdropdown({tab = "legit", subsection = "bullet redirection", name = "hitscan points", flag = "legit_bulletredirectionpoints", values = {{"head", false}, {"body", false}, {"arms", false}, {"legs", false}}, multichoice = true, tooltip = "the hitboxes that the silent aim will consider at all "})
			ui:createtoggle({tab = "legit", subsection = "bullet redirection", name = "use barrel fov", flag = "legit_silentbarrelfov", value = false, tooltip = "bases fov from your barrel instead of camera"})
			ui:createtoggle({tab = "legit", subsection = "bullet redirection", name = "auto wallbang", flag = "legit_bulletredirectionwallbang", value = false, tooltip = "will target enemies that can be wallbanged"})
			--ui:createtoggle({tab = "legit", subsection = "bullet redirection", name = "instant hit", flag = "legit_silentinstanthit", value = false, tooltip = "instantly hits your shots. not garunteed to be undetected"})

			ui:createtoggle({tab = "legit", subsection = "trigger bot", name = "enabled", flag = "legit_triggerbot", value = false, tooltip = "master switch for trigger bot, helps with shooting by automatically clicking when an enemy intersects your bullet path"})
			ui:createkeybind({tab = "legit", subsection = "trigger bot", object = "enabled", name = "trigger bot key", flag = "legit_triggerbotkey", parentflag = "legit_triggerbot", value = Enum.KeyCode.M})
			ui:createslider({tab = "legit", subsection = "trigger bot", name = "reaction time", suffix = "ms", flag = "legit_triggerbotspeed", value = 120, minimum = 0, maximum = 400, custom = {["0"] = "off"}, tooltip = "how long an enemy must intersect your bullet path before automatically clicking"})
			ui:createdropdown({tab = "legit", subsection = "trigger bot", name = "triggerbot hitboxes", flag = "legit_triggerbotpoints", values = {{"head", true}, {"body", true}, {"arms", false}, {"legs", false}}, multichoice = true, tooltip = "the hitboxes that the triggerbot will automatically click on"})
			ui:createtoggle({tab = "legit", subsection = "trigger bot", name = "auto wallbang", flag = "legit_triggerbotautowall", value = false, tooltip = "will automatically click when someone can be wallbanged by your bullet path"})
			ui:createtoggle({tab = "legit", subsection = "trigger bot", name = "magnet triggerbot", flag = "legit_magnet", value = false, tooltip = "master switch for the magnet, helps with aiming by applying a custom fov, smoothing and hitscan priority to the aim assist on triggerbot keybind"})
			ui:createslider({tab = "legit", subsection = "trigger bot", name = "magnet fov", suffix = "°", flag = "legit_magnetfov", value = 80, minimum = 0, maximum = 180, tooltip = "the maximum fov of the aim assist when the magnet triggerbot is active"})
			ui:createslider({tab = "legit", subsection = "trigger bot", name = "magnet speed", suffix = "%", flag = "legit_magnetsmoothing", value = 10, minimum = 0, maximum = 100, tooltip = "the smoothness of the aim assist when the magnet triggerbot is active"})
			ui:createdropdown({tab = "legit", subsection = "trigger bot", name = "magnet priority", flag = "legit_magnetnpriority", values = {{"closest", true}, {"head", false}, {"body", false}}, multichoice = false, tooltip = "the hitscan priority of the aim assist when the magnet triggerbot is active"})
		end

		-- rage features
		do
			ui:createtoggle({tab = "rage", subsection = "aimbot", name = "enabled", flag = "rage_enabled", value = false, tooltip = "master switch for the aimbot, helps with aiming by instantly aiming at an enemy once they are available to be aimed at and hit"})
			ui:createkeybind({tab = "rage", subsection = "aimbot", object = "enabled", name = "enabled key", flag = "rage_enabledkey", parentflag = "rage_enabled", value = Enum.KeyCode.E})
			ui:createtoggle({tab = "rage", subsection = "aimbot", name = "silent aim", flag = "rage_silentaim", value = false, tooltip = "the aimbot will not be locally visible"})
			ui:createtoggle({tab = "rage", subsection = "aimbot", name = "rotate viewmodel", flag = "rage_rotateviewmodel", value = false, tooltip = "rotates the viewmodel to point towards where the aimbot is aiming at"})
			ui:createslider({tab = "rage", subsection = "aimbot", name = "aimbot fov", suffix = "°", flag = "rage_aimbotfov", value = 90, minimum = 1, maximum = 181, custom = {["181"] = "ign."}, tooltip = "the maximum fov of the aimbot, all enemies within this fov will be considered"})
			ui:createslider({tab = "rage", subsection = "aimbot", name = "autowall fps", flag = "rage_autowallfps", value = 30, minimum = 0, maximum = 30, tooltip = "determines the accuracy of the autowall. lower values can increase performance but can decrease quality"})
			ui:createtoggle({tab = "rage", subsection = "aimbot", name = "auto shoot", flag = "rage_autofire", value = false, tooltip = "the aimbot will automatically shoot for you once it starts aiming"})
			ui:createtoggle({tab = "rage", subsection = "aimbot", name = "auto wall", flag = "rage_autowall", value = false, tooltip = "the aimbot will consider enemies that can be wallbanged"})
			ui:createdropdown({tab = "rage", subsection = "aimbot", name = "hitscan priority", flag = "rage_hitscanpriority", values = {{"head", true}, {"torso", false}}, multichoice = false, tooltip = "the hitbox that the aimbot will shoot at"})

			ui:createtoggle({tab = "rage", subsection = "misc", name = "damage prediction", flag = "rage_damagepred", value = false, tooltip = "the aimbot will ignore a player after attempting to deal fatal damage until after it is confirmed that attempting to deal fatal damage has failed to kill them, useful for conserving ammo"})
			-- rage_firepositionscanning
			-- rage_firepositionscanningradius
			ui:createtoggle({tab = "rage", subsection = "misc", name = "tp scanning", flag = "rage_firepositionscanning", value = false, tooltip = "the aimbot will scan for the best position to shoot the enemy from, teleport you there, shoot, and then teleport you back to your original position", detected = true})
			ui:createslider({tab = "rage", subsection = "misc", name = "tp scanning radius", suffix = "st", flag = "rage_firepositionscanningradius", value = 12, minimum = 1, maximum = 100, tooltip = "how close an enemy must be to you for the tp scanning to activate"})	
			ui:createtoggle({tab = "rage", subsection = "misc", name = "knife bot", flag = "rage_knifebot", value = false, tooltip = "the aimbot will aim with the knife, requires the aimbot to be enabled and its keybind to be active, reuses the aimbot fov"})
			ui:createkeybind({tab = "rage", subsection = "misc", object = "knife bot", name = "knife key", flag = "rage_knifekey", parentflag = "rage_knifebot", value = Enum.KeyCode.F})
			ui:createtoggle({tab = "rage", subsection = "misc", name = "disregard walls on knife", flag = "rage_knifebotignorewalls", value = false, tooltip = "the aimbot will aim with the knife even if an enemy is behind a wall"})
			ui:createdropdown({tab = "rage", subsection = "misc", name = "knife bot type", flag = "rage_knifebottype", values = {{"aura", true}, {"infinite aura", false}}, multichoice = false, tooltip = "aura targets everyone within the knife range, super teleports to the enemy if possible to do so and infinite aura utilizes artificial intelligence to teleport you to the enemy resulting in a much longer knife range"})
			ui:createslider({tab = "rage", subsection = "misc", name = "knife bot radius", suffix = "st", flag = "rage_knifeshift", value = 12, minimum = 1, maximum = 20, tooltip = "how close an enemy must be to you for the knife bot to stab them automatically"})
			ui:createtoggle({tab = "rage", subsection = "misc", name = "teleport grenades", flag = "rage_nadetp", value = false, tooltip = "requires speed check bypass, teleports grenades according to the below settings"})
			ui:createtoggle({tab = "rage", subsection = "misc", name = "cancel grenades", flag = "rage_nadecanceltp", value = false, tooltip = "will return a grenade if a valid target is not found"})
			ui:createdropdown({tab = "rage", subsection = "misc", name = "grenade target selection", flag = "rage_nadetptype", values = {{"closest to crosshair", true}, {"closest to player", false}}, multichoice = false, tooltip = "closest to crosshair teleports grenades to the closest enemy to your crosshair. closest to player teleports grenades to the enemy closest to you"})
			
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "teleporting", flag = "rage_repupdatecontrol", value = false, tooltip = "the aimbot and knife bot may teleport you to increase the possibilites of aiming at an enemy, highly recommended for hack versus hack as it greatly increases the effectiveness of the aimbot", detected = false})
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "anti aimbot correction", flag = "rage_resolver", value = false, tooltip = "automatically corrects player model interpolation that has desynced from their true position allowing you to see exactly where they are according to the game. note that this will allow the aimbot to attempt resolving anybody using fake position"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "maximum hitscanning points", flag = "rage_maxawalls", value = 64, minimum = 8, maximum = 200, tooltip = "the amount of points the ragebot will consider at a time, higher values decrease fps but make the aimbot more thorough"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "sorting selection", flag = "rage_sorting", values = {{"favor high damage", true}, {"favor fewer movements", false}, {"favor safety", false}}, multichoice = false, tooltip = "the aimbot will choose from where to shoot the enemy which favors this option best, favor high damage is better for hurting enemies more, favor fewer movments is better for preventing ping spikes and teleporting as little as possible"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "hitscan selection", flag = "rage_hitscanselection", values = {{"nearest", false}, {"clamping", false}, {"enemy move", false}, {"local move", false}, {"out of cover", false}}, multichoice = true, tooltip = "the autowall hitscan points that the aimbot will force. nearest will forcefully scan the nearest origin to the enemy, recommended for use with enemy position pathfinding. clamping will forcefully scan origins that are more in the direction of the enemy than not. enemy move will forcefully scan origins that are the same direction as the enemies movement. local move will forcefully scan origins that are the same direction as your movement, recommended for aggressive play"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "hitscan selection bias", suffix = "%", flag = "rage_hitscanselectbias", value = 25, minimum = 1, maximum = 50, tooltip = "the strength of the bias for hitscan selection. for example, at 1%, nearest will only select the nearest 1% of origins and points, at 50%, it will only select from the nearest 50% of origins and points"})
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "autowall hitscan", flag = "rage_autowallhitscan", value = false, tooltip = "the aimbot will consider multiple spots from which it may attempt to shoot an enemy from from rather than just your camera"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "autowall hitscan points", flag = "rage_hitscanpoints", values = {{"cardinal", false}, {"random", false}, {"circle", false}, {"corner", false}, {"snake", false}}, multichoice = true, tooltip = "the directions that the aimbot will consider in its autowall hitscan"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "autowall hitscan distance", suffix = "st", flag = "rage_hitscandistance", value = 60, minimum = 1, maximum = 400, tooltip = "the maximum distance the autowall hitscan will be from your camera in studs"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "autowall hitscan increments", flag = "rage_hitscanincrementdistance", value = 100, minimum = 1, maximum = 40, tooltip = "the amount of places in between 0 and your autowall hitscan distance that will be considered by the aimbot"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "autowall hitscan teleport threshold", suffix = "st", flag = "rage_hitscandistancebeforeteleport", value = 8, minimum = 1, maximum = 10, tooltip = "the maximum distance the autowall hitscan will be from your camera in studs before teleporting, higher values may miss but can shoot more often. recommedned to keep it at 8-9 for hvh and 4 or under to garuntee being undetected"})
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "path-finding assisted", flag = "rage_pathfinded", value = false, tooltip = "may lower fps dramatically but will allow the autowall hitscan to use artificial intelligence to more efficiently choose extra origination points, works best on maps with plenty of open space but with obstacles in the way"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "path-finding hitscan points", flag = "rage_pathfindingpoints", values = {{"enemy position", false}, {"cardinal", false}}, multichoice = true, tooltip = "the extra origination points that the aimbot will try to pathfind, cardinals help the autowall hitscan cardinal mode to find more points to shoot from and enemy positions pathfinds right up to the enemy, nearly garunteeing a kill as you are teleporting next to them"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "path-finding processing time", suffix = "%", flag = "rage_pathfindingtime", value = 100, minimum = 10, maximum = 1000, tooltip = "multiples how much time the pathfind will spend searching. higher than 100% will decrease fps but will give further reach. lower than 100% will increase fps but will give less reach"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "path-finding node size", suffix = "st", flag = "rage_pathfindingnodesize", value = 4, minimum = 1, maximum = 20, tooltip = "how large each step of the pathfinding will be, higher values are faster but less likely to successfully find a path"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "path-finding algorithim", flag = "rage_pathfindingtype", values = {{"a*", false}, {"bfs", false}}, multichoice = true, tooltip = "the search algorithim the aimbot will use"})
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "wait for enemy to load", flag = "rage_waitforspawn", value = false, tooltip = "the aimbot will only consider an enemy once they have fully spawned, doesnt kill as fast but misses less"})
			ui:createtoggle({tab = "rage", subsection = "hack vs. hack", name = "hitbox shifting", flag = "rage_multipoint", value = false, tooltip = "the aimbot will attempt to shift hitboxes around to increase the possibilities of aiming at an enemy"})
			ui:createdropdown({tab = "rage", subsection = "hack vs. hack", name = "hitbox shifting points", flag = "rage_multipointpoints", values = {{"cardinal", false}, {"random", false}}, multichoice = true, tooltip = "the directions that the hitboxes may be shifted in"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "hitbox shifting distance", suffix = "st", flag = "rage_multipointdistance", value = 8, minimum = 1, maximum = 12, tooltip = "the distance in studs that each hitbox is shifted by, higher values increase the chance of missing but can be shot at more often"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "hitbox shifting increments", flag = "rage_multipointincrment", value = 4, minimum = 1, maximum = 12, tooltip = "the amount of places in between 0 and your hitbox shifting distance that will be considered by the aimbot"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "maximum backtrack", suffix = "ms", flag = "rage_maxbacktrack", custom = {["0"] = "off"}, value = 1000, minimum = 0, maximum = 3000, tooltip = "the window of time for the aimbot to consider shooting at previous positions. higher values increase the chance of missing"})
			ui:createslider({tab = "rage", subsection = "hack vs. hack", name = "backtrack samples", flag = "rage_backtracksamples", value = 4, minimum = 1, maximum = 24, tooltip = "the amount of backtrack points that will be sampled at a time, increases how thorough the aimbot is in finding a target but can decrease fps"})
			
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "enabled", flag = "rage_antiaim", value = false, tooltip = "master switch for the anti aim, cosmetic effect"})
			ui:createdropdown({tab = "rage", subsection = "anti aimbot", name = "pitch", flag = "rage_antiaimpitch", values = {{"off", true}, {"up", false}, {"zero", false}, {"down", false}, {"default", false}, {"default up", false}, {"45 up", false}, {"45 down", false}, {"random", false}, {"bob", false}, {"roll forward", false}, {"roll backward", false}, {"shaky", false}}, multichoice = false, tooltip = "forces your player to look at a certain level"})
			ui:createdropdown({tab = "rage", subsection = "anti aimbot", name = "yaw", flag = "rage_antiaimyaw", values = {{"off", true}, {"forward", false}, {"backward", false}, {"random", false}, {"spin", false}, {"sway spin", false}, {"cycle spin", false}, {"robotic spin", false}, {"glitch spin", false}}, multichoice = false, tooltip = "forces your player to look at a certain yaw angle"})
			ui:createslider({tab = "rage", subsection = "anti aimbot", name = "yaw angle", suffix = "°", flag = "rage_antiaimyawdeg", value = 0, minimum = 0, maximum = 360 * 8, tooltip = "fine tunes the yaw option"})
			ui:createdropdown({tab = "rage", subsection = "anti aimbot", name = "yaw jitter", flag = "rage_antiaimyawjitter", values = {{"off", true}, {"step", false}, {"random", false}}, multichoice = false, tooltip = "adds jittering to the yaw option"})
			ui:createslider({tab = "rage", subsection = "anti aimbot", name = "yaw jitter angle", suffix = "°", flag = "rage_antiaimyawjitterdeg", value = 0, minimum = 0, maximum = 360 * 8, tooltip = "fine tunes the jittering option"})
			ui:createdropdown({tab = "rage", subsection = "anti aimbot", name = "force stance", flag = "rage_antiaimforcestance", values = {{"off", true}, {"stand", false}, {"crouch", false}, {"prone", false}}, multichoice = false, tooltip = "forces your player to assume the following stance"})
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "lower arms", flag = "rage_lowerarms", value = false, tooltip = "forces the sprinting state for your player model"})
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "tilt neck", flag = "rage_necktilt", value = false, tooltip = "forces the aiming state for your player model"})
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "fake position", flag = "rage_desync", value = false, tooltip = "will cause the server to report incorrect data to other players on where you are, heavily limits everyone else's ability to hit you. disables teleporting and fire rate modification"})
			ui:createslider({tab = "rage", subsection = "anti aimbot", name = "maximum fake position", suffix = "st", flag = "rage_desyncst", value = 64, minimum = 12, maximum = 80, tooltip = "the limit of how incorrect the data on where you are may be"})
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "instant fake flick", flag = "rage_instantdesync", value = false, tooltip = "some cheats may struggle to hit fake position more with this enabled"})
			ui:createtoggle({tab = "rage", subsection = "anti aimbot", name = "spawn protection", flag = "spawn_protection", values = false, tooltip = "This will enable spawn protection."})
			ui:createslider({tab = "rage", subsection = "anti aimbot", name = "spawn protection duration", flag = "spawn_protection_duration", value = 2, minimum = 1, maximum = 10, tooltip = "This will set the spawn protection duration."})
		end

		-- esp features
		do
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "enabled", flag = "enemy_esp", value = false, tooltip = "enables enemy esp"})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "bounding box", flag = "enemy_box", value = false, tooltip = "shows enemy boxes"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "bounding box", name = "box", flag = "enemy_boxcolor", color = Color3.new(1, 0, 0)})
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "filled bounding box", flag = "enemy_filledbox", value = false, tooltip = "filles enemy boxes"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "filled bounding box", name = "filled box", flag = "enemy_filledboxcolor", color = Color3.new(1, 0, 0), transparency = 0.8})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "health bar", flag = "enemy_healthbar", value = false, tooltip = "shows enemy health bars"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "health bar", name = "low health", flag = "enemy_lowhealth", color = Color3.fromRGB(255, 100, 100)})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "health bar", name = "full health", flag = "enemy_fullhealth", color = Color3.fromRGB(100, 255, 100)})
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "gradient health bar", flag = "enemy_gradienthealthbar", value = false, tooltip = "health bars will appear as gradients"})
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "health number", flag = "enemy_healthnumber", value = false, tooltip = "shows enemy health values"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "health number", name = "health number", flag = "enemy_healthnumbercolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "display name", flag = "enemy_name", value = false, tooltip = "shows enemy names"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "display name", name = "name", flag = "enemy_namecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "rank", flag = "enemy_rank", value = false, tooltip = "shows enemy ranks"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "rank", name = "rank", flag = "enemy_rankcolor", color = Color3.fromRGB(0, 219, 255)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "held weapon", flag = "enemy_heldweapon", value = false, tooltip = "shows the enemies held weapon"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "held weapon", name = "held weapon", flag = "enemy_heldweaponcolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "distance", flag = "enemy_distance", value = false, tooltip = "shows the distance to the enemy"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "distance", name = "distance", flag = "enemy_distancecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "exploiting", flag = "enemy_exploit", value = false, tooltip = "shows when a enemy is using a time exploit, usually involved with fire rate modification, teleporting and fake position. delta is the time difference between packet times, changes between this indicates tick shifting. delay is how far the packet time stamp is, consider this how time travelled someone is. choke is when the last packet was sent. typically indicating fake lag"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "exploiting", name = "exploit flag", flag = "enemy_exploitcolor", color = Color3.new(1, 0, 0)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "stance", flag = "enemy_stance", value = false, tooltip = "shows what stance a enemy has"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "stance", name = "exploit flag", flag = "enemy_stancecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "visible", flag = "enemy_visible", value = false, tooltip = "shows if a enemy is visible"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "visible", name = "visible flag", flag = "enemy_visiblecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "chams", flag = "enemy_chams", value = false, tooltip = "shows enemy chams"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "chams", name = "inner cham", flag = "enemy_innerchamcolor", color = Color3.fromRGB(100, 0, 0), transparency = 155/255})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "chams", name = "outer cham", flag = "enemy_outerchamcolor", color = Color3.fromRGB(255, 0, 0), transparency = 0})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "skeleton", flag = "enemy_skeleton", value = false, tooltip = "shows enemy skeletons"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "skeleton", name = "skeleton", flag = "enemy_skeletoncolor", color = Color3.fromRGB(236, 251, 136)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "snap lines", flag = "enemy_snaplines", value = false, tooltip = "shows enemy snap lines"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "snap lines", name = "snap line", flag = "enemy_snaplinescolor", color = Color3.new(1, 1, 1), transparency = 0})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "view angle", flag = "enemy_viewangle", value = false, tooltip = "shows a line in the direction the enemy is looking"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "view angle", name = "view angle", flag = "enemy_viewanglecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "head dot", flag = "enemy_headdot", value = false, tooltip = "shows a circle at which shooting at will result in a headshot"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "head dot", name = "head dot", flag = "enemy_headdotcolor", color = Color3.new(1, 0, 0)})

			ui:createtoggle({tab = "esp", subsection = "enemy", name = "out of view", flag = "enemy_oov", value = false, tooltip = "shows an arrow pointing towards an enemy if they are not in view"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "out of view", name = "arrow", flag = "enemy_oovcolor", color = Color3.new(1, 1, 1)})

			ui:createslider({tab = "esp", subsection = "enemy", name = "arrow distance", suffix = "%", flag = "arrow_distance", value = 30, minimum = 1, maximum = 100})
			ui:createslider({tab = "esp", subsection = "enemy", name = "arrow size", suffix = "%", flag = "arrow_size", value = 30, minimum = 1, maximum = 100})
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "dynamic arrow size", flag = "enemy_dynamicarrowsize", value = false, tooltip = "sizes the arrows based on distance"})
			ui:createtoggle({tab = "esp", subsection = "enemy", name = "show resolved flag", flag = "enemy_showresolvedflag", value = false, tooltip = "highlights enemies that have been successfully resolved"})
			ui:createcolorpicker({tab = "esp", subsection = "enemy", object = "show resolved flag", name = "resolved", flag = "enemy_resolvedflagcolor", color = Color3.fromRGB(237, 229, 62)})

			ui:createtoggle({tab = "esp", subsection = "dropped", name = "grenade warning", flag = "dropped_grenadewarning", value = false, tooltip = "predicts where nades will land and will display the danger level"})
			ui:createcolorpicker({tab = "esp", subsection = "dropped", object = "grenade warning", name = "low time", flag = "dropped_grenadehighcolor", color = Color3.fromRGB(255, 0, 0)})
			ui:createcolorpicker({tab = "esp", subsection = "dropped", object = "grenade warning", name = "high time", flag = "dropped_grenadelowcolor", color = Color3.fromRGB(0, 255, 0)})
			ui:createtoggle({tab = "esp", subsection = "dropped", name = "grenade lines", flag = "dropped_grenadelines", value = false, tooltip = "displays a line that maps how a grenade will travel"})
			ui:createcolorpicker({tab = "esp", subsection = "dropped", object = "grenade lines", name = "line start", flag = "dropped_grenadealinecolor", color = Color3.fromRGB(81, 75, 242)})
			ui:createcolorpicker({tab = "esp", subsection = "dropped", object = "grenade lines", name = "line end", flag = "dropped_grenadeblinecolor", color = Color3.fromRGB(237, 85, 103)})
			ui:createtoggle({tab = "esp", subsection = "dropped", name = "weapon names", flag = "dropped_weaponnames", value = false, tooltip = "shows weapon names"})
			ui:createcolorpicker({tab = "esp", subsection = "dropped", object = "weapon names", name = "weapon name", flag = "dropped_weaponnamecolor", color = Color3.fromRGB(255, 255, 255)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "enabled", flag = "team_esp", value = false, tooltip = "enables team esp"})

			ui:createtoggle({tab = "esp", subsection = "team", name = "bounding box", flag = "team_box", value = false, tooltip = "shows team boxes"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "bounding box", name = "box", flag = "team_boxcolor", color = Color3.new(0, 1, 0)})
			ui:createtoggle({tab = "esp", subsection = "team", name = "filled bounding box", flag = "team_filledbox", value = false, tooltip = "fills team boxes"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "filled bounding box", name = "filled box", flag = "team_filledboxcolor", color = Color3.new(0, 1, 0), transparency = 0.8})

			ui:createtoggle({tab = "esp", subsection = "team", name = "health bar", flag = "team_healthbar", value = false, tooltip = "shows team health bars"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "health bar", name = "low health", flag = "team_lowhealth", color = Color3.fromRGB(255, 100, 100)})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "health bar", name = "full health", flag = "team_fullhealth", color = Color3.fromRGB(100, 255, 100)})
			ui:createtoggle({tab = "esp", subsection = "team", name = "gradient health bar", flag = "team_gradienthealthbar", value = false, tooltip = "health bars will appear as gradients"})
			ui:createtoggle({tab = "esp", subsection = "team", name = "health number", flag = "team_healthnumber", value = false, tooltip = "shows enemy health values"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "health number", name = "health number", flag = "team_healthnumbercolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "display name", flag = "team_name", value = false, tooltip = "shows team names"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "display name", name = "name", flag = "team_namecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "rank", flag = "team_rank", value = false, tooltip = "shows team ranks"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "rank", name = "rank", flag = "team_rankcolor", color = Color3.fromRGB(0, 219, 255)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "held weapon", flag = "team_heldweapon", value = false, tooltip = "shows teammate held weapon"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "held weapon", name = "held weapon", flag = "team_heldweaponcolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "distance", flag = "team_distance", value = false, tooltip = "shows the distance to teammate"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "distance", name = "distance", flag = "team_distancecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "exploiting", flag = "team_exploit", value = false, tooltip = "shows when a enemy is using a time exploit, usually involved with fire rate modification, teleporting and fake position. delta is the time difference between packet times, changes between this indicates tick shifting. delay is how far the packet time stamp is, consider this how time travelled someone is. choke is when the last packet was sent. typically indicating fake lag"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "exploiting", name = "exploit flag", flag = "team_exploitcolor", color = Color3.new(1, 0, 0)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "stance", flag = "team_stance", value = false, tooltip = "shows what stance a teammate has"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "stance", name = "stance flag", flag = "team_stance", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "visible", flag = "team_visible", value = false, tooltip = "shows if a teammate is visible"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "visible", name = "visible flag", flag = "team_visiblecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "chams", flag = "team_chams", value = false, tooltip = "shows teammate chams"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "chams", name = "inner cham", flag = "team_innerchamcolor", color = Color3.fromRGB(0, 100, 0), transparency = 155/255})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "chams", name = "outer cham", flag = "team_outerchamcolor", color = Color3.fromRGB(0, 255, 0), transparency = 0})

			ui:createtoggle({tab = "esp", subsection = "team", name = "skeleton", flag = "team_skeleton", value = false, tooltip = "shows teammate skeletons"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "skeleton", name = "skeleton", flag = "team_skeletoncolor", color = Color3.fromRGB(236, 251, 136)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "view angle", flag = "team_viewangle", value = false, tooltip = "shows a line in the direction the teammate is looking"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "view angle", name = "view angle", flag = "team_viewanglecolor", color = Color3.new(1, 1, 1)})

			ui:createtoggle({tab = "esp", subsection = "team", name = "head dot", flag = "team_headdot", value = false, tooltip = "shows a circle at which shooting at will result in a headshot"})
			ui:createcolorpicker({tab = "esp", subsection = "team", object = "head dot", name = "head dot", flag = "team_headdotcolor", color = Color3.new(0, 1, 0)})

			ui:createslider({tab = "esp", subsection = "esp settings", name = "max hp visiblity cap", suffix = "hp", flag = "espsettings_maxhp", value = 98, minimum = 0, maximum = 100, tooltip = "the highest a health value can be before showing health numbers"})
			ui:createdropdown({tab = "esp", subsection = "esp settings", name = "text font", flag = "espsettings_font", values = {{"Plex", true}, {"Monospace", false}, {"System", false}, {"UI", false}}, multichoice = false, tooltip = "the font of the main text"})
			ui:createdropdown({tab = "esp", subsection = "esp settings", name = "text case", flag = "espsettings_case", values = {{"lowercase", false}, {"UPPERCASE", false}, {"Normal", true}}, multichoice = false, tooltip = "the case of the main text"})
			ui:createslider({tab = "esp", subsection = "esp settings", name = "text size", flag = "espsettings_size", value = 13, minimum = 1, maximum = 40, tooltip = "the size of the main text"})
			ui:createdropdown({tab = "esp", subsection = "esp settings", name = "flag text font", flag = "espsettings_flagfont", values = {{"Plex", true}, {"Monospace", false}, {"System", false}, {"UI", false}}, multichoice = false, tooltip = "the font of the main text"})
			ui:createdropdown({tab = "esp", subsection = "esp settings", name = "flag text case", flag = "espsettings_flagcase", values = {{"lowercase", false}, {"UPPERCASE", false}, {"Normal", true}}, multichoice = false, tooltip = "the case of the main text"})
			ui:createslider({tab = "esp", subsection = "esp settings", name = "flag text size", flag = "espsettings_flagsize", value = 13, minimum = 1, maximum = 40, tooltip = "the size of the main text"})
			ui:createtoggle({tab = "esp", subsection = "esp settings", name = "highlight aimbot target", flag = "espsettings_showaimbottarget", value = false, tooltip = "shows the current aimbot target"})
			ui:createcolorpicker({tab = "esp", subsection = "esp settings", object = "highlight aimbot target", name = "aimbot target", flag = "espsettings_showaimbottargetcolor", color = Color3.new(1, 0, 0)})
			ui:createtoggle({tab = "esp", subsection = "esp settings", name = "highlight friendlies", flag = "espsettings_showfriendlies", value = false, tooltip = "shows the current aimbot target"})
			ui:createcolorpicker({tab = "esp", subsection = "esp settings", object = "highlight friendlies", name = "friendlies", flag = "espsettings_showfriendliescolor", color = Color3.fromRGB(120, 189, 245)})
			ui:createtoggle({tab = "esp", subsection = "esp settings", name = "highlight priorities", flag = "espsettings_showpriorities", value = false, tooltip = "shows the current aimbot target"})
			ui:createcolorpicker({tab = "esp", subsection = "esp settings", object = "highlight priorities", name = "priorities", flag = "espsettings_showprioritiescolor", color = Color3.fromRGB(245, 239, 120)})
		end
		-- visual features
		do
			ui:createtoggle({tab = "visuals", subsection = "local", name = "arm chams", flag = "visuals_armchams", value = false, tooltip = "changes the appearance of your arms"})
			ui:createcolorpicker({tab = "visuals", subsection = "local", object = "arm chams", name = "sleeve", flag = "visuals_sleevecolor", color = Color3.fromRGB(106, 136, 213), transparency = 1})
			ui:createcolorpicker({tab = "visuals", subsection = "local", object = "arm chams", name = "arm", flag = "visuals_armcolor", color = Color3.fromRGB(181, 179, 253), transparency = 1})
			ui:createslider({tab = "visuals", subsection = "local", name = "arm reflectance", flag = "visuals_armreflectance", value = 0, minimum = 0, maximum = 128})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "arm material", flag = "visuals_armmaterial", values = {{"ghost", true}, {"flat", false}, {"foil", false}, {"custom", false}, {"reflective", false}}, multichoice = false})
			ui:createtoggle({tab = "visuals", subsection = "local", name = "weapon chams", flag = "visuals_weaponchams", value = false, tooltip = "changes the appearance of your weapon"})
			ui:createcolorpicker({tab = "visuals", subsection = "local", object = "weapon chams", name = "weapon", flag = "visuals_weaponcolor", color = Color3.fromRGB(106, 136, 213), transparency = 1})
			ui:createslider({tab = "visuals", subsection = "local", name = "weapon reflectance", flag = "visuals_weaponreflectance", value = 0, minimum = 0, maximum = 128})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "weapon material", flag = "visuals_weaponmaterial", values = {{"ghost", true}, {"flat", false}, {"foil", false}, {"custom", false}, {"reflective", false}}, multichoice = false})
			ui:createtoggle({tab = "visuals", subsection = "local", name = "local chams", flag = "visuals_localchams", value = false, tooltip = "changes the appearance of your character in 3rd person"})
			ui:createcolorpicker({tab = "visuals", subsection = "local", object = "local chams", name = "local", flag = "visuals_localcolor", color = Color3.fromRGB(106, 136, 213), transparency = 1})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "local material", flag = "visuals_localmaterial", values = {{"ghost", true}, {"flat", false}, {"foil", false}, {"custom", false}, {"reflective", false}}, multichoice = false})
			--ui:createtoggle({tab = "visuals", subsection = "local", name = "animate ghost arm", flag = "visuals_armanimation", value = false, tooltip = "allows your arms to have a visual animation if the material is ghost"})
			--ui:createtoggle({tab = "visuals", subsection = "local", name = "animate ghost weapon", flag = "visuals_weaponanimation", value = false, tooltip = "allows your weapon to have a visual animation if the material is ghost"})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "arm animation", flag = "visuals_armanimationtype", values = forcefieldAnimationsDropDown, multichoice = false})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "weapon animation", flag = "visuals_weaponanimationtype", values = forcefieldAnimationsDropDown, multichoice = false})
			ui:createdropdown({tab = "visuals", subsection = "local", name = "local animation", flag = "visuals_localanimationtype", values = forcefieldAnimationsDropDown, multichoice = false})

			ui:createslider({tab = "visuals", subsection = "camera", name = "camera fov", flag = "visuals_fov", value = 90, minimum = 10, maximum = 120, tooltip = "forces your camera fov to be a certain amount"})
			ui:createslider({tab = "visuals", subsection = "camera", name = "horizontal aspect ratio", flag = "visuals_aspectratiox", value = 100, minimum = 0, maximum = 120, tooltip = "forces your camera horizontal aspect ratio to be a certain amount"})
			ui:createslider({tab = "visuals", subsection = "camera", name = "vertical aspect ratio", flag = "visuals_aspectratioy", value = 100, minimum = 0, maximum = 120, tooltip = "forces your camera vertical aspect ratio to be a certain amount"})
			ui:createtoggle({tab = "visuals", subsection = "camera", name = "remove camera bob", flag = "visuals_camerabob", value = false, tooltip = "removes camera bobbing when moving"})
			ui:createtoggle({tab = "visuals", subsection = "camera", name = "remove ads fov", flag = "visuals_adsfov", value = false, tooltip = "removes fov effects when aiming"})
			ui:createtoggle({tab = "visuals", subsection = "camera", name = "remove visual suppresion", flag = "visuals_visualssuppresion", value = false, tooltip = "removes visual suppression effects when you get shot at"})
			ui:createtoggle({tab = "visuals", subsection = "camera", name = "reduce camera recoil", flag = "visuals_camerarecoil", value = false, tooltip = "reduces the amount of camera recoil"})
			ui:createslider({tab = "visuals", subsection = "camera", name = "camera recoil reduction", flag = "visuals_camerarecoilscale", value = 0, minimum = 0, maximum = 100, tooltip = "camera recoil reduction scale"})
			ui:createtoggle({tab = "visuals", subsection = "camera", name = "third person", flag = "visuals_thirdp", value = false, tooltip = "allows you to go into 3rd person"})
			ui:createkeybind({tab = "visuals", subsection = "camera", object = "third person", name = "third person key", flag = "visuals_thirdpkey", parentflag = "visuals_thirdp", value = Enum.KeyCode.H})
			ui:createslider({tab = "visuals", subsection = "camera", name = "third person distance", flag = "visuals_thirdpdistance", value = 100, minimum = 0, maximum = 240, tooltip = "how far away the camera is in third person"})

			ui:createtoggle({tab = "visuals", subsection = "viewmodel", name = "offset viewmodel", flag = "visuals_offsetviewmodel", value = false, tooltip = "offsets your viewmodel from its default position"})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "offset x", flag = "visuals_offsetviewmodelx", value = 180, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "offset y", flag = "visuals_offsetviewmodely", value = 180, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "offset z", flag = "visuals_offsetviewmodelz", value = 180, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "pitch", suffix = "°", flag = "visuals_offsetviewmodelp", value = 180, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "yaw", suffix = "°", flag = "visuals_offsetviewmodelya", value = 180, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "roll", suffix = "°", flag = "visuals_offsetviewmodelr", value = 180, minimum = 0, maximum = 360})
			ui:createtoggle({tab = "visuals", subsection = "viewmodel", name = "laser pointer", flag = "misc_customcrosshair", value = false, tooltip = "shows a custom crosshair"})
			ui:createtoggle({tab = "visuals", subsection = "viewmodel", name = "outline laser pointer", flag = "misc_customcrosshairoutline", value = false, tooltip = "outlines a custom crosshair"})
			ui:createcolorpicker({tab = "visuals", subsection = "viewmodel", object = "laser pointer", name = "laser pointer", flag = "misc_customcrosshaircolor", color = Color3.new(255, 255, 255)})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer width", flag = "misc_customcrosshairw", value = 20, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer length", flag = "misc_customcrosshairl", value = 20, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer length gap", flag = "misc_customcrosshairg", value = 20, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer width gap", flag = "misc_customcrosshairf", value = 20, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer thickness", flag = "misc_customcrosshairth", value = 1, minimum = 1, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer rotation", flag = "misc_laserpointerrotation", value = 45, minimum = 0, maximum = 360})
			ui:createslider({tab = "visuals", subsection = "viewmodel", name = "laser pointer rotation speed", flag = "misc_laserpointerrotationspeed", value = 0, minimum = -360, maximum = 360})

			ui:createtoggle({tab = "visuals", subsection = "world", name = "ambient", flag = "visuals_ambient", value = false, tooltip = "changes the color of the world"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "ambient", name = "indoor", flag = "visuals_indoorcolor", color = Color3.fromRGB(117, 76, 236)})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "ambient", name = "outdoor", flag = "visuals_outdoorcolor", color = Color3.fromRGB(117, 76, 236)})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "force time", flag = "visuals_forcetime", value = false, tooltip = "forces the time of the world"})
			ui:createslider({tab = "visuals", subsection = "world", name = "time of day", flag = "visuals_time", value = 6, minimum = 0, maximum = 24})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "local bullet tracers", flag = "visuals_bullettracers", value = false, tooltip = "creates a visual tracer of a bullets trajectory when a bullet is fired"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "local bullet tracers", name = "bullet tracers", flag = "visuals_bullettracercolor", color = Color3.fromRGB(201, 69, 54), transparency = 1})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "enemy bullet tracers", flag = "visuals_bullettracers2", value = false, tooltip = "creates a visual tracer of a bullets trajectory when a bullet is fired"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "enemy bullet tracers", name = "bullet tracers", flag = "visuals_bullettracercolor2", color = Color3.fromRGB(201, 69, 54), transparency = 1})
			ui:createslider({tab = "visuals", subsection = "world", name = "bullet tracer time", suffix = "s", flag = "visuals_bulettracertime", value = 4, minimum = 0, maximum = 16})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "hit chams", flag = "visuals_hitchams", value = false, tooltip = "creates a visual copy of an enemy when they have been shot"})
			ui:createslider({tab = "visuals", subsection = "world", name = "hit cham time", suffix = "s", flag = "visuals_hitchamtime", value = 2, minimum = 0, maximum = 12})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "hit chams", name = "hit chams", flag = "visuals_hitchamcolor", color = Color3.fromRGB(106, 136, 213), transparency = 1})
			ui:createdropdown({tab = "visuals", subsection = "world", name = "hit chams material", flag = "visuals_hitchammaterial", values = {{"ghost", true}, {"flat", false}, {"foil", false}, {"custom", false}, {"glass", false}}, multichoice = false})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "custom brightness", flag = "visuals_brightness", value = false, tooltip = "changes the brightness of the world"})
			ui:createdropdown({tab = "visuals", subsection = "world", name = "brightness mode", flag = "visuals_brightnesstype", values = {{"dimmed", true}, {"nightmode", false}, {"fullbright", false}}, multichoice = false})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "teleporting lines", flag = "visuals_teleportlines", value = false, tooltip = "creates a line showing the teleporting done by the aimbot"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "teleporting lines", name = "teleport line", flag = "visuals_teleportlinecolor", color = Color3.fromRGB(168, 232, 65)})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "show fake position", flag = "visuals_realshow", value = false, tooltip = "shows where your fake position is if you are desynced. yellow text means it is ready to be moved"})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "show fov", flag = "visuals_showfov", value = false, tooltip = "shows fov circles"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "show fov", name = "aim assist fov", flag = "visuals_aimassistfovcolor", color = Color3.fromRGB(127, 72, 163), transparency = 1})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "show fov", name = "triggerbot magnet fov", flag = "visuals_triggerbotmagnetcolor", color = Color3.fromRGB(100, 100, 100), transparency = 1})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "show fov", name = "bullet redirection fov", flag = "visuals_bulletredirectioncolor", color = Color3.fromRGB(163, 72, 127), transparency = 1})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "show fov", name = "aimbot fov", flag = "visuals_aimbotcolor", color = Color3.fromRGB(255, 60, 0), transparency = 1})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "custom skybox", flag = "visuals_customsky", value = false, tooltip = "adds a custom sky to the world"})
			ui:createdropdown({tab = "visuals", subsection = "world", name = "skybox", flag = "visuals_skychoice", values = skyboxDropDown, multichoice = false})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "custom bloom", flag = "visuals_custombloom", value = false, tooltip = "adds bloom to the world"})
			ui:createslider({tab = "visuals", subsection = "world", name = "bloom intensity", suffix = "%", flag = "visuals_bloomintensity", value = 10, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "world", name = "bloom size", suffix = "%", flag = "visuals_bloomsize", value = 10, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "world", name = "bloom threshold", suffix = "%", flag = "visuals_bloomthreshold", value = 10, minimum = 0, maximum = 100})
			ui:createtoggle({tab = "visuals", subsection = "world", name = "custom atmosphere", flag = "visuals_customatm", value = false, tooltip = "adds bloom to the world"})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "custom atmosphere", name = "color", flag = "visuals_customatmcolor", color = Color3.fromRGB(117, 76, 236)})
			ui:createcolorpicker({tab = "visuals", subsection = "world", object = "custom atmosphere", name = "decay", flag = "visuals_customatmdecay", color = Color3.fromRGB(117, 76, 236)})
			ui:createslider({tab = "visuals", subsection = "world", name = "atmosphere density", suffix = "%", flag = "visuals_densityatm", value = 10, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "world", name = "atmosphere glare", suffix = "%", flag = "visuals_glareatm", value = 10, minimum = 0, maximum = 100})
			ui:createslider({tab = "visuals", subsection = "world", name = "atmosphere haze", suffix = "%", flag = "visuals_hazeatm", value = 10, minimum = 0, maximum = 100})
		end
		-- misc features
		do
			ui:createtoggle({tab = "misc", subsection = "movement", name = "elytra", flag = "misc_fly", value = false, tooltip = "manipulates your movement to be able to fly"})
			ui:createkeybind({tab = "misc", subsection = "movement", object = "elytra", name = "fly key", parentflag = "misc_fly", flag = "misc_flykey"})
			ui:createslider({tab = "misc", subsection = "movement", name = "elytra speed factor", suffix = "st/s", flag = "misc_flyspeedfactor", value = 60, minimum = 0, maximum = 400})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "auto jump", flag = "misc_autojump", value = false, tooltip = "forces you to jump continuously when space is held"})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "speed", flag = "misc_speed", value = false, tooltip = "manipulates your movement to be able to move faster"})
			ui:createkeybind({tab = "misc", subsection = "movement", object = "speed", name = "speed key", parentflag = "misc_speed", flag = "misc_speedkey"})
			ui:createdropdown({tab = "misc", subsection = "movement", name = "speed type", flag = "misc_speedtype", values = {{"always", true}, {"in air", false}}, multichoice = false})
			ui:createslider({tab = "misc", subsection = "movement", name = "speed factor", suffix = "st/s", flag = "misc_speedfactor", value = 60, minimum = 0, maximum = 400})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "circle strafe", flag = "misc_circlestrafe", value = false, tooltip = "automatically strafes in a circle"})
			ui:createkeybind({tab = "misc", subsection = "movement", object = "circle strafe", name = "circle strafe key", parentflag = "misc_circlestrafe", flag = "misc_circlestrafekey"})
			ui:createslider({tab = "misc", subsection = "movement", name = "circle strafe radius", suffix = "st", flag = "misc_circlestraferadius", value = 8, minimum = 2, maximum = 20})
			--ui:createtoggle({tab = "misc", subsection = "movement", name = "no clip", flag = "misc_noclip", value = false, detected = true, tooltip = "allows you to fly through walls, will rubberband you if it failed to noclip. requires fly"})
			--ui:createkeybind({tab = "misc", subsection = "movement", object = "no clip", name = "no clip key", parentflag = "misc_noclip", flag = "misc_noclipkey"})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "bypass speed checks", flag = "misc_bypassspeed", value = false, tooltip = "attempts to bypass the maximum speed limit on the server when your speed exceeds 60 st./sec", detected = false})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "evie tick bypass", flag = "misc_evietickbypass", value = false, tooltip = "uses evie's ping hook instead of invadeds. use this if you're despawning with high firerate", detected = true})
			--ui:createtoggle({tab = "misc", subsection = "movement", name = "bypass flight checks", flag = "misc_bypassfly", value = false, tooltip = "attempts to bypass the flight check on the server, requires bypass speed checks", detected = true})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "bypass fall damage", flag = "misc_bypassfall", value = false, tooltip = "allows you to fall any distance without taking damage"})
			ui:createtoggle({tab = "misc", subsection = "movement", name = "super jump", flag = "misc_superjump", value = false, tooltip = "allows you to jump higher"})
			ui:createslider({tab = "misc", subsection = "movement", name = "super jump strength", suffix = "%", flag = "misc_superjumpstrength", value = 200, minimum = 0, maximum = 4000})

			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "enabled", flag = "misc_gunmods", value = false, tooltip = "allows the modification of your weapon statistics"})
			ui:createslider({tab = "misc", subsection = "weapon modifications", name = "fire rate scale", suffix = "%", flag = "misc_fireratescale", value = 100, minimum = 100, maximum = 10000, tooltip = "changes the speed that your weapon fires at"})
			ui:createslider({tab = "misc", subsection = "weapon modifications", name = "recoil scale", suffix = "%", flag = "misc_recoilscale", value = 100, minimum = 0, maximum = 100, tooltip = "changes the amount of recoil your weapon has"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "no weapon sway", flag = "misc_nosway", value = false, tooltip = "removes the gun moving around when you move your camera"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "no weapon bob", flag = "misc_nobob", value = false, tooltip = "removes the gun moving around when you walk around"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "no fire animation", flag = "misc_nofireanim", value = false, tooltip = "removes the gun firing animation, particularly useful for guns that require bolting"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "instant equip", flag = "misc_instantequip", value = false, tooltip = "removes the time it takes to equip your weapon"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "instant reload", flag = "misc_instantreload", value = false, tooltip = "removes the time it takes to reload your weapon"})
			ui:createtoggle({tab = "misc", subsection = "weapon modifications", name = "full auto", flag = "misc_fullauto", value = false, tooltip = "makes every gun fully automatic and able to continously shoot when mouse 1 is held"})

			ui:createtoggle({tab = "misc", subsection = "extra", name = "auto kick", flag = "misc_autokick", value = false, tooltip = "automatically kicks a random player from the server when you get kills"})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "supress only", flag = "misc_supressonly", value = false, tooltip = "the cheat will not do damage"})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "auto deploy", flag = "misc_autodeploy", value = false, tooltip = "the cheat will automatically deploy you"})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "ignore friendlies", flag = "misc_ignorefriendlies", value = false, tooltip = "the cheat will ignore targetting friendlies"})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "priorities only", flag = "misc_onlypriorities", value = false, tooltip = "the cheat will only target priorities"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "vote neutral", flag = "misc_voteneutral", values = {{"no", true}, {"yes", false}, {"none", false}}, multichoice = false})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "vote priority", flag = "misc_votepriority", values = {{"no", true}, {"yes", false}, {"none", false}}, multichoice = false})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "vote friendly", flag = "misc_votefriendly", values = {{"no", true}, {"yes", false}, {"none", false}}, multichoice = false})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "hit sound", flag = "misc_hitsound", value = false, tooltip = "plays a certain sound when you hit someone"})    
			ui:createslider({tab = "misc", subsection = "extra", name = "hit sound volume", suffix = "%", flag = "misc_hitsoundlevel", value = 20, minimum = 0, maximum = 100})
			ui:createtextbox({tab = "misc", subsection = "extra", text = "6229978482", flag = "misc_hitsoundid"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "hit sounds", flag = "misc_hitsoundids", values = cheatHitSoundsDropDown, multichoice = false})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "kill sound", flag = "misc_killsound", value = false, tooltip = "plays a certain sound when you kill someone"})
			ui:createslider({tab = "misc", subsection = "extra", name = "kill sound volume", suffix = "%", flag = "misc_killsoundlevel", value = 20, minimum = 0, maximum = 100})
			ui:createtextbox({tab = "misc", subsection = "extra", text = "5709456554", flag = "misc_killsoundid"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "kill sounds", flag = "misc_killsoundids", values = cheatHitSoundsDropDown, multichoice = false})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "chat spammer", flag = "misc_chatspam", value = false, tooltip = "sends chat messages in quick succession"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "chat spammer messages", flag = "misc_chatspamchoice", values = {{"normal", true}, {"emojis", false}, {"custom", false}}, multichoice = false})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "kill say", flag = "misc_killsay", value = false, tooltip = "sends chat messages after anyone is killed"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "kill say messages", flag = "misc_killsaychoice", values = {{"normal", true}, {"custom", false}}, multichoice = false})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "kill streak sounds", flag = "misc_killstreak", value = false, tooltip = "plays a certain sound when you get a kill streak"})
			ui:createslider({tab = "misc", subsection = "extra", name = "kill streak volume", suffix = "%", flag = "misc_killstreaklevel", value = 20, minimum = 0, maximum = 100})
			ui:createtoggle({tab = "misc", subsection = "extra", name = "fake equip", flag = "misc_fakeequip", value = false, tooltip = "you will appear as if you are holding a different weapon"})
			ui:createdropdown({tab = "misc", subsection = "extra", name = "fake equip slot", flag = "misc_fakeequipslot", values = {{"primary", true}, {"secondary", false}, {"melee", false}}, multichoice = false})
		end
		-- settings features
		do
			ui:createtextbox({tab = "config", subsection = "other", text = "preset name", flag = "configname"})

			local newList = ui.getconfigs()
			for i, v in next, newList do
				ui.flags.configname:setvalue(v[1])
				break
			end

			ui:createdropdown({tab = "config", subsection = "other", name = "preset", flag = "configselection", values = newList, multichoice = false})
			ui:createbutton({tab = "config", subsection = "other", name = "save preset", flag = "saveconfig", confirmation = true})
			ui:createbutton({tab = "config", subsection = "other", name = "load preset", flag = "loadconfig", confirmation = true})
			ui:createbutton({tab = "config", subsection = "other", name = "delete preset", flag = "deleteconfig", confirmation = true})

			ui:createtoggle({tab = "config", subsection = "ui", name = "key binds", value = false, flag = "keybinds"})

			ui:createslider({tab = "config", subsection = "ui", name = "key binds horizonatal offset", flag = "keybindoffsetx", value = 0, minimum = 0, maximum = 4096})
			ui:createslider({tab = "config", subsection = "ui", name = "key binds vertical offset", flag = "keybindoffsety", value = 256, minimum = 0, maximum = 4096})

			ui:createtoggle({tab = "config", subsection = "ui", name = "water mark", value = true, flag = "watermark"})
			ui:createtextbox({tab = "config", subsection = "ui", text = "vader", flag = "wmtext1"})
			ui:createtextbox({tab = "config", subsection = "ui", text = " haxx", flag = "wmtext2"})
			ui:createtoggle({tab = "config", subsection = "ui", name = "ui accent", value = false, flag = "uiaccent"})
			ui:createcolorpicker({tab = "config", subsection = "ui", object = "ui accent", name = "accent", flag = "uiaccentcolor", color = ui.accent})
			for groupName, group in next, ui.colorGroups do
				ui:createtoggle({tab = "config", subsection = "ui", name = "ui color " .. groupName, value = false, flag = "uicolor" .. groupName})
				ui:createcolorpicker({tab = "config", subsection = "ui", object = "ui color " .. groupName, name = "color " .. groupName, flag = "uicolorpicker" .. groupName, color = ui.startingParameters.colors[groupName]})
			end
			ui:createbutton({tab = "config", subsection = "ui", name = "reset ui layout", flag = "resetuilayout", confirmation = true})

			ui:createbutton({tab = "config", subsection = "extra", name = "rejoin", flag = "rejoin", confirmation = true})
			ui:createbutton({tab = "config", subsection = "extra", name = "join a new game", flag = "joinnewgame", confirmation = true})
			ui:createbutton({tab = "config", subsection = "extra", name = "set clipboard game id", flag = "clipboardgameid", confirmation = true})
			ui:createbutton({tab = "config", subsection = "extra", name = "set clipboard teleport code", flag = "clipboardtpcode", confirmation = true})
			ui:createbutton({tab = "config", subsection = "extra", name = "set clipboard join code", flag = "clipboardjoincode", confirmation = true})
		end
	end

	-- config area setup
	do
		local function resetConfigs()
			local oldThis = ui.elements["config"]["other"]["preset"]
			local oldHolderPos = oldThis.holder.position
			local oldValues = ui.flags.configselection.value
			local lastSelection
			for i, v in next, oldValues do
				if v then
					lastSelection = i
				end
			end

			oldThis.holder.visible = false -- hey guys vader here, today we're making a memory leak
			ui.elements["config"]["other"]["preset"] = nil
			local newList = ui.getconfigs()
			local setNew = false
			for i, v in next, newList do
				if lastSelection == v[1] then -- if the last selcetion is in the new list
					setNew = true
					break
				end
			end
			if setNew then
				for i, v in next, newList do
					if lastSelection == v[1] then -- if the last selcetion is in the new list
						ui.flags.configname:setvalue(v[1])
						v[2] = true
					else
						v[2] = false
					end
				end
			end
			ui:createdropdown({tab = "config", subsection = "other", name = "preset", flag = "configselection", values = newList, multichoice = false})
			ui.elements["config"]["other"]["preset"].holder.position = oldHolderPos
			ui.flags.configselection.changed:Connect(function()
				local selected
				for i, v in next, (ui.flags.configselection.value) do
					if v then
						selected = i
					end
				end
				if not selected then return end
				ui.flags.configname:setvalue(selected)
			end)
			ui:updatemenuanimations()
		end

		-- update config selection
		ui.flags.configselection.changed:Connect(function()
			local selected
			for i, v in next, (ui.flags.configselection.value) do
				if v then
					selected = i
				end
			end
			if not selected then return end
			ui.flags.configname:setvalue(selected)
		end)

		-- save config button
		ui.flags.saveconfig.pressed:Connect(function()
			writefile(cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. ui.flags.configname.value .. ".cfg", ui:savestate())
			ui:createnotification({text = "saved " .. ui.flags.configname.value .. ".cfg", lifetime = 5, priority = 0})
			resetConfigs()
		end)

		-- delete config button
		ui.flags.deleteconfig.pressed:Connect(function()
			local ConfigPath = cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. ui.flags.configname.value .. ".cfg"
			if isfile(ConfigPath) then
				delfile(ConfigPath)
				ui:createnotification({text = "deleted " .. ui.flags.configname.value .. ".cfg", lifetime = 5, priority = 0})
			end
			resetConfigs()
		end)

		-- load config button
		ui.flags.loadconfig.pressed:Connect(function()
			local ConfigPath = cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. ui.flags.configname.value .. ".cfg"
			if isfile(ConfigPath) then
				ui:loadstate(readfile(ConfigPath))
				ui:createnotification({text = "loaded " .. ui.flags.configname.value .. ".cfg", lifetime = 5, priority = 0})
			end
			resetConfigs()
		end)

		coroutine.wrap(function()
			repeat
				task.wait()
			until getgenv().vaderhaxx and getgenv().vaderhaxx.loaded
			task.wait()
			if isfile(cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. "default.cfg") then
				ui:loadstate(readfile(cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. "default.cfg"))
				ui:createnotification({text = "auto-loaded defualt.cfg", lifetime = 5, priority = 0})
			end
			writefile(cheat_path .. "/" .. game_path .. "/" .. config_path .. "/" .. "reset" .. ".cfg", ui:savestate())

			resetConfigs()
		end)()
	end
	-- color setup
	do
		-- update ui accents
		ui.flags.uiaccent.changed:Connect(function()
			ui.updateaccent()
		end)

		ui.flags.uiaccentcolor.changed:Connect(function()
			ui.updateaccent()
		end)

		for i, v in next, ui.startingParameters.colors do
			ui.flags["uicolor" .. i].changed:Connect(function()
				ui.updatecolors[i]()
			end)
			ui.flags["uicolorpicker" .. i].changed:Connect(function()
				ui.updatecolors[i]()
			end)
		end
	end
	-- extra 
	do
		ui.flags.rejoin.pressed:Connect(function()
			ui:createnotification({text = "rejoining...", lifetime = 5, priority = 0})
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
		end)
		ui.flags.joinnewgame.pressed:Connect(function()
			ui:createnotification({text = "joining a new game...", lifetime = 5, priority = 0})
			local thing = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
			local jobid = thing.data[math.random(1, table.getn(thing.data))].id

			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobid)
		end)
		ui.flags.clipboardgameid.pressed:Connect(function()
			ui:createnotification({text = "set job id to clipboard!", lifetime = 5, priority = 0})
			setclipboard(game.JobId)
		end)
		ui.flags.clipboardtpcode.pressed:Connect(function()
			ui:createnotification({text = "set job id to clipboard!", lifetime = 5, priority = 0})
			setclipboard('game:GetService("TeleportService"):TeleportToPlaceInstance('..game.PlaceId..',"'..game.JobId..'")')
		end)
		ui.flags.clipboardjoincode.pressed:Connect(function()
			ui:createnotification({text = "set job id to clipboard!", lifetime = 5, priority = 0})
			setclipboard('Roblox.GameLauncher.joinGameInstance('..game.PlaceId..',"'..game.JobId..'")')
		end)
	end

	-- watermark setup
	do
		if oldWatermark == true then
			local this = {}
			this.container = utilities:draw("frame", {
				parent = utilities.base,
				anchorpoint = Vector2.new(1, 0),
				size = UDim2.new(0, 100, 0, 100),
				position = UDim2.new(32, 0, 32, 0),
				zindex = ui.basezindex + -4,
				color = Color3.new(0.0862745, 0.0862745, 0.0862745),
				visible = false,
				thickness = 1,
				transparency = 1,
				filled = true,
				name = "okay",
			})
			this.outline1 = utilities:draw("frame", {
				parent = this.container,
				anchorpoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(1, 2, 1, 2),
				position = UDim2.new(0.5, 0, 0.5, 0),
				zindex = ui.basezindex + 5,
				color = Color3.new(0.262745, 0.262745, 0.262745),
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			this.outline2 = utilities:draw("frame", {
				parent = this.containeroutline,
				anchorpoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(1, 2, 1, 2),
				position = UDim2.new(0.5, 0, 0.5, 0),
				zindex = ui.basezindex + 4,
				color = Color3.new(0.0862745, 0.0862745, 0.0862745),
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})

			local textobjs = 42
			this.textObject = {}
			for i = 1, textobjs do
				this.textObject[i] = utilities:draw("text", {
					parent = this.container,
					anchorpoint = Vector2.new(0, 0),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 8 + ((i - 1) * 7), 0, 6),
					zindex = ui.basezindex + -4,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					text = " ",
					name = "okay",
				})
			end

			local statss = {
				framespersec = 0,
				memusage = math.floor(stats:GetTotalMemoryUsageMb()),
				instancecount = stats.InstanceCount,
			}

			runservice.RenderStepped:Connect(function()
				statss.framespersec = statss.framespersec + 1
			end)

			local lastthing = tick()
			local lastcolor = tick()
			local wmtext = ""
			local textthing = {}
			local hue = 0

			local months = {"Jan.","Feb.","Mar.","Apr.","May","Jun.","Jul.","Aug.","Sep.","Oct.","Nov.","Dec."}
			local daysinmonth = {31,28,31,30,31,30,31,31,30,31,30,31}

			local function getDate()
				local time = os.time()
				local year = math.floor(time/60/60/24/365.25+1970)
				local day = math.ceil(time/60/60/24%365.25)
				local month
				for i=1, #daysinmonth do
					if day > daysinmonth[i] then
						day = day - daysinmonth[i]
					else
						month = i
						break
					end
				end
				return month, day, year
			end

			local wtf = tick()
			runservice.RenderStepped:Connect(function(dt)
				local result = ui.startWatermark and ui.flags.watermark and ui.flags.watermark.value or false
				if this.container.visible ~= result then
					this.container.visible = result
				end

				if this.container.visible == false then return end

				local gayresult = UDim2.new(1, -100, 0, 42)
				if this.container.position ~= gayresult then
					this.container.position = gayresult
				end

				hue = hue + (dt * 5) -- el speed$$

				if tick() - lastthing > 1 then -- optimized$$$$$
					local seconds = os.date("*t") ["sec"]
					local minutes = os.date("*t") ["min"]
					local hours = os.date("*t") ["hour"]

					if tonumber(seconds) <= 9 then
						seconds = "0"..seconds
					end
					if tonumber(minutes) <= 9 then
						minutes = "0"..minutes
					end
					if tonumber(hours) <= 9 then
						hours = "0"..hours
					end

					lastthing = tick()
					statss.memusage = math.floor(stats:GetTotalMemoryUsageMb())
					statss.instancecount = stats.InstanceCount
					--wmtext = "[ vader haxx ] BETA" .. " | " .. statss.framespersec .. " fps" .. " | " .. hours..":"..minutes..":"..seconds
					local month, day, year = getDate()
					wmtext = "[ " .. ui.flags.wmtext1.value .. ui.flags.wmtext2.value .. " ] BETA" .. " | " .. tostring(months[month]) .. " " .. tostring(day) .. " " .. tostring(year)	
					statss.framespersec = 0
					this.container.size = UDim2.new(0, (#wmtext * 7) + 16, 0, 26)


					textthing = wmtext:split("")

					for i = 1, textobjs do
						local v = this.textObject[i]
						local addhue = 0
						if not textthing[i] then
							v.drawingobject.Text = ""
						else
							if i >= 6 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value and i <= 10 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value then
								addhue = addhue + 10 -- now add a bit for the next fucken character
								v.drawingobject.Color = Color3.fromHSV(((addhue + hue / 60) + (i / 60)) % 1, 0.58, 1) -- fully saturated made it look pasted so i toned that down a notch
							elseif i >= 3 + #ui.flags.wmtext1.value and i <= 3 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value then
								--v.drawingobject.Color = Color3.fromRGB(191, 255, 107)
								v.drawingobject.Color = ui.accent
							else
								v.drawingobject.Color = Color3.new(1, 1, 1)
							end

							v.drawingobject.Text = textthing[i]
						end
					end

					return
				end

				textthing = wmtext:split("")

				if tick() - wtf > 1/19 then
					wtf = tick()
					for i = 1, textobjs do
						local v = this.textObject[i]
						local addhue = 0
						if not textthing[i] then
							v.drawingobject.Text = ""
						else
							if i >= 6 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value and i <= 10 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value then
								addhue = addhue + 10 -- now add a bit for the next fucken character
								v.drawingobject.Color = Color3.fromHSV(((addhue + hue / 60) + (i / 60)) % 1, 0.58, 1) -- fully saturated made it look pasted so i toned that down a notch
							elseif i >= 3 + #ui.flags.wmtext1.value and i <= 3 + #ui.flags.wmtext1.value + #ui.flags.wmtext2.value then
								--v.drawingobject.Color = Color3.fromRGB(191, 255, 107)
								v.drawingobject.Color = ui.accent
							else
								v.drawingobject.Color = Color3.new(1, 1, 1)
							end

							v.drawingobject.Text = textthing[i]
						end
					end
				end
			end)
		else
			ui.objects.watermarkback = utilities:draw("frame", {
				parent = utilities.base,
				anchorpoint = Vector2.new(1, 0),
				size = UDim2.new(0, 420, 0, 28),
				position = UDim2.new(1, 0, 0, 92),
				zindex = ui.basezindex + -5,
				color = Color3.fromRGB(46, 46, 46),
				visible = false,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			ui.startWatermark = false
			ui.objects.watermarktextobjects = {}
			local textobjs = 56
			for i = 1, textobjs do
				ui.objects.watermarktextobjects[i] = utilities:draw("text", {
					parent = ui.objects.watermarkback,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 8 + ((i - 1) * 7), 0.5, 0),
					zindex = ui.basezindex + -4,
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					text = " ",
					name = "okay",
				})
			end

			local statss = {
				framespersec = 0,
				memusage = math.floor(stats:GetTotalMemoryUsageMb()),
				instancecount = stats.InstanceCount,
			}

			runservice.RenderStepped:Connect(function()
				statss.framespersec = statss.framespersec + 1
			end)

			local lastthing = tick()
			local lastcolor = tick()
			local wmtext = ""
			local textthing = ""
			local hue = 0
			runservice.RenderStepped:Connect(function(dt)
				local result = ui.startWatermark and ui.flags.watermark and ui.flags.watermark.value or false
				if ui.objects.watermarkback.visible ~= result then
					ui.objects.watermarkback.visible = result
				end

				if ui.objects.watermarkback.visible == false then return end

				local gayresult = UDim2.new(1, 0, 0, ui.flags.watermarkoffset and ui.flags.watermarkoffset.value or 256)
				if ui.objects.watermarkback.position ~= gayresult then
					ui.objects.watermarkback.position = gayresult
				end

				if tick() - lastthing > 1 then -- optimized$$$$$
					lastthing = tick()
					statss.memusage = math.floor(stats:GetTotalMemoryUsageMb())
					statss.instancecount = stats.InstanceCount
					wmtext = "vader haxx" .. " | " .. statss.framespersec .. " fps | " .. statss.memusage .. " mb | " .. statss.instancecount .. " objects"
					statss.framespersec = 0
				end
				hue = hue + (dt * 20) -- el speed$$
				textthing = wmtext:split("")
			end)

			local addhue = 0
			for i = 1, textobjs do
				local v = ui.objects.watermarktextobjects[i]
				local thislast = tick()
				addhue = addhue + 1/360 -- now add a bit for the next fucken character
				runservice.Stepped:Connect(function(u, dt)
					if tick() - thislast < 1/20 then
						return
					end
					thislast = tick()
					if not textthing[i] then
						v.drawingobject.Text = ""
						return
					end
					v.drawingobject.Color = Color3.fromHSV(((addhue + hue / 60) + (i / 60)) % 1, 0.58, 1) -- fully saturated made it look pasted so i toned that down a notch
					v.drawingobject.Text = textthing[i]
				end)
			end
		end
	end
	-- resizing setup
	do
		-- resizing function
		ui.objects.resizedetection.clicked:Connect(function()
			if not ui.uiopen then return end
			local connection connection = runservice.RenderStepped:Connect(function()
				if not ui.objects.resizedetection.holding then
					connection:Disconnect()
					connection = nil
					return
				end
				local final = Vector2.new(utilities.mouse.position.x - ui.objects.backborder.absoluteposition.x, utilities.mouse.position.y - ui.objects.backborder.absoluteposition.y)
				ui:setsize(final)
			end)
		end)

		ui.flags.resetuilayout.pressed:Connect(function()
			for tab, columns in next, ui.subsections do
				if tab ~= "players" then
					for column, panels in next, columns do
						for panel, data in next, panels do
							data.panelReposition.resetSide()
						end
					end
				end
			end
			for tab, columns in next, ui.subsections do
				if tab ~= "players" then
					for column, panels in next, columns do
						for panel, data in next, panels do
							data.panelReposition.resetPosition()
						end
					end
				end
			end
			for tab, columns in next, ui.subsections do
				if tab ~= "players" then
					for column, panels in next, columns do
						for panel, data in next, panels do
							data.panelResize.resetSize()
						end
					end
				end
			end
		end)
	end

	-- dragging setup
	do
		-- dragging function
		ui.objects.dragdetection.clicked:Connect(function()
			local relative = utilities.mouse.position - ui.objects.dragdetection.absoluteposition
			local connection connection = runservice.RenderStepped:Connect(function()
				if not ui.objects.dragdetection.holding then
					connection:Disconnect()
					connection = nil
					return
				end
				local result = Vector2.new(mouse.x, mouse.y + 36) - relative

				ui.objects.backborder.position = UDim2.new(result.x / camera.ViewportSize.x, 0, result.y / camera.ViewportSize.y, 0)
			end)
		end)
	end
	
	-- player list setup
	-- -sighs-
	-- hey guys, vader here, today we're getting depression (totally real)
	-- i love evie <3
	do
		local playerListTab = ui.tabs["players"]
		local playerMemory = {}
		ui.playerListRanks = {}
		ui.playerListStatus = playerMemory
		if playerListTab ~= nil then
			local reDrawPlayerList = function() end
			local playerFocused

			if isfile(cheat_path .. "/" .. game_path .. "/" .. "relations.json") then
				local oldMemory = readfile(cheat_path .. "/" .. game_path .. "/" .. "relations.json")
				local decoded = json.decode(oldMemory)

				for i, v in next, decoded do
					playerMemory[tonumber(i)] = v
				end
			end

			local currentlyShowing = {}
			local currentScrollLevel = 0
			local rows = {}

			ui:createsubsection({tab = "players", name = "options", length = 0.34, side = 1, ignoreScrolling = true, ignoreResizing = true, ignoreMoving = true})
			ui:createsubsection({tab = "players", name = "players", length = 0.66, side = 1, ignoreScrolling = true, ignoreResizing = true, ignoreMoving = true})

			local usernameText = ui.drawingFunction("text", {
				parent = ui.subsections.players[1].options.container,
				anchorpoint = Vector2.new(0, 0),
				size = 13,
				font = Drawing.Fonts.Plex,
				position = UDim2.new(0, 16, 0, 10),
				zindex = ui.basezindex + 8,
				color = Color3.fromRGB(255, 255, 255),
				visible = true,
				outline = false,
				outlinecolor = Color3.fromRGB(12, 12, 12),
				text = "player: ",
				name = "okay",
			})
			ui.openclose[1 + #ui.openclose] = usernameText
			local nextIndex = 1 + #ui.elements["players"]["options"]
			ui.elements["players"]["options"][nextIndex] = {
				bounds = Vector2.new(0, 18)
			}   
			ui:createdropdown({tab = "players", subsection = "options", name = "status", flag = "playerlist_status", values = {{"neutral", true}, {"priority", false}, {"friendly", false}}, multichoice = false})
			ui:createbutton({tab = "players", subsection = "options", name = "copy profile", flag = "copyprofile", confirmation = true})
			ui:createbutton({tab = "players", subsection = "options", name = "votekick", flag = "votekick", confirmation = true})

			ui.flags.copyprofile.pressed:Connect(function()
				if playerFocused then
					setclipboard(string.format("https://web.roblox.com/users/%s/profile", playerFocused.UserId))
				end
			end)

			ui.flags.votekick.pressed:Connect(function()
				if playerFocused then
					getgenv().vaderhaxx.modules.cheat.networking.send("modcmd", string.format("/votekick:%s:cheats", playerFocused.Name))
				end
			end)

			ui.flags.playerlist_status.changed:Connect(function()
				local vals = ui.flags.playerlist_status.value
				if playerFocused then
					if not playerMemory[playerFocused.UserId] then
						playerMemory[playerFocused.UserId] = {}
					end
					local reference = playerMemory[playerFocused.UserId]
					reference.neutral = vals.neutral
					reference.priority = vals.priority
					reference.friendly = vals.friendly

					-- no need to save neutral players
					for i, v in next, playerMemory do
						if v.neutral then
							playerMemory[i] = nil
						end
					end

					local copied = {}
					for i, v in next, playerMemory do
						copied[tostring(i)] = v
					end

					if isfile(cheat_path .. "/" .. game_path .. "/" .. "relations.json") then
						writefile(cheat_path .. "/" .. game_path .. "/" .. "relations.json", json.encode(copied))
					end
				end
				reDrawPlayerList()
			end)

			-- width correction
			for i, v in next, {"players", "options"} do
				local size = ui.subsections.players[1][v].maincontainer.size
				ui.subsections.players[1][v].maincontainer.size = UDim2.new(1, 0, size.Height.Scale, 0)
			end
			ui.subsections.players[1]["players"].maincontainer.size = UDim2.new(1, 0, 0, ui.subsections.players[1]["players"].maincontainer.absolutesize.y)
			local mainHolder = {}
			mainHolder.outline = ui.drawingFunction("frame", {
				parent = ui.directory.players.players,
				anchorpoint = Vector2.new(0.5, 0),
				size = UDim2.new(1, -16, 1, -20), -- what the FUCK?????
				position = UDim2.new(0.5, 0, 0, 12),
				zindex = ui.basezindex + 5,
				color = Color3.fromRGB(0, 0, 0),
				visible = true,
				thickness = 1,
				filled = false,
				name = "okay",
			})
			ui.openclose[1 + #ui.openclose] = mainHolder.outline

			mainHolder.container = ui.drawingFunction("frame", {
				parent = mainHolder.outline,
				anchorpoint = Vector2.new(0.5, 0.5),
				size = UDim2.new(1, -2, 1, -2),
				position = UDim2.new(0.5, 0, 0.5, 0),
				zindex = ui.basezindex + 6,
				color = Color3.fromRGB(12, 12, 12),
				visible = true,
				thickness = 0,
				filled = true,
				name = "okay",
			})
			ui.openclose[1 + #ui.openclose] = mainHolder.container

			local eachSize = 48
			for i = 1, 8 do
				local thisRow = {}
				thisRow.outline = ui.drawingFunction("frame", {
					parent = mainHolder.container,
					anchorpoint = Vector2.new(0.5, 0),
					size = UDim2.new(1, -2, 0, eachSize),
					position = UDim2.new(0.5, 0, 0, ((i - 1) * eachSize) + 2), -- the fuck is wrong with this shitty 1 pixel fix???
					zindex = ui.basezindex + 5,
					color = Color3.fromRGB(0, 0, 0),
					visible = true,
					thickness = 1,
					filled = false,
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.outline

				thisRow.container = ui.drawingFunction("frame", {
					parent = thisRow.outline,
					anchorpoint = Vector2.new(0.5, 0.5),
					size = UDim2.new(1, -2, 1, -2),
					position = UDim2.new(0.5, 0, 0.5, 0),
					zindex = ui.basezindex + 6,
					color = Color3.fromRGB(21, 21, 21),
					visible = true,
					activated = true,
					thickness = 0,
					filled = true,
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.container

				thisRow.container.clicked:Connect(function()
					playerFocused = currentlyShowing[i]
					if playerFocused then
						usernameText.text = "player: " .. playerFocused.Name
						local status = {
							neutral = true,
							priority = false,
							friendly = false,
						}
						if playerMemory[playerFocused.UserId] then
							for i, v in next, playerMemory[playerFocused.UserId] do
								status[i] = v
							end
						end
						ui.flags.playerlist_status:setvalue(status)
						reDrawPlayerList()
					end
				end)    

				thisRow.avatarOutline = ui.drawingFunction("frame", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = UDim2.new(0, 44, 0, 44),
					position = UDim2.new(0, 1, 0.5, 0),
					zindex = ui.basezindex + 7,
					color = Color3.fromRGB(16, 16, 16),
					visible = true,
					thickness = 1,
					filled = false,
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.avatarOutline

				thisRow.avatarImage = ui.drawingFunction("image", {
					parent = thisRow.avatarOutline,
					anchorpoint = Vector2.new(0.5, 0.5),
					size = UDim2.new(1, -2, 1, -2),
					position = UDim2.new(0.5, 0, 0.5, 0),
					zindex = ui.basezindex + 8,
					visible = true,
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.avatarImage

				local charsUsed = 6
				thisRow.usernameText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "username text here 1",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.usernameText

				charsUsed = charsUsed + 20

				thisRow.usernameDivideText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = " | ",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.usernameDivideText

				charsUsed = charsUsed + 3

				thisRow.rankText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "rank 9999",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.rankText

				charsUsed = charsUsed + 7

				thisRow.rankDivideText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = " | ",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.rankDivideText

				charsUsed = charsUsed + 3

				thisRow.statusText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 70, 60),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "priority",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.statusText

				charsUsed = charsUsed + 6

				thisRow.statusDivideText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,   
					color = Color3.fromRGB(255, 255, 255),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = " | ",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.statusDivideText

				charsUsed = charsUsed + 3

				thisRow.teamText = ui.drawingFunction("text", {
					parent = thisRow.container,
					anchorpoint = Vector2.new(0, 0.5),
					size = 13, -- x3
					font = Drawing.Fonts.Plex,
					position = UDim2.new(0, 4 + (7 * charsUsed), 0.5, -1),
					zindex = ui.basezindex + 7,
					color = Color3.fromRGB(119, 255, 60),
					visible = true,
					outline = false,
					outlinecolor = Color3.fromRGB(12, 12, 12),
					text = "team",
					name = "okay",
				})
				ui.openclose[1 + #ui.openclose] = thisRow.teamText

				rows[1 + #rows] = thisRow
			end
			local moderators = {}
			local function isPlayerInGroupAndRank(player, groupId, requiredRank)
				-- Check if the player is in the specified group
				local inGroup = false
			
				-- Get the player's groups asynchronously
				local success, groups = pcall(function()
					return player:GetGroupsAsync()
				end)
			
				if success then
					-- Loop through the player's groups to find the specified group
					for _, groupInfo in pairs(groups) do
						if groupInfo.Id == groupId then
							inGroup = true
							break
						end
					end
					
					-- If the player is in the group, check their rank
					if inGroup then
						-- Get the player's rank in the group
						local playerRank = player:GetRankInGroup(groupId)
						
						-- Check if the player's rank is equal to or greater than the required rank
						if playerRank and playerRank >= requiredRank then
							return true  -- Player is in the group and has the required rank
						end
					end
				end
			
				return false  -- Player is not in the group or doesn't have the required rank
			end
			local asyncwaiting = false
			function reDrawPlayerList()
				local plrs = {}
				for _, player in pairs(players:GetPlayers()) do
					if player == localplayer then
						continue
					end

					plrs[#plrs + 1] = player
				end
				coroutine.wrap(function()
					for _, player in pairs(players:GetPlayers()) do
						if player == localplayer then
							continue
						end
						
						if ui.imagecache[player.UserId] then
							continue
						end
						
						ui.imagecache[player.UserId] = base64.decode("/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAAqACoDAREAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD+X+gAoAKACgAoAKACgBCQASeABkn0AoA8tj8VeMtYivNY8N6LpMug2k9zFbrqFzPHqWrJZu0c8tqIswQK7o6wrNksRg7jkAA7vQNZt/EGj2OsWqvHDew+Z5UmPMhkVmjmhcjgtFKjoSOG27hwaANigAoAKAM7VdV03RrN73VryCytFIRpZ2wGd87Y0UAvJIwBIjjVnIDHGFJAB89x+KIdHivNH8N+MtMi0G7nuZbZ9Q0TW5NS0lL12knitGis/InVHd3habBBYdGySAeueBdS8LvpNtovh3VUvxpduFlWRZILxi8jNLcyW88cUgWWd2YsqGNC6pu5XIB3NABQAUAeXePfPj13wbevo2p63pmn3Gq3V5aadYtflZxbQx2Mrx8R7o5nLp5jrwrsgZlxQBa/4T2MdPBPjX/wQL/8kUAYkWoTa3478MalZeGfEGkJb2+r2uqXmpaSbOOaCWzL2kUkyNIrKk8bbfNZNruioSWIAB7FQAUAFABQAUAFABQAUAFABQAUAFABQAUAf//Z")
						
						if disableImageLoading then
							continue
						end
						
						local data, content
						local success, err = pcall(function()
							task.wait(math.random() * 2)
							data = game:HttpGetAsync("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. player.UserId .. "&size=48x48&format=Png&isCircular=false")
						end)

						if not success then
							ui.imagecache[player.UserId] = nil
							continue
						end

						success, err = pcall(function()
							local decoded = json.decode(data)
							task.wait(math.random() * 2)
							content = game:HttpGetAsync(decoded.data[1].imageUrl)
							table.clear(decoded)
						end)
						
						if success then
							ui.imagecache[player.UserId] = content
						else
							ui.imagecache[player.UserId] = nil
						end
					end
				end)()
				table.clear(currentlyShowing)
				for i, v in next, plrs do
					local correspondingListIndex = i - currentScrollLevel
					local rowData = rows[correspondingListIndex]

					if not rowData then
						continue
					end

					if rowData.avatarImage.data ~= ui.imagecache[v.UserId] then
						rowData.avatarImage.data = ui.imagecache[v.UserId] or ""
					end

					rowData.usernameText.text = v.Name
					rowData.usernameText.color = Color3.fromRGB(255, 255, 255)

					local superUsers = pfModules.SuperUsers
					local isMod = moderators[v.UserId] or isPlayerInGroupAndRank(v, 1103278, 17827696)
					if not moderators[v.UserId] then
						moderators[v.UserId] = isMod
					end
					if isMod or superUsers and superUsers[v.UserId] then
						rowData.usernameText.color = Color3.fromRGB(255, 106, 79)
					end

					local ffs = ui.playerListRanks[v.Name]
					if ffs then
						rowData.rankText.text = "rank  " .. ui.playerListRanks[v.Name]
					else
						rowData.rankText.text = "rank  0"
					end

					local theirStatus = "neutral"
					if playerMemory[v.UserId] then
						for st, is in next, playerMemory[v.UserId] do
							if is == true then
								theirStatus = st
								break
							end
						end
					end
					rowData.statusText.text = theirStatus
					rowData.statusText.color = theirStatus == "neutral" and Color3.new(1, 1, 1) or theirStatus == "priority" and Color3.fromRGB(245, 239, 120) or Color3.fromRGB(120, 189, 245)

					rowData.teamText.text = v.TeamColor == localplayer.TeamColor and "team" or "enemy"
					rowData.teamText.color = v.TeamColor == localplayer.TeamColor and Color3.fromRGB(119, 255, 60) or Color3.fromRGB(255, 70, 60)

					currentlyShowing[correspondingListIndex] = v
				end
				for i = 1, 8 do
					local correspondingListIndex = i + currentScrollLevel

					if not plrs[correspondingListIndex] then
						local rowData = rows[i]

						rowData.avatarImage.data = ""

						rowData.usernameText.text = "-"
						rowData.rankText.text = "rank -"

						local theirStatus = "-"
						rowData.statusText.text = theirStatus
						rowData.statusText.color = Color3.new(1, 1, 1)

						rowData.teamText.text = "-"
						rowData.teamText.color = Color3.new(1, 1, 1)
						currentlyShowing[i] = nil
					end
				end
			end
			reDrawPlayerList()
			local last = 0
			runservice.Stepped:Connect(function()
				if tick() - last > 1/5 then
					last = tick()
					reDrawPlayerList()
				end
			end)

			utilities.mouse.scrollup:Connect(function()
				if utilities.mousechecks.inbounds(mainHolder.outline, utilities.mouse.position) and mainHolder.outline.drawingobject.Visible then
					currentScrollLevel = math.max(currentScrollLevel - 1, 0)
				end
			end)
			utilities.mouse.scrolldown:Connect(function()
				if utilities.mousechecks.inbounds(mainHolder.outline, utilities.mouse.position) and mainHolder.outline.drawingobject.Visible then
					currentScrollLevel = math.min(currentScrollLevel + 1, #(players:GetPlayers()) - 3)
				end
			end)

			players.PlayerRemoving:Connect(function(player)
				if ui.imagecache[player.UserId] then
					table.remove(ui.imagecache, player.UserId)
				end
			end)
		end
	end
	-- animation setup
	do
		-- setup ui animations
		ui:updatemenuanimations()
	end
end

-- keybinds list setup
local keybindsui
do
	local workspace                     = game:GetService("Workspace")
	local camera			            = workspace.CurrentCamera
	local stats                         = game:GetService("Stats")
	local runservice                    = game:GetService("RunService")
	local players                       = game:GetService("Players")
	local localplayer                   = players.LocalPlayer
	local mouse                         = localplayer:GetMouse()

	-- initiate key binds ui
	do
		local started = uilibrary:start({
			size = Vector2.new(200, 64),
			name = "vader haxx",
			basezindex = 10000,
			accent = Color3.fromRGB(255, 200, 69),
			colors = {
				a = Color3.fromRGB(0, 0, 0),
				b = Color3.fromRGB(56, 56, 56),
				c = Color3.fromRGB(46, 46, 46),
				d = Color3.fromRGB(12, 12, 12),
				e = Color3.fromRGB(21, 21, 21),
				f = Color3.fromRGB(84, 84, 84),
				g = Color3.fromRGB(54, 54, 54),
			},
			tabs = {
				"keybinds",
			}
		})
		keybindsui = started
	end
	-- dragging setup
	--do
	--    -- dragging function
	--    keybindsui.objects.dragdetection.clicked:Connect(function()
	--        local relative = utilities.mouse.position - keybindsui.objects.dragdetection.absoluteposition
	--        local connection connection = runservice.Stepped:Connect(function()
	--            if not keybindsui.objects.dragdetection.holding then
	--                connection:Disconnect()
	--                connection = nil
	--                return
	--            end
	--            local result = Vector2.new(mouse.x, mouse.y + 36) - relative
	--           
	--            keybindsui.objects.backborder.position = UDim2.new(result.x / camera.ViewportSize.x, 0, result.y / camera.ViewportSize.y, 0)
	--        end)
	--    end)
	--end

	-- key binds ui
	do
		keybindsui.objects.backborder.position = UDim2.new(0, 0, 0.5, 0)

		local keybinders = {}
		for i, v in next, ui.flags do -- oh god kill me please :skull:
			if v.type == "keybind" then
				keybinders[1 + #keybinders] = v
			end
		end

		local keytexts = {}
		for i = 1, #keybinders do
			local txt = utilities:draw("text", {
				parent = keybindsui.tabs["keybinds"],
				anchorpoint = Vector2.new(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = UDim2.new(0, -8, 0, ((i - 1) * 18) -12),
				zindex = keybindsui.tabs["keybinds"].zindex + 1,
				color = Color3.fromRGB(255, 255, 255),
				visible = false,
				outline = false,
				text = "",
				name = "okay",
			})
			keytexts[i] = txt
		end

		local function singlekeybindupdate()
			local currentkeys = {}
			for i2, v2 in next, keybinders do
				if v2.value == true then
					local parentthatleft = v2.parentflag
					if ui.flags[parentthatleft].value == true then
						currentkeys[1 + #currentkeys] = v2
					end
				end
			end
			local FUCKYOU = Vector2.new(200, 64)
			for i2, v2 in next, keytexts do
				v2.visible = false
			end
			for i2, v2 in next, currentkeys do
				local keynig = v2.key
				local keyastext = "NONE"
				if keynig and keynig ~= "NONE" then
					keyastext = string.sub(string.upper(keynig:sub(14)), 1, 5)
				end
				local thingtoshow = ""
				if v2.object == "enabled" then
					thingtoshow = v2.section .. ":" .. v2.activation
				else
					thingtoshow = v2.object .. ":" .. v2.activation
				end
				keytexts[i2].text = "[ " .. keyastext .. " ] " .. thingtoshow
				keytexts[i2].visible = true
				local xbound = keytexts[i2].absolutesize.x + 64 -- ????????????????????? bitch??
				FUCKYOU = FUCKYOU + Vector2.new(xbound > FUCKYOU.x and xbound - FUCKYOU.x or 0, 18)
			end
			keybindsui:setsize(FUCKYOU)
		end

		local oldcreatekeybind = ui.createkeybind
		ui.createkeybind = function(self, ...)
			local arg = {...}
			local param = arg[1]
			local func = oldcreatekeybind(self, ...)

			local flagRef = ui.flags[param.flag]

			flagRef.changed:Connect(function()
				singlekeybindupdate()
			end)
			ui.flags[flagRef.parentflag].changed:Connect(function()
				singlekeybindupdate()
			end)

			keybinders[1 + #keybinders] = flagRef

			local txt = utilities:draw("text", {
				parent = keybindsui.tabs["keybinds"],
				anchorpoint = Vector2.new(0, 0),
				size = 13, -- x3
				font = Drawing.Fonts.Plex,
				position = UDim2.new(0, -8, 0, ((#keytexts - 1) * 18) -12),
				zindex = keybindsui.tabs["keybinds"].zindex + 1,
				color = Color3.fromRGB(255, 255, 255),
				visible = false,
				outline = false,
				text = "",
				name = "okay",
			})
			keytexts[1 + #keytexts] = txt
			return func
		end

		for i, v in next, keybinders do
			v.changed:Connect(function()
				singlekeybindupdate()
			end)
			ui.flags[v.parentflag].changed:Connect(function()
				singlekeybindupdate()
			end)
		end

		singlekeybindupdate()

		keybindsui.objects.backborder.visible = false
		ui.flags.keybinds.changed:Connect(function()
			keybindsui.objects.backborder.visible = ui.flags.keybinds.value
			singlekeybindupdate()
		end)
	end
end
-- accent colors
do
	ui.oldaccent = ui.accent
	ui.updatecolors = {}
	local savedColors = {}
	for i, v in next, ui.startingParameters.colors do
		savedColors[i] = v
	end
	for i, v in next, ui.startingParameters.colors do
		ui.updatecolors[i] = function()
			local targetColor = ui.flags["uicolor" .. i].value and ui.flags["uicolorpicker" .. i].color or savedColors[i]
			for k, menuObject in next, {ui, keybindsui} do
				for i, v in next, menuObject.colorGroups[i] do
					v.color = targetColor
				end
			end
			ui.startingParameters.colors[i] = targetColor
		end
	end
	ui.updateaccent = function()
		if not ui.uiopen then
			return
		end 

		if ui.flags.uiaccent.value then
			ui.accent = ui.flags.uiaccentcolor.color
		else
			ui.accent = ui.oldaccent
		end
		for k, menuObject in next, {ui, keybindsui} do
			for i, v in next, (menuObject.accents) do
				if v.color then -- this is an object, not a table
					v.color = ui.accent
				else
					if v[2] == "tabs" or v[2] == "sliders" then
						if v[2] == "tabs" then
							for i2, v2 in next, (v[1]) do
								v2.color = ui.accent:lerp(Color3.fromRGB(math.clamp((ui.accent.r * 255) - 100, 0, 255), math.clamp((ui.accent.g * 255) - 100, 0, 255), math.clamp((ui.accent.b * 255) - 100, 0, 255)), (i2 - 1) / #v)
							end
						else
							for i2, v2 in next, (v[1]) do
								v2.color = ui.accent:lerp(Color3.fromRGB(math.clamp((ui.accent.r * 255) - 5, 0, 255), math.clamp((ui.accent.g * 255) - 5, 0, 255), math.clamp((ui.accent.b * 255) - 5, 0, 255)), (i2 - 1) / (#v - 1))
							end
						end
					else
						for i2, v2 in next, (v) do
							v2.color = ui.accent:lerp(Color3.fromRGB(math.clamp((ui.accent.r * 255) - 30, 0, 255), math.clamp((ui.accent.g * 255) - 30, 0, 255), math.clamp((ui.accent.b * 255) - 30, 0, 255)), (i2 - 1) / (#v - 1))
						end
					end
				end
			end
		end
	end
end

-- import the janitor
do
	-- Compiled with L+ C Edition
	-- Janitor
	-- Original by Validark
	-- Modifications by pobammer
	-- roblox-ts support by OverHash and Validark
	-- LinkToInstance fixed by Elttob.
	-- Cleanup edge cases fixed by codesenseAye.

	local GetPromiseLibrary = function() return false end
		--[[ 	A wrapper for an `RBXScriptConnection`. Makes the Janitor clean up when the instance is destroyed. This was created by Corecii.  	@class RbxScriptConnection ]] 
        local RbxScriptConnection = {} 
        RbxScriptConnection.Connected = true 
        RbxScriptConnection.__index = RbxScriptConnection  
        --[[ 	@prop Connected boolean 	@within RbxScriptConnection  	Whether or not this connection is still connected.  	Disconnects the signal. ]] 
        function RbxScriptConnection:Disconnect() 	
            if self.Connected then 		
                self.Connected = false 		
                self.Connection:Disconnect() 	
            end 
        end  
        function RbxScriptConnection._new(RBXScriptConnection: RBXScriptConnection) 	
            return setmetatable({ 		
                Connection = RBXScriptConnection 	
            }, RbxScriptConnection) 
        end  
        function RbxScriptConnection:__tostring() 	
            return "RbxScriptConnection" 
        end  
		local function Symbol(Name: string) 	
            local self = newproxy(true) 	
            local Metatable = getmetatable(self) 	

            function Metatable.__tostring() 		
                return Name 	
            end  	

            return self 
        end  

	local FoundPromiseLibrary, Promise = GetPromiseLibrary()

	local IndicesReference = Symbol("IndicesReference")
	local LinkToInstanceIndex = Symbol("LinkToInstanceIndex")

	local INVALID_METHOD_NAME = "Object is a %s and as such expected `true` for the method name and instead got %s. Traceback: %s"
	local METHOD_NOT_FOUND_ERROR = "Object %s doesn't have method %s, are you sure you want to add it Traceback: %s"
	local NOT_A_PROMISE = "Invalid argument #1 to 'Janitor:AddPromise' (Promise expected, got %s (%s)) Traceback: %s"

    --[[
        Janitor is a light-weight, flexible object for cleaning up connections, instances, or anything. This implementation covers all use cases,
        as it doesn't force you to rely on naive typechecking to guess how an instance should be cleaned up.
        Instead, the developer may specify any behavior for any object.

        @class Janitor
    ]]
	local Janitor = {}
	Janitor.ClassName = "Janitor"
	Janitor.CurrentlyCleaning = true
	Janitor[IndicesReference] = nil
	Janitor.__index = Janitor

    --[[
        @prop CurrentlyCleaning boolean
        @within Janitor

        Whether or not the Janitor is currently cleaning up.
    ]]

	local TypeDefaults = {
		["function"] = true,
		thread = true,
		RBXScriptConnection = "Disconnect"
	}

    --[[
        Instantiates a new Janitor object.
        @return Janitor
    ]]
	function Janitor.new()
		return setmetatable({
			CurrentlyCleaning = false,
			[IndicesReference] = nil
		}, Janitor)
	end

    --[[
        Determines if the passed object is a Janitor. This checks the metatable directly.

        @param Object any -- The object you are checking.
        @return boolean -- `true` if `Object` is a Janitor.
    ]]
	function Janitor.Is(Object: any): boolean
		return type(Object) == "table" and getmetatable(Object) == Janitor
	end

	function Janitor:Add(Object: T, MethodName: StringOrTrue, Index: any): T
		if Index then
			self:Remove(Index)

			local This = self[IndicesReference]
			if not This then
				This = {}
				self[IndicesReference] = This
			end

			This[Index] = Object
		end

		local TypeOf = typeof(Object)
		local NewMethodName = MethodName or TypeDefaults[TypeOf] or "Destroy"

		if TypeOf == "function" or TypeOf == "thread" then
			if NewMethodName ~= true then
				--warn(string.format(INVALID_METHOD_NAME, TypeOf, tostring(NewMethodName), debug.traceback(nil, 2)))
			end
		else
			if not (Object)[NewMethodName] then
				--warn(string.format(METHOD_NOT_FOUND_ERROR, tostring(Object), tostring(NewMethodName), debug.traceback(nil, 2)))
			end
		end

		self[Object] = NewMethodName
		return Object
	end

	function Janitor:AddPromise(PromiseObject)
		if FoundPromiseLibrary then
			if not Promise.is(PromiseObject) then
				error(string.format(NOT_A_PROMISE, typeof(PromiseObject), tostring(PromiseObject), debug.traceback(nil, 2)))
			end

			if PromiseObject:getStatus() == Promise.Status.Started then
				local Id = newproxy(false)
				local NewPromise = self:Add(Promise.new(function(Resolve, _, OnCancel)
					if OnCancel(function()
							PromiseObject:cancel()
						end) then
						return
					end

					Resolve(PromiseObject)
				end), "cancel", Id)

				NewPromise:finallyCall(self.Remove, self, Id)
				return NewPromise
			else
				return PromiseObject
			end
		else
			return PromiseObject
		end
	end

	function Janitor:Remove(Index: any)
		local This = self[IndicesReference]

		if This then
			local Object = This[Index]

			if Object then
				local MethodName = self[Object]

				if MethodName then
					if MethodName == true then
						if type(Object) == "function" then
							Object()
						else
							task.cancel(Object)
						end
					else
						local ObjectMethod = Object[MethodName]
						if ObjectMethod then
							ObjectMethod(Object)
						end
					end

					self[Object] = nil
				end

				This[Index] = nil
			end
		end

		return self
	end

	function Janitor:RemoveList(...)
		local This = self[IndicesReference]
		if This then
			local Length = select("#", ...)
			if Length == 1 then
				return self:Remove(...)
			else
				for Index = 1, Length do
					-- MACRO
					local Object = This[select(Index, ...)]
					if Object then
						local MethodName = self[Object]

						if MethodName then
							if MethodName == true then
								if type(Object) == "function" then
									Object()
								else
									task.cancel(Object)
								end
							else
								local ObjectMethod = Object[MethodName]
								if ObjectMethod then
									ObjectMethod(Object)
								end
							end

							self[Object] = nil
						end

						This[Index] = nil
					end
				end
			end
		end

		return self
	end

	function Janitor:Get(Index: any): any
		local This = self[IndicesReference]
		return (This) and (This[Index]) or (nil)
	end

	local function GetFenv(self)
		return function()
			for Object, MethodName in next, self do
				if Object ~= IndicesReference then
					return Object, MethodName
				end
			end
		end
	end

	function Janitor:Cleanup()
		if not self.CurrentlyCleaning then
			self.CurrentlyCleaning = nil

			local Get = GetFenv(self)
			local Object, MethodName = Get()

			while Object and MethodName do -- changed to a while loop so that if you add to the janitor inside of a callback it doesn't get untracked (instead it will loop continuously which is a lot better than a hard to pindown edgecase)
				if MethodName == true then
					if type(Object) == "function" then
						Object()
					else
						task.cancel(Object)
					end
				else
					local ObjectMethod = Object[MethodName]
					if ObjectMethod then
						ObjectMethod(Object)
					end
				end

				self[Object] = nil
				Object, MethodName = Get()
			end

			local This = self[IndicesReference]
			if This then
				table.clear(This)
				self[IndicesReference] = {}
			end

			self.CurrentlyCleaning = false
		end
	end

	function Janitor:Destroy()
		self:Cleanup()
		table.clear(self)
		setmetatable(self, nil)
	end

	Janitor.__call = Janitor.Cleanup

	function Janitor:LinkToInstance(Object: Instance, AllowMultiple: boolean): RBXScriptConnection
		local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex

		return self:Add(Object.Destroying:Connect(function()
			self:Cleanup()
		end), "Disconnect", IndexToUse)
	end

	function Janitor:LegacyLinkToInstance(Object: Instance, AllowMultiple: boolean): RbxScriptConnection
		local Connection
		local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
		local IsNilParented = Object.Parent == nil
		local ManualDisconnect = setmetatable({}, RbxScriptConnection)

		local function ChangedFunction(_DoNotUse, NewParent)
			if ManualDisconnect.Connected then
				_DoNotUse = nil
				IsNilParented = NewParent == nil

				if IsNilParented then
					task.defer(function()
						if not ManualDisconnect.Connected then
							return
						elseif not Connection.Connected then
							self:Cleanup()
						else
							while IsNilParented and Connection.Connected and ManualDisconnect.Connected do
								task.wait()
							end

							if ManualDisconnect.Connected and IsNilParented then
								self:Cleanup()
							end
						end
					end)
				end
			end
		end

		Connection = Object.AncestryChanged:Connect(ChangedFunction)
		ManualDisconnect.Connection = Connection

		if IsNilParented then
			ChangedFunction(nil, Object.Parent)
		end

		Object = nil
		return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
	end

	function Janitor:LinkToInstances(...)
		local ManualCleanup = Janitor.new()
		for _, Object in ipairs({...}) do
			ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
		end

		return ManualCleanup
	end

	function Janitor:__tostring()
		return "Janitor"
	end

	table.freeze(Janitor)
	janitor = Janitor
end

-- pfmodules setup
do
	for i, v in getupvalue(getrenv().shared.require, 1)._cache do
		pfModules[i] = v.module or nil
	end
end
