// Cloudflare Rate Limiting bindings

///|
/// Cloudflare Rate Limiter binding (`[[ratelimits]]` in wrangler).
#external
pub type RateLimitBinding

///|
pub fn RateLimitBinding::as_any(self : RateLimitBinding) -> @core.Any = "%identity"

///|
pub(all) struct RateLimitResult {
  success : Bool
}

///|
pub fn RateLimitResult::as_any(self : RateLimitResult) -> @core.Any = "%identity"

///|
pub fn RateLimitResult::success(self : RateLimitResult) -> Bool {
  self.as_any()["success"].cast()
}

///|
/// Apply rate limit with a key.
/// Returns `true` when request is allowed.
pub async fn RateLimitBinding::limit(self : RateLimitBinding, key : String) -> Bool {
  let payload = @core.new_object()
  payload["key"] = @core.any(key)
  let promise : @core.Promise[@core.Any] = self.as_any()._call("limit", [payload]).cast()
  let raw = promise.wait()
  if @core.typeof_(raw) == "undefined" || @core.is_null(raw) {
    false
  } else {
    let result : RateLimitResult = raw.cast()
    result.success()
  }
}
