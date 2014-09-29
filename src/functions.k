require "memory.k"

module FUNCTIONS 
	imports MEMORY	

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Functions} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Internal Representation} */
// ---------------------------------------------------------------------------------------------

syntax FunReturnType ::= "@byValue" | "@byRef"
syntax FunDef ::= "f" "(" K "," K "," FunReturnType "," Loc ")"
syntax StackFrame ::= "sf" "(" String "," K "," Loc "," K "," K "," K "," K ")"	

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Function Declaration} */
// ---------------------------------------------------------------------------------------------

/*@ When a function declaration is found, first an empty location is found and a symbol 
    table is created there (this will contain the function's static variables). 
    Then, the information already present in the AST node is passed to the auxiliary 
    operation MAKEFUNCTION. this operation will process the function body 
    (since static declarations need to be computed at compile time) and store
    the function in memory.  */

rule [function-decl-ret-value]:	
	<k> 'FunctionDecl(Name:String,, 'ListWrap(Parameters:KList),, Body:K) =>  
		ArrayCreateEmpty(L) ~> incRefCount(L) ~>
		makeFunction(Name, 'ListWrap(Parameters:KList), makeStaticDecls(Body, L), @byValue, L)
	... </k>
	<functions> Rho:Map </functions> 
	<trace> Trace:List => Trace ListItem("function-decl-ret-value") </trace>
	when notBool (Name in keys(Rho)) andBool (fresh(L:Loc))
	[step]

rule [function-decl-ret-ref]:	
	<k> 'FunctionDeclRef(Name:String,, 'ListWrap(Parameters:KList),, Body:K) =>  
		ArrayCreateEmpty(L) ~> incRefCount(L) ~>
		makeFunction(Name, 'ListWrap(Parameters:KList), makeStaticDecls(Body, L), @byRef, L)
	... </k>
	<functions> Rho:Map </functions> 
	<trace> Trace:List => Trace ListItem("function-decl-ret-ref") </trace>
	when notBool (Name in keys(Rho)) andBool (fresh(L:Loc))
	[step]

/* make function -- stores the function in memory.  */

syntax K ::= "makeFunction" "(" String "," K "," K "," K "," Loc ")" [strict(3)]

rule [make-function]:	
	<k> makeFunction(Name, 'ListWrap(Parameters:KList), visitedK(Body:K), ValueOrRef:K, L:Loc) => . ... </k>	
	<functions> Rho:Map => Rho[f('ListWrap(Parameters), Body, ValueOrRef, L) / Name] </functions> 
	<trace> Trace:List => Trace ListItem("make-function") </trace>
	[internal]
		
/*@ And here is some error management... */

rule [function-decl-type-hint-not-supported-1]:
	<k> 'FunctionDecl(_,,'ListWrap('ParamDefault(X:K,,Y:K,,Z:K)),,_) => NOT-SUPPORTED("Class type hint") ... </k>       	
	<trace> Trace:List => Trace ListItem("function-decl-type-hint-not-supported-1") </trace>
	[step, error]
	
rule [function-decl-type-hint-not-supported-2]:
	<k> 'FunctionDecl(_,,'ListWrap('Param(X:K,,Y:K)),,_) => NOT-SUPPORTED("Class type hint") ... </k>       	
	<trace> Trace:List => Trace ListItem("function-decl-type-hint-not-supported-2") </trace>
	[step, error]

rule [function-decl-type-hint-not-supported-3]:
	<k> 'ParamDefault(X:K,,Y:K,,Z:K) => NOT-SUPPORTED("Class type hint") ... </k>       	
	<trace> Trace:List => Trace ListItem("function-decl-type-hint-not-supported-3") </trace>
	[step, error]
	
rule [function-decl-type-hint-not-supported-4]:
	<k> 'Param(X:K,,Y:K) => NOT-SUPPORTED("Class type hint") ... </k>       	
	<trace> Trace:List => Trace ListItem("function-decl-type-hint-not-supported-4") </trace>
	[step, error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Function Call} */
// ---------------------------------------------------------------------------------------------

rule [function-name]:
	<k> 'FunctionName(FName:String) => FName ... </k>
	<trace> Trace:List => Trace ListItem("function-name") </trace>
	[step]

context [func-call-fname-strict]: 
	'FunctionCall(HOLE,,_:K)
	[structural]

rule [func-call-fname2LangValue]:
	<k> 'FunctionCall((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_:K) ... </k>
	<trace> Trace:List => Trace ListItem("func-call-fname2LangValue") </trace>
	[intermediate]

rule [func-call]:
	<k> 'FunctionCall(FName:String,,'ListWrap(Args:KList)) => 
		runFunction(FName, FunDef, 'ListWrap(Args), none, none, true) ... </k>
	<functions> ... FName |-> FunDef ... </functions>
	<trace> Trace:List => Trace ListItem("func-call") </trace>
	when notBool (FName ==String "var_dump") 
	[step]

rule [func-call-func-not-defined]: 
	<k> 'FunctionCall(FName:String,, 'ListWrap(Args:KList)) => 
		NOT-SUPPORTED("'" +String FName +String "' not defined!") ... </k>
	<functions> F:Map </functions>
	<trace> Trace:List => Trace ListItem("func-call-func-not-defined") </trace>
	when notBool (FName in keys(F)) 
	[step, error]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Return} */
// ---------------------------------------------------------------------------------------------

context [return-strict]: 
	'Return(HOLE)
	[structural]
	
context [some-strict]:
	'Some(HOLE)
	[structural]
	
/* TODO: remove
rule
	<k> 'Some(V:KResult) => V ... </k>
	<trace> Trace:List => Trace ListItem("some") </trace>
	[structural]

rule 
	<k> 'Return('Some(V:KResult)) => 'Return(V) ... </k>
	<trace> Trace:List => Trace ListItem("return-some") </trace>
	[structural]
*/

syntax Returnable ::= LanguageValue | Loc | Breakpoint

syntax Bool ::= "isRetValueLoc" "(" Returnable ")" [function]

rule isRetValueLoc(L:Loc) => true 
rule isRetValueLoc(V:LanguageValue) => false 
rule isRetValueLoc(B:Breakpoint) => false 


// No matter if the function returns by value or by reference; in both cases
// if the return value is a Ref, we get the corresponding location.

rule [return-arg2Loc]:    
	<k> 'Return (R:Ref => convertToLoc(R,r)) ... </k> 
	<functionStack> ListItem(_:StackFrame) ... </functionStack>
	<trace> Trace:List => Trace ListItem("return-arg2Loc") </trace>
	[intermediate]

// If the function returns by value, we perform a further reading step, so that 
// we get the value stored into the location. 
// But note that there is an exception: if the returned value ia compound (object 
// or array) we return a loc. 
// This is required for cases such as
//		foreach ( foo() as $v ) {...}
// where foo() is supposed to return an array by reference. 
// The reson why that would not work if the array is returned by value, is that 
// foreach expects a location as argument.

rule [return-arg2LangValue-not-compound]:    
	<k> 'Return (L:Loc => convertToLanguageValue(L)) ... </k> 
	<functionStack> ListItem(sf(_,_,_,_,_,@byValue,_)) ... </functionStack>
	<heap> ... L |-> zval(V,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("return-arg2LangValue-not-compound") </trace>
	when notBool (V isCompoundValue)
	[intermediate]

rule [return]:    
	<k> 'Return (V:Returnable) ~> _ => 
			*Cond(
				(RefMode ==K @byRef) andBool (notBool isRetValueLoc(V)),
                NOTICE("Only variable references should be returned by reference in %s on line %d\n"),.) ~>         	
                setCrntScope(CallerScope) ~>
                setCrntClass(CallerClass) ~>
                setCrntObj(CallerObj) ~>
                decRefCount(LocalScope) ~>
                popStackFrame ~>
                V ~> K </k>
        	<functionStack> ListItem(sf(_:String,K, CallerScope, CallerClass, CallerObj:K, RefMode, D)) ... </functionStack>
        	<currentScope> LocalScope:Loc </currentScope>
        <heap> ... LocalScope |-> zval(Array(_,Elems:List),_,_,_) ... </heap>
		<functionArgumentsDeclaration> _ => D </functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("return") </trace>
	[step]
		
// ---------------------------------------------------------------------------------------------
/*@ \subsection{The static construct} */
// ---------------------------------------------------------------------------------------------

/* TODO: remove if ok
context //[static-args-strict]: 
	'DeclareStatic('ListWrap('StaticVariable(_,, HOLE),, Gs:KList))
	[structural]

rule //[static-no-init-value]: 	
	<k> 'DeclareStatic('ListWrap('StaticVariable(G:K),, Gs:KList)) => 
		'DeclareStatic('ListWrap('StaticVariable(G:K,, NULL),, Gs:KList)) ... </k>
	//<trace> Trace:List => Trace ListItem("static-no-init-value") </trace>
	[structural]

rule //[static-cons]: 	
	<k> 'DeclareStatic('ListWrap('StaticVariable(G:K,, V:Value),, Gs:KList)) => 
	declareStatic(G, V) ~> 'DeclareStatic('ListWrap(Gs)) ... </k>
	//<trace> Trace:List => Trace ListItem("static-cons") </trace>
	[structural]

rule //[static-nil]:
	<k> 'DeclareStatic('ListWrap(.KList)) => . ... </k>
	//<trace> Trace:List => Trace ListItem("static-nil") </trace>
	[step]

syntax K ::= "declareStatic" "(" K "," Value ")"

rule //[declare-static]: 
	<k> declareStatic('Variable('Simple(X:String)), V:Value) => 'Expr('Assign('Variable('Simple(X)),,V)) ... </k>
*/
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{The global construct} */
// ---------------------------------------------------------------------------------------------

rule [global-cons]: 	
	<k> 'DeclareGlobal('ListWrap(G:K,, Gs:KList)) => 
		declareGlobal(G) ~> 'DeclareGlobal('ListWrap(Gs)) ... </k>
	<trace> Trace:List => Trace ListItem("global-cons") </trace>
	[intermediate]

rule [global-nil]: 	
	<k> 'DeclareGlobal('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("global-nil") </trace>
	[step]

syntax K ::= "declareGlobal" "(" K ")"

context [declare-global-indirect-strict]: 
	declareGlobal('IndirectReference(HOLE))
	[context]
	
rule [declare-global-indirect-arg2LangVal]: 
	<k> declareGlobal('IndirectReference(R:Ref => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("declare-global-indirect-arg2LangVal") </trace>
	[intermediate]

rule [declare-global-indirect]: 
	<k> declareGlobal('IndirectReference(X:String)) => declareGlobal('Variable('Simple(X:String))) ... </k>
	<trace> Trace:List => Trace ListItem("declare-global-indirect") </trace>
	[intermediate]

rule [declare-global]:	
	<k> declareGlobal('Variable('Simple(X:String))) => 
		'Expr('ReferenceAssign('Variable('Simple(X)),,'ArrayAccess('Variable('Simple("GLOBALS")),, X))) ... </k>
	<trace> Trace:List => Trace ListItem("declare-global") </trace>
	[internal]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Internal operations for functions} 
		As usual with dealing with complex operations, we define a number of auxiliary 
		specialized functions, which we'll combine in order to complete the task. */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

context [param-strict]:
	'Param(HOLE)

rule [param]: 	
	<k> 'Param(V:Value) => V ... </k>
	<trace> Trace:List => Trace ListItem("param") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Changing the current scope} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "setCrntScope" "(" Loc ")" 

rule [set-crtn-scope]:    
	<k> setCrntScope(L:Loc) => .K ... </k>
	<currentScope> _ => L </currentScope>
	<trace> Trace:List => Trace ListItem("set-crtn-scope") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Changing the current object} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "setCrntObj" "(" K ")" 

rule [set-crnt-obj]:    
	<k> setCrntObj(Obj:K) => . ... </k>
	<object> _ => Obj </object>
	<trace> Trace:List => Trace ListItem("set-crnt-obj") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Allocating the current object} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "allocCrntObj" "(" OptionLoc ")"

rule [alloc-crnt-obj]:    
	<k> allocCrntObj(Obj:Loc) => write(V, L1) ... </k>
	<object> _ => L1 </object>
	<heap> ... Obj |-> zval(V:Object,_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("alloc-crnt-obj") </trace>
	when fresh(L1:Loc)
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Changing the current class} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "setCrntClass" "(" OptionId ")"

rule [set-crnt-class]:    
	<k> setCrntClass(Class:K) => .K ... </k>
	<class> _ => Class </class>
	<trace> Trace:List => Trace ListItem("set-crnt-class") </trace>
	[internal]
        
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Pushing a stack frame} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "pushStackFrame" "(" String "," K "," Loc "," K "," K "," K "," K ")"

rule [push-stack-frame]: 	
	<k> pushStackFrame(FName:String, K:K, OldScope:Loc, Class:K, Obj:K, RetType:K,D) => .K ... </k>
	<functionStack> . => ListItem(sf(FName, K, OldScope, Class, Obj, RetType, D)) ... </functionStack>
	<trace> Trace:List => Trace ListItem("push-stack-frame") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Popping a stack frame} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "popStackFrame"

rule [pop-stack-frame]:     
	<k> popStackFrame => . ... </k>
	<functionStack> (ListItem(sf(_,_,_,_,_,_,_)) => .) ... </functionStack>
	<trace> Trace:List => Trace ListItem("pop-stack-frame") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Processing functions arguments} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "processFunArgs" "(" K "," K ")"

