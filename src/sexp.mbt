///|
pub(all) enum Sexp[T] {
  Num(Float)
  Sym(String)
  Str(String)
  Cons(Sexp[T], Sexp[T])
  Nil
  Bool(Bool)
  Pure(T)
} derive(Eq, Debug)

///|
#warnings("-unused_value")
pub impl[T : Show] Show for Sexp[T] with output(self : Sexp[T], l : &Logger) -> Unit {
  let s = match self {
    Num(n) => n.to_string()
    Str(s) => "\"" + s + "\"" // TODO: エスケープ
    Cons(Sym("quote"), Cons(s, Nil)) => "'" + s.to_string()
    Cons(Sym("quasiquote"), Cons(s, Nil)) => "`" + s.to_string()
    Cons(Sym("unquote"), Cons(s, Nil)) => "," + s.to_string()
    Cons(Sym("unquote-splicing"), Cons(s, Nil)) => ",@" + s.to_string()
    Cons(car, cdr) => fmt_cons(car, cdr)
    Nil => "()"
    Bool(true) => "#t"
    Bool(false) => "#f"
    Sym(s) => s
    Pure(p) => p.to_string()
  }
  l.write_string(s)
}

///|
pub fn[T] Sexp::quote(s : Sexp[T]) -> Sexp[T] {
  Sexp::from_array([Sym("quote"), s])
}

///|
pub fn[T] Sexp::quasi_quote(s : Sexp[T]) -> Sexp[T] {
  Sexp::from_array([Sym("quasiquote"), s])
}

///|
pub fn[T] Sexp::unquote(s : Sexp[T]) -> Sexp[T] {
  Sexp::from_array([Sym("unquote"), s])
}

///|
pub fn[T] Sexp::unquote_splicing(s : Sexp[T]) -> Sexp[T] {
  Sexp::from_array([Sym("unquote-splicing"), s])
}

///|
/// Convert Array to Sexp::Cons
pub fn[T] Sexp::from_array(arr : Array[Sexp[T]]) -> Sexp[T] {
  let rev_cons = arr.rev_fold(init=Sexp::Nil, fn(acc, v) { Sexp::Cons(acc, v) })
  rev_cons.swap_list()
}

///|
/// Returns swapped list. If `self` is not `Cons`, it's just ignored (same value would be returned)
/// # Example
/// ```mbt check
/// test {
///   let list : Sexp[Unit] = Cons(Cons(Nil, Str("Banana")), Str("Apple"))
///   let got = list.swap_list()
///   let wanted : Sexp[Unit] = Cons(Str("Apple"), Sexp::Cons(Str("Banana"), Nil))
///   assert_eq(got, wanted)
/// }
/// ```
pub fn[T] Sexp::swap_list(self : Self[T]) -> Sexp[T] {
  match self {
    Cons(car, cdr) => Cons(cdr.swap_list(), car.swap_list())
    v => v
  }
}

///|
fn[T : Show] fmt_cons(a : Sexp[T], b : Sexp[T]) -> String {
  match b {
    Sexp::Nil => "\{a.to_string()}"
    Sexp::Cons(b, c) => "(\{a} \{fmt_cons(b,c)})"
    b => "(\{a} . \{b})"
  }
}
