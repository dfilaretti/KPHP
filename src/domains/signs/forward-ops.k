require "lattice.k"
module FORWARD-OPS
	imports LATTICE

//@ \subsection{Abstract forward operations}

	// Abstract Addition

	syntax Sign ::= Sign "plus" Sign					[function]
	
	rule 	Bot plus Bot			=> Bot
	rule 	Bot plus Neg 			=> Bot
	rule 	Bot plus Zero 			=> Bot
	rule 	Bot plus Pos 			=> Bot
	rule 	Bot plus Top 			=> Bot
	
	rule 	Top plus Bot 			=> Bot
	rule 	Top plus Neg 			=> Top
	rule 	Top plus Zero 			=> Top
	rule 	Top plus Pos 			=> Top
	rule 	Top plus Top 			=> Top
	
	rule 	Neg plus Bot 			=> Bot
	rule 	Neg plus Neg 			=> Neg
	rule 	Neg plus Zero 			=> Neg
	rule 	Neg plus Pos 			=> Top
	rule 	Neg plus Top 			=> Top

	rule 	Zero plus Bot 			=> Bot
	rule 	Zero plus Neg 			=> Neg
	rule 	Zero plus Zero 			=> Zero
	rule 	Zero plus Pos 			=> Pos
	rule 	Zero plus Top 			=> Top

	rule 	Pos plus Bot 			=> Bot
	rule 	Pos plus Neg 			=> Top
	rule 	Pos plus Zero 			=> Pos
	rule 	Pos plus Pos 			=> Pos
	rule 	Pos plus Top 			=> Top
	
// Abstract division

	syntax Sign ::= Sign "div" Sign					[function]
	
    rule 	Bot div Bot				=> Bot
	rule 	Bot div Neg 			=> Bot
	rule 	Bot div Zero 			=> Bot
	rule 	Bot div Pos 			=> Bot
	rule 	Bot div Top 			=> Bot
	
	rule 	Top div Bot 			=> Bot
	rule 	Top div Neg 			=> Top
	rule 	Top div Zero 			=> Bot	// ?
	rule 	Top div Pos 			=> Top
	rule 	Top div Top 			=> Top
	
	rule 	Neg div Bot 			=> Bot
	rule 	Neg div Neg 			=> Neg
	rule 	Neg div Zero 			=> Bot	// ?
	rule 	Neg div Pos 			=> Neg
	rule 	Neg div Top 			=> Top

	rule 	Zero div Bot 			=> Bot
	rule 	Zero div Neg 			=> Zero
	rule 	Zero div Zero 			=> Bot	// ?
	rule 	Zero div Pos 			=> Zero
	rule 	Zero div Top 			=> Top

	rule 	Pos div Bot 			=> Bot
	rule 	Pos div Neg 			=> Pos
	rule 	Pos div Zero 			=> Bot	// ?
	rule 	Pos div Pos 			=> Pos
	rule 	Pos div Top 			=> Top

// Abstract multiplication

	syntax Sign ::= Sign "mult" Sign					[function]

    rule 	Bot mult Bot			=> Bot
	rule 	Bot mult Neg 			=> Bot
	rule 	Bot mult Zero 			=> Bot
	rule 	Bot mult Pos 			=> Bot
	rule 	Bot mult Top 			=> Bot
	
	rule 	Top mult Bot 			=> Bot
	rule 	Top mult Neg 			=> Top
	rule 	Top mult Zero 			=> Zero
	rule 	Top mult Pos 			=> Top
	rule 	Top mult Top 			=> Top
	
	rule 	Neg mult Bot 			=> Bot
	rule 	Neg mult Neg 			=> Pos
	rule 	Neg mult Zero 			=> Zero
	rule 	Neg mult Pos 			=> Neg
	rule 	Neg mult Top 			=> Top

	rule 	Zero mult Bot 			=> Bot
	rule 	Zero mult Neg 			=> Zero
	rule 	Zero mult Zero 			=> Zero
	rule 	Zero mult Pos 			=> Zero
	rule 	Zero mult Top 			=> Zero

	rule 	Pos mult Bot 			=> Bot
	rule 	Pos mult Neg 			=> Neg
	rule 	Pos mult Zero 			=> Zero
	rule 	Pos mult Pos 			=> Pos
	rule 	Pos mult Top 			=> Top


    // isEqual_back
    syntax AbstractBool ::= SignVal "isEqual" SignVal        [function]
    
    rule    Bot isEqual Bot         => BBot
    rule    Bot isEqual Neg         => BBot
    rule    Bot isEqual Zero        => BBot
    rule    Bot isEqual Pos         => BBot
    rule    Bot isEqual Top         => BBot

    rule    Neg isEqual Bot         => BBot
    rule    Neg isEqual Neg         => BTop
    rule    Neg isEqual Zero        => BFalse
    rule    Neg isEqual Pos         => BFalse
    rule    Neg isEqual Top         => BTop
    
    rule    Zero isEqual Bot        => BBot
    rule    Zero isEqual Neg        => BFalse
    rule    Zero isEqual Zero       => BTrue
    rule    Zero isEqual Pos        => BFalse
    rule    Zero isEqual Top        => BTop

    rule    Pos isEqual Bot         => BBot
    rule    Pos isEqual Neg         => BFalse
    rule    Pos isEqual Zero        => BFalse
    rule    Pos isEqual Pos         => BTop
    rule    Pos isEqual Top         => BTop
    
    rule    Top isEqual Bot         => BBot
    rule    Top isEqual Neg         => BTop
    rule    Top isEqual Zero        => BTop
    rule    Top isEqual Pos         => BTop
    rule    Top isEqual Top         => BTop

    syntax  Pair ::= "pair" "(" K "," K ")"

