require "objects.k"
require "arrays.k"

module MEMORY
	imports OBJECTS
	imports ARRAYS
	
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Memory representation and low-level operations} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Values} */
// ---------------------------------------------------------------------------------------------

// Language values are partitioned into Scalar, compound and special values. 
syntax LanguageValue ::= PlainLanguageValue | LiteralValue

syntax PlainLanguageValue ::= ScalarValue 
			    | CompoundValue 
			    | SpecialValue
			    | "Top" | "Bot"

syntax ScalarValue ::= AInt | AFloat | ABool | AString     
syntax CompoundValue ::= Object | Array
syntax Null ::= "NULL"
syntax SpecialValue ::= Null

// We represent objects as triples consisting of the name of the class, the instance no.
// (which is completely implementation-dependent) and a Table.
syntax Object ::= "OID" "(" Loc "," Id "," Int ")"

// An array consists of a list of TableItems and an optional current item.
syntax Array ::= "Array" "(" OptionArrayCrntElem "," List ")"

// Array items consists of a key, an optional visibility and a location
syntax ArrayItem ::= "[" Key "," ArrayItemVisibility "," Loc "]"

// Array current element
syntax ArrayCrntElem ::= "[" Key "," ArrayItemVisibility "]"

// Visibility can be 'public', 'protected' or 'private'. For 'private' we also store
// the name of the class defining the property.
syntax ArrayItemVisibility ::= "public" | "protected" | "private" "(" Id ")"

// Keys can be Int or String. We use NULL to designate cases when no key is provided when 
// accessing an array (e.g. $x[] = 0). In such cases a default integer key will be provided.
syntax Key ::= Int | String | SpecialValue
rule isKResult(K:Key) => true

// For specification purpose language values are not enough, so we need to add other
// kind of values, which will be hidden to the programmer but needed for the semantics.
syntax SemanticValue ::= Loc | Ref

// As standard, locations are mapped into natural numbers.
syntax Loc ::= "locNull"

// References, which will be used extensively in the semantics, can be considered as pairs
// consisting of a location which contains an array (note that the variable environments are
// treated as arrays here) and a key. Keys can be integer or string. 
// Also, for semantic purposes, we allow the NULL key. 

