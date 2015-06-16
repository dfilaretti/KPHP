require "lattice.k"
module FORWARD-OPS
	imports LATTICE


//@ \section{Reference counter operations}

syntax  ARefCount ::= ARefCount "+ARefCount" ARefCount [function]
rule    R1 +ARefCount R2 => R1 +Int R2 

syntax  ARefCount ::= ARefCount "-ARefCount" ARefCount [function]
rule    R1 -ARefCount R2 => R1 -Int R2 

syntax  Bool ::= ARefCount "<ARefCount" ARefCount [function]
rule    R1 <ARefCount R2 => R1 <Int R2 


//@ \section{Arithmetic operations}

	// Plus
syntax  AInt ::= AInt "+AInt" AInt	[function]	
rule    I1:Int +AInt I2:Int => I1 +Int I2

syntax  AFloat ::= AFloat "+AFloat" AFloat	[function]
rule    F1:Float +AFloat F2:Float => F1 +Float F2
 
	// Min TODO: not user??
syntax  AInt ::= AInt "-AInt" AInt	[function]	
rule    I1:Int -AInt I2:Int => I1 -Int I2

syntax  AFloat ::= AFloat "-AFloat" AFloat	[function]
rule    F1:Float -AFloat F2:Float => F1 -Float F2

	// Mul
syntax  AInt ::= AInt "*AInt" AInt	[function]	
rule    I1:Int *AInt I2:Int => I1 *Int I2

syntax  AFloat ::= AFloat "*AFloat" AFloat	[function]
rule    F1:Float *AFloat F2:Float => F1 *Float F2

	// Div (TODO) 

    // Mod (TODO) 
syntax 	AInt ::= "negative_AInt" "(" AInt ")" [function]
rule	negative_AInt(X) => 0 -Int X

syntax 	AFloat ::= "negative_AFloat" "(" AFloat ")" [function]
rule	negative_AFloat(X) => 0.0 -Float X



//@ \section{Type conversion primitives}

syntax K ::= "*toString" "(" LanguageValue ")"  

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
	
rule [toString-object]:   
	<k> *toString(Obj:Object) => ERROR("Object of class %s could not be converted to string in %s on line %d") ... </k>
	<trace> Trace:List => Trace ListItem("toString-array") </trace>
	[internal, error]

rule [toString-null]:   
	<k> *toString(NULL) => "" ... </k>
	<trace> Trace:List => Trace ListItem("toString-null") </trace>
	[internal]


// to boolean
syntax K ::= "*toBoolean" "(" LanguageValue ")" [strict]

rule [toBoolean-bool]:    
	<k> *toBoolean(B:Bool) => B ... </k>
	[internal]
	
rule [toBoolean-int-zero]:
	<k> *toBoolean(0) => false ... </k>
	[internal]

rule [toBoolean-int]:
	<k> *toBoolean(N:Int) => true ... </k>
	when notBool (N ==Int 0)
	[internal]

rule [toBoolean-float-zero]:
	<k> *toBoolean(F:Float) => false ... </k>
	when (F ==Float 0.0)
	[internal]

rule [toBoolean-float]:    
	<k> *toBoolean(F:Float) => true ... </k>
	when notBool (F ==Float 0.0)
	[internal]

rule [toBoolean-empty-string]:    
	<k> *toBoolean("") => false ... </k>
	[internal]

rule [toBoolean-string-zero]:    
	<k> *toBoolean("0") => false ... </k>
	[internal]

rule [toBoolean-string]:    
	<k> *toBoolean(S:String) => true ... </k>
	when notBool ((S ==String "") orBool (S ==String "0"))
	[internal]

rule [toBoolean-empty-array]:    
	<k> *toBoolean(Array(_,Elems)) => false ... </k>
	when (Elems ==List .List)
	[internal]

rule [toBoolean-non-empty-array]:    
	<k> *toBoolean(Array(_,Elems)) => true ... </k>  
	when (notBool (Elems ==List .List))
	[internal]

// Object case: we add it, even if the online docs says this behaviour is "PHP 4 only"
// Since the expected behaviour for PHP 5 is not mentioned, I guess it is undefined..?

rule [toBoolean-object]:    
	<k> *toBoolean(OID(L,_,_) => convertToLanguageValue(L)) ... </k>  
	[internal]

rule [toBoolean-null]:        
	<k> *toBoolean(NULL) => false ... </k>
	[internal]

// to float
syntax K ::= "*toFloat" "(" LanguageValue ")"  [strict]

rule [toFloat-false]:
	<k> *toFloat(false) => 'DNumber("0.0") ... </k>
	[internal]
	
rule [toFloat-true]:
	<k> *toFloat(true) => 'DNumber("1.0") ... </k>
	[internal]

rule [toFloat-int]:
	<k> *toFloat(I:Int) => Int2Float(I) ... </k>
	[internal]

rule [toFloat-float]:
	<k> *toFloat(F:Float) => F ... </k>
	[internal]

rule [toFloat-string]:
	<k> *toFloat(S:String) => *toFloat(string2Number(S)) ... </k>
	[internal]
	
rule [toFloat-compound]:	
	<k> *toFloat(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> 1.0 ... </k>
	<trace> Trace:List => Trace ListItem("toFloat-compound") </trace>
	[internal, error]

//@ \section{Logic operations}

syntax  ABool ::= "notABool" ABool

rule    notABool B:Bool => notBool B

//@ \section{Comparisons}

syntax  ABool ::= AInt "==AInt" AInt
rule    I1:Int ==AInt I2:Int => I1 ==Int I2


syntax  ABool ::= AFloat "==AFloat" AFloat
// TODO
syntax  ABool ::= ABool "==ABool" ABool
// TODO
syntax  ABool ::= AString "==AString" AString

//@ \section{Input and output}

// basic output
syntax  K ::= "print" "(" K ")"     [strict]

rule    [internal-print]:    
	    <k> print (V:Float => Float2Int(V))  ... </k>
//	    when (hasNoDecimalPart(V))
	    [internal, output]
	
rule    [internal-print]:    
	    <k> print (V:Float => *toString(V))  ... </k> 
//	    when notBool (hasNoDecimalPart(V))
	    [internal, output]
	
rule    [internal-print]:    
	    <k> print (V:LanguageValue => *toString(V))  ... </k> 
	    when notBool(isFloatType(V) orBool isStringType(V))
	    [internal, output]

rule    [internal-print]:    
	    <k> print (V:String)  => . ... </k>
	    <out> ... . => ListItem(V) </out>  
	    [internal, output]


// input 
syntax K ::= "user_input"
	
rule    [input]:
        <k> user_input => V ...</k>
	    <in> ListItem(V:K) => . ...</in>







endmodule
