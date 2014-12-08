require "shared.k"

module EXCEPTIONS
    imports SHARED

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Exceptions} 
		We model PHP exception mechanisms following the standard K approach introduced in 
		KOOL. Note that we only model the try-catch construct, but we don't model the 
		finally clause. This is because it is not supported by our parser at the moment. */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Exception stack frames} 
		Stack frames contains, in this order: the name of the class, the variable, the 
		catch body and finally the continuation. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "(" Id "," K "," K "," K "," Bag ")"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Try-catch} */
// ---------------------------------------------------------------------------------------------

rule [try-catch]:	
	<k>
		('Try('Body(TryBody:K),,'ListWrap('Catch(XClass:String,,VarName:K,,'Body(CatchBody:K)))) => 
		TryBody ~> popx) ~> K:K 
	</k>
	<control>
		C:Bag
		<exceptionStack> . => ListItem((String2Id(XClass), VarName, CatchBody, K, C)) ... </exceptionStack>
	</control>
	<trace> Trace:List => Trace ListItem("try-catch") </trace>
	[step]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Popping the stack frame} 
		If the try body is executed and no exception is thrown, the exception stack frame 
		created before needs to be dissolved. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "popx"

rule [pop-exception-frame]:
	<k> popx => . ... </k>
	<exceptionStack> _ => . ... </exceptionStack> 
	<trace> Trace:List => Trace ListItem("pop-exception-frame") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Throw} */
// ---------------------------------------------------------------------------------------------

context [throw-strict]: 
	'Throw(HOLE)
	[structural]

rule [throw-arg2LangValue]:   
	<k> 'Throw(L:ConvertibleToLanguageValue => convertToLanguageValue(L)) ... </k>
	<trace> Trace:List => Trace ListItem("throw-arg2LangValue") </trace>
	[intermediate]

rule [throw-no-loop]:
	<k> 'Throw(V:Object) ~> _ => 'Expr('Assign(VarName,,V)) ~> CatchBody ~> K </k>
	<control>
		// TODO: uncommenting the following line magically solves the 
		//       'sync current' problems...
		//<loopStack> .List ... </loopStack> 
		<exceptionStack> ListItem((XClass:Id, VarName:K, CatchBody:K, K:K, C:Bag)) => . ... </exceptionStack>
		(_ => C)
	</control>
	<trace> Trace:List => Trace ListItem("throw-no-loop") </trace>
	[step]

/*
rule	<k> 'Throw(V:Object) ~> _ => 'Echo('ListWrap(
				"FATAL ERROR: ",,
				"Uncaught exception: ",, 
				'FunctionCall(L,, "getMessage",, 'ListWrap(.KList)),,
				"\n",,
				"Execution was aborted.\n"
			)) 
		</k>
		<exceptionStack> .List </exceptionStack>
*/	
endmodule 