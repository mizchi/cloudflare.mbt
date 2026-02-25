///|
extern "js" fn install_queue_stub() -> Unit =
  #| () => {
  #|   globalThis.__moonbit_queue_calls__ = {
  #|     sendBody: "",
  #|     sendContentType: "",
  #|     sendDelay: 0,
  #|     batchCount: 0,
  #|     batchDelay: 0,
  #|     messageRetryDelay: 0,
  #|     messageAcked: 0,
  #|     batchRetryDelay: 0,
  #|     batchAcked: 0,
  #|   };
  #| }

///|
extern "js" fn make_queue_stub() -> Queue =
  #| () => ({
  #|   send: async (message, options) => {
  #|     const calls = globalThis.__moonbit_queue_calls__;
  #|     calls.sendBody = String(message ?? "");
  #|     calls.sendContentType = String(options?.contentType ?? "");
  #|     calls.sendDelay = Number(options?.delaySeconds ?? 0);
  #|   },
  #|   sendBatch: async (messages, options) => {
  #|     const calls = globalThis.__moonbit_queue_calls__;
  #|     const list = Array.from(messages ?? []);
  #|     calls.batchCount = list.length;
  #|     calls.batchDelay = Number(options?.delaySeconds ?? 0);
  #|   },
  #| })

///|
extern "js" fn make_queue_message_batch_stub() -> QueueMessageBatch =
  #| () => {
  #|   const calls = globalThis.__moonbit_queue_calls__;
  #|   const message = {
  #|     id: "m-1",
  #|     timestamp: new Date(1700000000000),
  #|     body: { ok: true },
  #|     attempts: 2,
  #|     retry: (options) => {
  #|       calls.messageRetryDelay = Number(options?.delaySeconds ?? 0);
  #|     },
  #|     ack: () => {
  #|       calls.messageAcked += 1;
  #|     },
  #|   };
  #|   return {
  #|     messages: [message],
  #|     queue: "jobs",
  #|     retryAll: (options) => {
  #|       calls.batchRetryDelay = Number(options?.delaySeconds ?? 0);
  #|     },
  #|     ackAll: () => {
  #|       calls.batchAcked += 1;
  #|     },
  #|   };
  #| }

///|
extern "js" fn queue_last_send_body() -> String =
  #| () => globalThis.__moonbit_queue_calls__.sendBody

///|
extern "js" fn queue_last_send_content_type() -> String =
  #| () => globalThis.__moonbit_queue_calls__.sendContentType

///|
extern "js" fn queue_last_send_delay() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.sendDelay

///|
extern "js" fn queue_last_batch_count() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.batchCount

///|
extern "js" fn queue_last_batch_delay() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.batchDelay

///|
extern "js" fn queue_message_retry_delay() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.messageRetryDelay

///|
extern "js" fn queue_message_acked() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.messageAcked

///|
extern "js" fn queue_batch_retry_delay() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.batchRetryDelay

///|
extern "js" fn queue_batch_acked() -> Int =
  #| () => globalThis.__moonbit_queue_calls__.batchAcked

///|
extern "js" fn install_analytics_stub() -> Unit =
  #| () => {
  #|   globalThis.__moonbit_analytics_calls__ = {
  #|     hasEvent: false,
  #|     indexesLength: 0,
  #|     doublesLength: 0,
  #|     blobsLength: 0,
  #|   };
  #| }

///|
extern "js" fn make_analytics_dataset_stub() -> AnalyticsEngineDataset =
  #| () => ({
  #|   writeDataPoint: (event) => {
  #|     const calls = globalThis.__moonbit_analytics_calls__;
  #|     calls.hasEvent = event != null;
  #|     calls.indexesLength = event?.indexes?.length ?? 0;
  #|     calls.doublesLength = event?.doubles?.length ?? 0;
  #|     calls.blobsLength = event?.blobs?.length ?? 0;
  #|   },
  #| })

