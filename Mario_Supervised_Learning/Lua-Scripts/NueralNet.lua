local NeuralNet= {
	LEARN_LOG = "../Training_Logs/NETLearn_"..os.date("%b_%d_%H_%M_%S")..".xml",
	RUN_LOG = "../Run_Logs/NETRun_"..os.date("%b_%d_%H_%M_%S")..".xml",
	NET_VAL = "../Network_Values/NETVal_"..os.date("%b_%d_%H_%M_%S")..".dat",
	NET_VAL_XML = "../Network_Values/NETVal_"..os.date("%b_%d_%H_%M_%S")..".xml",
	TRAIN_ITERATIONS,
	TRAINING_FILE,
	NUM_INPUTS,  
	NUM_NUERONS, --add to config
	NUM_OUTPUTS = 6,

	NET_TOTAL, 
	 
	LOW_I,
	HIGH_I, 
	LOW_J,
	HIGH_J,
	LOW_K,
	HIGH_K, 

	C, --add to config
	RATE, --add to config

	I = {},
	y = {},
	O = {},
	w = {},
	wt = {},

	dx = {},
	dy = {},

	ButtonNames = {
  "A",
  "B",
  "Down",
  "Left",
  "Right",
  "Up",
	}

}

function NeuralNet.randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function NeuralNet.sigmod(x,r)
	if r ~= nil then
		return NeuralNet.round((1/(1+math.exp(-4.9*x))),r);
	else
		return 1/(1+math.exp(-4.9*x))
	end
end

function NeuralNet.bipolarSigmod(x)
	return round((2/math.pi) * math.atan(x),3)
end

function NeuralNet.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function NeuralNet.split(str, pat)
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


function NeuralNet.InitNetwork()
	print("Initiating Network!")
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		NeuralNet.w[i] = {}
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J , 1 do
			NeuralNet.w[i][j] = NeuralNet.randomFloat( -NeuralNet.C, NeuralNet.C )
		end
	end

	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		NeuralNet.w[j] = {}
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			NeuralNet.w[j][k] = NeuralNet.randomFloat( -NeuralNet.C, NeuralNet.C)
		end
	end

	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		NeuralNet.wt[j] = NeuralNet.randomFloat( -NeuralNet.C, NeuralNet.C)
	end

	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		NeuralNet.wt[k] = NeuralNet.randomFloat( -NeuralNet.C, NeuralNet.C)
	end
end

function NeuralNet.forwardPropigate()
	local x 
	--inputs -> hidden
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		x = 0
		for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
			--console.log(I[i])
			x = x + ( NeuralNet.I[i] * NeuralNet.w[i][j] )
			NeuralNet.y[j] = NeuralNet.sigmod( x - NeuralNet.wt[j])
		end
	end
	--hidden -> output
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K , 1 do
		x = 0 
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J , 1 do
			x = x + ( NeuralNet.y[j] * NeuralNet.w[j][k] )
			NeuralNet.y[k] = NeuralNet.sigmod( x - NeuralNet.wt[k])
		end
	end
end

function NeuralNet.backPropigate()
	local dw

	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		NeuralNet.dy[k] = NeuralNet.y[k] - NeuralNet.O[k];
		NeuralNet.dx[k] = ( NeuralNet.dy[k] ) * NeuralNet.y[k] * (1-NeuralNet.y[k])
	end

	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		local t = 0
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			t = t + ( NeuralNet.dx[k] * NeuralNet.w[j][k] )
		end
		NeuralNet.dy[j] = t
		NeuralNet.dx[j] = (NeuralNet.dy[j] ) * NeuralNet.y[j] * ( 1- NeuralNet.y[j])
	end
	-----------------------------------------
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			dw = NeuralNet.dx[k] * NeuralNet.y[j]
			NeuralNet.w[j][k] = NeuralNet.w[j][k] - (NeuralNet.RATE * dw)
		end
	end

	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
			dw = NeuralNet.dx[j] * NeuralNet.I[i]
			NeuralNet.w[i][j] = NeuralNet.w[i][j] - (NeuralNet.RATE * dw)
		end 
	end

	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		dw = NeuralNet.dx[k] * (-1)
		NeuralNet.wt[k] = NeuralNet.wt[k] - ( NeuralNet.RATE * dw )
	end

	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		dw = NeuralNet.dx[j] * (-1)
		NeuralNet.wt[j] = NeuralNet.wt[j] - ( NeuralNet.RATE * dw)
	end
