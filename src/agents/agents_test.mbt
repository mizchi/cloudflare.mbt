///|
extern "js" fn install_agents_stub() -> Unit =
  #| () => {
  #|   const calls = {
  #|     routeAgentEmail: 0,
  #|     getAgentByNameName: "",
  #|     getAgentByNameJurisdiction: "",
  #|     getAgentByNameLocationHint: "",
  #|   };
  #|   globalThis.__moonbit_cloudflare_agents_calls__ = calls;
  #|   globalThis.__moonbit_cloudflare_agents__ = {
  #|     routeAgentRequest: async (request, _env, _options) => {
  #|       const url = new URL(request.url);
  #|       if (url.pathname === "/none") return null;
  #|       return new Response("ok", { status: 201 });
  #|     },
  #|     routeAgentEmail: async (_email, _env, _options) => {
  #|       calls.routeAgentEmail += 1;
  #|     },
  #|     getAgentByName: async (namespace, name, options) => {
  #|       calls.getAgentByNameName = name;
  #|       calls.getAgentByNameJurisdiction = options?.jurisdiction ?? "";
  #|       calls.getAgentByNameLocationHint = options?.locationHint ?? "";
  #|       return namespace.get(namespace.idFromName(name));
  #|     },
  #|   };
  #| }

///|
extern "js" fn make_request(url : String) -> @http.Request =
  #| (url) => new Request(url)

///|
extern "js" fn response_status(response : @http.Response) -> Int =
  #| (response) => response.status

///|
extern "js" fn make_fake_namespace() -> @cloudflare.DurableObjectNamespace =
  #| () => ({
  #|   idFromName: (name) => `id:${name}`,
  #|   get: (id) => ({ id, fetch: async () => new Response("stub") }),
  #| })

///|
extern "js" fn durable_stub_id(stub : @cloudflare.DurableObjectStub) -> String =
  #| (stub) => String(stub.id)

///|
extern "js" fn route_agent_email_calls() -> Int =
  #| () => globalThis.__moonbit_cloudflare_agents_calls__.routeAgentEmail

///|
extern "js" fn get_agent_by_name_name() -> String =
  #| () => globalThis.__moonbit_cloudflare_agents_calls__.getAgentByNameName

///|
extern "js" fn get_agent_by_name_jurisdiction() -> String =
  #| () => globalThis.__moonbit_cloudflare_agents_calls__.getAgentByNameJurisdiction

///|
extern "js" fn get_agent_by_name_location_hint() -> String =
  #| () => globalThis.__moonbit_cloudflare_agents_calls__.getAgentByNameLocationHint

///|
extern "js" fn make_fake_agent() -> Agent =
  #| () => {
  #|   let state = undefined;
  #|   const schedules = new Map();
  #|   let seq = 0;
  #|   return {
  #|     get state() {
  #|       return state;
  #|     },
  #|     setState(next) {
  #|       state = next;
  #|     },
  #|     async schedule(when, callback, payload) {
  #|       seq += 1;
  #|       const row = {
  #|         id: `sc-${seq}`,
  #|         callback,
  #|         payload,
  #|         type: typeof when === "number" ? "delayed" : "cron",
  #|         time: 1700000000,
  #|       };
  #|       if (typeof when === "number") row.delayInSeconds = when;
  #|       if (typeof when === "string") row.cron = when;
  #|       schedules.set(row.id, row);
  #|       return row;
  #|     },
  #|     async getSchedule(id) {
  #|       return schedules.get(id);
  #|     },
  #|     getSchedules() {
  #|       return Array.from(schedules.values());
  #|     },
  #|     async cancelSchedule(id) {
  #|       return schedules.delete(id);
  #|     },
  #|     async alarm() {},
  #|     async destroy() {
  #|       state = undefined;
  #|       schedules.clear();
  #|     },
  #|   };
  #| }

///|
extern "js" fn object_get_int(obj : @core.Any, key : String) -> Int =
  #| (obj, key) => Number(obj[key] ?? 0)

///|
async test "agents bindings" {
  install_agents_stub()
  let env = @core.new_object()
  let some_response = route_agent_request(
    make_request("https://example.com/ok"),
    env,
  )
  let status = some_response.map(response_status).unwrap_or(0)
  assert_eq(status, 201)
  let none_response = route_agent_request(
    make_request("https://example.com/none"),
    env,
  )
  assert_true(none_response is None)
  let email = @core.new_object()
  route_agent_email(email, env)
  assert_eq(route_agent_email_calls(), 1)
  let agent_ns = make_fake_namespace()
  let options = AgentLookupOptions::{
    jurisdiction: Some("eu"),
    locationHint: Some("enam"),
  }
  let stub = get_agent_by_name(agent_ns, "assistant", options~)
  assert_eq(durable_stub_id(stub), "id:assistant")
  assert_eq(get_agent_by_name_name(), "assistant")
  assert_eq(get_agent_by_name_jurisdiction(), "eu")
  assert_eq(get_agent_by_name_location_hint(), "enam")
  let agent = make_fake_agent()
  assert_true(agent.state() is None)

  let next_state = @core.new_object()
  next_state["count"] = @core.any(1)
  agent.set_state(next_state)

  let state = match agent.state() {
    Some(value) => value
    None => panic()
  }
  assert_eq(object_get_int(state, "count"), 1)

  let delayed = agent.schedule_in(60, "tick", @core.any("payload"))
  assert_eq(delayed.type_(), "delayed")
  assert_eq(delayed.delay_in_seconds(), Some(60))

  let cron = agent.schedule_cron("*/5 * * * *", "tick", @core.any("payload"))
  assert_eq(cron.type_(), "cron")
  assert_eq(cron.cron(), Some("*/5 * * * *"))

  let by_id = agent.get_schedule(delayed.id())
  assert_true(by_id is Some(_))
  assert_eq(agent.get_schedules().length(), 2)
  assert_true(agent.cancel_schedule(delayed.id()))

  agent.alarm()
  agent.destroy()
  assert_true(agent.state() is None)
}
