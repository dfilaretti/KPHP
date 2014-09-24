require "shared.k"
require "model-checking.k"

module ARITH-OPS 
    imports SHARED
    imports MODEL-CHECKING

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Arithmetic operations} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Negation} */
// ---------------------------------------------------------------------------------------------

rule [negative]:
	<k> 'Negative(X:K) => 'Min(0,,X) ... </k>
	<trace> Trace:List => Trace ListItem("negative") </trace>
	[structural]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Positive} 
		It does nothing! */
// ---------------------------------------------------------------------------------------------

rule [positive]: 
	<k> 'Positive(X:K) => X ... </k>
	<trace> Trace:List => Trace ListItem("positive") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Addition} */
// ---------------------------------------------------------------------------------------------

syntax BinaryOp ::= "plus" | "min" | "mul" | "div" | "mod"
syntax K ::= "BinOp" "(" BinaryOp "," K "," K ")"

rule [plus]: 
	<k> 'Plus(L:K,, R:K) => BinOp(plus, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("plus") </trace>
	[step]

rule [min]: 
	<k> 'Min(L:K,, R:K)  => BinOp(min, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("min") </trace>
	[step]

rule [mul]:
	<k> 'Mul(L:K,, R:K)  => BinOp(mul, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("mul") </trace>
	[step]

rule [div]:
	<k> 'Div(L:K,, R:K)  => BinOp(div, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("div") </trace>
	[step]
	
rule [mod]:
	<k> 'Mod(L:K,, R:K)  => BinOp(mod, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("mod") </trace>
	[step]

context [binop-LHS-strict]: 
	BinOp(_,HOLE,_)
	
context [binop-RHS-strict-1]: 
	BinOp(_,_:BasicRef,HOLE)
	
context [binop-RHS-strict-2]: 
	BinOp(_,_:LanguageValue,HOLE)

// Arguments evaluation

rule [binop-LHS2LangValue-lref]:
	<k> BinOp(_,(R:LRef => convertToLanguageValue(R)),_) ... </k>
	<trace> Trace:List => Trace ListItem("binop-LHS2LangValue-lref") </trace>
	[intermediate]

rule [binop-LHS2LangValue-loc]:
	<k> BinOp(_,(R:Loc => convertToLanguageValue(R)),_) ... </k>
	<trace> Trace:List => Trace ListItem("binop-LHS2LangValue-loc") </trace>
	[intermediate]
	
rule [binop-RHS2LangValue-1]:
	<k> BinOp(_,_:LanguageValue,(V1:ConvertibleToLanguageValue => convertToLanguageValue(V1))) ... </k>
	<trace> Trace:List => Trace ListItem("binop-RHS2LangValue-1") </trace>
	[intermediate]

rule [binop-RHS2LangValue-2]:
	<k> BinOp(_,_:BasicRef,(V1:ConvertibleToLanguageValue => convertToLanguageValue(V1))) ... </k>
	<trace> Trace:List => Trace ListItem("binop-RHS2LangValue-2") </trace>
	[intermediate]

rule [binop-LHS2LangValue]:    
	<k> BinOp(_,(V:BasicRef => convertToLanguageValue(V)),_:LanguageValue) ... </k>
	<trace> Trace:List => Trace ListItem("binop-LHS2LangValue") </trace>
	[intermediate]

// Type juggling for binary operators

