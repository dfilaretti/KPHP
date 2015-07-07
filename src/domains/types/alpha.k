require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule alpha(N:Int) => specify(VE(AInt, .List)) [structural]

	rule alpha(F:Float) => specify(VE(AFloat, .List)) [structural]	

	rule alpha(B:Bool) => specify(VE(ABool, .List))	 [structural]

	rule alpha(S:String) => specify(VE(S, .List)) [structural]

	rule alpha(NULL) => NULL [structural]
	
syntax Bool ::= "isGammaSingleton" "(" K ")" [function]

rule isGammaSingleton(NULL) => true

rule isGammaSingleton(N:ANum)=> false

rule isGammaSingleton(B:ABool) => false

rule isGammaSingleton( (S:String, .List) ) => true

rule isGammaSingleton ( (AStringTop, _) ) => false

rule isGammaSingleton( (S:String, ListItem(_) _ )) => false

rule isGammaSingleton(Top) => false

//what about Bot ?


endmodule