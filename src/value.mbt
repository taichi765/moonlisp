///|
#warnings("-unused_constructor")
pub enum Native {
  Builtin(&Builtin)
  Syntax(&ISyntax)
  Fun(Closure)
  Macro(Closure)
  Vec(Array[Value])
}

///|
trait ISyntax {}

///|
type Value = Sexp[Native]

///|
pub struct Closure {
  env : Env[Value]
  pattern : Pattern
  body : Code[Value]
}

///|
pub trait Builtin {
  run(self : Self, vm : &VM, values : Array[Value]) -> Unit
}

///|
pub trait VM {
  push(self : Self, v : Value) -> Unit
  apply(self : Self, f : Value, args : Array[Value]) -> Unit
  apply_never(self : Self, f : Value, args : Array[Value]) -> Unit
  apply_cont(self : Self, c : Cont) -> Unit
  capture_cont(self : Self) -> Cont
  context(self : Self) -> Context
}

///|
pub struct Cont {
  stack : Array[Value]
  env : Env[Value]
  code : Code[Value]
  dump : Array[(Env[Value], Code[Value])]
}

///|
pub trait MacroExpander {
  expand(self : Self, flag : Bool, v : Value) -> Value
}

///|
pub trait Compiler {
  do(inst : Inst[Value]) -> Unit
  eval(expr : Value) -> Unit
  block(f : (Self) -> Unit) -> Code[Value]
}

///|
pub trait BuiltinRegistry {
  get(self : Self, k : String) -> &Builtin?
}
