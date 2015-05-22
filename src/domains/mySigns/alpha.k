require "lattice.k"

module ALPHA
	imports LATTICE


	// alpha

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


	// is_gamma_singleton
	// returns TRUE if |gamma(arg)| = 1, or FALSE otherwise
	// NOTE: what about Bot?

	syntax Bool ::= "isGammaSingleton" "(" K ")" [function]
	
	rule	isGammaSingleton(AIntZero) => true
	rule	isGammaSingleton(I:AInt) => false
		when I =/=K AIntZero

	rule	isGammaSingleton(AFloatZero) => true
	rule	isGammaSingleton(F:AFloat) => false
		when F =/=K AFloatZero
	
	rule	isGammaSingleton(S:String) => true
	rule 	isGammaSingleton(AStringTop) => false

	rule	isGammaSingleton(ABoolTop) => false
	rule	isGammaSingleton(B:ABool) => true
		when B =/=K ABoolTop
	






endmodule
