///|
extern "js" fn make_empty_env() -> @cloudflare.CloudflareEnv =
  #| () => ({})

///|
extern "js" fn make_env_with_ai_and_workflow() -> @cloudflare.CloudflareEnv =
  #| () => ({
  #|   AI: {
  #|     run: async (model, input, options) => ({
  #|       model,
  #|       input,
  #|       options: options ?? null,
  #|     }),
  #|   },
  #|   AGENT_WORKFLOW: {
  #|     create: async (opts) => ({
  #|       id: (opts && opts.id) || "wf-auto",
  #|       status: async () => ({ status: "queued" }),
  #|     }),
  #|     get: async (id) => ({
  #|       id,
  #|       status: async () => ({ status: "running" }),
  #|     }),
  #|   },
  #| })

///|
extern "js" fn make_cloudflare_request() -> @cloudflare.CloudflareRequest =
  #| () => new Request("https://example.com/api?x=1", {
  #|   method: "POST",
  #|   headers: { "X-Test": "ok" },
  #| })

///|
test "CloudflareEnv binding helper returns None on missing keys" {
  let env = make_empty_env()
  assert_true(env.get_ai_binding("AI") is None)
  assert_true(env.get_workflow_binding("AGENT_WORKFLOW") is None)
}

///|
async test "CloudflareEnv AI binding can run models" {
  let env = make_env_with_ai_and_workflow()
  let ai = match env.get_ai_binding("AI") {
    Some(value) => value
    None => panic()
  }
  let input = @core.new_object()
  input["prompt"] = @core.any("hello")
  let out = ai.run("@cf/meta/llama-3.3-70b-instruct-fp8-fast", input)
  assert_eq(out["model"].cast(), "@cf/meta/llama-3.3-70b-instruct-fp8-fast")
}

///|
async test "CloudflareEnv workflow binding can create instance" {
  let env = make_env_with_ai_and_workflow()
  let workflow = match env.get_workflow_binding("AGENT_WORKFLOW") {
    Some(value) => value
    None => panic()
  }
  let instance = workflow.create_with_id("wf-1")
  assert_eq(instance.id(), "wf-1")
  let status = instance.status()
  assert_true(status.is_queued())
}

///|
test "CloudflareRequest helper can read method and headers" {
  let req = make_cloudflare_request()
  assert_eq(req.get_url(), "https://example.com/api?x=1")
  assert_eq(req.method_(), "POST")
  assert_eq(req.header("X-Test"), Some("ok"))
  assert_eq(req.header("Missing"), None)
}
