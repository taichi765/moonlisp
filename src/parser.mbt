///|
/// Parse input string to `Value`
pub fn[T] parse(input : String) -> Array[Sexp[T]] raise UnexpectedToken {
  let tokens = tokenize(input)
  let parser = Parser::new(tokens)
  parser.parse()
}

///|
/// Parser

///|
/// Parser state
pub struct Parser {
  tokens : Array[Token]
  mut pos : Int
  mut deps : UInt
}

///|
pub fn Parser::new(tokens : Array[Token]) -> Parser {
  Parser::{ tokens, pos: 0, deps: 0 }
}

///|
pub suberror UnexpectedToken {
  UnexpectedToken(Token)
}

///|
/// Parse source file
pub fn[T] Parser::parse(self : Parser) -> Array[Sexp[T]] raise UnexpectedToken {
  let values : Array[Sexp[T]] = Array::new()
  while true {
    let s = match self.peek_kind() {
      EOF => break
      LParen => self.parse_lparen()
      LBrack => self.parse_lbrack()
      Quote => {
        self.pos += 1
        let s = self.parse_sexp()
        Sexp::quote(s)
      }
      QuasiQuote => {
        self.pos += 1
        let s = self.parse_sexp()
        Sexp::quasi_quote(s)
      }
      Unquote => {
        self.pos += 1
        let s = self.parse_sexp()
        Sexp::unquote(s)
      }
      UnquoteSplicing => {
        self.pos += 1
        let s = self.parse_sexp()
        Sexp::unquote_splicing(s)
      }
      Sym | Num | Str | True | False => {
        let tok = self.advance()
        match tok {
          t if t.kind == Sym => Sexp::Sym(t.text)
          t if t.kind == Num =>
            Sexp::Num(Float::from_double(try! @strconv.parse_double(t.text)))
          t if t.kind == Str => Sexp::Str(t.text)
          t if t.kind == True => Sexp::Bool(true)
          t if t.kind == False => Sexp::Bool(false)
          _ => abort("unreachable")
        }
      }
      RParen | RBrack | Dot | Error => raise UnexpectedToken(self.advance())
    }
    values.push(s)
  }
  values
}

///|
fn Parser::advance(self : Parser) -> Token {
  let ret = self.peek()
  self.pos += 1
  ret
}

///|
/// Peek current token
fn Parser::peek(self : Parser) -> Token {
  if self.pos >= self.tokens.length() {
    Token::new(EOF)
  } else {
    self.tokens[self.pos]
  }
}

///|
/// Peek token kind
fn Parser::peek_kind(self : Parser) -> TokenKind {
  self.peek().kind()
}

///|
/// Check if at a specific kind
fn Parser::at(self : Parser, kind : TokenKind) -> Bool {
  self.peek_kind() == kind
}

///|
priv suberror ExpectationFailed

///|
/// Expect and consume a specific token kind
fn Parser::expect(self : Parser, kind : TokenKind) -> Unit raise {
  //self.skip_trivia()
  if self.at(kind) {
    self.pos += 1
  } else {
    raise ExpectationFailed
  }
}

///|
#warnings("-unused_value")
fn Parser::current(self : Parser) -> Token {
  self.tokens[self.pos]
}

///|
/// s_expression ::= atomic_symbol 
///      | dotted_pair 
///      | list 
fn[T] Parser::parse_sexp(self : Self) -> Sexp[T] {
  match self.peek_kind() {
    Quote => {
      self.pos += 1
      let s = self.parse_sexp()
      Sexp::quote(s)
    }
    QuasiQuote => {
      self.pos += 1
      let s = self.parse_sexp()
      Sexp::quasi_quote(s)
    }
    Unquote => {
      self.pos += 1
      let s = self.parse_sexp()
      Sexp::unquote(s)
    }
    UnquoteSplicing => {
      self.pos += 1
      let s = self.parse_sexp()
      Sexp::unquote_splicing(s)
    }
    Sym | Num | Str | True | False => {
      let tok = self.advance()
      match tok {
        t if t.kind == Sym => Sexp::Sym(t.text)
        t if t.kind == Num =>
          Sexp::Num(Float::from_double(try! @strconv.parse_double(t.text)))
        t if t.kind == Str => Sexp::Str(t.text)
        t if t.kind == True => Sexp::Bool(true)
        t if t.kind == False => Sexp::Bool(false)
        _ => abort("unreachable")
      }
    }
    LParen => self.parse_lparen()
    LBrack => self.parse_lbrack()
    EOF | RBrack | RParen | Dot | Error => abort("unexpected token")
  }
}

