require "classes.k"

module SCOPE-RESOLUTION
    imports CLASSES

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Self and parent} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

rule [class-name-normal]:
	<k> 'ClassName(S:String) => S ... </k>
	<trace> Trace:List => Trace ListItem("class-name-normal") </trace>
	when (S =/=String "self") andBool (S =/=String "parent") 
	[step]

rule [class-name-self]:
	<k> 'ClassName("self") => Id2String(CurrentClass) ... </k>
	<class> CurrentClass:K </class>
	<trace> Trace:List => Trace ListItem("class-name-self") </trace>
	[step]
	
rule [class-name-parent]:
	<k> 'ClassName("parent") => Id2String(ParentClass) ... </k>
	<class> CurrentClass:K </class>
    <classes>... CurrentClass |-> class(ParentClass:K,_,_,_)  ...</classes>
	<trace> Trace:List => Trace ListItem("class-name-parent") </trace>
	[step]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Static method call} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

context [static-fun-class-name-strict]:
	'StaticFunctionCall(HOLE,, _:K,, _:K)
	[structural]
	
context [static-fun-fname-strict]:
	'StaticFunctionCall(_:K,, HOLE,, _:K)
	[structural]

context [static-fun-args-strict]:
	'StaticFunctionCall(_:K,, _:K,, 'ListWrap(_:KList,,HOLE,,_:KList))
	[structural]

rule [static-fun-fname2LangValue]:
	<k> 'StaticFunctionCall(_:K,, (R:Ref => convertToLanguageValue(R)),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("static-fun-fname2LangValue") </trace>
	[intermediate]

rule [static-fun]: 	
	<k> 'StaticFunctionCall(ClassName:String,,MethName:String,,'ListWrap(Args:KList)) => 
		methRunIfVisible(methodLookup(String2Id(ClassName), MethName), 'ListWrap(Args), none,123) ... </k> // TODO: fix label!!!
	<trace> Trace:List => Trace ListItem("static-fun") </trace>
	when isKResult(Args) 
	[step]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Access to class static properties} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

rule [class-constant-arg2Id]: 	
	<k> 'ClassConstant((S:String => String2Id(S)),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("class-constant-arg2Id") </trace>
	[internal]

rule [class-constant-parent]: 	
	<k> 'ClassConstant((ClassName:Id => Parent),,'Variable('Simple(X:String))) ... </k>
	<classes> ... ClassName |-> class(Parent,_,_,L')  ...  </classes>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,M),_,_,_)  ... </heap>
	<trace> Trace:List => Trace ListItem("class-constant-parent") </trace>
	when notBool (M hasProperty X)
	[intermediate]

rule [class-constant]:
	<k> 'ClassConstant(ClassName:Id,,'Variable('Simple(X:String))) 
		=> *Cond(
				isVisible(ClassName,Context,V),
				L1,
				ERROR(makeAccess2NonVisibleClassConstantErrorMsg(ClassName, X, V))
			) ... </k>
	<classes> ... ClassName |-> class(_,_,_,L')  ...  </classes>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,_ ListItem([alpha(X),V,L1]) _),_,_,_)  ... </heap>	//TODO check
	<class> Context:K  </class>
	<trace> Trace:List => Trace ListItem("class-constant") </trace>
	[step]
	
syntax String ::= "makeAccess2NonVisibleClassConstantErrorMsg" "(" Id "," String "," ArrayItemVisibility ")" [function]

rule
	makeAccess2NonVisibleClassConstantErrorMsg(Class,Var,Visib) => 
		"Cannot access " +String visibility2String(Visib) +String " property " +String
		Id2String(Class) +String "::" +String "$" +String Var +String " in " +String "%s" +String
		" on line " +String "%d\n"



endmodule 
