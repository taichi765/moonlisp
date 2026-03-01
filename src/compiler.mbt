///|
pub struct CompilerImpl {
  env : Env[Value]
}

///|
pub fn CompilerImpl::new(env : Env[Value]) -> Self {
  CompilerImpl::{ env, }
}

///|
fn CompilerImpl::compile() -> Unit {

}
