package com.compiler;

import com.compiler.grammar.*;
import com.compiler.visitor.SyntaxErrorCollector;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;

import java.io.IOException;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {

    public static void main(String[] args) throws IOException {
        Locale.setDefault(Locale.ENGLISH);
        Path root = Paths.get(args.length > 0 ? args[0] : "test-files");
        List<String> errors = new ArrayList<>();

        // ---------------- Java (Spring Boot) ----------------
        for (Path p : find(root, ".java")) {
            parseJava(p, errors);
        }

        // ---------------- HTML + Thymeleaf ----------------
        for (Path p : find(root, ".html")) {
            parseHtml(p, errors);
        }

        // ---------------- CSS ----------------
        for (Path p : find(root, ".css")) {
            parseCss(p, errors);
        }

        // ---------------- Output Errors ----------------
        System.out.println("==========================================");
        if (!errors.isEmpty()) {
            System.out.println("SYNTAX / LEXICAL ERRORS (" + errors.size() + "):");
            errors.forEach(System.out::println);
        } else {
            System.out.println("LEXER & PARSER COMPLETED SUCCESSFULLY (0 errors).");
        }
    }

    // ============================================================ Parsing Helpers
    private static void parseJava(Path p, List<String> errors) throws IOException {
        String name = p.getFileName().toString();
        JavaSubsetLexer lx = new JavaSubsetLexer(CharStreams.fromPath(p));
        lx.removeErrorListeners();
        lx.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        CommonTokenStream tokens = new CommonTokenStream(lx);
        JavaSubsetParser ps = new JavaSubsetParser(tokens);
        ps.removeErrorListeners();
        ps.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        ParseTree tree = ps.compilationUnit();
        printPhaseOutput(name, lx, tokens, ps, tree);
    }

    private static void parseHtml(Path p, List<String> errors) throws IOException {
        String name = p.getFileName().toString();
        HtmlLexer lx = new HtmlLexer(CharStreams.fromPath(p));
        lx.removeErrorListeners();
        lx.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        CommonTokenStream tokens = new CommonTokenStream(lx);
        HtmlParser ps = new HtmlParser(tokens);
        ps.removeErrorListeners();
        ps.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        ParseTree tree = ps.document();
        printPhaseOutput(name, lx, tokens, ps, tree);
    }

    private static void parseCss(Path p, List<String> errors) throws IOException {
        String name = p.getFileName().toString();
        CssLexer lx = new CssLexer(CharStreams.fromPath(p));
        lx.removeErrorListeners();
        lx.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        CommonTokenStream tokens = new CommonTokenStream(lx);
        CssParser ps = new CssParser(tokens);
        ps.removeErrorListeners();
        ps.addErrorListener(new SyntaxErrorCollector(name, 0, errors));

        ParseTree tree = ps.stylesheet();
        printPhaseOutput(name, lx, tokens, ps, tree);
    }

    // ============================================================ Print Lexer & Parser Results
    private static void printPhaseOutput(String fileName, Lexer lexer, CommonTokenStream tokens, Parser parser, ParseTree tree) {
        System.out.println("\n==================== FILE: " + fileName + " ====================");

        // 1. Lexer Output (Tokens)
        System.out.println("--- [1] LEXER TOKENS ---");
        tokens.fill();
        for (Token t : tokens.getTokens()) {
            if (t.getType() != Token.EOF) {
                String tokenName = lexer.getVocabulary().getSymbolicName(t.getType());
                if (tokenName == null) {
                    tokenName = lexer.getVocabulary().getLiteralName(t.getType());
                }
                System.out.printf("Line %-3d | %-22s | %s%n", t.getLine(), tokenName, t.getText().replace("\n", "\\n").replace("\r", ""));
            }
        }

        // 2. Parser Output (Parse Tree)
        System.out.println("\n--- [2] PARSE TREE ---");
        System.out.println(tree.toStringTree(parser));
    }

    private static List<Path> find(Path root, String ext) throws IOException {
        try (Stream<Path> s = Files.walk(root)) {
            return s.filter(Files::isRegularFile)
                    .filter(f -> f.toString().endsWith(ext))
                    .sorted()
                    .collect(Collectors.toList());
        }
    }
}