// isEqual_back

	syntax  Pair ::= SignVal "isEqual_back" SignVal		[function]

    rule    A isEqual_back B => pair(A glb B, A glb B)

// lt

    syntax  AbstractBool ::= SignVal "lt" SignVal

	rule 	Bot lt Bot 		=> BBot
	rule 	Bot lt Neg 		=> BBot
	rule 	Bot lt Zero 	=> BBot
	rule 	Bot lt Pos 		=> BBot
	rule 	Bot lt Top 		=> BBot

	rule 	Neg lt Bot 		=> BBot
	rule 	Neg lt Neg 		=> BTop
	rule 	Neg lt Zero 	=> BTrue
	rule 	Neg lt Pos 		=> BTrue
	rule 	Neg lt Top 		=> BTop
	
	rule 	Zero lt Bot 	=> BBot
	rule 	Zero lt Neg 	=> BFalse
	rule 	Zero lt Zero 	=> BFalse
	rule 	Zero lt Pos 	=> BTrue
	rule 	Zero lt Top 	=> BTop

	rule 	Pos lt Bot 		=> BBot
	rule 	Pos lt Neg 		=> BFalse
	rule 	Pos lt Zero 	=> BFalse
	rule 	Pos lt Pos 		=> BTop
	rule 	Pos lt Top 		=> BTop
	
	rule 	Top lt Bot 		=> BBot
	rule 	Top lt Neg 		=> BTop
	rule 	Top lt Zero 	=> BTop
	rule 	Top lt Pos 		=> BTop
	rule 	Top lt Top 		=> BTop

// lt_back
	syntax Pair ::= SignVal "lt_back" SignVal		[function]

	rule 	Bot lt_back Bot 		=> pair(Bot,Bot) 
	rule 	Bot lt_back Neg 		=> pair(Bot,Bot)  
	rule 	Bot lt_back Zero 	    => pair(Bot,Bot)  
	rule 	Bot lt_back Pos 		=> pair(Bot,Bot)
	rule 	Bot lt_back Top 		=> pair(Bot,Bot)

	rule 	Neg lt_back Bot 		=> pair(Bot,Bot)
	rule 	Neg lt_back Neg 		=> pair(Neg,Neg)
	rule 	Neg lt_back Zero 	    => pair(Neg,Zero)
	rule 	Neg lt_back Pos 		=> pair(Neg,Pos)
	rule 	Neg lt_back Top 		=> pair(Neg,Top)
	
	rule 	Zero lt_back Bot 	    => pair(Bot,Bot)
	rule 	Zero lt_back Neg 	    => pair(Bot,Bot)
	rule 	Zero lt_back Zero 	    => pair(Bot,Bot)
	rule 	Zero lt_back Pos 	    => pair(Zero,Pos)
	rule 	Zero lt_back Top 	    => pair(Zero,Pos)

	rule 	Pos lt_back Bot 		=> pair(Bot,Bot)
	rule 	Pos lt_back Neg 		=> pair(Bot,Bot)
	rule 	Pos lt_back Zero 	    => pair(Bot,Bot)
	rule 	Pos lt_back Pos 		=> pair(Pos,Pos)
	rule 	Pos lt_back Top 		=> pair(Pos,Pos)
	
	rule 	Top lt_back Bot 		=> pair(Bot,Bot)
	rule 	Top lt_back Neg 		=> pair(Neg,Neg)
	rule 	Top lt_back Zero 	    => pair(Neg,Zero)
	rule 	Top lt_back Pos 		=> pair(Top,Pos)
	rule 	Top lt_back Top 		=> pair(Top,Top)

// and

    syntax  AbstractBool ::= SignVal "and" SignVal   [function]

    rule    BBot    and     _       =>  BBot
    rule    _       and     BBot    =>  BBot

    rule    BTrue   and     BTrue   =>  BTrue 
    rule    BTrue   and     BFalse  =>  BFalse
    rule    BFalse  and     BTrue   =>  BFalse
    rule    BFalse  and     BFalse  =>  BFalse
        
    rule    BTop    and     _       =>  BTop
    rule    _       and     BTop    =>  BTop
 
// or

    syntax  AbstractBool ::= SignVal "or" SignVal   [function]
    
    rule    BBot    or     _       =>  BBot
    rule    _       or     BBot    =>  BBot

    rule    BTrue   or     BTrue   =>  BTrue 
    rule    BTrue   or     BFalse  =>  BFalse
    rule    BFalse  or     BTrue   =>  BFalse
    rule    BFalse  or     BFalse  =>  BFalse
        
    rule    BTop    or     _       =>  BTop
    rule    _       or     BTop    =>  BTop
 
// not

	syntax AbstractBool ::= "not" SignVal 		[function]
	
	rule 	not BBot 		=> BBot
	rule 	not BTrue 		=> BFalse
    rule 	not BFalse 		=> BTrue
	rule 	not BTop	    => BTop

    //rule    not A:Sign      => BTop

// input 

    syntax K ::= "read_int_input"
    rule    read_int_input => Top

    syntax K ::= "read_string_input"
    rule    read_string_input => Top

// output 
    syntax K ::= "print_value" "(" SignVal ")"
    rule print_value(_) => .

// string concat
    syntax SignVal ::= "string_concat" "(" SignVal "," SignVal ")"
    rule    string_concat(S1:String,S2:String) => S1 +String S2

// sanitize

    syntax SignVal ::= "sanitize_value" "(" SignVal ")" 
    rule sanitize_value(S:String) => S +String "sanitized!"


endmodule
