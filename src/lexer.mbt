///|
/// Tokenize entire input
pub fn tokenize(input : String) -> Array[Token] {
  let lexer = Lexer::new(input)
  let tokens : Array[Token] = []
  while not(lexer.is_eof()) {
    tokens.push(lexer.next_token())
  }
  tokens.push(Token::new(EOF))
  tokens
}

///|
pub(all) enum TokenKind {
  EOF
  Error
  LParen
  RParen
  LBrack
  RBrack
  Dot
  Quote
  QuasiQuote
  Unquote
  UnquoteSplicing
  True
  False
  Num
  Sym
  Str
} derive(Show, Eq)

///|
/// Token produced by the lexer
pub struct Token {
  kind : TokenKind
  text : String
} derive(Show, Eq)

///|
pub fn Token::new(kind : TokenKind, text? : String = "") -> Token {
  Token::{ kind, text }
}

///|
pub fn Token::kind(self : Self) -> TokenKind {
  self.kind
}

///|
pub fn Token::text(self : Self) -> String {
  self.text
}

///|
pub struct Lexer {
  source : String
  mut pos : Int
}

///|
pub fn Lexer::new(source : String) -> Lexer {
  Lexer::{ source, pos: 0 }
}

///|
fn Lexer::peek(self : Lexer) -> Char? {
  if self.pos >= self.source.length() {
    None
  } else {
    Some(self.source[self.pos].to_int().unsafe_to_char())
  }
}

///|
fn Lexer::advance(self : Lexer) -> Char? {
  match self.peek() {
    Some(c) => {
      self.pos += 1
      Some(c)
    }
    None => None
  }
}

///|
fn is_alphabet(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn is_alphabet_or_digit(c : Char) -> Bool {
  is_alphabet(c) || is_digit(c)
}

///|
fn is_whitespace_char(c : Char) -> Bool {
  c == ' ' || c == '\t'
}

///|
fn is_special(c : Char) -> Bool {
  match c {
    '!'
    | '$'
    | '%'
    | '&'
    | '*'
    | '+'
    | '-'
    | '/'
    | ':'
    | '<'
    | '='
    | '>'
    | '?'
    | '@'
    | '^'
    | '_'
    | '~' => true
    _ => false
  }
}

///|
fn Lexer::slice_from(self : Lexer, start : Int) -> String {
  let buf = StringBuilder::new()
  for i = start; i < self.pos; i = i + 1 {
    buf.write_char(self.source[i].to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
/// Lex a single token
pub fn Lexer::next_token(self : Lexer) -> Token {
  match self.peek() {
    None => Token::new(EOF)
    Some(c) =>
      match c {
        c if is_whitespace_char(c) => {
          let _ = self.advance()
          return self.next_token()
        }
        '(' => {
          let _ = self.advance()
          return Token::new(LParen)
        }
        ')' => {
          let _ = self.advance()
          return Token::new(RParen)
        }
        '[' => {
          let _ = self.advance()
          return Token::new(LBrack)
        }
        ']' => {
          let _ = self.advance()
          return Token::new(RBrack)
        }
        '.' => {
          let _ = self.advance()
          return Token::new(Dot)
        }
        '#' => {
          let _ = self.advance()
          return match self.peek() {
            Some('t') => Token::new(True)
            Some('f') => Token::new(False)
            c =>
              Token::new(
                Error,
                text="unexpected character after '#': " + c.to_string(),
              )
          }
        }
        '\'' => {
          let _ = self.advance()
          return Token::new(Quote)
        }
        '`' => return Token::new(QuasiQuote)
        ',' => {
          let _ = self.advance()
          return if self.peek() == Some('@') {
            let _ = self.advance()
            Token::new(UnquoteSplicing)
          } else {
            Token::new(Unquote)
          }
        }
        c if is_special(c) || is_alphabet(c) => {
          let start = self.pos
          while (match self.peek() {
                  Some(ch) if is_special(ch) || is_alphabet_or_digit(ch) => true
                  _ => false
                }) {
            let _ = self.advance()
          }
          let text = self.slice_from(start)
          return Token::new(Sym, text~)
        }
        c if is_digit(c) => {
          let start = self.pos
          while (match self.peek() {
                  Some(ch) => is_digit(ch)
                  None => false
                }) {
            let _ = self.advance()
          }
          let text = self.slice_from(start)
          return Token::new(Num, text~)
        }
        '"' => {
          let start = self.pos
          while (match self.peek() {
                  Some(_) => true
                  None => false
                }) {
            let _ = self.advance()
            if c == '"' {
              let text = self.slice_from(start)
              return Token::new(Str, text~) // TODO: エスケープなど
            }
          }
          return Token::new(EOF)
        }
        c => {
          let _ = self.advance()
          return Token::new(Error, text="unknow character" + c.to_string())
        }
      }
  }
}

///|
/// Check if lexer is at end
pub fn Lexer::is_eof(self : Lexer) -> Bool {
  self.pos >= self.source.length()
}
