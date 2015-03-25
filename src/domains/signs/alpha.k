require "../concrete/IMP-concrete-domain.k"
require "../../imp-syntax.k"

require "lattice.k"

module ALPHA
	imports IMP-CONCRETE-DOMAIN
    imports IMP-SYNTAX  // TODO: try to avoid this include!
	imports LATTICE

/* \subsection{Abstraction Function} 
        This is the classical abstraction function mapping concrete values
        into signs. */

	syntax SignVal ::= "alpha" "(" ConcreteVal ")" [function]

    //@ Errors (i.e. reading non-initialised variable) are mappet to Top
	rule alpha(Wrong) => Top

    //@ Booleans are mapped to their abstract equivalents
	rule alpha(true) => BTrue
	rule alpha(false) => BFalse

    //@ Finally, numbers are mapped into their sign
	rule alpha(N:Int) => 
		#if (N ==Int 0) #then 
			Zero 
		#else
			#if (N >Int 0) #then
				Pos
			#else
				Neg
			#fi
		#fi

    //@ string goes to Bot (i.e. strings doesn't have sign)
    rule alpha(S:String) => Bot

    //@ Exceptions (i.e. reading non-initialised variable) are mappet to Top
	rule alpha(GenericError) => AGenericError
    rule alpha(ArithError) => AArithError

    //@ Last thing, we instruct the K tool to consider Signs as values	
	syntax KResult ::= SignVal

    //@ TODO: move?/
    syntax SignVal ::= "noError"    [function]
    rule    noError => AErrBot
endmodule
