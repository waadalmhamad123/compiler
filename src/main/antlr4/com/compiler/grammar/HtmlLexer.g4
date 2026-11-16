lexer grammar HtmlLexer;

// ===================== Default mode: content between tags =====================
HTML_COMMENT : '<!--' .*? '-->' ;
DOCTYPE      : '<!' [dD][oO][cC][tT][yY][pP][eE] ~'>'* '>' ;

// void elements (no closing tag): <meta>, <link>, <img>, <input>, <br>, <hr>
VOID_TAG_OPEN
    : '<' ('meta' | 'link' | 'img' | 'input' | 'br' | 'hr')
      { !Character.isLetterOrDigit(_input.LA(1)) && _input.LA(1) != '-' }?
      -> pushMode(TAG)
    ;

TAG_OPEN  : '<' -> pushMode(TAG) ;
HTML_TEXT : ~[<]+ ;

// ===================== Inside a tag =====================
mode TAG;

TAG_CLOSE        : '>'  -> popMode ;
TAG_SLASH_CLOSE  : '/>' -> popMode ;
TAG_SLASH        : '/' ;
TAG_EQUALS       : '=' ;
ATTR_VALUE       : '"' ~["]* '"' | '\'' ~[']* '\'' ;
TAG_NAME         : [a-zA-Z_:@] [a-zA-Z0-9_:.\-]* ;
TAG_WS           : [ \t\r\n]+ -> skip ;
