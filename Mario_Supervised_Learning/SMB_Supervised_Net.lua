

local STATE_FILE = "C:/Users/eoinm_000/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Save_States/SMB_L1-1_laptop.State" --laptop

---local STATE_FILE = "C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Save_States/SMB_L1-1.State" -- desktop
local TOGGLE_UI = "ON" 
local RECORD_EXEMPLARS = "OFF"
local EXPLOIT_NET = "OFF"
local READY_TO_RECORD = false
local EXEMPLAR_FILENAME
local NUM_PAD1, NUM_PAD2, NUM_PAD3, NUM_PAD4, NUM_PAD5
local RECORD_F = 1000
local ELAPSED_F = 0

local PLAYER_X, PLAYER_Y

local NUM_INPUTS = 37
local NUM_NUERONS = 1
local NUM_OUTPUTS = 6

local NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
 
local LOW_I = 1
local HIGH_I = NUM_INPUTS 
local LOW_J = NUM_INPUTS + 1
local HIGH_J = NUM_INPUTS + NUM_NUERONS
local LOW_K = NUM_INPUTS + NUM_NUERONS + 1
local HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

local C = 0.1
local RATE = 0.8

local I = {}
local y = {}
local O = {}
local w = {}
local wt = {}

local dx = {}
local dy = {}

ButtonNames = {
  "A",
  "B",
  "Down",
  "Left",
  "Right",
  "Up",
}


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
		EXEMPLAR_FILENAME = "DAT_Files/exemplars_"..os.date("%b_%d_%H_%M_%S")..".dat"
		NUM_PAD3 = false
	end

	if inputs["NumberPad4"] == true then
		NUM_PAD4 = true
	end

	if inputs["NumberPad4"] == nil and NUM_PAD4 == true then
		learn("DAT_Files/exemplars_Nov_04_14_57_56.dat")
		NUM_PAD4 = false
	end

	if inputs["NumberPad5"] == true then
		NUM_PAD5 = true
	end

	if inputs["NumberPad5"] == nil and NUM_PAD5 == true then
		EXPLOIT_NET = "ON"
		NUM_PAD5 = false
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

