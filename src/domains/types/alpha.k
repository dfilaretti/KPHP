require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule alpha(N:Int) => AInt [structural]

	rule alpha(F:Float) => AFloat [structural]	

	rule alpha(B:Bool) => ABool	 [structural]

	rule alpha(S:String) => S [structural]

	rule alpha(NULL) => NULL [structural]
	
	//used only for literals ?
endmodule