module LATTICE


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






syntax 	Bool ::= K "<Lattice" K		[function]

rule _ <Lattice _ => false






/*@ \subsection{Lattice Operations} */

// LUB

syntax AInt ::= "lub_AInt" "(" AInt "," AInt ")" [function]
syntax AFloat ::= "lub_AFloat" "(" AFloat "," AFloat ")" [function]
syntax ABool ::= "lub_ABool" "(" ABool "," ABool ")" [function]
syntax AString ::= "lub_AString" "(" AString "," AString ")" [function]

endmodule
