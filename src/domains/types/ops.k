require "lattice.k"
require "../../lang/arith-ops.k"
module OPS
       imports LATTICE
	   imports ARITH-OPS
	   imports INIT
	   
	   
	   syntax K ::= "stopDebug"
	   
	   // Domain value manipulation
	   
	   syntax AIntValue ::= "AIntOfErr" "(" ErrFlag ")" [function]
	   
	   rule AIntOfErr(E) => *valueToInteger(valueOfErr(E)) //Always AInt in this domain, but useful to make a library at some point
	   
	   syntax AIntValue ::= "AIntOfErrs" "(" List ")" [function]
	   
	   rule AIntOfErrs(.List) => Bot
	   
	   rule AIntOfErrs( ListItem(E)  L) =>  lub_Value(AIntOfErr(E), AIntOfErrs(L))
	   
	   syntax AIntValue ::= "AIntOfTuple" "(" DomainValue ")" [function]
	   
	   rule AIntOfTuple(NULL) => AInt
	   rule AIntOfTuple( (V, E):AInt ) => lub_Value(*valueToInteger(V), AIntOfErrs(E)) 
	   rule AIntOfTuple( (V, E):AFloat ) => lub_Value(*valueToInteger(V), AIntOfErrs(E)) 
	   rule AIntOfTuple( (V, E):AString) => lub_Value(*valueToInteger(V), AIntOfErrs(E)) 
	   rule AIntOfTuple( (V, E):ABool) => lub_Value(*valueToInteger(V), AIntOfErrs(E)) 
	   
	   syntax AFloatValue ::= "AFloatOfErr" "(" ErrFlag ")" [function]
	   
	   rule AFloatOfErr(E) => *valueToFloat(valueOfErr(E)) 
	   
	   syntax AFloatValue ::= "AFloatOfErrs" "(" List ")" [function]
	   
	   rule AFloatOfErrs(.List) => Bot
	   
	   rule AFloatOfErrs( ListItem(E)  L) =>  lub_Value(AFloatOfErr(E), AFloatOfErrs(L))
	   
	   syntax AFloatValue ::= "AFloatOfTuple" "(" DomainValue ")" [function]
	   
	   rule AFloatOfTuple(NULL) => AFloat
	   rule AFloatOfTuple( (V, E):AInt ) => lub_Value(*valueToFloat(V), AFloatOfErrs(E)) 
	   rule AFloatOfTuple( (V, E):AFloat ) => lub_Value(*valueToFloat(V), AFloatOfErrs(E)) 
	   rule AFloatOfTuple( (V, E):AString ) => lub_Value(*valueToFloat(V), AFloatOfErrs(E)) 
	   rule AFloatOfTuple( (V, E):ABool ) => lub_Value(*valueToFloat(V), AFloatOfErrs(E)) 
	   
	   syntax AStringValue ::= "AStringOfErr" "(" ErrFlag ")" [function]
	   
	   rule AStringOfErr(E) => *valueToString(valueOfErr(E)) 
	   
	   syntax AStringValue ::= "AStringOfErrs" "(" List ")" [function]
	   
	   rule AStringOfErrs(.List) => Bot
	   
	   rule AStringOfErrs( ListItem(E)  L) =>  lub_Value(AStringOfErr(E), AStringOfErrs(L))
	   
	   syntax AStringValue ::= "AStringOfTuple" "(" K ")" [function]
	 
	   rule AStringOfTuple(NULL) => ""
	   rule AStringOfTuple( (V, E):AInt ) => lub_Value(*valueToString(V), AStringOfErrs(E)) 
	   rule AStringOfTuple( (V, E):AFloat ) => lub_Value(*valueToString(V), AStringOfErrs(E)) 
	   rule AStringOfTuple( (V, E):AString ) => lub_Value(*valueToString(V), AStringOfErrs(E)) 
	   rule AStringOfTuple( (V, E):ABool ) => lub_Value(*valueToString(V), AStringOfErrs(E)) 
	   
	   syntax ABoolValue ::= "ABoolOfErr" "(" ErrFlag ")" [function]
	   
	   rule ABoolOfErr(E) => *valueToBool(valueOfErr(E)) 
	   
	   syntax ABoolValue ::= "ABoolOfErrs" "(" List ")" [function]
	   
	   rule ABoolOfErrs(.List) => Bot
	   
	   rule ABoolOfErrs( ListItem(E)  L) =>  lub_Value(ABoolOfErr(E), ABoolOfErrs(L))
	   
	   syntax ABoolValue ::= "ABoolOfTuple" "(" DomainValue ")" [function]
	   
	   rule ABoolOfTuple(NULL) => ABool
	   rule ABoolOfTuple( (V, E):AInt ) => lub_Value(*valueToBool(V), ABoolOfErrs(E)) 
	   rule ABoolOfTuple( (V, E):AFloat ) => lub_Value(*valueToBool(V), ABoolOfErrs(E)) 
	   rule ABoolOfTuple( (V, E):AString ) => lub_Value(*valueToBool(V), ABoolOfErrs(E)) 
	   rule ABoolOfTuple( (V, E):ABool ) => lub_Value(*valueToBool(V), ABoolOfErrs(E)) 
	   
	   // Domain operations
	   
       syntax AIntValue ::= AIntValue "+AIntValue" AIntValue [function]
       syntax AIntValue ::= AIntValue "-AIntValue" AIntValue [function]
       syntax AIntValue ::= AIntValue "*AIntValue" AIntValue [function]
       syntax AIntValue ::= AIntValue "/AIntValue" AIntValue [function]
       syntax AIntValue ::= AIntValue "modAIntValue" AIntValue [function]
       syntax AIntValue ::= "negative_AIntValue" "(" AIntValue ")" [function]       

	   rule AInt +AIntValue AInt => AInt
       rule AInt -AIntValue AInt => AInt
       rule AInt *AIntValue AInt => AInt
       rule AInt /AIntValue AInt => AInt
       rule AInt modAIntValue AInt => AInt
       rule negative_AIntValue(AInt) => AInt
	   
	   
	   //TODO : move syntax decls to lang ? (required for any domain)
	   
	   syntax AInt ::= AInt "+AInt" AInt [function]
       syntax AInt ::= AInt "-AInt" AInt [function]
       syntax AInt ::= AInt "*AInt" AInt [function]
       syntax AInt ::= AInt "/AInt" AInt [function]
       syntax AInt ::= AInt "modAInt" AInt [function]
       syntax AInt ::= "negative_AInt" "(" AInt ")" [function]       
	   
	   rule (V1, E1) +AInt (V2, E2) => (AIntOfTuple( (V1, E1) ) +AIntValue AIntOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) -AInt (V2, E2) => (AIntOfTuple( (V1, E1) ) -AIntValue AIntOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) *AInt (V2, E2) => (AIntOfTuple( (V1, E1) ) *AIntValue AIntOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) /AInt (V2, E2) => (AIntOfTuple( (V1, E1) ) /AIntValue AIntOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) modAInt (V2, E2) => (AIntOfTuple( (V1, E1) ) modAIntValue AIntOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule negative_AInt((V1, E1)) => (negative_AIntValue(AIntOfTuple((V1, E1))), FilterErrFlags(E1))
       

	   syntax AFloatValue ::= AFloatValue "+AFloatValue" AFloatValue	[function]
       syntax AFloatValue ::= AFloatValue "-AFloatValue" AFloatValue [function]
       syntax AFloatValue ::= AFloatValue "*AFloatValue" AFloatValue [function]
       syntax AFloatValue ::= AFloatValue "/AFloatValue" AFloatValue [function]
       syntax AFloatValue ::= "negative_AFloatValue" "(" AFloatValue ")" [function]
	   
       syntax AFloat ::= AFloat "+AFloat" AFloat	[function]
       syntax AFloat ::= AFloat "-AFloat" AFloat [function]
       syntax AFloat ::= AFloat "*AFloat" AFloat [function]
       syntax AFloat ::= AFloat "/AFloat" AFloat [function]
       syntax AFloat ::= "negative_AFloat" "(" AFloat ")" [function]

       rule  AFloat +AFloatValue AFloat => AFloat
       rule  AFloat -AFloatValue AFloat => AFloat
       rule  AFloat *AFloatValue AFloat => AFloat
       rule  AFloat /AFloatValue AFloat => AFloat
       rule negative_AFloatValue(AFloat) => AFloat

	   
	   rule (V1, E1) +AFloat (V2, E2) => (AFloatOfTuple( (V1, E1) ) +AFloatValue AFloatOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) -AFloat (V2, E2) => (AFloatOfTuple( (V1, E1) ) -AFloatValue AFloatOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) *AFloat (V2, E2) => (AFloatOfTuple( (V1, E1) ) *AFloatValue AFloatOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule (V1, E1) /AFloat (V2, E2) => (AFloatOfTuple( (V1, E1) ) /AFloatValue AFloatOfTuple( (V2, E2) ), mergeList(FilterErrFlags(E1), FilterErrFlags(E2)) )
	   rule negative_AFloat((V1, E1)) => (negative_AFloatValue(AFloatOfTuple((V1, E1))), FilterErrFlags(E1))
	   
	   
	   rule [greater-aint]:
	   <k> greater(I1:AInt, I2:AInt) => (ABool, mergeList(FilterErrFlags(getErrFlags(I1)), FilterErrFlags(getErrFlags(I2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greater-aint") </trace>
	   [internal]
		
	   rule [greater-afloat]:
	   <k> greater(F1:AFloat, F2:AFloat) => (ABool, mergeList(FilterErrFlags(getErrFlags(F1)), FilterErrFlags(getErrFlags(F2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greater-afloat") </trace>
	   [internal]
	
	   rule [greater-abool]:
	   <k> greater(B1:ABool, B2:ABool) => (ABool, mergeList(FilterErrFlags(getErrFlags(B1)), FilterErrFlags(getErrFlags(B2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greater-abool") </trace>
	   [internal]
	   
	   rule [greater-astring]:
	   <k> greater(S1:AString, S2:AString) => (ABool, mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greater-astring") </trace>
	   [internal]
	   
	   rule [less-aint]:
	   <k> less(I1:AInt, I2:AInt) => (ABool, mergeList(FilterErrFlags(getErrFlags(I1)), FilterErrFlags(getErrFlags(I2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("less-aint") </trace>
	   [internal]
		
	   rule [less-afloat]:
	   <k> less(F1:AFloat, F2:AFloat) => (ABool, mergeList(FilterErrFlags(getErrFlags(F1)), FilterErrFlags(getErrFlags(F2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("less-afloat") </trace>
	   [internal]
	
	   rule [less-abool]:
	   <k> less(B1:ABool, B2:ABool) => (ABool, mergeList(FilterErrFlags(getErrFlags(B1)), FilterErrFlags(getErrFlags(B2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("less-abool") </trace>
	   [internal]
	   
	   rule [less-astring]:
	   <k> less(S1:AString, S2:AString) => (ABool, mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("less-astring") </trace>
	   [internal]
	   
	   syntax K ::= "greaterEqual" "(" K "," K ")"

	   rule [greaterEqual-aint]:
	   <k> greaterEqual(I1:AInt, I2:AInt) => (ABool, mergeList(FilterErrFlags(getErrFlags(I1)), FilterErrFlags(getErrFlags(I2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-aint") </trace>
	   [internal]

	   rule [greaterEqual-afloat]:
	   <k> greaterEqual(F1:AFloat, F2:AFloat) => (ABool, mergeList(FilterErrFlags(getErrFlags(F1)), FilterErrFlags(getErrFlags(F2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-afloat") </trace>
	   [internal]

	   rule [greaterEqual-abool]:
	   <k> greaterEqual(B1:ABool, B2:ABool) => (ABool, mergeList(FilterErrFlags(getErrFlags(B1)), FilterErrFlags(getErrFlags(B2))))... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-abool") </trace>
	   [internal]
	   
	   rule [greaterEqual-astring]:
	   <k> greaterEqual(S1:AString, S2:AString) => (ABool, mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-astring") </trace>
	   [internal]
 
	   syntax K ::= "lessEqual" "(" K "," K ")"

	   rule [lessEqual-aint]:
	   <k> lessEqual(I1:AInt, I2:AInt) => (ABool, mergeList(FilterErrFlags(getErrFlags(I1)), FilterErrFlags(getErrFlags(I2))))... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-aint") </trace>
	   [internal]

	   rule [lessEqual-afloat]:
	   <k> lessEqual(F1:AFloat, F2:AFloat) => (ABool, mergeList(FilterErrFlags(getErrFlags(F1)), FilterErrFlags(getErrFlags(F2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-afloat") </trace>
	   [internal]

	   rule [lessEqual-abool]:
	   <k> lessEqual(B1:ABool, B2:ABool) =>(ABool, mergeList(FilterErrFlags(getErrFlags(B1)), FilterErrFlags(getErrFlags(B2))))... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-abool") </trace>
	   [internal]
	   
	   rule [lessEqual-astring]:
	   <k> lessEqual(S1:AString, S2:AString) => (ABool, mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2)))) ... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-astring") </trace>
	   [internal]
 

	rule *toInteger(I:AInt) => I [internal]
	
	rule *toInteger(F:AFloat) => (AIntOfTuple(F), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(F))))	[internal]
	
	rule *toInteger(B:ABool) => (AIntOfTuple(B), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(B))))	[internal]
 
	rule *toInteger(S:AString) => (AIntOfTuple(S), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(S))))	[internal]
	
	rule *toInteger(NULL) => (AInt, ListItem(NullTypeConversion))	[internal]
	
	rule *toInteger(Array(_, Elems)) => (AInt, ListItem(ImplicitTypeConversion))
	
	rule *toInteger(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> (AInt, ListItem(ImplicitTypeConversion))
 
 // to boolean
    syntax  ABool ::= "*toBoolean" "(" LanguageValue ")" [function]

    rule    [toBoolean-bool]:    
	        <k> *toBoolean(B:ABool) => B ... </k>
	        [internal]

    rule    [toBoolean-int]:
	        <k> *toBoolean(N:AInt) => (ABoolOfTuple(N), addErrFlag(ImplicitTypeConversion,FilterErrFlags(getErrFlags(N)))) ... </k>
	        [internal]

    rule    [toBoolean-float]:    
	        <k> *toBoolean(F:AFloat) => (ABoolOfTuple(F), addErrFlag(ImplicitTypeConversion,FilterErrFlags(getErrFlags(F))))... </k>
	        [internal]

    rule    [toBoolean-string]:    
	        <k> *toBoolean(S:AString) => (ABoolOfTuple(S), addErrFlag(ImplicitTypeConversion,FilterErrFlags(getErrFlags(S)))) ... </k>
	        [internal]


    rule    [toBoolean-array]:    
	        <k> *toBoolean(Array(_,Elems)) => (ABool, ListItem(ImplicitTypeConversion)) ... </k>
	        [internal]
			
	rule	[toBoolean-true]:    
	        <k> *toBoolean(true) => (ABool, .List) ... </k>
	        [internal]
	
	rule 	[toBoolean-false]:    
	        <k> *toBoolean(false) => (ABool, .List) ... </k>
	        [internal]

// Object case: we add it, even if the online docs says this behaviour is "PHP 4 only"
// Since the expected behaviour for PHP 5 is not mentioned, I guess it is undefined..?

    rule    [toBoolean-object]:    
	        <k> *toBoolean(OID(L,_,_) => convertToLanguageValue(L)) ... </k>  
	        [internal]

    rule    [toBoolean-null]:        
	        <k> *toBoolean(NULL) => (ABool, ListItem(NullTypeConversion)) ... </k>
	        [internal]

    // to float

    syntax  K ::= "*toFloat" "(" K ")"  [strict]

    rule    [toFloat-false]:
	        <k> *toFloat(BFalse) => 'DNumber("0.0") ... </k>
	        [internal]
	
    rule    [toFloat-true]:
	        <k> *toFloat(BTrue) => 'DNumber("1.0") ... </k>
	        [internal]

    rule    [toFloat-int]:
	        <k> *toFloat(I:AInt) => (AFloatOfTuple(I), addErrFlag(ImplicitTypeConversion,FilterErrFlags(getErrFlags(I)))) ... </k>
	        [internal]

	rule *toFloat("ANum") => (AFloat, ListItem(ImplicitTypeConversion)) [internal]		
			
    rule    [toFloat-float]:
	        <k> *toFloat(F:AFloat) => F ... </k>
	        [internal]

    rule    [toFloat-string]:
	        <k> *toFloat(S:AString) => *toFloat(string2Number(S)) ... </k>
	        [internal]
	
    rule    [toFloat-compound]:	
	        <k> *toFloat(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> AFloat  ... </k>
	        [internal, error]

	//to string		
			
	syntax AIntValue ::= "*valueToInteger" "(" Scalar ")" [function]
	
	rule *valueToInteger(Bot) => Bot
	
	rule *valueToInteger(V) => AInt
	when V =/=K Bot
	
	syntax AFloatValue ::= "*valueToFloat" "(" Scalar ")" [function]
	
	rule *valueToFloat(Bot) => Bot
	
	rule *valueToFloat(V) => AFloat
	when V =/=K Bot
	
	syntax ABoolValue ::= "*valueToBool" "(" Scalar ")" [function]
	
	rule *valueToBool(Bot) => Bot
	
	rule *valueToBool(V) => ABool
	when V =/=K Bot
	
	syntax AStringValue ::= "*valueToString" "(" Scalar ")" [function]
	
	rule *valueToString(Bot) => Bot
	
	rule *valueToString(I:AIntValue) => "AInt"
	when I =/=K Bot
	
	rule *valueToString(F:AFloatValue) => "AFloat"
	when F =/=K Bot
	
	rule *valueToString(S:AStringValue) => S
	
	rule *valueToString(B:ABoolValue) => "ABool"
	when B =/=K Bot
	
	rule *valueToString(NULL) => ""
	
	syntax AString ::= "*toString" "(" LanguageValue ")" [function]

	//TODO : change this when numeric strings get added
	//TODO : find a way to add traces ?
	
	rule  *toString(I:AInt) => (*valueToString(lub_Value(*valueToString(AInt), Bot)), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(I)))) [internal]

	rule *toString(B:ABool) => (AStringOfTuple(B), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(B))))	[internal]
			
	rule  *toString(F:AFloat) => (AStringOfTuple(F), addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(F)))) [internal]
	
	rule *toString(S:AString) => S [internal]

	rule *toString(Arr:Array) => (AStringTop, ListItem(ImplicitTypeConversion))	[internal] // concrete string is "Array" ?
	
	rule *toString(Top) => (AStringTop, ListItem(ImplicitTypeConversion)) [internal]
	
	// TODO: put correct error msg
	// TODO: use magic method __toString()

	rule *toString(Obj:Object) => ERROR("Object of class %s could not be converted to string in %s on line %d") [internal, error]

	rule *toString(NULL) => ("", ListItem(NullTypeConversion)) [internal]

	syntax K ::= "string2Number" "(" AString ")" [strict]
	
	rule [string2Number]:
			<k> string2Number(S:AString) => (AInt, addErrFlag(ImplicitTypeConversion, FilterErrFlags(getErrFlags(S)))) ... </k> //TODO : should be Anum
			<trace> Trace:List => Trace ListItem("string2Number") </trace>
			[internal]
	
	// String concatenation operation
	
	syntax AStringValue ::= "AStringValueConcat" "(" AStringValue "," AStringValue ")" [function]

	
	rule AStringValueConcat(S1:String, S2:String) => S1 +String S2 [step]
	
	rule AStringValueConcat(AStringTop,_) => AStringTop [step]
	
	rule AStringValueConcat(_, AStringTop) => AStringTop [step]
	
	
	/*
	rule [concat-string-bot-1]:
	<k> AStringValueConcat(Bot, S:AStringValue) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-1") </trace>
	[step]
	
	rule [concat-string-bot-2]:
	<k> AStringValueConcat(S:AStringValue, Bot) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-2") </trace>
	[step]
	*/
	
	rule 'Concat(S1:AString,, S2:AString) => specify(VE(AStringValueConcat(AStringOfTuple(S1), AStringOfTuple(S2)), mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2)))))
	
    syntax  ABool ::= "notABool" ABool [function]

    rule notABool B => (ABool, FilterErrFlags(getErrFlags(B)))

    syntax  ABool ::= AInt "==AInt" AInt [function]

    rule I1 ==AInt I2 => (ABool, mergeList(FilterErrFlags(getErrFlags(I1)), FilterErrFlags(getErrFlags(I2)))) 

    syntax  ABool ::= AFloat "==AFloat" AFloat [function]
    
    rule F1 ==AFloat F2 => (ABool, mergeList(FilterErrFlags(getErrFlags(F1)), FilterErrFlags(getErrFlags(F2))))
    
    syntax  ABool ::= ABool "==ABool" ABool [function]
    
    rule B1 ==ABool B2 => (ABool, mergeList(FilterErrFlags(getErrFlags(B1)), FilterErrFlags(getErrFlags(B2))))    
    
    syntax  ABool ::= AString "==AString" AString [function]
    
    rule S1 ==AString S2 => (ABool, mergeList(FilterErrFlags(getErrFlags(S1)), FilterErrFlags(getErrFlags(S2))))
    
    rule    [internal-print]:
            <k> print (V:AString)  => . ... </k>
            <out> ... . => ListItem(V) </out>
            [internal, output]   
	rule print(S:String) => print(specify(VE(S, .List)))		
			
    // input
    syntax K ::= "user_input"
	
    rule [input]:
    	<k>  user_input => specify(VE(AStringTop, .List)) ...</k>
	
	
	//can't be resolved in this domain
	
	syntax Bool ::= "isNumericString" "(" AString ")" [function]	
				| "isIntString" "(" AString ")" [function]	
				| "isFloatString" "(" AString ")" [function]	
	
	rule strlen(S:AString) => (AInt, .List)
	
	rule [init-domain]:
		<k> initDomain => . ... </k>
		<domain> .K => Types </domain>
	
	
	
	//@ \section{Operations on reference counters}

	//copied from mySigns
	
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
	
	
	
endmodule