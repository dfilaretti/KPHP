/**************************************************
 *** CONCRETE INTERPRETER *************************
 *************************************************/

require "../../IMP-syntax.k" 
require "IMP-concrete-domain.k"

module IMP-CONCRETE
	imports IMP-SYNTAX
	imports IMP-CONCRETE-DOMAIN

//@ \subsection{KResult}

    syntax Value ::= ConcreteVal	
	syntax KResult ::= Value

	syntax AExp ::= ConcreteVal
    syntax BExp ::= ConcreteVal

    // TODO: cleanup, reorganise, maybe different file?
    syntax ConcreteValue ::= "noError"  [function] 
    rule    noError => Bot

    syntax Bool ::= "isErrorValue" "(" ConcreteVal ")"  [predicate]
    rule    isErrorValue(E:Exception) => true
    rule    isErrorValue(L:LangVal) => false

    syntax Bool ::= "isScalarValue" "(" ConcreteVal ")" [predicate]

    rule    isScalarValue(V:LangValCompound) => false
    rule    isScalarValue(V:LangValScalar) => true

//@ \subsection{Lub}
    
	syntax  ConcreteVal ::= ConcreteVal "lub" "(" Int ")" ConcreteVal    [function]
    syntax  ConcreteVal ::= "Bot" | "Top"

    rule    Bot lub(_) I => I
    rule    I lub(_) Bot => I
    rule    Bot lub(_) Bot => Bot // TODO: remove

    syntax  ConcreteVal ::= ConcreteVal "ret_lub" ConcreteVal    [function]
    rule    X ret_lub Y => X lub(0) Y
 
    syntax  ConcreteVal ::= ConcreteVal "err_lub" ConcreteVal    [function]
    rule    X err_lub Y => X lub(0) Y

//@ \subsection{Glb}
    
	syntax  ConcreteVal ::= ConcreteVal "glb"  ConcreteVal    [function]

    rule    X glb X => X

/*
    rule    Bot lub(_) I => I
    rule    I lub(_) Bot => I
    rule    Bot lub(_) Bot => Bot // TODO: remove

    syntax  ConcreteVal ::= ConcreteVal "ret_lub" ConcreteVal    [function]
    rule    X ret_lub Y => X lub(0) Y
 
    syntax  ConcreteVal ::= ConcreteVal "err_lub" ConcreteVal    [function]
    rule    X err_lub Y => X lub(0) Y
*/	
//@ \subsection{Abstraction Function}

	syntax ConcreteVal ::= "alpha" "(" ConcreteVal ")" 				[function]

	rule alpha(X) => X		// identity

//@ \section{Input and output operations}

    syntax K ::= "print_value" "(" ConcreteVal ")"  

    rule    <k> print_value(V:ConcreteVal) => . ... </k>
            <out> ... . => ListItem(V) </out>  

    syntax K ::= "read_int_input"
   
    rule    <k> read_int_input => I ... </k>
            <in> ListItem(I:Int) => . ... </in>

    syntax K ::= "read_string_input"
   
    rule    <k> read_string_input => S ... </k>
            <in> ListItem(S:String) => . ... </in>

//@ \section{String concatenation}

    syntax ConcreteVal ::= "string_concat" "(" ConcreteVal "," ConcreteVal ")" [function]

    rule string_concat(S1:String,S2:String) => S1 +String S2

//@ \section{Sanitisation}

    syntax ConcreteVal ::= "sanitize_value" "(" ConcreteVal ")" [function]

    rule    sanitize_value(I:Int) => I
    rule    sanitize_value(S:String) => S +String " sanitized!"

//@ \section{Forward Operations}

    // pairs. TODO: also defined in SIGN and others. Factorise?
	
    syntax Pair ::= "pair" "(" K "," K ")"

	// Multiplicauion

	syntax 	Int ::= ConcreteVal "mult" ConcreteVal  				[function]

	rule 	I1:Int mult I2:Int => I1 *Int I2

	// Plus

	syntax 	Int ::= ConcreteVal "plus" ConcreteVal	 				[function]

	rule 	I1:Int plus I2:Int => I1 +Int I2
	
	// Division

	syntax 	Int ::= ConcreteVal "div" ConcreteVal	 				[function]

	rule 	I1:Int div I2:Int => I1 /Int I2

    // isEqual

	syntax 	Bool ::= ConcreteVal "isEqual" ConcreteVal				[function]

	rule 	I1:Int isEqual I2:Int => I1 ==Int I2

    // isEqual_back

	syntax 	Pair ::= ConcreteVal "isEqual_back" ConcreteVal				[function]

	rule 	I1:Int isEqual_back I2:Int => pair(I1,I2)
            when I1 ==Int I2

	rule 	I1:Int isEqual_back I2:Int => pair(Bot,Bot)
            when I1 =/=Int I2

    // less_back

	syntax 	Pair ::= ConcreteVal "lt_back" ConcreteVal				[function]

	rule 	I1:Int lt_back I2:Int => pair(I1,I2)
            when I1 <Int I2

	rule 	I1:Int lt_back I2:Int => pair(Bot,Bot)
            when notBool(I1 <Int I2)

    // less

	syntax 	Bool ::= ConcreteVal "lt" ConcreteVal				[function]

	rule 	I1:Int lt I2:Int => I1 <Int I2

    // and

    syntax  Bool ::= ConcreteVal "and" ConcreteVal             [function] 
    
    //rule    B1:Bool and B2:Bool => B1 andBool B2

    // or
    
    syntax  Bool ::= ConcreteVal "or" ConcreteVal             [function] 
    
    //rule    B1:Bool or B2:Bool => B1 orBool B2 

    // not

    syntax  Bool ::= "not" ConcreteVal

    rule    not B:Bool => notBool(B)  

	// valid 

	syntax 	Bool ::= "valid" "(" ConcreteVal ")"					[function]

	rule 	valid(B:Bool) => B ==Bool true

	// unsatisfiable

	syntax 	Bool ::= "unsatisfiable" "(" ConcreteVal ")"			[function]

	rule 	unsatisfiable(B:Bool) => B ==Bool false

endmodule