///|
extern "js" fn analytics_has_event() -> Bool =
  #| () => Boolean(globalThis.__moonbit_analytics_calls__.hasEvent)

///|
extern "js" fn analytics_indexes_length() -> Int =
  #| () => globalThis.__moonbit_analytics_calls__.indexesLength

///|
extern "js" fn analytics_doubles_length() -> Int =
  #| () => globalThis.__moonbit_analytics_calls__.doublesLength

///|
extern "js" fn analytics_blobs_length() -> Int =
  #| () => globalThis.__moonbit_analytics_calls__.blobsLength

///|
extern "js" fn make_hyperdrive_stub() -> Hyperdrive =
  #| () => ({
  #|   connect: () => ({ kind: "socket", address: "hd.internal:5432" }),
  #|   connectionString: "postgres://user:pass@hd.internal:5432/app",
  #|   host: "hd.internal",
  #|   port: 5432,
  #|   user: "user",
  #|   password: "pass",
  #|   database: "app",
  #| })

///|
extern "js" fn install_email_stub() -> Unit =
  #| () => {
  #|   globalThis.__moonbit_email_calls__ = {
  #|     sentFrom: "",
  #|     sentTo: "",
  #|     rejectReason: "",
  #|     forwardTo: "",
  #|     replyTo: "",
  #|   };
  #| }

///|
extern "js" fn make_send_email_stub() -> SendEmail =
  #| () => ({
  #|   send: async (message) => {
  #|     const calls = globalThis.__moonbit_email_calls__;
  #|     calls.sentFrom = String(message?.from ?? "");
  #|     calls.sentTo = String(message?.to ?? "");
  #|   },
  #| })

///|
extern "js" fn make_forwardable_email_message_stub() -> ForwardableEmailMessage =
  #| () => ({
  #|   from: "sender@example.com",
  #|   to: "worker@example.com",
  #|   raw: new ReadableStream(),
  #|   headers: new Headers({ "x-test": "ok" }),
  #|   rawSize: 128,
  #|   setReject: (reason) => {
  #|     globalThis.__moonbit_email_calls__.rejectReason = String(reason ?? "");
  #|   },
  #|   forward: async (rcptTo, _headers) => {
  #|     globalThis.__moonbit_email_calls__.forwardTo = String(rcptTo ?? "");
  #|   },
  #|   reply: async (message) => {
  #|     globalThis.__moonbit_email_calls__.replyTo = String(message?.to ?? "");
  #|   },
  #| })

///|
extern "js" fn email_last_sent_from() -> String =
  #| () => globalThis.__moonbit_email_calls__.sentFrom

///|
extern "js" fn email_last_sent_to() -> String =
  #| () => globalThis.__moonbit_email_calls__.sentTo

///|
extern "js" fn email_last_reject_reason() -> String =
  #| () => globalThis.__moonbit_email_calls__.rejectReason

///|
extern "js" fn email_last_forward_to() -> String =
  #| () => globalThis.__moonbit_email_calls__.forwardTo

///|
extern "js" fn email_last_reply_to() -> String =
  #| () => globalThis.__moonbit_email_calls__.replyTo

///|
extern "js" fn make_browser_fetcher_stub() -> BrowserFetcher =
  #| () => ({
  #|   fetch: async (input, _init) => {
  #|     if (typeof input === "string") {
  #|       return new Response("url", { status: 207 });
  #|     }
  #|     return new Response("request", { status: 208 });
  #|   },
  #|   connect: (address, _options) => ({ address: String(address), kind: "socket" }),
  #| })

///|
extern "js" fn make_access_request_stub() -> CloudflareRequest =
  #| () => {
  #|   const req = new Request("https://example.com/private", {
  #|     headers: {
  #|       "cf-access-jwt-assertion": "jwt-token",
  #|       "cf-access-authenticated-user-email": "alice@example.com",
  #|       "cf-access-authenticated-user-id": "user-1",
  #|     },
  #|   });
  #|   req.cf = {
  #|     tlsClientAuth: {
  #|       certPresented: "1",
  #|       certIssuerDN: "CN=issuer",
  #|     },
  #|   };
  #|   return req;
  #| }

