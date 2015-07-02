require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule alpha(N:Int) => (AInt, .ErrFlags) [structural]

	rule alpha(F:Float) => (AFloat, .ErrFlags) [structural]	

	rule alpha(B:Bool) => (ABool, .ErrFlags)	 [structural]

	rule alpha(S:String) => (S, .ErrFlags) [structural]

	rule alpha(NULL) => NULL [structural]
	
syntax Bool ::= "isGammaSingleton" "(" K ")" [function]

rule isGammaSingleton(NULL) => true

rule isGammaSingleton(N:ANum)=> false

rule isGammaSingleton(B:ABool) => false

rule isGammaSingleton( (S:String, .ErrFlags) ) => true

rule isGammaSingleton ( (AStringTop, _) ) => false

rule isGammaSingleton( (S:String, E) ) => false
when E =/=K .ErrFlags

rule isGammaSingleton(Top) => false

//what about Bot ?


endmodule