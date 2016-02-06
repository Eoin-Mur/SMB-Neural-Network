File Name Structure

exemplarFileName_DataType_NumIterations_Attributes.csv

exemplarFileName:
	This is the filename for the file containing the exemplars that were processed.

DataType:
	this describes the type of data stored in the file.

NumIteraions:
	the number of iterations the of the exemplars the net was trained over

Atributes:
	each attribute is seperated by the '_' char.
	#NOTE: These are not the set attributes and others can be added at any time

	List of attribute abrivations:

		ND		: no duplicates - the duplicate exemplars were removed from the file.

		HOOC	: Highest on output chosen - 	for exemplars where the input was the same as others but with a different output 
																				the exemplar with the lowest number of on inputs was removed.
																				Example:
																					IN 							OUT
																					1|0|0|0|1|-1  	0|0|0|0|1
																					1|0|0|0|1|-1  	1|0|0|0|1

																					the first exemplar is removed as it only has the lowest "on"(1) inputs.