require "shared.k"
require "classes.k"

module OBJECTS
	imports SHARED
	imports CLASSES

syntax Id ::= "stdclass"
rule "stdclass" => "stdClass" [function, anywhere]
rule stdclass => stdClass [function, anywhere]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Object creation} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Instanceof} 
        http://php.net/manual/en/language.operators.type.php */
// ---------------------------------------------------------------------------------------------

// is_stdclass is just an auxiliary predicate - nothing complex, just a macro

syntax Bool ::= String "is_stdclass" [predicate]
rule S is_stdclass => (S ==String "stdclass") orBool (S ==String "stdClass") 

// the LHS should be a reference (since 'Instance of is strict in both its 
// arguments - see syntax.k), we now evaluate it to a language value

rule [instanceof-lhs-2-lang-value]:
    'Instanceof((V:ConvertibleToLanguageValue => convertToLanguageValue(V)),, _) 
	[intermediate]

// the RHS should be a reference (since 'Instance of is strict in both its 
// arguments - see syntax.k), we now evaluate it to a language value.
// NOTE: we are approximating here, as the behaviour of Zend is more strict 
// (i.e. it will allow only certain things here, while we allow everything)
    
rule [instanceof-lhs-2-lang-value]:
    'Instanceof(_,, (V:ConvertibleToLanguageValue => convertToLanguageValue(V))) 
	[intermediate]

// the LHS is a language value but not an object. in this case the result is false.

rule [instanceof-LHS-not-object]:
    'Instanceof(V:LanguageValue,, _) => false
    when notBool (isObjectType(V))
	[step]

// both LHS and RHS are objects. In this case we check wether the LHS object
// is an instance of the RHS object's class 

rule [instanceof-LHS-and-RHS-objects]:
    'Instanceof(OID(_,C1:Id,_),, (OID(_,C2:Id,_) => Id2String(C2)))
	[structural]

// the LHS is an object of class C1 - the class for which we are testing. return true.

rule [instanceof-LHS-object-base]:
    'Instanceof(OID(_,C1:Id,_),, C2:String) => true
    when Id2String(C1) ==String C2
	[step]

// the LHS is an object of class C1, but we are testing if it is an object of
// class C2 - and C1 is different from C2. In this case we check wether C1
// is a subclass of C2. But notice that we exclude stdClass from the check
// (not really sure why, but Zend does it).

rule [instanceof-LHS-object-cons]:
    'Instanceof(OID(_,C1:Id,_),, C2:String) => isSubclass(C1, String2Id(C2))
    when (Id2String(C1) =/=String C2) andBool (notBool (C2 is_stdclass)) 
	[intermediate] // or step?

// finally, if the LHS is an object of class C1 which is not stdClass, and 
// C2 is stdClass, we must return false.

rule [instanceof-LHS-object-stdclass]:
    'Instanceof(OID(_,C1:Id,_),, C2) => false
    when (notBool (Id2String(C1) is_stdclass)) andBool (C2 is_stdclass)
	[step]
// ---------------------------------------------------------------------------------------------
/*@ \subsection{This} */
// ---------------------------------------------------------------------------------------------

rule [this-obj-cntx]: 	
	<k> var(X:Id) => thisTag(L) ... </k>
	<object> L:Loc </object>
	<trace> Trace:List => Trace ListItem("this-obj-cntx") </trace>
	when Id2String(X) ==String "this"
	[step]

rule [this-no-obj-cntx]: 	
	<k> var(X:Id) => thisTag(NULL) ... </k>
	<object> .K </object>
	<trace> Trace:List => Trace ListItem("this-no-obj-cntx") </trace>
	when Id2String(X) ==String "this"
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Object creation (new construct)} */
// ---------------------------------------------------------------------------------------------

/*@ Surface syntax  */

rule isKResult(X:Id) => true

context [obj-creation-className-strict]: 
	'ObjectCreation(HOLE,,_)

rule [obj-creation-className2LangValue]: 	
	<k> 'ObjectCreation((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("obj-creation-className2LangValue") </trace>
	[intermediate]

rule [obj-creation-className2Id]:    
	<k> 'ObjectCreation((Name:String => String2Id(Name)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("obj-creation-className2Id") </trace>
	[intermediate]


rule 	'ObjectCreation(ClassName:K) => 'ObjectCreation(ClassName,,'ListWrap(.KList)) 

// -----------

rule [obj-creation]: 	
	<k> 'ObjectCreation(ClassName:Id,,Args:K) => Literal('ObjectCreation(ClassName,,Args)) ... </k>
	<trace> Trace:List => Trace ListItem("obj-creation") </trace>
	[step]

syntax K ::= "makeNewObject" "(" Loc "," Id "," K ")" [strict(1)]