rule [binop-RHS2Float]: 	
	<k> BinOp(_,V1:Float,(V2:LanguageValue => 'FloatCast(V2))) ... </k>
	<trace> Trace:List => Trace ListItem("binop-RHS2Float") </trace>
	when notBool (isFloatType(V2))
	[intermediate]

rule [binop-LHS2Float]: 	
	<k> BinOp(_,(V1:LanguageValue => 'FloatCast(V1)),V2:Float) ... </k>
	<trace> Trace:List => Trace ListItem("binop-LHS2Float") </trace>
	when notBool (isFloatType(V1))
	[intermediate]

rule [binop-RHS2Int]:
	<k> BinOp(_,V1:Int,(V2:String => string2Number(V2))) ... </k>
	<trace> Trace:List => Trace ListItem("binop-RHS2Int") </trace>
	[intermediate]
	
rule [binop-LHS2Int]:
	<k> BinOp(_,(V2:String => string2Number(V2)),V1:Int) ... </k>
	<trace> Trace:List => Trace ListItem("binop-LHS2Int") </trace>
	[intermediate]

// plus

rule [binop-plus-int]:    
	<k> BinOp(plus,I1:Int,I2:Int) => I1 +Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-plus-int") </trace>
	[step]

rule [binop-plus-float]:    
	<k> BinOp(plus,F1:Float,F2:Float) => F1 +Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-plus-float") </trace>
	[step]

// min

rule [binop-min-int]:    
	<k> BinOp(min,I1:Int,I2:Int) => I1 -Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-min-int") </trace>
	[step]

rule [binop-min-float]:    
	<k> BinOp(min,F1:Float,F2:Float) => F1 -Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-min-float") </trace>
	[step]

// mul

rule [binop-mul-int]:    
	<k> BinOp(mul,I1:Int,I2:Int) => I1 *Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-mul-int") </trace>
	[step]

rule [binop-mul-float]:    
	<k> BinOp(mul,F1:Float,F2:Float) => F1 *Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-mul-float") </trace>
	[step]

// div

rule [binop-div-int]:    
	<k> BinOp(div,I1:Int,I2:Int) => normalizeFloat(Int2Float(I1) /Float Int2Float(I2)) ... </k>
	<trace> Trace:List => Trace ListItem("binop-div-int") </trace>
	when I2 =/=Int 0
	[step]

rule [binop-div-float]:    
	<k> BinOp(div,F1:Float,F2:Float) => F1 /Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-div-float") </trace>
	when F2 =/=Float 0.0
	[step]

// --- Division by zero triggers a warning and returns false

rule [binop-div-int-zero]:    
	<k> BinOp(div,_,Z:ScalarValue) => WARNING("Division by zero in %s on line %d\n") ~> false ... </k>
	<trace> Trace:List => Trace ListItem("binop-div-int-zero") </trace>
	when Z ==K 0 orBool Z ==K 0.0 
	[error]
	
// mod

rule [binop-mod-args2Int]:    
	<k> BinOp(mod,I1:Float => *toInteger(I1),(I2:Float => *toInteger(I2))) ... </k>
	<trace> Trace:List => Trace ListItem("binop-mod-args2Int") </trace>
	[intermediate]
	
rule [binop-mod-int]:    
	<k> BinOp(mod,I1:Int,I2:Int) => I1 modInt I2 ... </k>
	<trace> Trace:List => Trace ListItem("binop-mod-int") </trace>
	[step]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Comparison operators} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

syntax NonStrictComparisonOp ::= "equal" | "less" | "lessEqual" | "greater" | "greaterEqual"
syntax StrictComparisonOp ::= "identical"
syntax ComparisonOp ::= StrictComparisonOp | NonStrictComparisonOp 
syntax Bool ::= "isStrictComparison" "(" ComparisonOp ")" [function]

rule isStrictComparison(Op:StrictComparisonOp) => true
rule isStrictComparison(Op:NonStrictComparisonOp) => false

syntax K ::= "comparison" "(" ComparisonOp "," K "," K ")"

rule [isEqual]: 
	<k> 'IsEqual(L:K,, R:K) => comparison(equal, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual") </trace>
	[step]
	
rule [isIdentical]: 
	<k> 'IsIdentical(L:K,, R:K) => comparison(identical, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("isIdentical") </trace>
	[step]

rule [less]:
	<k> 'Less(L:K,, R:K) => comparison(less, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("less") </trace>
	[step]

rule [lessEqual]:
	<k> 'LessEqual(L:K,, R:K) => comparison(lessEqual, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual") </trace>
	[step]

rule [greater]:
	<k> 'Greater(L:K,, R:K) => comparison(greater, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("greater") </trace>
	[step]

rule [greaterEqual]:
	<k> 'GreaterEqual(L:K,, R:K) => comparison(greaterEqual, L, R) ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual") </trace>
	[step]

// The construct is strict in both arguments

context comparison(_,HOLE,_)
context comparison(_,_,HOLE)

// Evaluate arguments to locations...

rule [isEqual-LHS2Loc]:
	<k> comparison(_,(CL:ConvertibleToLoc => convertToLoc(CL,r)),_) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-LHS2Loc") </trace>
	[intermediate]

rule [isEqual-RHS2Loc]:
	<k> comparison(_,_,(CL:ConvertibleToLoc => convertToLoc(CL,r))) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-RHS2Loc") </trace>
	[intermediate]
	
// ... and locations to values, but only if the location does NOT contain a compound value

rule [isEqual-LHS2LangValue]:
	<k> comparison(_,(L:Loc => V),_) ... </k>
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("isEqual-LHS2LangValue") </trace>
	when notBool(V isCompoundValue)
	[intermediate]
			
rule [isEqual-RHS2LangValue]: 	
	<k> comparison(_,_,(L:Loc => V)) ... </k>
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("isEqual-RHS2LangValue") </trace>
	when notBool(V isCompoundValue)
	[intermediate]

// Type juggling (see http://php.net/manual/en/language.operators.comparison.php)

rule [isEqual-type-juggling-1-1]: 	
	<k> comparison(Op:ComparisonOp,(NULL => ""),S:String) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-type-juggling-1-1") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]
	
rule [isEqual-type-juggling-1-2]: 	
	<k> comparison(Op:ComparisonOp,S:String,(NULL => "")) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-type-juggling-1-2") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]

// -- convert to boolean if one arg is boolean or null

syntax BoolOrNull ::= Bool | Null
syntax LanguageValue ::= BoolOrNull

rule [isEqual-type-juggling-2]: 	
	<k> comparison(Op:ComparisonOp,(B:BoolOrNull => *toBoolean(B)),(V2:LanguageValue => *toBoolean(V2))) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-type-juggling-2") </trace>
	when notBool ((isStringType(V2)) orBool (isBoolType(V2)))
	andBool notBool(isStrictComparison(Op))
	[intermediate]
	
rule [isEqual-type-juggling-3]: 	
	<k> comparison(Op:ComparisonOp,(V2:LanguageValue => *toBoolean(V2)),(B:BoolOrNull => *toBoolean(B))) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-type-juggling-3") </trace>
	when notBool ((isStringType(V2)) orBool (isBoolType(V2)))
	andBool notBool(isStrictComparison(Op))
	[intermediate]

// --  converts "numeric strings" to number

rule 	comparison(Op:ComparisonOp,(V1:String => string2Number(V1)),_)
			when (isNumericString(V1)) andBool (notBool(isStrictComparison(Op)))
			
rule 	comparison(Op:ComparisonOp,_,(V2:String => string2Number(V2)))
			when (isNumericString(V2)) andBool (notBool(isStrictComparison(Op)))

// -- converts any string args to number

rule [comparison-ac]:
	<k> comparison(Op:ComparisonOp,V1:Value,(S:String => 0)) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-ac") </trace>
	when (notBool isStringType(V1)) andBool (notBool isNumericString(S)) andBool (notBool(isStrictComparison(Op)))
	[internal]

rule [comparison-acd]:
	<k> comparison(Op:ComparisonOp,(S:String => 0),V1:Value) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-acd") </trace>
	when (notBool isStringType(V1)) andBool (notBool isNumericString(S)) andBool (notBool(isStrictComparison(Op)))
	[internal]

// -- if any arg is float, the other one is converted to float as well
rule [isEqual-toFloat-RHS]:
	<k> comparison(Op:ComparisonOp,V1:Float,(V2:Int => *toFloat(V2))) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-toFloat-RHS") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]

rule [isEqual-toFloat-LHS]:	
	<k> comparison(Op:ComparisonOp,(V1:Int => *toFloat(V1)),V2:Float) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-toFloat-LHS") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]

// -- locNull becomes NULL
rule [isEqual-null-RHS]:	
	<k> comparison(Op:ComparisonOp,(locNull => NULL),_) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-null-RHS") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]

rule [isEqual-null-LHS]:	
	<k> comparison(Op:ComparisonOp,_,(locNull => NULL)) ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-null-LHS") </trace>
	when notBool(isStrictComparison(Op))
	[intermediate]

// isEqual

rule [comparison-equal-scalar]: 
	<k> comparison(equal, V1:LanguageValue, V2:LanguageValue) => isEqual(V1, V2) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-equal-scalar") </trace>
	when (V1 isScalar) andBool (hasSameType(V1, V2))
	[intermediate]

rule [comparison-equal-array]: 
	<k> comparison(equal, V1:Loc, V2:Loc) => isEqual(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-equal-array") </trace>
	when locsHoldSameCompound(M, V1, V2) 
	[intermediate]

/* REMOVE
rule [comparison-equal-loc]: 
	<k> comparison(equal, V1:Loc, V1) => true ... </k>
	<trace> Trace:List => Trace ListItem("comparison-equal-loc") </trace>
	[internal]
*/
	
// isIdentical

rule [comparison-identical-scalar]: 
	<k> comparison(identical, V1:LanguageValue, V2:LanguageValue) => V1 ==K V2 ... </k>
		<trace> Trace:List => Trace ListItem("comparison-identical-scalar") </trace>
	when notBool ((V1 isCompoundValue andBool V2 isCompoundValue) andBool hasSameType(V1, V2))
	[intermediate]
	
rule [comparison-identical-array]: 
	<k> comparison(identical, V1:Loc, V2:Loc) => isEqual(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-identical-array") </trace>
	when locsHoldSameCompound(M, V1, V2) 
	[intermediate]

/* REMOVE
rule [comparison-identical-loc]: 
	<k> comparison(identical, V1:Loc, V1) => true ... </k>
	<trace> Trace:List => Trace ListItem("comparison-identical-loc") </trace>
	[internal]
*/


// less

rule [comparison-less-scalar]: 
	<k> comparison(less, V1:LanguageValue, V2:LanguageValue) => less(V1, V2) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-less-scalar") </trace>
	when (V1 isScalar) andBool (hasSameType(V1, V2))
	[intermediate]

rule [comparison-less-array]: 
	<k> comparison(less, V1:Loc, V2:Loc) => less(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-less-array") </trace>
	when locsHoldSameCompound(M, V1, V2)
	[intermediate]	

// lessEqual

rule [comparison-lessequal-scalar]: 
	<k> comparison(lessEqual, V1:LanguageValue, V2:LanguageValue) => lessEqual(V1, V2) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-lessequal-scalar") </trace>
	when (V1 isScalar) andBool (hasSameType(V1, V2))
	[intermediate]

rule [comparison-lessEqual-array]: 
	<k> comparison(lessEqual, V1:Loc, V2:Loc) => lessEqual(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-lessEqual-array") </trace>
	when locsHoldSameCompound(M, V1, V2)
	[intermediate]	

// greater

rule [comparison-greater-scalar]: 
	<k> comparison(greater, V1:LanguageValue, V2:LanguageValue) => greater(V1, V2) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-greater-scalar") </trace>
	when (V1 isScalar) andBool (hasSameType(V1, V2))
	[intermediate]
	
rule [comparison-greater-array]: 
	<k> comparison(greater, V1:Loc, V2:Loc) => greater(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-greater-array") </trace>
	when locsHoldSameCompound(M, V1, V2)
	[intermediate]	

// greaterEqual

rule [comparison-greaterEqual-scalar]: 
	<k> comparison(greaterEqual, V1:LanguageValue, V2:LanguageValue) => greaterEqual(V1, V2) ... </k>
	<trace> Trace:List => Trace ListItem("comparison-greaterEqual-scalar") </trace>
	when (V1 isScalar) andBool (hasSameType(V1, V2))
	[intermediate]
	
rule [comparison-greaterEqual-array]: 
	<k> comparison(greaterEqual, V1:Loc, V2:Loc) => greaterEqual(V1, V2) ... </k>
	<heap> M:Map </heap>
	<trace> Trace:List => Trace ListItem("comparison-greaterEqual-array") </trace>
	when locsHoldSameCompound(M, V1, V2)
	[intermediate]	

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Equality} 
		$a == $b Equal TRUE if $a is equal to $b after type juggling. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "isEqual" "(" Value "," Value ")"

// Equality of scalar types. We inherit K/Maude builtin stuff.

rule [isEqual-int]:    
	<k> isEqual(I1:Int, I2:Int) => I1 ==Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-int") </trace>
	[internal]

rule [isEqual-float]:    
	<k> isEqual(F1:Float, F2:Float) => F1 ==Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-float") </trace>
	[internal]

rule [isEqual-bool]: 
	<k> isEqual(B1:Bool, B2:Bool) => B1 ==Bool B2 ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-bool") </trace>
	[internal]

rule [isEqual-string]:    
	<k> isEqual(S1:String, S2:String) => S1 ==String S2 ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-string") </trace>
	[internal]

/*
rule
	<k> isEqual(NULL, V:LanguageValue) => false ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-null-left") </trace>
	[internal]

rule
	<k> isEqual(V:LanguageValue, NULL) => false ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-null-right") </trace>
	[internal]
*/

// Array comparison: calls comparison routine "isEqualArray" (taken from PHP docs)


rule
	<k> isEqual(L:Loc,L) => true ... </k>
	<trace> Trace:List => Trace ListItem("isEqual-same-loc") </trace>
	[internal]

rule [isEqual-array]: 	
	<k> isEqual(L1:Loc, L2:Loc) => 
		*Cond(
		isEqualScalar('FunctionCall("isEqualArray",,'ListWrap('Param(L1),, 'Param(L2))),0),
		true,
		false) ... </k>
	<heap> 
	... 
		L1 |-> zval(V1:Array,_,_,_)
		L2 |-> zval(V2:Array,_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("isEqual-array") </trace>
	when (L1 =/=K L2)
	[internal]

// Object comparison. 

// --- if the objects has same class, they are compared as arrays

rule [isEqual-object-same-class]: 	
	<k> isEqual((L1:Loc => L3), (L2:Loc => L4)) ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class,_),_,_,_)
		L2 |-> zval(OID(L4,Class,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("isEqual-object-same-class") </trace>
	[internal]

// --- If the two objects has different classes, the comparison is false

rule [isEqual-object-different-class]: 	
	<k> isEqual(L1:Loc, L2:Loc) => false ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class1,_),_,_,_)
		L2 |-> zval(OID(L4,Class2,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("isEqual-object-different-class") </trace>
	when Class1 =/=K Class2
	[internal]

/* TODO: remove
rule //[isEqual-object-same-loc]: 	
	<k> isEqual(L1:Loc, L1) => true ... </k>
	//<trace> Trace:List => Trace ListItem("isEqual-object-same-loc") </trace>
	[internal]
*/

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Strict Equality} 
		$a === $b Equal TRUE if $a is equal to $b  */
// ---------------------------------------------------------------------------------------------

syntax K ::= "isIdentical" "(" Value "," Value ")"

rule [is-identical]: 
	<k> isIdentical(L:Value, R:Value) => L ==K R ... </k>
	<trace> Trace:List => Trace ListItem("isIdentical") </trace>

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Less Than} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "less" "(" K "," K ")"

// Scalars

rule [less-int]:
	<k> less(I1:Int, I2:Int) => I1 <Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("less-int") </trace>
	[internal]

rule [less-float]:     
	<k> less(F1:Float, F2:Float) => F1 <Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("less-float") </trace>
	[internal]

rule [less-bool-1]:
	<k> less(true, true) => false ... </k>
	<trace> Trace:List => Trace ListItem("less-bool-1") </trace>
	[internal]

rule [less-bool-2]:
	<k> less(true, false) => false ... </k>
	<trace> Trace:List => Trace ListItem("less-bool-2") </trace>
	[internal]

rule [less-bool-3]:
	<k> less(false, true) => true ... </k>
	<trace> Trace:List => Trace ListItem("less-bool-3") </trace>
	[internal]

rule [less-bool-4]:
	<k> less(false, false) => false ... </k>
	<trace> Trace:List => Trace ListItem("less-bool-4") </trace>
	[internal]

rule [less-string]:
	<k> less(S1:String, S2:String) => S1 <String S2 ... </k>
	<trace> Trace:List => Trace ListItem("less-string") </trace>
	[internal]

// Arrays and objects

rule [less-array]: 	
	<k> less(L1:Loc, L2:Loc) => 
			*Cond(
			isEqualScalar('FunctionCall("isEqualArray",,'ListWrap('Param(L1),, 'Param(L2))),-1),
			true,
			false) ... 
	</k>
	<heap> 
	... 
		L1 |-> zval(V1:Array,_,_,_)
		L2 |-> zval(V2:Array,_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("less-array") </trace>
	[internal]

// Object comparison. 

// ---  if the objects has same class, they are compared as arrays

rule [less-object-same-class]: 	
	<k> less((L1:Loc => L3), (L2:Loc => L4)) ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class,_),_,_,_)
		L2 |-> zval(OID(L4,Class,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("less-object-same-class") </trace>
	[internal]

// --- If the two objects has different classes, the comparison is false

rule [less-object-diff-class]: 	
	<k> less(L1:Loc, L2:Loc) => false ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class1,_),_,_,_)
		L2 |-> zval(OID(L4,Class2,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("less-object-diff-class") </trace>
	when Class1 =/=K Class2
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Greater Than} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "greater" "(" K "," K ")"

rule [greater-int]:
	<k> greater(I1:Int, I2:Int) => I1 >Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("greater-int") </trace>
	[internal]

rule [greater-float]:
	<k> greater(F1:Float, F2:Float) => F1 >Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("greater-float") </trace>
	[internal]

rule [greater-bool-1]:
	<k> greater(true, true) => false ... </k>
	<trace> Trace:List => Trace ListItem("greater-bool-1") </trace>
	[internal]

rule [greater-bool-2]:
	<k> greater(true, false) => true ... </k>
	<trace> Trace:List => Trace ListItem("greater-bool-2") </trace>
	[internal]

rule [greater-bool-3]:
	<k> greater(false, true) => false ... </k>
	<trace> Trace:List => Trace ListItem("greater-bool-3") </trace>
	[internal]

rule [greater-bool-4]:
	<k> greater(false, false) => false ... </k>
	<trace> Trace:List => Trace ListItem("greater-bool-4") </trace>
	[internal]

rule [greater-string]:
	<k> greater(S1:String, S2:String) => S1 >String S2 ... </k>
	<trace> Trace:List => Trace ListItem("greater-string") </trace>
	[internal]
	
// Array comparison: calls comparison routine "isEqualArray" (taken from PHP docs)

rule [greater-array]: 	
	<k> greater(L1:Loc, L2:Loc) => 
			*Cond(
			//isEqualScalar('FunctionCall("isEqualArray",,'ListWrap('Param(L1),, 'Param(L2))),1),
			isEqualScalar('FunctionCall("isEqualArray",,'ListWrap('Param(L2),, 'Param(L1))),-1),
			true,
			false) ... 
		
	</k>
	<heap> 
	... 
		L1 |-> zval(V1:Array,_,_,_)
		L2 |-> zval(V2:Array,_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greater-array") </trace>
	[internal]

// Object comparison. 

// --- if the objects has same class, they are compared as arrays

rule [greater-obj-same-class]: 	
	<k> greater((L1:Loc => L3), (L2:Loc => L4)) ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class,_),_,_,_)
		L2 |-> zval(OID(L4,Class,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greater-obj-same-class") </trace>
	[internal]

// --- If the two objects has different classes, the comparison is false

rule [greater-obj-diff-class]: 	
	<k> greater(L1:Loc, L2:Loc) => false ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class1,_),_,_,_)
		L2 |-> zval(OID(L4,Class2,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greater-obj-diff-class") </trace>
	when Class1 =/=K Class2

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Less than or equal} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "lessEqual" "(" K "," K ")"

// Equality of scalar types. We inherit K/Maude builtin stuff.

rule [lessEqual-int]:
	<k> lessEqual(I1:Int, I2:Int) => I1 <=Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-int") </trace>
	[internal]

rule [lessEqual-float]:
	<k> lessEqual(F1:Float, F2:Float) => F1 <=Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-float") </trace>
	[internal]

rule [lessEqual-bool-1]:
	<k> lessEqual(true, true) => true ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-bool-1") </trace>
	[internal]

rule [lessEqual-bool-2]:
	<k> lessEqual(true, false) => false ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-bool-2") </trace>
	[internal]

rule [lessEqual-bool-3]:
	<k> lessEqual(false, true) => true ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-bool-3") </trace>
	[internal]

rule [lessEqual-bool-4]:
	<k> lessEqual(false, false) => true ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-bool-4") </trace>
	[internal]

rule [lessEqual-string]:
	<k> lessEqual(S1:String, S2:String) => S1 <=String S2 ... </k>
	<trace> Trace:List => Trace ListItem("lessEqual-string") </trace>
	[internal]
	
// Array comparison: calls comparison routine "isEqualArray" (taken from PHP docs)

rule [lessEqual.-array]: 	
	<k> lessEqual(L1:Loc, L2:Loc) => *or('Less(L1,, L2), 'IsEqual(L1,, L2)) ... </k>
	<heap> 
	... 
		L1 |-> zval(V1:Array,_,_,_)
		L2 |-> zval(V2:Array,_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("lessEqual.-array") </trace>
	[internal]

// Object comparison. 

// --- if the objects has same class, they are compared as arrays

rule [lessEqual-obj-same-class]: 	
	<k> lessEqual((L1:Loc => L3), (L2:Loc => L4)) ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class,_),_,_,_)
		L2 |-> zval(OID(L4,Class,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("lessEqual-obj-same-class") </trace>
	[internal]

// --- If the two objects has different classes, the comparison is false

rule [lessEqual-obj-diff-class]: 	
	<k> lessEqual(L1:Loc, L2:Loc) => false ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class1,_),_,_,_)
		L2 |-> zval(OID(L4,Class2,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("lessEqual-obj-diff-class") </trace>
	when Class1 =/=K Class2
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Greater then or equal} */
// ---------------------------------------------------------------------------------------------

syntax K ::= "greaterEqual" "(" K "," K ")"

rule [greaterEqual-int]:
	<k> greaterEqual(I1:Int, I2:Int) => I1 >=Int I2 ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-int") </trace>
	[internal]

rule [greaterEqual-float]:
	<k> greaterEqual(F1:Float, F2:Float) => F1 >=Float F2 ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-float") </trace>
	[internal]

rule [greaterEqual-bool-1]:
	<k> greaterEqual(true, true) => true ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-bool-1") </trace>
	[internal]

rule [greaterEqual-bool-2]:
	<k> greaterEqual(true, false) => true ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-bool-2") </trace>
	[internal]

rule [greaterEqual-bool-3]:
	<k> greaterEqual(false, true) => false ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-bool-3") </trace>
	[internal]

rule [greaterEqual-bool-4]:
	<k> greaterEqual(false, false) => true ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-bool-4") </trace>
	[internal]

rule [greaterEqual-string]:
	<k> greaterEqual(S1:String, S2:String) => S1 >=String S2 ... </k>
	<trace> Trace:List => Trace ListItem("greaterEqual-string") </trace>
	[internal]

// Array comparison: calls comparison routine "isEqualArray" (taken from PHP docs)

rule [greaterEqual-array]: 	
	<k> greaterEqual(L1:Loc, L2:Loc) => *or(greater(L1, L2), isEqual(L1, L2)) ... </k>
	<heap> 
	... 
		L1 |-> zval(V1:Array,_,_,_)
		L2 |-> zval(V2:Array,_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greaterEqual-array") </trace>
	[internal]

// Object comparison. 

// --- if the objects has same class, they are compared as arrays

rule [greaterEqual-obj-same-class]:
	<k> greaterEqual((L1:Loc => L3),(L2:Loc => L4)) ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class,_),_,_,_)
		L2 |-> zval(OID(L4,Class,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greaterEqual-obj-same-class") </trace>
	[internal]

// --- If the two objects has different classes, the comparison is false

rule [greaterEqual-obj-diff-class]:
	<k> greaterEqual(L1:Loc, L2:Loc) => false ... </k>
	<heap> 
	... 
		L1 |-> zval(OID(L3,Class1,_),_,_,_)
		L2 |-> zval(OID(L4,Class2,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("greaterEqual-obj-diff-class") </trace>
	when Class1 =/=K Class2
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Strict Inequality} 
		$a !== $b	Not identical	TRUE if $a is not equal to $b, 
		or they are not of the same type.*/
// ---------------------------------------------------------------------------------------------

rule [isNotIdentical]: 
	<k> 'IsNotIdentical(A:K,,B:K) => 'Not('IsIdentical(A,,B)) ... </k>
	<trace> Trace:List => Trace ListItem("isNotIdentical") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Inequality} 
		$a != $b or $a <> $b 	Not equal	TRUE if $a is not equal to $b after type juggling.*/
// ---------------------------------------------------------------------------------------------

rule [isNotEqual]: 
	<k> 'IsNotEqual(A:K,, B:K) => 'Not('IsEqual(A,, B)) ... </k>
	<trace> Trace:List => Trace ListItem("isNotEqual") </trace>
	[structural]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Logic operators} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{And} */
// ---------------------------------------------------------------------------------------------

context 'And(HOLE,, _:K)

rule [and-LHS2LangValue]:
	<k> 'And((R:Ref => convertToLanguageValue(R)),, B:K) ... </k>
	<trace> Trace:List => Trace ListItem("and-LHS2LangValue") </trace>
	[intermediate]

rule [and-LHS2Bool]: 	
	<k> 'And((V:Value => 'BoolCast(V)),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("and-LHS2Bool") </trace>
	when notBool (isBoolType(V))

rule [and-true]:    
	<k> 'And(true,, B:K) => B ... </k>
	<trace> Trace:List => Trace ListItem("and-true") </trace>
	[step]

rule [and-false]:   
	<k> 'And(false,, _:K) => false ... </k>
	<trace> Trace:List => Trace ListItem("and-false") </trace>
	[step]

rule [land]: 
	<k> 'LAnd(A:K,,B:K) => 'And(A,,B) ... </k>
	<trace> Trace:List => Trace ListItem("land") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Or} */
// ---------------------------------------------------------------------------------------------

context 'Or(HOLE,, _:K)

rule [or-LHS2LangValue]:
	<k> 'Or((R:Ref => convertToLanguageValue(R)),, B:K) ... </k>
	<trace> Trace:List => Trace ListItem("or-LHS2LangValue") </trace>
	[step]

rule [or-LHS2Bool]: 	
	<k> 'Or((V:Value => 'BoolCast(V)),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("or-LHS2Bool") </trace>
	when notBool (isBoolType(V))
	[step]

rule [or-true]:
	<k> 'Or(true,, _:K) => true ... </k>
	<trace> Trace:List => Trace ListItem("or-true") </trace>
	[step]

rule [or-false]:    
	<k> 'Or(false,, B:K) => B ... </k>
	<trace> Trace:List => Trace ListItem("or-false") </trace>
	[step]

rule [lor]: 
	<k> 'LOr(A::K,,B::K) => 'Or(A,,B) ... </k>
	<trace> Trace:List => Trace ListItem("lor") </trace>
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Xor} */
// ---------------------------------------------------------------------------------------------

rule [xor]: 
	<k> 'LXor(A:K,,B:K) => 'Or('And(A,, 'Not(B)),,'And('Not(A),, B)) ... </k>
	<trace> Trace:List => Trace ListItem("xor") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Not} */
