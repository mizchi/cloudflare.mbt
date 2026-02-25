///|
extern "js" fn install_ai_sdk_stub() -> Unit =
  #| () => {
  #|   const calls = {
  #|     debug: false,
  #|     prefix: "",
  #|     model: "",
  #|   };
  #|   globalThis.__moonbit_cloudflare_ai_sdk_calls__ = calls;
  #|   globalThis.__moonbit_cloudflare_ai_sdk__ = {
  #|     Ai: class Ai {
  #|       constructor(_binding, options) {
  #|         this.lastRequestId = "";
  #|         calls.debug = options?.debug === true;
  #|         calls.prefix = options?.prefix ?? "";
  #|       }
  #|       async run(model, input) {
  #|         calls.model = model;
  #|         this.lastRequestId = `req-${model}`;
  #|         return { model, input, ok: true };
  #|       }
  #|       getLogs() {
  #|         return ["log-1", "log-2"];
  #|       }
  #|     },
  #|   };
  #| }

///|
extern "js" fn ai_stub_debug() -> Bool =
  #| () => globalThis.__moonbit_cloudflare_ai_sdk_calls__.debug

///|
extern "js" fn ai_stub_prefix() -> String =
  #| () => globalThis.__moonbit_cloudflare_ai_sdk_calls__.prefix

///|
extern "js" fn ai_stub_model() -> String =
  #| () => globalThis.__moonbit_cloudflare_ai_sdk_calls__.model

///|
extern "js" fn read_bool(obj : @core.Any, key : String) -> Bool =
  #| (obj, key) => Boolean(obj[key])

///|
async test "cloudflare ai sdk bindings" {
  install_ai_sdk_stub()
  let ai_options = AiOptions::{
    debug: Some(true),
    prefix: Some("/ai"),
    extraHeaders: None,
    overrideSettings: None,
    fetchUrl: None,
  }
  let ai = Ai::new(@core.new_object(), options=ai_options)
  assert_true(ai_stub_debug())
  assert_eq(ai_stub_prefix(), "/ai")

  let input = @core.new_object()
  input["prompt"] = @core.any("hello")
  let ai_result = ai.run("@cf/meta/llama-3.1-8b-instruct", input)
  assert_true(read_bool(ai_result, "ok"))
  assert_eq(ai_stub_model(), "@cf/meta/llama-3.1-8b-instruct")
  assert_eq(ai.last_request_id(), Some("req-@cf/meta/llama-3.1-8b-instruct"))
  assert_eq(ai.get_logs().length(), 2)
}
