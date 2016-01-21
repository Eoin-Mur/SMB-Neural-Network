local NeuralNet= {
	LEARN_LOG = "../DAT_Files/NETLearn_"..os.date("%b_%d_%H_%M_%S")..".dat",
	RUN_LOG = "../DAT_Files/NETRun_"..os.date("%b_%d_%H_%M_%S")..".dat",
	NET_VAL = "../DAT_Files/NETVal_"..os.date("%b_%d_%H_%M_%S")..".dat",

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
		return round((1/(1+math.exp(-4.9*x))),r);
	else
		return 1/(1+math.exp(-4.9*x))
	end
end

function NeuralNet.bipolarSigmod(x)
	return round((2/math.pi) * math.atan(x),3)
end

function NeuralNet:round(num, idp)
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
			NeuralNet.y[j] = NeuralNet.sigmod( x - NeuralNet.wt[j] )
		end
	end
	--hidden -> output
	for k = NeuralNet.LOW_K, NeuralNet.HIGH_K , 1 do
		x = 0 
		for j = NeuralNet.LOW_J, NeuralNet.HIGH_J , 1 do
			x = x + ( NeuralNet.y[j] * NeuralNet.w[j][k] )
			NeuralNet.y[k] = NeuralNet.sigmod( x - NeuralNet.wt[k] )
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

	NeuralNet.logNet(NeuralNet.RUN_LOG)

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

function NeuralNet.learn(filename,iterations)
	for i = 1, iterations, 1 do 
		for line in io.lines(filename) do
			gui.drawBox(10,10,120,30,0xFF000000,0xA0000000)
			gui.drawText(10,12,"TRAINING NETWORK!"..i,0xFFFF0000,10,"Segoe UI")

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

			NeuralNet.logNet(NeuralNet.LEARN_LOG,"learn")

			emu.frameadvance() --to stop bizhawk from crashing becasue of not loading a new frame for two long.
		end
	end
	NeuralNet.StoreNetworkValues( NeuralNet.NET_VAL )
end
