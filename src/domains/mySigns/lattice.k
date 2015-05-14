module LATTICE

    syntax  AInt ::= "AIntTop" 
                   | "AIntBot" 
                   | "AIntZero" 
                   | "AIntPos" 
                   | "AIntNeg"

    syntax  AFloat ::= "AFloatTop" 
                   | "AFloatBot" 
                   | "AFloatZero" 
                   | "AFloatPos" 
                   | "AFloatNeg"

    syntax  ABool ::= "ABoolTrue" 
		    | "ABoolFalse" 
		    | "ABoolTop" 
		    | "ABoolBot"
 
    syntax  AString ::= "AStringTop" | String | "AStringBot"

/*@ \subsection{Lattice ordering} */

// NOTE: theoretically, this should be defined for everything. 
//       In practice, I only need it for Keys (int and string)

syntax 	Bool ::= K "<Lattice" K		[function]

	rule 	AIntBot <Lattice AIntBot	=> false
	rule 	AIntBot <Lattice AIntNeg 	=> true
	rule 	AIntBot <Lattice AIntZero 	=> true
	rule 	AIntBot <Lattice AIntPos 	=> true
	rule 	AIntBot <Lattice AIntTop 	=> true
	
	rule 	AIntTop <Lattice AIntBot 	=> false
	rule 	AIntTop <Lattice AIntNeg 	=> false
	rule 	AIntTop <Lattice AIntZero 	=> false
	rule 	AIntTop <Lattice AIntPos 	=> false
	rule 	AIntTop <Lattice AIntTop 	=> false
	
	rule 	AIntNeg <Lattice AIntBot 	=> false
	rule 	AIntNeg <Lattice AIntNeg 	=> false
	rule 	AIntNeg <Lattice AIntZero 	=> false
	rule 	AIntNeg <Lattice AIntPos 	=> false
	rule 	AIntNeg <Lattice AIntTop 	=> true

	rule 	AIntZero <Lattice AIntBot 	=> false
	rule 	AIntZero <Lattice AIntNeg 	=> false
	rule 	AIntZero <Lattice AIntZero 	=> false
	rule 	AIntZero <Lattice AIntPos 	=> false
	rule 	AIntZero <Lattice AIntTop 	=> true

	rule 	AIntPos <Lattice AIntBot 	=> false
	rule 	AIntPos <Lattice AIntNeg 	=> false
	rule 	AIntPos <Lattice AIntZero 	=> false
	rule 	AIntPos <Lattice AIntPos 	=> false
	rule 	AIntPos <Lattice AIntTop 	=> true

/*
syntax 	Bool ::= K ">Lattice" K [predicate]

	rule V1:AInt >Lattice V2:AInt => V2 <Lattice V1
*/


//syntax 	Bool ::= AString "<Lattice" AString	 [function]

	rule AStringBot <Lattice AStringBot => false

	rule AStringBot <Lattice S:AString => true
	when (S =/=K AStringBot)


	rule S1:String <Lattice S2:String => false

	rule S1:String <Lattice AStringTop => true
	
	rule AStringTop <Lattice AStringTop => false

	rule S:AString <Lattice AStringTop => true
	when (S =/=K AStringTop)

/*
syntax 	Bool ::= AString ">Lattice" AString [function]

	rule V1:AString >Lattice V2:AString => 
	(notBool V1 <Lattice V2) andBool (notBool V1 ==K V2)
*/





/*@ \subsection{Lattice Operations} */

// LUB
   
syntax  AInt ::= "lub_AInt" "(" AInt "," AInt ")" [function]

rule 	lub_AInt(AIntBot,AIntBot) 			=> AIntBot
rule 	lub_AInt(AIntBot,AIntNeg) 			=> AIntNeg
rule 	lub_AInt(AIntBot,AIntZero) 			=> AIntZero
rule 	lub_AInt(AIntBot,AIntPos) 			=> AIntPos
rule 	lub_AInt(AIntBot,AIntTop) 			=> AIntTop

rule 	lub_AInt(AIntNeg,AIntBot) 			=> AIntNeg
rule 	lub_AInt(AIntNeg,AIntNeg) 			=> AIntNeg
rule 	lub_AInt(AIntNeg,AIntZero) 			=> AIntTop
rule 	lub_AInt(AIntNeg,AIntPos) 			=> AIntTop
rule 	lub_AInt(AIntNeg,AIntTop) 			=> AIntTop

rule 	lub_AInt(AIntZero,AIntBot) 			=> AIntZero
rule 	lub_AInt(AIntZero,AIntNeg) 			=> AIntTop
rule 	lub_AInt(AIntZero,AIntZero) 			=> AIntZero
rule 	lub_AInt(AIntZero,AIntPos) 			=> AIntTop
rule 	lub_AInt(AIntZero,AIntTop) 			=> AIntTop

rule 	lub_AInt(AIntPos,AIntBot) 			=> AIntPos
rule 	lub_AInt(AIntPos,AIntNeg) 			=> AIntTop
rule 	lub_AInt(AIntPos,AIntZero) 			=> AIntTop
rule 	lub_AInt(AIntPos,AIntPos) 			=> AIntPos
rule 	lub_AInt(AIntPos,AIntTop) 			=> AIntTop

