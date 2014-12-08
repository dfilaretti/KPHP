module CONSTANTS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Constants} 
		Constants are added via the 'define(CONST_NAME, ScalarValue)' internal function.
   		They are available averywhere (like superglobals) and cannot be reassigned. */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
	
/*@ If the constant extists, its value is returned */

rule [constant-declared]: 	
	<k> 'ConstantVariable(ConstName:String) => Value ... </k>
	<constants> ... ConstName |-> Value  ... </constants>
	<trace> Trace:List => Trace ListItem("constant-declared") </trace>
	[step]

/*@ Otherwise, the name of the constant itself is returned */

rule [constant-undeclared]: 	
	<k> 'ConstantVariable(ConstName:String) => ConstName ... </k>
	<constants> Constants:Map </constants>
	<trace> Trace:List => Trace ListItem("constant-undeclared") </trace>
	when notBool (ConstName in keys(Constants))
	[step]

endmodule
