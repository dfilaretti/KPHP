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

    syntax  AInt ::= Int
    syntax  AFloat ::= Float
    syntax  ABool ::= Bool
    syntax  AString ::= String

	// valid 
	syntax 	Bool ::= "valid" "(" ABool ")"	        [function]
	rule 	valid(B:Bool) => B ==Bool true

	// unsatisfiable
	syntax 	Bool ::= "unsatisfiable" "(" ABool ")"	[function]
	rule 	unsatisfiable(B:Bool) => B ==Bool false

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

syntax AInt ::= "lub_AInt" "(" AInt "," AInt ")" [function]
syntax AFloat ::= "lub_AFloat" "(" AFloat "," AFloat ")" [function]
syntax ABool ::= "lub_ABool" "(" ABool "," ABool ")" [function]
syntax AString ::= "lub_AString" "(" AString "," AString ")" [function]

// GLB
    

// valid 

/*
	syntax Bool ::= "valid" "(" AbstractBool ")"					[predicate]

	rule 	valid(B) => B ==K BTrue 
*/	
// unsatisfiable

/*
	syntax Bool ::= "unsatisfiable" "(" AbstractBool ")"			[predicate]

	rule 	unsatisfiable(B) => B ==K BFalse 
*/
endmodule