rule 	lub_AInt(AIntTop,AIntBot) 			=> AIntTop
rule 	lub_AInt(AIntTop,AIntNeg) 			=> AIntTop
rule 	lub_AInt(AIntTop,AIntZero) 			=> AIntTop
rule 	lub_AInt(AIntTop,AIntPos) 			=> AIntTop
rule 	lub_AInt(AIntTop,AIntTop) 			=> AIntTop

syntax  AFloat ::= "lub_AFloat" "(" AFloat "," AFloat ")" [function]
 
rule 	lub_AFloat(AFloatBot,AFloatBot) 	=> AFloatBot
rule 	lub_AFloat(AFloatBot,AFloatNeg) 	=> AFloatNeg
rule 	lub_AFloat(AFloatBot,AFloatZero) 	=> AFloatZero
rule 	lub_AFloat(AFloatBot,AFloatPos) 	=> AFloatPos
rule 	lub_AFloat(AFloatBot,AFloatTop) 	=> AFloatTop

rule 	lub_AFloat(AFloatNeg,AFloatBot) 	=> AFloatNeg
rule 	lub_AFloat(AFloatNeg,AFloatNeg) 	=> AFloatNeg
rule 	lub_AFloat(AFloatNeg,AFloatZero) 	=> AFloatTop
rule 	lub_AFloat(AFloatNeg,AFloatPos) 	=> AFloatTop
rule 	lub_AFloat(AFloatNeg,AFloatTop) 	=> AFloatTop

rule 	lub_AFloat(AFloatZero,AFloatBot) 	=> AFloatZero
rule 	lub_AFloat(AFloatZero,AFloatNeg) 	=> AFloatTop
rule 	lub_AFloat(AFloatZero,AFloatZero) 	=> AFloatZero
rule 	lub_AFloat(AFloatZero,AFloatPos) 	=> AFloatTop
rule 	lub_AFloat(AFloatZero,AFloatTop) 	=> AFloatTop

rule 	lub_AFloat(AFloatPos,AFloatBot) 	=> AFloatPos
rule 	lub_AFloat(AFloatPos,AFloatNeg) 	=> AFloatTop
rule 	lub_AFloat(AFloatPos,AFloatZero) 	=> AFloatTop
rule 	lub_AFloat(AFloatPos,AFloatPos) 	=> AFloatPos
rule 	lub_AFloat(AFloatPos,AFloatTop) 	=> AFloatTop

rule 	lub_AFloat(AFloatTop,AFloatBot) 	=> AFloatTop
rule 	lub_AFloat(AFloatTop,AFloatNeg) 	=> AFloatTop
rule 	lub_AFloat(AFloatTop,AFloatZero) 	=> AFloatTop
rule 	lub_AFloat(AFloatTop,AFloatPos) 	=> AFloatTop
rule 	lub_AFloat(AFloatTop,AFloatTop) 	=> AFloatTop


syntax  ABool ::= "lub_ABool" "(" ABool "," ABool ")" [function]


rule 	lub_ABool(ABoolBot,ABoolBot) 		=> ABoolBot
rule 	lub_ABool(ABoolBot,ABoolTrue) 		=> ABoolBot
rule 	lub_ABool(ABoolBot,ABoolFalse) 		=> ABoolBot
rule 	lub_ABool(ABoolBot,ABoolTop) 		=> ABoolBot

rule 	lub_ABool(ABoolTrue,ABoolBot) 		=> ABoolBot
rule 	lub_ABool(ABoolTrue,ABoolTrue) 		=> ABoolTrue
rule 	lub_ABool(ABoolTrue,ABoolFalse) 	=> ABoolTop
rule 	lub_ABool(ABoolTrue,ABoolTop) 		=> ABoolTop

rule 	lub_ABool(ABoolFalse,ABoolBot) 		=> ABoolBot
rule 	lub_ABool(ABoolFalse,ABoolTrue) 	=> ABoolTop
rule 	lub_ABool(ABoolFalse,ABoolFalse) 	=> ABoolFalse
rule 	lub_ABool(ABoolFalse,ABoolTop) 		=> ABoolTop

rule 	lub_ABool(ABoolTop,ABoolBot) 		=> ABoolTop
rule 	lub_ABool(ABoolTop,ABoolTrue) 		=> ABoolTop
rule 	lub_ABool(ABoolTop,ABoolFalse) 		=> ABoolTop
rule 	lub_ABool(ABoolTop,ABoolTop) 		=> ABoolTop



// strings lub
syntax  AString ::= "lub_AString" "(" AString "," AString ")" [function]
rule	lub_AString(AStringTop,_) => AStringTop
rule	lub_AString(_,AStringTop) => AStringTop
rule	lub_AString(AStringBot,_) => AStringBot
rule	lub_AString(_,AStringBot) => AStringBot
rule	lub_AString(S1:String,S2:String) => S1 when (S1 ==String S2)
rule	lub_AString(S1:String,S2:String) => AStringTop when (S1 =/=String S2)




// GLB
    

    // valid 
	syntax  Bool ::= "valid" "(" ABool ")"	                [predicate]
	rule 	valid(B) => B ==K ABoolTrue 

    // unsatisfiable
	syntax  Bool ::= "unsatisfiable" "(" ABool ")"    [predicate]
	rule 	unsatisfiable(B) => B ==K ABoolFalse 
endmodule
