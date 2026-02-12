// Cloudflare Workers AI bindings

///|
/// Cloudflare AI binding (`[ai]` in wrangler).
#external
pub type AI

///|
pub fn AI::as_any(self : AI) -> @core.Any = "%identity"

///|
/// Run a model with input payload.
pub async fn AI::run(self : AI, model : String, input : @core.Any) -> @core.Any {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("run", [@core.any(model), input])
    .cast()
  promise.wait()
}

///|
/// Run a model with explicit options.
pub async fn AI::run_with_options(
  self : AI,
  model : String,
  input : @core.Any,
  options : @core.Any,
) -> @core.Any {
  let promise : @core.Promise[@core.Any] = self
    .as_any()
    ._call("run", [@core.any(model), input, options])
    .cast()
  promise.wait()
}
