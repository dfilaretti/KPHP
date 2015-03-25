require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule    alpha(X:Int) => X
    rule    alpha(X:Float) => X
    rule    alpha(X:String) => X
    rule    alpha(X:Bool) => X

endmodule