end

function NeuralNet.run(inputs)

	--local inputs = getScreen(VIEW_RADIUS)

	printScreen(inputs)
	local x = 1 
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		NeuralNet.I[i] = inputs[x]
		x = x + 1
	end

	NeuralNet.forwardPropigate()

	local outputs = {}
	local x = 1
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		local button = "P1 "..NeuralNet.ButtonNames[x] 
		if NeuralNet.y[k] > 0.5 then
			outputs[button] = true
		else
			outputs[button] = false
		end
		x = x + 1
	end	

	NeuralNet.logNet_XML(NeuralNet.RUN_LOG)

	return outputs
end

function NeuralNet.logNet(f,t)
	local file = io.open(f,"a")
	file:write("inputs: ")
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		file:write(NeuralNet.I[i].."|")
	end
	file:write("\nNet Outputs: ")
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		file:write(NeuralNet.y[k].."|")
	end
	if t=="learn" then
		file:write(" Exp Outputs: ")
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			file:write(NeuralNet.O[k].."|")
		end
	end
	file:write("\n")
	file:close()
end

function NeuralNet.logNet_XML(f,t)
	local file = io.open(f,"a")
	file:write("<Pass>\n")
	file:write("<Input>")
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		file:write(NeuralNet.I[i])
	end
	file:write("</Input>\n")
	file:write("<Net_Output>")
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		file:write(NeuralNet.y[k].."|")
	end
	file:write("</Net_Output>\n")
	if t=="learn" then
		file:write("<Exp_Output>")
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			file:write(NeuralNet.O[k].."|")
		end
		file:write("</Exp_Output>\n")
	end
	file:write("</Pass>\n")
	file:close()
end


function NeuralNet.StoreNetworkValues( f )
	local file = io.open(f,"a")
	file:write("##Inputs->Hidden weights\n")
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J , 1 do
			file:write(NeuralNet.w[i][j].."|")
		end
			file:write("\n")
	end
	file:write("##Tresholds\n")
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		file:write(NeuralNet.wt[j].."|")
	end
	file:write("\n##Hidden->Output weights\n")
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			file:write(NeuralNet.w[j][k].."|")
		end
			file:write("\n")
	end
	file:write("##Tresholds\n")
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		file:write(NeuralNet.wt[k].."|")
	end
	file:close()
end

function NeuralNet.StoreNetworkValues_XML( f )
	local file = io.open(f,"w")
	file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
	file:write('<Network>')
	file:write('<IL_HL_Weights>\n')
	for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
		file:write('<i'..i..'>')
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J , 1 do
			file:write(NeuralNet.w[i][j].."|")
		end
			file:write('</i'..i..'>\n')
	end
	file:write('<iT>')
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		file:write(NeuralNet.wt[j].."|")
	end
	file:write('</iT>\n')
	file:write('</IL_HL_Weights>\n')

	file:write('<HL_OL_Weights>\n')
	for j = NeuralNet.LOW_J, NeuralNet.HIGH_J, 1 do
		file:write('<j'..j..'>')
		for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
			file:write(NeuralNet.w[j][k].."|")
		end
			file:write('</j'..j..'>\n')
	end
	file:write('<jT>')
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
		file:write(NeuralNet.wt[k].."|")
	end
	file:write('</jT>\n')
	file:write('</HL_OL_Weights>\n')
	file:write('</Network>')
	file:close()
end

