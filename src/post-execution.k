require "shared.k"
module POST-EXECUTION
	imports SHARED
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Post execution} 
		In this module we define stuff that will be executed after the program has run. 
		For now, we just include some form of garbage collection (i.e. cleanup of the zvals
		with a ref count equals to zero). */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Detecting termination} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "terminated"

// When the program is terminated we place a "terminated" placeholder as a top computation
rule [termination]:
	<k> . => terminated </k> 
	<isTerminated> false => true </isTerminated> 
	<trace> Trace:List => Trace ListItem("termination") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Post execution operations} */
// ---------------------------------------------------------------------------------------------

rule [post-exec-ops]:
	<k> terminated => cleanTrace ~> gc ... </k>
	<trace> Trace:List => Trace ListItem("post-exec-ops") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Clean trace} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "cleanTrace"

rule [clean-trace-enabled-true]:
	<k> cleanTrace => . ... </k>
	<cleanTraceOnTermination> true </cleanTraceOnTermination> 
	
rule [clean-trace-enabled-false]:
	<k> cleanTrace => . ... </k>
	<cleanTraceOnTermination> false </cleanTraceOnTermination> 
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Garbage collection} 
		Simple mark and sweep */
// ---------------------------------------------------------------------------------------------

syntax K ::= "gc" | "mark" "(" Map ")" | "sweep"

rule [gc-enabled]:
	<k> gc => mark (Mem) ~> sweep ... </k>
	<heap> Mem:Map </heap>
	<locationsToCollect> _ => .List </locationsToCollect>
	<gcEnabled> true </gcEnabled>
	
rule [gc-disabled]:
	<k> gc => . ... </k>
	<gcEnabled> false </gcEnabled>

// mark: make a list of all locations whose ref count is zero

rule [mark-collect]:
	<k> mark((L:Loc |-> zval(_,_,0,_) => .) Mem:Map) ... </k>
	<locationsToCollect> Locs2Collect => Locs2Collect ListItem(L) </locationsToCollect>
	
rule [mark-leave]:
	<k> mark((L:Loc |-> zval(_,_,RefCount,_) => .) Mem:Map) ... </k>
	<trace> Trace:List => Trace ListItem("mark-leave") </trace>
	when (RefCount >Int 0)

rule [mark-done]:
	<k> mark(.Map) => . ... </k>

// sweep: collect those locations

rule [sweep-some]:
	<k> sweep ... </k>
	<locationsToCollect> (ListItem(L) => .) Locs2Collect:List </locationsToCollect>
	<heap> ... (L |-> _) => . ... </heap>
	
rule [sweep-none]:
	<k> sweep => . ... </k>
	<locationsToCollect> .List </locationsToCollect>

endmodule