require "type-conversions.k"

module IO 
	imports TYPE-CONVERSIONS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Input and Output} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Exit, Die} */
// ---------------------------------------------------------------------------------------------

syntax KLabel ::= "'Exit" | "'Die"

rule [die-desugar]:
	<k> ('Die => 'Exit)(_) ... </k>
	<trace> Trace:List => Trace ListItem("die-desugar") </trace>
	[structural]

context 'Exit(HOLE)

rule [exit-arg2LangValue]: 
	<k> 'Exit(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("exit-arg2LangValue") </trace>
	[intermediate]

rule [exit]:
	<k> 'Exit(V:LanguageValue) ~> _ => print(V) </k>
	<exitStatus> _ => V </exitStatus>
	<trace> Trace:List => Trace ListItem("exit") </trace>
	[step]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Auxiliary stuff} */
// ---------------------------------------------------------------------------------------------


syntax  K ::= "print" "(" K ")"     [strict]
/* SM-FIXME: missing cases due to AFLOAT domain

rule [internal-print]:    
	<k> print (V:AFloat => Float2Int(V))  ... </k>
	<trace> Trace:List => Trace ListItem("internal-print") </trace>
	when (hasNoDecimalPart(V))
	[internal, output]
	
rule [internal-print]:    
	<k> print (V:AFloat => *toString(V))  ... </k>
	<trace> Trace:List => Trace ListItem("internal-print") </trace>
	when notBool (hasNoDecimalPart(V))
	[internal, output]
*/
rule [internal-print]:    
	<k> print (V:LanguageValue => *toString(V))  ... </k>
	<trace> Trace:List => Trace ListItem("internal-print") </trace>
	when notBool(isFloatType(V) orBool isStringType(V))
	[internal, output]

rule [internal-print]:    
	<k> print (V:String)  => . ... </k>
	<out> ... . => ListItem(V) </out>  
	<trace> Trace:List => Trace ListItem("internal-print") </trace>
	[internal, output]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Echo} */
// ---------------------------------------------------------------------------------------------

context [echo-args-strict]: 
	'Echo('ListWrap(_:KList,,HOLE,,_:KList))
	[structural]
	
rule [echo-args2LangValue]: 	
	<k> 'Echo('ListWrap((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_:KList)) ... </k>
	<trace> Trace:List => Trace ListItem("echo-args2LangValue") </trace>
	[intermediate]

rule [echo-cons]:
	<k> 'Echo('ListWrap(V:LanguageValue,,Args:KList)) => print(V) ~> 'Echo('ListWrap(Args)) ... </k>
	<trace> Trace:List => Trace ListItem("echo-cons") </trace>
	[intermediate] // Or step?
	
rule [echo-nil]: 
	<k> 'Echo('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("echo-nil") </trace>
	[step]

rule [echo-more-args]:	
	<k> 'Echo(Args:K,, "") => 'Echo(Args) ... </k>
	<trace> Trace:List => Trace ListItem("echo-more-args") </trace>
	[structural]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Inline Echo} */
// ---------------------------------------------------------------------------------------------

rule [inline-echo]: 
	<k> 'InlineEcho('EchoOpenTag(.KList),,K:K,,_,,'CloseTag(.KList)) => 'Echo('ListWrap(K)) ... </k>
	<trace> Trace:List => Trace ListItem("inline-echo") </trace>
	[structural] 

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Print} 
		Same as 'Echo, but also returns a nice "1". */
// ---------------------------------------------------------------------------------------------

rule [print]:
	<k> 'Print(Item:K) => 'Echo('ListWrap(Item)) ~> 1 ... </k>
	<trace> Trace:List => Trace ListItem("print") </trace>
	[structural]
	
endmodule 