///|
extern "js" fn install_turnstile_capture() -> Unit =
  #| () => {
  #|   globalThis.__moonbit_turnstile_calls__ = { body: "" };
  #| }

///|
extern "js" fn make_turnstile_fetch_stub() -> @core.Any =
  #| () => async (_url, init) => {
  #|   const calls = globalThis.__moonbit_turnstile_calls__;
  #|   calls.body = String(init?.body ?? "");
  #|   return new Response(
  #|     JSON.stringify({
  #|       success: true,
  #|       challenge_ts: "2025-01-01T00:00:00.000Z",
  #|       hostname: "example.com",
  #|       action: "login",
  #|       cdata: "trace-1",
  #|       "error-codes": ["timeout-or-duplicate"],
  #|     }),
  #|     {
  #|       status: 200,
  #|       headers: { "content-type": "application/json" },
  #|     },
  #|   );
  #| }

///|
extern "js" fn turnstile_last_body_contains(fragment : String) -> Bool =
  #| (fragment) => String(globalThis.__moonbit_turnstile_calls__.body ?? "").includes(fragment)

///|
extern "js" fn response_status(response : @http.Response) -> Int =
  #| (response) => Number(response.status ?? 0)

///|
extern "js" fn read_string(obj : @core.Any, key : String) -> String =
  #| (obj, key) => String(obj?.[key] ?? "")

///|
async test "queues bindings" {
  install_queue_stub()
  let queue = make_queue_stub()
  let send_options = QueueSendOptions::{
    contentType: Some(QueueContentType::Json),
    delaySeconds: Some(5),
  }
  queue.send(@core.any("hello"), options=send_options)
  assert_eq(queue_last_send_body(), "hello")
  assert_eq(queue_last_send_content_type(), "json")
  assert_eq(queue_last_send_delay(), 5)

  let m1 = MessageSendRequest::{
    body: @core.any("a"),
    contentType: Some(QueueContentType::Text),
    delaySeconds: None,
  }
  let m2 = MessageSendRequest::{
    body: @core.any("b"),
    contentType: None,
    delaySeconds: Some(2),
  }
  let batch_options = QueueSendBatchOptions::{ delaySeconds: Some(7) }
  queue.send_batch([m1, m2], options=batch_options)
  assert_eq(queue_last_batch_count(), 2)
  assert_eq(queue_last_batch_delay(), 7)

  let batch = make_queue_message_batch_stub()
  assert_eq(batch.queue(), "jobs")
  assert_eq(batch.messages().length(), 1)
  let message = batch.messages()[0]
  assert_eq(message.id(), "m-1")
  assert_eq(message.attempts(), 2)
  message.ack()
  message.retry(options={ delaySeconds: Some(11) })
  assert_eq(queue_message_acked(), 1)
  assert_eq(queue_message_retry_delay(), 11)

  batch.ack_all()
  batch.retry_all(options={ delaySeconds: Some(13) })
  assert_eq(queue_batch_acked(), 1)
  assert_eq(queue_batch_retry_delay(), 13)
}

///|
test "analytics engine bindings" {
  install_analytics_stub()
  let dataset = make_analytics_dataset_stub()
  dataset.write_data_point()
  assert_true(not(analytics_has_event()))

  let point = AnalyticsEngineDataPoint::{
    indexes: Some([@core.any("idx-1")]),
    doubles: Some([1.5, 2.5]),
    blobs: Some([@core.any("blob-1")]),
  }
  dataset.write_data_point(event=point)
  assert_true(analytics_has_event())
  assert_eq(analytics_indexes_length(), 1)
  assert_eq(analytics_doubles_length(), 2)
  assert_eq(analytics_blobs_length(), 1)
}

