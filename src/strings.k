require "shared.k"

module STRINGS
	imports SHARED

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Strings} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

context 'ConstantEncapsedString(HOLE)

rule [constant-encapsed-string]: 
	<k> 'ConstantEncapsedString(S:String) => S ... </k>
	<trace> Trace:List => Trace ListItem("constant-encapsed-string") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{String Access} */
// ---------------------------------------------------------------------------------------------

syntax KLabel ::= "'StringAccess"

rule ('StringAccess => 'ArrayAccess)(_,,_)

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Single Quoted Strings} */
// ---------------------------------------------------------------------------------------------

context 'SingleQuoted('ListWrap(_:KList,,HOLE,,_:KList))

rule [single-quoted]: 
	<k> 'SingleQuoted('ListWrap(S:String)) => S ... </k>
	<trace> Trace:List => Trace ListItem("single-quoted") </trace>
	[structural]

rule [single-quoted-empty]: 
	<k> 'SingleQuoted('ListWrap(.KList)) => "" ... </k>
	<trace> Trace:List => Trace ListItem("single-quoted-empty") </trace>
	[structural]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Double Quoted Strings} */
// ---------------------------------------------------------------------------------------------

context 'DoubleQuoted(HOLE)

rule [double-quoted]: 
	<k> 'DoubleQuoted(S:String) => S ... </k>
	<trace> Trace:List => Trace ListItem("double-quoted") </trace>
	[structural]

// Base case (double quoted simple string - i.e. no variables in it)
context 'DQContent('Some(HOLE))

rule [dq-content]: 
	<k> 'DQContent('Some(S:String)) => S ... </k>
	<trace> Trace:List => Trace ListItem("dq-content") </trace>
	[structural]

rule [dq-content-empty]: 
	<k> 'DQContent('None(_)) => "" ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-empty") </trace>
	[structural]
	
//Complex case (double quoted string containing variables)
context 'DQContent(HOLE,, _:K,, _:K)
context 'DQContent(_:K,, HOLE,, _:K)
context 'DQContent(_:K,, _:K,, HOLE)

rule [dq-content-arg2LangValue-1]:
	<k> 'DQContent((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),, _:K,, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg2LangValue-1") </trace>
	[intermediate]

rule [dq-content-arg2LangValue-2]:
	<k> 'DQContent(_:K,, (R:ConvertibleToLanguageValue => convertToLanguageValue(R)),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg2LangValue-2") </trace>
	[intermediate]

rule [dq-content-arg2LangValue-3]:
	<k> 'DQContent(_:K,, _:K,, (R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg2LangValue-3") </trace>
	[intermediate]

rule [dq-content-arg-none-1]: 
	<k> 'DQContent(('None(_) => ""),, _:K,, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg-none-1") </trace>
	[intermediate]

rule [dq-content-arg-none-2]: 
	<k> 'DQContent(_:K,, ('None(_) => ""),, _:K) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg-none-2") </trace>
	[intermediate]

rule [dq-content-arg-none-3]: 
	<k> 'DQContent(_:K,, _:K,, ('None(_) => "")) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-arg-none-3") </trace>
	[intermediate]

rule [dq-content-concat]: 
	<k> 'DQContent(S1:LanguageValue,, S2:LanguageValue,, S3:LanguageValue) => 
		'Concat('Concat(*toString(S1),, *toString(S2)),, *toString(S3)) ... </k>
	<trace> Trace:List => Trace ListItem("dq-content-concat") </trace>
	[intermediate]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Braced variables} */
// ---------------------------------------------------------------------------------------------

context 'Variable('Braced(HOLE))

rule [braced]: 
	<k> 'Braced(Stuff:K) => Stuff ... </k>
	<trace> Trace:List => Trace ListItem("braced") </trace>
	[structural]

rule [var-braced-arg2LangValue]: 
	<k> 'Variable('Braced(R:Ref => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("var-braced-arg2LangValue") </trace>
	[intermediate]

rule [var-braced]: 
	<k> 'Variable('Braced(S:String)) => 'Variable('Simple(S)) ... </k>
	<trace> Trace:List => Trace ListItem("var-braced") </trace>
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{String Concatenation Operation} */
// ---------------------------------------------------------------------------------------------

context 'Concat(HOLE,, _:K)
context 'Concat(_:BasicRef,, HOLE)
context 'Concat(_:LanguageValue,, HOLE)

// Arguments evaluation
rule [concat-LHS2LangValue-1]:    
	<k> 'Concat((R:LRef => convertToLanguageValue(R)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("concat-LHS2LangValue-1") </trace>
	[intermediate]

rule [concat-LHS2LangValue-2]:    
	<k> 'Concat((R:Loc => convertToLanguageValue(R)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("concat-LHS2LangValue-2") </trace>
	[intermediate]

rule [concat-RHS2LangValue-1]:    
	<k> 'Concat(_:LanguageValue,, (V1:ConvertibleToLanguageValue => convertToLanguageValue(V1))) ... </k>
	<trace> Trace:List => Trace ListItem("concat-RHS2LangValue-1") </trace>
	[intermediate]

rule [concat-RHS2LangValue-2]:    
	<k> 'Concat(_:BasicRef,, (V1:ConvertibleToLanguageValue => convertToLanguageValue(V1))) ... </k>
	<trace> Trace:List => Trace ListItem("concat-RHS2LangValue-2") </trace>
	[intermediate]

rule [concat-LHS2LangValue]:    
	<k> 'Concat((V:BasicRef => convertToLanguageValue(V)),, _:LanguageValue) ... </k>
	<trace> Trace:List => Trace ListItem("concat-LHS2LangValue") </trace>
	[intermediate]

// String concatenation operation
rule [concat-string]:    
	<k> 'Concat(Str1:String,, Str2:String) => Str1 +String Str2 ... </k>
	<trace> Trace:List => Trace ListItem("concat-string") </trace>
	[step]

rule [concat-toString]:
	<k> 'Concat(V1:LanguageValue,, V2:LanguageValue) => 'Concat(*toString(V1),, *toString(V2)) ... </k>
	<trace> Trace:List => Trace ListItem("concat-toString") </trace>
	when notBool (isStringType(V1) andBool isStringType(V2))
	[intermediate]
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Escape Characters} */
// ---------------------------------------------------------------------------------------------

rule [escape-34]:
 	<k> 'Escape(34) => "\"" ... </k>
	<trace> Trace:List => Trace ListItem("escape-34") </trace>
	[step]

rule [escape-36]:
	<k> 'Escape(36) => "$" ... </k>
	<trace> Trace:List => Trace ListItem("escape-36") </trace>
	[step]

rule [escape-39]:
	<k> 'Escape(39) => "'" ... </k>
	<trace> Trace:List => Trace ListItem("escape-39") </trace>
	[step]

rule [escape-92]:
	<k> 'Escape(92) => "\\" ... </k>
	<trace> Trace:List => Trace ListItem("escape-92") </trace>
	[step]

rule [escape-110]:
	<k> 'Escape(110) => "\n" ... </k>
	<trace> Trace:List => Trace ListItem("escape-110") </trace>
	[step]

rule [escape-116]:
	<k> 'Escape(116) => "\t" ... </k>
	<trace> Trace:List => Trace ListItem("escape-116") </trace>
	[step]

rule [escape-114]:
	<k> 'Escape(114) => "\r"  ... </k>
	<trace> Trace:List => Trace ListItem("escape-114") </trace>
	[step]

// LATER: add more

endmodule