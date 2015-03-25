module IMP-CONCRETE-DOMAIN
	//@ \section{Concrete domain}

    syntax LangValCompound      ::= ArrayValue //[klabel('lcomp)]
    syntax LangValScalar        ::= Int | Bool | String 
    syntax LangVal              ::= LangValScalar | LangValCompound
//    syntax LangVal              ::= ArrayValue | Int | Bool | String
    syntax ErrVal               ::= Exception | "Wrong"
    syntax SemVal               ::= Loc
    syntax ConcreteVal          ::= LangVal | ErrVal | SemVal
    


/*
	syntax ConcreteVal ::= Int 
						 | Bool
                         | String 
                         | Exception 
                         | ArrayValue
						 | "Wrong"
*/
endmodule
