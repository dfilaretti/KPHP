require "errors.k"
require "functions.k"
module CLASSES 
    imports ERRORS
	imports FUNCTIONS

	syntax Id ::= "this" | "stdClass" | "ROOT"
    
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Class Declaration} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Data Structures} */
// ---------------------------------------------------------------------------------------------

syntax ClassDef ::= "class" "(" Id "," List "," Map "," Loc ")"
syntax ClassProp ::= "prop" "(" String "," ArrayItemVisibility "," K ")"
syntax ClassMethod ::= "method" "(" FunDef "," ArrayItemVisibility "," Bool ")"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Surface syntax} */
// ---------------------------------------------------------------------------------------------

rule [class-no-extends]: 	
	<k> 'Class(_,,Name:String,,('None(_) => 'Some('Extends("stdClass"))),,_,,_) ... </k>
	<trace> Trace:List => Trace ListItem("class-no-extends") </trace>
	when Name =/=String "stdClass"
	[structural]
	
rule [class-stdClass]: 	
	<k> 'Class(_,,"stdClass",,('None(_) => 'Some('Extends("ROOT"))),,_,,_) ... </k>
	<trace> Trace:List => Trace ListItem("class-stdClass") </trace>
	[internal]

rule [class]: 	
	<k> 'Class('Normal(_),,Name:String,,'Some('Extends(Parent:String)),,'None(_),,'ListWrap(Members:KList)) =>
		createEmptyClass(String2Id(Name), String2Id(Parent)) ~> initClass(String2Id(Name), 'ListWrap(Members)) ... </k>
	<classInstanceCounters> ... .=> String2Id(Name) |-> 0 ... </classInstanceCounters>
	<trace> Trace:List => Trace ListItem("class") </trace>
	[step]
	
rule [class-implements]: 	
	<k> 'Class(_,,_,,_,,'Some('Implements(_)),,_) => NOT-SUPPORTED("KPHP ERROR: Interfaces not supported!") ... </k>
	<trace> Trace:List => Trace ListItem("class-implements") </trace>
	[step, error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Internal operations for class declaration} */
// ---------------------------------------------------------------------------------------------

syntax Bool ::= "isStatic" "(" K ")" [function]

rule isStatic('Modifiers('ListWrap('Static(_),, 'Public(_)))) => true
rule isStatic('Modifiers('ListWrap('Static(_),, 'Protected(_)))) => true
rule isStatic('Modifiers('ListWrap('Static(_),, 'Private(_)))) => true
rule isStatic('Modifiers('ListWrap('Public(_),,'Static(_)))) => true
rule isStatic('Modifiers('ListWrap('Protected(_),,'Static(_)))) => true
rule isStatic('Modifiers('ListWrap('Private(_),,'Static(_)))) => true
rule isStatic('Modifiers('ListWrap('Static(_)))) => true
rule isStatic('Modifiers('ListWrap('Public(_)))) => false
rule isStatic('Modifiers('ListWrap('Protected(_)))) => false
rule isStatic('Modifiers('ListWrap('Private(_)))) => false

syntax ArrayItemVisibility ::= "getVisibility" "(" K "," Id ")" [function]

rule getVisibility('Modifiers('ListWrap('Static(_),, 'Public(_))),_) => public
rule getVisibility('Modifiers('ListWrap('Static(_),, 'Protected(_))),_) => protected
rule getVisibility('Modifiers('ListWrap('Static(_),, 'Private(_))),ClassName) => private(ClassName)
rule getVisibility('Modifiers('ListWrap('Public(_),,'Static(_))),_) => public
rule getVisibility('Modifiers('ListWrap('Protected(_),,'Static(_))),_) => protected
rule getVisibility('Modifiers('ListWrap('Private(_),,'Static(_))),ClassName) => private(ClassName)
rule getVisibility('Modifiers('ListWrap('Static(_))),_) => public
rule getVisibility('Modifiers('ListWrap('Public(_))),_) => public
rule getVisibility('Modifiers('ListWrap('Protected(_))),_) => protected
rule getVisibility('Modifiers('ListWrap('Private(_))),ClassName) => private(ClassName)

/*@ Creating an empty class */

syntax K ::= "createEmptyClass" "(" Id "," Id ")"

rule [create-empty-class]:    
	<k> createEmptyClass(ClassName:Id, ParentName:Id) => ArrayCreateEmpty(L1) ~> incRefCount(L1) ... </k>
	<classes> Classes:Map => Classes[class(ParentName, .List, .Map, L1)/ClassName] </classes>
	<trace> Trace:List => Trace ListItem("create-empty-class") </trace>
	when notBool (ClassName in keys(Classes)) andBool fresh(L1:Loc)
	[internal]

/*@ Class initialization */

syntax K ::=  "initClass" "(" Id "," K ")"

rule [init-class-cons]:
	<k> initClass(ClassName:Id, 'ListWrap(D:K,, Ds:KList)) => 
		initClassMemberDecl(ClassName, D) ~>
		initClass(ClassName, 'ListWrap(Ds)) ... </k>         
	<trace> Trace:List => Trace ListItem("init-class-cons") </trace>
	[intermediate]

rule [init-class-nil]:
	<k> initClass(ClassName:Id, 'ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("init-class-nil") </trace>
	[internal]
	
/* Processing a class member (prop or method) declaration */

syntax K ::= "initClassMemberDecl" "(" Id "," K ")"

// TODO: maybe remove??
/*
rule 
	<k> initClassMemberDecl(ClassName:Id,'InstanceVariable(_,,'ListWrap(.KList))) => . ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-nil") </trace>
	[internal]
*/

/* Non supported stuff: */

// --- Class Constants
rule [init-class-member-constant-decl-list]: 
	<k> initClassMemberDecl(_, 'ClassConstantDeclList(_)) => NOT-SUPPORTED("ClassConstantDeclList") ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-constant-decl-list") </trace>
	[internal]
	
/* property with no modifiers are considered just public by default */

rule [init-class-member-decl-no-modifier]:
	<k> initClassMemberDecl(
		ClassName:Id, 
		'InstanceVariable('ListWrap(Vars:K))) => 
	initClassMemberDecl(
		ClassName, 
		'InstanceVariable('Modifiers('ListWrap('Public(.KList))),, 'ListWrap(Vars))) ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-no-modifier") </trace>
	[structural]

/* static property */

rule [init-class-member-decl-static]:
	<k> initClassMemberDecl(ClassName:Id, 'InstanceVariable(Modifiers:K,, Members:K)) => 
	writeClassInstanceMembers(ClassName, Members, getVisibility(Modifiers,ClassName)) ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-static") </trace>
	when notBool (isStatic(Modifiers))			
	[intermediate]

/* instance property */

rule [init-class-member-decl-instance]:    
	<k> initClassMemberDecl(ClassName:Id, 'InstanceVariable(Modifiers:K,, Members:K)) => 
	writeClassStaticMembers(ClassName, Members, getVisibility(Modifiers,ClassName)) ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-instance") </trace>
	when isStatic(Modifiers)
	[intermediate]

/* methods with no declared visibility are considered poublic by default */

rule [init-class-member-decl-meth-no-modifiers]:	
	<k> initClassMemberDecl(ClassName:Id, 'FunctionDecl(
		FName:String,,
		Parameters:K,,
		Body:K)) => 
	initClassMemberDecl(ClassName, 'FunctionDecl(
		'Modifiers('ListWrap('Public(.KList))),,
		FName,,
		Parameters,,
		Body)) ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-meth-no-modifiers") </trace>
	[structural]
			
rule [init-class-member-decl-meth-ref-no-modifiers]:	
	<k> initClassMemberDecl(ClassName:Id, 'FunctionDeclRef(
		FName:String,,
		Parameters:K,,
		Body:K)) => 
	initClassMemberDecl(ClassName, 'FunctionDeclRef(
		'Modifiers('ListWrap('Public(.KList))),,
		FName,,
		Parameters,,
		Body)) ... </k>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-meth-ref-no-modifiers") </trace>
	[structural]

/* method (return by value) */
rule [init-class-member-decl-meth]:	    
	<k> initClassMemberDecl(
			ClassName:Id, 'FunctionDecl(
				Modifiers:K,,
				FName:String,,
				Parameters:K,,
				Body:K
			)
		)
		=> ArrayCreateEmpty(L) ~> incRefCount(L) ~>
		writeClassMethod(ClassName, FName, Parameters, @byValue, getVisibility(Modifiers,ClassName), isStatic(Modifiers), makeStaticDecls(Body, L), L)
	... </k>
	<classes>... ClassName |-> class(_,_,Methods:Map,_) ...</classes>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-meth") </trace>
	when notBool (FName in keys(Methods)) andBool (fresh(L:Loc))
	[internal]

/* method (return by reference) */
rule [init-class-member-decl-meth-ref]:	        
	<k> initClassMemberDecl(
			ClassName:Id, 'FunctionDeclRef(
				Modifiers:K,,
				FName:String,,
				Parameters:K,,
				Body:K
			)
		)
		=> ArrayCreateEmpty(L) ~> incRefCount(L) ~>
		writeClassMethod(ClassName, FName, Parameters, @byRef, getVisibility(Modifiers,ClassName), isStatic(Modifiers), makeStaticDecls(Body, L), L)
	... </k>
	<classes>... ClassName |-> class(_,_,Methods:Map,_) ...</classes>
	<trace> Trace:List => Trace ListItem("init-class-member-decl-meth-ref") </trace>
	when notBool (FName in keys(Methods)) andBool (fresh(L:Loc))
	[internal]

// Membership predicates
syntax Bool ::= List "hasMember" K [function]
rule ListItem(prop(K2:K,_,_)) L2:List hasMember K1:K => (K1 ==K K2) orBool (L2 hasMember K1)
rule .List hasMember _ => false

/* Initializes instance members  */

syntax K ::= "writeClassInstanceMembers" "(" Id "," K "," ArrayItemVisibility ")" 

rule [write-class-instance-members-nil]:    
	<k> writeClassInstanceMembers(_,'ListWrap(.KList),_) => . ... </k>
	<trace> Trace:List => Trace ListItem("write-class-instance-members-nil") </trace>
	[internal]

// If no initialisation value is provided, NULL is used instead

rule [write-class-instance-members-no-default]:    
	<k> writeClassInstanceMembers(ClassName:Id,'ListWrap(('Normal('Variable('Simple(X:String))) => 'Default('Variable('Simple(X)),,NULL)),, Others:KList),Visib) ... </k>
	<trace> Trace:List => Trace ListItem("write-class-instance-members-no-default") </trace>
	[structural]

rule [write-class-instance-members]:
	<k> writeClassInstanceMembers(ClassName:Id,'ListWrap('Default('Variable('Simple(X:String)),,DefValue:K),, Others:KList), Visib) =>
		writeClassInstanceMembers(ClassName:Id,'ListWrap(Others), Visib) ... </k>
	<classes>... ClassName |-> class(_,ClassProps => ClassProps ListItem(prop(X,Visib,DefValue)),_,_) ... </classes>
	<trace> Trace:List => Trace ListItem("write-class-instance-members") </trace>
	[intermediate]

/* Initializes static members  */

syntax K ::= "writeClassStaticMembers" "(" Id "," K "," ArrayItemVisibility ")" 

rule [write-class-static-members]:
	<k> writeClassStaticMembers(_,'ListWrap(.KList),_) => . ... </k>
	<trace> Trace:List => Trace ListItem("write-class-static-members") </trace>
	[internal]

// If no initialisation value is provided, NULL is used instead

rule [write-class-static-members-no-default]:    
	<k> writeClassStaticMembers(ClassName:Id,'ListWrap(('Normal('Variable('Simple(X:String))) => 'Default('Variable('Simple(X)),,NULL)),, Others:KList),Visib) ... </k>
	<trace> Trace:List => Trace ListItem("write-class-static-members-no-default") </trace>
	[structural]
	
context
	writeClassStaticMembers(_,'ListWrap('Default('Variable('Simple(X:String)),, HOLE),, Others:KList),_)

rule [write-class-static-members-default]:
	<k> writeClassStaticMembers(
				ClassName:Id, 
				'ListWrap('Default('Variable('Simple(X:String)),,DefValue:Value),, Others:KList), 
				Visib) => 
			ArrayCreateElem(L,alpha(X),Visib,allocValue(DefValue)) ~>
			writeClassStaticMembers(ClassName, 'ListWrap(Others), Visib) ...
			</k>
	<classes>... ClassName |-> class(_,_,_,L) ... </classes>
	<trace> Trace:List => Trace ListItem("write-class-static-members-default") </trace>
	[intermediate]

/* Initializes a method members  */

syntax K ::= "writeClassMethod" "(" Id "," String "," K "," K "," ArrayItemVisibility "," Bool "," K  "," Loc ")" [strict(7)]

rule [write-class-method-if-visited]: 	
	<k> writeClassMethod(_,_,_,_,_,_, visitedK('MethodBody(Body:K) => Body), L:Loc) ... </k>
	<trace> Trace:List => Trace ListItem("write-class-method-if-visited") </trace>
	[structural]

rule [write-class-method]: 	
	<k> writeClassMethod(ClassName:Id, FName:String, Parameters:K, RetType:K, V, StaticOrNot:Bool, visitedK(Body:K), L:Loc) => . ... </k>
	<classes>... ClassName |-> class(_,_,Methods:Map => Methods[(method(f(Parameters, Body, RetType, L), V, StaticOrNot))/FName],_) ...</classes>
	<trace> Trace:List => Trace ListItem("write-class-method") </trace>
	when getKLabel(Body) ==KLabel 'ListWrap
endmodule 
