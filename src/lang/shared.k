require "memory.k"
require "meta.k"

module SHARED
	imports MEMORY
    imports META

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Shared Definitions} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

syntax LoopFrame ::= "loopFrame" "(" K "," OptionForeachArrayPair ")"

syntax ForeachArrayPair ::= "foreachArrayPair" "(" Loc "," OptionLoc ")"
syntax OptionForeachArrayPair ::= ForeachArrayPair | None

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Helper cnstructs} */ 
// ---------------------------------------------------------------------------------------------

syntax K ::= "*Cond" "(" K "," K "," K ")"			[strict(1)]

rule [cond-true]:
	<k> *Cond(true, ActionTrue:K,_) => ActionTrue ... </k>
	<trace> Trace:List => Trace ListItem("cond-true") </trace>
	[internal]

rule [cond-false]:
	<k> *Cond(false,_, ActionFalse:K) => ActionFalse ... </k>
	<trace> Trace:List => Trace ListItem("cond-false") </trace>
	[internal]
  	
syntax K ::= "*or" "(" K "," K ")" 					[strict(1)]

rule [spec-or-true]:
	<k> *or(true, _) => true ... </k>
	<trace> Trace:List => Trace ListItem("spec-or-true") </trace>
	[internal]

rule [spec-or-false]:
	<k> *or(false, K:K) => K ... </k>
	<trace> Trace:List => Trace ListItem("spec-or-false") </trace>
	[internal]

syntax ThisTag ::= "thisTag" "(" K ")" 
rule isKResult (thisTag(_)) => true

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Macros for solving references} */ 
// ---------------------------------------------------------------------------------------------

syntax ConvertibleToLoc ::= LiteralValue | Ref | ThisTag
syntax ConversionMode ::= "l" | "r"
syntax OptionConversionMode ::= ConversionMode | None

syntax Loc ::= "convertToLoc" "(" ConvertibleToLoc "," OptionConversionMode ")" [function]
rule convertToLoc(V:LiteralValue,_) => allocValue(V)
rule convertToLoc(R:Ref,l) => sref2loc(Lget(R)) //SM extract loc from sref
rule convertToLoc(R:Ref,r) => sref2loc(Rget(R))
rule convertToLoc(thisTag(L),_) => L

syntax BasicRef ::= "toBasicRef" "(" LRef ")" [function]
rule toBasicRef(lref(R:Ref,X:Key,T:RefType)) => ref(LgetRef(R, T), X)

syntax BasicRef ::= "readBasicRef" "(" LRef ")" [function]
rule readBasicRef(lref(R:Ref,X:Key,T:RefType)) => ref(RgetRef(R, T), X)

syntax ConvertibleToLanguageValue ::= Loc | ConvertibleToLoc
syntax LanguageValue ::= "convertToLanguageValue" "(" ConvertibleToLanguageValue ")" [function]

rule convertToLanguageValue(L:Loc) => read(L)
rule convertToLanguageValue(V:ConvertibleToLoc) => read(convertToLoc(V,r))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Internal "arithmetic"} */ 
// ---------------------------------------------------------------------------------------------

syntax K ::= "isEqualScalar" "(" K "," K ")" [seqstrict]

rule [isEqual-scalar-RHS2LangValue]:
	<k> isEqualScalar(_, (R2:ConvertibleToLanguageValue => convertToLanguageValue(R2))) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-scalar-RHS2LangValue") </trace>
	[intermediate]

/* TODO: remove
rule //[isEqual-scalar-LS2LangValue]:
	<k> isEqualScalar((R1:ConvertibleToLanguageValue => convertToLanguageValue(R1)), _) ... </k>
	//<trace> Trace:List => Trace ListItem("isEqual-scalar-LS2LangValue") </trace>
	[intermediate]
*/

rule [isEqual-scalar]:
	<k> isEqualScalar(I1:Int, I2:Int) => I1 ==Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-scalar") </trace>
	[internal]

context 'Some(HOLE)
rule 	'Some(V:Value) => V

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Auxiliary predicates} */ 
// ---------------------------------------------------------------------------------------------

syntax Bool ::= "currentOverflow" "(" Map "," Loc ")" [function]

rule currentOverflow(Mem:Map(L |-> zval(Array(Crnt,_),_,_,_)), L) => Crnt ==K none
rule currentOverflow(Mem:Map(L |-> zval(V,_,_,_)), L) => false
	when notBool (isArrayType(V))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Visibility 2 string} */ 
// ---------------------------------------------------------------------------------------------

syntax String ::= "visibility2String" "(" ArrayItemVisibility ")" [function]

rule visibility2String(public) => "public"
rule visibility2String(protected) => "protected"
rule visibility2String(private(_)) => "private"




//////// LIST OPS
syntax Int ::= "listLen" "(" List ")" [function]
rule	listLen(.List) => 0
rule	listLen(ListItem(_) L:List) => 1 +Int listLen(L)







endmodule
