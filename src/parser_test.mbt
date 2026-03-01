///|
test "parse_lparen_with_dotted_pair_works" {
  let tokens = [
    Token::new(LParen),
    Token::new(Str, text="Apple"),
    Token::new(Dot),
    Token::new(Str, text="Banana"),
    Token::new(RParen),
    Token::new(EOF),
  ]
  let parser = Parser::new(tokens)

  let v : Array[@src.Sexp[Unit]] = parser.parse()
  assert_eq(v.length(), 1)
  let v = v[0]
  assert_eq(Sexp::Cons(Str("Apple"), Str("Banana")), v)
}

///|
test "parse_lbrack_list_works" {
  let tokens = [
    Token::new(LBrack),
    Token::new(Num, text="1"),
    Token::new(Num, text="2"),
    Token::new(Num, text="3"),
    Token::new(RBrack),
    Token::new(EOF),
  ]

  let parser = Parser::new(tokens)
  let v : Array[Sexp[Unit]] = parser.parse()
  assert_eq(v.length(), 1)
  let v = v[0]
  assert_eq(v, Cons(Num(1.0), Cons(Num(2.0), Cons(Num(3.0), Nil))))
}

///|
test "rosetta_test_suites" {
  let cases = @fs.read_file_to_string("rosetta-lisp/testsuites/parser")
  let cases = cases.split("\n\n")
  let cases_total = cases.count()
  for i, t in cases {
    let sp = t.split("\n").collect()
    let input = sp[0].sub(start=2)
    let want = sp[1]
    try parse(input.to_string())[0] catch {
      UnexpectedToken(_) => assert_eq(want.to_string(), "fail")
    } noraise {
      got => {
        let got : Sexp[Unit] = got
        println("\n\{i}/\{cases_total}")
        debug(got)
        assert_eq(want.to_string(), got.to_string())
      }
    }
  }
}
