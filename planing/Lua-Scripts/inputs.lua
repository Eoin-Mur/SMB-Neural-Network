--functions to get values that can be used for inputs into the network
--Px = 0-3999 in binary = 1111 1001 1111 ---- 12 inputs
--Py = 0-255 in binary = 1111 1111 -- 8 inputs 
--i = 1-5
--Eix = 0-3999 in binary = 1111 1001 1111 ---- 12 inputs x 5
--Eiy = 0-255 in binary = 1111 1111 --- 8 inputs x 5

--j = 1-169
--Tj = 0 - 1 --- 169 inputs

-- x = (Px,Py,E1x .. E5x, E1y .. E5y, t1 .. t169)
-- total x = (12, 12, 12*5,12*5,169)
--
function getPlayerPosition()
	--Counter to incemenrt player x past 256. multiply by 0x100 to get the true value and add with screenx
	playerX = memory.readbyte(0x006D) * 0x100 + memory.readbyte(0x0086)
	playerY = memory.readbyte(0x03B8) + 16

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
end

function getEnemysLoaded()
	enemysLoaded = {}
	for enemy = 0, 4, 1 do
		enemysLoaded[enemy+1] = memory.readbyte(0x000F + enemy)
	end
	return enemysLoaded
end


function getTile(tileX,tileY)
	local x = playerX + tileX + 8
	local y = playerY + tileY - 16
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


function getScreen()
	getPlayerPosition()
	local screen = {}
	for tileY = -2*16, 2*16, 16 do
		for tileX = -2*16, 2*16, 16 do
			screen[#screen+1] = 0

			if getTile(tileX,tileY) ~= 0 and playerY+tileY < 0x1B0 then
				screen[#screen] = 1
			end

		end
	end
	return screen
end

function printScreen(screenArray)
	local currentRow = 1
	local currentColumn = 1
	gui.drawBox(10,10,10*6,10*6,0xFF000000,0xA0000000)
	for i = 1, #screenArray, 1 do
		gui.drawText(10*currentColumn,10*currentRow,screenArray[i],0xFFFFFFFF,10,"Segoe UI")
		currentColumn = currentColumn + 1
		if i % 5 == 0 and i ~= 1 then
			currentRow = currentRow + 1
			currentColumn = 1
		end
		
	end
end

function decimalToBinaryArray(decimal,arrayLen)
	if decimal == 0 then
		return {0}
	end
	local binaryArray = {}
	while decimal ~= 0 do
		binaryArray[#binaryArray+1] = decimal%2
		decimal = math.floor(decimal/2)
	end
	return binaryArray
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

	--clean up out puts
	for i=1, #outputs, 1 do
		if outputs[i] == false then
			outputs[i] = 0
		else
			outputs[i] = 1
		end
	end
	return outputs
end

function drawData()
	getPlayerPosition()
	getEnemyScreenPositions()

	gui.drawBox(150,10,255,140,0xFF000000,0xA0000000)
	gui.drawText(152,12,"PlayerX   : "..table.concat(decimalToBinaryArray(playerX),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,22,"PlayerY   : "..table.concat(decimalToBinaryArray(playerY),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,32,"Enemy1X: "..table.concat(decimalToBinaryArray(enemyPositons[1]["x"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,42,"Enemy1Y: "..table.concat(decimalToBinaryArray(enemyPositons[1]["y"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,52,"Enemy2X: "..table.concat(decimalToBinaryArray(enemyPositons[2]["x"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,62,"Enemy2Y: "..table.concat(decimalToBinaryArray(enemyPositons[2]["y"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,72,"Enemy3X: "..table.concat(decimalToBinaryArray(enemyPositons[3]["x"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,82,"Enemy3Y: "..table.concat(decimalToBinaryArray(enemyPositons[3]["y"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,92,"Enemy4X: "..table.concat(decimalToBinaryArray(enemyPositons[4]["x"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,102,"Enemy4Y: "..table.concat(decimalToBinaryArray(enemyPositons[4]["y"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,112,"Enemy5X: "..table.concat(decimalToBinaryArray(enemyPositons[5]["x"]),""),0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(152,122,"Enemy5Y: "..table.concat(decimalToBinaryArray(enemyPositons[5]["y"]),""),0xFFFFFFFF,10,"Segoe UI")

	outputs = getKeyPresses()
	gui.drawBox(10,160,60,260,0xFF000000,0xA0000000)
	gui.drawText(12,162,"A: "..outputs[1],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(12,172,"B: "..outputs[2],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(12,182,"Down: "..outputs[3],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(12,192,"Left: "..outputs[4],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(12,202,"Right: "..outputs[5],0xFFFFFFFF,10,"Segoe UI")
	gui.drawText(12,212,"Up: "..outputs[6],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawBox(190,10,255,150,0xFF000000,0xA0000000)
	--gui.drawText(192,12,"1Loaded: "..enemysLoaded[1],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,22,"2Loaded: "..enemysLoaded[2],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,32,"3Loaded: "..enemysLoaded[3],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,42,"4Loaded: "..enemysLoaded[4],0xFFFFFFFF,10,"Segoe UI")
	--gui.drawText(192,52,"5Loaded: "..enemysLoaded[5],0xFFFFFFFF,10,"Segoe UI")
end	

while true do
	tiles = getScreen()
	printScreen(tiles)
	drawData()
	emu.frameadvance()
end
