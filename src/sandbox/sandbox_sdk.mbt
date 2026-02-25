// Cloudflare Sandbox SDK bindings

///|
extern "js" fn import_cloudflare_sandbox_sdk() -> @core.Promise[@core.Any] =
  #| async () => {
  #|   if (globalThis.__moonbit_cloudflare_sandbox_sdk__) {
  #|     return globalThis.__moonbit_cloudflare_sandbox_sdk__;
  #|   }
  #|   return import("@cloudflare/sandbox");
  #| }

///|
fn sandbox_is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
extern "js" fn sandbox_sdk_proxy_to_sandbox(
  mod : @core.Any,
  request : @http.Request,
  env : @core.Any,
) -> @core.Promise[@core.Any] =
  #| (mod, request, env) => mod.proxyToSandbox(request, env)

///|
#external
pub type SandboxSdk

///|
pub fn SandboxSdk::as_any(self : SandboxSdk) -> @core.Any = "%identity"

///|
pub async fn get_sandbox(
  sandbox_namespace : @cloudflare.DurableObjectNamespace,
  id : String,
  options? : @core.Any,
) -> SandboxSdk {
  let mod = import_cloudflare_sandbox_sdk().wait()
  let value = match options {
    Some(opts) =>
      mod._call("getSandbox", [
        @core.any(sandbox_namespace),
        @core.any(id),
        opts,
      ])
    None =>
      mod._call("getSandbox", [@core.any(sandbox_namespace), @core.any(id)])
  }
  value.cast()
}

///|
pub async fn proxy_to_sandbox(
  request : @http.Request,
  env : @core.Any,
) -> @http.Response? {
  let mod = import_cloudflare_sandbox_sdk().wait()
  let promise : @core.Promise[@core.Any] = sandbox_sdk_proxy_to_sandbox(
    mod, request, env,
  )
  let response = promise.wait()
  if sandbox_is_js_nullish(response) {
    None
  } else {
    Some(response.cast())
  }
}

///|
pub async fn SandboxSdk::exec(
  self : SandboxSdk,
  command : String,
  options? : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = match options {
    Some(opts) => self.as_any()._call("exec", [@core.any(command), opts]).cast()
    None => self.as_any()._call("exec", [@core.any(command)]).cast()
  }
  promise.wait()
}

///|
pub async fn SandboxSdk::list_processes(self : SandboxSdk) -> Array[@core.Any] {
  let promise : @core.Promise[Array[@core.Any]] = self
    .as_any()
    ._call("listProcesses", [])
    .cast()
  promise.wait()
}

///|
pub async fn SandboxSdk::write_file(
  self : SandboxSdk,
  path : String,
  content : String,
  options? : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = match options {
    Some(opts) =>
      self
      .as_any()
      ._call("writeFile", [@core.any(path), @core.any(content), opts])
      .cast()
    None =>
      self
      .as_any()
      ._call("writeFile", [@core.any(path), @core.any(content)])
      .cast()
  }
  promise.wait()
}

///|
pub async fn SandboxSdk::read_file(
  self : SandboxSdk,
  path : String,
  options? : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = match options {
    Some(opts) =>
      self.as_any()._call("readFile", [@core.any(path), opts]).cast()
    None => self.as_any()._call("readFile", [@core.any(path)]).cast()
  }
  promise.wait()
}

///|
pub async fn SandboxSdk::expose_port(
  self : SandboxSdk,
  port : Int,
  options : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("exposePort", [@core.any(port), options])
    .cast()
  promise.wait()
}

///|
pub async fn SandboxSdk::unexpose_port(self : SandboxSdk, port : Int) -> Unit {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("unexposePort", [@core.any(port)])
    .cast()
  promise.wait() |> ignore
}

///|
pub async fn SandboxSdk::fetch_request(
  self : SandboxSdk,
  request : @http.Request,
) -> @http.Response {
  let promise : @core.Promise[@http.Response] = self
    .as_any()
    ._call("fetch", [@core.any(request)])
    .cast()
  promise.wait()
}

///|
pub async fn SandboxSdk::fetch_path(
  self : SandboxSdk,
  path : String,
  options? : @core.Any,
) -> @http.Response {
  let promise : @core.Promise[@http.Response] = match options {
    Some(opts) => self.as_any()._call("fetch", [@core.any(path), opts]).cast()
    None => self.as_any()._call("fetch", [@core.any(path)]).cast()
  }
  promise.wait()
}
