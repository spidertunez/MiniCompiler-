// lib/scanner/scanner.dart
import 'package:untitled9/token.dart';

class Scanner {
  final String source;
  final List<Token> tokens = [];

  int start = 0;
  int current = 0;
  int line = 1;

  // Keywords map
  final Map<String, TokenType> keywords = {
    'if': TokenType.IF,
    'while': TokenType.WHILE,
    'begin': TokenType.BEGIN,
    'end': TokenType.END,
    'IF': TokenType.IF,
    'WHILE': TokenType.WHILE,
    'BEGIN': TokenType.BEGIN,
    'END': TokenType.END,
    'int': TokenType.INT,
    'INT': TokenType.INT,
  };

  Scanner(this.source);

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      // Beginning of the next lexeme
      start = current;
      scanToken();
    }

    tokens.add(Token(TokenType.EOF, "", null, line));
    return tokens;
  }

  void scanToken() {
    final c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;
      case ';':
        addToken(TokenType.SEMICOLON);
        break;
      case '+':
        addToken(TokenType.PLUS);
        break;
      case '-':
        addToken(TokenType.MINUS);
        break;
      case '*':
        addToken(TokenType.STAR);
        break;
      case '/':
        addToken(TokenType.SLASH);
        break;

      case '=':
        addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '>':
        addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '<':
        addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '!':
        addToken(
          match('=') ? TokenType.NOT_EQUAL : TokenType.NOT_EQUAL,
        ); // Simplified for now
        break;

      // Ignore whitespace
      case ' ':
      case '\r':
      case '\t':
        break;

      case '\n':
        line++;
        break;

      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          // We'll just ignore unrecognized characters for now
          // In a real compiler, you would report an error
        }
        break;
    }
  }

  void identifier() {
    while (isAlphaNumeric(peek())) advance();

    // Check if the identifier is a reserved word
    String text = source.substring(start, current);

    TokenType type = keywords[text] ?? TokenType.IDENTIFIER;
    addToken(type);
  }

  void number() {
    while (isDigit(peek())) advance();

    // Look for a fractional part
    if (peek() == '.' && isDigit(peekNext())) {
      // Consume the "."
      advance();

      while (isDigit(peek())) advance();
    }

    addToken(TokenType.NUMBER, double.parse(source.substring(start, current)));
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;

    current++;
    return true;
  }

  String peek() {
    if (isAtEnd()) return String.fromCharCode(0);
    return source[current];
  }

  String peekNext() {
    if (current + 1 >= source.length) return String.fromCharCode(0);
    return source[current + 1];
  }

  bool isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) ||
        c == '_';
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }

  bool isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool isAtEnd() {
    return current >= source.length;
  }

  String advance() {
    return source[current++];
  }

  void addToken(TokenType type, [Object? literal]) {
    String text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
  }
}
