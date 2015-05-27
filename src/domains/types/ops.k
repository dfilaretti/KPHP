require "lattice.k"
require "../../lang/arith-ops.k"
module OPS
       imports LATTICE
	   imports ARITH-OPS
	   imports INIT
	   
       syntax AInt ::= AInt "+AInt" AInt [function]
       syntax AInt ::= AInt "-AInt" AInt [function]
       syntax AInt ::= AInt "*AInt" AInt [function]
       syntax AInt ::= AInt "/AInt" AInt [function]
       syntax AInt ::= AInt "modAInt" AInt [function]
       syntax AInt ::= "negative_AInt" "(" AInt ")" [function]       

       rule AInt +AInt AInt => AInt
       rule AInt -AInt AInt => AInt
       rule AInt *AInt AInt => AInt
       rule AInt /AInt AInt => AInt
       rule AInt modAInt AInt => AInt
       rule negative_AInt(AInt) => AInt

       syntax AFloat ::= AFloat "+AFloat" AFloat	[function]
       syntax AFloat ::= AFloat "-AFloat" AFloat [function]
       syntax AFloat ::= AFloat "*AFloat" AFloat [function]
       syntax AFloat ::= AFloat "/AFloat" AFloat [function]
       syntax AFloat ::= "negative_AFloat" "(" AFloat ")" [function]

	   syntax K ::= "stopDebug"
	   
       rule  AFloat +AFloat AFloat => AFloat
       rule  AFloat -AFloat AFloat => AFloat
       rule  AFloat *AFloat AFloat => AFloat
       rule  AFloat /AFloat AFloat => AFloat
       rule negative_AFloat(AFloat) => AFloat
 
	   rule [greater-aint]:
	   <k> greater(I1:AInt, I2:AInt) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greater-aint") </trace>
	   [internal]
		
	   rule [greater-afloat]:
	   <k> greater(F1:AFloat, F2:AFloat) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greater-afloat") </trace>
	   [internal]
	
	   rule [greater-abool]:
	   <k> greater(B1:ABool, B2:ABool) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greater-abool") </trace>
	   [internal]
	   
	   rule [greater-astring]:
	   <k> greater(S1:AString, S2:AString) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greater-astring") </trace>
	   [internal]
	   
	   rule [less-aint]:
	   <k> less(I1:AInt, I2:AInt) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("less-aint") </trace>
	   [internal]
		
	   rule [less-afloat]:
	   <k> less(F1:AFloat, F2:AFloat) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("less-afloat") </trace>
	   [internal]
	
	   rule [less-abool]:
	   <k> less(B1:ABool, B2:ABool) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("less-abool") </trace>
	   [internal]
	   
	   rule [less-astring]:
	   <k> less(S1:AString, S2:AString) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("less-astring") </trace>
	   [internal]
	   
	   syntax K ::= "greaterEqual" "(" K "," K ")"

	   rule [greaterEqual-aint]:
	   <k> greaterEqual(I1:AInt, I2:AInt) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-aint") </trace>
	   [internal]

	   rule [greaterEqual-afloat]:
	   <k> greaterEqual(F1:AFloat, F2:AFloat) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-afloat") </trace>
	   [internal]

	   rule [greaterEqual-abool]:
	   <k> greaterEqual(ABool, ABool) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-abool") </trace>
	   [internal]
	   
	   rule [greaterEqual-astring]:
	   <k> greaterEqual(S1:AString, S2:AString) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("greaterEqual-astring") </trace>
	   [internal]
 
	   syntax K ::= "lessEqual" "(" K "," K ")"

	   rule [lessEqual-aint]:
	   <k> lessEqual(I1:AInt, I2:AInt) => ABool... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-aint") </trace>
	   [internal]

	   rule [lessEqual-afloat]:
	   <k> lessEqual(F1:AFloat, F2:AFloat) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-afloat") </trace>
	   [internal]

	   rule [lessEqual-abool]:
	   <k> lessEqual(ABool, ABool) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-abool") </trace>
	   [internal]
	   
	   rule [lessEqual-astring]:
	   <k> lessEqual(S1:AString, S2:AString) => ABool ... </k>
	   <trace> Trace:List => Trace ListItem("lessEqual-astring") </trace>
	   [internal]
 
 // to boolean
    syntax  K ::= "*toBoolean" "(" LanguageValue ")" [strict]

    rule    [toBoolean-bool]:    
	        <k> *toBoolean(B:ABool) => B ... </k>
	        [internal]

    rule    [toBoolean-int]:
	        <k> *toBoolean(N:AInt) => ABool ... </k>
	        [internal]

    rule    [toBoolean-float]:    
	        <k> *toBoolean(F:AFloat) => ABool ... </k>
	        [internal]

    rule    [toBoolean-string]:    
	        <k> *toBoolean(S:AString) => ABool ... </k>
	        [internal]


    rule    [toBoolean-array]:    
	        <k> *toBoolean(Array(_,Elems)) => ABool ... </k>
	        [internal]
			
	rule	[toBoolean-true]:    
	        <k> *toBoolean(true) => ABool ... </k>
	        [internal]
	
	rule 	[toBoolean-false]:    
	        <k> *toBoolean(false) => ABool ... </k>
	        [internal]

