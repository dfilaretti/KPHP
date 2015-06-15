require "lattice.k"
module FORWARD-OPS
	imports LATTICE

//@ \section{Operations on reference counters}

	syntax 	ARefCount ::= ARefCount "+ARefCount" ARefCount [function]

	rule	ARC0 +ARefCount ARC0   => ARC0
	rule	ARC0 +ARefCount ARC1   => ARC1
	rule	ARC0 +ARefCount ARC2   => ARC2
	rule	ARC0 +ARefCount ARC>2  => ARC>2

	rule	ARC1 +ARefCount ARC0   => ARC1
	rule	ARC1 +ARefCount ARC1   => ARC2
	rule	ARC1 +ARefCount ARC2   => ARC>2
	rule	ARC1 +ARefCount ARC>2  => ARC>2

	rule	ARC2 +ARefCount ARC0   => ARC2
	rule	ARC2 +ARefCount ARC1   => ARC>2
	rule	ARC2 +ARefCount ARC2   => ARC>2
	rule	ARC2 +ARefCount ARC>2  => ARC>2

	rule	ARC>2 +ARefCount ARC0  => ARC>2
	rule	ARC>2 +ARefCount ARC1  => ARC>2
	rule	ARC>2 +ARefCount ARC2  => ARC>2
	rule	ARC>2 +ARefCount ARC>2 => ARC>2

	syntax 	ARefCount ::= ARefCount "-ARefCount" ARefCount [function] 

	rule	ARC0 -ARefCount ARC0   => ARC0
	//rule	ARC0 -ARefCount ARC1   => ARC1
	//rule	ARC0 -ARefCount ARC2   => ARC2
	//rule	ARC0 -ARefCount ARC>2  => ARC>2

	rule	ARC1 -ARefCount ARC0   => ARC1
	rule	ARC1 -ARefCount ARC1   => ARC0
	//rule	ARC1 -ARefCount ARC2   => ARC>2
	//rule	ARC1 -ARefCount ARC>2  => ARC>2

	rule	ARC2 -ARefCount ARC0   => ARC2
	rule	ARC2 -ARefCount ARC1   => ARC1
	rule	ARC2 -ARefCount ARC2   => ARC0
	//rule	ARC2 -ARefCount ARC>2  => ARC>2

	rule	ARC>2 -ARefCount ARC0  => ARC>2
	rule	ARC>2 -ARefCount ARC1  => ARC>2
	rule	ARC>2 -ARefCount ARC2  => ARC>2
	rule	ARC>2 -ARefCount ARC>2 => ARC>2
	

	syntax 	Bool ::= ARefCount "<ARefCount" ARefCount [function] 

	rule	ARC0 <ARefCount ARC0   => false
	rule	ARC0 <ARefCount ARC1   => true
	rule	ARC0 <ARefCount ARC2   => true
	rule	ARC0 <ARefCount ARC>2  => true

	rule	ARC1 <ARefCount ARC0   => false
	rule	ARC1 <ARefCount ARC1   => false
	rule	ARC1 <ARefCount ARC2   => true
	rule	ARC1 <ARefCount ARC>2  => true

	rule	ARC2 <ARefCount ARC0   => false
	rule	ARC2 <ARefCount ARC1   => false
	rule	ARC2 <ARefCount ARC2   => false
	rule	ARC2 <ARefCount ARC>2  => true

	rule	ARC>2 <ARefCount ARC0  => false
	rule	ARC>2 <ARefCount ARC1  => false
	rule	ARC>2 <ARefCount ARC2  => false
	rule	ARC>2 <ARefCount ARC>2 => false // ?!?





