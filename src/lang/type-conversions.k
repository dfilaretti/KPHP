require "core.k"

module TYPE-CONVERSIONS 
    imports CORE

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Type Conversions} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Surface syntax for type conversione} */
// ---------------------------------------------------------------------------------------------

context 'IntCast(HOLE)

rule [int-cast-arg2LangValue]:
	<k> 'IntCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("int-cast-arg2LangValue") </trace>
	[intermediate]

rule [int-cast]:    
	<k> 'IntCast(V:LanguageValue) => *toInteger(V) ... </k>
	<trace> Trace:List => Trace ListItem("int-cast") </trace>
	[step]

context 'StringCast(HOLE)

rule [string-cast-arg2LangValue]: 	
	<k> 'StringCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("string-cast-arg2LangValue") </trace>
	[intermediate]

rule [string-cast]:    
	<k> 'StringCast(V:LanguageValue) => *toString(V) ... </k>
	<trace> Trace:List => Trace ListItem("string-cast") </trace>
	[step]

context 'BoolCast(HOLE)

rule [bool-cast-arg2LangValue]:
	<k> 'BoolCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("bool-cast-arg2LangValue") </trace>
	[intermediate]

rule [bool-cast]:    
	<k> 'BoolCast(V:LanguageValue) => *toBoolean(V) ... </k>
	<trace> Trace:List => Trace ListItem("bool-cast") </trace>
	[step]

context 'FloatCast(HOLE)

rule [float-cast-arg2LangValue]:
	<k> 'FloatCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("float-cast-arg2LangValue") </trace>
	[intermediate]

rule [float-cast]:    
	<k> 'FloatCast(V:LanguageValue) => *toFloat(V) ... </k>
	<trace> Trace:List => Trace ListItem("float-cast") </trace>
	[step]
	
context 'ObjectCast(HOLE)

rule [object-cast-arg2LangValue]: 	
	<k> 'ObjectCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("object-cast-arg2LangValue") </trace>
	[intermediate]
rule [object-cast]:    
	<k> 'ObjectCast(V:LanguageValue) => *toObject(V) ... </k>
	<trace> Trace:List => Trace ListItem("object-cast") </trace>
	[step]
	
context 'ArrayCast(HOLE)

rule [array-cast-arg2LangValue]: 	
	<k> 'ArrayCast(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("array-cast-arg2LangValue") </trace>
	[intermediate]

rule [array-cast]:    
	<k> 'ArrayCast(V:LanguageValue) => *toArray(V) ... </k>
	<trace> Trace:List => Trace ListItem("array-cast") </trace>
	[step]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{To Boolean} */
// ---------------------------------------------------------------------------------------------


//syntax K ::= "*toBoolean" "(" LanguageValue ")" [strict, domain]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{To Float} */
// ---------------------------------------------------------------------------------------------


//syntax K ::= "*toFloat" "(" LanguageValue ")"  [strict, domain]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{To Integer} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "*toInteger" "(" LanguageValue ")"  [strict]

/* TODO: move to domains 
rule [toInteger-false]:
	<k> *toInteger(false) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-false") </trace>
	[internal]

rule [toInteger-true]:
	<k> *toInteger(true) => 1 ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-true") </trace>
	[internal]

rule [toInteger-int]:
	<k> *toInteger(I:Int) => I ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-int") </trace>
	[internal]

rule [toInteger-float]:   
	<k> *toInteger(F:Float) => Float2Int(F) ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-float") </trace>
	[internal]

rule [toInteger-string]:	
	<k> *toInteger(S:String) => *toInteger(string2Number(S)) ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-string") </trace>
	[internal]

// Object and Array cases are "udefined" according to the docs
// (http://www.php.net/manual/en/language.types.integer.php)

// However, it seems that Zend returns 1 when converting an object 
// or an array to integer. We do the same here, but we also issue a 
// warning.

rule [toInteger-compound]:	
	<k> *toInteger(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> 1 ... </k>
	<trace> Trace:List => Trace ListItem("toInteger-compound") </trace>
	[internal, error]
*/


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Is numeric string} */
// ---------------------------------------------------------------------------------------------

// TODO: move to domain	
syntax Bool ::= "isNumericString" "(" String ")" [function]	
			  | "isIntString" "(" String ")" [function]	
			  | "isFloatString" "(" String ")" [function]	

// empty string
rule isNumericString("") => false

// one char
rule isNumericString(S:String) => false
	when (lengthString(S) ==Int 1 orBool lengthString(S) ==Int 2) andBool (notBool #isDigit(substrString(S, 0, 1)))

rule 
	isNumericString(S:String) => true
	when (lengthString(S) ==Int 1) andBool (#isDigit(substrString(S, 0, 1)))

// non numeric

rule 
	isNumericString(S:String) => false
	when notBool (
		((lengthString(S) >Int 1) andBool #isDigit(substrString(S, 0, 1))) orBool	
		((substrString(S, 0, 1) ==String "-" orBool substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2)))) orBool
		((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3)))))

// integer