// Object case: we add it, even if the online docs says this behaviour is "PHP 4 only"
// Since the expected behaviour for PHP 5 is not mentioned, I guess it is undefined..?

    rule    [toBoolean-object]:    
	        <k> *toBoolean(OID(L,_,_) => convertToLanguageValue(L)) ... </k>  
	        [internal]

    rule    [toBoolean-null]:        
	        <k> *toBoolean(NULL) => ABool ... </k>
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
	        <k> *toFloat(I:AInt) => AFloat ... </k> // TODO: fix!
	        [internal]

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
			
	syntax K ::= "*toString" "(" LanguageValue ")" [strict]

	//TODO : change this when numeric strings get added
	
	rule [toString-int]:
			<k> *toString(I:AInt) => "AInt" ... </k>
			<trace> Trace:List => Trace ListItem("toString-int") </trace>
			[internal]
	
	rule [toString-bool]:
			<k> *toString(B:ABool) => "ABool" ... </k>
			<trace> Trace:List => Trace ListItem("toString-bool") </trace>
			[internal]
			
	rule [toString-float]:   
			<k> *toString(F:AFloat) => "AFloat" ... </k>
			<trace> Trace:List => Trace ListItem("toString-float") </trace>
			[internal]
	rule [toString-string]:   
			<k> *toString(S:AString) => S ... </k>
			<trace> Trace:List => Trace ListItem("toString-string") </trace>
			[internal]

	rule [toString-array]:   
			<k> *toString(Arr:Array) => AStringTop ... </k> //concrete string is "Array" ?
			<trace> Trace:List => Trace ListItem("toString-array") </trace>
			[internal]
	
	rule [toString-top]:
			<k> *toString(Top) => AStringTop ... </k>
			<trace> Trace:List => Trace ListItem("toString-top") </trace>
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
	
	syntax K ::= "string2Number" "(" AString ")"
	
	rule [string2Number]:
			<k> string2Number(S:AString) => ANum ... </k>
			<trace> Trace:List => Trace ListItem("string2Number") </trace>
			[internal]
	
	// String concatenation operation
	rule [concat-string-concrete]:
	<k> 'Concat(S1:String,, S2:String) => S1 +String S2 ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-concrete") </trace>
	[step]
	
	rule [concat-string-top-1]:
	<k> 'Concat(AStringTop,, S:AString) => AStringTop ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-top-1") </trace>
	[step]
	
	rule [concat-string-top-2]:
	<k> 'Concat(S:AString,, AStringTop) => AStringTop ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-top-2") </trace>
	[step]
	
	rule [concat-string-bot-1]:
	<k> 'Concat(AStringBot,, S:AString) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-1") </trace>
	[step]
	
	rule [concat-string-bot-2]:
	<k> 'Concat(S:AString,, AStringBot) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-2") </trace>
	[step]
	
    syntax  ABool ::= "notABool" ABool [function]

    rule    notABool ABool => ABool

    syntax  ABool ::= AInt "==AInt" AInt

    rule AInt ==AInt AInt => ABool

    syntax  ABool ::= AFloat "==AFloat" AFloat
    
    rule AFloat ==AFloat AFloat => ABool
    
    syntax  ABool ::= ABool "==ABool" ABool
    
    rule ABool ==ABool ABool => ABool    
    
    syntax  ABool ::= AString "==AString" AString
    
    rule X:AString ==AString Y:AString => ABool
    
    rule    [internal-print]:
            <k> print (V:AString)  => . ... </k>
            <out> ... . => ListItem(V) </out>
            [internal, output]   
			
			
    // input
    syntax K ::= "user_input"
	
    rule [input]:
    	<k>  user_input => AStringTop ...</k>
	
	
	//can't be resolved in this domain
	
	syntax Bool ::= "isNumericString" "(" AString ")" [function]	
				| "isIntString" "(" AString ")" [function]	
				| "isFloatString" "(" AString ")" [function]	
	
	rule strlen(S:AString) => AInt
	
	rule [init-domain]:
		<k> initDomain => . ... </k>
		<domain> .K => Types </domain>
	
endmodule