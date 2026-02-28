///|
pub struct Env {
  current : Map[String, Value]
  parent : Env?
}

///|
fn Env::new(parent : Env?) -> Env {
  Env::{ current: Map::new(), parent }
}

///|
fn Env::def(self : Self, k : String, v : Value) -> Unit {
  self.current.set(k, v)
}

///|
suberror KeyNotFoundError

///|
/// Updates the value associated with a key in the environment, searching up the
/// parent chain until the key is found.
///
/// Throws an error of type `KeyNotFoundError` if the key is not found in this
/// environment or any of its parent environments.
///
pub fn Env::set(self : Self, k : String, v : Value) -> Unit raise {
  if self.current.contains(k) {
    self.current.set(k, v)
  } else if self.parent is Some(e) {
    e.set(k, v)
  } else {
    raise KeyNotFoundError
  }
}

///|
pub fn Env::get(self : Self, k : String) -> Value? {
  if self.current.get(k) is Some(v) {
    Some(v)
  } else if self.parent is Some(e) {
    e.get(k)
  } else {
    None
  }
}

///|
pub fn Env::contains(self : Self, k : String) -> TBool {
  if self.current.contains(k) {
    true
  } else if self.parent is Some(e) {
    e.contains(k)
  } else {
    false
  }
}

///|
pub fn Env::refer(_self : Self) -> Unit {
  // TODO
}