context [process-fun-args-strict]:	
	processFunArgs(
		'ListWrap('Param(Param:K),, Params:KList),
		'ListWrap('Param(HOLE),, Args:KList))

rule [process-fun-args-arg2LangValue-typehints-not-supported]:	
	<k> processFunArgs('ListWrap('Param(Hint:K,,Var:K),,Params:KList),_:K) => NOT-SUPPORTED("Type hints") ... </k>		

rule [process-fun-args-arg2LangValue]:	
	<k> processFunArgs(
		'ListWrap('Param(Param:K),, Params:KList),
		'ListWrap('Param(R:Ref => convertToLanguageValue(R)),, Args:KList)) ... </k>
	<trace> Trace:List => Trace ListItem("process-fun-args-arg2LangValue") </trace>
	[intermediate]

rule [process-fun-args-param]:
	<k> processFunArgs(
		'ListWrap('Param(Param:K),, Params:KList),
		'ListWrap('Param(V:Value),, Args:KList)) => 
		processFunArgs('ListWrap(Params), 'ListWrap(Args)) ... </k>
	<functionArgumentsDeclaration> 
		I:K => I ~>'Expr('Assign(Param,, V)) 
	</functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("process-fun-args-param") </trace>
	[intermediate]

rule [process-fun-args-param2]: 
	<k> processFunArgs(
		'ListWrap('Param(Param:K),, Params:KList),
		'ListWrap(V:Value,, Args:KList)) => 
		processFunArgs('ListWrap(Params), 'ListWrap(Args)) ... </k>
	<functionArgumentsDeclaration> 
		I:K => I ~>'Expr('Assign(Param,, V)) 
	</functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("process-fun-args-param2") </trace>
	[intermediate]

