///|
/// Instructions
#warnings("-unused_constructor")
pub enum Inst[T] {
  Ldc(T)
  Ldv(String)
  Ldf
  Ldm
  Ldb(String)
  Sel(Code[T], Code[T])
  App(Int)
  Leave
  Pop
  Def(String)
  Set(String)
}

///|
#warnings("-unused_constructor")
pub struct Code[T](Array[Inst[T]])
