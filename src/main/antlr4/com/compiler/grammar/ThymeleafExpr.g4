grammar ThymeleafExpr;

// Used in a second pass: the HTML parser gives us the raw attribute value
// (e.g. "${product.name}"), and we parse it with one of these entry rules.

attrValue : expr EOF ;                                       // th:text, th:if, th:href, th:src, th:action, th:object, th:field ...
eachValue : iterVar=IDENT (',' statVar=IDENT)? ':' expr EOF ; // th:each="p, stat : ${products}"

expr
    : expr '.' IDENT '(' (expr (',' expr)*)? ')'             # MethodCallExpr
    | expr '.' IDENT                                         # PropertyExpr
    | expr '[' expr ']'                                      # IndexExpr
    | op=('!' | 'not') expr                                  # NotExpr
    | expr op=('*' | '/' | '%') expr                         # MulExpr
    | expr op=('+' | '-') expr                               # AddExpr
    | expr op=('>' | '<' | '>=' | '<=' | 'gt' | 'lt' | 'ge' | 'le') expr   # RelationalExpr
    | expr op=('==' | '!=' | 'eq' | 'ne') expr               # EqualityExpr
    | expr op=('and' | 'or') expr                            # LogicalExpr
    | <assoc=right> expr '?' expr ':' expr                   # ConditionalExpr
    | '${' expr '}'                                          # VariableExpr
    | '*{' expr '}'                                          # SelectionExpr
    | '#{' messageKey '}'                                    # MessageExpr
    | '@{' linkPath ('(' linkParam (',' linkParam)* ')')? '}'  # LinkExpr
    | UTIL                                                   # UtilityObjectExpr
    | IDENT                                                  # IdentifierExpr
    | STRING                                                 # StringLiteralExpr
    | NUMBER                                                 # NumberLiteralExpr
    | ('true' | 'false')                                     # BooleanLiteralExpr
    | 'null'                                                 # NullLiteralExpr
    | '(' expr ')'                                           # ParenExpr
    ;

messageKey : IDENT ('.' IDENT)* ;

linkPath : linkPart+ ;
linkPart
    : '/' | '.' | '-' | '?' | '&' | '=' | ':'
    | IDENT
    | NUMBER
    | '{' IDENT '}'            // path placeholder {id}
    | '${' expr '}'            // @{${product.image}}
    ;
linkParam : name=IDENT '=' expr ;

// ===================== Lexer =====================
UTIL   : '#' [a-zA-Z_] [a-zA-Z0-9_]* ;          // #lists, #strings ...
STRING : '\'' ( ~['\\] | '\\' . )* '\'' | '"' ( ~["\\] | '\\' . )* '"' ;
NUMBER : [0-9]+ ('.' [0-9]+)? ;
IDENT  : [a-zA-Z_] [a-zA-Z_0-9]* ;
WS     : [ \t\r\n]+ -> skip ;
