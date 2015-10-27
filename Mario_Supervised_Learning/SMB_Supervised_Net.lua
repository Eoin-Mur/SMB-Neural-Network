local STATE_FILE = "C:/Users/Eoin/Documents/GitHub/fourth-year-project/Mario_Supervised_Learning/Save_States/SMB_L1-1.State"

local TOGGLE_UI = "ON" 
local RECORD_EXEMPLARS = "OFF"
local EXEMPLAR_FILENAME = "DAT_Files/exemplars_"..os.date("%b_%d_%H_%M_%S")..".dat"
console.log(EXEMPLAR_FILENAME)
local NUM_PAD1, NUM_PAD2, NUM_PAD3, NUM_PAD4
local RECORD_F = 100
local ELAPSED_F = 0

function toggleOption(option)
	if option == "ON" then
		option = "OFF"
	else
		option = "ON"
	end
	return option
end

function drawUI()
	readInputs()
	if TOGGLE_UI == "ON" then
		gui.drawBox(150,10,255,140,0xFF000000,0xA0000000)
		gui.drawText(150,12,"Toggle UI: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(200,12,"NUM PAD 1",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(150,32,"Load 1.1: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(200,32,"NUM PAD 2",0xFFFFFF00,10,"Segoe UI")
		gui.drawText(150,52,"Record: ",0xFFFFFFFF,10,"Segoe UI")
		gui.drawText(200,52,"NUM PAD 3",0xFFFFFF00,10,"Segoe UI")
	end
end

function loadSaveState(stateLocation)
	savestate.load(stateLocation)
end

function recordExemplars()
	if ELAPSED_F < RECORD_F and RECORD_EXEMPLARS == "ON" then
		local file = io.open(EXEMPLAR_FILENAME,"a")
		file:write("test\n")
		file:close()
		ELAPSED_F = ELAPSED_F + 1
	else 
		RECORD_EXEMPLARS = "OFF"
	end
end

function readInputs()
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
		RECORD_EXEMPLARS = "ON"
		NUM_PAD3 = false
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
