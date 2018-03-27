--[[
cmudict.lua
CMU Pronouncing Dictionary
Implementation in Lua, created by Jack Britchford (https://github.com/jackbritchford/cmudict-lua)
Created 24/03/2018.
License: The Unlicense (do whatever you want and don't blame me. credit is always nice)

Todo:
	- Uppercase words on "entry" functions but not internally because inefficient ugh.
	- Make words objects as apposed to tables w metatables/functions/etc
	- Optimise

]]


-- https://gist.github.com/jackbritchford/5f0d5f6dbf694b44ef0cd7af952070c9
local function enclose(str, leftboth, right)
	local left = leftboth or "[\""
	right = right or leftboth or "\"]"
	return left .. tostring(str) .. right
end
local function tbltostrint(t, count, indent, pad) -- now i realise, using "int" to mean "internal" is bad in any language, even Lua.
	indent = indent or 0
	pad = pad or "\t"

	local curpad = pad:rep(indent + count)
	local out = ""

	for k, v in pairs(t) do
		out = out .. curpad
		if type(v) == "table" then
			out = out .. enclose(k) .. " = {" .. "\n"
			out = out .. tbltostrint(v, count, indent + (count * 2), pad) .. curpad .. "},\n"
		elseif type(v) == "string" then
			out = out .. enclose(k) .. pad .. "=" .. pad .. enclose(v, "\"") .. ",\n"
		else
			out = out .. enclose(k) .. pad .. "=" .. pad .. enclose(v, "") .. ",\n"
		end
	end
	return out
end
local function tbltostr(t, count, pad)
	count = count or 1
	return tbltostrint(t, count, 0, pad)
end
local function printtable(t, count, pad)
	print(tbltostr(t, count, pad))
end

cmu = cmu or {}

-- link to the cmudict SF repo
cmu._RepositoryURL = "http://svn.code.sf.net/p/cmusphinx/code/trunk/cmudict/"


cmu._DB = cmu._DB or {}
cmu._FrequentCache = true
cmu._Cache = {}

-- this is faster then checking the value of frequentcache everytime, but change before making a module/whatever
if not cmu._FrequentCache then
	function cmu.get(word)
		return cmu._DB[word]
	end
else
	function cmu.get(word)
		if cmu._Cache[word] then
			return cmu._Cache[word]
		end
		local w = cmu._DB[word]
		cmu._Cache[word] = w
		return w
	end
end


--[[
cmudict-0.7b
cmudict-0.7b.phones
cmudict-0.7b.symbols
]]
--[[
function cmu.loaddbfrmstr(str)


end

function cmu.loaddbfromfile()
]]
-- as of cmudict-0.7b
-- may not work with cmudict-0.6? or the one which doesnt use ;;; and instead uses ;
function cmu.loaddb(filename)
	local f = io.open(filename)

	for line in f:lines() do
		if line:sub(0,3) ~= ";;;" then -- if this isn't a comment
			local word, pron = string.match(line, "(.+)%s%s(.+)")
			if word and pron then
				local pronDB = {}
				local pronDBold = {}
				string.gsub(pron, "(%a+)", function(phoneme)
					local stress = phoneme:find("%d+") or 0
					table.insert(pronDB, {
						phone = phoneme,
						stress = stress
					})
				end)
				
				--pronDB.word = word
				cmu._DB[word] = pronDB
			end
		end
	end

end

local spl = "\t"

function cmu.phonemes_str(phonemes)
	local str = ""
	for _, p in pairs(phonemes) do
		local stress = p.stress ~=0 and "[" .. p.stress .. "]" or ""
		str = str .. p.phone .. stress .. spl
	end
	return str
end

function cmu.wordp_str(word, phonemes)
	return word .. spl:rep(2) .. cmu.phonemes_str(phonemes)
end

function cmu.mapvtok(tbl)
	local map = {}

	for word, sim in pairs(tbl) do
		if not map[sim] then map[sim] = {} end
		table.insert(map[sim], word)
	end
end

function cmu.compare(word1, word2)
	local w1p = cmu._DB[word1]
	local w2p = cmu._DB[word2]

	local pad, first = 0, false
	if (#w1p < #w2p) then
		first = true
		pad = #w1p - #w2p
	else
		pad = #w2p - #w1p
	end

	-- ugh, doesn't work exactly as wanted, cba to fix
	print(word1 .. spl:rep(2) .. (first and spl:rep(pad) or "") .. cmu.phonemes_str(w1p))
	print(word2 .. spl:rep(2) .. (not first and spl:rep(pad) or "") .. cmu.phonemes_str(w2p))
	print("--------")
end


--cmu.loaddb("cmudict-0.7b")




return cmu