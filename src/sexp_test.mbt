///|
test "from_array_works" {
  let arr : Array[Sexp[Unit]] = [Sexp::Str("Apple"), Sexp::Str("Banana")]
  let cons = Sexp::from_array(arr)

  guard cons is Sexp::Cons(car, cdr) else { abort("should be Cons") }
  assert_eq(car, Sexp::Str("Apple"))
  guard cdr is Sexp::Cons(car, cdr) else { abort("should be Cons") }
  assert_eq(car, Sexp::Str("Banana"))
  assert_eq(cdr, Sexp::Nil)
}
