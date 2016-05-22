

--local STATE_FILE = "../Save_States/SMB_L1-1_laptop.State" --laptop
local STATE_FILE = "../Save_States/SMB_L1-1.State" -- desktop
local TOGGLE_UI = "ON" 
local RECORD_EXEMPLARS = "OFF"
local EXPLOIT_NET = "OFF"
local SHOW_DATA = "OFF"
local SETTINGS = "OFF"
local READY_TO_RECORD = false
local EXEMPLAR_FILENAME
local NUM_PAD1, NUM_PAD2, NUM_PAD3, NUM_PAD4, NUM_PAD5, NUM_PAD0, NUM_PAD6, NUM_PAD7, ESCAPE, RETURN
local UP_ARROW,DOWN_ARROW
local RECORD_F --add to config
local ELAPSED_F = 0
local VIEW_RADIUS --add to config
local PLAYER_X, PLAYER_Y
local PREV_PLAYER_X ,PREV_PLAYER_Y
local MARIO_STATE = 0x0000 
local PREV_MARIO_STATE = 0x0000
local PREV_EXEMPLAR
local RUN_LOG = "../Run_Logs/NET-Run_"..os.date("%b-%d-%H-%M-%S")..".xml"
local Q_LOG = "../Training_Logs/Q_Learn_"..os.date("%b-%d-%H-%M-%S")..".train"
local Q_EXPERIENCE_LOG = "../Experiences/Q_Learn_"..os.date("%b-%d-%H-%M-%S")..".experiences"
--local NET_VAL = "../Network_Values/NETVal_"..os.date("%b_%d_%H_%M_%S")..".dat"
local NET_VAL_XML_Q = "../Network_Values/NETVal_Q-Learning_"..os.date("%b_%d_%H_%M_%S")..".xml"
local NET_TYPE
local NET_VALUES_FILE 
local TRAINING_FILE
local MAX_RADIUS = 7

--Network variables---

local NUM_INPUTS
local NUM_ACTIONS = 8 
local NUM_NUERONS --add to config
local NUM_OUTPUTS = 6

local NET_TOTAL 
 
local LOW_I 
local HIGH_I 
local LOW_J
local HIGH_J
local LOW_K 
local HIGH_K 

local TRAIN_ITERATIONS --add to config
local RUN_EXPERIENCES --config
local TEMPATURE_CEILING --added to config
local C --add to config
local RATE --add to config
local DISCOUNT_FACTOR --added to config
local SIGMOID_TYPE
local maxQT = 1.0/2
local minQT = 1.0/50
local xState
local yState

local NETWORK = {
	I = {},
	y = {},
	O = {},
	w = {},
	wt = {},

	dx = {},
	dy = {}
}

local ACTION_NETWORKS = {
	ACTION1,
	ACTION2,
	ACTION3,
	ACTION4,
	ACTION5,
	ACTION6,
	ACTION7, 	--actions left and jump at the same time
	ACTION8 	--actions right and jump at the same time
}

local EXPERIENCES = {}
local EXPERIENCE_REPLAY --added to config

--Array for control buttons used in setting from net out put---
ButtonNames = {
  "A",
  "B",
  "Down",
  "Left",
  "Right",
  "Up",
}


--Read the numpad used in the main UI to access diferent fucntions
function readNumpad()
	local inputs = input.get()
	if inputs["NumberPad1"] == true then
		NUM_PAD1 = true
	end

	if inputs["NumberPad1"] == nil and NUM_PAD1 == true then
		TOGGLE_UI = toggleOption(TOGGLE_UI)
		NUM_PAD1 = false
	end

	if inputs["NumberPad2"] == true then
		NUM_PAD2 = true
	end

	if inputs["NumberPad2"] == nil and NUM_PAD2 == true then
		loadSaveState(STATE_FILE)
		NUM_PAD2 = false
	end

	if inputs["NumberPad3"] == true then
		NUM_PAD3 = true
	end

	if inputs["NumberPad3"] == nil and NUM_PAD3 == true then
		loadSaveState(STATE_FILE)
		RECORD_EXEMPLARS = "ON"
		EXEMPLAR_FILENAME = "../Exemplar_Files/exemplars_"..VIEW_RADIUS.."_"..os.date("%b-%d-%H-%M-%S")..".dat"
		NUM_PAD3 = false
	end

	if inputs["NumberPad4"] == true then
		NUM_PAD4 = true
	end

	if inputs["NumberPad4"] == nil and NUM_PAD4 == true then
		if NET_TYPE == "ReinforcmentMul" then
			for a = 1, NUM_ACTIONS, 1 do
				parseXMLActionNetvalues(NET_VALUES_FILE,ACTION_NETWORKS["ACTION"..a],a)
			end
		else
			parseXMLNetvalues(NET_VALUES_FILE,NETWORK)
		end
		for i = 1, 120, 1 do
			gui.drawBox(50,160,180,180,0xFF000000,0xE1000000)
			gui.drawText(52,162,"Loaded Network Values!",0xFFFF0000,10,"Segoe UI")
			emu.frameadvance()
		end
		NUM_PAD4 = false
	end

	if inputs["NumberPad5"] == true then
		NUM_PAD5 = true
	end

	if inputs["NumberPad5"] == nil and NUM_PAD5 == true then
		if EXPLOIT_NET == "OFF" then
			loadSaveState(STATE_FILE)
			local file = io.open(RUN_LOG,"a")
			file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
			file:write('<?xml-stylesheet type="text/xsl" href="run_style.xsl"?>\n')
			file:write('<Network_LOG>')
			file:close()
			EXPLOIT_NET = "ON"
		else
			local file = io.open(RUN_LOG,"a")
			file:write('</Network_LOG>')
			file:close()
			EXPLOIT_NET = "OFF"
		end
		
		--EXPLOIT_NET = toggleOption(EXPLOIT_NET)
		NUM_PAD5 = false
	end

	if inputs["NumberPad0"] == true then
		NUM_PAD0 = true
	end

	if inputs["NumberPad0"] == nil and NUM_PAD0 == true then
		SHOW_DATA = toggleOption(SHOW_DATA)
		NUM_PAD0 = false
	end

	if inputs["NumberPad6"] == true then
		NUM_PAD6 = true
	end

	if inputs["NumberPad6"] == nil and NUM_PAD6 == true then
		--loadSaveState(STATE_FILE)
		if NET_TYPE == "Reinforcment" then
			Q_Learn()
		elseif NET_TYPE == "ReinforcmentMul" then
			Q_Learn_ActionNets()
		end
		NUM_PAD6 = false
	end

	if inputs["NumberPad7"] == true then
		NUM_PAD7 = true
	end

	if inputs["NumberPad7"] == nil and NUM_PAD7 == true then
		SETTINGS = toggleOption(SETTINGS)
		TOGGLE_UI = toggleOption(TOGGLE_UI)
		NUM_PAD7 = false
	end

end

function toggleOption(option)
	if option == "ON" then
		option = "OFF"
	else
		option = "ON"
	end
	return option
end

