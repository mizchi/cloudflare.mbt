// Cloudflare AI SDK bindings

///|
extern "js" fn import_cloudflare_ai_sdk() -> @core.Promise[@core.Any] =
  #| async () => {
  #|   if (globalThis.__moonbit_cloudflare_ai_sdk__) {
  #|     return globalThis.__moonbit_cloudflare_ai_sdk__;
  #|   }
  #|   return import("@cloudflare/ai");
  #| }

///|
fn ai_is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
#external
pub type Ai

///|
pub fn Ai::as_any(self : Ai) -> @core.Any = "%identity"

///|
pub(all) struct AiOptions {
  debug : Bool?
  prefix : String?
  extraHeaders : @core.Any?
  overrideSettings : @core.Any?
  fetchUrl : String?
}

///|
pub fn AiOptions::to_js(self : AiOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.debug is Some(v) {
    obj["debug"] = @core.any(v)
  }
  if self.prefix is Some(v) {
    obj["prefix"] = @core.any(v)
  }
  if self.extraHeaders is Some(v) {
    obj["extraHeaders"] = v
  }
  if self.overrideSettings is Some(v) {
    obj["overrideSettings"] = v
  }
  if self.fetchUrl is Some(v) {
    obj["fetchUrl"] = @core.any(v)
  }
  obj
}

///|
pub fn AiOptions::default() -> AiOptions {
  {
    debug: None,
    prefix: None,
    extraHeaders: None,
    overrideSettings: None,
    fetchUrl: None,
  }
}

///|
pub async fn Ai::new(binding : @core.Any, options? : AiOptions) -> Ai {
  let mod = import_cloudflare_ai_sdk().wait()
  let klass : @core.Any = mod["Ai"]
  match options {
    Some(value) => @core.new(klass, [binding, value.to_js()]).cast()
    None => @core.new(klass, [binding]).cast()
  }
}

///|
pub async fn Ai::run(self : Ai, model : String, input : @core.Any) -> @core.Any {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("run", [@core.any(model), input])
    .cast()
  promise.wait()
}

///|
pub fn Ai::get_logs(self : Ai) -> Array[String] {
  self.as_any()._call("getLogs", []).cast()
}

///|
pub fn Ai::last_request_id(self : Ai) -> String? {
  let value = self.as_any()["lastRequestId"]
  if ai_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}