rule 
	isNumericString(S:String) => true
	when ((lengthString(S) >Int 1) andBool
		#isDigit(substrString(S, 0, 1))) orBool
		((substrString(S, 0, 1) ==String "-") andBool (#isDigit(substrString(S, 1, 2))))

/* string starting with ".N"  */

rule 
	isNumericString(S:String) => true
	when ((lengthString(S) >Int 1) andBool
		#isDigit(substrString(S, 0, 1))) orBool
		((substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2))))

/* string starting with "-."  */

rule     
	isNumericString(S:String) => true
	when ((lengthString(S) >Int 2) andBool
		#isDigit(substrString(S, 0, 1))) orBool
		((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3))))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{String 2 number} 
		Converts a string to a number. */
// ---------------------------------------------------------------------------------------------

// TODO: move to domains
syntax K ::= "string2Number" "(" AString ")"

rule [string2Number-empty]:
	<k> string2Number("") => 0 ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-empty") </trace>
	[internal]

// one character string

rule [string2Number-char-non-digit]:    
	<k> string2Number(S:String) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-char-non-digit") </trace>
	when (lengthString(S) ==Int 1 orBool lengthString(S) ==Int 2) andBool (notBool #isDigit(substrString(S, 0, 1)))
	[internal]

rule [string2Number-char-digit]:    
	<k> string2Number(S:String) => String2Int(S) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-char-digit") </trace>
	when (lengthString(S) ==Int 1) andBool (#isDigit(substrString(S, 0, 1)))
	[internal]

// non numeric 

rule [string2Number-non-numeric]:    
	<k> string2Number(S:String) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-non-numeric") </trace>
	when notBool (
		((lengthString(S) >Int 1) andBool #isDigit(substrString(S, 0, 1))) orBool	
		((substrString(S, 0, 1) ==String "-" orBool substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2)))) orBool
		((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3)))))
	[internal]
	
// integer 

rule [string2Number-int]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 1), 1, int) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-int") </trace>
	when ((lengthString(S) >Int 1) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 1) ==String "-") andBool (#isDigit(substrString(S, 1, 2))))
	[internal]

// string starting with ".N" 

rule [string2Number-float-dot]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 1), 1, float) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-float-dot") </trace>
	when ((lengthString(S) >Int 1) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2))))
	[internal]

// string starting with "-." 

rule [string2Number-float-minus-dot]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 2), 2, float) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-float-minus-dot") </trace>
	when ((lengthString(S) >Int 2) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3))))
	[internal]

// conversion from string to int according to PHP rules (see PHP docs) 

// TODO: move to domains
syntax K ::= "extractIntSubstring" "(" String "," String "," Int "," Type ")"

// digit
rule [extract-int-substring-1]:
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int,
		T:Type
	) =>
	extractIntSubstring(
		Origin:String, 
		Number +String substrString(Origin, Index, Index +Int 1),
		Index +Int 1,
		T:Type
	) ... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-1") </trace>
	when 	#isDigit(substrString(Origin, Index, Index +Int 1)) andBool 
			(Index <Int lengthString(Origin))
	[internal]
		
// "."
rule [extract-int-substring-2]: 	
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int,
		int
	) =>
	extractIntSubstring(
		Origin:String, 
		Number +String substrString(Origin, Index, Index +Int 1),
		Index +Int 1,
		float
	) ... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-2") </trace>
	when 	(substrString(Origin, Index, Index +Int 1) ==String ".") andBool
			(#isDigit(substrString(Origin, Index +Int 1, Index +Int 2))) andBool
			((Index +Int 1) <Int lengthString(Origin))
	[internal]

rule [extract-int-substring-3]: 	
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int,
		float
	) => String2Float(Number) ... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-3") </trace>
	when notBool (#isDigit(substrString(Origin, Index, Index +Int 1)) andBool 
	(Index <Int lengthString(Origin)))
	[internal]
				
rule [extract-int-substring-4]: 	
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int,
		int
	) => String2Int(Number) ... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-4") </trace>
	when notBool (#isDigit(substrString(Origin, Index, Index +Int 1)) andBool 
			(notBool (substrString(Origin, Index, Index +Int 1) ==String ".")) andBool
			(Index <Int lengthString(Origin)))
	[internal]

/* the entire string represent a number  */

rule [extract-int-substring-5]: 	
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int, 
		int
	) => String2Int(Number)	... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-5") </trace>
	when Index ==Int lengthString(Origin)
	[internal]
		
rule [extract-int-substring-6]: 	
	<k> extractIntSubstring(
		Origin:String, 
		Number:String, 
		Index:Int, 
		float
	) => String2Float(Number) ... </k>
	<trace> Trace:List => Trace ListItem("extract-int-substring-6") </trace>				
	when Index ==Int lengthString(Origin)
	[internal]
		
/*@ to string */


//syntax K ::= "*toString" "(" LanguageValue ")"  

