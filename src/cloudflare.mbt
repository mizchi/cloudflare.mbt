// WIP

///|
#external
pub type CloudflareEnv

///|
pub fn CloudflareEnv::as_any(self : CloudflareEnv) -> @core.Any = "%identity"

///|
/// Read an environment binding by key.
/// Returns `None` for missing/undefined/null bindings.
pub fn CloudflareEnv::get(self : CloudflareEnv, key : String) -> @core.Any? {
  let value = self.as_any()[key]
  if @core.typeof_(value) == "undefined" || @core.is_null(value) {
    None
  } else {
    Some(value)
  }
}

///|
/// Read a Durable Object namespace binding by key.
pub fn CloudflareEnv::get_durable_object_namespace(
  self : CloudflareEnv,
  key : String,
) -> DurableObjectNamespace? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Rate Limiter binding by key.
pub fn CloudflareEnv::get_rate_limit_binding(
  self : CloudflareEnv,
  key : String,
) -> RateLimitBinding? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read an AI binding by key.
pub fn CloudflareEnv::get_ai_binding(self : CloudflareEnv, key : String) -> AI? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Workflow binding by key.
pub fn CloudflareEnv::get_workflow_binding(
  self : CloudflareEnv,
  key : String,
) -> Workflow? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Sandbox (Container) namespace binding by key.
pub fn CloudflareEnv::get_sandbox_namespace(
  self : CloudflareEnv,
  key : String,
) -> DurableObjectNamespace? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Queue binding by key.
pub fn CloudflareEnv::get_queue_binding(
  self : CloudflareEnv,
  key : String,
) -> Queue? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read an Analytics Engine dataset binding by key.
pub fn CloudflareEnv::get_analytics_engine_binding(
  self : CloudflareEnv,
  key : String,
) -> AnalyticsEngineDataset? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Hyperdrive binding by key.
pub fn CloudflareEnv::get_hyperdrive_binding(
  self : CloudflareEnv,
  key : String,
) -> Hyperdrive? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Send Email binding by key.
pub fn CloudflareEnv::get_send_email_binding(
  self : CloudflareEnv,
  key : String,
) -> SendEmail? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read a Browser Fetcher binding by key.
pub fn CloudflareEnv::get_browser_fetcher_binding(
  self : CloudflareEnv,
  key : String,
) -> BrowserFetcher? {
  match self.get(key) {
    Some(value) => Some(value.cast())
    None => None
  }
}

///|
/// Read an env var as String.
pub fn CloudflareEnv::get_string(self : CloudflareEnv, key : String) -> String? {
  match self.get(key) {
    Some(value) =>
      if @core.typeof_(value) == "string" {
        Some(value.cast())
      } else {
        None
      }
    None => None
  }
}

///|
#external
pub type CloudflareContext

///|
pub fn CloudflareContext::as_any(self : CloudflareContext) -> @core.Any = "%identity"

///|
#alias(wait_until)
pub fn CloudflareContext::waitUntil(
  self : CloudflareContext,
  promise : @core.Promise[Unit],
) -> Unit {
  self.as_any()._call("waitUntil", [@core.any(promise)]) |> ignore
}

///|
#alias(pass_through_exception)
pub fn CloudflareContext::passThroughOnException(
  self : CloudflareContext,
) -> Unit {
  self.as_any()._call("passThroughOnException", []) |> ignore
}

///|
pub(all) struct CloudflareRequest {
  cf : CloudflareContext
  url : String
}

///|
pub fn CloudflareRequest::as_any(self : CloudflareRequest) -> @core.Any = "%identity"

///|
pub fn CloudflareRequest::get_url(self : CloudflareRequest) -> String {
  self.as_any()["url"].cast()
}

///|
pub fn CloudflareRequest::method_(self : CloudflareRequest) -> String {
  self.as_any()["method"].cast()
}

///|
pub fn CloudflareRequest::headers(self : CloudflareRequest) -> @http.Headers {
  self.as_any()["headers"].cast()
}

///|
pub fn CloudflareRequest::header(
  self : CloudflareRequest,
  name : String,
) -> String? {
  self.headers().as_any()._call("get", [@core.any(name)])
  |> @core.identity_option
}

///|
/// CloudflareFetchHandler is a type alias for Cloudflare Worker fetch handler
pub type CloudflareFetchHandler = (
  CloudflareRequest,
  CloudflareEnv,
  CloudflareContext,
) -> @core.Promise[@http.Response]
