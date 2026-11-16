grammar JavaSubset;

// ===================== Parser: Java + Spring Boot subset =====================
compilationUnit : packageDecl? importDecl* typeDecl* EOF ;

packageDecl : 'package' qualifiedName ';' ;
importDecl  : 'import' 'static'? qualifiedName ('.' '*')? ';' ;

typeDecl    : annotation* modifier* classDecl ;
classDecl   : 'class' IDENT ('extends' type)? ('implements' type (',' type)*)? classBody ;
classBody   : '{' member* '}' ;

member
    : fieldDecl         # FieldMember
    | methodDecl        # MethodMember
    | constructorDecl   # ConstructorMember
    ;

fieldDecl       : annotation* modifier* type IDENT ('=' expression)? ';' ;
methodDecl      : annotation* modifier* type IDENT '(' params? ')' block ;
constructorDecl : annotation* modifier* IDENT '(' params? ')' block ;

params : param (',' param)* ;
param  : annotation* type IDENT ;

// ---- annotations (@Controller, @GetMapping("/x"), @PathVariable ...) ----
annotation        : '@' qualifiedName ('(' annotationArgs? ')')? ;
annotationArgs    : elementValuePair (',' elementValuePair)* | elementValue ;
elementValuePair  : IDENT '=' elementValue ;
elementValue      : expression | '{' (elementValue (',' elementValue)*)? '}' ;

modifier : 'public' | 'private' | 'protected' | 'static' | 'final' ;

type
    : qualifiedName typeArgs? ('[' ']')*
    | primitiveType ('[' ']')*
    ;
typeArgs      : '<' type (',' type)* '>' ;
primitiveType : 'int' | 'long' | 'double' | 'float' | 'boolean' | 'char' | 'void' ;
qualifiedName : IDENT ('.' IDENT)* ;

// ---- statements ----
block : '{' statement* '}' ;

statement
    : localVarDecl ';'                                  # LocalVarStmt
    | 'return' expression? ';'                          # ReturnStmt
    | 'if' '(' expression ')' statement ('else' statement)?  # IfStmt
    | 'for' '(' type IDENT ':' expression ')' statement # ForEachStmt
    | block                                             # BlockStmt
    | expression ';'                                    # ExprStmt
    ;

localVarDecl : type IDENT ('=' expression)? ;

// ---- expressions ----
expression
    : expression '.' IDENT '(' arguments? ')'                     # MethodCallExpr
    | expression '.' IDENT                                        # FieldAccessExpr
    | IDENT '(' arguments? ')'                                    # SimpleCallExpr
    | 'new' type '(' arguments? ')'                               # NewExpr
    | expression '[' expression ']'                               # IndexExpr
    | '!' expression                                              # NotExpr
    | expression op=('*' | '/' | '%') expression                  # MulExpr
    | expression op=('+' | '-') expression                        # AddExpr
    | expression op=('<' | '>' | '<=' | '>=' | '==' | '!=') expression  # CompareExpr
    | expression op=('&&' | '||') expression                      # LogicExpr
    | <assoc=right> expression '=' expression                     # AssignExpr
    | literal                                                     # LiteralExpr
    | 'this'                                                      # ThisExpr
    | IDENT                                                       # IdentExpr
    | '(' expression ')'                                          # ParenExpr
    ;

arguments : expression (',' expression)* ;
literal   : INT_LIT | DOUBLE_LIT | STRING_LIT | 'true' | 'false' | 'null' ;

// ===================== Lexer =====================
IDENT       : [a-zA-Z_$] [a-zA-Z_$0-9]* ;
DOUBLE_LIT  : [0-9]+ '.' [0-9]+ ;
INT_LIT     : [0-9]+ 'L'? ;
STRING_LIT  : '"' ( ~["\\\r\n] | '\\' . )* '"' ;

LINE_COMMENT  : '//' ~[\r\n]*       -> skip ;
BLOCK_COMMENT : '/*' .*? '*/'       -> skip ;
WS            : [ \t\r\n]+          -> skip ;
