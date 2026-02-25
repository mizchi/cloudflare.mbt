// Cloudflare Agents bindings

///|
extern "js" fn import_cloudflare_agents() -> @core.Promise[@core.Any] =
  #| async () => {
  #|   if (globalThis.__moonbit_cloudflare_agents__) {
  #|     return globalThis.__moonbit_cloudflare_agents__;
  #|   }
  #|   return import("@cloudflare/agents");
  #| }

///|
fn is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
fn as_int_option(value : @core.Any) -> Int? {
  if is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
fn as_string_option(value : @core.Any) -> String? {
  if is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
pub type AgentContext = @cloudflare.DurableObjectState

///|
pub type AgentNamespace = @cloudflare.DurableObjectNamespace

///|
pub type AgentStub = @cloudflare.DurableObjectStub

///|
#external
pub type WorkflowEntrypoint

///|
pub fn WorkflowEntrypoint::as_any(self : WorkflowEntrypoint) -> @core.Any = "%identity"

///|
#external
pub type Agent

///|
pub fn Agent::as_any(self : Agent) -> @core.Any = "%identity"

///|
pub fn Agent::state(self : Agent) -> @core.Any? {
  let value = self.as_any()["state"]
  if is_js_nullish(value) {
    None
  } else {
    Some(value)
  }
}

///|
pub fn Agent::set_state(self : Agent, state : @core.Any) -> Unit {
  self.as_any()._call("setState", [state]) |> ignore
}

///|
pub async fn Agent::schedule(
  self : Agent,
  when : @core.Any,
  callback : String,
  payload : @core.Any,
) -> AgentSchedule {
  let promise : @core.Promise[AgentSchedule] = self
    .as_any()
    ._call("schedule", [when, @core.any(callback), payload])
    .cast()
  promise.wait()
}

///|
pub async fn Agent::schedule_in(
  self : Agent,
  delay_in_seconds : Int,
  callback : String,
  payload : @core.Any,
) -> AgentSchedule {
  self.schedule(@core.any(delay_in_seconds), callback, payload)
}

///|
pub async fn Agent::schedule_cron(
  self : Agent,
  cron : String,
  callback : String,
  payload : @core.Any,
) -> AgentSchedule {
  self.schedule(@core.any(cron), callback, payload)
}

///|
pub async fn Agent::get_schedule(self : Agent, id : String) -> AgentSchedule? {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("getSchedule", [@core.any(id)])
    .cast()
  let value = promise.wait()
  if is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
pub fn Agent::get_schedules(
  self : Agent,
  criteria? : AgentScheduleCriteria,
) -> Array[AgentSchedule] {
  let result = match criteria {
    Some(value) => self.as_any()._call("getSchedules", [value.to_js()])
    None => self.as_any()._call("getSchedules", [])
  }
  result.cast()
}

///|
pub async fn Agent::cancel_schedule(self : Agent, id : String) -> Bool {
  let promise : @core.Promise[Bool] = self
    .as_any()
    ._call("cancelSchedule", [@core.any(id)])
    .cast()
  promise.wait()
}

///|
pub async fn Agent::alarm(self : Agent) -> Unit {
  let promise : @core.Promise[Unit] = self.as_any()._call("alarm", []).cast()
  promise.wait()
}

///|
pub async fn Agent::destroy(self : Agent) -> Unit {
  let promise : @core.Promise[Unit] = self.as_any()._call("destroy", []).cast()
  promise.wait()
}

///|
#external
pub type AgentSchedule

///|
pub fn AgentSchedule::as_any(self : AgentSchedule) -> @core.Any = "%identity"

///|
pub fn AgentSchedule::id(self : AgentSchedule) -> String {
  self.as_any()["id"].cast()
}

///|
pub fn AgentSchedule::callback(self : AgentSchedule) -> String {
  self.as_any()["callback"].cast()
}

///|
pub fn AgentSchedule::payload(self : AgentSchedule) -> @core.Any {
  self.as_any()["payload"]
}

///|
pub fn AgentSchedule::type_(self : AgentSchedule) -> String {
  self.as_any()["type"].cast()
}

///|
pub fn AgentSchedule::time(self : AgentSchedule) -> Int {
  self.as_any()["time"].cast()
}

///|
pub fn AgentSchedule::delay_in_seconds(self : AgentSchedule) -> Int? {
  as_int_option(self.as_any()["delayInSeconds"])
}

///|
pub fn AgentSchedule::cron(self : AgentSchedule) -> String? {
  as_string_option(self.as_any()["cron"])
}

///|
pub(all) struct AgentScheduleCriteria {
  description : String?
  id : String?
  type_ : String?
  startTime : Int?
  endTime : Int?
}

///|
pub fn AgentScheduleCriteria::to_js(self : AgentScheduleCriteria) -> @core.Any {
  let obj = @core.new_object()
  if self.description is Some(v) {
    obj["description"] = @core.any(v)
  }
  if self.id is Some(v) {
    obj["id"] = @core.any(v)
  }
  if self.type_ is Some(v) {
    obj["type"] = @core.any(v)
  }
  if self.startTime is Some(_) || self.endTime is Some(_) {
    let time_range = @core.new_object()
    if self.startTime is Some(start) {
      time_range["start"] = js_date_from_unix_seconds(start)
    }
    if self.endTime is Some(end) {
      time_range["end"] = js_date_from_unix_seconds(end)
    }
    obj["timeRange"] = time_range
  }
  obj
}

///|
pub fn AgentScheduleCriteria::default() -> AgentScheduleCriteria {
  { description: None, id: None, type_: None, startTime: None, endTime: None }
}

///|
extern "js" fn js_date_from_unix_seconds(seconds : Int) -> @core.Any =
  #| (seconds) => new Date(seconds * 1000)

///|
pub(all) struct AgentLookupOptions {
  jurisdiction : String?
  locationHint : String?
}

///|
pub fn AgentLookupOptions::to_js(self : AgentLookupOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.jurisdiction is Some(v) {
    obj["jurisdiction"] = @core.any(v)
  }
  if self.locationHint is Some(v) {
    obj["locationHint"] = @core.any(v)
  }
  obj
}

///|
pub fn AgentLookupOptions::default() -> AgentLookupOptions {
  { jurisdiction: None, locationHint: None }
}

///|
pub async fn route_agent_request(
  request : @http.Request,
  env : @core.Any,
  options? : @core.Any,
) -> @http.Response? {
  let mod = import_cloudflare_agents().wait()
  let promise : @core.Promise[@core.Any] = match options {
    Some(value) =>
      mod._call("routeAgentRequest", [@core.any(request), env, value]).cast()
    None => mod._call("routeAgentRequest", [@core.any(request), env]).cast()
  }
  let result = promise.wait()
  if is_js_nullish(result) {
    None
  } else {
    Some(result.cast())
  }
}

///|
pub async fn route_agent_email(
  email : @core.Any,
  env : @core.Any,
  options? : @core.Any,
) -> Unit {
  let mod = import_cloudflare_agents().wait()
  let promise : @core.Promise[Unit] = match options {
    Some(value) => mod._call("routeAgentEmail", [email, env, value]).cast()
    None => mod._call("routeAgentEmail", [email, env]).cast()
  }
  promise.wait()
}

///|
pub async fn get_agent_by_name(
  agent_namespace : AgentNamespace,
  name : String,
  options? : AgentLookupOptions,
) -> AgentStub {
  let mod = import_cloudflare_agents().wait()
  let promise : @core.Promise[AgentStub] = match options {
    Some(value) =>
      mod
      ._call("getAgentByName", [
        @core.any(agent_namespace),
        @core.any(name),
        value.to_js(),
      ])
      .cast()
    None =>
      mod
      ._call("getAgentByName", [@core.any(agent_namespace), @core.any(name)])
      .cast()
  }
  promise.wait()
}