--draw the main UI
function drawUI()
	if SETTINGS == "ON" then
		settingsUI()
	else
		readNumpad()
		if TOGGLE_UI == "ON" then
			gui.drawBox(10,10,120,150,0xFF000000,0xE1000000)
			gui.drawText(10,12,"Toggle UI: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,12,"NUM PAD 1",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,32,"Load 1.1: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,32,"NUM PAD 2",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,52,"Record: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,52,"NUM PAD 3",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,72,"Load Net: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,72,"NUM PAD 4",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,92,"Exploit: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,92,"NUM PAD 5",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,112,"QLearn: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,112,"NUM PAD 6",0xFFFFFF00,10,"Segoe UI")
			gui.drawText(10,132,"Settings: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,132,"NUM PAD 7",0xFFFFFF00,10,"Segoe UI")
		end
	end
end

function loadSaveState(stateLocation)
	savestate.load(stateLocation)
end

-----------------------------------------------
--------------Input/Outputs functions-----------
-----------------------------------------------

--get marios true X and Y position
function getPlayerPosition()
	PLAYER_X = memory.readbyte(0x006D) * 0x100 + memory.readbyte(0x0086)
	PLAYER_Y = memory.readbyte(0x03B8) + 16
end

-- get the ture enemy positions 
function getEnemyScreenPositions()
	enemyPositons = {}
	for enemy = 0, 4, 1 do
		local enemyLoaded = memory.readbyte(0x000F + enemy)
		if enemyLoaded == 1 then
			enemyX = memory.readbyte(0x006E + enemy) * 0x100 + memory.readbyte(0x0087 + enemy)
			enemyY = memory.readbyte(0x00CF + enemy) + 24 
			enemyPositons[enemy+1] = {["x"] = enemyX, ["y"] = enemyY}
		else
			enemyPositons[enemy+1] = {["x"] = 0, ["y"] = 0}
		end	
	end
	return enemyPositons
end

function getHitBoxes()
	local hitBoxes = {
		mario = {},
		enemy = {}
	}

	hitBoxes.mario = 
	{
		["x1"] = memory.readbyte( 0x04AC ),
		["y1"] = memory.readbyte( 0x04AD ),
		["x2"] = memory.readbyte( 0x04AE ),
		["y2"] = memory.readbyte( 0x04AF )
	}

	--0x000F-0x0013
	local address = 0x04B0
	local x = 1
	for i = 0x000F, 0x0013, 0x0001 do
		if memory.readbyte(i) == 1 then
			hitBoxes.enemy[x] = 
			{ 
				["x1"] = memory.readbyte( address ), 
				["y1"] = memory.readbyte( address + 0x0001 ),
				["x2"] = memory.readbyte( address + 0x0002 ), 
				["y2"] = memory.readbyte( address + 0x0003 ) 
			}
			x = x + 1
		end
		address = address + 0x0004
	end
	return hitBoxes
end


function norm(value,min,max)
	return (value - min) / (max - min)
end

-- get the value of the tile passed as x and y positions.
function getTile(tileX,tileY)
	local x = PLAYER_X + tileX + 8
	local y = PLAYER_Y + tileY - 16
	local page = math.floor(x/256)%2

	local subX = math.floor((x%256)/16)
	local subY = math.floor((y-32)/16)
	local tileAddress = 0x500 + page*13*16+subY*16+subX

	if subY >= 13 or subY < 0 then
		return 0
	end

	if memory.readbyte(tileAddress) ~= 0 then
		return 1
	else 
		return 0
	end
end

-- return the screen as an array of values ranging -1 too 1
function getScreen(radius)
	getPlayerPosition()
	local enemys = getEnemyScreenPositions()
	local screen = {}
	for tileY = -radius*16, radius*16, 16 do
		for tileX = -radius*16, radius*16, 16 do
			screen[#screen+1] = 0

			if getTile(tileX,tileY) ~= 0 and PLAYER_Y + tileY < 0x1B0 then
				screen[#screen] = 1
			end

			for i = 1, #enemys,1 do
				distx = math.abs(enemys[i]["x"] - (PLAYER_X+tileX))
		        disty = math.abs(enemys[i]["y"] - (PLAYER_Y+tileY))
		        if distx <= 8 and disty <= 8 then
		          screen[#screen] = -1
		        end
      		end
		end
	end
	return screen
end

--convert binary to decimal 
-- not needed anymore
function binToDec(i)
	local dec = 0
	for j = #i, 0, -1 do
		if i[j] == 1 then
			dec = dec + 2^(#i - j)
		end
	end
	return dec
end

--read the key presses on the controler
function getKeyPresses()
	local keys = {}
	keys = joypad.getimmediate()
	local outputs = {}

	--for i = 1, #ButtonNames, 1 do
	--	outputs[i] = keys[ButtonNames[i]]
	--end
	outputs[1] = keys["P1 A"]
	outputs[2] = keys["P1 B"]
	outputs[3] = keys["P1 Down"]
	outputs[4] = keys["P1 Left"]
	outputs[5] = keys["P1 Right"]
	outputs[6] = keys["P1 Up"]

	--clean up out puts convert to 1 and 0
	for i=1, #outputs, 1 do
		if outputs[i] == false then
			outputs[i] = 0
		else
			outputs[i] = 1
		end
	end
	return outputs
end


-----------------------------------------------------
-------------- END Input/Outputs functions-----------
-----------------------------------------------------


------------------------------------------------------
---------------Exemplar fuctions----------------------
------------------------------------------------------

--old input scheme where i pass in also the player and enemy x and y
function getExemplarInputString(del)
	local inputsString

	local enemyPositons = getEnemyScreenPositions()
	local screenArray = getScreen(VIEW_RADIUS)

	inputsString = PLAYER_X..del..PLAYER_Y..del..enemyPositons[1]["x"]..
		del..enemyPositons[1]["y"]..del..enemyPositons[2]["x"]..del..enemyPositons[2]["y"]..
		del..enemyPositons[3]["x"]..del..enemyPositons[3]["y"]..del..enemyPositons[4]["x"]..
		del..enemyPositons[4]["y"]..del..enemyPositons[5]["x"]..del..enemyPositons[5]["y"]..
		del..table.concat( screenArray, del)

	return inputsString
end

function getExemplarOutputString(del)
	return table.concat(getKeyPresses(),del)
end

--write the current exemplars to file
function recordExemplars()
	if READY_TO_RECORD ~= false then
		if isPlayerDead() == true then
			loadSaveState(STATE_FILE)
		end

		gui.drawBox(10,10,120,30,0xFF000000,0xA0000000)
		gui.drawText(10,12,"RECORDING EXEMPLARS",0xFFFF0000,10,"Segoe UI")

		if ELAPSED_F < RECORD_F and RECORD_EXEMPLARS == "ON" then
			local exemplarIn = table.concat( getScreen(MAX_RADIUS), "|")
			local exemplarOut = getExemplarOutputString("|")
			local file = io.open(EXEMPLAR_FILENAME,"a")

			if PREV_EXEMPLAR == nil then
				PREV_EXEMPLAR = exemplarIn 
			end

			file:write(PREV_EXEMPLAR..";"..exemplarOut.."\n")
			file:close()
			PREV_EXEMPLAR = exemplarIn
			ELAPSED_F = ELAPSED_F + 1
		else 
			RECORD_EXEMPLARS = "OFF"
			READY_TO_RECORD = false
			ELAPSED_F = 0
		end
	else 
		readyToRecord()
	end
end

--flag to begin exemplar recording
function readyToRecord()

	gui.drawBox(10,100,130,120,0xFF000000,0xA0000000)
	gui.drawText(10,102,"PRESS ANY KEY TO START",0xFFFF0000,10,"Segoe UI")

	if checkKeyPress(getKeyPresses()) == true then
		READY_TO_RECORD = true
	end
end

------------------------------------------------------
---------------END Exemplar fuctions------------------
------------------------------------------------------

--returns if a key has been pressed
function checkKeyPress(keys)
	for i=1, #keys, 1 do
		if keys[i] == 1 then
			return true
		end
	end
	return false
end

--returns if the player is dead
function isPlayerDead()
	if memory.readbyte(0x000E) == 0x06 then
		return true
	else 
		return false
	end
end

---------------------------------------------------------
-----------Network Functions-----------------------------
---------------------------------------------------------

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function InitNetwork(net)
	for i = LOW_I, HIGH_I, 1 do
		net.w[i] = {}
		for j = LOW_J, HIGH_J , 1 do
			net.w[i][j] = randomFloat( -C, C )
		end
	end

	for j = LOW_J, HIGH_J, 1 do
		net.w[j] = {}
		for k = LOW_K, HIGH_K, 1 do
			net.w[j][k] = randomFloat( -C, C)
		end
	end

	for j = LOW_J, HIGH_J, 1 do
		net.wt[j] = randomFloat( -C, C)
	end

	for k = LOW_K, HIGH_K, 1 do
		net.wt[k] = randomFloat( -C, C)
	end
	return net
end

function forwardPropigate(net)
	local x 
	--inputs -> hidden
	for j = LOW_J, HIGH_J, 1 do
		x = 0
		for i = LOW_I, HIGH_I, 1 do
			x = x + ( net.I[i] * net.w[i][j] )
			if SIGMOID_TYPE == "binary" then
				net.y[j] = sigmod( x - net.wt[j])
			else 
				net.y[j] = bipolarSigmod( x - net.wt[j])
			end
		end
	end
	--hidden -> output
	for k = LOW_K, HIGH_K , 1 do
		x = 0 
		for j = LOW_J, HIGH_J , 1 do
			x = x + ( net.y[j] * net.w[j][k] )
			if SIGMOID_TYPE == "binary" then
				net.y[k] = sigmod( x - net.wt[k])
			else 
				net.y[k] = bipolarSigmod( x - net.wt[k])
			end
		end
	end
	return net
end

function sigmod(x,r)
	if r ~= nil then
		return round((1.0/(1+math.exp(-4.9*x))),r);
	else
		return 1.0/(1+math.exp(-4.9*x))
	end
end

function bipolarSigmod(x,r)
	if r ~= nil then
		return round((2/math.pi) * math.atan(x),r)
	else
		return (2/math.pi) * math.atan(x)
	end
end


--removed +0.5 to just turnicate and not round
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

--console.log(round(0.061856471638378,1))

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


function logNet(f,net)
	local file = io.open(f,"a")
	file:write("inputs: ")
	for i = LOW_I, HIGH_I, 1 do
		file:write(net.I[i].."|")
	end
	file:write("\nNet Outputs: ")
	for k = LOW_K, HIGH_K, 1 do
		file:write(net.y[k].."|")
	end
	if t=="learn" then
		file:write(" Exp Outputs: ")
		for k = LOW_K, HIGH_K, 1 do
			file:write(net.O[k].."|")
		end
	end
	file:write("\n")
	file:close()
end

function logNet_XML(f,net)
	local file = io.open(f,"a")
	file:write("<Pass>\n")
	file:write("<Input>")
	for i = LOW_I, HIGH_I, 1 do
		file:write(net.I[i])
	end
	file:write("</Input>\n")
	file:write("<Net_Output>")
	for k = LOW_K, HIGH_K, 1 do
		file:write(net.y[k].."|")
	end
	file:write("</Net_Output>\n")
	if t=="learn" then
		file:write("<Exp_Output>")
		for k = LOW_K, HIGH_K, 1 do
			file:write(net.O[k].."|")
		end
		file:write("</Exp_Output>\n")
	end
	file:write("</Pass>\n")
	file:close()
end

function StoreQLearningNetworkValues_XML(f)
	local file = io.open(f,"w")
	file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
	file:write('<Q-Learning_NETWORKS>\n')
	for a = 1 , NUM_ACTIONS, 1 do
		file:write('<ACTION_NET'..a..">\n")
		file:write('<IL_HL_Weights>\n')
		for i = LOW_I, HIGH_I, 1 do
			file:write('<i'..i..'>')
			for j = LOW_J, HIGH_J , 1 do
				file:write(ACTION_NETWORKS["ACTION"..a].w[i][j].."|")
			end
				file:write('</i'..i..'>\n')
		end
		file:write('<iT>')
		for j = LOW_J, HIGH_J, 1 do
			file:write(ACTION_NETWORKS["ACTION"..a].wt[j].."|")
		end
		file:write('</iT>\n')
		file:write('</IL_HL_Weights>\n')

		file:write('<HL_OL_Weights>\n')
		for j = LOW_J, HIGH_J, 1 do
			file:write('<j'..j..'>')
			for k = LOW_K, HIGH_K, 1 do
				file:write(ACTION_NETWORKS["ACTION"..a].w[j][k].."|")
			end
				file:write('</j'..j..'>\n')
		end
		file:write('<jT>')
		for k = LOW_K, HIGH_K, 1 do
			file:write(ACTION_NETWORKS["ACTION"..a].wt[k].."|")
		end
		file:write('</jT>\n')
		file:write('</HL_OL_Weights>\n')
		file:write('</ACTION_NET'..a..">\n")
	end
	file:write('</Q-Learning_NETWORKS>\n')
	file:close()
end

function parseXMLActionNetvalues(file,net,a)
	console.log("Loading net values for: "..a)
	local e
	local x
	local index 
	local inBlock = false
	for line in io.lines(file) do
		if line:match("<ACTION_NET"..a..">") then 
			inBlock = true
		elseif line:match("</ACTION_NET"..a..">") then 
			inBlock = false
			return net
		end
		if inBlock then
			--input to hiden layer values
			if line:match("<i%d+>(.+)</i%d+>") then
				index = tonumber(line:match("<i(%d+)>"))
				line = line:match("<i%d+>(.+)</i%d+>")
				e = split(line,"|")
				x = 1
				for j = LOW_J, HIGH_J ,1 do
					net.w[index][j] = e[x]
					x = x + 1
				end

			--input to hidden layer thresholds
			elseif line:match("<iT>(.+)</iT>") then
				line = line:match("<iT>(.+)</iT>")
				e = split(line,"|")
				x = 1
				for j = LOW_J, HIGH_J, 1 do
					net.wt[j] = e[x]
					x = x +1
				end

			--hiden to output layer
			elseif line:match("<j%d+>(.+)</j%d+>") then
				index = tonumber(line:match("<j(%d+)>"))
				line = line:match("<j%d+>(.+)</j%d+>")
				e = split(line,"|")
				x = 1
				for k = LOW_K, HIGH_K, 1 do
					net.w[index][k] = e[x]
					x = x +1
				end

			--hidden to output layer thresholds
			elseif line:match("<jT>(.+)</jT>") then
				line = line:match("<jT>(.+)</jT>")
				e = split(line,"|")
				x = 1
				for k = LOW_K, HIGH_K, 1 do
					net.wt[k] = e[x]
					x = x +1
				end
			end
		end --end inblock
	end
	console.log("Finshed Loading net values for: "..a)
	return net
end

function getInputs()
	local inp = {}
	local screen = getScreen(VIEW_RADIUS)
	local enemyPositons = getEnemyScreenPositions()

	inp[1] = PLAYER_X
	inp[2] = PLAYER_Y

	for i = 1, #enemyPositons, 1 do
		inp[#inp+1] = enemyPositons[i]["x"]
		inp[#inp+1] = enemyPositons[i]["y"]
	end 

	for i = 1, #screen, 1 do
		inp[#inp+1] = screen[i] 
	end
	return inp
end

function exploit(net)

	local inputs = getScreen(VIEW_RADIUS)

	drawData(false)
	local x = 1 
	for i = LOW_I, HIGH_I, 1 do
		net.I[i] = inputs[x]
		x = x + 1
	end

	forwardPropigate(net)

	local outputs = {}
	local x = 1
	for k = LOW_K, HIGH_K, 1 do
		local button = "P1 "..ButtonNames[x] 
		--if round(y[k],1) >= 0.1 then
		if net.y[k] > 0.5 then
			outputs[button] = true
		else
			outputs[button] = false
		end
		x = x + 1
	end	

	logNet_XML(RUN_LOG,net)

	return outputs
end

function parseXMLNetvalues(file,net)
	console.log("Loading net values")
	local e
	local x
	local index 
	for line in io.lines(file) do
		--input to hiden layer values
		if line:match("<i%d+>(.+)</i%d+>") then
			index = tonumber(line:match("<i(%d+)>"))
			line = line:match("<i%d+>(.+)</i%d+>")
			e = split(line,"|")
			x = 1
			for j = LOW_J, HIGH_J ,1 do
				net.w[index][j] = e[x]
				x = x + 1
			end

		--input to hidden layer thresholds
		elseif line:match("<iT>(.+)</iT>") then
			line = line:match("<iT>(.+)</iT>")
			e = split(line,"|")
			x = 1
			for j = LOW_J, HIGH_J, 1 do
				net.wt[j] = e[x]
				x = x +1
			end

		--hiden to output layer
		elseif line:match("<j%d+>(.+)</j%d+>") then
			index = tonumber(line:match("<j(%d+)>"))
			line = line:match("<j%d+>(.+)</j%d+>")
			e = split(line,"|")
			x = 1
			for k = LOW_K, HIGH_K, 1 do
				net.w[index][k] = e[x]
				x = x +1
			end

		--hidden to output layer thresholds
		elseif line:match("<jT>(.+)</jT>") then
			line = line:match("<jT>(.+)</jT>")
			e = split(line,"|")
			x = 1
			for k = LOW_K, HIGH_K, 1 do
				net.wt[k] = e[x]
				x = x +1
			end
		end
	end
	console.log("finshed Loading Net values")
	return net
end

---------------------------------------------------------
-----------END Network Functions-------------------------
---------------------------------------------------------

function printScreen(screenArray)
	local currentRow = 1
	local currentColumn = 1
	gui.drawBox(10,10,10*((VIEW_RADIUS*2)+2),10*((VIEW_RADIUS*2)+2),0xFF000000,0xFFFFFFFF)
	for i = 1, #screenArray, 1 do
		if screenArray[i] == 0 then
			gui.drawBox(10*currentColumn,10*currentRow,(10*currentColumn)+10,(10*currentRow)+10,0xFF000000,0x00000000)
		elseif screenArray[i] == 1 then
			gui.drawBox(10*currentColumn,10*currentRow,(10*currentColumn)+10,(10*currentRow)+10,0xFF000000,0xFFFFFF00)
		else
			gui.drawBox(10*currentColumn,10*currentRow,(10*currentColumn)+10,(10*currentRow)+10,0xFF00000,0xFFFF0000)
		end
		--gui.drawText(10*currentColumn,10*currentRow,screenArray[i],0xFFFFFFFF,10,"Segoe UI")
		currentColumn = currentColumn + 1

		if i % ((VIEW_RADIUS*2)+1) == 0 and i ~= 1 then
			currentRow = currentRow + 1
			currentColumn = 1
		end
	end
end

function drawHitBoxes()
	getPlayerPosition()
	getEnemyScreenPositions()
	local hitBoxes = getHitBoxes()
	gui.drawBox(hitBoxes.mario["x1"],hitBoxes.mario["y1"], hitBoxes.mario["x2"], hitBoxes.mario["y2"],0xFF000000,0xE1000000)
	for i = 1, #hitBoxes.enemy, 1 do
		gui.drawBox(hitBoxes.enemy[i]["x1"],hitBoxes.enemy[i]["y1"], hitBoxes.enemy[i]["x2"], hitBoxes.enemy[i]["y2"],0xFF000000,0xE1000000)
	end
end

function drawData(drawPos)
	printScreen(getScreen(VIEW_RADIUS))

	--drawHitBoxes()
	drawController()
	if drawPos == true then
		drawPosData()
	end
end	

function drawPosData()
	getPlayerPosition()
	getEnemyScreenPositions()

	gui.drawBox(150,10,255,140,0xFF000000,0xA0000000)
	gui.drawText(152,12,"PlayerX   : "..PLAYER_X,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,22,"PlayerY   : "..PLAYER_Y,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,32,"Enemy1X: "..enemyPositons[1]["x"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,42,"Enemy1Y: "..enemyPositons[1]["y"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,52,"Enemy2X: "..enemyPositons[2]["x"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,62,"Enemy2Y: "..enemyPositons[2]["y"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,72,"Enemy3X: "..enemyPositons[3]["x"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,82,"Enemy3Y: "..enemyPositons[3]["y"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,92,"Enemy4X: "..enemyPositons[4]["x"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,102,"Enemy4Y: "..enemyPositons[4]["y"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,112,"Enemy5X: "..enemyPositons[5]["x"],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,122,"Enemy5Y: "..enemyPositons[5]["y"],0xFFFFFFFF,10,"Segoe UI")
end

function drawController()
	outputs = getKeyPresses()

	--controler output
	gui.drawBox(150,30,250,70,0xFF000000,0xFFB8B8B8)
	gui.drawRectangle(165,34,5,10,0xFF000000,highlightKey(outputs,6,0xFF000000)) --up
	gui.drawRectangle(153,46,10,5,0xFF000000,highlightKey(outputs,4,0xFF000000)) --left
	gui.drawRectangle(165,53,5,10,0xFF000000,highlightKey(outputs,3,0xFF000000)) --down
	gui.drawRectangle(172,46,10,5,0xFF000000,highlightKey(outputs,5,0xFF000000)) --right
	gui.drawRectangle(187,46,10,5,0xFF000000,0xFF000000) --select (not outputed)
	gui.drawRectangle(202,46,10,5,0xFF000000,0xFF000000) --start (not outputed)
	gui.drawEllipse(217,44,10,10,0xFF000000,highlightKey(outputs,2,0xFF000000)) --B
	gui.drawEllipse(232,44,10,10,0xFF000000,highlightKey(outputs,1,0xFF000000)) --A
end

function highlightKey(outputs,key,defaultColour)
	if outputs[key] == 1 then
		return 0xFFFF0000
	else
		return defaultColour
	end
end

function parseConfig(filename)
	local config = {}
	for line in io.lines(filename) do
		line = line:match("%s*(.+)") -- only read in lines that have characters 
		if line and line:sub(1,1) ~= "#" and line:sub(1,1) ~= ";" then 
			option = line:match("(.*)%s+") --string of any char's followed by one or more space
			value = line:match("%s+(.*)") -- all characters after one or more space
			config[option] = value
		end
	end
	return config
end

function loadConfig(filename)
	local config = parseConfig(filename)
	NET_VALUES_FILE = config["NET_VALUES_FILE"]
	TRAINING_FILE = config["TRAINING_FILE"]
	RECORD_F = tonumber(config["RECORD_F"])
	VIEW_RADIUS = tonumber(config["VIEW_RADIUS"])
	NUM_NUERONS = tonumber(config["NUM_NUERONS"])
	C = tonumber(config["C"])
	RATE = tonumber(config["RATE"])
	DISCOUNT_FACTOR = tonumber(config["DISCOUNT_FACTOR"])
	SIGMOID_TYPE = config["SIGMOID_TYPE"]
	TRAIN_ITERATIONS = tonumber(config["TRAIN_ITERATIONS"])
	RUN_EXPERIENCES = tonumber(config["RUN_EXPERIENCES"])
	NET_TYPE = config["NET_TYPE"];
	EXPERIENCE_REPLAY = tonumber(config["EXPERIENCE_REPLAY"])
	TEMPATURE_CEILING = tonumber(config["TEMPATURE_CEILING"])
	loadNetConfig()

end

function loadNetConfig()
	if NET_TYPE == "ReinforcmentMul" then
		ACTION_NETWORKS.ACTION1 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION2 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION3 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION4 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION5 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION6 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION7 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		ACTION_NETWORKS.ACTION8 = {I = {},y = {},O = {},w = {},wt = {},dx = {},dy = {}}
		NUM_OUTPUTS = 1
	end
	if NET_TYPE == "Reinforcment" then 
		NUM_INPUTS = ( (VIEW_RADIUS * 2 + 1) * (VIEW_RADIUS * 2 + 1)  ) + NUM_ACTIONS
		NUM_OUTPUTS = 1
		NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
	 
		LOW_I = 1
		HIGH_I = NUM_INPUTS 
		LOW_J = NUM_INPUTS + 1
		HIGH_J = NUM_INPUTS + NUM_NUERONS
		LOW_K = NUM_INPUTS + NUM_NUERONS + 1
		HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
	else 
		NUM_INPUTS = (VIEW_RADIUS * 2 + 1) * (VIEW_RADIUS * 2 + 1)  

		NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
	 
		LOW_I = 1
		HIGH_I = NUM_INPUTS 
		LOW_J = NUM_INPUTS + 1
		HIGH_J = NUM_INPUTS + NUM_NUERONS
		LOW_K = NUM_INPUTS + NUM_NUERONS + 1
		HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
	end

end

function printVariables()
	console.log("DEBUG PRINT:")
	console.log(TRAINING_FILE)
	console.log(RECORD_F)
	console.log(VIEW_RADIUS)
	console.log(NUM_NUERONS)
	console.log(C)
	console.log(RATE)
	console.log(TRAIN_ITERATIONS)
	console.log(NUM_INPUTS)
	console.log(NET_TOTAL)
end

local maxSel = 7
local curSel = 1
function settingsUI()

	local inputs = input.get()
	gui.drawBox(10,10,240, 240,0xFF000000,0xE1000000)
	--gui.drawText(12,20,"TRAINING_FILE: ",highlight(1,curSel),10,"Segoe UI")
	gui.drawText(12,12,"NET_TYPE: ",highlight(1,curSel),10,"Segoe UI")
	gui.drawText(12,32,"RECORD_F: ",highlight(2,curSel),10,"Segoe UI")
	gui.drawText(12,52,"VIEW_RADIUS: ",highlight(3,curSel),10,"Segoe UI")
	gui.drawText(12,72,"NUM_NUERONS: ",highlight(4,curSel),10,"Segoe UI")
	gui.drawText(12,92,"C: ",highlight(5,curSel),10,"Segoe UI")
	gui.drawText(12,112,"RATE: ",highlight(6,curSel),10,"Segoe UI")
	gui.drawText(12,132,"TRAIN_ITERATIONS: ",highlight(7,curSel),10,"Segoe UI")
	gui.drawText(12,152,"NET_VALUES_FILE:",highlight(8,curSel),10,"Segoe UI")

	--gui.drawText(24,40,TRAINING_FILE,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,12,NET_TYPE,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,32,RECORD_F,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,52,VIEW_RADIUS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,72,NUM_NUERONS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,92,C,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,112,RATE,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,132,TRAIN_ITERATIONS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(24,172,NET_VALUES_FILE,0xFFFFFF00,10,"Segoe UI")
	--gui.drawText(12,200,"Navigate: Up/Down",0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(110,200,"Edit: Enter",0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(160,200,"Exit: Escape",0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(30,200,"Reload: NUM1",0xFFFFFFFF,10,"Segoe UI")
	--not sure if iam going to allow users to edit from bizhawk
	--unless i can find a way to disable the bizhawk hot keys while in a read keyboard function


	if inputs["Escape"] == true then
		ESCAPE = true
	end

	if inputs["Escape"] == nil and ESCAPE == true then
		TOGGLE_UI = toggleOption(TOGGLE_UI)
		SETTINGS = toggleOption(SETTINGS)
		ESCAPE = false
	end

	if inputs["NumberPad1"] == true then
		NUM_PAD1 = true
	end

	if inputs["NumberPad1"] == nil and NUM_PAD1 == true then
		loadConfig("../config.txt")
		console.log("blah")
		if NET_TYPE == "ReinforcmentMul" then
			
			ACTION_NETWORKS.ACTION1 = InitNetwork(ACTION_NETWORKS.ACTION1 )
			ACTION_NETWORKS.ACTION2 = InitNetwork(ACTION_NETWORKS.ACTION2 )
			ACTION_NETWORKS.ACTION3 = InitNetwork(ACTION_NETWORKS.ACTION3 )
			ACTION_NETWORKS.ACTION4 = InitNetwork(ACTION_NETWORKS.ACTION4 )
			ACTION_NETWORKS.ACTION5 = InitNetwork(ACTION_NETWORKS.ACTION5 )
			ACTION_NETWORKS.ACTION6 = InitNetwork(ACTION_NETWORKS.ACTION6 )
			ACTION_NETWORKS.ACTION7 = InitNetwork(ACTION_NETWORKS.ACTION7 )
			ACTION_NETWORKS.ACTION8 = InitNetwork(ACTION_NETWORKS.ACTION8 )
				
		else
			NETWORK = InitNetwork(NETWORK)
		end

		NUM_PAD1 = false
	end

--[[
	if inputs["Return"] == true then
		RETURN = true
	end

	if inputs["Return"] == nil and RETURN == true then

		RETURN = false
	end

	--nav keys
	if inputs["UpArrow"] == true then
		UP_ARROW = true
	end

	if inputs["UpArrow"] == nil and UP_ARROW == true then
		curSel = toggleSel(curSel,maxSel,"UP")
		UP_ARROW = false
	end

	if inputs["DownArrow"] == true then
		DOWN_ARROW = true
	end

	if inputs["DownArrow"] == nil and DOWN_ARROW == true then
		curSel = toggleSel(curSel,maxSel,"DOWN")
		DOWN_ARROW = false
	end
	-]]

end

function  toggleSel( sel, maxSel, dir )
	if dir == "UP" then
		if sel == 1 then
			return maxSel
		else
			return sel-1
		end
	else 
		if sel == maxSel then
			return 1
		else
			return sel+1
		end
	end
end

function highlight(itemNum, currentSel)
	if(currentSel == itemNum) then
		return 0xFFFF0000
	else 
		return 0xFFFFFFFF
	end
end

--if marios x position hasnt moved for x amount of frames 
--set the controllers values all to 0 and let the net reset.
--for a set amount of reset frames
local previousX = 0
local previousY = 0
local stuckFramesElapsed = 0
function resetIfStuck(f,rF)
	if PLAYER_X == previousX and PLAYER_Y == previousY then
		stuckFramesElapsed = stuckFramesElapsed + 1
	else
		stuckFramesElapsed = 0
		previousX = PLAYER_X
		previousY = PLAYER_Y
	end

	if stuckFramesElapsed == f then
		local outputs = {}
		local x = 1
		for k = LOW_K, HIGH_K, 1 do
			local button = "P1 "..ButtonNames[x] 
			outputs[button] = false
			x = x + 1
		end
		local i = 1
		while i ~= rF do
			emu.frameadvance()
			i = i + 1
		end
		joypad.set(outputs)
		stuckFramesElapsed = 0
	end
end
	--Test to verify parseing net values successfull.
--[[
StoreNetworkValues_XML( "../Network_Values/parseTestPrev2.xml" )
parseXMLNetvalues("../Network_Values/NETVal_Jan_25_18_35_15.xml")
StoreNetworkValues_XML( "../Network_Values/parseTestAfter2.xml" )
--]]

function displayQvalues(qValues)
	gui.drawBox(150,80,250,170,0xFF000000,0xA0000000)
	gui.drawText(152,82,"Q(x,A): "..qValues[1].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,92,"Q(x,B): "..qValues[2].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,102,"Q(x,D): "..qValues[3].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,112,"Q(x,L): "..qValues[4].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,122,"Q(x,R): "..qValues[5].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,132,"Q(x,U): "..qValues[6].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,142,"Q(x,L A): "..qValues[7].value,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,152,"Q(x,R A): "..qValues[8].value,0xFFFFFFFF,10,"Segoe UI")
end

function displayBoltzValues(qValues_Boltz)
	gui.drawBox(10,130,122,200,0xFF000000,0xA0000000)
	gui.drawText(10,132,"P(x|A): "..qValues_Boltz[1].boltzD,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(10,142,"P(x|B): "..qValues_Boltz[2].boltzD,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(10,152,"P(x|D): "..qValues_Boltz[3].boltzD,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(10,162,"P(x|L): "..qValues_Boltz[4].boltzD,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(10,172,"P(x|R): "..qValues_Boltz[5].boltzD,0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(10,182,"P(x|U): "..qValues_Boltz[6].boltzD,0xFFFFFFFF,10,"Segoe UI")
end
function displayR( r )
	--	150,30,250,70
	gui.drawBox(150,10,250,28,0xFF000000,0xA0000000)
	gui.drawText(150,12,"Reinforcment: "..r,0xFFFFFFFF,10,"Segoe UI")
end

function displayX(inputs)
	gui.drawBox(10,100,130,110,0xFF000000,0xA0000000)
	for i = 1, HIGH_I,1 do
		gui.drawText(6+(i*4),102," "..inputs[i].." ",0xFFFFFFFF,6,"Segoe UI")
	end
end

--qlearning algorithm with actions passed as inputs to the network
function Q_Learn( )
	loadSaveState(STATE_FILE)
	for steps = 0, TRAIN_ITERATIONS, 1 do
		local inputs = getScreen(VIEW_RADIUS)
		local qValues = {}
		for a = 1, NUM_ACTIONS, 1 do
			local x = 1 
			for i = LOW_I, HIGH_I - NUM_ACTIONS, 1 do
				NETWORK.I[i] = inputs[x]
				x = x + 1
			end
			for ia = 1, NUM_ACTIONS, 1 do
				if ia == a then 
					NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 1
				else
					NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 0
				end 
 			end
			forwardPropigate(NETWORK)
			qValues[#qValues + 1] = 
			{
				value = NETWORK.y[HIGH_K],
				state = inputs,
				action = a
			}
		end

		local qValues_Boltz = calculateBolzmannDist(qValues, temperature(steps))
		local qxa = chooseAction(qValues_Boltz)
		xState = qxa.state
		PREV_MARIO_STATE = memory.readbyte(0x001D)

		displayQvalues(qValues)
		drawData(false)

		local buttons = {}
		for a = 1, #ButtonNames, 1 do
			if a == qxa.action then
				buttons["P1 "..ButtonNames[a]] = true
			else
				buttons["P1 "..ButtonNames[a]] = false
			end
		end
		local elapsedFrames = 0
		while table.concat(xState,"") == table.concat(getScreen(VIEW_RADIUS), "") do
			if elapsedFrames > 180 then -- if after 100 frames mario hasnt reached a new state then break to allow for a new action to be tried
				break
			end
			displayQvalues(qValues)
			drawData(false)
			joypad.set( buttons )
			PREV_PLAYER_X = PLAYER_X
			PREV_PLAYER_Y = PLAYER_Y
			emu.frameadvance()
			resetTime( )
			MARIO_STATE = memory.readbyte(0x001D)
			elapsedFrames = elapsedFrames + 1
		end

		resetJumpOnAirToGround(buttons)

		--get next state
		inputs = getScreen(VIEW_RADIUS)
		qValues = {}
		for a = 1, NUM_ACTIONS, 1 do
			local x = 1 
			for i = LOW_I, HIGH_I - NUM_ACTIONS, 1 do
				NETWORK.I[i] = inputs[x]
				x = x + 1
			end
			for ia = 1, NUM_ACTIONS, 1 do
				if ia == a then 
					NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 1
				else
					NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 0
				end 
 			end
			forwardPropigate(NETWORK)
			qValues[#qValues + 1] = 
			{
				value = NETWORK.y[HIGH_K],
				state = inputs,
				action = a
			}
		end

		local qyb = highestQ(qValues)
		yState = qyb.state

		local r = getReinformentValues()
		local ok = r + (DISCOUNT_FACTOR * qyb.value)
		local yk = qxa.value
		yk = ((1-RATE) * yk) + (RATE * ok)
		for i = LOW_I, HIGH_I, 1 do
			NETWORK.I[i] = qxa.state[i]
		end
		for ia = 1, NUM_ACTIONS, 1 do
			if ia == qxa.action then 
				NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 1
			else
				NETWORK.I[(HIGH_I - NUM_ACTIONS)+ia] = 0
			end 
		end
		forwardPropigate(NETWORK)
		backPropigate_QValue(yk, ok, NETWORK)

		logQLearn(qxa, qyb, r, ok, yk)
		storeExperience(qxa.state, qxa.action, qyb.state, r)
		if hitEnemy() or fellInPit() then
			loadSaveState(STATE_FILE)
		end
	end
	StoreQLearningNetworkValues_XML( NET_VAL_XML_Q , ACTION_NETWORKS)
end

function Q_Learn_ActionNets()
	local total_epochs = 0
	for run = 1, TRAIN_ITERATIONS, 1 do
		--drawData(false)
		local runFinshed = false
		loadSaveState(STATE_FILE)
		EXPERIENCES = {}
		local epoch = 0
		-- if we want to train untill it beats the level
		--while(runFinshed == false) do

		while(epoch < RUN_EXPERIENCES) do
			epoch = epoch+1
			total_epochs = total_epochs + 1
			gui.drawBox(150,10,250,28,0xFF000000,0xA0000000)
			gui.drawText(150,10,"Epoch: "..epoch.." Run: "..run,0xFFFFFFFF,10,"Segoe UI")
			local inputs = getScreen(VIEW_RADIUS)
			--first we pass the state through the net for each possible action and get all the qvalues
			local qValues = {}
			--for each action
			for a = 1, NUM_ACTIONS, 1 do
				--load the the state inputs to pass through net
				for i = LOW_I, HIGH_I, 1 do
					ACTION_NETWORKS["ACTION"..a].I[i] = inputs[i]
				end
				--pass the inputs through the net
				forwardPropigate(ACTION_NETWORKS["ACTION"..a])
				--add the outputed qvalues to out list of qvalues
				qValues[#qValues + 1] = 
				{
					value = ACTION_NETWORKS["ACTION"..a].y[HIGH_K],
					state = inputs,
					action = a
				}

			end
			local qValues_Boltz = calculateBolzmannDist(qValues, temperature(total_epochs))
			local qxa = chooseAction(qValues_Boltz)
			if qxa == nil then
				console.log(qValues)
				console.log(qValues_Boltz)
				for i = 1, #qValues, 1 do 
					console.log(qValues[i])
				end
				console.log("---------------")
				for i = 1, #qValues_Boltz, 1 do 
					console.log(qValues_Boltz[i])
				end
			end
			--local qxa = highestQ(qValues_Boltz)
			xState = qxa.state
			PREV_MARIO_STATE = memory.readbyte(0x001D)

			displayQvalues(qValues)
			--displayBoltzValues(qValues_Boltz)
			drawData(false)

			--now set the controler for each according to the action taken
			local buttons = {}
			for a = 1, #ButtonNames, 1 do
				if a == qxa.action then
					buttons["P1 "..ButtonNames[a]] = true
				else
					buttons["P1 "..ButtonNames[a]] = false
				end
			end
			if qxa.action == 7 then
				buttons["P1 Left"] = true
				buttons["P1 A"] = true
			elseif qxa.action == 8 then
				buttons["P1 Right"] = true
				buttons["P1 A"] = true
			end
			--console.log( buttons )
			--execute controler button press and move to next frame/state
			local elapsedFrames = 0
			while table.concat(xState,"") == table.concat(getScreen(VIEW_RADIUS), "") do
				if elapsedFrames > 180 then -- if after 100 frames mario hasnt reached a new state then break to allow for a new action to be tried
					break
				end
				if completedLevel() then
					runFinshed = true
				end
				gui.drawBox(150,10,250,28,0xFF000000,0xA0000000)
				gui.drawText(150,10,"Epoch: "..epoch.." Run: "..run,0xFFFFFFFF,10,"Segoe UI")
				displayQvalues(qValues)
				--displayBoltzValues(qValues_Boltz)
				drawData(false)
				joypad.set( buttons )
				PREV_PLAYER_X = PLAYER_X
				PREV_PLAYER_Y = PLAYER_Y
				emu.frameadvance()
				resetTime( )
				MARIO_STATE = memory.readbyte(0x001D)
				elapsedFrames = elapsedFrames + 1
			end

			resetJumpOnAirToGround(buttons)

			--get our reincforment values for the new state.
			--reward if mario progressed further into the level(PLAYER_X increases) NOTE:may need to alter this
			--punish if mario dies
				-- *gets hit by a enemy (getHitboxes() function if marios hit box falls inside a enemys hit box) NOTE: will need to alter this
					--in case it doest reflect in training that previsous states lead to death ie. mario jumped to late and as such the state in which mario actually hit the enemy may hae a different action 
					-- then the state that initaly caused it...... i need to write up all this more detail outside of comments..
					--TODO:write up report on potental/identifyed problems/resolutions
				-- *falls into a pit (where PLAYER_Y position falls below 16 pixels, this is ass each tile is a 16x16 sprite so the top of the floor should be on the 16 pixel level )
			--get the next state
			inputs = getScreen(VIEW_RADIUS)

			--displayR(r)
			--calculate ok
			--local ok = r + (DISCOUNT_FACTOR *qxa.value)

			--now calulate our yk value and back propigate the error through the net to adjust the weights
			--set our qvalues list to be empty
			qValues = {}
			for a = 1, NUM_ACTIONS, 1 do
				--load the the state inputs to pass through net
				for i = LOW_I, HIGH_I, 1 do
					ACTION_NETWORKS["ACTION"..a].I[i] = inputs[i]
				end
				forwardPropigate(ACTION_NETWORKS["ACTION"..a])
				qValues[#qValues + 1] = 
				{
					value = ACTION_NETWORKS["ACTION"..a].y[HIGH_K],
					state = inputs,
					action = a
				}
			end

			local qyb = highestQ(qValues)
			yState = qyb.state

			local r = getReinformentValues()
			--displayR(r)
			local ok
			if hitEnemy() or fellInPit() then
				ok = r 
				console.log("terminal State!")
			else 
				 ok = r + (DISCOUNT_FACTOR * qyb.value)
			end
			local yk = qxa.value
			yk = ((1-RATE) * yk) + (RATE * ok)

			--yk = yk + RATE * (ok - yk)
		
		--[[
			console.log("X = ")
			console.log(qxa)
			console.log("Y = ")
			console.log(qyb)
			console.log("R = "..r)
			console.log("ok: "..ok)
			console.log("yk:"..yk)
		--]]
			
			--pass back the original state to the network we are updating
			for i = LOW_I, HIGH_I, 1 do
				ACTION_NETWORKS["ACTION"..qxa.action].I[i] = qxa.state[i]
			end

			forwardPropigate(ACTION_NETWORKS["ACTION"..qxa.action])

			backPropigate_QValue(yk, ok, ACTION_NETWORKS["ACTION"..qxa.action])

			logQLearn(qxa, qyb, r, ok, yk)
			storeExperience(qxa.state, qxa.action, qyb.state, r)

			-- if the resulting action cause mario to die we need to reload the game to the start 
			--or else if we leave it the reulting jumps in memory could coruppt the net.
			if hitEnemy() or fellInPit() then
				loadSaveState(STATE_FILE)
			end
			if completedLevel() then
				runFinshed = true
			end

			--if we are running for a set number of experiences we need to reload the savestate
			--if the agent reachs the end instead of moving to a new run
			--REMOVE THIS IF USING TRAINING UNTILL BEAT
			if runFinshed == true then
				console.log("completed Level!")
				loadSaveState(STATE_FILE)
				runFinshed = false
			end

		end --end while
		console.log(total_epochs)
		replayExperiences()
	end
	StoreQLearningNetworkValues_XML( NET_VAL_XML_Q , ACTION_NETWORKS)
end

function resetJumpOnAirToGround(buttons)
	if PREV_MARIO_STATE >= 0x0001 and MARIO_STATE == 0x0000 and buttons["P1 A"] == true then
		buttons["P1 A"] = false
		joypad.set(buttons)
		emu.frameadvance()
		buttons["P1 A"] = true
	end
end

function storeExperience(x,a,y,r)
	EXPERIENCES[#EXPERIENCES+1] = 
	{
		StateX = x,
		action = a,
		StateY = y,
		reward = r
	}

	--[[
	local file = io.open(Q_EXPERIENCE_LOG,"a")
	file:write(
		table.concat( x, "|")..
		";"..a..
		";"..table.concat( y, "|")..
		";"..r.."\n"
	)
	file:close()
	--]]
end

function expOccurence( exp )
	local x = 0;
	for i = 1, #EXPERIENCES, 1 do
		local cur = EXPERIENCES[i]
		if cur.StateX == exp.StateX and cur.StateY == exp.StateY
		and cur.reward == exp.reward and cur.action == exp.action then
			x = x + 1
		end
	end
	return x - 1
end

function completedLevel()
	--if the sound effect register 3 is set to zero
	--the game is playing the flagpoll sound when mario beats the level
	if memory.readbyte(0x00FF) == 64 then
		return true
	end
	return false
end
	
function replayExperiences()
	gui.drawBox(10,180,250,204,0xFF000000,0xE1000000)
	gui.drawText(2,182,"Replaying "..#EXPERIENCES.." Experiences From Last Run "..EXPERIENCE_REPLAY.." Times!",0xFFFFFFFF,10,"Segoe UI")
	--client.pause() --stope emulation to avoid the emulator from crashing from not having a new frame rendered (doesnt actually work sometimes Best of just calling frame advance)
	--emu.yield()
	for replay = 1, EXPERIENCE_REPLAY, 1 do
		--replay experiences backwares
		for e = #EXPERIENCES, 1, -1 do
		--for e = 1, #EXPERIENCES, 1 do
			gui.drawBox(10,180,240,204,0xFF000000,0xE1000000)
			gui.drawText(12,182,"Replaying Experiences: "..replay.."/"..EXPERIENCE_REPLAY..
				" Experience: "..e.."/"..#EXPERIENCES,0xFFFFFFFF,10,"Segoe UI")
			local qxa = {}
			local qValues = {}
			for i = LOW_I, HIGH_I, 1 do
				ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action].I[i] = EXPERIENCES[e].StateX[i]
			end
			forwardPropigate(ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action])
			qxa = { 
				value = ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action].y[HIGH_K],
				state = EXPERIENCES[e].StateX,
				action = EXPERIENCES[e].action
			}
			for a = 1, NUM_ACTIONS, 1 do
					for i = LOW_I, HIGH_I, 1 do
						ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action].I[i] = EXPERIENCES[e].StateY[i]
					end
					forwardPropigate(ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action])
					qValues[#qValues + 1] = 
					{
						value = ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action].y[HIGH_K],
						state = inputs,
						action = a
					}
			end
			local qyb = highestQ(qValues)

			local ok = EXPERIENCES[e].reward + (DISCOUNT_FACTOR * qyb.value)
			local yk = qxa.value
			yk = ((1-RATE) * yk) + (RATE * ok)

			for i = LOW_I, HIGH_I, 1 do
				ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action].I[i] = EXPERIENCES[e].StateX[i]
			end
			forwardPropigate(ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action])
			backPropigate_QValue(yk, ok, ACTION_NETWORKS["ACTION"..EXPERIENCES[e].action])
			
			emu.frameadvance()--stop bizhawk from crashing when a frame isnt loaded after a while
		end
	end--end replay loop
	client.unpause()
end

function logQLearn(qxa, qyb, r, ok, yk)
	local file = io.open(Q_LOG,"a")
	file:write("Q(x,a): \n")
	file:write("action: "..qxa.action)
	file:write(" , State: "..table.concat( qxa.state, ""))
	file:write(" , value: "..qxa.value)
	file:write(" , Boltz: "..qxa.boltzD)
	file:write("\nQ(y,b): \n")
	file:write("action: "..qyb.action)
	file:write(" , State: "..table.concat( qyb.state, ""))
	file:write(" , value: "..qyb.value)
	file:write("\n\nReinforcment value for x,a: "..r)
	file:write("\nok: "..ok)
	file:write("\nyk: "..yk)
	file:write("\nE = (yk-ok)^2 = "..math.pow(yk-ok,2))
	file:write("\nyk - ok = "..yk - ok)
	file:write("\nUpdated Qvalue for Q(x,a): ")
	if NET_TYPE == "ReinforcmentMul" then
		for i = LOW_I, HIGH_I, 1 do
			ACTION_NETWORKS["ACTION"..qxa.action].I[i] = qxa.state[i]
		end
		forwardPropigate(ACTION_NETWORKS["ACTION"..qxa.action])
		file:write(ACTION_NETWORKS["ACTION"..qxa.action].y[HIGH_K])
	else
		for i = LOW_I, HIGH_I, 1 do
			NETWORK.I[i] = qxa.state[i]
		end
		for a = 1, NUM_ACTIONS, 1 do
			if a == qxa.action then
				NETWORK.I[(HIGH_I - NUM_ACTIONS)+a ] = 1
			else
				NETWORK.I[(HIGH_I - NUM_ACTIONS)+a ] = 1
			end
		end
		forwardPropigate(NETWORK)
		file:write(NETWORK.y[HIGH_K])
	end
	file:write("\n---------------------------------------------\n")
	file:close()
end

function backPropigate_QValue(yk,ok,net)
	local dw

	--net.dy[HIGH_K] = math.pow((ok - yk),2)
	net.dy[HIGH_K] = (yk-ok)
	--totalError = totalError +  math.pow(dy[k],2) 
	net.dx[HIGH_K] = ( net.dy[HIGH_K] ) * yk * (1-yk)

	for j = LOW_J, HIGH_J, 1 do
		local t = 0
		for k = LOW_K, HIGH_K, 1 do
			t = t + ( net.dx[k] * net.w[j][k] )
		end
		net.dy[j] = t
		net.dx[j] = (net.dy[j] ) * net.y[j] * ( 1- net.y[j])
	end
	-----------------------------------------
	for j = LOW_J, HIGH_J, 1 do
		for k = LOW_K, HIGH_K, 1 do
			dw = net.dx[k] * net.y[j]
			--logError("outputLayerError.csv",dx[k],dw)
			net.w[j][k] = net.w[j][k] - (RATE * dw)
		end
	end

	for i = LOW_I, HIGH_I, 1 do
		for j = LOW_J, HIGH_J, 1 do
			dw = net.dx[j] * net.I[i]
			--logError("inputLayerError.csv",dx[j],dw)
			net.w[i][j] = net.w[i][j] - (RATE * dw)
		end 
	end

	for k = LOW_K, HIGH_K, 1 do
		dw = net.dx[k] * (-1)
		net.wt[k] = net.wt[k] - ( RATE * dw )
	end

	for j = LOW_J, HIGH_J, 1 do
		dw = net.dx[j] * (-1)
		net.wt[j] = net.wt[j] - ( RATE * dw)
	end
	return net
end

function highestQ(qValues)
	local q = qValues[1]

	for i = 2, #qValues, 1 do
		if qValues[i].value > q.value then
			q = qValues[i]
		end
	end	
	return q
end


function chooseHighestBoltz( QA )
	local highest = QA[1]

	for i = 2, #QA, 1 do
		if QA[i].boltzD > highest.boltzD then
			highest = QA[i]
		end
	end
	return highest
end

function chooseAction( QA )
	local x = randomFloat(0.1,1) --dont want it to give a value of zero
	local i = 0
	local sum = 0
	while sum < x do
		i = i+1
		sum = sum + QA[i].boltzD;
		if i == NUM_ACTIONS and sum < x then
			return QA[NUM_ACTIONS]
		end
	end
	if QA[i] == nil then
		console.log("x:"..x)
		console.log(i)
	end
	return QA[i]
end

function calculateBolzmannDist(qValues, T )
	local QA_list = {}

	local x = 0
	for b = 1, #qValues, 1 do
		x = x + math.exp(qValues[b].value / T)
	end
	for i = 1, #qValues, 1 do
		QA_list[#QA_list+1] = 
		{
			value = qValues[i].value,
			state = qValues[i].state,
			action = i,
			boltzD = (math.exp(qValues[i].value / T ) / x)
		}	
	end
	return QA_list
end

function temperature(steps)
	if steps >= TRAIN_ITERATIONS then
		return minQT
	else
		local e = steps / TEMPATURE_CEILING
		return minQT + (1-e) *(maxQT-minQT)
	end
end

function inputsToMatrix(inputs)
	local matrix = {}
	local currentRow = 1
	local currentColumn = 1
	matrix[currentRow] = {}
	for i = 1, #inputs, 1 do

		matrix[currentRow][currentColumn] = inputs[i]
		currentColumn = currentColumn + 1

		if i % ((VIEW_RADIUS*2)+1) == 0 and i ~= 1 then
			currentRow = currentRow + 1
			currentColumn = 1
			matrix[currentRow] = {}
		end
	end
	return matrix
end


function inFrontOfObsticle( state )
	local m = inputsToMatrix( state )
	local marioRow 
	--if mario is airborn we have to actually read the row below him as his hitbox it appears shifts down in the air
	if memory.readbyte(0x001D) == 0x0001 then
		marioRow = m[VIEW_RADIUS+3]
	else
		marioRow = m[VIEW_RADIUS+2]
	end
	--there is a solid object in at most a two tile radius of mario and on his x axis
	--return their is an obsticle in front
	if marioRow[VIEW_RADIUS+2] == 1 then
		return true
	end
	return false
end

function getColumn(matrix , columnNumber)
	local column = {}
	for i = 1, #matrix, 1 do
		column[#column+1] = matrix[i][columnNumber]
	end

	return column
end

function  closerOverObject( prevState, newState )
	if inFrontOfObsticle( newState ) == false then
		return false 
	end
	local M1 = inputsToMatrix( prevState )
	local M2 = inputsToMatrix( newState )

	local M1Col = getColumn(M1,VIEW_RADIUS+2)
	local M2Col = getColumn(M2,VIEW_RADIUS+2)
	--console.log("prev")
	--console.log(M1Col)
	--console.log("New")
	--console.log(M2Col)
	for i = 1, #M1Col, 1 do 
		--if we are on the ground we dont want to read row represnting the goround
		--as this will result in a false positive simply from mario jumping
		if memory.readbyte(0x001D) == 0 and i == (VIEW_RADIUS + 3) then
			return false
		end
		if M1Col[i] == 1 and M2Col[i] == 0 and joypad.get()["P1 A"] == true and memory.readbyte(0x0003) == 1 then
			return true
		end
	end
	return false
end

function overObject( prevState, newState )
	
end

function enemyInRadius( state )
	local m = inputsToMatrix(state)
	local marioRow = m[VIEW_RADIUS+2]

	if marioRow[VIEW_RADIUS+2] == -1 or marioRow[VIEW_RADIUS+3] == -1 
		or marioRow[VIEW_RADIUS] == -1 or marioRow[VIEW_RADIUS-1] == -1 then
		return true
	else
		return false
	end
end

function  closerOverEnemy( prevState, newState )
	if enemyInRadius(prevState) == false then
		return false
	end 

	local M1 = inputsToMatrix( prevState )
	local M2 = inputsToMatrix( newState )

	--enemy to the right of mario
	local M1ColR = getColumn(M1,VIEW_RADIUS+2)
	local M2ColR = getColumn(M2,VIEW_RADIUS+2)

	--enemy to the left of mario
	local M1ColL = getColumn(M1,VIEW_RADIUS)
	local M2ColL = getColumn(M2,VIEW_RADIUS)

	--console.log("prev")
	--printMatrix(M1)
	--console.log("new")
	--printMatrix(M2)

	--check the right side of mario
	for i = 1, #M1ColR, 1 do
		if i == #M1ColR then 
			if M1ColR[i] == -1 and M2ColR[i] == 0 then
				return true
			end
			return false
		end
		if M1ColR[i] == -1 and M2ColR[i+1] == -1 then
			return true
		end
	end

	--check the left side of mario
	for i = 1, #M1ColL, 1 do
		if i == #M1ColL then 
			if M1ColL[i] == -1 and M2ColL[i] == 0 then
				return true
			end
			return false
		end
		if M1ColL[i] == -1 and M2ColL[i+1] == -1 then
			return true
		end
	end
	return false
end

function  exploitQNet()
	drawData(false)
	local inputs = getScreen(VIEW_RADIUS)
		--first we pass the state through the net for each possible action and get all the qvalues
	local qValues = {}

	--for each action
	for a = 1, NUM_ACTIONS, 1 do
		--load the the state inputs to pass through net
		local x = 1 
		for i = LOW_I, HIGH_I, 1 do
			ACTION_NETWORKS["ACTION"..a].I[i] = inputs[x]
			x = x + 1
		end

		--pass the inputs through the net
		forwardPropigate(ACTION_NETWORKS["ACTION"..a])
		--add the outputed qvalues to out list of qvalues
		qValues[#qValues + 1] = 
			{
				value = ACTION_NETWORKS["ACTION"..a].y[HIGH_K],
				state = inputs,
				action = a
			}
	end

	local qxa = highestQ(qValues)
	displayQvalues(qValues)
	local buttons = {}
	for a = 1, #ButtonNames, 1 do
		if a == qxa.action then
			buttons["P1 "..ButtonNames[a]] = true
		else
			buttons["P1 "..ButtonNames[a]] = false
		end
	end
	if qxa.action == 7 then
			buttons["P1 Left"] = true
			buttons["P1 A"] = true
		elseif qxa.action == 8 then
			buttons["P1 Right"] = true
			buttons["P1 A"] = true
		end

	resetJumpOnAirToGround(buttons)
	joypad.set( buttons )

end

function getReinformentValues( )
	--if the agent was hit by a enemy penilise
	local r = 0.0
	if hitEnemy() then 
		r = -0.2
		return r
	end
	--if the agent fell in a hole penelise
	if fellInPit() then
		r = -0.2
		return r
	end
	--reward the agent if it got closer over an obsticle in its path
	if closerOverObject(xState,yState) then
		r = r + 0.2
	end
	--reward the agent if it got closer over an enemy in its path
	if closerOverEnemy(xState,yState) then
		r = r + 0.2
	end
	--penilise the agent if it took an action that didnt lead to a new state
	if table.concat( xState, "") == table.concat( yState, "") then
		r = r -0.04
	end
	if PREV_PLAYER_X < PLAYER_X then
		r = r + 0.1
	end
	--otherwise if the action was of no benifit penilise
	if r == 0.0 then 
		r = r -0.02
	end
	return r
end

function hitEnemy(  )
	if memory.readbyte(0x000E) == 0x000B then
		return true
	end
	return false
end

function fellInPit()
	getPlayerPosition()
	if(PLAYER_Y * memory.readbyte(0x00B5) > 198 ) and MARIO_STATE > 0 then
		return true
	end
	return false
end

function resetTime( )
	if memory.readbyte(0x07F8) == 1 then
		memory.writebyte(0x07F8,0x0009) 
		memory.writebyte(0x07F9,0x0009) 
		memory.writebyte(0x07FA,0x0009) 
	end
end


loadConfig("../config.txt")

if NET_TYPE == "ReinforcmentMul" then
	
	ACTION_NETWORKS.ACTION1 = InitNetwork(ACTION_NETWORKS.ACTION1 )
	ACTION_NETWORKS.ACTION2 = InitNetwork(ACTION_NETWORKS.ACTION2 )
	ACTION_NETWORKS.ACTION3 = InitNetwork(ACTION_NETWORKS.ACTION3 )
	ACTION_NETWORKS.ACTION4 = InitNetwork(ACTION_NETWORKS.ACTION4 )
	ACTION_NETWORKS.ACTION5 = InitNetwork(ACTION_NETWORKS.ACTION5 )
	ACTION_NETWORKS.ACTION6 = InitNetwork(ACTION_NETWORKS.ACTION6 )
	ACTION_NETWORKS.ACTION7 = InitNetwork(ACTION_NETWORKS.ACTION7 )
	ACTION_NETWORKS.ACTION8 = InitNetwork(ACTION_NETWORKS.ACTION8 )
		
else
	NETWORK = InitNetwork(NETWORK)
end

function printMatrix(m)
	for y = 1, #m, 1 do
		console.log(table.concat(m[y]))
	end
end

--printMatrix(inputsToMatrix(getScreen(VIEW_RADIUS)))
--console.log(getColumn(inputsToMatrix(getScreen(VIEW_RADIUS)) , VIEW_RADIUS+2))

while true do
	if SHOW_DATA == "ON" then
		drawData(false)
	end
	if RECORD_EXEMPLARS == "ON" then
		recordExemplars()
	elseif EXPLOIT_NET == "ON" then
		--check if the user hits 5 again to end the net execute.
		if NET_TYPE == "ReinforcmentMul" then
			exploitQNet()
			readNumpad()
		else
			buttons = exploit(NETWORK)
			resetJumpOnAirToGround(buttons)
			joypad.set(buttons)
			readNumpad()
			--if isPlayerDead() then
			--	loadSaveState(STATE_FILE)
			--end
		end
	else
		drawUI()
	end
	PREV_MARIO_STATE = MARIO_STATE
	emu.frameadvance()
	MARIO_STATE = memory.readbyte(0x001D)
	--console.log(completedLevel())
end
