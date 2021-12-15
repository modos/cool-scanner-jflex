package classes;

%%

%class CompilerScanner
%public
%unicode
//%standalone
%line
%column
%function nextToken
%type Symbol
%implements Lexical

%{
    public int intValue = 0;
    public double doubleValue = 0.0;
    public boolean booleanValue;
    public StringBuffer string  = new StringBuffer();
    private Symbol symbol(String token, Type type) {
        return new Symbol(token, type);
    }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace = {LineTerminator} | [ \t\f]

// Comment
TraditionalComment = "/*" [^*] ~"*/" | "/*"~"*/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
Comment = {TraditionalComment} | {EndOfLineComment}

// Identifiers
Digit = [0-9]
ZeroOrMoreDigits = {Digit}*
OneOrMoreDigits = {Digit}+
Letter = [a-zA-Z]
Underline = "_"
Identifier = {Letter} ({Underline} | {Letter} | {Digit}) {0,30}

// Numbers
Sign = [+-]?
DecimalInteger = {Sign}{OneOrMoreDigits}
Zero = "0"
Dot = "."
HexaDeciamlDigit = {Digit} | [a-fA-F]
OneOrMoreHexaDecimalDigit = {HexaDeciamlDigit}+
Xx = "x" | "X"
Ee = "e" | "E"
HexaDecimal = {Sign} {Zero} {Xx} {OneOrMoreHexaDecimalDigit}
RealNumber = {Sign} {OneOrMoreDigits} {Dot} {ZeroOrMoreDigits}
ScientificNotation = ({RealNumber} | {DecimalInteger}) {Ee} {DecimalInteger}

// Reserved Keywords
Void = "void"
Int = "int"
Let = "let"
Real = "real"
Bool = "bool"
String = "string"
Static = "static"
Class = "class"
For = "for"
Rof = "rof"
Loop = "loop"
Pool = "pool"
While = "while"
Break = "break"
Continue = "continue"
If = "if"
Fi = "fi"
Else = "else"
Then = "then"
New = "new"
Array = "Array"
Return = "return"
In_string = "in_string"
In_int = "in_int"
Print = "print"
Len = "len"

ReservedKeyword = {Void} | {Int} | {Let} | {Real} | {Bool} | {String} | {Static} | {Class} | {For} | {Rof} | {Loop} | {Pool} | {While} | {Break} | {Continue} | {If} | {Fi} | {Else} | {Then} | {New} | {Array} | {Return} | {In_string} | {In_int} | {Print} | {Len}

// Operators and Punctuations
Add = "+"
Unaryminus = "-"
Production = "*"
Division = "/"
AdditionAssignment = "+="
SubtractionAssignment = "-="
ProductionAssignment = "*="
DivisionAssignment = "/="
Increment = "++"
Decrement = "--"
Less = "<"
LessEqual = "<="
Greater = ">"
GreaterEqual = ">="
NotEqual = "!="
DoubleEqual = "=="
Equal = "="
Assignment = "<-"
Mod = "%"
LogicalAnd = "&&"
LogicalOr = "||"
BitwiseAnd = "&"
BitwiseOr = "|"
StringLiteral = "“"
BitwiseXor = "^"
Not = "!"
Dot = "."
Comma = ","
Semicolon = ";"
OpeningBraces = "["
ClosingBraces = "]"
OpeningParenthesis = "("
ClosingParenthesis = ")"
OpeningCurlyBraces = "{"
ClosingCurlyBraces = "}"
OperatorAndPunctuation = {DoubleEqual} | {Add} | {Unaryminus} | {Production} | {Division} | {AdditionAssignment} | {SubtractionAssignment} | {ProductionAssignment} | {DivisionAssignment} | {Increment} | {Decrement} | {Less} | {LessEqual} | {Greater} | {GreaterEqual} | {NotEqual} | {Equal} | {Assignment} | {Mod} | {LogicalAnd} | {LogicalOr} | {BitwiseAnd} | {BitwiseOr} | {StringLiteral} | {BitwiseXor} | {Not} | {Dot} | {Comma} | {Semicolon} | {OpeningBraces} | {ClosingBraces} | {OpeningParenthesis} | {ClosingParenthesis} | {OpeningCurlyBraces} | {ClosingCurlyBraces}

// Boolean
True = "true"
False = "false"
Boolean = {True} | {False}

// String
StringLiteral = \"

// States
%state STRING

%%

<YYINITIAL> {
    {StringLiteral} {
        yybegin(STRING);
        return symbol(yytext(), Type.STRING);
    }
    {Comment} {
        return symbol(yytext(), Type.COMMENT);
    }
    {Boolean} {
        booleanValue = Boolean.valueOf(yytext());
        return symbol(yytext(), Type.BOOLEAN);
    }
    {ReservedKeyword} {
        return symbol(yytext(), Type.RESERVED_KEYWORD);
    }
    {OperatorAndPunctuation} {
        return symbol(yytext(), Type.OPERATOR_AND_PUNCTUATION);
    }
    {Identifier} {
        return symbol(yytext(), Type.IDENTIFIER);
    }
    {DecimalInteger} {
        intValue = Integer.valueOf(yytext());
        return symbol(yytext(), Type.INTEGER_NUMBER);
    }
    {RealNumber} {
        doubleValue = Double.valueOf(yytext());
        return symbol(yytext(), Type.REAL_NUMBER);
    }
    {HexaDecimal} {
        String absoluteStringValue = yytext().substring(yytext().indexOf("0") + 2);
        char firstChar = yytext().charAt(0);
        String stringToParse = (firstChar == '-') ? firstChar + absoluteStringValue : absoluteStringValue;
        intValue = Integer.parseInt(stringToParse, 16);
        return symbol(yytext(), Type.HEX);
    }
    {ScientificNotation} {
        doubleValue = Double.valueOf(yytext());
        return symbol(yytext(), Type.SCIENTIFIC_NOTATION);
    }
    {WhiteSpace} {
        return symbol(yytext(), Type.WHITESPACE);
    }
    [^] {
        System.err.println("\nscanner undefined token error: Token " + yytext() + " is not defined at "+ "line " + (yyline + 1) + " with character index " + yycolumn + "\n");
        return symbol(yytext(), Type.UNDEFINED);
    }
}

<STRING> {
    \"            {
                        yybegin(YYINITIAL);
                        string.append(yytext());
                        String value = string.toString();
                        string.setLength(0);
                        return symbol(yytext(), Type.STRING);
                    }
    [^\r\n\t\"\'\\]+  {string.append(yytext()); return symbol(yytext(), Type.STRING);}
    "\\r"   {string.append("\r"); return symbol(yytext(), Type.ESCAPE_CHAR);}
    "\\n"    {string.append("\n"); return symbol(yytext(), Type.ESCAPE_CHAR);}
    "\\t"    {string.append("\t"); return symbol(yytext(), Type.ESCAPE_CHAR);}
    "\\\'"  {string.append("'"); return symbol(yytext(), Type.ESCAPE_CHAR);}
    "\\\""  {string.append("\""); return symbol(yytext(), Type.ESCAPE_CHAR);}
    "\\\\"    {string.append("\\"); return symbol(yytext(), Type.ESCAPE_CHAR);}
}

[^] {
        System.err.println("\nscanner undefined token error: Token " + yytext() + " is not defined at "+ "line " + (yyline + 1) + " with character index " + yycolumn + "\n");
        return symbol(yytext(), Type.UNDEFINED);
}
