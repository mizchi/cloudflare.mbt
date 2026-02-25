///|
extern "js" fn make_container() -> Container =
  #| () => ({
  #|   listProcesses: async () => [
  #|     { id: "p-1", command: "npm run dev", status: "running" },
  #|   ],
  #|   startProcess: async (command, _options) => ({
  #|     id: "p-2",
  #|     command,
  #|     status: "starting",
  #|     waitForPort: async (_port, _opts) => {},
  #|     kill: async () => {},
  #|     getLogs: async () => ({ stdout: "ok", stderr: "" }),
  #|   }),
  #|   exec: async (command, _options) => ({
  #|     success: true,
  #|     command,
  #|   }),
  #|   containerFetch: async (_request, _options) => new Response("ok", { status: 201 }),
  #|   wsConnect: async (_request, _options) => new Response("ws", { status: 202 }),
  #| })

///|
extern "js" fn make_request(url : String) -> @core.Any =
  #| (url) => new Request(url)

///|
extern "js" fn response_status(response : @core.Any) -> Int =
  #| (response) => response.status

///|
extern "js" fn read_bool(obj : @core.Any, key : String) -> Bool =
  #| (obj, key) => Boolean(obj[key])

///|
extern "js" fn read_string(obj : @core.Any, key : String) -> String =
  #| (obj, key) => String(obj[key] ?? "")

///|
async test "containers bindings" {
  let c = make_container()
  let list = c.list_processes()
  assert_eq(list.length(), 1)
  let p = c.start_process("npm run dev")
  assert_eq(p.id(), "p-2")
  assert_eq(p.command(), "npm run dev")
  assert_eq(p.status(), "starting")

  let wait_options = WaitForPortOptions::{
    mode: Some("http"),
    timeout: Some(1000),
  }
  p.wait_for_port(3000, wait_options)
  let logs = p.get_logs()
  assert_eq(read_string(logs, "stdout"), "ok")
  p.kill()

  let exec_result = c.exec("echo hello")
  assert_true(read_bool(exec_result, "success"))
  assert_eq(read_string(exec_result, "command"), "echo hello")

  let req = make_request("https://example.com/")
  let fetch_res = c.container_fetch(req, 8080)
  assert_eq(response_status(fetch_res), 201)
  let ws_res = c.ws_connect(req, 8080)
  assert_eq(response_status(ws_res), 202)
}
