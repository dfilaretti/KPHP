require "shared.k"
module ARRAYS 
    imports SHARED

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Array literal} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Surface syntax} */
// ---------------------------------------------------------------------------------------------

rule [array-literal]:
	<k> 'Array(Elems:K) => Literal('Array(Elems)) ... </k>
	<trace> Trace:List => Trace ListItem("array-literal") </trace>
	[structural]

syntax K ::= "makeArrayLiteral" "(" Loc "," K ")" [strict(1)]

context [make-array-literal-key-values-strict]: 
	makeArrayLiteral(_, 'ListWrap(_:KList,,HOLE,,_:KList))

context [pair-key-strict]: 
	'Pair('Some('Key(HOLE)),, _:K)

context [pair-value-strict-1]:
	'Pair(_:K,, 'Value(HOLE))

context [pair-value-strict-2]:
	'Pair(_:K,, 'RefValue(HOLE))

rule 	isKResult('Pair('Some('Key(K:KResult)),, 'Value(V:KResult))) => true
rule 	isKResult('Pair('None(_),, 'Value(V:KResult))) => true
rule 	isKResult('Pair('Some('Key(K:KResult)),, 'RefValue(V:KResult))) => true
rule 	isKResult('Pair('None(_),, 'RefValue(V:KResult))) => true

// Allocates an array literal
rule [make-array-literal]: 	
	<k> makeArrayLiteral(L:Loc, 'ListWrap(KVs:KList)) => 
		ArrayCreateEmpty(L) ~>
		ArrayInitProps(L, 'ListWrap(KVs)) ... </k>
	<trace> Trace:List => Trace ListItem("make-array-literal") </trace>
	when isKResult(KVs)
	[internal]

/*@ Initialise an array property */
 
syntax K ::= "ArrayInitProps" "(" Loc "," K ")"

rule [array-init-props-nil]:    
	<k> ArrayInitProps(L:Loc, 'ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("array-init-props-nil") </trace>
	[internal]

rule [array-init-props-cons]:
	<k> ArrayInitProps(L:Loc, 'ListWrap(Kv:K,, KVs:KList)) => ArrayInitProp(L, Kv) ~> ArrayInitProps(L, 'ListWrap(KVs)) ... </k>
	<trace> Trace:List => Trace ListItem("array-init-props-cons") </trace>
	[intermediate]

/*@ Initialize a list of array properties */

syntax K ::= "ArrayInitProp" "(" Loc "," K ")"

rule [array-init-prop-key]:    
	<k> ArrayInitProp(L:Loc, 'Pair('Some('Key(X:Value)),, 'Value(V:KResult))) => 'Expr('Assign('ArrayAccess(L,,X),, V)) ... </k>
	<trace> Trace:List => Trace ListItem("array-init-prop-key") </trace>
	[internal]

rule [array-init-prop-key-ref]:    
	<k> ArrayInitProp(L:Loc, 'Pair('Some('Key(X:Value)),, 'RefValue(V:KResult))) => 'Expr('ReferenceAssign('ArrayAccess(L,,X),, V)) ... </k>
	<trace> Trace:List => Trace ListItem("array-init-prop-key-ref") </trace>
	[internal]

rule [array-init-prop-def-key]:    
	<k> ArrayInitProp(L':Loc, 'Pair('None(_),, 'Value(V:KResult))) => 
		'Expr('Assign(ref(L',biggestIntKey(Elems) +Int 1),, V)) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,Elems),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("array-init-prop-def-key") </trace>
	[internal]

rule [array-init-prop-def-key-ref]:    
	<k> ArrayInitProp(L':Loc, 'Pair('None(_),, 'RefValue(V:KResult))) => 
		'Expr('ReferenceAssign(ref(L',biggestIntKey(Elems) +Int 1),, V)) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,Elems),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("array-init-prop-def-key-ref") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Arrays internal functions} */
// ---------------------------------------------------------------------------------------------

context [empty-strict]: 
	'InternalFunction('Empty(HOLE))

rule [empty-arg2LangValue]:
	<k> 'InternalFunction('Empty(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("empty-arg2LangValue") </trace>
	[intermediate]

// Integers

rule [empty-int-true]:
	<k> 'InternalFunction('Empty(0)) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-int-true") </trace>
	[step]
	
rule [empty-int-false]:
	<k> 'InternalFunction('Empty(I:Int)) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-int-false") </trace>
	when I =/=Int 0
	[step]
	
// Floats

rule [empty-float-true]:
	<k> 'InternalFunction('Empty(0.0)) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-float-true") </trace>
	[step]
	
rule [empty-float-false]:
	<k> 'InternalFunction('Empty(F:Float)) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-float-false") </trace>
	when F =/=Float 0.0
	[step]
	
// Booleans

rule [empty-bool-true]:
	<k> 'InternalFunction('Empty(false)) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-bool-true") </trace>
	[step]
	
rule [empty-bool-false]:
	<k> 'InternalFunction('Empty(true)) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-bool-false") </trace>
	[step]
	
// Strings

rule [empty-string-true]:
	<k> 'InternalFunction('Empty(S:String)) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-string-true") </trace>
	when (S ==String "") orBool (S ==String "0") 
	[step]
	
rule [empty-string-false]:
	<k> 'InternalFunction('Empty(S:String)) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-string-false") </trace>
	when (S =/=String "") andBool (S =/=String "")
	[step]

// Arrays
		
rule [empty-array-true]: 	
	<k> 'InternalFunction('Empty(Array(_,Elems))) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-array-true") </trace>
	when Elems ==List .List
	[step]
		
rule [empty-array-false]:
	<k> 'InternalFunction('Empty(Array(_,Elems))) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-array-false") </trace>
	when Elems =/=List .List
	[step]

// Objects 
	
rule [empty-object]: 	
	<k> 'InternalFunction('Empty(O:Object)) => false ... </k>
	<trace> Trace:List => Trace ListItem("empty-object") </trace>
	[step]
	
// NULL
	
rule [empty-null]: 	
	<k> 'InternalFunction('Empty(NULL)) => true ... </k>
	<trace> Trace:List => Trace ListItem("empty-null") </trace>
	[step]
		
endmodule
