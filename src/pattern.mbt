///|
pub struct Pattern {
  fixed : Array[String]
  rest : String?
}

///|
pub fn[T] Pattern::build(s : Sexp[T]) -> Result[Pattern, Sexp[T]] {
  abort("todo")
}

///|
pub fn[T] Pattern::bind(
  self : Self,
  args : Array[Sexp[T]],
) -> Result[Map[String, Sexp[T]], String] {
  abort("todo")
}
