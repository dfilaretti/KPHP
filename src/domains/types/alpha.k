require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule alpha(N:Int) => AInt [structural]

	rule alpha(F:Float) => AFloat [structural]	

	rule alpha(B:Bool) => ABool	 [structural]

	rule alpha(S:String) => S [structural]

	rule alpha(NULL) => NULL [structural]
	
syntax Bool ::= "isGammaSingleton" "(" K ")" [function]

rule isGammaSingleton(NULL) => true

rule isGammaSingleton(AInt) => false

rule isGammaSingleton(AFloat) => false

rule isGammaSingleton(ANum)=> false

rule isGammaSingleton(ABool) => false

rule isGammaSingleton(S:String) => true

rule isGammaSingleton(AStringTop) => false

rule isGammaSingleton(Top) => false

//what about Bot ?


endmodule