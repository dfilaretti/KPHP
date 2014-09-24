require "errors.k"
module NOT-SUPPORTED
	imports ERRORS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Language constructs which we do not support} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

syntax KLabel ::= "'ASPCloseTag"
|"'ASPOpenTag"
|"'Abstract"
|"'AbstractClass"
|"'AbstractMethodBody"
|"'AltElseIf"
|"'AltForEach"
|"'ArrayCast"
|"'BinAnd"
|"'Body"
|"'Braced"
|"'BracedArrayAccess"
|"'ClassConstantDecl"
|"'ClassConstantDeclList"
|"'Clone"
|"'Continue"
|"'Declare"
|"'DefaultCase"
|"'Directive"
|"'EchoOpenTag"
|"'ElseIf"
|"'EmbeddedArrayVariable"
|"'EmbeddedString"
|"'ErrorFree"
|"'Eval"
|"'Final"
|"'FinalClass"
|"'HereDoc"
|"'HereDocContent"
|"'HereDocStart"
|"'Hexa"
|"'HexaChar"
|"'Implements"
|"'IncludeOnce"
|"'InlineHTML"
|"'InterfaceDecl"
|"'InterfaceExtends"
|"'InterfaceFunction"
|"'InterfaceFunctionRef"
|"'MagicConstant"
|"'MulAssign"
|"'Neg"
|"'NullCast"
|"'Octa"
|"'OctaChar"
|"'OldFunctionDecl"
|"'OldFunctionDeclRef"
|"'ParamConstant"
|"'Ref"
|"'RefValue"
|"'SLAssign"
|"'SRAssign"
|"'ShellCommand"
|"'StaticVariable"
|"'VariableBraced"
|"'Print"
|"'Name"

rule 'InterfaceDecl(_) => NOT-SUPPORTED("'InterfaceDecl")
//rule #noparse => NOT-SUPPORTED("runtime parsing not supported (eval, include, etc.)") 
rule 'RefValue(_) => NOT-SUPPORTED("'RefValue") 
rule 'ErrorFree(_) => NOT-SUPPORTED("'ErrorFree") 
rule 'HexaChar(_) => NOT-SUPPORTED("'HexaChar")
rule 'MagicConstant(_) => NOT-SUPPORTED("'MagicConstant")
rule 'InternalFunction('IncludeOnce(_)) => NOT-SUPPORTED("IncludeOnce")

endmodule

