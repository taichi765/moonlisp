///|
pub struct Env[T] {
  current : Map[String, T]
  parent : Env[T]?
}

///|
#warnings("-unused_value")
fn[T] Env::new(parent : Env[T]?) -> Env[T] {
  Env::{ current: Map::new(), parent }
}

///|
#warnings("-unused_value")
fn[T] Env::def(self : Self[T], k : String, v : T) -> Unit {
  self.current.set(k, v)
}

///|
priv suberror KeyNotFoundError

///|
/// Updates the value associated with a key in the environment, searching up the
/// parent chain until the key is found.
///
/// Throws an error of type `KeyNotFoundError` if the key is not found in this
/// environment or any of its parent environments.
///
pub fn[T] Env::set(self : Self[T], k : String, v : T) -> Unit raise {
  if self.current.contains(k) {
    self.current.set(k, v)
  } else if self.parent is Some(e) {
    e.set(k, v)
  } else {
    raise KeyNotFoundError
  }
}

///|
pub fn[T] Env::get(self : Self[T], k : String) -> T? {
  if self.current.get(k) is Some(v) {
    Some(v)
  } else if self.parent is Some(e) {
    e.get(k)
  } else {
    None
  }
}

///|
pub fn[T] Env::contains(self : Self[T], k : String) -> Bool {
  if self.current.contains(k) {
    true
  } else if self.parent is Some(e) {
    e.contains(k)
  } else {
    false
  }
}

///|
pub fn[T] Env::refer(_self : Self[T]) -> Unit {
  // TODO
}
