///|
pub struct Context {
  toplevel : Env[Value]
  builtins : &BuiltinRegistry
}

///|
pub fn Context::compile() -> Unit {

}

///|
pub fn Context::eval(self : Self, expr : Value) -> Value {
  Sexp::Nil
}

///|
pub struct BuiltinRegistryImpl {}