function NeuralNet.learn(filename,iterations)
	local file = io.open(NeuralNet.LEARN_LOG,"a")
	file:write('<?xml version="1.0" encoding="UTF-8"?>\n')
	file:write('<?xml-stylesheet type="text/xsl" href="training_style.xsl"?>')
	file:write('<Network_LOG>')
	file:close()
	print("\nStarting Trainning for exemplars in file:"..filename)
	print("Running BP for "..iterations.." iterations")
	for i = 1, iterations, 1 do 
		print("Iteration: "..i)
		for line in io.lines(filename) do

			local s1 = string.sub(line,1,string.find(line,";") -1)
			local s2 = string.sub(line,string.find(line,";")+1,string.len(line))

			eI = NeuralNet.split(s1,"|")
			eO = NeuralNet.split(s2,"|")

			local x = 1
			for i = NeuralNet.LOW_I, NeuralNet.HIGH_I, 1 do
				NeuralNet.I[i] = eI[x]
				x = x + 1
			end

			x = 1
			for k = NeuralNet.LOW_K, NeuralNet.HIGH_K, 1 do
				NeuralNet.O[k] = eO[x]
				x = x + 1
			end 

			NeuralNet.forwardPropigate()

			NeuralNet.backPropigate()

			NeuralNet.logNet_XML(NeuralNet.LEARN_LOG,"learn")
		end
	end
	print("Finished Trainning\n Values Strored in:"..NeuralNet.NET_VAL_XML)
	local file = io.open(NeuralNet.LEARN_LOG,"a")
	file:write('</Network_LOG>')
	file:close()
	NeuralNet.StoreNetworkValues_XML( NeuralNet.NET_VAL_XML )

end

function NeuralNet.readVarsFromUsr()
	io.write("Enter number of inputs:")
	NeuralNet.NUM_INPUTS = io.read()
	io.write("Enter Number of nuerons:")
	NeuralNet.NUM_NUERONS = io.read()
	NeuralNet.NET_TOTAL = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS + NeuralNet.NUM_OUTPUTS
	print(NeuralNet.NUM_INPUTS)
	NeuralNet.LOW_I = 1
	NeuralNet.HIGH_I = NeuralNet.NUM_INPUTS
	NeuralNet.LOW_J = NeuralNet.NUM_INPUTS + 1
	NeuralNet.HIGH_J = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS
	NeuralNet.LOW_K = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS + 1
	NeuralNet.HIGH_K = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS + NeuralNet.NUM_OUTPUTS

	io.write("Enter the value for C constant:")
	NeuralNet.C = io.read()

	io.write("Enter the values for the learning rate:")
	NeuralNet.RATE = io.read()

end

function NeuralNet.parseConfig(filename)
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

function NeuralNet.loadConfig(filename)
	print("Loading Values from config file!")
	local config = NeuralNet.parseConfig(filename)
	NeuralNet.VIEW_RADIUS = config["VIEW_RADIUS"]
	NeuralNet.NUM_NUERONS = config["NUM_NUERONS"]
	NeuralNet.C = config["C"]
	NeuralNet.RATE = config["RATE"]
	NeuralNet.TRAIN_ITERATIONS = config["TRAIN_ITERATIONS"]
	NeuralNet.TRAINING_FILE = config["TRAINING_FILE"]
	NeuralNet.NUM_INPUTS = math.floor((NeuralNet.VIEW_RADIUS * 2 + 1) * (NeuralNet.VIEW_RADIUS * 2 + 1)) 

	NeuralNet.LOW_I = 1
	NeuralNet.HIGH_I = NeuralNet.NUM_INPUTS
	NeuralNet.LOW_J = NeuralNet.NUM_INPUTS + 1
	NeuralNet.HIGH_J = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS
	NeuralNet.LOW_K = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS + 1
	NeuralNet.HIGH_K = NeuralNet.NUM_INPUTS + NeuralNet.NUM_NUERONS + NeuralNet.NUM_OUTPUTS

end


NeuralNet.loadConfig("../config.txt")

NeuralNet.InitNetwork()

NeuralNet.learn(NeuralNet.TRAINING_FILE,NeuralNet.TRAIN_ITERATIONS)


