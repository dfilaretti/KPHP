require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule    alpha(X:Int) => X
	rule    alpha(X:Float) => X
	rule    alpha(X:String) => X
	rule    alpha(X:Bool) => X

	syntax K ::= "alphaRC" "(" K ")" [function]

	rule	alphaRC(X) => X


syntax Bool ::= "isGammaSingleton" "(" K ")" [function]

// Since we are a concrete domain we have alpha(x) = gamma(x) = x	
rule	isGammaSingleton(_) => true

endmodule