//@ \section{Arithmetic operations}

	// Plus
	syntax  AInt ::= AInt "+AInt" AInt	[function]	

	rule 	AIntBot +AInt AIntBot			=> AIntBot
	rule 	AIntBot +AInt AIntNeg 			=> AIntBot
	rule 	AIntBot +AInt AIntZero 			=> AIntBot
	rule 	AIntBot +AInt AIntPos 			=> AIntBot
	rule 	AIntBot +AInt AIntTop 			=> AIntBot
	
	rule 	AIntTop +AInt AIntBot 			=> AIntBot
	rule 	AIntTop +AInt AIntNeg 			=> AIntTop
	rule 	AIntTop +AInt AIntZero 			=> AIntTop
	rule 	AIntTop +AInt AIntPos 			=> AIntTop
	rule 	AIntTop +AInt AIntTop 			=> AIntTop
	
	rule 	AIntNeg +AInt AIntBot 			=> AIntBot
	rule 	AIntNeg +AInt AIntNeg 			=> AIntNeg
	rule 	AIntNeg +AInt AIntZero 			=> AIntNeg
	rule 	AIntNeg +AInt AIntPos 			=> AIntTop
	rule 	AIntNeg +AInt AIntTop 			=> AIntTop

	rule 	AIntZero +AInt AIntBot 			=> AIntBot
	rule 	AIntZero +AInt AIntNeg 			=> AIntNeg
	rule 	AIntZero +AInt AIntZero 		=> AIntZero
	rule 	AIntZero +AInt AIntPos 			=> AIntPos
	rule 	AIntZero +AInt AIntTop 			=> AIntTop

	rule 	AIntPos +AInt AIntBot 			=> AIntBot
	rule 	AIntPos +AInt AIntNeg 			=> AIntTop
	rule 	AIntPos +AInt AIntZero 			=> AIntPos
	rule 	AIntPos +AInt AIntPos 			=> AIntPos
	rule 	AIntPos +AInt AIntTop 			=> AIntTop

	syntax  AFloat ::= AFloat "+AFloat" AFloat	[function]
   
	rule 	AFloatBot +AFloat AFloatBot		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatNeg 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatZero 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatPos 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatTop 		=> AFloatBot
	
	rule 	AFloatTop +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatTop +AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatZero 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatTop 		=> AFloatTop
	
	rule 	AFloatNeg +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatNeg +AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatNeg +AFloat AFloatZero 		=> AFloatNeg
	rule 	AFloatNeg +AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatNeg +AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatZero +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatZero +AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatZero +AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatZero +AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatZero +AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatPos +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatPos +AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatPos +AFloat AFloatZero 		=> AFloatPos
	rule 	AFloatPos +AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatPos +AFloat AFloatTop 		=> AFloatTop
  
	// Min
	syntax  AInt ::= AInt "-AInt" AInt	[function]	
    
	syntax  AFloat ::= AFloat "-AFloat" AFloat	[function]

	// Mul
	syntax  AInt ::= AInt "*AInt" AInt	[function]	

    	rule 	AIntBot *AInt AIntBot			=> AIntBot
	rule 	AIntBot *AInt AIntNeg 			=> AIntBot
	rule 	AIntBot *AInt AIntZero 			=> AIntBot
	rule 	AIntBot *AInt AIntPos 			=> AIntBot
	rule 	AIntBot *AInt AIntTop 			=> AIntBot
	
	rule 	AIntTop *AInt AIntBot 			=> AIntBot
	rule 	AIntTop *AInt AIntNeg 			=> AIntTop
	rule 	AIntTop *AInt AIntZero 			=> AIntZero
	rule 	AIntTop *AInt AIntPos 			=> AIntTop
	rule 	AIntTop *AInt AIntTop 			=> AIntTop
	
	rule 	AIntNeg *AInt AIntBot 			=> AIntBot
	rule 	AIntNeg *AInt AIntNeg 			=> AIntPos
	rule 	AIntNeg *AInt AIntZero 			=> AIntZero
	rule 	AIntNeg *AInt AIntPos 			=> AIntNeg
	rule 	AIntNeg *AInt AIntTop 			=> AIntTop

	rule 	AIntZero *AInt AIntBot 			=> AIntBot
	rule 	AIntZero *AInt AIntNeg 			=> AIntZero
	rule 	AIntZero *AInt AIntZero 		=> AIntZero
	rule 	AIntZero *AInt AIntPos 			=> AIntZero
	rule 	AIntZero *AInt AIntTop 			=> AIntZero

	rule 	AIntPos *AInt AIntBot 			=> AIntBot
	rule 	AIntPos *AInt AIntNeg 			=> AIntNeg
	rule 	AIntPos *AInt AIntZero 			=> AIntZero
	rule 	AIntPos *AInt AIntPos 			=> AIntPos
	rule 	AIntPos *AInt AIntTop 			=> AIntTop


	syntax  AFloat ::= AFloat "*AFloat" AFloat	[function]

    	rule 	AFloatBot *AFloat AFloatBot		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatNeg 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatZero 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatPos 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatTop 		=> AFloatBot
	
	rule 	AFloatTop *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatTop *AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatTop *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatTop *AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatTop *AFloat AFloatTop 		=> AFloatTop
	
	rule 	AFloatNeg *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatNeg *AFloat AFloatNeg 		=> AFloatPos
	rule 	AFloatNeg *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatNeg *AFloat AFloatPos 		=> AFloatNeg
	rule 	AFloatNeg *AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatZero *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatZero *AFloat AFloatNeg 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatPos 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatTop 		=> AFloatZero

	rule 	AFloatPos *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatPos *AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatPos *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatPos *AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatPos *AFloat AFloatTop 		=> AFloatTop

	// Div (TODO) 

    // Mod (TODO) 

	syntax 	AInt ::= "negative_AInt" "(" AInt ")" [function]
	rule	negative_AInt(AIntBot) 	=> AIntBot
	rule	negative_AInt(AIntPos) 	=> AIntNeg
	rule	negative_AInt(AIntZero) => AIntZero
	rule	negative_AInt(AIntNeg) 	=> AIntPos
	rule	negative_AInt(AIntTop) 	=> AIntTop
	
	syntax 	AFloat ::= "negative_AFloat" "(" AFloat ")" [function]
	rule	negative_AFloat(AFloatBot) 	=> AFloatBot
	rule	negative_AFloat(AFloatPos) 	=> AFloatNeg
	rule	negative_AFloat(AFloatZero) 	=> AFloatZero
	rule	negative_AFloat(AFloatNeg) 	=> AFloatPos
	rule	negative_AFloat(AFloatTop) 	=> AFloatTop
	