///|
test "hyperdrive bindings" {
  let hyperdrive = make_hyperdrive_stub()
  assert_eq(
    hyperdrive.connection_string(),
    "postgres://user:pass@hd.internal:5432/app",
  )
  assert_eq(hyperdrive.host(), "hd.internal")
  assert_eq(hyperdrive.port(), 5432)
  assert_eq(hyperdrive.user(), "user")
  assert_eq(hyperdrive.password(), "pass")
  assert_eq(hyperdrive.database(), "app")
  let socket = hyperdrive.connect()
  assert_eq(read_string(socket, "kind"), "socket")
}

///|
async test "email workers bindings" {
  install_email_stub()
  let sender = make_send_email_stub()
  let outgoing = EmailMessage::new(
    "from@example.com",
    "to@example.com",
    @core.any("raw-message"),
  )
  assert_eq(outgoing.from(), "from@example.com")
  assert_eq(outgoing.to_(), "to@example.com")
  sender.send(outgoing)
  assert_eq(email_last_sent_from(), "from@example.com")
  assert_eq(email_last_sent_to(), "to@example.com")

  let incoming = make_forwardable_email_message_stub()
  assert_eq(incoming.from(), "sender@example.com")
  assert_eq(incoming.to_(), "worker@example.com")
  assert_eq(incoming.raw_size(), 128)
  incoming.set_reject("blocked")
  assert_eq(email_last_reject_reason(), "blocked")
  incoming.forward("dest@example.com")
  assert_eq(email_last_forward_to(), "dest@example.com")
  incoming.reply(outgoing)
  assert_eq(email_last_reply_to(), "to@example.com")
}

///|
async test "browser rendering bindings" {
  let fetcher = make_browser_fetcher_stub()
  let from_url = fetcher.fetch_url("https://example.com/session")
  assert_eq(response_status(from_url), 207)
  let request = @http.Request::new("https://example.com/screenshot")
  let from_request = fetcher.fetch_request(request)
  assert_eq(response_status(from_request), 208)
  let socket = fetcher.connect("127.0.0.1:9222")
  assert_eq(read_string(socket, "address"), "127.0.0.1:9222")
}

///|
test "access helpers" {
  let request = make_access_request_stub()
  assert_eq(request.access_jwt_assertion(), Some("jwt-token"))
  assert_eq(
    request.access_authenticated_user_email(),
    Some("alice@example.com"),
  )
  assert_eq(request.access_authenticated_user_id(), Some("user-1"))
  assert_true(request.tls_client_auth() is Some(_))
  assert_eq(
    access_jwt_assertion_from_headers(request.headers()),
    Some("jwt-token"),
  )
}

///|
async test "turnstile helper" {
  install_turnstile_capture()
  let fetch_stub = make_turnstile_fetch_stub()
  let options = TurnstileVerifyOptions::{
    remoteIp: Some("203.0.113.1"),
    idempotencyKey: Some("idem-1"),
  }
  let result = verify_turnstile_token_with_fetch(
    fetch_stub,
    "secret-key",
    "token-value",
    options~,
    endpoint="https://turnstile.test/verify",
  )
  assert_true(result.success())
  assert_eq(result.hostname(), Some("example.com"))
  assert_eq(result.action(), Some("login"))
  assert_eq(result.cdata(), Some("trace-1"))
  assert_eq(result.error_codes().length(), 1)
  assert_eq(result.error_codes()[0], "timeout-or-duplicate")
  assert_true(turnstile_last_body_contains("secret=secret-key"))
  assert_true(turnstile_last_body_contains("response=token-value"))
  assert_true(turnstile_last_body_contains("remoteip=203.0.113.1"))
  assert_true(turnstile_last_body_contains("idempotency_key=idem-1"))
}