// ---------------------------------------------------------------------------------------------

context 'Not(HOLE)

rule [not-arg2LangValue]: 
	<k> 'Not(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	<trace> Trace:List => Trace ListItem("not-arg2LangValue") </trace>
	[intermediate]
	
rule [not-arg2Bool]: 
	<k> 'Not(V:LanguageValue => *toBoolean(V)) ... </k>
	<trace> Trace:List => Trace ListItem("not-arg2Bool") </trace>
	when notBool (isBoolType(V))
	[intermediate]

rule [not]: 
	<k> 'Not(B:Bool) => notBool B  ... </k>
	<trace> Trace:List => Trace ListItem("not") </trace>
	[structural]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Increment operators} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

/* post dec */

context 'PostDec(HOLE)

rule [postDecArg2Loc]:    
		<k> 'PostDec(R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("postDecArg2Loc") </trace>
	[intermediate]

rule [postDec]:    
	<k> 'PostDec(L:Loc) => V ... </k>
	<heap> ... L |-> zval(V:Int => V -Int 1, _, _, _) ...  </heap>
	<trace> Trace:List => Trace ListItem("postDec") </trace>
	[step]

/* post inc */

context 'PostInc(HOLE)

rule [postIncArg2Loc]:
	<k> 'PostInc(R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("postIncArg2Loc") </trace>
	[intermediate]

