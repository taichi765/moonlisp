///|
pub enum Value {
  Number(TNumber)
  Sym
  String(TString)
  Cons(TCons)
  Nil(TNil)
  Bool(TBool)
  Fun
  Builtin
  Macro
  Syntax
  Vec
} derive(Show)
