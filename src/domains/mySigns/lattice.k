module LATTICE

    // Language values are partitioned into Scalar, compound and special values. 
/*
    syntax  LanguageValue ::= PlainLanguageValue | LiteralValue

    syntax  PlainLanguageValue ::= ScalarValue | CompoundValue | SpecialValue
    syntax  ScalarValue ::= AInt | AFloat | ABool | AString     
    syntax  CompoundValue ::= Object | Array
    syntax  Null ::= "NULL"
    syntax  SpecialValue ::= Null
*/

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


/*@ \section{The SIGN abstract domain} */
/*
	syntax  Sign ::= "Top" | "Bot" | "Zero" | "Pos" | "Neg"
	syntax  AbstractBool ::= "BTrue" | "BFalse" | "BTop" | "BBot"
    syntax  AbstractErr  ::= "AArithError" | "AGenericError" | "AErr" | "AErrBot"
    syntax  AbstractString ::= String


    syntax  SignLangValScalar ::= Sign | AbstractBool | AbstractString
    syntax  SignLangValCompound ::= ArrayValue 

    syntax  SignLangVal ::= SignLangValScalar | SignLangValCompound

    syntax  SignSemVal  ::= Loc
    syntax  SignRegVal  ::= SignLangVal | SignSemVal
    syntax  SignErrVal  ::= AbstractErr
    syntax  SignVal ::= SignRegVal | SignErrVal

    syntax  AExp ::= SignVal
    syntax  BExp ::= SignVal

    syntax  Bool ::= "isErrorValue" "(" SignVal ")" [predicate]

    rule    isErrorValue(E:SignErrVal) => true
    rule    isErrorValue(E:SignRegVal) => false

    syntax  Bool ::= "isScalarValue" "(" SignVal ")" [predicate]
    rule    isScalarValue(E:SignLangValCompound) => false
    rule    isScalarValue(E:SignLangValScalar) => true
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
