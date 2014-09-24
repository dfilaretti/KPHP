require "k-visitor.k"
require "shared.k"
module PROGRAM-TRANSFORMATIONS
	imports K-VISITOR
	imports SHARED

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Static declarations} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "makeStaticDecls" "(" K "," Loc ")"

rule [make-static-decls]:
	<k>  makeStaticDecls(P:K, L:Loc) => 
			visit P applying 'MakeStaticDecl if 'staticDeclFound ... </k>
	<function> _ => L </function>
	<trace> Trace:List => Trace ListItem("make-static-decls") </trace>
	[internal]

/* The idea is that we let the visitor pattern explore all the fragment of code, 
   and we perform something only when a static declaration is found. We model this 
   by defining the following predicate: */
   
syntax Bool ::= staticDeclFound(K) [klabel('staticDeclFound), predicate]

rule staticDeclFound(S:K) => true
	when (getKLabel(S) ==KLabel 'DeclareStatic) orBool (getKLabel(S) ==KLabel 'FunctionDecl)
rule staticDeclFound('FunctionCall('FunctionName("define"),,'ListWrap(Args:KList))) => true

/* When a static declaration is found, two operations are performed: 
    1: the variable is initialized in the function's static scope
    2: the static declaration is replaced with an auxiliary instruction
       that, when executed at runtime, will put a reference to the static 
       variable in the function local scope. */

syntax K ::= "MakeStaticDecl" "(" K ")" [klabel('MakeStaticDecl)]

/* base case  */
		
rule [make-static-decl-1]:
	<k> MakeStaticDecl(
			'DeclareStatic(
				'ListWrap(
					.KList
				)
			)
		) => visitedK(ProcStaticDecls) ... </k>
	<processedStaticDeclarations> ProcStaticDecls:K => .   </processedStaticDeclarations> 
	<trace> Trace:List => Trace ListItem("make-static-decl-1") </trace>
	[internal]
	
// don't recursively look into function declarations

rule [make-static-decl-2]:
	<k> MakeStaticDecl(F:K) => visitedK(F) ... </k>
	<trace> Trace:List => Trace ListItem("make-static-decl-2") </trace>
	when getKLabel(F) ==KLabel 'FunctionDecl
	[internal]

rule [make-static-decl-3]:
	<k> MakeStaticDecl('FunctionCall('FunctionName("define"),,'ListWrap(Args:KList)))
	=> 'Expr('FunctionCall('FunctionName("define"),,'ListWrap(Args:KList))) ~> visitedK(true) ... </k>
	<trace> Trace:List => Trace ListItem("make-static-decl-3") </trace>
	[internal]
	
/* cons case */

rule [make-static-decl-cons-1]:
	<k> MakeStaticDecl(
			'DeclareStatic(
				'ListWrap(
					'StaticVariable('Variable('Simple(X:String)),, V:K),, G:KList
				)
			)
		) => 
			'Expr('Assign(ref(L, X),, V)) ~>
			MakeStaticDecl(
			'DeclareStatic(
			'ListWrap(G))) ... </k>		
	<function> L:Loc </function>
	<processedStaticDeclarations> D:K => D ~> makeStaticDecl(X, L)  </processedStaticDeclarations> 
	<trace> Trace:List => Trace ListItem("make-static-decl-cons-1") </trace>
	[intermediate]

/* declarations without value are given NULL as default  */

rule [make-static-decl-cons-2]: 	
	<k> MakeStaticDecl(
		'DeclareStatic(
			'ListWrap(
				'StaticVariable('Variable('Simple(X:String))),, G:KList
			)
		)
	) 
	=>
	MakeStaticDecl(
		'DeclareStatic(
			'ListWrap(	
				'StaticVariable('Variable('Simple(X:String)),, NULL),, G
			)
		)
	)  ... </k>
	<trace> Trace:List => Trace ListItem("make-static-decl-cons-2") </trace>
	[intermediate]
	
syntax K ::= "makeStaticDecl" "(" String "," Loc ")"

rule [make-static-decl]:	
	<k> makeStaticDecl(X:String, Ls:Loc) => 'Expr('ReferenceAssign(ref(L, X),, ref(Ls, X))) ... </k>
	<currentScope> L:Loc </currentScope> 
	<trace> Trace:List => Trace ListItem("make-static-decl") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Hoisting} 
		The following operations are meant to be executed at initialization. What happens
		is that a refactoring of the initial code is performed, by moving at the top
		all function and class declarations so that those will be always available in the
		program, also before declaration. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "refactor" "(" K ")"

rule [refactor-cons-fun]:
	<k> refactor('ListWrap(K:KList,, D:K)) => refactor('ListWrap(K)) ... </k>
	<declarations> . => D ...  </declarations>
	<trace> Trace:List => Trace ListItem("refactor-cons-fun") </trace>
	when (getKLabel(D) ==KLabel 'FunctionDecl)
	[intermediate]

rule [refactor-cons-no-fun]: 
	<k> refactor('ListWrap(K:KList,, C:K)) => refactor('ListWrap(K)) ... </k>
	<commands> . => C ...  </commands>
	<trace> Trace:List => Trace ListItem("refactor-cons-no-fun") </trace>
	when (getKLabel(C) =/=KLabel 'FunctionDecl)
	[intermediate]

rule [refactor-nil]:
	<k> refactor('ListWrap(.KList)) => run ... </k>
	<trace> Trace:List => Trace ListItem("refactor-nil") </trace>
	[internal]

/* TODO: remove when done
rule //[refactor-nil-fun]:
	<k> refactor(D:K) => run ... </k>
	<declarations> . => D ...  </declarations>
	//<trace> Trace:List => Trace ListItem("refactor-nil-fun") </trace>
	when (getKLabel(D) ==KLabel 'FunctionDecl)
	[internal]

rule //[refactor-nil-no-fun]:
	<k> refactor(C:K) => run ... </k>
	<commands> . => C ...  </commands>
	//<trace> Trace:List => Trace ListItem("refactor-nil-no-fun") </trace>
	when (getKLabel(C) =/=KLabel 'FunctionDecl)
	[internal]
*/

syntax K ::= "run" |  "quotedCode" "(" K ")"

rule [run]:    
	<k> (run ~> K:K) => quotedCode(D ~> C) ~> K </k>
	<declarations> D:K => . </declarations>
 	<commands> C:K => . </commands>
	<trace> Trace:List => Trace ListItem("run") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Detect deprecated} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "detectDeprecated" "(" K ")"

rule [detect-deprecated]:
	<k> detectDeprecated(P:K) => 
		visit P applying 'MakeDeprecatedWarning if 'deprecatedIdiomFound ... </k>
	<trace> Trace:List => Trace ListItem("detect-deprecated") </trace>
	[internal]

syntax Bool ::= deprecatedIdiomFound(K) [klabel('deprecatedIdiomFound), predicate]
rule deprecatedIdiomFound('ReferenceAssign(_,,'ObjectCreation(_))) => true
rule deprecatedIdiomFound(S:K) => false
	when getKLabel(S) =/=KLabel 'ObjectCreation

syntax K ::= "MakeDeprecatedWarning" "(" K ")" [klabel('MakeDeprecatedWarning)]

rule [make-deprecated-warning]:
	<k> MakeDeprecatedWarning(K)
		=> DEPRECATED("Assigning the return value of new by reference is deprecated in %s on line %d\n") ~> visitedK(K) ... </k>
	<trace> Trace:List => Trace ListItem("make-deprecated-warning") </trace>
	[internal]
endmodule