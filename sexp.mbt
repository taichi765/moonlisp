///|
pub struct TCons {
  car : Value
  cdr : Value
}

///|
impl Show for TCons with output(_self : TCons, l : &Logger) -> Unit {
  l.write_string("todo")
}

///|
pub struct TNumber(Float)

///|
impl Show for TNumber with output(self : TNumber, l : &Logger) -> Unit {
  l.write_string(self.0.to_string())
}

///|
pub struct TString(String)

///|
impl Show for TString with output(self : TString, l : &Logger) -> Unit {
  l.write_string("\"" + self.0 + "\"")
}

///|
pub struct TBool(Bool)

///|
impl Show for TBool with output(self : TBool, l : &Logger) -> Unit {
  let str = if self.0 { "#t" } else { "#f" }
  l.write_string(str)
}

///|
pub struct TNil {}

///|
impl Show for TNil with output(_ : TNil, l : &Logger) -> Unit {
  l.write_string("()")
}