function drawUI()
	readNumpad()
	if TOGGLE_UI == "ON" then
		gui.drawBox(10,10,120,110,0xFF000000,0xA0000000)
		gui.drawText(10,12,"Toggle UI: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(60,12,"NUM PAD 1",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(10,32,"Load 1.1: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(60,32,"NUM PAD 2",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(10,52,"Record: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(60,52,"NUM PAD 3",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(10,72,"Learn: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(60,72,"NUM PAD 4",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(10,92,"Exploit: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(60,92,"NUM PAD 5",0xFFFFFF00,10,"Segoe UI")
	end
end

function loadSaveState(stateLocation)
	savestate.load(stateLocation)
end

function getPlayerPosition()
	PLAYER_X = memory.readbyte(0x006D) * 0x100 + memory.readbyte(0x0086)
	PLAYER_Y = memory.readbyte(0x03B8) + 16
end

function getEnemyScreenPositions()
	enemyPositons = {}
	for enemy = 0, 4, 1 do
		local enemyLoaded = memory.readbyte(0x000F + enemy)
		if enemyLoaded == 1 then
			enemyX = memory.readbyte(0x006E + enemy) * 0x100 + memory.readbyte(0x0087 + enemy)
			enemyY = memory.readbyte(0x00CF + enemy) + 8 
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

function getScreen(radius)
	getPlayerPosition()
	local screen = {}
	for tileY = -radius*16, radius*16, 16 do
		for tileX = -radius*16, radius*16, 16 do
			screen[#screen+1] = 0

			if getTile(tileX,tileY) ~= 0 and PLAYER_Y + tileY < 0x1B0 then
				screen[#screen] = 1
			end

		end
	end
	return screen
end

function getKeyPresses()
	local keys = {}
	keys = joypad.getimmediate()
	local outputs = {}
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

function getExemplarInputString(del)
	local inputsString

	local enemyPositons = getEnemyScreenPositions()
	local screenArray = getScreen(2)

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

function recordExemplars()
	if READY_TO_RECORD ~= false then
		if isPlayerDead() == true then
			loadSaveState(STATE_FILE)
		end

		gui.drawBox(10,10,120,30,0xFF000000,0xA0000000)
		gui.drawText(10,12,"RECORDING EXEMPLARS",0xFFFF0000,10,"Segoe UI")

		if ELAPSED_F < RECORD_F and RECORD_EXEMPLARS == "ON" then
			local file = io.open(EXEMPLAR_FILENAME,"a")
			file:write(getExemplarInputString("|")..";"..getExemplarOutputString("|").."\n")
			file:close()
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

function readyToRecord()

	gui.drawBox(10,100,130,120,0xFF000000,0xA0000000)
	gui.drawText(10,102,"PRESS ANY KEY TO START",0xFFFF0000,10,"Segoe UI")

	if checkKeyPress(getKeyPresses()) == true then
		READY_TO_RECORD = true
	end
end

function checkKeyPress(keys)
	for i=1, #keys, 1 do
		if keys[i] == 1 then
			return true
		end
	end
	return false
end

function isPlayerDead()
	if memory.readbyte(0x000E) == 0x06 then
		return true
	else 
		return false
	end
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

function backPropigate()
	local dw

	for k = LOW_K, HIGH_K, 1 do
		dy[k] = y[k] - O[k];
		dx[k] = ( dy[k] ) * y[k] * (1-y[k])
	end

	for j = LOW_J, HIGH_J, 1 do
		local t = 0
		for k = LOW_K, HIGH_K, 1 do
			t = t + ( dx[k] * w[j][k] )
		end
		dy[j] = t
		dx[j] = (dy[j] ) * y[j] * ( 1- y[j])
	end
	-----------------------------------------
	for j = LOW_J, HIGH_J, 1 do
		for k = LOW_K, HIGH_K, 1 do
			dw = dx[k] * y[j]
			w[j][k] = w[j][k] - (RATE * dw)
		end
	end

	for i = LOW_I, HIGH_I, 1 do
		for j = LOW_J, HIGH_J, 1 do
			dw = dx[j] * I[i]
			w[i][j] = w[i][j] - (RATE * dw)
		end 
	end

	for k = LOW_K, HIGH_K, 1 do
		dw = dx[k] * (-1)
		wt[k] = wt[k] - ( RATE * dw )
	end

	for j = LOW_J, HIGH_J, 1 do
		dw = dx[j] * (-1)
		wt[j] = wt[j] - ( RATE * dw)
	end
end

function sigmod(x)
	return round((1/(1+math.exp(-4.9*x))),3);
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

function learn(filename)
	gui.drawBox(10,10,120,30,0xFF000000,0xA0000000)
	gui.drawText(10,12,"TRAINING NETWORK!",0xFFFF0000,10,"Segoe UI")
	for line in io.lines(filename) do
		local s1 = string.sub(line,1,string.find(line,";") -1)
		local s2 = string.sub(line,string.find(line,";")+1,string.len(line))

		eI = split(s1,"|")
		eO = split(s2,"|")

		local x = 1
		for i = LOW_I, HIGH_I, 1 do
			I[i] = eI[x]
			x = x + 1
		end

		x = 1
		for k = LOW_K, HIGH_K, 1 do
			O[k] = eO[x]
			x = x + 1
		end 

		forwardPropigate()

		backPropigate()

		logNet("DAT_Files/NETTest.dat")
	end

end

function logNet(f)
	local file = io.open(f,"a")
	file:write("inputs: ")
	for i = LOW_I, HIGH_I, 1 do
		file:write(I[i].."|")
	end
	file:write(" Net Outputs: ")
	for k = LOW_K, HIGH_K, 1 do
		file:write(y[k].."|")
	end
	file:write("\n")
	file:close()
end

function getInputs()
	local inp = {}
	local screen = getScreen(2)
	local enemyPositons = getEnemyScreenPositions()

	inp[1] = PLAYER_X
	inp[2] = PLAYER_Y

	for i = 1, #enemyPositons, 1 do
		inp[#inp+1] = enemyPositons[i]["x"]
		inp[#inp+2] = enemyPositons[i]["y"]
	end 

	local x = 1
	for i = 1, #screen, 1 do
		inp[#inp+1] = screen[x] 
		x = x + 1	
	end
	return inp
end

function exploit()

	local inputs = getInputs()

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

	joypad.set(outputs)

	for i = 1, #outputs, 1 do
		outputs[ButtonNames[i]] = false
	end

	joypad.set(outputs)
	
	logNet("DAT_Files/NETTest.dat")

end


InitNetwork()

while true do
	if RECORD_EXEMPLARS == "ON" then
		recordExemplars()
	elseif EXPLOIT_NET == "ON" then
		exploit()
	else
		drawUI()
	end
	emu.frameadvance()
end