//@ \section{Type conversion primitives}


syntax K ::= "*toString" "(" LanguageValue ")"  

rule	*toString(_) => AStringTop
// TODO: define!!!

/*
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
*/


    // to boolean
    syntax  K ::= "*toBoolean" "(" LanguageValue ")" [strict]

    rule    [toBoolean-bool]:    
	        <k> *toBoolean(B:ABool) => B ... </k>
	        [internal]
	
    rule    [toBoolean-int-zero]:
	        <k> *toBoolean(AIntZero) => ABoolFalse ... </k>
	        [internal]

    rule    [toBoolean-int]:
	        <k> *toBoolean(N:AInt) => ABoolTrue ... </k>
	        when (N =/=K AIntZero)
	        [internal]

    rule    [toBoolean-float-zero]:
	        <k> *toBoolean(AFloatZero) => ABoolFalse ... </k>
	        [internal]

    rule    [toBoolean-float]:    
	        <k> *toBoolean(F:AFloat) => ABoolTrue ... </k>
	        when (F =/=K AFloatZero)
	        [internal]

    rule    [toBoolean-empty-string]:    
	        <k> *toBoolean("") => ABoolFalse ... </k>
	        [internal]

    rule    [toBoolean-string-zero]:    
	        <k> *toBoolean("0") => ABoolFalse ... </k>
	        [internal]

    rule    [toBoolean-string]:    
	        <k> *toBoolean(S:String) => ABoolTrue ... </k>
	        when notBool ((S ==String "") orBool (S ==String "0"))
	        [internal]

    rule    [toBoolean-string]:    
	        <k> *toBoolean(AStringTop) => ABoolTop ... </k>
	        [internal]

    rule    [toBoolean-empty-array]:    
	        <k> *toBoolean(Array(_,Elems)) => ABoolFalse ... </k>
	        when (Elems ==List .List)
	        [internal]

    rule    [toBoolean-non-empty-array]:    
	        <k> *toBoolean(Array(_,Elems)) => ABoolTrue ... </k>  
	        when (notBool (Elems ==List .List))
	        [internal]

