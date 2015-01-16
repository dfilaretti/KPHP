require "shared.k"
require "program-transformations.k"
require "builtin-functions.k"

//require "../domains/empty/empty-domain.k"
require "../domains/mySigns/mySigns-domain.k"

module CORE 
	imports SHARED
	imports PROGRAM-TRANSFORMATIONS
	imports BUILTIN-FUNCTIONS
//	imports EMPTY-DOMAIN
    imports MYSIGNS-DOMAIN
    	
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Core} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Documents} 
		PHP scripts are parsed as Document. Documents comes in different flavours, depending
		on if the closing tag if present, if some additional HTML is present etc. */
// ---------------------------------------------------------------------------------------------

/*@ In all cases, and at least for now (we may want to be more precise later) we extract the PHP
	script from the Document and schedule it for execution. 
	Before executing the script we perform a pre-processing refactoring operation which consists 
	in moving all function and class declaration to the top of the program (i.e. before any 
	statement). This models the fact that PHP allows function call and class instantiation before 
	function or class declaration. */

syntax K ::= "runScript" "(" K ")" 

rule runScript(Prog:K) =>  refactor(Prog) ~> detectDeprecated ~> initStatic

syntax K ::= "detectDeprecated"

rule 	(quotedCode(Prog:K) ~> detectDeprecated) => detectDeprecated(Prog)

syntax K ::= "initStatic"

rule 	<k> (visitedK(Prog:K) ~> initStatic) => makeStaticDecls(Prog, L) ~> start ... </k>
		<globalStaticScope> L:Loc </globalStaticScope> 

syntax K ::= "start"

rule visitedK(Prog) ~> start => Prog 

rule [document-1]:
	<k> 'Document(_:K,, _:K,, Prog:K) => runScript(Prog) ... </k>
	<trace> Trace:List => Trace ListItem("document-1") </trace>
	[structural]

rule [document-2]:
	<k> 'Document(_:K,, _:K,, Prog:K,, _:K,, 'ListWrap(.KList)) => runScript(Prog) ... </k>
	<trace> Trace:List => Trace ListItem("document-2") </trace>
	[structural]

rule [document-3]: 
	<k> 'Document(PreHTML:K,, _:K,, Prog:K,, _:K,, PostHTML:K) => 'Echo(PreHTML) ~> runScript(Prog) ~> 'Echo(PostHTML) ... </k>
	<trace> Trace:List => Trace ListItem("document-3") </trace>
	[structural]

rule [inline-html]:  
	<k> 'InlineHTML('CloseTag(_),,Stuff:K,,'FullOpenTag(_)) => 'Echo(Stuff) ... </k>
	<trace> Trace:List => Trace ListItem("inline-html") </trace>
	[structural]

/* Empty document */

rule [template-document-empty]:
	<k> 'TemplateDocument('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("template-document-empty") </trace>
	[structural]

/* literal */

rule [template-document-literal]: 
	<k> 'TemplateDocument('ListWrap('Literal(L:String),, Stuff:KList)) => 
	'Echo('ListWrap(L)) ~>  'TemplateDocument('ListWrap(Stuff)) ... </k>
	<trace> Trace:List => Trace ListItem("template-document-literal") </trace>
	[structural]

/* inline echo */

rule [template-document-echo]: 
	<k> 'TemplateDocument('ListWrap(K:K,, Stuff:KList)) => 
	K ~> 'TemplateDocument('ListWrap(Stuff)) ... </k>
	<trace> Trace:List => Trace ListItem("template-document-echo") </trace>
	when getKLabel(K) ==KLabel 'InlineEcho
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Literals} */
// ---------------------------------------------------------------------------------------------

rule    [literal-int]:
	    <k> 'LNumber('Deci(Str:String)) => alpha(String2Int(Str)) ... </k>
	    [structural]

rule    [literal-float]:
	    <k> 'DNumber(Str:String) => alpha(String2Float(Str)) ... </k>
	    [structural]

rule    [literal-string]:
	    <k> 'Literal(Str:String) => alpha(Str)	... </k>
	    [structural]

rule    [literal-true]:
	    <k> 'True(_) => alpha(true) ... </k>
    	[structural]

rule    [literal-false]:
	    <k> 'False(_) => alpha(false) ... </k>
	    [structural]

rule    [literal-null]:
	    <k> 'Null(_) => alpha(NULL) ... </k>
	    [structural]		

























