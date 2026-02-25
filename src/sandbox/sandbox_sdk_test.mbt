///|
extern "js" fn install_sandbox_sdk_stub() -> Unit =
  #| () => {
  #|   const calls = {
  #|     sandboxId: "",
  #|     normalizeId: false,
  #|     proxyCalls: 0,
  #|   };
  #|   globalThis.__moonbit_cloudflare_sandbox_sdk_calls__ = calls;
  #|   globalThis.__moonbit_cloudflare_sandbox_sdk__ = {
  #|     getSandbox: (_namespace, id, options) => {
  #|       calls.sandboxId = id;
  #|       calls.normalizeId = options?.normalizeId === true;
  #|       return {
  #|         exec: async (command, _options) => ({
  #|           success: true,
  #|           command,
  #|           stdout: `ran:${command}`,
  #|           stderr: "",
  #|           exitCode: 0,
  #|         }),
  #|         listProcesses: async () => [
  #|           { id: "proc-1", command: "npm run dev", status: "running" },
  #|         ],
  #|         writeFile: async (path, content, _options) => ({
  #|           success: true,
  #|           path,
  #|           content,
  #|         }),
  #|         readFile: async (path, _options) => ({
  #|           success: true,
  #|           path,
  #|           content: "hello from sandbox",
  #|         }),
  #|         exposePort: async (port, _options) => ({
  #|           success: true,
  #|           port,
  #|           url: `https://sandbox.example.com:${port}`,
  #|         }),
  #|         unexposePort: async (_port) => {},
  #|         fetch: async (requestOrPath, _options) => {
  #|           if (typeof requestOrPath === "string") {
  #|             return new Response(`path:${requestOrPath}`, { status: 203 });
  #|           }
  #|           return new Response("request", { status: 202 });
  #|         },
  #|       };
  #|     },
  #|     proxyToSandbox: async (request, _env) => {
  #|       calls.proxyCalls += 1;
  #|       const pathname = new URL(request.url).pathname;
  #|       if (pathname === "/proxy-none") return null;
  #|       return new Response("proxied", { status: 200 });
  #|     },
  #|   };
  #| }

///|
extern "js" fn make_sandbox_namespace() -> @cloudflare.DurableObjectNamespace =
  #| () => ({})

///|
extern "js" fn sandbox_stub_id() -> String =
  #| () => globalThis.__moonbit_cloudflare_sandbox_sdk_calls__.sandboxId

///|
extern "js" fn sandbox_stub_normalize_id() -> Bool =
  #| () => globalThis.__moonbit_cloudflare_sandbox_sdk_calls__.normalizeId

///|
extern "js" fn sandbox_stub_proxy_calls() -> Int =
  #| () => globalThis.__moonbit_cloudflare_sandbox_sdk_calls__.proxyCalls

///|
extern "js" fn sandbox_response_status(response : @http.Response) -> Int =
  #| (response) => response.status

///|
extern "js" fn sandbox_make_request(url : String) -> @http.Request =
  #| (url) => new Request(url)

///|
extern "js" fn read_bool(obj : @core.Any, key : String) -> Bool =
  #| (obj, key) => Boolean(obj[key])

///|
extern "js" fn read_string(obj : @core.Any, key : String) -> String =
  #| (obj, key) => String(obj[key] ?? "")

///|
async test "sandbox sdk bindings" {
  install_sandbox_sdk_stub()
  let ns = make_sandbox_namespace()
  let options = @core.new_object()
  options["normalizeId"] = @core.any(true)
  let sandbox = get_sandbox(ns, "my-sandbox", options~)
  assert_eq(sandbox_stub_id(), "my-sandbox")
  assert_true(sandbox_stub_normalize_id())

  let proxy_env = @core.new_object()
  let proxy_response = proxy_to_sandbox(
    sandbox_make_request("https://example.com/proxy"),
    proxy_env,
  )
  assert_eq(proxy_response.map(sandbox_response_status).unwrap_or(0), 200)
  let proxy_none = proxy_to_sandbox(
    sandbox_make_request("https://example.com/proxy-none"),
    proxy_env,
  )
  assert_true(proxy_none is None)
  assert_eq(sandbox_stub_proxy_calls(), 2)

  let exec_result = sandbox.exec("echo hello")
  assert_true(read_bool(exec_result, "success"))
  assert_eq(read_string(exec_result, "stdout"), "ran:echo hello")
  assert_eq(sandbox.list_processes().length(), 1)

  let write_result = sandbox.write_file("/workspace/a.txt", "hello")
  assert_true(read_bool(write_result, "success"))
  let read_result = sandbox.read_file("/workspace/a.txt")
  assert_eq(read_string(read_result, "content"), "hello from sandbox")

  let expose_result = sandbox.expose_port(3000, @core.new_object())
  assert_eq(
    read_string(expose_result, "url"),
    "https://sandbox.example.com:3000",
  )
  sandbox.unexpose_port(3000)
  let fetch_req = sandbox.fetch_request(
    sandbox_make_request("https://example.com/path"),
  )
  assert_eq(sandbox_response_status(fetch_req), 202)
  let fetch_path = sandbox.fetch_path("/health")
  assert_eq(sandbox_response_status(fetch_path), 203)
}