// Object case: we add it, even if the online docs says this behaviour is "PHP 4 only"
// Since the expected behaviour for PHP 5 is not mentioned, I guess it is undefined..?

    rule    [toBoolean-object]:    
	        <k> *toBoolean(OID(L,_,_) => convertToLanguageValue(L)) ... </k>  
	        [internal]

    rule    [toBoolean-null]:        
	        <k> *toBoolean(NULL) => ABoolFalse ... </k>
	        [internal]

    // to float
    syntax  K ::= "*toFloat" "(" LanguageValue ")"  [strict]

    rule    [toFloat-false]:
	        <k> *toFloat(BFalse) => 'DNumber("0.0") ... </k>
	        [internal]
	
    rule    [toFloat-true]:
	        <k> *toFloat(BTrue) => 'DNumber("1.0") ... </k>
	        [internal]

    rule    [toFloat-int]:
	        <k> *toFloat(I:AInt) => AFloatTop ... </k> // TODO: fix!
	        [internal]

    rule    [toFloat-float]:
	        <k> *toFloat(F:AFloat) => F ... </k>
	        [internal]

    rule    [toFloat-string]:
	        <k> *toFloat(S:String) => *toFloat(string2Number(S)) ... </k>
	        [internal]
	
    rule    [toFloat-compound]:	
	        <k> *toFloat(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> 1.0 ... </k>
	        [internal, error]

//@ \section{Logical ops}

    syntax  ABool ::= "notABool" ABool [function]

    rule    notABool ABoolTrue => ABoolFalse
    rule    notABool ABoolFalse => ABoolTrue
    rule    notABool ABoolBot => ABoolBot
    rule    notABool ABoolTop => ABoolTop

//@ \section{Comparisons}




    syntax  ABool ::= AInt "==AInt" AInt

    rule    AIntBot ==AInt AIntBot         => ABoolBot
    rule    AIntBot ==AInt  AIntNeg        => ABoolBot
    rule    AIntBot ==AInt  AIntZero       => ABoolBot
    rule    AIntBot ==AInt  AIntPos        => ABoolBot
    rule    AIntBot ==AInt  AIntTop        => ABoolBot

    rule    AIntNeg ==AInt  AIntBot        => ABoolBot
    rule    AIntNeg ==AInt  AIntNeg        => ABoolTop
    rule    AIntNeg ==AInt  AIntZero       => ABoolFalse
    rule    AIntNeg ==AInt  AIntPos        => ABoolFalse
    rule    AIntNeg ==AInt AIntTop         => ABoolTop
    
    rule    AIntZero ==AInt  AIntBot       => ABoolBot
    rule    AIntZero ==AInt  AIntNeg       => ABoolFalse
    rule    AIntZero ==AInt  AIntZero      => ABoolTrue
    rule    AIntZero ==AInt  AIntPos       => ABoolFalse
    rule    AIntZero ==AInt  AIntTop       => ABoolTop

    rule    AIntPos ==AInt  AIntBot        => ABoolBot
    rule    AIntPos ==AInt AIntNeg         => ABoolFalse
    rule    AIntPos ==AInt  AIntZero       => ABoolFalse
    rule    AIntPos ==AInt  AIntPos        => ABoolTop
    rule    AIntPos ==AInt  AIntTop        => ABoolTop
    
    rule    AIntTop ==AInt  AIntBot        => ABoolBot
    rule    AIntTop ==AInt  AIntNeg        => ABoolTop
    rule    AIntTop ==AInt  AIntZero       => ABoolTop
    rule    AIntTop ==AInt  AIntPos        => ABoolTop
    rule    AIntTop ==AInt  AIntTop        => ABoolTop


    syntax  ABool ::= AFloat "==AFloat" AFloat
    // TODO
    syntax  ABool ::= ABool "==ABool" ABool
    // TODO
    syntax  ABool ::= AString "==AString" AString
    // TODO

//@ \section{Input and output}

    // output
    syntax  K ::= "print" "(" K ")"
    
rule    [internal-print]:
            <k> print (V:String)  => . ... </k>
            <out> ... . => ListItem(V) </out>
            [internal, output]   

    // input
    syntax K ::= "user_input"
	
    rule [input]:
    	<k>  user_input => AStringTop ...</k>

endmodule
