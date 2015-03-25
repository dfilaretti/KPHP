require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

    // abstraction of integers
	rule    alpha(N:Int) => 
		    #if (N ==Int 0) #then 
			    AIntZero 
		    #else
			    #if (N >Int 0) #then
				    AIntPos
			    #else
				    AIntNeg
			    #fi
		    #fi

    // abstrction of floats
	rule    alpha(F:Float) => 
		    #if (F ==Float 0.0) #then 
			    AFloatZero 
		    #else
			    #if (F >Float 0.0) #then
				    AFloatPos
			    #else
				    AFloatNeg
			    #fi
		    #fi

    // anstraction of strings
    rule    alpha(S:String) => S
    
    // abstraction of booleans
    rule    alpha(true) => ABoolTrue
    rule    alpha(false) => ABoolFalse

endmodule