/* TODO: move to domain
rule [toString-true]:
	<k> *toString(true) => "1" ... </k>
	<trace> Trace:List => Trace ListItem("toString-true") </trace>
	[internal]

rule [toString-false]:
	<k> *toString(false) => "" ... </k>
	<trace> Trace:List => Trace ListItem("toString-false") </trace>
	[internal]

rule [toString-int]:   
	<k> *toString(I:Int) => Int2String(I) ... </k>
	<trace> Trace:List => Trace ListItem("toString-int") </trace>
	[internal]

rule [toString-float]:   
	<k> *toString(F:Float) => Float2String(F) ... </k>
	<trace> Trace:List => Trace ListItem("toString-float") </trace>
	[internal]

rule [toString-string]:   
	<k> *toString(S:String) => S ... </k>
	<trace> Trace:List => Trace ListItem("toString-string") </trace>
	[internal]

rule [toString-array]:   
	<k> *toString(Arr:Array) => "Array" ... </k>
	<trace> Trace:List => Trace ListItem("toString-array") </trace>
	[internal]
	
// TODO: put correct error msg
// TODO: use magic method __toString()

rule [toString-object]:   
	<k> *toString(Obj:Object) => ERROR("Object of class %s could not be converted to string in %s on line %d") ... </k>
	<trace> Trace:List => Trace ListItem("toString-array") </trace>
	[internal, error]

rule [toString-null]:   
	<k> *toString(NULL) => "" ... </k>
	<trace> Trace:List => Trace ListItem("toString-null") </trace>
	[internal]
*/


// ---------------------------------------------------------------------------------------------
/*@ \subsection{To Object} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "*toObject" "(" LanguageValue ")" [strict]

// cast to object for scalar values

rule [toObject-scalar]:    
	<k> *toObject(S:ScalarValue) =>  makeObjectFromArray(makeArrayFromScalar(S, "scalar")) ... </k>
	<trace> Trace:List => Trace ListItem("toObject-scalar") </trace>
	[internal]

// cast to object for compound values. 

rule [toObject-array]:    
	<k> *toObject(A:Array) =>  makeObjectFromArray(A) ... </k>
	<trace> Trace:List => Trace ListItem("toObject-array") </trace>
	[internal]
	
rule [toObject-object]:    
	<k> *toObject(O:Object) =>  O ... </k>
	<trace> Trace:List => Trace ListItem("toObject-object") </trace>
	[internal]

// construct an object of stdClass from a given array

syntax K ::= "makeObjectFromArray" "(" Array ")" [strict]

rule [make-object-from-array]:
	<k> makeObjectFromArray(A) => 
			copyValueToLoc(A, L) ~> 
			*Cond(arrayCurrentOverflow(A), 'Expr(reset(L)), .K) ~>
			OID(L, String2Id("stdClass"), 0) ... </k>
	<trace> Trace:List => Trace ListItem("make-object-from-array") </trace>
	when fresh(L:Loc)
	[internal]

// takes a scalar V and a key K as input and returns an array {K => V}. 

syntax K ::= "makeArrayFromScalar" "(" ScalarValue "," Key ")"

rule [make-array-from-scalar]:
	<k> makeArrayFromScalar(V, K) => Literal('Array('ListWrap('Pair('Some('Key(K)),,'Value(V))))) ... </k>
	<trace> Trace:List => Trace ListItem("make-array-from-scalar") </trace>
	[internal]

// returns true if the argument has current pointer set to none and 
// is not an empty array

syntax Bool ::= "arrayCurrentOverflow" "(" Array ")"	[function]
rule arrayCurrentOverflow(Array(none, Elems)) => true when Elems =/=List .List
rule arrayCurrentOverflow(Array(none, .List)) => false 
rule arrayCurrentOverflow(Array(ArrayItem, _)) => false 

// ---------------------------------------------------------------------------------------------
/*@ \subsection{To Array} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "*toArray" "(" LanguageValue ")" [strict]

// cast to array for scalar values

rule [toArray-scalar]:    
	<k> *toArray(S:ScalarValue) =>  makeArrayFromScalar(S, 0) ... </k>
	<trace> Trace:List => Trace ListItem("toArray-scalar") </trace>
	[internal]

// cast to object for compound values. 

rule [toArray-array]:    
	<k> *toArray(A:Array) => A ... </k>
	<trace> Trace:List => Trace ListItem("toArray-array") </trace>
	[internal]
	
rule [toArray-object]:    
	<k> *toArray(OID(L,_,_)) => 
			copyValueToLoc(A, L1) ~> 
			*Cond(arrayCurrentOverflow(A), 'Expr(reset(L1)), .K) ~>
			L1 
	... </k>
	<heap> ... L |-> zval(A:Array,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("toArray-object") </trace>
	when fresh(L1:Loc)
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Some auxiliary constructs} */
// ---------------------------------------------------------------------------------------------

// Ugly "normalisation" function for floats. 
// If the argument is a float with decimal part of zero, it is casted to int,
// otherwise the float is kept.

syntax K ::= "normalizeFloat" "(" Float ")"	[function]

/* TODO: move to domain
rule normalizeFloat(F) => F	
	when notBool (hasNoDecimalPart(F))
	
rule normalizeFloat(F) => Float2Int(F)
	when (hasNoDecimalPart(F))

syntax Bool ::= "hasNoDecimalPart" "(" Float ")"	[function]

rule hasNoDecimalPart(F) => (Int2Float(Float2Int(F)) -Float F) ==Float 0.0
*/

endmodule 
