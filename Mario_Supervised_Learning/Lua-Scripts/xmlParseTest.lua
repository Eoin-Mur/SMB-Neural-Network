local VIEW_RADIUS = 4

local NUM_INPUTS  
local NUM_NUERONS = 20--add to config
local NUM_OUTPUTS = 6

local NET_TOTAL 
 
local LOW_I 
local HIGH_I 
local LOW_J
local HIGH_J
local LOW_K 
local HIGH_K 

local C = 0.1

NUM_INPUTS = (VIEW_RADIUS * 2 + 1) * (VIEW_RADIUS * 2 + 1)  

NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

LOW_I = 1
HIGH_I = NUM_INPUTS 
LOW_J = NUM_INPUTS + 1
HIGH_J = NUM_INPUTS + NUM_NUERONS
LOW_K = NUM_INPUTS + NUM_NUERONS + 1
HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

local w = {}
local wt = {}

function parseXMLNetvalues(file)
	local e
	local x
	local index 
	for line in io.lines(file) do
		--input to hiden layer values
		if line:match("<i%d>(.+)</i%d>") then
			index = tonumber(line:match("<i(%d+)>"))
			line = line:match("<i%d>(.+)</i%d>")
			e = split(line,"|")
			x = 1
			for j = LOW_J, HIGH_J ,1 do
				w[index][j] = e[x]
				x = x + 1
			end

		--input to hidden layer thresholds
		elseif line:match("<iT>(.+)</iT>") then
			line = line:match("<iT>(.+)</iT>")
			e = split(line,"|")
			x = 1
			for j = LOW_J, HIGH_J, 1 do
				wt[j] = e[x]
				x = x +1
			end

		--hiden to output layer
		elseif line:match("<j%d>(.+)</j%d>") then
			index = tonumber(line:match("<j(%d+)>"))
			line = line:match("<j%d>(.+)</j%d>")
			e = split(line,"|")
			x = 1
			for k = LOW_K, HIGH_K, 1 do
				w[index][k] = e[x]
				x = x +1
			end

		--hidden to output layer thresholds
		elseif line:match("<jT>(.+)</jT>") then
			line = line:match("<jT>(.+)</jT>")
			e = split(line,"|")
			x = 1
			for k = LOW_K, HIGH_K, 1 do
				wt[k] = e[x]
				x = x +1
			end
		end
	end
end

function split(str, pat)
   local t = {}  
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 			table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function InitNetwork()
	for i = LOW_I, HIGH_I, 1 do
		w[i] = {}
		for j = LOW_J, HIGH_J , 1 do
			w[i][j] = randomFloat( -C, C )
		end
	end

	for j = LOW_J, HIGH_J, 1 do
		w[j] = {}
		for k = LOW_K, HIGH_K, 1 do
			w[j][k] = randomFloat( -C, C)
		end
	end

	for j = LOW_J, HIGH_J, 1 do
		wt[j] = randomFloat( -C, C)
	end

	for k = LOW_K, HIGH_K, 1 do
		wt[k] = randomFloat( -C, C)
	end
end
InitNetwork()
parseXMLNetvalues("../Network_Values/NETVal_Jan_21_21_11_06.xml")