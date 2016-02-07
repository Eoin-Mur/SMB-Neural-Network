

--local STATE_FILE = "C:/Users/eoinm_000/Documents/GitHub/fourth-year-project/src/Save_States/SMB_L1-1_laptop.State" --laptop

local STATE_FILE = "C:/Users/Eoin/Documents/GitHub/fourth-year-project/src/Save_States/SMB_L1-1.State" -- desktop
local TOGGLE_UI = "ON" 
local RECORD_EXEMPLARS = "OFF"
local EXPLOIT_NET = "OFF"
local SHOW_DATA = "OFF"
local SETTINGS = "OFF"
local READY_TO_RECORD = false
local EXEMPLAR_FILENAME
local NUM_PAD1, NUM_PAD2, NUM_PAD3, NUM_PAD4, NUM_PAD5, NUM_PAD0, NUM_PAD6,ESCAPE, RETURN
local UP_ARROW,DOWN_ARROW
local RECORD_F --add to config
local ELAPSED_F = 0
local VIEW_RADIUS --add to config
local PLAYER_X, PLAYER_Y
local PREV_EXEMPLAR
local LEARN_LOG = "../Training_Logs/NETLearn_"..os.date("%b-%d-%H-%M-%S")..".xml"
local RUN_LOG = "../Run_Logs/NETRun_"..os.date("%b-%d-%H-%M-%S")..".xml"
--local NET_VAL = "../Network_Values/NETVal_"..os.date("%b_%d_%H_%M_%S")..".dat"
--local NET_VAL_XML = "../Network_Values/NETVal_"..os.date("%b_%d_%H_%M_%S")..".xml"
local NET_VALUES_FILE 
local TRAINING_FILE

--Network variables---

local NUM_INPUTS  
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

local C --add to config
local RATE --add to config

local I = {}
local y = {}
local O = {}
local w = {}
local wt = {}

local dx = {}
local dy = {}

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
		parseXMLNetvalues(NET_VALUES_FILE)
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
		SETTINGS = toggleOption(SETTINGS)
		TOGGLE_UI = toggleOption(TOGGLE_UI)
		NUM_PAD6 = false
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
			gui.drawBox(10,10,120,130,0xFF000000,0xE1000000)
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
			gui.drawText(10,112,"Settings: ",0xFFFFFFFF,10,"Segoe UI")
			gui.drawText(60,112,"NUM PAD 6",0xFFFFFF00,10,"Segoe UI")
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
			local exemplarIn = table.concat( getScreen(VIEW_RADIUS), "|")
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

function forwardPropigate()
	local x 
	--inputs -> hidden
	for j = LOW_J, HIGH_J, 1 do
		x = 0
		for i = LOW_I, HIGH_I, 1 do
			--console.log(I[i])
			x = x + ( I[i] * w[i][j] )
			y[j] = sigmod( x - wt[j] )
		end
	end
	--hidden -> output
	for k = LOW_K, HIGH_K , 1 do
		x = 0 
		for j = LOW_J, HIGH_J , 1 do
			x = x + ( y[j] * w[j][k] )
			y[k] = sigmod( x - wt[k] )
		end
	end
end

function sigmod(x,r)
	if r ~= nil then
		return round((1.0/(1+math.exp(-4.9*x))),r);
	else
		return 1.0/(1+math.exp(-4.9*x))
	end
end

function bipolarSigmod(x)
	return round((2/math.pi) * math.atan(x),3)
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
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


function logNet(f,t)
	local file = io.open(f,"a")
	file:write("inputs: ")
	for i = LOW_I, HIGH_I, 1 do
		file:write(I[i].."|")
	end
	file:write("\nNet Outputs: ")
	for k = LOW_K, HIGH_K, 1 do
		file:write(y[k].."|")
	end
	if t=="learn" then
		file:write(" Exp Outputs: ")
		for k = LOW_K, HIGH_K, 1 do
			file:write(O[k].."|")
		end
	end
	file:write("\n")
	file:close()
end

function logNet_XML(f,t)
	local file = io.open(f,"a")
	file:write("<Pass>\n")
	file:write("<Input>")
	for i = LOW_I, HIGH_I, 1 do
		file:write(I[i])
	end
	file:write("</Input>\n")
	file:write("<Net_Output>")
	for k = LOW_K, HIGH_K, 1 do
		file:write(y[k].."|")
	end
	file:write("</Net_Output>\n")
	if t=="learn" then
		file:write("<Exp_Output>")
		for k = LOW_K, HIGH_K, 1 do
			file:write(O[k].."|")
		end
		file:write("</Exp_Output>\n")
	end
	file:write("</Pass>\n")
	file:close()
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

