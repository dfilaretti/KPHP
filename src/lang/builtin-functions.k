require "shared.k"
require "io.k"

module BUILTIN-FUNCTIONS
	imports SHARED
	imports IO
	
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Builtin Functions} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{array key exists} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "array_key_exists" "(" K "," K  ")" [strict]

rule [array-key-exists-RHS2LangValue]: 	
	<k> array_key_exists(_,(V:ConvertibleToLanguageValue => convertToLanguageValue(V))) ... </k>
	<trace> Trace:List => Trace ListItem("array-key-exists-RHS2LangValue") </trace>
	[intermediate]
	
rule [array-key-exists-LHS2LangValue]: 	
	<k> array_key_exists((V:ConvertibleToLanguageValue => convertToLanguageValue(V)),_) ... </k>
	<trace> Trace:List => Trace ListItem("array-key-exists-LHS2LangValue") </trace>
	[intermediate]

rule [array-key-exists-obj]: 
	<k> array_key_exists(_,(OID(L,_,_) => L)) ... </k>
	<trace> Trace:List => Trace ListItem("array-key-exists-obj") </trace>
	[intermediate]

rule [array-key-exists]:
	<k> array_key_exists(X:Key, Array(_,Elems)) => Elems hasProperty X ... </k>
	<trace> Trace:List => Trace ListItem("array-key-exists") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{count} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "count" "(" K ")" [strict]

rule [count-arg2LangValue]: 	
	<k> count(V:ConvertibleToLanguageValue => convertToLanguageValue(V)) ... </k>
	<trace> Trace:List => Trace ListItem("count-arg2LangValue") </trace>
	[intermediate]

rule [count-object]:
	<k> count((OID(L,_,_) => L)) ... </k>
	<trace> Trace:List => Trace ListItem("count-object") </trace>
	[intermediate]

rule [count-scalar-value]: 	
	<k> count(V:LanguageValue) => 1 ... </k>
	<trace> Trace:List => Trace ListItem("count-scalar-value") </trace>
	when (notBool (V isCompoundValue)) andBool (V =/=K NULL)
	[internal]

rule [count-null]:	
	<k> count(NULL) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("count-null") </trace>
	[internal]
	
rule [count-array]: 	
	<k> count(Array(_,Elems)) => len(Elems) ... </k>
	<trace> Trace:List => Trace ListItem("count-array") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Current} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "current" "(" K ")" [strict]

// first we evaluate the argument to a location
rule [current-arg2Loc]:
	<k> current(R:ConvertibleToLoc => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("current-arg2Loc") </trace>
	[intermediate]

// when trying to read the current of the array being iterated by a foreach, AND 
// we are in the 'local copy/no-aliasing' case (i.e. the foreach iteration is being
// 'secretly' performed on a local copy of the array), we return the value of 
// the current for the local copy of the array (the one being iterated). 
// Note that this is different from what Zend does (which we actually believe 
// is a bug -- i.e. be believe the behaviour we propose here was the intended one.

rule [current-1a]:
	<k> current(L:Loc) => myCurrent(L1) ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(L,L1:Loc))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("current-1a") </trace>
	[intermediate]
	
// all the following cases are meant to be 'normal cases' (i.e. not the special case
// above). What they does is just to perform 'current' normally.
	
rule [current-1b]:
	<k> current(L:Loc) => myCurrent(L) ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(_,L))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("current-1b") </trace>
	[intermediate]

rule [current-2a]:
	<k> current(L:Loc) => myCurrent(L) ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(L,none))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("current-2a") </trace>
	[intermediate]
	
rule [current-2b]:
	<k> current(L:Loc) => myCurrent(L) ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(L1,L2))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("current-2b") </trace>
	when (L =/=K L1 andBool L =/=K L2)
	[intermediate]

rule [current-3]:
	<k> current(L:Loc) => myCurrent(L) ... </k>
	<loopStack> ListItem(loopFrame(_,none))  ... </loopStack>
	<trace> Trace:List => Trace ListItem("current-3") </trace>
	[intermediate]

