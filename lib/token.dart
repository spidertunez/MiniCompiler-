// lib/models/token.dart
enum TokenType {
  // Single character tokens
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACE,
  RIGHT_BRACE,
  SEMICOLON,
  PLUS,
  MINUS,
  STAR,
  SLASH,

  // One or two character tokens
  EQUAL,
  EQUAL_EQUAL,
  GREATER,
  GREATER_EQUAL,
  LESS,
  LESS_EQUAL,
  NOT_EQUAL,

  // Literals
  IDENTIFIER,
  NUMBER,

  // Keywords
  IF,
  WHILE,
  BEGIN,
  END,
  INT,

  EOF,
}

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() {
    return '$type $lexeme ${literal ?? ""}';
  }
}
