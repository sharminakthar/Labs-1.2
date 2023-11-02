# Test Vector File
<PinDef>
A1,A2,Q1
</PinDef>
<TestVector>
	# A1	A2		Q1
	# oscillator oscillates (Q1=1) when nResetOsc=1, EnableOsc=1 
	1		1		1	
	1		1		0
	1		1		1
	1		1		0
	1		1		1
	# oscillator doesnt oscillate (Q1=0) when nResetOsc=1, EnableOsc=0	
	1		0		1		
	1		0		1
	# oscillator resets when nResetOsc=0	
	0		X		0
</TestVector>
# End of the test vector file
