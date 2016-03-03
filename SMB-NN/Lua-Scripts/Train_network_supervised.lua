local	LEARN_LOG = "../Training_Logs/NET-Learn_"..os.date("%b-%d-%H-%M-%S")..".xml"

local	NET_VAL_XML = "../Network_Values/NET-Values.xml"
local	TRAIN_ITERATIONS
local	TRAINING_FILE
local	NUM_INPUTS 
local	NUM_NUERONS --add to config
local	NUM_OUTPUTS = 6
local	NET_VALUES_FILE

local	NET_TOTAL 
	 
local	LOW_I
local	HIGH_I
local	LOW_J
local	HIGH_J
local	LOW_K
local	HIGH_K

local	C --add to config
local	RATE --add to config

local	I = {}
local	y = {}
local	O = {}
local	w = {}
local	wt = {}

local	dx = {}
local	dy = {}

local	ButtonNames = {
  "A",
  "B",
  "Down",
  "Left",
  "Right",
  "Up",
}


function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
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


function InitNetwork()
	print("Initiating Network!")
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
			y[j] = sigmod( x - wt[j])
		end
	end
	--hidden -> output
	for k = LOW_K, HIGH_K , 1 do
		x = 0 
		for j = LOW_J, HIGH_J , 1 do
			x = x + ( y[j] * w[j][k] )
			y[k] = sigmod( x - wt[k])
		end
	end
end

local totalError

function backPropigate()
	local dw

	for k = LOW_K, HIGH_K, 1 do
		dy[k] = y[k] - O[k]
		totalError = totalError +  math.pow(dy[k],2) 
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
			--logError("outputLayerError.csv",dx[k],dw)
			w[j][k] = w[j][k] - (RATE * dw)
		end
	end

	for i = LOW_I, HIGH_I, 1 do
		for j = LOW_J, HIGH_J, 1 do
			dw = dx[j] * I[i]
			--logError("inputLayerError.csv",dx[j],dw)
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

function logError(filename,E,epoch)
	
	local file = io.open(filename,'a')
	file:write(E..","..epoch.."\n")
	file:close()
end

function run(inputs)

	--local inputs = getScreen(VIEW_RADIUS)

	printScreen(inputs)
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


function StoreNetworkValues( f )
	local file = io.open(f,"a")
	file:write("##Inputs->Hidden weights\n")
	for i = LOW_I, HIGH_I, 1 do
		for j = LOW_J, HIGH_J , 1 do
			file:write(w[i][j].."|")
		end
			file:write("\n")
	end
	file:write("##Tresholds\n")
	for j = LOW_J, HIGH_J, 1 do
		file:write(wt[j].."|")
	end
	file:write("\n##Hidden->Output weights\n")
	for j = LOW_J, HIGH_J, 1 do
		for k = LOW_K, HIGH_K, 1 do
			file:write(w[j][k].."|")
		end
			file:write("\n")
	end
	file:write("##Tresholds\n")
	for k = LOW_K, HIGH_K, 1 do
		file:write(wt[k].."|")
	end
	file:close()
end

function StoreNetworkValues_XML( f )
	local file = io.open(f,"w")
	file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
	file:write('<'..TRAINING_FILE:match("/(exemplars.+)%.dat")..'_'..TRAIN_ITERATIONS..'>')
	file:write('<IL_HL_Weights>\n')
	for i = LOW_I, HIGH_I, 1 do
		file:write('<i'..i..'>')
		for j = LOW_J, HIGH_J , 1 do
			file:write(w[i][j].."|")
		end
			file:write('</i'..i..'>\n')
	end
	file:write('<iT>')
	for j = LOW_J, HIGH_J, 1 do
		file:write(wt[j].."|")
	end
	file:write('</iT>\n')
	file:write('</IL_HL_Weights>\n')

	file:write('<HL_OL_Weights>\n')
	for j = LOW_J, HIGH_J, 1 do
		file:write('<j'..j..'>')
		for k = LOW_K, HIGH_K, 1 do
			file:write(w[j][k].."|")
		end
			file:write('</j'..j..'>\n')
	end
	file:write('<jT>')
	for k = LOW_K, HIGH_K, 1 do
		file:write(wt[k].."|")
	end
	file:write('</jT>\n')
	file:write('</HL_OL_Weights>\n')
	file:write('</'..TRAINING_FILE:match("/(exemplars.+)%.dat")..'_'..TRAIN_ITERATIONS..'>')
	file:close()
