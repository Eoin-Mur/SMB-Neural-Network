
-----------------------------------------------------------------
--------THERE HAS TO BE A CLEANER WAY OF DOING THIS--------------
-----------------------------------------------------------------

local keyboard = {
	A,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,
	NUM0,
	NUM1,
	NUM2,
	NUM3,
	NUM4,
	NUM5,
	NUM6,
	NUM7,
	NUM8,
	NUM9,
	UNDERSCORE,
	PERIOD,
	COLON,
	SLASH

}


--"Shift+Semicolon": "True" 
--"Slash": "True"
--"Shift+Minus"
--"Period": "True"

function keyboard.readKeyPress(capital)
	local inputs = inputs.get()

	--------------A-------------
	if inputs["A"] == true then
		A = true
	end

	if inputs["A"] == nil and A == true then
		if capital == true then
			return "A"
		else
			return "a"
		end
		A = false
	end

	--------------B-----------
	if inputs["B"] == true then
		B = true
	end

	if inputs["B"] == nil and B == true then
		if capital == true then
			return "B"
		else
			return "b"
		end
		B = false
	end

	---------------C-----------
	if inputs["C"] == true then
		C = true
	end

	if inputs["C"] == nil and C == true then
		if capital == true then
			return "C"
		else
			return "c"
		end
		C = false
	end

	--------------D-------------
	if inputs["D"] == true then
		D = true
	end

	if inputs["D"] == nil and D == true then
		if capital == true then
			return "D"
		else
			return "d"
		end
		D = false
	end

	--------------E-----------
	if inputs["E"] == true then
		E = true
	end

	if inputs["E"] == nil and E == true then
		if capital == true then
			return "E"
		else
			return "e"
		end
		E = false
	end

	---------------F-----------
	if inputs["F"] == true then
		F = true
	end

	if inputs["F"] == nil and F == true then
		if capital == true then
			return "F"
		else
			return "f"
		end
		F = false
	end

	--------------G-------------
	if inputs["G"] == true then
		G = true
	end

	if inputs["G"] == nil and G == true then
		if capital == true then
			return "G"
		else
			return "g"
		end
		G = false
	end

	--------------H-----------
	if inputs["H"] == true then
		H = true
	end

	if inputs["H"] == nil and H == true then
		if capital == true then
			return "H"
		else
			return "h"
		end
		H = false
	end

	---------------I-----------
	if inputs["I"] == true then
		I = true
	end

	if inputs["I"] == nil and I == true then
		if capital == true then
			return "I"
		else
			return "i"
		end
		I = false
	end

	--------------J-------------
	if inputs["J"] == true then
		J = true
	end

	if inputs["J"] == nil and J == true then
		if capital == true then
			return "J"
		else
			return "j"
		end
		J = false
	end

	--------------K-----------
	if inputs["K"] == true then
		K = true
	end

	if inputs["K"] == nil and K == true then
		if capital == true then
			return "K"
		else
			return "k"
		end
		K = false
	end

	---------------L-----------
	if inputs["L"] == true then
		L = true
	end

	if inputs["L"] == nil and L == true then
		if capital == true then
			return "L"
		else
			return "l"
		end
		L = false
	end

	--------------M-------------
	if inputs["M"] == true then
		M = true
	end

	if inputs["M"] == nil and M == true then
		if capital == true then
			return "M"
		else
			return "m"
		end
		M = false
	end

	--------------N-----------
	if inputs["N"] == true then
		N = true
	end

	if inputs["N"] == nil and N == true then
		if capital == true then
			return "N"
		else
			return "n"
		end
		N = false
	end

	---------------O-----------
	if inputs["O"] == true then
		O = true
	end

	if inputs["O"] == nil and O == true then
		if capital == true then
			return "O"
		else
			return "o"
		end
		O = false
	end

	--------------P-------------
	if inputs["P"] == true then
		P = true
	end

	if inputs["P"] == nil and P == true then
		if capital == true then
			return "P"
		else
			return "p"
		end
		P = false
	end

	--------------Q-----------
	if inputs["Q"] == true then
		Q = true
	end

	if inputs["Q"] == nil and Q == true then
		if capital == true then
			return "Q"
		else
			return "q"
		end
		Q = false
	end

	---------------R-----------
	if inputs["R"] == true then
		R = true
	end

	if inputs["R"] == nil and R == true then
		if capital == true then
			return "R"
		else
			return "r"
		end
		R = false
	end

	--------------S-------------
	if inputs["S"] == true then
		S = true
	end

	if inputs["S"] == nil and S == true then
		if capital == true then
			return "S"
		else
			return "s"
		end
		S = false
	end

	--------------T-----------
	if inputs["T"] == true then
		T = true
	end

	if inputs["T"] == nil and T == true then
		if capital == true then
			return "T"
		else
			return "t"
		end
		T = false
	end

	---------------U-----------
	if inputs["U"] == true then
		U = true
	end

	if inputs["U"] == nil and U == true then
		if capital == true then
			return "U"
		else
			return "u"
		end
		U = false
	end

	--------------V-------------
	if inputs["V"] == true then
		V = true
	end

	if inputs["V"] == nil and V == true then
		if capital == true then
			return "V"
		else
			return "v"
		end
		V = false
	end

	--------------W-----------
	if inputs["W"] == true then
		W = true
	end

	if inputs["W"] == nil and W == true then
		if capital == true then
			return "W"
		else
			return "w"
		end
		W = false
	end

	---------------X-----------
	if inputs["X"] == true then
		X = true
	end

	if inputs["X"] == nil and X == true then
		if capital == true then
			return "X"
		else
			return "x"
		end
		X = false
	end


	--------------Y-----------
	if inputs["Y"] == true then
		Y = true
	end

	if inputs["Y"] == nil and Y == true then
		if capital == true then
			return "Y"
		else
			return "y"
		end
		Y = false
	end

	---------------Z-----------
	if inputs["Z"] == true then
		Z = true
	end

	if inputs["Z"] == nil and Z == true then
		if capital == true then
			return "Z"
		else
			return "z"
		end
		Z = false
	end

	----------------0-------------------
	if inputs["NumberPad0"] == true then
		NUM0 = true
	end

	if inputs["NumberPad0"] == nil and NUM1 == true then
		return 0
		NUM0 = false
	end

	----------------1-------------------
	if inputs["NumberPad1"] == true then
		NUM1 = true
	end

	if inputs["NumberPad1"] == nil and NUM1 == true then
		return 1
		NUM1 = false
	end

	----------------2-------------------
	if inputs["NumberPad2"] == true then
		NUM2 = true
	end

	if inputs["NumberPad2"] == nil and NUM2 == true then
		return 2
		NUM2 = false
	end

	----------------3-------------------
	if inputs["NumberPad3"] == true then
		NUM3 = true
	end

	if inputs["NumberPad3"] == nil and NUM3 == true then
		return 3
		NUM3 = false
	end

	----------------4-------------------
	if inputs["NumberPad4"] == true then
		NUM4 = true
	end

	if inputs["NumberPad4"] == nil and NUM4 == true then
		return 4
		NUM4 = false
	end

	----------------5-------------------
	if inputs["NumberPad5"] == true then
		NUM5 = true
	end

	if inputs["NumberPad5"] == nil and NUM5 == true then
		return 5
		NUM5 = false
	end

	----------------6-------------------
	if inputs["NumberPad6"] == true then
		NUM6 = true
	end

	if inputs["NumberPad6"] == nil and NUM6 == true then
		return 6
		NUM6 = false
	end

	----------------7-------------------
	if inputs["Numberad7"] == true then
		NUM7 = true
	end

	if inputs["NumberPad7"] == nil and NUM7 == true then
		return 7
		NUM7 = false
	end

	----------------8------------------
	if inputs["NumberPad8"] == true then
		NUM8 = true
	end

	if inputs["NumberPad8"] == nil and NUM8 == true then
		return 8
		NUM8 = false
	end

	----------------9-------------------
	if inputs["NumberPad9"] == true then
		NUM9 = true
	end

	if inputs["NumberPad9"] == nil and NUM9 == true then
		return 9
		NUM9 = false
	end

	----------------underscore-------------------
	if inputs["Shift+Minus"] == true then
		UNDERSCORE = true
	end

	if inputs["Shift+Minus"] == nil and UNDERSCORE == true then
		return "_"
		UNDERSCORE = false
	end

	----------------PERIOD-------------------
	if inputs["PERIOD"] == true then
		PERIOD = true
	end

	if inputs["PERIOD"] == nil and PERIOD == true then
		return "."
		PERIOD = false
	end

	----------------SLASH-------------------
	if inputs["SLASH"] == true then
		SLASH = true
	end

	if inputs["SLASH"] == nil and SLASH == true then
		return "/"
		SLASH = false
	end

	----------------PERIOD-------------------
	if inputs["Shift+Semicolon"] == true then
		COLON = true
	end

	if inputs["Shift+Semicolon"] == nil and COLON == true then
		return ":"
		COLON = false
	end
end

return keyboard