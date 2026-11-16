grammar Css;

// ===================== Parser =====================
stylesheet : cssRule* EOF ;

cssRule : selectorList '{' declaration? (';' declaration?)* '}' ;

selectorList : selector (',' selector)* ;
selector     : simpleSelector (combinator? simpleSelector)* ;
combinator   : '>' | '+' | '~' ;

simpleSelector
    : (IDENT | '*') selectorSuffix*
    | selectorSuffix+
    ;
selectorSuffix : HASH | CLASS | attrSelector | pseudo ;
attrSelector   : '[' IDENT (('=' | '~=' | '|=' | '^=' | '$=' | '*=') (IDENT | STRING))? ']' ;
pseudo         : ':' ':'? IDENT ('(' IDENT? ')')? ;

declaration : property=IDENT ':' value important? ;
important   : '!' IDENT ;

value : term (sep=(',' | '/')? term)* ;
term
    : NUMBER        # NumberTerm
    | DIMENSION     # DimensionTerm
    | PERCENTAGE    # PercentTerm
    | STRING        # StringTerm
    | HASH          # ColorTerm
    | IDENT         # KeywordTerm
    | function      # FunctionTerm
    ;
function : IDENT '(' (value)? ')' ;

// ===================== Lexer =====================
DIMENSION  : NUM [a-zA-Z]+ ;
PERCENTAGE : NUM '%' ;
NUMBER     : NUM ;
HASH       : '#' [a-zA-Z0-9_\-]+ ;
CLASS      : '.' [a-zA-Z_] [a-zA-Z0-9_\-]* ;
IDENT      : '-'? [a-zA-Z_] [a-zA-Z0-9_\-]* ;
STRING     : '"' ~["\r\n]* '"' | '\'' ~['\r\n]* '\'' ;

fragment NUM : '-'? ( [0-9]+ ('.' [0-9]+)? | '.' [0-9]+ ) ;

COMMENT : '/*' .*? '*/' -> skip ;
WS      : [ \t\r\n]+    -> skip ;
