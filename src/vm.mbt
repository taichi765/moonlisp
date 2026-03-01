///|
pub struct VMImpl {
  context : Context
  mut stack : Array[Value]
  mut env : Env[Value]
  mut code : Code[Value]
  mut dump : Array[(Env[Value], Code[Value])]
}

///|
pub fn VMImpl::new(
  context : Context,
  env : Env[Value],
  code : Code[Value],
) -> Self {
  VMImpl::{ context, stack: [], env, code, dump: [] }
}

///|
fn VMImpl::enter(
  self : Self,
  next_env : Env[Value],
  next_code : Code[Value],
) -> Unit {
  match self.code {
    Code([Inst::Leave]) => ()
    _ => self.dump.insert(0, (self.env, self.code))
  }
  self.env = next_env
  self.code = next_code
}

///|
impl VM for VMImpl with push(self : VMImpl, v : Value) -> Unit {
  self.stack.push(v)
}

///|
impl VM for VMImpl with apply(self : VMImpl, f : Value, args : Array[Value]) -> Unit {
  match f {
    Pure(Native::Builtin(b)) => {
      args.insert(0, f)
      b.run(self, args)
    }
    Pure(Native::Fun(closure)) => {
      let env = Env::new(Some(closure.env))
      match closure.pattern.bind(args) {
        Ok(map) => {
          for k, v in map {
            env.def(k, v)
          }
          self.enter(env, closure.body)
        }
        Err(e) => abort("failed to run function: " + e)
      }
    }
    _ => abort("todo")
  }
}

///|
impl VM for VMImpl with apply_never(
  self : VMImpl,
  f : Value,
  args : Array[Value],
) -> Unit {
  self.stack = []
  self.code = Code([Inst::Leave])
  self.dump = []
  self.apply(f, args)
}

///|
impl VM for VMImpl with apply_cont(self : VMImpl, c : Cont) -> Unit {
  self.stack = c.stack
  self.env = c.env
  self.code = c.code
  self.dump = c.dump
}

///|
impl VM for VMImpl with capture_cont(self : VMImpl) -> Cont {
  Cont::{ stack: self.stack, env: self.env, code: self.code, dump: self.dump }
}

///|
impl VM for VMImpl with context(self : VMImpl) -> Context {
  self.context
}
