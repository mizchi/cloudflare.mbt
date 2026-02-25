// Cloudflare Email Workers bindings

///|
fn email_is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
fn email_as_string_option(value : @core.Any) -> String? {
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
fn email_as_int_option(value : @core.Any) -> Int? {
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
#external
pub type EmailMessage

///|
pub fn EmailMessage::as_any(self : EmailMessage) -> @core.Any = "%identity"

///|
pub fn EmailMessage::new(
  from : String,
  to : String,
  raw : @core.Any,
) -> EmailMessage {
  let obj = @core.new_object()
  obj["from"] = @core.any(from)
  obj["to"] = @core.any(to)
  obj["raw"] = raw
  obj.cast()
}

///|
pub fn EmailMessage::from(self : EmailMessage) -> String {
  self.as_any()["from"].cast()
}

///|
pub fn EmailMessage::to_(self : EmailMessage) -> String {
  self.as_any()["to"].cast()
}

///|
pub fn EmailMessage::raw(self : EmailMessage) -> @core.Any? {
  let value = self.as_any()["raw"]
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value)
  }
}

///|
pub fn EmailMessage::headers(self : EmailMessage) -> @http.Headers? {
  let value = self.as_any()["headers"]
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
pub fn EmailMessage::raw_size(self : EmailMessage) -> Int? {
  email_as_int_option(self.as_any()["rawSize"])
}

///|
#external
pub type ForwardableEmailMessage

///|
pub fn ForwardableEmailMessage::as_any(
  self : ForwardableEmailMessage,
) -> @core.Any = "%identity"

///|
pub fn ForwardableEmailMessage::from(self : ForwardableEmailMessage) -> String {
  self.as_any()["from"].cast()
}

///|
pub fn ForwardableEmailMessage::to_(self : ForwardableEmailMessage) -> String {
  self.as_any()["to"].cast()
}

///|
pub fn ForwardableEmailMessage::raw(
  self : ForwardableEmailMessage,
) -> @core.Any? {
  let value = self.as_any()["raw"]
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value)
  }
}

///|
pub fn ForwardableEmailMessage::headers(
  self : ForwardableEmailMessage,
) -> @http.Headers? {
  let value = self.as_any()["headers"]
  if email_is_js_nullish(value) {
    None
  } else {
    Some(value.cast())
  }
}

///|
pub fn ForwardableEmailMessage::raw_size(self : ForwardableEmailMessage) -> Int {
  self.as_any()["rawSize"].cast()
}

///|
pub fn ForwardableEmailMessage::set_reject(
  self : ForwardableEmailMessage,
  reason : String,
) -> Unit {
  self.as_any()._call("setReject", [@core.any(reason)]) |> ignore
}

///|
pub async fn ForwardableEmailMessage::forward(
  self : ForwardableEmailMessage,
  rcpt_to : String,
  headers? : @http.Headers,
) -> Unit {
  let promise : @core.Promise[Unit] = match headers {
    Some(value) =>
      self
      .as_any()
      ._call("forward", [@core.any(rcpt_to), @core.any(value)])
      .cast()
    None => self.as_any()._call("forward", [@core.any(rcpt_to)]).cast()
  }
  promise.wait()
}

///|
pub async fn ForwardableEmailMessage::reply(
  self : ForwardableEmailMessage,
  message : EmailMessage,
) -> Unit {
  let promise : @core.Promise[Unit] = self
    .as_any()
    ._call("reply", [@core.any(message)])
    .cast()
  promise.wait()
}

///|
#external
pub type SendEmail

///|
pub fn SendEmail::as_any(self : SendEmail) -> @core.Any = "%identity"

///|
pub async fn SendEmail::send(self : SendEmail, message : EmailMessage) -> Unit {
  let promise : @core.Promise[Unit] = self
    .as_any()
    ._call("send", [@core.any(message)])
    .cast()
  promise.wait()
}

///|
pub fn ForwardableEmailMessage::to_email_message(
  self : ForwardableEmailMessage,
) -> EmailMessage {
  self.as_any().cast()
}

///|
pub fn EmailMessage::message_id(self : EmailMessage) -> String? {
  email_as_string_option(self.as_any()["messageId"])
}
