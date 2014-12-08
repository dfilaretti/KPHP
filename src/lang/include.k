require "errors.k"
module INCLUDE
	imports ERRORS
	imports URIS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{File inclusion} 
		Unsupported at the moment */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=


rule
	<k> 'InternalFunction('Eval(_)) => NOT-SUPPORTED("KPHP ERROR: 'Eval not supported") ... </k>
	<trace> Trace:List => Trace ListItem("eval") </trace>
	[step, error]

/*
rule
	<k> 'InternalFunction('Include(M:String)) => #parse(#readFile(M)); 
	</k>
	<trace> Trace:List => Trace ListItem("include") </trace>
	[step, error]
*/

/*
syntax String ::= readFile(Int) [function]
syntax Int ::= "BUFFER_SIZE"
rule BUFFER_SIZE => 1000 [macro]
syntax String ::= readFile(K, Int) [function]
rule readFile(Fd:Int) => readFile(#fReadBytes(Fd, BUFFER_SIZE), Fd)
rule readFile(S:String, Fd) => S +String readFile(Fd)
rule readFile(#EOF, Fd) => closeFile(#close(Fd))
syntax String ::= closeFile(K) [function]
rule closeFile(.K) => ""
*/


context 'InternalFunction('Include(HOLE))


rule 
	<k> 'InternalFunction('Include(M:String)) => #parse(M, "K") ... </k>



/*
rule
	<k> 'InternalFunction('RequireOnce(_)) => NOT-SUPPORTED("KPHP ERROR: 'RequireOnce not supported") ... </k>
	<trace> Trace:List => Trace ListItem("require-once") </trace>
	[step, error]

rule
	<k> 'InternalFunction('Require(_)) => NOT-SUPPORTED("KPHP ERROR: 'Require not supported") ... </k>
	<trace> Trace:List => Trace ListItem("require") </trace>
	[step, error]
*/
endmodule