context	[process-fun-args-default-strict]:
	processFunArgs(
		'ListWrap('ParamDefault(Param:K,, Default:K),, Params:KList),
		'ListWrap('Param(HOLE),, Args:KList))
		
rule [process-fun-args-default-arg2LangValue]:
	<k> processFunArgs(
		'ListWrap('ParamDefault(Param:K,, Default:K),, Params:KList),
		'ListWrap('Param(R:Ref => convertToLanguageValue(R)),, Args:KList)) ... </k>
	<trace> Trace:List => Trace ListItem("process-fun-args-default-arg2LangValue") </trace>
	[intermediate]

rule [process-fun-args-default]:
	<k> processFunArgs(
			'ListWrap('ParamDefault(Param:K,, Default:K),, Params:KList),
			'ListWrap('Param(V:Value),, Args:KList)) => 
			processFunArgs('ListWrap(Params), 'ListWrap(Args)) ... </k>
	<functionArgumentsDeclaration> 
		I:K => I ~>'Expr('Assign(Param,, V)) 
	</functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("process-fun-args-default") </trace>
	[intermediate]

rule [process-fun-args-default-none]:
	<k> processFunArgs(
			'ListWrap('ParamDefault(Param:K,, Default:K),, Params:KList),
			'ListWrap(.KList)) => 
	processFunArgs('ListWrap(Params), 'ListWrap(.KList)) ... </k>
	<functionArgumentsDeclaration> 
		I:K => I ~>'Expr('Assign(Param,, Default)) 
	</functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("process-fun-args-default-none") </trace>
	[intermediate]