/* TODO: remove when done
rule    [literal-int]:
	    <k> 'LNumber('Deci(Str:String)) => String2Int(Str) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-int") </trace>
	    [structural]

rule    [literal-float]:
	    <k> 'DNumber(Str:String) => String2Float(Str) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-float") </trace>
	    [structural]

// can be removed?
//rule [hello]:
//	<k> 'Deci(V:Value) => V ... </k>
//	<trace> Trace:List => Trace ListItem("hello") </trace>
//	[structural]

rule    [literal-string]:
	    <k> 'Literal(Str:String) => Str	... </k>
	    <trace> Trace:List => Trace ListItem("literal-string") </trace>
	    [structural]

rule    [literal-true]:
	    <k> 'True(_) => true ... </k>
	    <trace> Trace:List => Trace ListItem("literal-true") </trace>
    	[structural]

rule    [literal-false]:
	    <k> 'False(_) => false ... </k>
	    <trace> Trace:List => Trace ListItem("literal-false") </trace>
	    [structural]

rule    [literal-null]:
	    <k> 'Null(_) => NULL ... </k>
	    <trace> Trace:List => Trace ListItem("literal-null") </trace>
	    [structural]		
*/


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Blocks} 
		Blocks are evaluated by simply executing the statement (i.e. we simply discard
		parenthesis). */
// ---------------------------------------------------------------------------------------------

rule [block]:
	<k> 'Block(B:K) => B ... </k> 									
	<trace> Trace:List => Trace ListItem("block") </trace>
	[structural]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Sequential composition} 
        Statements are avaluated conditionally, depending on the status of the 
        machine. For example, if the status is NEXT, statements are executed 
        normally, but if the status is e.g. RET or ERR, statements are not 
        executed. */
///////////////////////////////////////////////////////////////////////////////

rule [seq-cons]:
	<k> 'ListWrap(S:K,, Ss:KList) => S ~> runStmt('ListWrap(Ss)) ... </k>	
	[structural]

rule [seq-empty]:
	<k> 'ListWrap(.KList) => . ... </k>
	[structural]

rule [empty]:	
	<k> 'Empty(.KList) => . ... </k>
	[structural]

//@ statements might or might not be executed, depending on the status 
syntax K ::= "runStmt" "(" K ")"

rule    <k> runStmt(S) => S ... </k>
        <status> NEXT </status> 
        [transition]

rule    <k> runStmt(S) => . ... </k>
        <status> RET </status> 
        [transition]

rule    <k> runStmt(S) => . ... </k>
        <status> ERR </status> 
        [transition]

rule    <k> runStmt(S) ~> K => . ... </k>
        <status> LOOP </status> 
        [transition]



// ---------------------------------------------------------------------------------------------
/*@ \subsection{Expression as a statement} */
// ---------------------------------------------------------------------------------------------

context 'Expr(HOLE)

rule [expr]:	
	<k> 'Expr(V:Value) => . ... </k>
	<trace> Trace:List => Trace ListItem("expr") </trace>
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Variable lookup} 
		Variable lookup returns a reference, i.e. a pair consisting of a location (the location 
		of the appropriate symbol table) and the name of the variable itself. 
		Depending on the type of variable, different symbol tables may be considered: if 
		the variable is a user-defined one, the location of the current environment is used. 
		If the variable is a superglobal, the location of the superglobal envirnoment is 
		used. */
// ---------------------------------------------------------------------------------------------

syntax Var ::= "var" "(" Id ")"

rule [var2Id]: 	
	<k> 'Variable('Simple(Str:String)) => var(String2Id(Str)) ... </k>
	<trace> Trace:List => Trace ListItem("var2Id") </trace>
	[structural]

/*@ The following is the rule for variable lookup. Note that is makes use of the auxiliary
	predicates defined below. */

rule [var] :   
	<k> var(X:Id)  => *Cond(isSuperGlobal(X), 
			ref(Lsg, Id2String(X)), 
			ref(Lg, Id2String(X))) ... </k>
	<currentScope> Lg:Loc </currentScope>
	<superGlobalScope> Lsg:Loc </superGlobalScope>
	when notBool(isSpecialVar(X))
	[step]

/*@ The following auxiliary predicate returns true if the variable is a superglobal, 
	false otherwise */

syntax  Bool ::= "isSuperGlobal" "(" Id ")"	[function]

rule
	isSuperGlobal(X:Id) => true
	when 	(Id2String(X) ==String "_GET") orBool 
           	(Id2String(X) ==String "_POST") orBool 
            (Id2String(X) ==String "GLOBALS")
            	