function exploit()

	local inputs = getScreen(VIEW_RADIUS)

	drawData(false)
	local x = 1 
	for i = LOW_I, HIGH_I, 1 do
		I[i] = inputs[x]
		x = x + 1
	end

	forwardPropigate()

	local outputs = {}
	local x = 1
	for k = LOW_K, HIGH_K, 1 do
		local button = "P1 "..ButtonNames[x] 
		if y[k] > 0.5 then
			outputs[button] = true
		else
			outputs[button] = false
		end
		x = x + 1
	end	

	logNet_XML(RUN_LOG)

	return outputs
end

function parseXMLNetvalues(file)
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
		elseif line:match("<j%d+>(.+)</j%d+>") then
			index = tonumber(line:match("<j(%d+)>"))
			line = line:match("<j%d+>(.+)</j%d+>")
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
	console.log("finshed Loading Net values")
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

function drawData(drawPos)
	printScreen(getScreen(VIEW_RADIUS))

	getPlayerPosition()
	getEnemyScreenPositions()

	if drawPos == true then
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


	--gui.drawBox(150,10,210,80,0xFF000000,0xA0000000)
	--gui.drawText(152,12,"A: "..outputs[1],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(152,22,"B: "..outputs[2],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(152,32,"Down: "..outputs[3],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(152,42,"Left: "..outputs[4],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(152,52,"Right: "..outputs[5],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(152,62,"Up: "..outputs[6],0xFFFFFFFF,10,"Segoe UI")

	--gui.drawBox(190,10,255,150,0xFF000000,0xA0000000)
	--gui.drawText(192,12,"1Loaded: "..enemysLoaded[1],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,22,"2Loaded: "..enemysLoaded[2],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,32,"3Loaded: "..enemysLoaded[3],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,42,"4Loaded: "..enemysLoaded[4],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,52,"5Loaded: "..enemysLoaded[5],0xFFFFFFFF,10,"Segoe UI")
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
	VIEW_RADIUS = config["VIEW_RADIUS"]
	NUM_NUERONS = config["NUM_NUERONS"]
	C = config["C"]
	RATE = config["RATE"]
	TRAIN_ITERATIONS = config["TRAIN_ITERATIONS"]

	loadNetConfig()

end

function loadNetConfig()

	NUM_INPUTS = (VIEW_RADIUS * 2 + 1) * (VIEW_RADIUS * 2 + 1)  

	NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
 
	LOW_I = 1
	HIGH_I = NUM_INPUTS 
	LOW_J = NUM_INPUTS + 1
	HIGH_J = NUM_INPUTS + NUM_NUERONS
	LOW_K = NUM_INPUTS + NUM_NUERONS + 1
	HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

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
	gui.drawText(12,20,"TRAINING_FILE: ",highlight(1,curSel),10,"Segoe UI")
	gui.drawText(12,60,"RECORD_F: ",highlight(2,curSel),10,"Segoe UI")
	gui.drawText(12,80,"VIEW_RADIUS: ",highlight(3,curSel),10,"Segoe UI")
	gui.drawText(12,100,"NUM_NUERONS: ",highlight(4,curSel),10,"Segoe UI")
	gui.drawText(12,120,"C: ",highlight(5,curSel),10,"Segoe UI")
	gui.drawText(12,140,"RATE: ",highlight(6,curSel),10,"Segoe UI")
	gui.drawText(12,160,"TRAIN_ITERATIONS: ",highlight(7,curSel),10,"Segoe UI")
	gui.drawText(12,180,"NET_VALUES_FILE:",highlight(8,curSel),10,"Segoe UI")

	gui.drawText(24,40,TRAINING_FILE,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,60,RECORD_F,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,80,VIEW_RADIUS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,100,NUM_NUERONS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,120,C,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,140,RATE,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(120,160,TRAIN_ITERATIONS,0xFFFFFF00,10,"Segoe UI")
	gui.drawText(24,200,NET_VALUES_FILE,0xFFFFFF00,10,"Segoe UI")
	--gui.drawText(12,200,"Navigate: Up/Down",0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(110,200,"Edit: Enter",0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(160,220,"Exit: Escape",0xFFFFFFFF,10,"Segoe UI")

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
		console.log("Stuck")
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

loadConfig("../config.txt")

InitNetwork()


	--Test to verify parseing net values successfull.
--[[
StoreNetworkValues_XML( "../Network_Values/parseTestPrev2.xml" )
parseXMLNetvalues("../Network_Values/NETVal_Jan_25_18_35_15.xml")
StoreNetworkValues_XML( "../Network_Values/parseTestAfter2.xml" )
--]]

while true do
	if SHOW_DATA == "ON" then
		drawData(false)
	end
	if RECORD_EXEMPLARS == "ON" then
		recordExemplars()
	elseif EXPLOIT_NET == "ON" then
		--check if the user hits 5 again to end the net execute.
		
		resetIfStuck(10,4)
		joypad.set(exploit())
		readNumpad()
		if isPlayerDead() then
			loadSaveState(STATE_FILE)
		end
	else
		drawUI()
	end
	emu.frameadvance()
end