///|
/// list ::= "(" s_expression { s_expression } ")" 
/// dotted_pair ::= "(" s_expression "." s_expression ")"
/// nil ::= "()"
fn[T] Parser::parse_lparen(self : Self) -> Sexp[T] {
  try! self.expect(LParen)
  self.deps += 1

  if self.peek_kind() == RParen {
    self.pos += 1
    return Sexp::Nil
  }

  let list = Array::new()
  let mut is_dotted = false // TODO: 汚い
  let mut idx = 0

  while true {
    let s = match self.peek_kind() {
      LBrack => {
        self.pos += 1
        idx += 1
        self.parse_lbrack()
      }
      LParen => {
        self.pos += 1
        idx += 1
        self.parse_lparen()
      }
      Quote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::quote(s)
      }
      QuasiQuote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::quasi_quote(s)
      }
      Unquote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::unquote(s)
      }
      UnquoteSplicing => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::unquote_splicing(s)
      }
      Sym | Num | Str | True | False => {
        let tok = self.advance()
        idx += 1
        match tok {
          t if t.kind == Sym => Sexp::Sym(t.text)
          t if t.kind == Num =>
            Sexp::Num(Float::from_double(try! @strconv.parse_double(t.text)))
          t if t.kind == Str => Sexp::Str(t.text)
          t if t.kind == True => Sexp::Bool(true)
          t if t.kind == False => Sexp::Bool(false)
          _ => abort("unreachable")
        }
      }
      Dot =>
        if idx == 1 {
          self.pos += 1
          let next = self.parse_sexp()
          try! self.expect(RParen)
          is_dotted = true
          list.push(next)
          break
        } else {
          abort("unexpected token")
        }
      RParen => {
        self.pos += 1
        break
      }
      EOF | Error | RBrack => abort("unexpected token")
    }
    list.push(s)
  }
  if is_dotted {
    Sexp::Cons(list[0], list[1])
  } else {
    Sexp::from_array(list)
  }
}

///|
fn[T] Parser::parse_lbrack(self : Self) -> Sexp[T] {
  try! self.expect(LBrack)
  self.deps += 1

  if self.peek_kind() == RBrack {
    self.pos += 1
    return Sexp::Nil
  }

  let list = Array::new()
  let mut idx = 0

  while true {
    let s = match self.peek_kind() {
      LBrack => {
        self.pos += 1
        idx += 1
        self.parse_lbrack()
      }
      LParen => {
        self.pos += 1
        idx += 1
        self.parse_lparen()
      }
      Quote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::quote(s)
      }
      QuasiQuote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::quasi_quote(s)
      }
      Unquote => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::unquote(s)
      }
      UnquoteSplicing => {
        self.pos += 1
        idx += 1
        let s = self.parse_sexp()
        Sexp::unquote_splicing(s)
      }
      Sym | Num | Str | True | False => {
        let tok = self.advance()
        idx += 1
        match tok {
          t if t.kind == Sym => Sexp::Sym(t.text)
          t if t.kind == Num =>
            Sexp::Num(Float::from_double(try! @strconv.parse_double(t.text)))
          t if t.kind == Str => Sexp::Str(t.text)
          t if t.kind == True => Sexp::Bool(true)
          t if t.kind == False => Sexp::Bool(false)
          _ => abort("unreachable")
        }
      }
      Dot =>
        if idx == 1 {
          self.pos += 1
          let next = self.parse_sexp()
          list.push(next)
          break
        } else {
          abort("unexpected token")
        }
      RBrack => {
        self.pos += 1
        break
      }
      EOF | RParen | Error => abort("unexpected token")
    }

    list.push(s)
  }
  Sexp::from_array(list)
}