rule
	isSuperGlobal(X:Id) => false
	when 	(Id2String(X) =/=String "_GET") andBool 
			(Id2String(X) =/=String "_POST") andBool 
			(Id2String(X) =/=String "GLOBALS")

/*@ The following auxiliary predicate returns true if the variable is special (e.g. this), 
	false otherwise  */

syntax Bool ::= "isSpecialVar" "(" Id ")"		[function]

rule 	
	isSpecialVar(X:Id) => true 
	when (Id2String(X) ==String "this") 

rule
	isSpecialVar(X:Id) => false 
	when notBool (Id2String(X) ==String "this") 

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Variable variables} */
// ---------------------------------------------------------------------------------------------

// A small comment!

context 'IndirectReference(HOLE)

rule [variable-variable-arg2Value] :	
	<k> 'IndirectReference(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	[intermediate]

rule [variable-variable]	:	
	<k> 'IndirectReference(X:String) => 'Variable('Simple(X)) ... </k>
	[step]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Array access} */
// ---------------------------------------------------------------------------------------------

// Array access is strict in both arguments

context [array-access-strict-LHS]: 
	'ArrayAccess(HOLE,,_)
	[structural]

context [array-access-strict-RHS]: 
	'ArrayAccess(_,,HOLE)
	[structural]

// The RHS is fully evaluated to a Language Value

rule [array-access-LHS2LangValue]: 	
	<k> 'ArrayAccess(_,,(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-LHS2LangValue") </trace>
	[intermediate]

// The RHS must be a key (int or string). If it's not, we try to convert it to Int as follows

rule [array-access-key-cast-float]:	
	<k> 'ArrayAccess(_,,(F:Float => 'IntCast(F))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-float") </trace>
	[intermediate]
	
rule [array-access-key-cast-bool]:	
	<k> 'ArrayAccess(_,,(B:Bool => 'IntCast(B))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-bool") </trace>
	[intermediate]

/*
rule [array-access-key-cast-string]:	
	<k> 'ArrayAccess(_,,(S:AString => 'IntCast(S))) ... </k>
	when isIntType(String2Int(S)) // TODO: this condition only works in concrete.
                                  // need to update the predicates 
	[intermediate]
*/

// Finally if no key is provided, we use NULL as s special key

rule [array-access-no-key]:	
	<k> 'ArrayAccess(_,,('None(.KList) => NULL)) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-no-key") </trace>
	[step]

// And here we give semantics to array access -- generating references.

rule [array-access-simple]:	
	<k> 'ArrayAccess(L:Loc,,X:Key) => ref(L, X) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-simple") </trace>
	[step]

rule [array-access-nested]: 	
	<k> 'ArrayAccess(R:Ref,,K:Key) => lref(R,K,arr) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-nested") </trace>
	[step]

// This is not a real rule of the semantics. We just use it to catch a parser bug

rule [array-access-parsing-error]:	
	<k> 'ArrayAccess(S:String,,_) ~> K:K => print("PARSING BUG!!!") ... </k>
	<errorManagement> _ => 4 </errorManagement>
	<trace> Trace:List => Trace ListItem("array-access-parsing-error") </trace>
	[error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Assignment by value} */
// ---------------------------------------------------------------------------------------------

context [assign-strict-LHS]: 
	'Assign(HOLE,,_)
	[structural]
	
context [assign-strict-RHS]: 
	'Assign(_:KResult,,HOLE) 
	[structural]

rule [assign-LHS2Loc]:
	<k> 'Assign((R:Ref => convertToLoc(R,l)),,_:KResult) ... </k>
	<trace> Trace:List => Trace ListItem("assign-LHS2Loc") </trace>
	[intermediate]

rule [assign-RHS2Loc-NonLiteral]:    
	<k> 'Assign(_:KResult,, (V:ConvertibleToLoc => convertToLoc(V,r))) ... </k>
	<trace> Trace:List => Trace ListItem("assign-RHS2Loc-NonLiteral") </trace>
	when notBool (isLiteral(V))
	[intermediate]

rule [assign-RHS2LangValue-overflow]:    
	<k> 'Assign(L:Loc,, L1:Loc) =>  
			'Expr('Assign(L,, convertToLanguageValue(L1))) ~>
			'Expr(reset(L)) ~>
			convertToLanguageValue(L) ...
	</k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("assign-RHS2LangValue-overflow") </trace>
	when currentOverflow(M,L1)
	[intermediate]