context [process-fun-args-ref-strict]:	
	processFunArgs(
		'ListWrap('ParamRef(Param:K),, Params:KList),
		'ListWrap('Param(HOLE),, Args:KList))

rule [process-fun-args-ref]:	
	<k> processFunArgs(
		'ListWrap('ParamRef(Param:K),, Params:KList),
		'ListWrap('Param(V:Value),, Args:KList)) => 
		processFunArgs('ListWrap(Params), 'ListWrap(Args)) ... </k>
	<functionArgumentsDeclaration> 
		I:K => I ~>'Expr('ReferenceAssign(Param,, V)) 
	</functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("process-fun-args-ref") </trace>
	[intermediate]

rule	<k> processFunArgs(
			'ListWrap('ParamRef(Param:K),, Params:KList),
			'ListWrap(V:Value,, Args:KList)) => 
			processFunArgs('ListWrap(Params), 'ListWrap(Args)) ... </k>
		<functionArgumentsDeclaration> 
			I:K => I ~>'Expr('ReferenceAssign(Param,, V)) 
		</functionArgumentsDeclaration>

rule [process-fun-args-empty]:	
	<k> processFunArgs('ListWrap(.KList),_:K) => . ... </k>
	<trace> Trace:List => Trace ListItem("process-fun-args-empty") </trace>
	[step]

/* Type Hint not supported */

rule [process-fun-args-error]: 	
	<k> processFunArgs ('ListWrap('ParamDefault(TypeHint:String,, _:K,, _:K)),_) => NOT-SUPPORTED("Type Hints") ... </k>
	<trace> Trace:List => Trace ListItem("process-fun-args-error") </trace>
	[step, error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Trying to reference assing on a function which returns a value} 
		This operation is clearly not possible, and it is managed by treating the 
		reference assignment as a value assignment (which we do via desugaring). */