end


--TODO: dont write anything to the train log if log is false... headers etc..
function learn(filename,iterations,log, selectTrain)
	local selectedExemplars = {}

	--write our training log header
	local file = io.open(LEARN_LOG,"a")
	file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
	file:write('<?xml-stylesheet type="text/xsl" href="training_style.xsl"?>')
	file:write('<'..TRAINING_FILE:match("/(exemplars.+)%.dat")..'>')
	file:write('<Network_LOG>')
	file:close()

	--output to the user the file training from and the number of iterations
	print("\nStarting Trainning for exemplars in file:"..filename)
	print("Running BP for "..iterations.." iterations")
	--for each iteration of the exemplars specificed... The number of epochs
	os.execute("cls")
	for i = 1, iterations, 1 do 
		--open out file and write the start of the xml no for this iteration/epoch
		local file = io.open(LEARN_LOG,"a")
		file:write('<Iteration'..i..">")
		file:close();
		--so to not just keep printing (numberExemplars * Iterations) number of lines saying the
		--algorithms progress call a cls to clear the console then write.
		
		print("Trainning for exemplars in file:"..filename.." \n Progress: "..math.floor(((i/TRAIN_ITERATIONS)*100)).."%")
		totalError = 0 --set our total error for the epoch to zero
		-- for every exemplar in the training file.
		for line in io.lines(filename) do

			--load the read in exemplar to the network
			loadExemplarToNet(line)

			--now pass the inputs through the network
			forwardPropigate()

			--if the flag to use our selective training procedure in the call to train
			if selectTrain == true then
				--if the the current exemplar has a rarly occuring/important output
				--(in this simple procedure rare/important outputs are jumps!) 
				--first out put represnents a jump is LOW_K
				if O[LOW_K] == 1 then
					--if the networks ouput for this exemplar was not acceptable add the exemplar to our list
					if y[LOW_K] < 0.1 then
						selectedExemplars[#selectedExemplars + 1] = line
					end
				end
			end	

			--now backPropigate the error through the net and adjust our weights
			backPropigate()
			--log the training if we want too
			if log == true then
				logNet_XML(LEARN_LOG,"learn")
			end

		end--end epoch
		--close the xml node
		local file = io.open(LEARN_LOG,"a")
		file:write('</Iteration'..i..">")
		file:close();
		--log our error data for this epoch
		logError("../Analysis/"..TRAINING_FILE:match("/(exemplars.+)%.dat").."_"..TRAIN_ITERATIONS.."_trainingError.csv",((1/2)*totalError),i)

		os.execute("cls")
		if selectTrain == true and selectedExemplars ~= nil then
			replaySelectedExemplars(selectedExemplars)
		end
		--reset the selected exemplars list
		selectedExemplars = {}
	end --end training

	--notify the user we are done training
	--close our training xml file
	--and write store the trained nework values.
	print("Finished Trainning\n Values Strored in:"..NET_VAL_XML)
	local file = io.open(LEARN_LOG,"a")
	file:write('</Network_LOG>')
	file:write('</'..TRAINING_FILE:match("/(exemplars.+)%.dat")..'>')
	file:close()
	StoreNetworkValues_XML( NET_VAL_XML )
end --end function

function loadExemplarToNet(exemplar)
	local s1 = string.sub(exemplar,1,string.find(exemplar,";") -1) --get the input
	local s2 = string.sub(exemplar,string.find(exemplar,";")+1,string.len(exemplar)) --get the expected output

	--split the inputs and the outputs into a table on the seperator |
	eI = split(s1,"|")
	eO = split(s2,"|")

	--set our net inputs to the exemplar input
	local x = 1
	for i = LOW_I, HIGH_I, 1 do
		I[i] = tonumber(eI[x])
		x = x + 1
	end

	--set our expected outputs to the exemplar output
	x = 1
	for k = LOW_K, HIGH_K, 1 do
		O[k] = tonumber(eO[x])
		x = x + 1
	end 
end

function replaySelectedExemplars(list)
	print("Replaying selected exempalrs, Total selected Exemplars "..#list.."\n")
	--while all the selected exemplars are not classfied correctly
	while checkAllClassified(list) ~= true do
		for i = 1, #list, 1 do
			loadExemplarToNet(list[i])

			forwardPropigate()

			backPropigate()
		end
	end
end

function checkAllClassified( list )
	--for the the selected exemplars
	for i = 1, #list, 1 do

		loadExemplarToNet(list[i])

		--pass each exmplar though the net
		forwardPropigate()

		--check if the net classified the outputs correctly
		for k = LOW_K, HIGH_K, 1 do
			--if the correct output was 1
			if O[k] == 1 then
				--then if the actual output was less then 0.5 it was cassified wrong so return false
				if y[k] < 0.1 then
					return false
				end
				--else if the correct was a 0
			else 
				--if the actual outputs was greater then 0.5 it was incorrectly classified so return false
				if y[k] > 0.1 then
					return false
				end --end if
			end -- and if
		end --end for
	end --end for 
	--if we have gone though all exemplars in our list that implies all were classifed correctly
	--fucntion never returned early with a false value
	return true
end

function readVarsFromUsr()
	io.write("Enter number of inputs:")
	NUM_INPUTS = io.read()
	io.write("Enter Number of nuerons:")
	NUM_NUERONS = io.read()
	NET_TOTAL = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS
	print(NUM_INPUTS)
	LOW_I = 1
	HIGH_I = NUM_INPUTS
	LOW_J = NUM_INPUTS + 1
	HIGH_J = NUM_INPUTS + NUM_NUERONS
	LOW_K = NUM_INPUTS + NUM_NUERONS + 1
	HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

	io.write("Enter the value for C constant:")
	C = io.read()

	io.write("Enter the values for the learning rate:")
	RATE = io.read()

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
	print("Loading Values from config file!")
	local config = parseConfig(filename)
	VIEW_RADIUS = config["VIEW_RADIUS"]
	NUM_NUERONS = config["NUM_NUERONS"]
	C = config["C"]
	RATE = config["RATE"]
	TRAIN_ITERATIONS = config["TRAIN_ITERATIONS"]
	TRAINING_FILE = config["TRAINING_FILE"]
	NUM_INPUTS = math.floor((VIEW_RADIUS * 2 + 1) * (VIEW_RADIUS * 2 + 1)) 
	NET_VALUES_FILE = config["NET_VALUES_FILE"]

	LOW_I = 1
	HIGH_I = NUM_INPUTS
	LOW_J = NUM_INPUTS + 1
	HIGH_J = NUM_INPUTS + NUM_NUERONS
	LOW_K = NUM_INPUTS + NUM_NUERONS + 1
	HIGH_K = NUM_INPUTS + NUM_NUERONS + NUM_OUTPUTS

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

function parseXMLNetvalues(file)
	print("Loading network values from: "..file)
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
	print("Finished loading values")
end

loadConfig("../config.txt")

InitNetwork()

function trainSeleted()

end

io.write("Do you wish to load prev network values (yes/no) : ")
if io.read() == "yes" then
	parseXMLNetvalues(NET_VALUES_FILE)
end

local log = false
io.write("Do you wish to log training to file (yes/no) : ")
if io.read() == "yes" then
	log = true
end

local selective = false
io.write("Do you wish to use the selective procedure (yes/no) : ")
if io.read() == "yes" then
	selective = true
end

learn(TRAINING_FILE,TRAIN_ITERATIONS,log,selective)


