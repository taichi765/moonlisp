///|
pub fn eof() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(0)
}

///|
pub fn error() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(15)
}

///|
pub fn lparen() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(1)
}

///|
pub fn rparen() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(2)
}

///|
pub fn lbrack() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(3)
}

///|
pub fn rblack() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(4)
}

///|
pub fn dot() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(5)
}

///|
pub fn true_() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(6)
}

///|
pub fn false_() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(7)
}

///|
pub fn quote() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(8)
}

///|
pub fn quasi_quote() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(9)
}

///|
pub fn unquote() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(10)
}

///|
pub fn unquote_splicing() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(11)
}

///|
pub fn num() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(12)
}

///|
pub fn sym() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(13)
}

///|
pub fn str() -> @cst.SyntaxKind {
  @cst.SyntaxKind::new(14)
}
