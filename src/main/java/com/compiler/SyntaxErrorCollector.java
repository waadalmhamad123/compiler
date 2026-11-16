package com.compiler.visitor;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

import java.util.List;

public class SyntaxErrorCollector extends BaseErrorListener {
    private final String source;
    private final int lineOffset;
    private final List<String> sink;

    public SyntaxErrorCollector(String source, int lineOffset, List<String> sink) {
        this.source = source;
        this.lineOffset = lineOffset;
        this.sink = sink;
    }

    @Override
    public void syntaxError(Recognizer<?, ?> r, Object offendingSymbol, int line, int charPos, String msg, RecognitionException e) {
        sink.add(source + ":" + (line + lineOffset) + ":" + charPos + "  " + msg);
    }
}
