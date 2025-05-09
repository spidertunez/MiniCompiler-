// lib/parser/parser.dart
import 'package:untitled9/token.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;
  StringBuffer output = StringBuffer();

  Parser(this.tokens);

  /*
  Grammar based on Example 1 from the document:

  Program -> Stmt_list
  Stmt_list -> Stmt Stmt_list | ε
  Stmt -> id = math_expr ;
        | IF ( logic_expr ) stmt
        | WHILE ( logic_expr ) { Stmt_list }
  math_expr -> math_expr + term
            | math_expr - term
            | term
  term -> term * factor
       | term / factor
       | factor
  factor -> number | id | ( math_expr )
  logic_expr -> math_expr relop math_expr
  relop -> > | >= | < | <= | == | !=
  */

  bool parse() {
    try {
      output.writeln("Starting parsing...");
      program();
      output.writeln("Parsing completed successfully!");
      return true;
    } catch (e) {
      output.writeln("Error: $e");
      return false;
    }
  }

  void program() {
    output.writeln("Program -> Stmt_list");
    stmtList();

    if (!isAtEnd()) {
      throw Exception(
        "Unexpected token after end of program: ${peek().lexeme} at line ${peek().line}",
      );
    }
  }

  void stmtList() {
    output.writeln("Stmt_list -> Stmt Stmt_list | ε");

    if (isAtEnd() || check(TokenType.RIGHT_BRACE)) {
      output.writeln("Stmt_list -> ε (empty)");
      return;
    }

    stmt();
    stmtList();
  }

  void stmt() {
    output.writeln(
      "Stmt -> type id = math_expr ; | IF ( logic_expr ) stmt | WHILE ( logic_expr ) { Stmt_list }",
    );

    if (match([TokenType.IF])) {
      consume(TokenType.LEFT_PAREN, "Expect '(' after 'if'.");
      logicExpr();
      consume(TokenType.RIGHT_PAREN, "Expect ')' after condition.");
      stmt();
    } else if (match([TokenType.WHILE])) {
      consume(TokenType.LEFT_PAREN, "Expect '(' after 'while'.");
      logicExpr();
      consume(TokenType.RIGHT_PAREN, "Expect ')' after condition.");
      consume(TokenType.LEFT_BRACE, "Expect '{' before while body.");
      stmtList();
      consume(TokenType.RIGHT_BRACE, "Expect '}' after while body.");
    } else {
      if (match([TokenType.INT])) {
        output.writeln("Found type declaration: int");
        if (!check(TokenType.IDENTIFIER)) {
          throw Exception(
            "Expected identifier after type at line ${peek().line}",
          );
        }
        Token id = advance();
        output.writeln("Found identifier: ${id.lexeme}");
        consume(TokenType.EQUAL, "Expect '=' after identifier in declaration.");
        mathExpr();
        consume(TokenType.SEMICOLON, "Expect ';' after declaration.");
      } else if (check(TokenType.IDENTIFIER)) {
        Token id = advance();
        output.writeln("Found identifier: ${id.lexeme}");
        consume(TokenType.EQUAL, "Expect '=' after identifier in assignment.");
        mathExpr();
        consume(TokenType.SEMICOLON, "Expect ';' after statement.");
      } else {
        throw Exception("Expected statement at line ${peek().line}");
      }
    }
  }

  void mathExpr() {
    output.writeln("math_expr -> math_expr + term | math_expr - term | term");

    term();

    while (match([TokenType.PLUS, TokenType.MINUS])) {
      Token operator = previous();
      output.writeln("Found operator: ${operator.lexeme}");
      term();
    }
  }

  void term() {
    output.writeln("term -> term * factor | term / factor | factor");

    factor();

    while (match([TokenType.STAR, TokenType.SLASH])) {
      Token operator = previous();
      output.writeln("Found operator: ${operator.lexeme}");
      factor();
    }
  }

  void factor() {
    output.writeln("factor -> number | id | ( math_expr )");

    if (match([TokenType.NUMBER])) {
      output.writeln("Found number: ${previous().lexeme}");
    } else if (match([TokenType.IDENTIFIER])) {
      output.writeln("Found identifier: ${previous().lexeme}");
    } else if (match([TokenType.LEFT_PAREN])) {
      mathExpr();
      consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
    } else {
      throw Exception("Expected expression at line ${peek().line}");
    }
  }

  void logicExpr() {
    output.writeln("logic_expr -> math_expr relop math_expr");

    mathExpr();

    if (match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL,
      TokenType.EQUAL_EQUAL,
      TokenType.NOT_EQUAL,
    ])) {
      Token operator = previous();
      output.writeln("Found relational operator: ${operator.lexeme}");
      mathExpr();
    } else {
      throw Exception("Expected relational operator at line ${peek().line}");
    }
  }

  // Helper methods for the parser

  bool match(List<TokenType> types) {
    for (var type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();
    throw Exception("$message at line ${peek().line}");
  }

  bool check(TokenType type) {
    if (isAtEnd()) return false;
    return peek().type == type;
  }

  Token advance() {
    if (!isAtEnd()) current++;
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.EOF;
  }

  Token peek() {
    return tokens[current];
  }

  Token previous() {
    return tokens[current - 1];
  }

  String getOutput() {
    return output.toString();
  }
}