rule [make-new-obj]:
	<k> makeNewObject(L1:Loc, ClassName:Id, ConstructArgs:K) =>  
		ArrayCreateEmpty(L) ~>
		objectInit(L, ClassName) ~> copyValueToLoc(OID(L, ClassName, 0), L1,true) ~> 
		allocAndRunConstructor(L1, ConstructArgs) ... </k>
	<trace> Trace:List => Trace ListItem("make-new-obj") </trace>
	when fresh(L:Loc)
    [internal, mem]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Initialization of the object data structure} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "objectInit" "(" Loc "," Id ")"

rule [obj-init]: 	
	<k> objectInit(L':Loc, ClassName) => buildObjElemList(L', ClassName, PropList) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(_,.List),_,_,_) ... </heap>
	<classes> ... ClassName |-> class(_,PropList:List,_,_)  ... </classes>
	<trace> Trace:List => Trace ListItem("obj-init") </trace>
	[internal]

syntax K ::= "buildObjElemList" "(" Loc "," Id "," List ")"

// cons -- goto parent

rule [built-obj-prop-list-parent]: 	
	<k> buildObjElemList(L,ClassName,.List) => buildObjElemList(L,Parent,PropList) ... </k>
	<classes> 
	... 
		ClassName |-> class(Parent,_,_,_)  
		Parent |-> class(_,PropList,_,_)  
	... 
	</classes>
	<trace> Trace:List => Trace ListItem("built-obj-prop-list-parent") </trace>
	[internal]

// finish when reached the root

rule [built-obj-prop-list-root]: 	
	<k> buildObjElemList(L,ClassName:Id,.List) => . ... </k>
	<trace> Trace:List => Trace ListItem("built-obj-prop-list-root") </trace>
	when (Id2String(ClassName) ==String "stdClass")
	[internal]

// context

context [built-obj-prop-list-args-strict]: 	 
	buildObjElemList(L, ClassName, ListItem(prop(X,_,HOLE)) Items:List) 
	[structural]

// --- adding a public or protected property ---