// ---------------------------------------------------------------------------------------------

/* TODO: remove once tested
rule 	
	<k> 'ReferenceAssign(X:K,,'FunctionCall(Fname:String,,'ListWrap(Args:KList)))  		
		=> 'Assign(X,,'FunctionCall(Fname,,'ListWrap(Args)))  ... </k>
	<functions> ... Fname |-> f(_,_,@byValue,_) ... </functions>
	[structural]
*/

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Internal function and method call operation} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "runFunction" "(" String "," FunDef "," K "," OptionId "," OptionLoc "," Bool ")"

rule [run-function]:	
	<k> runFunction(FName:String, f(Parameters:K, Body:K, RetType:K, LStatic:Loc), Args:K, Class:OptionId, Obj:OptionLoc, Static:Bool) ~> K:K =>
			*Cond(
				(notBool Static) andBool ((Obj ==K none) andBool (CurrentObj ==K .K)),
				NOTICE("Non-static method should not be called statically\n"),.) ~>
			processFunArgs(Parameters, Args) ~> 
			pushStackFrame(FName, K, L, CurrentClass, CurrentObj, RetType, D) ~> 
			ArrayCreateEmpty(L1) ~>
			setCrntScope(L1) ~>
			incRefCount(L1) ~> 
			setCrntClass(Class) ~> 
			*Cond(Obj =/=K none, allocCrntObj(Obj), .K) ~>
			CopyFunctionArgs ~> 
			Body ~> 'Return(NULL) </k>
	<functionArgumentsDeclaration> D:K => . </functionArgumentsDeclaration>
	<currentScope> L:Loc </currentScope>
	<class> CurrentClass:K </class>
	<object> CurrentObj:K </object>
	<trace> Trace:List => Trace ListItem("run-function") </trace>
	when fresh(L1:Loc)
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Getting the function arguments} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "CopyFunctionArgs"

rule [get-fun-decls]:
	<k> CopyFunctionArgs => Declarations ... </k>
	<functionArgumentsDeclaration> Declarations:K => . </functionArgumentsDeclaration>
	<trace> Trace:List => Trace ListItem("get-fun-decls") </trace>
	[internal]

endmodule