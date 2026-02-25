// Cloudflare Turnstile verification bindings

///|
let turnstile_siteverify_endpoint = "https://challenges.cloudflare.com/turnstile/v0/siteverify"

///|
fn turnstile_is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
fn turnstile_as_string_option(value : @core.Any) -> String? {
  if turnstile_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
extern "js" fn turnstile_js_null() -> @core.Any =
  #| null

///|
extern "js" fn turnstile_verify_request(
  fetch_impl : @core.Any,
  endpoint : String,
  secret : String,
  response : String,
  remote_ip : @core.Any,
  idempotency_key : @core.Any,
) -> @core.Promise[@core.Any] =
  #| async (fetchImpl, endpoint, secret, response, remoteIp, idempotencyKey) => {
  #|   const doFetch = fetchImpl == null ? globalThis.fetch : fetchImpl;
  #|   const params = new URLSearchParams();
  #|   params.set("secret", secret);
  #|   params.set("response", response);
  #|   if (remoteIp !== undefined && remoteIp !== null) {
  #|     params.set("remoteip", String(remoteIp));
  #|   }
  #|   if (idempotencyKey !== undefined && idempotencyKey !== null) {
  #|     params.set("idempotency_key", String(idempotencyKey));
  #|   }
  #|   const res = await doFetch(endpoint, {
  #|     method: "POST",
  #|     body: params,
  #|   });
  #|   return await res.json();
  #| }

///|
pub(all) struct TurnstileVerifyOptions {
  remoteIp : String?
  idempotencyKey : String?
}

///|
pub fn TurnstileVerifyOptions::default() -> TurnstileVerifyOptions {
  { remoteIp: None, idempotencyKey: None }
}

///|
pub fn TurnstileVerifyOptions::remote_ip_js(
  self : TurnstileVerifyOptions,
) -> @core.Any {
  match self.remoteIp {
    Some(value) => @core.any(value)
    None => turnstile_js_null()
  }
}

///|
pub fn TurnstileVerifyOptions::idempotency_key_js(
  self : TurnstileVerifyOptions,
) -> @core.Any {
  match self.idempotencyKey {
    Some(value) => @core.any(value)
    None => turnstile_js_null()
  }
}

///|
#external
pub type TurnstileVerifyResult

///|
pub fn TurnstileVerifyResult::as_any(self : TurnstileVerifyResult) -> @core.Any = "%identity"

///|
pub fn TurnstileVerifyResult::success(self : TurnstileVerifyResult) -> Bool {
  self.as_any()["success"].cast()
}

///|
pub fn TurnstileVerifyResult::challenge_ts(
  self : TurnstileVerifyResult,
) -> String? {
  turnstile_as_string_option(self.as_any()["challenge_ts"])
}

///|
pub fn TurnstileVerifyResult::hostname(self : TurnstileVerifyResult) -> String? {
  turnstile_as_string_option(self.as_any()["hostname"])
}

///|
pub fn TurnstileVerifyResult::action(self : TurnstileVerifyResult) -> String? {
  turnstile_as_string_option(self.as_any()["action"])
}

///|
pub fn TurnstileVerifyResult::cdata(self : TurnstileVerifyResult) -> String? {
  turnstile_as_string_option(self.as_any()["cdata"])
}

///|
pub fn TurnstileVerifyResult::error_codes(
  self : TurnstileVerifyResult,
) -> Array[String] {
  let value_hyphen = self.as_any()["error-codes"]
  if not(turnstile_is_js_nullish(value_hyphen)) {
    value_hyphen.cast()
  } else {
    let value_snake = self.as_any()["error_codes"]
    if turnstile_is_js_nullish(value_snake) {
      []
    } else {
      value_snake.cast()
    }
  }
}

///|
pub async fn verify_turnstile_token(
  secret : String,
  response : String,
  options? : TurnstileVerifyOptions,
  endpoint? : String,
) -> TurnstileVerifyResult {
  match options {
    Some(opt) =>
      match endpoint {
        Some(url) =>
          verify_turnstile_token_with_fetch(
            turnstile_js_null(),
            secret,
            response,
            options=opt,
            endpoint=url,
          )
        None =>
          verify_turnstile_token_with_fetch(
            turnstile_js_null(),
            secret,
            response,
            options=opt,
          )
      }
    None =>
      match endpoint {
        Some(url) =>
          verify_turnstile_token_with_fetch(
            turnstile_js_null(),
            secret,
            response,
            endpoint=url,
          )
        None =>
          verify_turnstile_token_with_fetch(
            turnstile_js_null(),
            secret,
            response,
          )
      }
  }
}

///|
pub async fn verify_turnstile_token_with_fetch(
  fetch_impl : @core.Any,
  secret : String,
  response : String,
  options? : TurnstileVerifyOptions,
  endpoint? : String,
) -> TurnstileVerifyResult {
  let verify_endpoint = endpoint.unwrap_or(turnstile_siteverify_endpoint)
  let effective_options = options.unwrap_or(TurnstileVerifyOptions::default())
  let promise : @core.Promise[@core.Any] = turnstile_verify_request(
    fetch_impl,
    verify_endpoint,
    secret,
    response,
    effective_options.remote_ip_js(),
    effective_options.idempotency_key_js(),
  )
  promise.wait().cast()
}