rule [built-obj-prop-list-non-private-add]: 	
	<k> buildObjElemList(L', ClassName, ListItem(prop(X,Visib,V:Value)) Items:List) => 
		ArrayCreateElem(L',X,Visib,allocValue(V)) ~>
		buildObjElemList(L', ClassName, Items) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(_,ObjItems),_,_,_)  ... </heap>
	<trace> Trace:List => Trace ListItem("built-obj-prop-list-non-private-add") </trace>
	when (notBool ObjItems hasProperty X) andBool 
		 (Visib ==K public orBool Visib ==K protected)
	[internal]
	
// --- public or protected property is already present, hence skipped ---

rule [built-obj-prop-list-non-private-skip]: 	
	<k> buildObjElemList(L', ClassName, ListItem(prop(X,Visib,_)) Items:List) =>  
		buildObjElemList(L', ClassName, Items) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(_,ObjItems),_,_,_)  ... </heap>
	<trace> Trace:List => Trace ListItem("built-obj-prop-list-non-private-skip") </trace>
	when (ObjItems hasProperty X) andBool (Visib ==K public orBool Visib ==K protected)
	[internal]

// --- adding a private property ---

rule [built-obj-prop-list-private]: 	
	<k> buildObjElemList(L', ClassName, ListItem(prop(X,private(ClassName),V:Value)) Items:List) => 
		ArrayCreateElem(L,X,private(ClassName),allocValue(V)) ~>
		buildObjElemList(L', ClassName, Items) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(_,ObjItems),_,_,_)  ... </heap>
	<trace> Trace:List => Trace ListItem("built-obj-prop-list-private") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Object field access} */
// ---------------------------------------------------------------------------------------------

context [obj-access-LHS-strict]: 
	'ObjectAccess(HOLE,, _:K)
	[structural]
	
context [obj-access-RHS-strict]:
	'ObjectAccess(_:K,, HOLE)
	[structural]

rule [obj-access-RHS2LangValue]:
	<k> 'ObjectAccess(_:K,, (R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("obj-access-RHS2LangValue") </trace>
	[intermediate]

syntax ThisOrLiteral ::= ThisTag | LiteralValue
syntax ConvertibleToLoc ::= ThisOrLiteral

rule [obj-access-RHS2Loc-ThisOrLiteral]:
	<k> 'ObjectAccess((V:ThisOrLiteral => convertToLoc(V,r)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("obj-access-RHS2Loc-ThisOrLiteral") </trace>
	[intermediate]

rule [obj-access-nested]:
	<k> 'ObjectAccess(R:Ref,, K:Key) => lref(R, K, obj) ... </k>
	<trace> Trace:List => Trace ListItem("obj-access-nested") </trace>
	[step]
	
rule [obj-access-simple]:
	<k> 'ObjectAccess(L:Loc,, K:Key) => ref(L, K) ... </k>
	<trace> Trace:List => Trace ListItem("obj-access-simple") </trace>
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Object Property} */
// ---------------------------------------------------------------------------------------------

context 'ObjectProperty('Variable('Braced(HOLE)))
rule	'ObjectProperty('Variable('Braced(V:Value))) => V
rule	'ObjectProperty('Variable('Braced(V:ConvertibleToLanguageValue) => convertToLanguageValue(V)))
rule 	'ObjectProperty('Simple(V:Value)) => V
rule 	'ObjectProperty('Variable('Simple(X:String))) => 'Variable('Simple(X:String)) 

context 'ObjectProperty('Braced(HOLE))
rule 	'ObjectProperty('Braced(V:LanguageValue)) => *toString(V)

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Method Call} */
// ---------------------------------------------------------------------------------------------

context [meth-call-name-strict]:	
	'FunctionCall(_:K,,HOLE,,_:K,,_:Int) 
	[structural]

context	[meth-call-obj-strict]:	
	'FunctionCall(HOLE,,_:K,,_:K,,_:Int) 
	[structural]

rule [meth-call-obj2Loc]:	
	<k> 'FunctionCall(((R:ConvertibleToLoc => convertToLoc(R,r)),,_:K,,_:K,,_:Int)) ... </k>
	<trace> Trace:List => Trace ListItem("meth-call-obj2Loc") </trace>
	[intermediate]
	
rule [meth-call-name2LangValue]:	
	<k> 'FunctionCall(_:K,,(R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_:K,,_:Int) ... </k>
	<trace> Trace:List => Trace ListItem("meth-call-name2LangValue") </trace>
	[intermediate]

rule [meth-call]: 	
	<k> 'FunctionCall(L',,MethodName:String,,'ListWrap(Args:KList),,Lab:Int) =>
		methRunIfVisible(methodLookup(ObjClass,MethodName),'ListWrap(Args),L',Lab) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L  |-> zval(OID(L1:Loc,ObjClass:Id,_),_,_,_) ...  </heap>
	<trace> Trace:List => Trace ListItem("meth-call") </trace>
	[step]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Auxiliary operations for method call} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Method Lookup} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "methodLookup" "(" Id "," String ")"
           | "methodInfo" "(" Id "," String "," K "," Bool ")"
           | "MethodNotFound"

rule isKResult(methodInfo(_,_,_,_)) => true

rule [meth-lookup-found]:
	<k> methodLookup(ClassName:Id, MethName:String) => methodInfo(ClassName, MethName, Visibility, Static) ... </k> 
	<classes> ... ClassName |-> class(_,_,Meths:Map(MethName |-> method(_,Visibility:ArrayItemVisibility,Static:Bool)),_) ... </classes>
	<trace> Trace:List => Trace ListItem("meth-lookup-found") </trace>
	[internal]
	
rule [meth-lookup-parent]:
	<k> methodLookup(ClassName:Id, MethName:String) => methodLookup(Parent, MethName)  ... </k>
	<classes> ... ClassName |-> class(Parent:Id,_,Meths:Map,_) ... </classes>
	<trace> Trace:List => Trace ListItem("meth-lookup-parent") </trace>
	when notBool(MethName in keys(Meths)) 
    [internal]
    
rule [meth-lookup-not-found]: 	
	<k> methodLookup (ClassName:Id , MethName:String) => ERROR(makeAccess2NonDefinedClassMethodErrorMsg(ClassName, MethName))  ... </k>
	<trace> Trace:List => Trace ListItem("meth-lookup-not-found") </trace>
	when Id2String(ClassName) ==String "ROOT"
	[internal] 
	
syntax String ::= "makeAccess2NonDefinedClassMethodErrorMsg" "(" Id "," String ")" [function]

rule 
	makeAccess2NonDefinedClassMethodErrorMsg(Class,Var) => 
		"Call to undefined method "  +String
		Id2String(Class) +String "::" +String "$" +String Var +String " in " +String "%s" +String
		" on line " +String "%d\n"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Run the method is visibility constraints are met} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "methRunIfVisible" "(" K "," K "," OptionLoc "," Int ")" [strict(1)]

// Calling a non static method 

rule [meth-run-if-visib-non-static]:
	<k> methRunIfVisible(methodInfo(Class:Id, Name:String, Visibility:ArrayItemVisibility, false), Args:K, Obj,Lab) =>  
		*Cond(isVisible(Class, CurrentClass, Visibility), methExecute(Class, Name, Args, Obj,Lab), 99)
	... </k>
	<class> CurrentClass:K </class>
	<trace> Trace:List => Trace ListItem("meth-run-if-visib-non-static") </trace>
	[internal]
	
// Calling a static method as non static -- the call is desugared to a static call

rule [meth-run-if-visib-static]:
	<k> methRunIfVisible(methodInfo(Class:Id, Name:String, Visibility:ArrayItemVisibility, true), Args:K, Obj,Lab) =>  
		*Cond(isVisible(Class, CurrentClass, Visibility), methExecute(Class, Name, Args, none,Lab), 99)
	... </k>
	<class> CurrentClass:K </class>
	<trace> Trace:List => Trace ListItem("meth-run-if-visib-static") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Run a method} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "methExecute" "(" Id "," String "," K "," OptionLoc "," Int ")"         

rule [meth-exec]:    
	<k> methExecute(Class:Id,MethName:String,Args:K,Obj:OptionLoc,Lab) => runFunction(MethName,FunDef,Args,Class,Obj,Static,Lab,sf(MethName,L,CurrentClass,CurrentObj,(retTypeOfFunDef(FunDef)),D,Lab)) ... </k>
	<classes> ... Class |-> class(_,_,Meths:Map(MethName |-> method(FunDef:K,_,Static)),_) ... </classes>
	<functionArgumentsDeclaration> D:K => . </functionArgumentsDeclaration>
	<currentScope> L:Loc </currentScope>
	<class> CurrentClass:K </class>
	<object> CurrentObj:K </object>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Running a constructor} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "allocAndRunConstructor" "(" Loc "," K ")"

// run constructor, old style (function with same name as class)

rule [run-constructor-old]:	
	<k> allocAndRunConstructor(L', Args:K)  =>
		'Expr('FunctionCall(L',,Id2String(ClassName),,Args)) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ...  L |-> zval(OID(_,ClassName,_),_,_,_) ... </heap>
	<classes> ... ClassName |-> class(_,_,Meths:Map,_) ... </classes>
	<trace> Trace:List => Trace ListItem("run-constructor-old") </trace>
	when (Id2String(ClassName) in keys(Meths))
	[internal]

// run the constructor, PHP 5 style */

rule [run-constructor-PHP-5]:	
	<k> allocAndRunConstructor(L', Args:K)  =>
		'Expr('FunctionCall(L',,"__construct",,Args)) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ...  L |-> zval(OID(_,ClassName,_),_,_,_) ... </heap>
	<classes> ... ClassName |-> class(_,_,Meths:Map,_) ... </classes>
	<trace> Trace:List => Trace ListItem("run-constructor-PHP-5") </trace>
	when ("__construct" in keys(Meths))
	[internal]

// No constructor is present 

rule [run-constructor-none]:	
	<k> allocAndRunConstructor(L', Args:K)  => . ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ...  L |-> zval(OID(_,ClassName,_),_,_,_) ... </heap>
	<classes> ... ClassName |-> class(_,_,Meths:Map,_) ... </classes>
	<trace> Trace:List => Trace ListItem("run-constructor-none") </trace>
	when notBool (Id2String(ClassName) in keys(Meths))
	[internal]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Auxiliary stuff for Objects} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{isVisible} */
// ---------------------------------------------------------------------------------------------

syntax K ::=  "isVisible" "(" K "," K "," ArrayItemVisibility ")"

rule    isVisible(_,_,public) => true
rule    isVisible(ObjClass,.K,protected) => false 
rule    isVisible(ObjClass,.K,private(_)) => false
rule    isVisible(Context,Context:Id,private(_)) => true
rule    isVisible(ObjClass,Context:Id,private(_)) => false
            when (ObjClass =/=K Context)
rule    isVisible(ObjClass:Id,Context:Id,protected) => 
            *or(isSuperclass(Context, ObjClass), isSubclass(Context, ObjClass))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{isInPath} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "isInPath" "(" Id "," Id ")"
    
rule 	isInPath(Root:Id, _) => false			when Id2String(Root) ==String "ROOT"
rule 	isInPath(Origin:Id, Root:Id) => true 	when Id2String(Root) ==String "ROOT"
rule 	isInPath(Origin:Id, Origin) => true
rule 	<k> isInPath(Origin:Id, Dest:Id) => isInPath(Parent, Dest) ... </k>
		<classes> ... Origin |-> class(Parent:Id,_,_,_) ... </classes>

// ---------------------------------------------------------------------------------------------
/*@ \subsection{isSubclass and isSuperclass} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "isSubclass" "(" Id "," Id ")" | "isSuperclass" "(" Id "," Id ")"

rule isSubclass(Origin:Id, Dest:Id) => isInPath(Origin, Dest)
rule isSuperclass(Origin:Id, Dest:Id) => isInPath(Dest, Origin)

endmodule