rule [assign-RHS2LangValue-no-overflow]:    
	<k> 'Assign(L:Loc,, (L1:Loc => convertToLanguageValue(L1))) ... </k>  
	<heap> M:Map </heap>
		<trace> Trace:List => Trace ListItem("assign-RHS2LangValue-no-overflow") </trace>
	when notBool (currentOverflow(M,L1))
	[intermediate]

rule [assign-RHS2LangValue-locNull]:    
	<k> 'Assign(L:Loc,, (locNull => NULL)) ... </k>
	<trace> Trace:List => Trace ListItem("assign-RHS2LangValue-locNull") </trace>
	[intermediate]

rule [assign]:
	<k> 'Assign(L:Loc,, V:LanguageValue) => copyValueToLoc(V, L) ~> V ... </k>
	<trace> Trace:List => Trace ListItem("assign") </trace>
	[step]

rule [assign-error]:
	<k> 'Assign(thisTag(L:K),, _) =>  ERROR("Cannot re-assign $this in %s on line %d") ... </k>
	<trace> Trace:List => Trace ListItem("assign-error") </trace>
	[step, error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Shortcuts} */
// ---------------------------------------------------------------------------------------------

rule [concat-assign]: 
	<k> 'ConcatAssign(X:K,, Y:K) => 'Assign(X,, 'Concat(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("concat-assign") </trace>
	[structural]

rule [div-assign]: 
	<k> 'DivAssign(X:K,, Y:K) => 'Assign(X,, 'Div(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("div-assign") </trace>
	[structural]

rule [min-assign]: 
	<k> 'MinAssign(X:K,, Y:K) => 'Assign(X,, 'Min(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("min-assign") </trace>
	[structural]
	
rule [mod-assign]: 
	<k> 'ModAssign(X:K,, Y:K) => 'Assign(X,, 'Mod(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("mod-assign") </trace>
	[structural]

rule [plus-assign]: 
	<k> 'PlusAssign(X:K,, Y:K) => 'Assign(X,, 'Plus(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("plus-assign") </trace>
	[structural]	

// the following bitwise ops are not fully supported - we exclude them from the trace 

rule //[and-assign]: 
	<k> 'AndAssign(X:K,, Y:K) => 'Assign(X,, 'And(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("and-assign") </trace>
	[structural]

rule //[or-assign]: 
	<k> 'OrAssign(X:K,, Y:K) => 'Assign(X,, 'Or(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("or-assign") </trace>
	[structural]

rule //[xor-assign]: 
	<k> 'XorAssign(X:K,, Y:K) => 'Assign(X,, 'LXor(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("xor-assign") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Assignment by reference} */
// ---------------------------------------------------------------------------------------------

context [ref-assign-strict-LHS]:
	'ReferenceAssign(HOLE,,_)
	[structural]

context [ref-assign-strict-RHS]:
	'ReferenceAssign(_:KResult,,HOLE)
	[structural]

rule [ref-assign-LHS2BasicRef]:
	<k> 'ReferenceAssign((LR:LRef => toBasicRef(LR)),, V:Value) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-LHS2BasicRef") </trace>
	[intermediate]

rule [ref-assign-RHS2Loc]:
	<k> 'ReferenceAssign(_,, (V:ConvertibleToLoc => convertToLoc(V, l))) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-RHS2Loc") </trace>
	[intermediate]

rule [ref-assign-fresh-obj-prop]:
		<k> 'ReferenceAssign(ref((L:Loc => L2), X:Key),, L1:Loc) ... </k>
        <heap> 
        ... 
        	L  |-> zval(OID(L2,_,_),_,_,_) L1 |-> _
			L2 |-> zval(Array(_,Elems),_,_,_)
		...
		</heap>
	<trace> Trace:List => Trace ListItem("ref-assign-fresh-obj-prop") </trace>
	when notBool (Elems hasProperty X)
		[intermediate]

rule [ref-assign-fresh-array-elem]:
		<k> 'ReferenceAssign(ref(L:Loc, X:Key),, L1:Loc) =>  
            ArrayUpdateElem(L, X, L1) ~> ref(L, X) ... </k>
        <heap> ... L  |-> zval(Array(_,Elems),_,_,_) L1 |-> _ ... </heap>
	<trace> Trace:List => Trace ListItem("ref-assign-fresh-array-elem") </trace>
	when notBool (Elems hasProperty X)
		[step]
			
rule [ref-assign-existent-array-elem]:
		<k> 'ReferenceAssign(ref(L:Loc, X:Key),, L1:Loc) =>  
            //'Unset(ref(L, X)) ~>
            ArrayUpdateElem(L, X, L1) ~> ref(L, X) ... </k>
        <heap> ... L  |-> zval(Array(_,_ ListItem([X,_,L2]) _),_,_,_) L1 |-> _ ... </heap>
	<trace> Trace:List => Trace ListItem("ref-assign-existent-array-elem") </trace>
	when L1 =/=K L2
        [step]
        	
rule [ref-assign-existent-array-elem-same]:
		<k> 'ReferenceAssign(ref(L:Loc, X:Key),, L1:Loc) =>  ref(L,X) ... </k>
        <heap> ... L  |-> zval(Array(_,_ ListItem([X,_,L1]) _),_,_,_) L1 |-> _ ... </heap>
	<trace> Trace:List => Trace ListItem("ref-assign-existent-array-elem-same") </trace>
	[step]

rule [ref-assign-language-value]:
	<k> 'ReferenceAssign(ref(L:Loc, X:Key),,V:PlainLanguageValue) => 
		WARNING("Only variables should be assigned by reference in %s on line %d\n") ~> 
			'Assign(ref(L:Loc, X:Key),,V:PlainLanguageValue) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-language-value") </trace>
	[step, error]

// --------------------------------------------------------------------------------------------
/*@ \subsection{List Assignment} */
// ---------------------------------------------------------------------------------------------

context [list-assign-strict-LHS]: 
	'ListAssign(HOLE,,_:K)
	[structural]

context [list-assign-strict-RHS]: 
	'ListAssign(_:KResult,,HOLE)
	[structural]

context [list-elems-strict]: 
	'List('ListWrap(_:KList,, 'Some(HOLE),, _:KList))
	[structural]

rule isKResult ('List('ListWrap(X:KList))) => true 	    when isKResult(X)
rule isKResult ('Some(X:K)) => true	    	            when isKResult(X)
rule isKResult ('None(_)) => true

rule [list-assign-RHS2Loc]: 	
	<k> 'ListAssign(_:KResult,, (R:ConvertibleToLoc => convertToLoc(R,r))) ... </k>
	<trace> Trace:List => Trace ListItem("list-assign-RHS2Loc") </trace>
	[intermediate]
	
rule [list-assign]: 
	<k> 'ListAssign('List(Vars:K),,L:Loc) => assignSeqOfIds(Vars, L, 0) ~>  L ... </k>
	<trace> Trace:List => Trace ListItem("list-assign") </trace>
	[step]
	
syntax K ::= "assignSeqOfIds" "(" K "," Loc "," Int ")"

rule [assign-seq-some-non-list]:    
	<k> assignSeqOfIds('ListWrap('Some(X:KResult),, Xs:KList), L:Loc,I:Int) =>             
    assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ~> 'Expr('Assign(X,, 'ArrayAccess(L,, I))) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-some-non-list") </trace>
	when getKLabel(X) =/=KLabel 'List
	[internal]

rule [assign-seq-some-list]:    
	<k> assignSeqOfIds('ListWrap('Some('List('ListWrap(X:KList))),, Xs:KList), L:Loc, I:Int ) =>
	assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ~> 'Expr('ListAssign('List('ListWrap(X)),, 'ArrayAccess(L,, I))) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-some-list") </trace>
	when isKResult(X)								
	[internal]

rule [assign-seq-skip]:
	<k> assignSeqOfIds('ListWrap('None(_),, Xs:KList), L:Loc, I:Int )  =>
		assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-skip") </trace>
	[internal]

rule [assign-seq-nil]:    
	<k> assignSeqOfIds('ListWrap(.KList), L:Loc, _ ) => . ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-nil") </trace>
	[internal]
	
rule [assign-seq-not-a-loc]:    
	<k> 'ListAssign(_:KResult,, V:LanguageValue) => false ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-not-a-loc") </trace>
	[internal, error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsSet} */
// ---------------------------------------------------------------------------------------------

context [internal-fun-isset-args-strict]:
	'InternalFunction('Isset('ListWrap(_:KList,,HOLE,,_:KList)))
	[structural]
	
rule [internal-fun-isset-2-spec]: 	
	<k> 'InternalFunction('Isset('ListWrap(Arg:KResult))) => isset(Arg) ... </k>
	<trace> Trace:List => Trace ListItem("internal-fun-isset-2-spec") </trace>
	[structural]
	
syntax K ::= "isset" "(" K ")" [strict]

rule [isset-arg2BasicRef]:    
	<k> isset(LR:LRef => readBasicRef(LR)) ... </k>
	<trace> Trace:List => Trace ListItem("isset-arg2BasicRef") </trace>
	[internal, intermediate]

rule [isset-true]:
	<k> isset (ref(L:Loc, K:Key)) => true ... </k>
	<heap> ... L |-> zval(Array(_,_ ListItem([K,public,_]) _),_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-true") </trace>
	[internal]

rule [isset-false]:
	<k> isset (ref(L:Loc, K:Key)) => false ... </k>
	<heap> ... L |-> zval(Array(_,Elems),_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-false") </trace>
	when notBool (Elems hasProperty K)
	[internal]

// this never gets called because toBasicRef (called above) always CREATE the ref
// TODO: fix it

rule [isset-null]: 	
	<k> isset(ref(locNull,_)) => false ... </k>
	<trace> Trace:List => Trace ListItem("isset-null") </trace>
	[internal]

rule [isset-scalar]:    
	<k> isset (ref(L:Loc, K:Key)) => false ... </k>
	<heap> ... L |-> zval(V:Value,_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-scalar") </trace>
	when notBool (V isCompoundValue)
	[internal]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Unset} */
// ---------------------------------------------------------------------------------------------

rule [unset-cons]:
	<k> 'Unset('ListWrap(Item:K,, T:KList)) => 'Unset(Item) ~> 'Unset('ListWrap(T)) ... </k>
	<trace> Trace:List => Trace ListItem("unset-cons") </trace>
	[internal]
	
rule [unset-nil]:
	<k> 'Unset('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("unset-nil") </trace>
	[step]

context [unset-strict]: 
	'Unset(HOLE) 
	when getKLabel(HOLE) =/=KLabel 'ListWrap
	[structural]

rule [unset-arg2BasicRef]: 
	<k> 'Unset(LR:LRef => readBasicRef(LR)) ... </k>
	<trace> Trace:List => Trace ListItem("unset-arg2BasicRef") </trace>
	[intermediate]

rule [unset-obj-prop]:        
	<k> 'Unset(ref((L => L1),X)) ... </k>
	<heap> ... L |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("unset-obj-prop") </trace>
	[intermediate]

rule [unset-null-ref]:    
	<k> 'Unset(ref(L:Loc, X:Key))=> . ... </k>
	<heap>... L |-> zval(Array(_,Elems),_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("unset-null-ref") </trace>
	when notBool (Elems hasProperty X)				
	[step]

rule [unset-non-current]:
	<k> 'Unset(ref(L:Loc, X:Key)) => decRefCount(L1) ... </k>
	<heap> ... L |-> zval(Array([Y,Vis1],_ (ListItem([X,Vis,L1]) => .) _),_,_,_)  
			  L1 |-> zval(V:Value,_,_,_) ... </heap>       
	<trace> Trace:List => Trace ListItem("unset-non-current") </trace>
	when (Y =/=K X) orBool (Vis =/=K Vis1)
	[step]

rule [unset-current-none]:    
	<k> 'Unset(ref(L:Loc, X:Key)) => decRefCount(L1) ... </k>
	<heap> ... L |-> zval(Array(none,_ (ListItem([X,Vis,L1]) => .) _),_,_,_)  
			  L1 |-> zval(V:Value,_,_,_) ... </heap>       
	<trace> Trace:List => Trace ListItem("unset-current-none") </trace>
	[step]
	
rule [unset-current-not-last]:
	<k> 'Unset(ref(L:Loc, X:Key)) => decRefCount(L1) ... </k>
	<heap> ... L |-> zval(Array([X,Vis] => [X1,V1],_ ((ListItem([X,Vis,L1]) => .) ListItem([X1,V1,_])) _),_,_,_)  
			  L1 |-> zval(V:Value,_,_,_) ... </heap>       
	<trace> Trace:List => Trace ListItem("unset-current-not-last") </trace>
	[step]

rule [unset-current-last]:   
	<k> 'Unset(ref(L:Loc, X:Key)) => decRefCount(L1) ... </k>
	<heap> ... L |-> zval(Array([X,Visib] => none, E:List (ListItem([X,Visib,L1]) => .)),_,_,_)  
		L1 |-> zval(V:Value,_,_,_) ... </heap>       
	<trace> Trace:List => Trace ListItem("unset-current-last") </trace>
	[step]

rule [unset-refNull]:    
	<k> 'Unset(ref(locNull, _)) => . ... </k>
	<trace> Trace:List => Trace ListItem("unset-refNull") </trace>
	[step]

endmodule 
