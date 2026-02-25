// Cloudflare Containers bindings

///|
#external
pub type Container

///|
pub fn Container::as_any(self : Container) -> @core.Any = "%identity"

///|
/// List all processes running in the container.
pub async fn Container::list_processes(
  self : Container,
) -> Array[ContainerProcess] {
  let promise : @core.Promise[Array[ContainerProcess]] = @core.any(self)
    ._call("listProcesses", [])
    .cast()
  promise.wait()
}

///|
/// Start a new process in the container.
pub async fn Container::start_process(
  self : Container,
  command : String,
  options? : @core.Any,
) -> ContainerProcess {
  let promise : @core.Promise[ContainerProcess] = match options {
    Some(opts) =>
      @core.any(self)._call("startProcess", [@core.any(command), opts]).cast()
    None => @core.any(self)._call("startProcess", [@core.any(command)]).cast()
  }
  promise.wait()
}

///|
/// Execute a command in the container.
pub async fn Container::exec(
  self : Container,
  command : String,
  options? : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = match options {
    Some(opts) =>
      @core.any(self)._call("exec", [@core.any(command), opts]).cast()
    None => @core.any(self)._call("exec", [@core.any(command)]).cast()
  }
  promise.wait()
}

///|
/// Fetch from the container, proxying to the given port.
pub async fn Container::container_fetch(
  self : Container,
  request : @core.Any,
  port : Int,
) -> @core.Any {
  let options = @core.new_object()
  options["port"] = @core.any(port)
  let promise : @core.Promise[@core.Any] = @core.any(self)
    ._call("containerFetch", [request, options])
    .cast()
  promise.wait()
}

///|
/// Connect WebSocket to the container on the given port.
pub async fn Container::ws_connect(
  self : Container,
  request : @core.Any,
  port : Int,
) -> @core.Any {
  let options = @core.new_object()
  options["port"] = @core.any(port)
  let promise : @core.Promise[@core.Any] = @core.any(self)
    ._call("wsConnect", [request, options])
    .cast()
  promise.wait()
}

// --- ContainerProcess ---

///|
#external
pub type ContainerProcess

///|
pub fn ContainerProcess::as_any(self : ContainerProcess) -> @core.Any = "%identity"

///|
/// Get process ID.
pub fn ContainerProcess::id(self : ContainerProcess) -> String {
  self.as_any()["id"].cast()
}

///|
/// Get process command string.
pub fn ContainerProcess::command(self : ContainerProcess) -> String {
  self.as_any()["command"].cast()
}

///|
/// Get process status ("starting", "running", etc.).
pub fn ContainerProcess::status(self : ContainerProcess) -> String {
  self.as_any()["status"].cast()
}

///|
/// Wait for a port to become available on the process.
pub async fn ContainerProcess::wait_for_port(
  self : ContainerProcess,
  port : Int,
  options : WaitForPortOptions,
) -> Unit {
  let promise : @core.Promise[Unit] = @core.any(self)
    ._call("waitForPort", [@core.any(port), options.to_js()])
    .cast()
  promise.wait()
}

///|
/// Kill the process.
pub async fn ContainerProcess::kill(self : ContainerProcess) -> Unit {
  let promise : @core.Promise[Unit] = @core.any(self)._call("kill", []).cast()
  promise.wait()
}

///|
/// Get process logs (returns `{ stdout, stderr }`).
pub async fn ContainerProcess::get_logs(self : ContainerProcess) -> @core.Any {
  let promise : @core.Promise[@core.Any] = @core.any(self)
    ._call("getLogs", [])
    .cast()
  promise.wait()
}

// --- Options ---

///|
/// Options for `ContainerProcess::wait_for_port`.
pub(all) struct WaitForPortOptions {
  mode : String? // "tcp" | "http"
  timeout : Int? // milliseconds
}

///|
pub fn WaitForPortOptions::to_js(self : WaitForPortOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.mode is Some(v) {
    obj["mode"] = @core.any(v)
  }
  if self.timeout is Some(v) {
    obj["timeout"] = @core.any(v)
  }
  obj
}