rule [postInc]:
	<k> 'PostInc(L:Loc) => V ... </k>
	<heap> ... L |-> zval(V:Int => V +Int 1, _, _, _) ...  </heap>
	<trace> Trace:List => Trace ListItem("postInc") </trace>
	[step]
        
rule [postInc-null]:
	<k> 'PostInc(L:Loc) => NULL ... </k>
 	<heap> ... L |-> zval(NULL => 1, _, _, _) ...  </heap>
	<trace> Trace:List => Trace ListItem("postInc-null") </trace>
	[step]

/* pre dec */

context 'PreDec(HOLE)

rule [preDec-arg2Loc]:
	<k> 'PreDec(R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("preDec-arg2Loc") </trace>
	[intermediate]

rule [preDec]:    
	<k> 'PreDec(L:Loc) => V -Int 1 ... </k>
	<heap> ... L |-> zval(V:Int => V -Int 1, _, _, _) ...  </heap>
	<trace> Trace:List => Trace ListItem("preDec") </trace>
	[step]

/* pre inc */

context 'PreInc(HOLE)

rule [preInc-arg2Loc]:    
	<k> 'PreInc(R:Ref => convertToLoc(R,r)) ... </k>
	<trace> Trace:List => Trace ListItem("preInc-arg2Loc") </trace>
	[intermediate]

rule [preInc]:    
	<k> 'PreInc(L:Loc) => V +Int 1 ... </k>
	<heap> ... L |-> zval(V:Int => V +Int 1, _, _, _) ...  </heap>
	<trace> Trace:List => Trace ListItem("preInc") </trace>
	[step]
endmodule