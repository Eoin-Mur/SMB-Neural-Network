local STATE_FILE = "C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Save_States/SMB_L1-1.State"

local TOGGLE_UI = "ON" 
local RECORD_EXEMPLARS = "OFF"
local READY_TO_RECORD = false
local EXEMPLAR_FILENAME
local NUM_PAD1, NUM_PAD2, NUM_PAD3, NUM_PAD4, NUM_PAD5
local RECORD_F = 1000
local ELAPSED_F = 0

local PLAYER_X, PLAYER_Y

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
		NUM_PAD4 = false
	end

	if inputs["NumberPad5"] == true then
		NUM_PAD5 = true
	end

	if inputs["NumberPad5"] == nil and NUM_PAD5 == true then
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

while true do
	if RECORD_EXEMPLARS ~= "ON" then
		drawUI()
	else 
		recordExemplars()
	end
	emu.frameadvance()
end
