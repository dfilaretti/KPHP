module LATTICE

/*@ \section{The SIGN abstract domain} */

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

//	syntax SignVal ::= Sign | AbstractBool | AbstractString | AbstractErr

    syntax  Bool ::= "isErrorValue" "(" SignVal ")" [predicate]

    rule    isErrorValue(E:SignErrVal) => true
    rule    isErrorValue(E:SignRegVal) => false

    syntax  Bool ::= "isScalarValue" "(" SignVal ")" [predicate]
    rule    isScalarValue(E:SignLangValCompound) => false
    rule    isScalarValue(E:SignLangValScalar) => true
  
/*@ \subsection{Lattice Operations} */

// LUB

	syntax  SignVal ::= SignVal "lub" "(" Int ")"  SignVal 	[function]

    rule    X lub(_) Y => X plain_lub Y

    syntax  SignVal ::= SignVal "ret_lub" SignVal 	[function]
    rule    X ret_lub Y => X plain_lub Y

    syntax  SignVal ::= SignVal "err_lub" SignVal 	[function]
    rule    X err_lub Y => X plain_lub Y
	

	syntax  SignVal ::= SignVal "plain_lub" SignVal 	[function]

	rule 	Bot plain_lub X:SignVal     => X

	rule 	Neg plain_lub Bot 			=> Neg
	rule 	Neg plain_lub Neg 			=> Neg
	rule 	Neg plain_lub Zero 			=> Top
	rule 	Neg plain_lub Pos 			=> Top
	rule 	Neg plain_lub Top 			=> Top

	rule 	Zero plain_lub Bot 			=> Zero
	rule 	Zero plain_lub Neg 			=> Top
	rule 	Zero plain_lub Zero 		=> Zero
	rule 	Zero plain_lub Pos 			=> Top
	rule 	Zero plain_lub Top 			=> Top

	rule 	Pos plain_lub Bot 			=> Pos
	rule 	Pos plain_lub Neg 			=> Top
	rule 	Pos plain_lub Zero 			=> Top
	rule 	Pos plain_lub Pos 			=> Pos
	rule 	Pos plain_lub Top 			=> Top

	rule 	I:Sign plain_lub E:AbstractErr => Top
	rule 	E:AbstractErr plain_lub I:Sign => Top


	rule 	Top plain_lub Bot 			=> Top
	rule 	Top plain_lub Neg 			=> Top
	rule 	Top plain_lub Zero 			=> Top
	rule 	Top plain_lub Pos 			=> Top
	rule 	Top plain_lub Top 			=> Top

    rule    Top plain_lub E:AbstractErr => Top
    rule    E:AbstractErr plain_lub Top => Top
 
    rule    S:Sign plain_lub B:AbstractBool => Top

//@ LUB on errors
    rule    AErrBot plain_lub E:AbstractErr => E
    rule    E:AbstractErr plain_lub AErrBot => E
    rule    E:AbstractErr plain_lub E => E
    rule    E1:AbstractErr plain_lub E2:AbstractErr => AErr
            when (E1 =/=K E2)    

// GLB => TODO

	syntax  SignVal ::= SignVal "glb"  SignVal 	[function]

	rule 	Bot glb Bot 			=> Bot
	rule 	Bot glb Neg 			=> Bot
	rule 	Bot glb Zero 			=> Bot
	rule 	Bot glb Pos 			=> Bot
	rule 	Bot glb Top 			=> Bot

	rule 	Neg glb Bot 			=> Bot
	rule 	Neg glb Neg 			=> Neg
	rule 	Neg glb Zero 			=> Bot
	rule 	Neg glb Pos 			=> Bot
	rule 	Neg glb Top 			=> Neg

	rule 	Zero glb Bot 			=> Bot
	rule 	Zero glb Neg 			=> Bot
	rule 	Zero glb Zero 		    => Zero
	rule 	Zero glb Pos 			=> Bot
	rule 	Zero glb Top 			=> Zero

	rule 	Pos glb Bot 			=> Bot
	rule 	Pos glb Neg 			=> Bot
	rule 	Pos glb Zero 			=> Bot
	rule 	Pos glb Pos 			=> Pos
	rule 	Pos glb Top 			=> Pos

	rule 	Top glb Bot 			=> Bot
	rule 	Top glb Neg 			=> Neg
	rule 	Top glb Zero 			=> Zero
	rule 	Top glb Pos 			=> Pos
	rule 	Top glb Top 			=> Top

    // TODO: sure?
    rule    Top glb E:AbstractErr => E
    rule    E:AbstractErr glb Top => E
	rule 	I:Sign glb E:AbstractErr => Top
	rule 	E:AbstractErr glb I:Sign => Top
	rule 	Bot glb E:AbstractErr 	=> E
	rule 	E:AbstractErr glb Bot 	=> E
    

// valid 

	syntax Bool ::= "valid" "(" AbstractBool ")"					[predicate]

	rule 	valid(B) => B ==K BTrue 
	
// unsatisfiable

	syntax Bool ::= "unsatisfiable" "(" AbstractBool ")"			[predicate]

	rule 	unsatisfiable(B) => B ==K BFalse 

endmodule
