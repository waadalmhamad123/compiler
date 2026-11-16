parser grammar HtmlParser;

options { tokenVocab = HtmlLexer; }

document : (DOCTYPE | content)* EOF ;

content
    : element
    | voidElement
    | HTML_COMMENT
    | text
    ;

// <div class="x"> ... </div>   or   <div/>
element
    : TAG_OPEN openName=TAG_NAME attribute*
      ( TAG_SLASH_CLOSE
      | TAG_CLOSE content* TAG_OPEN TAG_SLASH closeName=TAG_NAME TAG_CLOSE )
    ;

// <meta charset="UTF-8">   <img src="x">   <input ...>
voidElement : VOID_TAG_OPEN attribute* (TAG_CLOSE | TAG_SLASH_CLOSE) ;

attribute : name=TAG_NAME (TAG_EQUALS value=ATTR_VALUE)? ;

text : HTML_TEXT ;
