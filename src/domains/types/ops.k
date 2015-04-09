require "lattice.k"
module OPS
       imports LATTICE

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

       rule  AFloat +AFloat AFloat => AFloat
       rule  AFloat -AFloat AFloat => AFloat
       rule  AFloat *AFloat AFloat => AFloat
       rule  AFloat /AFloat AFloat => AFloat
       rule negative_AFloat(AFloat) => AFloat
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

	rule [toString-int]:
			<k> *toString(I:AInt) => AStringUntainted ... </k>
			<trace> Trace:List => Trace ListItem("toString-int") </trace>
			[internal]
	
	rule [toString-bool]:
			<k> *toString(B:ABool) => AStringUntainted ... </k>
			<trace> Trace:List => Trace ListItem("toString-bool") </trace>
			[internal]
			
	rule [toString-float]:   
			<k> *toString(F:AFloat) => AStringUntainted ... </k>
			<trace> Trace:List => Trace ListItem("toString-float") </trace>
			[internal]
	rule [toString-string]:   
			<k> *toString(S:AString) => S ... </k>
			<trace> Trace:List => Trace ListItem("toString-string") </trace>
			[internal]

	rule [toString-array]:   
			<k> *toString(Arr:Array) => AStringUntainted ... </k> //concrete string is "Array" ?
			<trace> Trace:List => Trace ListItem("toString-array") </trace>
			[internal]
	
	// TODO: put correct error msg
	// TODO: use magic method __toString()

	rule [toString-object]:   
			<k> *toString(Obj:Object) => ERROR("Object of class %s could not be converted to string in %s on line %d") ... </k>
			<trace> Trace:List => Trace ListItem("toString-array") </trace>
			[internal, error]

	rule [toString-null]:   
			<k> *toString(NULL) => AStringUntainted ... </k>
			<trace> Trace:List => Trace ListItem("toString-null") </trace>
			[internal]
	
	syntax K ::= "string2Number" "(" AString ")"
	
	rule [string2Number]:
			<k> string2Number(S:AString) => AInt ... </k>
			<trace> Trace:List => Trace ListItem("string2Number") </trace>
			[internal]
	
	// String concatenation operation
	rule [concat-string-untainted-1]:    
	<k> 'Concat(AStringUntainted,, S:AString) => S ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-untainted-1") </trace>
	[step]
	
	rule [concat-string-untainted-2]:    
	<k> 'Concat(S:AString,, AStringUntainted) => S ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-untainted-2") </trace>
	[step]
	
	rule [concat-string-tainted-1]:
	<k> 'Concat(AStringTainted,, S:AString) => AStringTainted ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-tainted-1") </trace>
	[step]
	
	rule [concat-string-tainted-2]:
	<k> 'Concat(S:AString,, AStringTainted) => AStringTainted ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-tainted-2") </trace>
	[step]
	
	rule [concat-string-top]:
	<k> 'Concat(AStringTop,, AStringTop) => AStringTop ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-tainted-2") </trace>
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

    // output
    syntax  K ::= "print" "(" K ")"
    
    rule    [internal-print]:
            <k> print (V:AString)  => . ... </k>
            <out> ... . => ListItem(V) </out>
            [internal, output]   

    // input
    syntax K ::= "user_input"
	
    rule [input]:
    	<k>  user_input => AStringTainted ...</k>
	
	
	//can't be resolved in this domain
	
	syntax Bool ::= "isNumericString" "(" AString ")" [function]	
				| "isIntString" "(" AString ")" [function]	
				| "isFloatString" "(" AString ")" [function]	
	
	
endmodule