syntax RefType  ::= "arr" | "obj" | "nul"
syntax Ref ::= BasicRef | LRef | "refNull"
syntax BasicRef ::= "ref" "(" Loc "," Key ")" [strict(1), klabel('ref)] 
syntax LRef 	::= "lref" "(" Ref "," Key "," RefType ")" [strict(1), klabel('lref)]  

// Literal values are used in order to delay the evaluation of literal arrays and 
// object creation (new construct). The parameter has type K (i.e. the most general 
// type, and cannot specialized anymore.
syntax LiteralValue ::= "Literal" "(" K ")" [klabel('lit)]


// Finally, we define Values as the union of Semantic and Language values, and we set
// KResult = Values
syntax Value ::= LanguageValue | SemanticValue 
syntax KResult ::= Value  


/* For convenience, we define a set of option types */

syntax None ::= "none"
syntax OptionId ::= Id | None
syntax OptionLoc ::= Loc | None
syntax OptionInt ::= Int | None
syntax OptionString ::= String | None
syntax OptionArrayItem ::= ArrayItem | None
syntax OptionArrayCrntElem ::= ArrayCrntElem | None


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Lub} */

syntax PlainLanguageValue ::= "lub" "(" PlainLanguageValue "," PlainLanguageValue ")" [function]

rule lub(V1:AInt,V2:AInt) => lub_AInt(V1,V2)
//rule lub(V1:AFloat,V2:AFloat) => lub_AFloat(V1,V2) TODO
//rule lub(V1:ABool,V2:ABool) => lub_ABool(V1,V2) TODO
rule lub(V1:AString,V2:AString) => lub_AString(V1,V2)

rule lub(Bot,X) => X
rule lub(X,Bot) => X

// NOTE: doesn't wotk for booleans! 
 
rule lub(V1,V2) => Top
	when (V1 =/=K Bot andBool V2 =/=K Bot) andBool
		(getKLabel(V1) =/=KLabel getKLabel(V2))









/*
syntax Bool "hasDifferentType" "(" PlainLanguageValue "," PlainLanguageValue ")" [predicate]

rule hasDifferentType(V1:AInt,V2:AInt) =>  
rule hasDifferentType(V1:AInt,V2:AFloat) =>  
rule hasDifferentType(V1:AInt,V2:ABool) =>  
rule hasDifferentType(V1:AInt,V2:AString) =>  
*/


// ---------------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Types} 
		In the official PHP implementation, the (runtime) type of values is stored in memory. 
		We define here the different types. */
// ---------------------------------------------------------------------------------------------

syntax Type ::= "int"   | "integer"			
        	  | "bool"  | "boolean"
        	  | "float" | "double" | "real"
        	  | "string"
 	          | "array"
        	  | "object"
        	  | "unset"
		  | "unknown" // internal!!!

/*@ For semantic purposes, we actually need types to be considered as values. For clarity we 
	choose not to directly add types to the set of values, but instead we just add the following 
	line, telling the \K tool that a type is to be considered as a KResult, i.e something which 
	cannot reduce anymore. */

rule isKResult(T:Type) => true

/*@ We define here some helper predicates that will make the semantic rules more concise. */

// TODO: can use builtin (isArray(V) == true)
syntax Bool ::=  "isArrayType" "(" Value ")"			[function]
rule    isArrayType(V:Array) => true                  
rule    isArrayType(V:ScalarValue) => false            
rule    isArrayType(V:Object) => false                 
rule    isArrayType(V:SpecialValue) => false           

rule    isArrayType(Top) => false      
rule    isArrayType(Bot) => false      

syntax Bool ::=  "isFloatType" "(" Value ")"			[function]

rule    isFloatType(X) => true
        when (isAFloat(X) ==K true) 

rule    isFloatType(X) => false
        when notBool (isAFloat(X) ==K true) 


syntax Bool ::=  "isIntType" "(" Value ")" 				[function]

rule    isIntType(X) => true
        when (isAInt(X) ==K true) 

rule    isIntType(X) => false
        when notBool (isAInt(X) ==K true) 


syntax Bool ::=  "isBoolType" "(" Value ")" 				[function]

rule    isBoolType(X) => true
        when (isABool(X) ==K true) 

rule    isBoolType(X) => false
        when notBool (isABool(X) ==K true) 

syntax Bool ::=  "isStringType" "(" Value ")"	[function]

rule    isStringType(X) => true
        when (isAString(X) ==K true) 

rule    isStringType(X) => false
        when notBool (isAString(X) ==K true) 

syntax Bool ::=  "isObjectType" "(" Value ")"	[function]

rule    isObjectType(X) => true
        when (isObject(X) ==K true) 

rule    isObjectType(X) => false
        when notBool (isObject(X) ==K true) 


syntax Type ::= "typeOf" "(" Value ")"					[function]

rule    typeOf(V:ABool) => bool
rule    typeOf(V:AInt) => int
rule    typeOf(V:AFloat) => float
rule    typeOf(V:AString) => string
rule    typeOf(V:Object) => object
rule    typeOf(V:Array) => array
rule    typeOf(NULL) => unset

rule	typeOf(Top) => unknown // NOTE: internal!


syntax Bool ::= Value "isNumeric" [function]
rule V isNumeric => isIntType(V) orBool isFloatType(V)

syntax Bool ::= Value "isCompoundValue" [function]
rule V isCompoundValue => isArrayType(V) orBool isObjectType(V)

syntax Bool ::= Value "isScalar" [function]
rule V isScalar => isStringType(V) orBool isIntType(V) orBool isFloatType(V) orBool isBoolType(V)

syntax Bool ::= "hasSameType" "(" Value "," Value ")" [function]
rule hasSameType(V1, V2) => typeOf(V1) ==K typeOf(V2) 

syntax Bool ::= "isLiteral" "(" ConvertibleToLoc ")" [function]

rule isLiteral(V) => true	
	when (getKLabel(V) ==KLabel 'lit)

rule isLiteral(V) => false	
	when (getKLabel(V) =/=KLabel 'lit)

syntax Bool ::= "locHoldsArray" "(" Map "," Loc ")" [function]
rule locHoldsArray(Mem:Map(L |-> zval(V:Value,_,_,_)), L) => isArrayType(V)

syntax Bool ::= "locHoldsObject" "(" Map "," Loc ")" [function]
rule locHoldsObject(Mem:Map(L |-> zval(V:Value,_,_,_)), L) => isObjectType(V)

syntax Bool ::= "locsHoldSameCompound" "(" Map "," Loc "," Loc ")" [function]
rule locsHoldSameCompound(M, V1, V2) => 
	(locHoldsArray(M,V1) andBool (locHoldsArray(M,V2))) orBool 
	(locHoldsObject(M,V1) andBool (locHoldsObject(M,V2)))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Zvalues} 
		As in the official PHP implementation, values are stored in memory alongside other 
		information, such as the type, the 'refCount' flag and the 'isRef' flag, in a structure
		which is called ZValue, which we define as follows:	 */
// ---------------------------------------------------------------------------------------------

syntax Zval ::= "zval" "(" Value "," Type "," Int "," Bool ")"
	                               
/*@ We also define a number of low-level rules for reading and writing a given field of a 
	ZValue, as well as for creating or destroying them. Those operations will be used as 
	building blocks in the rest of the semantics. */

syntax ZvalField ::= "@Value" | "@Type" | "@RefCount" | "@IsRef"

syntax K ::= "zvalRead" "(" Loc "," ZvalField ")" [strict(1)]

rule [zval-read-value]:
	<k> zvalRead(L,@Value) => V ... </k>
 	<heap> ... L |-> zval(V,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-read-value") </trace>
	[internal]

rule [zval-read-type]:
	<k> zvalRead(L,@Type) => T ... </k>
	<heap>... L |-> zval(_,T,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-read-type") </trace>
	[internal]

rule [zval-read-refCount]:    
	<k> zvalRead(L:Loc, @RefCount) => RC ... </k>
	<heap>... L |-> zval(_, _, RC:Int, _) ...</heap>
	<trace> Trace:List => Trace ListItem("zval-read-refCount") </trace>
	[internal]

rule [zval-read-isRef]:    
	<k> zvalRead(L:Loc, @IsRef) => IR ... </k>
	<heap>... L |-> zval(_, _, _, IR:Bool) ...</heap>
	<trace> Trace:List => Trace ListItem("zval-read-isRef") </trace>
	[internal]

syntax LanguageValueOrType ::= LanguageValue | Type
                             | Int | Bool // NOTE: I added this stuff!!

syntax K ::= "zvalWrite" "(" Loc "," ZvalField "," LanguageValueOrType ")" [strict(1,3)]
    
rule [zval-write-value]:
	<k> zvalWrite(L,@Value,V:LanguageValue) => . ... </k>	
	<heap> ... L |-> zval(_=> V,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-write-value") </trace>
	[internal, mem]

rule [zval-write-type]:    
	<k> zvalWrite(L,@Type,T:Type) => . ... </k>
	<heap> ... L |-> zval(_,_=> T,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-write-type") </trace>
	[internal, mem]

rule [zval-write-refCount]:    
	<k> zvalWrite(L,@RefCount,N:Int) => .K ... </k>
	<heap> ... L |-> zval(_,_,_ => N,_) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-write-refCount") </trace>
	[internal, mem]

rule [zval-write-isRef]:    
	<k> zvalWrite(L:Loc, @IsRef, B:Bool) => .K ... </k>
	<heap> ... L |-> zval(_,_,_,_ => B) ... </heap>
	<trace> Trace:List => Trace ListItem("zval-write-isRef") </trace>
	[internal, mem]

syntax K ::= "zvalCreate" "(" Loc "," Value "," Type "," Int "," Bool ")" 
  
rule [zval-create]:    
	<k> zvalCreate(L:Loc, V:KResult, T:Type, R:Int, IR:Bool) => .K ... </k>
	<heap> Rho:Map => Rho[zval(V, T, R, IR) / L] </heap>
	<trace> Trace:List => Trace ListItem("zval-create") </trace>
	[internal, mem]
    
syntax K ::= "zvalDestroy" "(" Loc ")"    

rule [zval-destroy]:    
	<k> zvalDestroy(L:Loc) => .K ... </k>
	<heap> ... (L |-> _) => . ... </heap>
	<trace> Trace:List => Trace ListItem("zval-destroy") </trace>
	[internal, mem]

syntax K ::= "incRefCount" "(" Loc ")"

rule [inc-refCount-1]:
	<k> incRefCount(L:Loc) => zvalWrite(L, @RefCount, Refs +Int 1) ... </k>
	<heap> ... L |-> zval(_,_,Refs:Int,false) ... </heap>
	<trace> Trace:List => Trace ListItem("inc-refCount-1") </trace>
	when (Refs ==Int 0)
	[internal, mem]

rule [inc-refCount-2]:
	<k> incRefCount(L:Loc) => zvalWrite(L, @RefCount, Refs +Int 1) ... </k>
	<heap> ... L |-> zval(_,_,Refs:Int,false => true) ... </heap>
	<trace> Trace:List => Trace ListItem("inc-refCount-2") </trace>
	when (Refs ==Int 1)
	[internal, mem]		
		
rule [inc-refCount-3]:
	<k> incRefCount(L:Loc) => zvalWrite(L, @RefCount, Refs +Int 1) ... </k>
	<heap> ... L |-> zval(_,_,Refs:Int,true) ... </heap>
	<trace> Trace:List => Trace ListItem("inc-refCount-3") </trace>
	when (Refs >Int 1)
	[internal, mem]

syntax K ::= "decRefCount" "(" Loc ")"            
			
rule [dec-refCount-1]:
	<k> decRefCount(L:Loc) => zvalWrite(L,@RefCount,Refs -Int 1) ... </k>
	<heap> ... L |-> zval(_,_,Refs:Int,true) ... </heap>
	<trace> Trace:List => Trace ListItem("dec-refCount-1") </trace>
	when (Refs >Int 2)
	[internal, mem]

rule [dec-refCount-2]:
	<k> decRefCount(L:Loc) => zvalWrite(L,@RefCount,Refs -Int 1) ... </k>
	<heap> ... L |-> zval(_,_,Refs,true => false) ... </heap>
	<trace> Trace:List => Trace ListItem("dec-refCount-2") </trace>
	when (Refs ==Int 2)
	[internal, mem]
			
rule [dec-refCount-3]:
	<k> decRefCount(L:Loc) => 
		zvalWrite(L,@RefCount,Refs -Int 1) ~>
		*Cond(V isCompoundValue, decRefCountCompound(L),.) ... </k>
	<heap> ... L |-> zval(V,_,Refs,false) ... </heap>
	<trace> Trace:List => Trace ListItem("dec-refCount-3") </trace>
	when (Refs <=Int 1)
	[internal, mem]

syntax K ::= "decRefCountCompound" "(" Loc ")"

rule [dec-refCount-compound-array]:
	<k> decRefCountCompound(L) => decRefCountArrayElems(L,Elems)... </k>
	<heap> ... L |-> zval(Array(_,Elems),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("dec-refCount-compound-array") </trace>
	[internal]

rule [dec-refCount-compound-obj]:    
	<k> decRefCountCompound(L:Loc => L1) ... </k>
	<heap> 
	... 
		L  |-> zval(OID(L1,_,_),_,_,_) 
		L1 |-> zval(Array(_,Elems),_,_,_) 
	... 
	</heap>
	<trace> Trace:List => Trace ListItem("dec-refCount-compound-obj") </trace>
	[structural]

syntax K ::= "decRefCountArrayElems" "(" Loc "," List ")"

rule [dec-refCount-array-elems-cons]:
	<k> decRefCountArrayElems(L:Loc, Elems:List ListItem([X,_,L1])) => decRefCount(L1) ~> decRefCountArrayElems(L, Elems) ... </k>
	<trace> Trace:List => Trace ListItem("dec-refCount-array-elems-cons") </trace>
	[internal]

rule [dec-refCount-array-elems-nil]:
	<k> decRefCountArrayElems(L:Loc,.List) => .K ... </k>
	<trace> Trace:List => Trace ListItem("dec-refCount-array-elems-nil") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Operations on Arrays} */
// ---------------------------------------------------------------------------------------------

/* empty array, macro */

syntax Array ::= "emptyArray" [function]
rule	emptyArray => Array(none,.List)

/* Creating an empty array at a given location */

syntax K ::= "ArrayCreateEmpty" "(" Loc ")" 

rule [array-create-empty]: 	
	<k> ArrayCreateEmpty(L:Loc) => write(emptyArray,L) ... </k>
	<trace> Trace:List => Trace ListItem("array-create-empty") </trace>
	[structural]

/* Inserting a new item into an array. Note that the entry consists of a location, 
   and it is expected to be already allocated. Once inserted, its reference counter
   is incremented by one. */

syntax K ::= "ArrayCreateElem" "(" Loc "," Key "," ArrayItemVisibility "," Loc ")" [strict(4)]

rule [array-create-elem]:
	<k> ArrayCreateElem(L, K, V, L1:Loc) => incRefCount(L1) ... </k> 
	<heap> ... L |-> zval(Array(Crnt,ArrayElems:List (. => ListItem([K, V, L1]))),_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("array-create-elem") </trace>
	when Crnt =/=K none
	[internal]
	
rule [array-create-elem-update-crnt]:
	<k> ArrayCreateElem(L, K, V, L1:Loc) => incRefCount(L1) ... </k> 
	<heap> ... L |-> zval(Array(none => [K, V], .(List => ListItem([K, V, L1]))),_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("array-create-elem-update-crnt") </trace>
	[internal]
	
/* Updates an element, or creates it if don't exists  */

syntax K ::= "ArrayUpdateElem" "(" Loc "," Key "," Loc ")"

rule //[array-update-elem-update]:
	<k> ArrayUpdateElem(L1:Loc, X:Key, L2:Loc) => decRefCount(L3) ~> incRefCount(L2) ... </k>
	<heap>... L1 |-> zval(Array(_,_ ListItem([X,_,L3 => L2]) _),_,_,_)  ...</heap>    
	<trace> Trace:List => Trace ListItem("array-update-elem-update") </trace>
	[internal]

rule [array-update-elem-create]:    
	<k> ArrayUpdateElem(L1:Loc, X:Key, L2:Loc) => ArrayCreateElem(L1, X, public, L2) ... </k>
	<heap>... L1 |-> zval(Array(_,Elems),_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("array-update-elem-create") </trace>
	when notBool (Elems hasProperty X)
	[internal]
	
/* Gets the array element at a specific numeric index (internal use only) */

syntax OptionArrayCrntElem ::= "ArrayGetElemAtIndex" "(" Int "," List ")" [function]

rule ArrayGetElemAtIndex(-1, _) => none
rule ArrayGetElemAtIndex(0, ListItem([X,V,_]) L:List) => [X,V]
rule ArrayGetElemAtIndex(N, ListItem(_) L:List) => ArrayGetElemAtIndex(N -Int 1, L)
	when N >Int 0

/* Returns the numerical index of an element (internal use only) */

syntax Int ::= "ArrayIndexOf" "(" OptionArrayCrntElem "," List ")" [function]
rule ArrayIndexOf(none,_) => -1
rule ArrayIndexOf([X,V],ListItem([X,V,_]) _ ) => 0
rule ArrayIndexOf([X,V],ListItem([X1,V1]) L:List) => 1 +Int ArrayIndexOf([X,V],L) 
	when (X =/=K X1) orBool (V =/=K V1)


/* Update of the current pointer */

syntax K ::= "ArrayInitCrnt" "(" Loc "," Int ")"

rule [array-init-reset]:
	<k> ArrayInitCrnt(L, 0) => 'Expr(reset(L)) ... </k>	
	<trace> Trace:List => Trace ListItem("array-init-reset") </trace>
	[internal]	
	
rule [array-init-n]:
	<k> ArrayInitCrnt(L, N) => ArrayWriteCrnt(L,ArrayGetElemAtIndex(N, Elems)) ... </k>	
	<heap> 
		... L |-> zval(Array(_,Elems),_,_,_)  ...
	</heap>
	<trace> Trace:List => Trace ListItem("array-init-n") </trace>
	[internal]	

syntax K ::= "ArrayWriteCrnt" "(" Loc "," OptionArrayCrntElem ")"

rule [array-write-current-some]:
	<k> ArrayWriteCrnt(L,C) => . ... </k>
	<heap> ... L |-> zval(Array(_ => C,_),_,_,_)  ... </heap>
	<trace> Trace:List => Trace ListItem("array-write-current-some") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Auxiliary List and arithmetic ops} */
// ---------------------------------------------------------------------------------------------

// "raw" reading operations (TODO move) 

syntax  Zval ::= "heap_read" "(" Map "," Loc ")" [function]

rule	heap_read(H,L) => heap_read1(H,L)
	when (L in keys(H))

/*
rule	heap_read(H,L) => zval(Array(none,.List),array,1,false)	
	when notBool(L in keys(H))
*/

syntax  Zval ::= "heap_read1" "(" Map "," Loc ")" [function]

rule    heap_read1(_:Map (L:Loc |-> V:Zval) _:Map,L:Loc) => V 




syntax  ArrayItem ::= "array_read" "(" List "," Key ")" [function]

rule array_read((ListItem([K,V,L]) A:List),K) => [K,V,L]
rule array_read((ListItem([K',_,_]) A:List),K) => array_read(A,K)
    when K =/=K K'

syntax  Loc ::= "array_read_v" "(" List "," Key ")" [function]

rule    array_read_v(A,K) => arrayItem2Loc(array_read(A,K))

syntax  List ::= "arrayRemove" "(" List "," Key ")" [function]

rule    arrayRemove(ListItem([K,V,L]) A,K1) => ListItem([K,V,L]) arrayRemove(A,K)
        when (K =/=K K1)

rule    arrayRemove(ListItem([K,V,L]) A,K) => arrayRemove(A,K)

rule    arrayRemove(.List,_) => .List

syntax  Loc ::= "arrayItem2Loc" "(" ArrayItem ")" [function]

rule    arrayItem2Loc([_,_,L]) => L

// Membership operations

syntax Bool ::= List "hasProperty" K [function]
rule ListItem([K2:K,_,_]) L2:List hasProperty K1:K => (K1 ==K K2) orBool (L2 hasProperty K1)
rule .List hasProperty _ => false

syntax Bool ::= List "hasPrivateProperty" K "for" K [function]
rule ListItem([P:K,C:K,_]) L2:List hasPrivateProperty Prop:K for Class:K 
	=> ((P ==K Prop) andBool (C ==K private(Class))) orBool (L2 hasPrivateProperty Prop for Class)
rule .List hasPrivateProperty _ for _ => false

syntax OptionArrayCrntElem ::= "head" "(" List ")" [function]
rule head(ListItem([X,V,_]) L:List) => [X,V]
rule head(.List) => none

/* Returns the lenght of a list  */

syntax Int ::= "len" "(" List ")" [function]
rule len(.List) => 0
rule len(ListItem(_) Tail) => 1 +Int len(Tail)

/* Returns the max int key in a list  */

syntax Int ::= "biggestIntKey" "(" List ")" [function]
rule biggestIntKey(.List) => -1
rule biggestIntKey(ListItem([Key:String,_,_]) Tail) => biggestIntKey(Tail)
rule biggestIntKey(ListItem([Key:Int,_,_]) Tail) => max(Key, biggestIntKey(Tail))

/* Return the biggest of two integers  */

syntax Int ::= "max" "(" Int "," Int ")" [function]
rule max(I1, I2) => I1	when I1 >=Int I2
rule max(I1, I2) => I2	when I1 <Int I2

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Macros} 
		We define here a nummber of useful operations which allows us to manipulate the heap 
		without having to update all the low level details manually (e.g. the type of a value, 
		the reference counter etc.). 
		We will mostly use this operations in the semantics, so that the low-level actions 
		are all defined here. This will make the semantic rules easier to write and also easy
		to fix. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "read" "(" K ")" [strict]

rule [read-loc]:
	<k> read(L:Loc) => zvalRead(L, @Value) ... </k>       
	<trace> Trace:List => Trace ListItem("read-loc") </trace>
	when (L =/=K locNull)
	[internal]

rule [read-locNull]:    
	<k> read(locNull) => NULL ... </k>
	<trace> Trace:List => Trace ListItem("read-locNull") </trace>
	[internal]

rule [read-string]:
	<k> read(S:String) => S ... </k>
	<trace> Trace:List => Trace ListItem("read-string") </trace>
	[internal]

syntax K ::= "write" "(" Value "," Loc ")" [strict] 

rule [write-loc-exists]:
	<k> write(V:KResult, L:Loc) => 
		zvalWrite(L, @Value, V) ~> 
		zvalWrite(L, @Type, typeOf(V))   ...  </k>
	<heap> ... L |-> _ ... </heap>                                                                                                 
	<trace> Trace:List => Trace ListItem("write-loc-exists") </trace>
	[internal]

rule [write-loc-undef]:    
	<k> write(V:KResult, L:Loc) => zvalCreate(L, V, typeOf(V), 0, false) ...  </k>
	<heap> Mem:Map </heap>
	<trace> Trace:List => Trace ListItem("write-loc-undef") </trace>
	when (notBool (L in keys(Mem))) andBool (L =/=K locNull)                                                                                                         	
	[internal]

// This is needed for cases like $c[$c=1] = 0; (when $c is not initialised)
rule [write-locNull]:    
	<k> write(_, locNull) => . ...  </k>
	<trace> Trace:List => Trace ListItem("write-locNull") </trace>
	[internal]

syntax K ::= "allocValue" "(" Value ")" [strict]

rule [alloc-value]: 	
	<k> allocValue(V:Value) => copyValueToLoc(V,L) ~> L ... </k>
	<trace> Trace:List => Trace ListItem("alloc-value") </trace>
	when fresh(L:Loc)
	[internal]

syntax K ::= "copyValueToLoc" "(" Value "," Loc ")" [strict]

rule [copy-value-to-loc-scalar]:
	<k> copyValueToLoc(V:LanguageValue, L:Loc) => 
	write(V, L) ... </k>
	<trace> Trace:List => Trace ListItem("copy-value-to-loc-scalar") </trace>
	when notBool (isArrayType(V) orBool isObjectType(V))
	[internal]

rule [copy-value-to-loc-array]:    
	<k> copyValueToLoc(Array(Crnt,Elems), L:Loc) => 
	ArrayCreateEmpty(L) ~> 
	copyArrayMembers(L,Elems) ~>
	ArrayInitCrnt(L, ArrayIndexOf(Crnt,Elems)) 
	... </k>
	<trace> Trace:List => Trace ListItem("copy-value-to-loc-array") </trace>
	[internal]
    
rule [copy-value-to-loc-obj]:    
	<k> copyValueToLoc(OID(L1,ClassName,InstanceN), L:Loc) => 
	incRefCount(L1) ~> write(OID(L1,ClassName,InstanceN), L)
	... </k>
	<trace> Trace:List => Trace ListItem("copy-value-to-loc-obj") </trace>
	[internal]

rule [copy-value-to-loc-array-literal]: 	
	<k> copyValueToLoc(Literal('Array(Elems:K)),L1) => makeArrayLiteral(L1, Elems) ... </k>
	<trace> Trace:List => Trace ListItem("copy-value-to-loc-array-literal") </trace>
	[internal]

rule [copy-value-to-loc-object-literal]: 	
	<k> copyValueToLoc(Literal('ObjectCreation(ClassName:Id,, Args:K)),L1) => makeNewObject(L1, ClassName, Args) ... </k>
	<trace> Trace:List => Trace ListItem("copy-value-to-loc-object-literal") </trace>
	[internal]

syntax K ::= "copyArrayMembers" "(" Loc "," List ")"    

rule [copyArrayMembers-cons-no-aliasing]: 
	<k> copyArrayMembers(L1:Loc, ListItem([Key,Visib,L]) Elems) => 
		ArrayCreateElem(L1,Key,Visib,allocValue(V)) ~> 
		copyArrayMembers(L1, Elems) ... </k>
	<heap> ...  L |-> zval(V:Value,_,_,false) ... </heap>
	<trace> Trace:List => Trace ListItem("copyArrayMembers-cons-no-aliasing") </trace>
	[intermediate]

rule [copyArrayMembers-cons-aliasing]:
	<k> copyArrayMembers(L1:Loc, ListItem([Key,Visib,L]) Elems) => 
		ArrayCreateElem(L1,Key,Visib,L) ~> 
		copyArrayMembers(L1, Elems) ... </k>
	<heap> ...  L |-> zval(V:Value,_,_,true) ... </heap>
	<trace> Trace:List => Trace ListItem("copyArrayMembers-cons-aliasing") </trace>
	[intermediate]
    
rule [copyArrayMembers-nil]:    
	<k> copyArrayMembers(_,.List) => . ... </k>
	<trace> Trace:List => Trace ListItem("copyArrayMembers-nil") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Basic Operations on references} 
		We define here a number of internal oparations on references, that will be used 
		extensively in the semantics. */
// ---------------------------------------------------------------------------------------------

/*@ get operations take a reference as input and returns a memory location */

syntax K ::= "Rget" "(" Ref ")" 				[strict]
		   | "RgetRef" "(" Ref "," RefType ")"	[strict(1)]
		   
rule [rget-default]: 
	<k> Rget(R:Ref) => RgetRef(R, nul) ... </k>
	<trace> Trace:List => Trace ListItem("rget-default") </trace>
	[structural]

// Recursive propagation of get operations

rule [rget-propagate]:    
	<k> RgetRef(lref(R:Ref, X:Key, T1:RefType),T2:RefType) => RgetRef(ref(RgetRef(R,T1), X), T2) ... </k>
	<trace> Trace:List => Trace ListItem("rget-propagate") </trace>
	[structural]
	
// Reading an array property

rule [rget-array-prop]:
	<k> RgetRef(ref(L:Loc, X:Key), _) =>  L1 ... </k>
	<heap>... L |-> zval(Array(_,_:List ListItem([X,public,L1]) _:List),_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("rget-array-prop") </trace>
	[internal]

rule [rget-array-prop-undefined]:
	<k> RgetRef(ref(L:Loc, X:Key), _) =>  
		NOTICE("Undefined variable: %s in %s on line %d\n") ~> locNull ... </k>
	<heap>... L |-> zval(Array(_,ArrayElements),_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("rget-array-prop-undefined") </trace>
	when notBool (ArrayElements hasProperty X)
	[internal, error]

// Reading an object property

// public (i.e. no restrictions)

rule [rget-obj-prop-public]:
	<k> RgetRef(ref(L:Loc, X:String), _) => L2 ... </k>
	<class> Context:K </class>
	<heap>
	... 
		L |-> zval(OID(L1:Loc,_,_),_,_,_)  
		L1 |-> zval(Array(_,(E:List ListItem([X,public,L2:Loc]) F:List)),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("rget-obj-prop-public") </trace>
	when notBool (E F hasPrivateProperty X for Context)
	[internal]

// protected        

rule [rget-obj-prop-protected]:    
	<k> RgetRef(ref(L:Loc, X:String), _) => 
		*Cond(isVisible(ObjClass, Context, protected), L2, ERROR("ERROR-PROTECTED")) ... </k>
	<class> Context:K </class>
	<heap>
	... 
		L |-> zval(OID(L1:Loc,ObjClass:Id,_),_,_,_)  
		L1 |-> zval(Array(_,(E:List ListItem([X,protected,L2:Loc]) F:List)),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("rget-obj-prop-protected") </trace>
	when notBool (E F hasPrivateProperty X for Context)
	[internal]
	
// private

rule [rget-obj-prop-private]:
	<k> RgetRef(ref(L:Loc, X:String),_) => L2 ... </k>
	<class> Context </class>
	<heap>
	... 
		L |-> zval(OID(L1:Loc,ObjClass,_),_,_,_)  
        L1 |-> zval(Array(_,(E:List ListItem([X,private(Context),L2:Loc]) F:List)),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("rget-obj-prop-private") </trace>
	[internal]

// non-existent property

rule [rget-obj-prop-undefined]:    
	<k> RgetRef(ref(L:Loc, X:String), _) => 
		NOTICE("Undefined property: %s in %s on line %d\n") ~> 
		locNull ... </k>
	<heap>
	... 
		L |-> zval(OID(L1:Loc,_,_),_,_,_)  
        L1 |-> zval(Array(_,E:List),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("rget-obj-prop-undefined") </trace>
	when notBool (E hasProperty X)
	[internal]

// not a compound value

rule [rget-obj-scalar]:
	<k> RgetRef(ref(L:Loc,_),_) =>  locNull ... </k>
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("rget-obj-scalar") </trace>
	when (notBool (isArrayType(V))) andBool (notBool (isStringType(V))) andBool (notBool (isObjectType(V)))
	[internal]

rule [rget-null]: 	
	<k> RgetRef(ref(locNull, _), _) => locNull ... </k>
	<trace> Trace:List => Trace ListItem("rget-null") </trace>
	[internal]

// String element access. Most likely we'll need to change this one 

rule [rget-string-index]:	
	<k> RgetRef(ref(L:Loc, Index:Int),_) => substrString(Str, Index, Index +Int 1) ... </k>
	<heap> ... L |-> zval(Str:String,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("rget-string-index") </trace>
	[internal]

rule [rget-string-undef]:	
	<k> RgetRef(ref(L:Loc, Index:String),_) => locNull ... </k>
	<heap> ... L |-> zval(Str:String,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("rget-string-undef") </trace>
	[internal]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Lget} 
		LGet works the same ways as RGet when the reference being resolved does exists. 
		The difference between RGet is that in the case the reference does not exists, 
		it is created on the fly. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "Lget" "(" Ref ")" [strict]

rule [lget-default]:
	<k> Lget(R:Ref) => LgetRef(R, nul) ... </k>
	<trace> Trace:List => Trace ListItem("lget-default") </trace>
	[structural]

syntax K ::= "LgetRef" "(" Ref "," RefType ")" [strict(1), klabel('put)]
syntax Loc ::= "LError"

rule [lget-propagate]:    
	<k> LgetRef(lref(R:Ref, X:Key, T1:RefType),T2:RefType) => LgetRef(ref(LgetRef(R,T1), X), T2) ... </k>
	<trace> Trace:List => Trace ListItem("lget-propagate") </trace>
	[structural]

/* Case 1: the reference exists. RGet is called */

// Array case

rule [lget-found-array]:
	<k> LgetRef(ref(L:Loc,X:Key), _) => Rget(ref(L,X)) ... </k>
	<heap> ... L |-> zval(Array(_,ArrayElems),_,_,_) ... </heap>    
	<trace> Trace:List => Trace ListItem("lget-found-array") </trace>
	when (ArrayElems hasProperty X) andBool (L =/=K LError)
	[internal]
	
// Object case

rule [lget-found-obj]:
	<k> LgetRef(ref(L:Loc, X:Key),_) =>  Rget(ref(L, X)) ... </k>
	<heap>
	... 
		L  |-> zval(OID(L1:Loc,_,_),_,_,_)
		L1 |-> zval(Array(_,Elems:List),_,_,_)  
	...
	</heap>
	<trace> Trace:List => Trace ListItem("lget-found-obj") </trace>
	when (Elems hasProperty X)
	[internal]
	
/* Case 2: the reference does not exists. */

// Array 

rule [lget-not-found-init-null]:
	<k> LgetRef(ref(L:Loc,X:Key), nul) =>   
		ArrayCreateElem(L, X, public, allocValue(NULL)) ~> 
		Rget(ref(L,X)) ... </k>
	<heap> ... L |-> zval(Array(_,ArrayElems),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("lget-not-found-init-null") </trace>
	when (notBool ArrayElems hasProperty X) andBool
	(L =/=K LError) andBool (X =/=K NULL)
	[internal]

rule [lget-not-found-init-array]:    
	<k> LgetRef(ref(L:Loc,X:Key), arr) =>   
		ArrayCreateElem(L, X, public, allocValue(emptyArray)) ~> Rget(ref(L,X)) ... </k>
	<heap> ... L |-> zval(Array(_,ArrayElems),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("lget-not-found-init-array") </trace>
	when (notBool ArrayElems hasProperty X) andBool 
    	 (L =/=K LError) andBool (X =/=K NULL)
	[internal]

rule [lget-not-found-init-obj]:    
	<k> LgetRef(ref(L:Loc,X:Key), obj) => 
		'Expr('Assign(ref(L, X),, ('ObjectCreation("stdClass")))) ~> 
		Rget(ref(L,X)) ...  </k>
	<heap> ... L |-> zval(Array(_,Elems:List), _, _, _) ... </heap>
	<trace> Trace:List => Trace ListItem("lget-not-found-init-obj") </trace>
	when (notBool Elems hasProperty X) andBool 
    	 (L =/=K LError) andBool (X =/=K NULL)
	[internal]

// Object

rule [lget-not-found-in-obj]:    
	<k> LgetRef(ref((L:Loc => L2),X:Key), _) ... </k>
	<heap> 
	... 
		L |-> zval(OID(L2:Loc,_,_),_,_,_)  
		L2 |-> zval(Array(_,ArrayElems),_,_,_) 
	... 
	</heap>
	<trace> Trace:List => Trace ListItem("lget-not-found-in-obj") </trace>
	when (notBool ArrayElems hasProperty X)
	[internal]

// Default array key

rule [lget-not-found-default-array-key]:    
	<k> LgetRef(ref(L:Loc,NULL), T) => LgetRef(ref(L,biggestIntKey(Elems) +Int 1),T) ... </k>
	<heap> ... L |-> zval(Array(_,Elems:List),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("lget-not-found-default-array-key") </trace>
	when  (L =/=K LError)
	[internal]

// Error

rule [lget-error-1]:    
	<k> LgetRef(ref(L:Loc,X:Key),_) => 
		WARNING("Cannot use a scalar value as an array in %s on line %d\n") ~> locNull ... </k>
  	<heap>... L |-> zval(V:Value,_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("lget-error-1") </trace>
	when (notBool (isArrayType(V))) andBool (notBool (isObjectType(V)))
	[internal, error]
	
endmodule