rule [current-4]:
	<k> current(L:Loc) => myCurrent(L) ... </k>
	<loopStack> .List </loopStack>
	<trace> Trace:List => Trace ListItem("current-4") </trace>
	[intermediate]
	
// we need 'myCurrent' for convenience

syntax K ::= "myCurrent" "(" K ")" [strict]

// Object
rule [current-obj]:    
	<k> myCurrent(L':Loc => L1) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L  |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("current-obj") </trace>
	[intermediate]

// Array (no current)   
rule [current-none]:    
	<k> myCurrent(L':Loc) => false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap>... L |-> zval(Array(none,_),_,_,_) ...</heap>
	<trace> Trace:List => Trace ListItem("current-none") </trace>
	[internal]

// Array (current)   
rule [current-some]:    
	<k> myCurrent(L':Loc) => L1 ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array([X,V], _ ListItem([X,V,L1]) _),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("current-some") </trace>
	[internal]

// Scalar (returns NULL)
rule [current-null]:    
	<k> myCurrent(L':Loc) => NULL ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("current-null") </trace>
	when notBool (isArrayType(V) orBool isObjectType(V)) 
    [internal]
    
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Key} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "key" "(" K ")" [strict]

rule [key-arg2Loc]:    
	<k> key(R:Ref) => key(convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("key-arg2Loc") </trace>
	[intermediate]
	
// Object
rule [key-obj]:    
	<k> key(L':Loc => L1) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L  |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("key-obj") </trace>
	[intermediate]

// Array (no current)   
rule [key.none]:    
	<k> key(L':Loc) => false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap>... L |-> zval(Array(none,_),_,_,_) ...</heap>
	<trace> Trace:List => Trace ListItem("key.none") </trace>
	[internal]

// Array (current)   
rule [key-some]:    
	<k> key(L':Loc) => alpha(X) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array([X,_],_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("key-some") </trace>
	[internal]

// Scalar case (returns NULL)
rule [key-scalar]:    
	<k> key(L':Loc) => NULL ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("key-scalar") </trace>
	when notBool (isArrayType(V) orBool isObjectType(V)) 
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Next} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "next" "(" K ")" [strict]

// the argument of next is evaluated to a location
rule [next-arg2Loc]:
	<k> next(R:Ref) => next(convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("next-arg2Loc") </trace>
	[intermediate]

// if trying to do next on the element being iterated in a foreach loop, 
// it must be ignored...
rule [next-ignore]:
	<k> next(L:Loc) => NULL ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(L,_))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("next-ignore") </trace>
	[intermediate]

// ... while in all other cases the operation can be executed:
// 1: we are in foreach, but next is executed on something which is not the iterated element
rule [next-do-1]:
	<k> next(L:Loc) => myNext(L) ... </k>
	<loopStack> ListItem(loopFrame(_,foreachArrayPair(L1,_))) ... </loopStack>
	<trace> Trace:List => Trace ListItem("next-do-1") </trace>
	when (L =/=K L1)
	[intermediate]

// 2: we are in a loop, but not a foreach loop
rule [next-do-2]:
	<k> next(L:Loc) => myNext(L) ... </k>
	<loopStack> ListItem(loopFrame(_,none))  ... </loopStack>
	<trace> Trace:List => Trace ListItem("next-do-2") </trace>
	[intermediate]

// 3: we are not into a loop at all
rule [next-do-3]:
	<k> next(L:Loc) => myNext(L) ... </k>
	<loopStack> .List </loopStack>
	<trace> Trace:List => Trace ListItem("next-do-3") </trace>
	[intermediate]

syntax K ::= "myNext" "(" K ")" [strict]

// object
rule [my-next-obj]:    
	<k> myNext(L':Loc) =>  myNext(L1) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L  |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("my-next-obj") </trace>
	[intermediate]

// array
rule [my-next-not-last-item]:    
	<k> myNext(L':Loc) =>  current(L') ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
 	<heap> 
	... 
	L |-> zval(Array([X,V] => [X1,V1], _ ListItem([X,V,_]) ListItem([X1,V1,_]) _ ),_,_,_) 
	... 
	</heap>
	<trace> Trace:List => Trace ListItem("my-next-not-last-item") </trace>
	[internal]
 	
rule [my-next-last-item]:    
	<k> myNext(L':Loc) =>  current(L') ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array([X,V] => none,_ ListItem([X,V,_])),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("my-next-last-item") </trace>
	[internal]
	
rule [my-next-none]:    
	<k> myNext(L':Loc) =>  false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(none,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("my-next-none") </trace>
	[internal]

// default case
rule [next-scalar]:    
	<k> myNext(L':Loc) => NULL ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap>... L |-> zval(V:Value, _, _, _) ...</heap>
	<trace> Trace:List => Trace ListItem("next-scalar") </trace>
	when notBool (isArrayType(V) orBool isObjectType(V))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Reset} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "reset" "(" K ")" [strict]

rule [reset-arg-strict]:
	<k> reset(R:Ref) => reset(convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("reset-arg-strict") </trace>
	[intermediate]

// object case
rule [reset-obj]:    
	<k> reset(L':Loc => L1) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L  |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("reset-obj") </trace>
	[intermediate]

// array case
rule [reset-array]:    
	<k> reset(L':Loc) => current(L') ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_=>head(K), K:List),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("reset-array") </trace>
	[internal]

// default case
rule [reset-scalar]:    
	<k> reset(L':Loc) => NULL ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap>... L |-> zval(V,_,_,_) ...</heap>
	<trace> Trace:List => Trace ListItem("reset-scalar") </trace>
	when notBool (V isCompoundValue)
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Each} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "each" "(" K ")" [strict]

rule [each-arg2Loc]:    
	<k> each(R:Ref) => each(convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("each-arg2Loc") </trace>
	[intermediate]

// Object case
rule [each-obj]:    
	<k> each(L':Loc) => each(L1) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(OID(L1,_,_),_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("each-obj") </trace>
	[intermediate]

// Scalar
rule [each-scalar]:
	<k> each(L':Loc) => NULL ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("each-scalar") </trace>
	when notBool (V isCompoundValue)
	[internal]

rule [each-none]:    
	<k> each(L':Loc) => false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap>... L |-> zval(Array(none,_),_,_,_) ...</heap>
	<trace> Trace:List => Trace ListItem("each-none") </trace>
	[internal]

rule [each-last]:
	<k> each(L':Loc) =>  
    	'Array('ListWrap(
    		'Pair('Some('Key(0)),, 'Value(K)),, 
    		'Pair('Some('Key(1)),, 'Value(convertToLanguageValue(L1))),,
    		'Pair('Some('Key("key")),, 'Value(K)),, 
    		'Pair('Some('Key("value")),, 'Value(convertToLanguageValue(L1)))
    		)
    	)... </k>            
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array([K,V] => [X1,V1],_ ListItem([K,V,L1]) ListItem([X1,V1,_]) _),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("each-last") </trace>
	[internal]		

rule [each-non-last]:    
	<k> each(L':Loc) =>  
    	'Array('ListWrap(
    		'Pair('Some('Key(0)),, 'Value(K)),, 
    		'Pair('Some('Key(1)),, 'Value(convertToLanguageValue(L1))),,
    		'Pair('Some('Key("key")),, 'Value(K)),, 
    		'Pair('Some('Key("value")),, 'Value(convertToLanguageValue(L1)))
    		)
    	)... </k>  
	<thematrix> ... L' |-> L ... </thematrix>	          
	<heap> ... L |-> zval(Array([K,V] => none,_ ListItem([K,V,L1])),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("each-non-last") </trace>
	[internal]

    
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Strlen} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "strlen" "(" K ")" [strict]

rule [strlen-arg2LangValue]: 
	<k> strlen(L:ConvertibleToLanguageValue => convertToLanguageValue(L)) ... </k>
	<trace> Trace:List => Trace ListItem("strlen-arg2LangValue") </trace>
	[intermediate]
	


	rule [strlen-arg2String]: 
	<k> strlen(V:LanguageValue => *toString(V)) ... </k>
	<trace> Trace:List => Trace ListItem("strlen-arg2String") </trace>
	when notBool (isStringType(V))
	[intermediate]

rule [strlen]: 
	<k> strlen(S:String) => lengthString(S) ... </k>
	<trace> Trace:List => Trace ListItem("strlen") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Var dump} */
// ---------------------------------------------------------------------------------------------

/* As a preliminary step we 'unroll' calls to unset which has more that one argument.   
   For example: var_dump($x, $y) ==> var_dump($x); var_dump($y). */

rule [vardump-unroll-cons]:
	<k> 'FunctionCall("var_dump",,'ListWrap(Arg:K,, Args:KList)) =>
		'Expr('FunctionCall("var_dump",,'ListWrap(Arg))) ~>
		'FunctionCall("var_dump",,'ListWrap(Args)) ... </k>
	<trace> Trace:List => Trace ListItem("vardump-unroll-cons") </trace>
	when (Args =/=KList .KList)
	[structural]
	
rule [func-call-vardump]:
	<k> 'FunctionCall(FName:String,,'ListWrap(Arg:K),,Lab) => 
		runFunction(FName, FunDef,'ListWrap(Arg),none,none,true,Lab,sf(FName,L,CurrentClass,CurrentObj,retTypeOfFunDef(FunDef),D,Lab)) ... </k>
	<functions> ... FName |-> FunDef ... </functions>
	<functionArgumentsDeclaration> D:K => . </functionArgumentsDeclaration>
	<currentScope> L:Loc </currentScope>
	<class> CurrentClass:K </class>
	<object> CurrentObj:K </object>
	when (FName ==String "var_dump") 
	[step]

syntax K ::= "var_dump" "(" K ")" [strict]

rule [vardump-arg2Loc]:    
	<k> var_dump (R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("vardump-arg2Loc") </trace>
	[intermediate]

/* var_dumping an array  */
rule [vardump-array]:
	<k> var_dump (L':Loc) => 
            print("array(") ~> 
			print(len(Elems)) ~> 
            print(") {\n") ~>
            indentInc ~>
            dump_content(Elems) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,Elems:List),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-array") </trace>
	[internal]

/* var_dumping an object  */
rule [vardump-object]:
	<k> var_dump (L':Loc) => 
    		print("object(") ~> 
            print(Id2String(ClassName)) ~>
            print(")#%d") ~>
            print(" (") ~> 
			print(len(Elems)) ~> 
			print(") {\n") ~>
            indentInc ~>
            dump_content(Elems) ... </k>
	<thematrix> 
	... 
		L'  |-> L 
		L1' |-> L1
	... 
	</thematrix>	
	<heap>
	...
		L  |-> zval(OID(L1',ClassName,_),_,_,_)
		L1 |-> zval(Array(_,Elems:List),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("vardump-object") </trace>
	[internal]

/* var_dumping a string  */


rule [vardump-string]:    
	<k> var_dump (L':Loc) => 
            *Cond(IsRef, print("&"), .) ~>
            print("string") ~> 
            print("(") ~>
            print(strlen(L)) ~>
            print(") \"") ~>
            print(S) ~>
            print("\"\n") ...
        </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(S:AString,_,_,IsRef) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-string") </trace>
	[internal]

/* var_dumping a boolean  */
rule [vardump-bool]:    
	<k> var_dump (L':Loc) => 
            *Cond(IsRef, print("&"), .) ~>
            print("bool") ~> 
            print("(") ~>
            *Cond(B ==Bool true, print("true"), print("false")) ~>
            print(")\n") 
        ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(B:Bool,_,_,IsRef) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-bool") </trace>
	[internal]

/* var_dumping NULL  */
rule [vardump-null]:    
	<k> var_dump (L':Loc) => 
            //*Cond(IsRef, print("&"), .) ~>
            print("NULL\n")
        ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(NULL,_,_,IsRef) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-null") </trace>
	[internal]

/* var_dumping integers  */
// TODO: move to domain?
rule [vardump-int]:    
	<k> var_dump (L':Loc)  => 
			*Cond(IsRef, print("&"), .) ~> 
            print ("int") ~> 
            print("(") ~>
            print(V) ~> 
            print(")\n") ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	 
	<heap> ... L |-> zval(V:AInt, _, _, IsRef:Bool) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-int") </trace>
	when (V isNumeric)
	
/* var_dumping floats  */
// TODO: move to domain?
rule [vardump-float]:    
	<k> var_dump (L':Loc)  => 
			*Cond(IsRef, print("&"), .) ~> 
            print ("float") ~> 
            print("(") ~>
            print(V) ~>
            //*Cond(hasNoDecimalPart(V), print(Float2Int(V)), print(V))  ~> 
            print(")\n") ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
        <heap> ... L |-> zval(V:AFloat, _, _, IsRef:Bool) ... </heap>
	<trace> Trace:List => Trace ListItem("vardump-float") </trace>
	when (V isNumeric)

/* Here we define an operation that recursively performs var_dump on compound 
   values (i.e. arrays and objects).  */

syntax K ::= "dump_content" "(" List ")"

/* This auxiliary predicte tells wether a key is string or int  */

syntax Bool ::= Key "isStringKey" [function]
rule K:String isStringKey => true
rule K:Int isStringKey => false

/* recursively var_dumps array elements  */
rule [dump-content-1]:   
	 <k> dump_content(ListItem([K:Key,public,L:Loc]) Elems:List) =>
                var_dump_indent(Depth) ~>
                print("[") ~> 
				*Cond(K isStringKey, print("\""), .) ~> 
                print(K) ~> 
                *Cond(K isStringKey, print("\""), .) ~> 
				print("]") ~> 
                print ("=>\n") ~>
                var_dump_indent(Depth) ~>
                var_dump(L) ~>
                dump_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("dump-content-1") </trace>
	[internal]

/* var_dumps protected object property */
rule [dump-content-2]:   
	 <k> dump_content(ListItem([K:String,protected,L:Loc]) Elems:List) =>
                var_dump_indent(Depth) ~>
                print("[\"") ~> 
                print(K) ~> 
                print("\":protected]") ~> 
                print ("=>\n") ~>
                var_dump_indent(Depth) ~>
                var_dump(L) ~>
                dump_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("dump-content-2") </trace>
	[internal]	

/* var_dumps private object property */
rule [dump-content-3]:   
	 <k> dump_content(ListItem([K:String,private(ClassName:Id),L:Loc]) Elems:List) =>
                var_dump_indent(Depth) ~>
                print("[\"") ~> 
                print(K) ~> 
                print("\":\"") ~> 
                print(Id2String(ClassName)) ~>
                print("\":private]") ~> 
                print ("=>\n") ~>
                var_dump_indent(Depth) ~>
                var_dump(L) ~>
                dump_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("dump-content-3") </trace>
		[internal]

rule [dump-content-nil]: 	
	<k> dump_content(.List) => indentDec ~> print("}\n") ... </k>
	<trace> Trace:List => Trace ListItem("dump-content-nil") </trace>
	[internal]

/* Finally some auxiliary indentation functions used for var_dump  */

syntax K ::= "indentInc" | "indentDec"

rule [indent-inc]:    
	<k> indentInc => . ... </k>
	<varDumpLevel> Depth:Int => Depth +Int 1 </varDumpLevel>
	<trace> Trace:List => Trace ListItem("indent-inc") </trace>
	[internal]

rule [indent-dec]:
	<k> indentDec => . ... </k>
	<varDumpLevel> Depth:Int => Depth -Int 1 </varDumpLevel>
	<trace> Trace:List => Trace ListItem("indent-dec") </trace>
	[internal]

syntax K ::= "var_dump_indent" "(" Int ")"

rule [vardump-indent-none]:    
	<k> var_dump_indent(0) => . ... </k>
	<trace> Trace:List => Trace ListItem("vardump-indent-none") </trace>
	[internal]

rule [vardump-indent-some]:    
	<k> var_dump_indent(N:Int) => print("  ") ~> var_dump_indent(N -Int 1) ... </k>
	<trace> Trace:List => Trace ListItem("vardump-indent-some") </trace>
	[internal]
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Define} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "define" "(" K "," K ")" [strict]

rule [define-LHS2LangValue]:	
	<k> define((R:Ref => convertToLanguageValue(R)), _) ... </k>
	<trace> Trace:List => Trace ListItem("define-LHS2LangValue") </trace>
	[intermediate]

rule [define-RHS2LangValue]:	
	<k> define(_, (R:Ref => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("define-RHS2LangValue") </trace>
	[intermediate]

rule [define-fresh]:	
	<k> define(ConstName:String, V:ScalarValue) => true ... </k>
	<constants> Constants:Map => Constants[V/ConstName] </constants> 
	<trace> Trace:List => Trace ListItem("define-fresh") </trace>
	when notBool (ConstName in keys(Constants))
	[internal]
	
rule [define-already]:	
	<k> define(ConstName:String, V:ScalarValue) => false ... </k>
	<constants> Constants:Map </constants> 
	<trace> Trace:List => Trace ListItem("define-already") </trace>
	when (ConstName in keys(Constants))
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{PrintR} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "print_r" "(" K ")" [strict]


// add cases for printing scalar values

rule [printr-arg2Loc]:    
	<k> print_r (R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("printr-arg2Loc") </trace>
	[intermediate]

/* var_dumping an array  */
rule [printr-array]:    
	<k> print_r(L':Loc) =>
			'Echo( 'ListWrap( "Array\n" )) ~> 
            print_r_indent(Depth *Int 2) ~>
            'Echo( 'ListWrap( "(\n" ) ) ~>
            indentInc ~> 
            print_r_content(Elems) ~> 
        	print_r_indent(Depth *Int 2) ~>
        	'Echo( 'ListWrap( ")\n" )  )  ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(Array(_,Elems:List),_,_,_) ... </heap>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("printr-array") </trace>
	[internal]

/* var_dumping an object  */
rule [printr-object]:        
	<k> print_r(L':Loc) =>
			'Echo('ListWrap(Id2String(ClassName))) ~>
			'Echo( 'ListWrap( " Object\n" )) ~> 
            print_r_indent(Depth *Int 2) ~>
            'Echo( 'ListWrap( "(\n" ) ) ~>
            indentInc ~> 
            print_r_content(Elems) ~> 
        	print_r_indent(Depth *Int 2) ~>
        	'Echo( 'ListWrap( ")\n" )) ... </k>
	<thematrix> 
	... 
		L'  |-> L 
		L1' |-> L1
	... 
	</thematrix>	
	<heap>
	...
		L  |-> zval(OID(L1',ClassName,_),_,_,_)
		L1 |-> zval(Array(_,Elems:List),_,_,_)
	...
	</heap>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("printr-object") </trace>
	[internal]

rule [printr-string]:        
	<k> print_r(L':Loc) => 
            'Echo( 'ListWrap(S) ) ~>
            'Echo( 'ListWrap("\n") ) ...
	</k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(S:AString,_,_,IsRef:Bool) ... </heap>
	<trace> Trace:List => Trace ListItem("printr-string") </trace>
	[internal]

rule [printr-other]:        
	<k> print_r(L':Loc)  => 
            'Echo( 'ListWrap(V) ) ~> 
            'Echo( 'ListWrap("\n") ) ...
        </k>
	<thematrix> ... L' |-> L ... </thematrix>	
        <heap> ... L |-> zval(V:Value,_,_,IsRef:Bool) ... </heap>
	<trace> Trace:List => Trace ListItem("printr-other") </trace>
	when (notBool (isArrayType(V))) andBool (notBool (isStringType(V))) andBool (notBool (isObjectType(V)))
	[internal]

/* Here we define an operation that recursively performs var_dump on compound 
   values (i.e. arrays and objects).  */

syntax K ::= "print_r_content" "(" List ")"

/* recursively var_dumps array elements  */
rule [printr-content-1]:        
	<k> print_r_content(ListItem([K:Key,public,L:Loc]) Elems:List) =>
                var_dump_indent(((Depth *Int 2) -Int 1)) ~>
                print("[") ~> 
				*Cond(K isStringKey, print("\""), .) ~> 
                print(K) ~> 
                *Cond(K isStringKey, print("\""), .) ~> 
				print("]") ~> 
                print ("=> ") ~>
                print_r(L) ~>
                print_r_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("printr-content-1") </trace>
	[internal]

/* var_dumps protected object property */
rule [printr-content-2]:        
	<k> print_r_content(ListItem([K:String,protected,L:Loc]) Elems:List) =>
                print_r_indent(((Depth *Int 2) -Int 1)) ~>
                print("[\"") ~> 
                print(K) ~> 
                print("\":protected]") ~> 
                print ("=> ") ~>
                print_r(L) ~>
                print_r_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("printr-content-2") </trace>
	[internal]

/* var_dumps private object property */
rule [printr-content-3]:            
	<k> print_r_content(ListItem([K:String,private(ClassName:Id),L:Loc]) Elems:List) =>
                print_r_indent(((Depth *Int 2) -Int 1)) ~>
                print("[\"") ~> 
                print(K) ~> 
                print("\":\"") ~> 
                print(Id2String(ClassName)) ~>
                print("\":private]") ~> 
                print ("=> ") ~>
                print_r(L) ~>
                print_r_content(Elems) ... 
	</k>
	<varDumpLevel> Depth:Int </varDumpLevel>
	<trace> Trace:List => Trace ListItem("printr-content-3") </trace>
	[internal]


rule [printr-content-nil]:         	
	<k> print_r_content(.List) => indentDec ... </k>
	<trace> Trace:List => Trace ListItem("printr-content-nil") </trace>
	[internal]

syntax K ::= "print_r_indent" "(" Int ")"

rule [printr-indent-none]:    
	<k> print_r_indent(0) => . ... </k>
	<trace> Trace:List => Trace ListItem("printr-indent-none") </trace>
	[internal]
	
rule [printr-indent-some]:            
	<k> print_r_indent(N:Int) => print("    ") ~> print_r_indent(N -Int 1) ... </k>
	<trace> Trace:List => Trace ListItem("printr-indent-some") </trace>
	[internal]

syntax K ::= "print_r_array" "(" Loc "," Int ")"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{GetType} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "gettype" "(" K ")" [strict]

rule [gettype-arg2LangValue]:    
	<k> gettype(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("gettype-arg2LangValue") </trace>
	[intermediate]

rule [gettype-int]:
	<k> gettype(I:Int) => "int" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-int") </trace>
	[internal]

rule [gettype-float]:
	<k> gettype(F:Float) => "double" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-float") </trace>
	[internal]

rule [gettype-string]:    
	<k> gettype(S:String) => "string" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-string") </trace>
	[internal]

rule [gettype-bol]:    
	<k> gettype(B:Bool) => "boolean" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-bol") </trace>
	[internal]

rule [gettype-array]:    
	<k> gettype(A:Array) => "array" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-array") </trace>
	[internal]

rule [gettype-obj]:    
	<k> gettype(O:Object) => "object" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-obj") </trace>
	[internal]

rule [gettype-null]:    
	<k> gettype(NULL) => "NULL" ... </k>
	<trace> Trace:List => Trace ListItem("gettype-null") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Defined} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "defined" "(" K ")" [strict]

rule [defined-arg2LangValue]:    
	<k> defined(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("defined-arg2LangValue") </trace>
	[intermediate]

rule [defined-true]: 	
	<k> defined(Const:String) => true ... </k>
	<constants> ... Const |-> _ ... </constants>
	<trace> Trace:List => Trace ListItem("defined-true") </trace>
	[internal]
		
rule [defined-false]: 	
	<k> defined(Const:String) => false ... </k>
	<constants> Consts:Map </constants>
	<trace> Trace:List => Trace ListItem("defined-false") </trace>
	when notBool (Const in keys(Consts))
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsFloat} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "is_float" "(" K ")" 	[strict]

rule [is-float]:
	<k> is_float(V) => is_type(V, "float") ... </k>
	<trace> Trace:List => Trace ListItem("is-float") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsString} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "is_string" "(" K ")" 	[strict]

rule [is-string]:
	<k> is_string(V) => is_type(V, "string") ... </k>
	<trace> Trace:List => Trace ListItem("is-string") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsArray} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "is_array" "(" K ")" 	[strict]
	
rule [is-array]:
	<k> is_array(V) => is_type(V, "array") ... </k>
	<trace> Trace:List => Trace ListItem("is-array") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsScalar} */
// ---------------------------------------------------------------------------------------------
	
syntax K ::= "is_scalar" "(" K ")" 	[strict]
	
rule [is-scalar]:
	<k> is_scalar(V) => is_type(V, "scalar") ... </k>
	<trace> Trace:List => Trace ListItem("is-scalar") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsNumeric} */
// ---------------------------------------------------------------------------------------------
	
syntax K ::= "is_numeric" "(" K ")" 	[strict]
	
rule [is-numeric]:
	<k> is_numeric(V) => is_type(V, "numeric") ... </k>
	<trace> Trace:List => Trace ListItem("is-numeric") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Is type} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "is_type" "(" K "," String ")" 	[strict]

rule [is-type-arg2LangValue]:    
	<k> is_type(R:ConvertibleToLanguageValue => convertToLanguageValue(R),_) ... </k>
	<trace> Trace:List => Trace ListItem("is-type-arg2LangValue") </trace>
	[intermediate]
	
rule [is-type-float]:
	<k> is_type(V:LanguageValue, "float") => isFloatType(V) ... </k>
	<trace> Trace:List => Trace ListItem("is-type-float") </trace>
	[internal]
	
rule [is-type-string]:
	<k> is_type(V:LanguageValue, "string") => isStringType(V) ... </k>
	<trace> Trace:List => Trace ListItem("is-type-string") </trace>
	[internal]
	
rule [is-type-array]:
	<k> is_type(V:LanguageValue, "array") => isArrayType(V) ... </k>
	<trace> Trace:List => Trace ListItem("is-type-array") </trace>
	[internal]
	
rule [is-type-scalar]:
	<k> is_type(V:LanguageValue, "scalar") => V isScalar ... </k>
	<trace> Trace:List => Trace ListItem("is-type-scalar") </trace>
	[internal]

rule [is-type-numeric-numericString2Number]:
	<k> is_type(S:AString, "numeric") => isNumericString(S) ... </k>
	<trace> Trace:List => Trace ListItem("is-type-numeric-numericString2Number") </trace>
	[internal]


rule [is-type-numeric]:
	<k> is_type(V:LanguageValue, "numeric") => V isNumeric ... </k>
	<trace> Trace:List => Trace ListItem("is-type-numeric") </trace>
	when notBool isStringType(V)
	[internal]

/* TODO: remove (has been moved to domains) 	
syntax K ::= "user_input"
	
rule <k> user_input => V ...</k>
	<in> ListItem(V:K) => . ...</in>
*/

syntax K ::= "label" "(" K ")" [strict]

rule label(S:ConvertibleToLanguageValue => convertToLanguageValue(S))

rule <k> label(S:AString) => NULL ... </k>
	 <label> _ => S </label>

// ---------------------------------------------------------------------------------------------
/*@ \subsection{substr} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "substr" "(" K "," K "," K ")" [seqstrict]

rule [substr-arg2LangValue-1]:
	<k> substr((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),_,_) ... </k>
	<trace> Trace:List => Trace ListItem("substr-arg2LangValue-1") </trace>
	[internal]

rule [substr-arg2LangValue-2]:
	<k> substr(_,(R:ConvertibleToLanguageValue => convertToLanguageValue(R)),_) ... </k>
	<trace> Trace:List => Trace ListItem("substr-arg2LangValue-2") </trace>
	[internal]
	
rule [substr-arg2LangValue-3]:
	<k> substr(_,_,(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("substr-arg2LangValue-3") </trace>
	[internal]

rule [substr]:
	<k> substr(S:String, Start:Int, Len:Int) => substrString(S,Start,Len) ... </k>
	<trace> Trace:List => Trace ListItem("substr") </trace>
	[internal]

endmodule
