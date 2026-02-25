// Cloudflare Queues bindings

///|
fn queue_to_js_any_array(items : Array[@core.Any]) -> @core.Any {
  let result = @core.new_array()
  let mut i = 0
  while i < items.length() {
    @core.any(result)._call("push", [items[i]]) |> ignore
    i = i + 1
  }
  result
}

///|
#external
pub type Queue

///|
pub fn Queue::as_any(self : Queue) -> @core.Any = "%identity"

///|
pub(all) enum QueueContentType {
  Text
  Bytes
  Json
  V8
}

///|
pub fn QueueContentType::to_string(self : QueueContentType) -> String {
  match self {
    Text => "text"
    Bytes => "bytes"
    Json => "json"
    V8 => "v8"
  }
}

///|
pub(all) struct QueueSendOptions {
  contentType : QueueContentType?
  delaySeconds : Int?
}

///|
pub fn QueueSendOptions::to_js(self : QueueSendOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.contentType is Some(value) {
    obj["contentType"] = @core.any(value.to_string())
  }
  if self.delaySeconds is Some(value) {
    obj["delaySeconds"] = @core.any(value)
  }
  obj
}

///|
pub(all) struct QueueSendBatchOptions {
  delaySeconds : Int?
}

///|
pub fn QueueSendBatchOptions::to_js(self : QueueSendBatchOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.delaySeconds is Some(value) {
    obj["delaySeconds"] = @core.any(value)
  }
  obj
}

///|
pub(all) struct MessageSendRequest {
  body : @core.Any
  contentType : QueueContentType?
  delaySeconds : Int?
}

///|
pub fn MessageSendRequest::to_js(self : MessageSendRequest) -> @core.Any {
  let obj = @core.new_object()
  obj["body"] = self.body
  if self.contentType is Some(value) {
    obj["contentType"] = @core.any(value.to_string())
  }
  if self.delaySeconds is Some(value) {
    obj["delaySeconds"] = @core.any(value)
  }
  obj
}

///|
pub(all) struct QueueRetryOptions {
  delaySeconds : Int?
}

///|
pub fn QueueRetryOptions::to_js(self : QueueRetryOptions) -> @core.Any {
  let obj = @core.new_object()
  if self.delaySeconds is Some(value) {
    obj["delaySeconds"] = @core.any(value)
  }
  obj
}

///|
pub async fn Queue::send(
  self : Queue,
  message : @core.Any,
  options? : QueueSendOptions,
) -> Unit {
  let promise : @core.Promise[Unit] = match options {
    Some(value) => self.as_any()._call("send", [message, value.to_js()]).cast()
    None => self.as_any()._call("send", [message]).cast()
  }
  promise.wait()
}

///|
pub async fn Queue::send_batch(
  self : Queue,
  messages : Array[MessageSendRequest],
  options? : QueueSendBatchOptions,
) -> Unit {
  let mapped : Array[@core.Any] = []
  let mut i = 0
  while i < messages.length() {
    mapped.push(messages[i].to_js())
    i = i + 1
  }
  let js_messages = queue_to_js_any_array(mapped)
  let promise : @core.Promise[Unit] = match options {
    Some(value) =>
      self.as_any()._call("sendBatch", [js_messages, value.to_js()]).cast()
    None => self.as_any()._call("sendBatch", [js_messages]).cast()
  }
  promise.wait()
}

///|
#external
pub type QueueMessage

///|
pub fn QueueMessage::as_any(self : QueueMessage) -> @core.Any = "%identity"

///|
pub fn QueueMessage::id(self : QueueMessage) -> String {
  self.as_any()["id"].cast()
}

///|
pub fn QueueMessage::timestamp(self : QueueMessage) -> @date.Date {
  self.as_any()["timestamp"].cast()
}

///|
pub fn QueueMessage::body(self : QueueMessage) -> @core.Any {
  self.as_any()["body"]
}

///|
pub fn QueueMessage::attempts(self : QueueMessage) -> Int {
  self.as_any()["attempts"].cast()
}

///|
pub fn QueueMessage::retry(
  self : QueueMessage,
  options? : QueueRetryOptions,
) -> Unit {
  match options {
    Some(value) => self.as_any()._call("retry", [value.to_js()]) |> ignore
    None => self.as_any()._call("retry", []) |> ignore
  }
}

///|
pub fn QueueMessage::ack(self : QueueMessage) -> Unit {
  self.as_any()._call("ack", []) |> ignore
}

///|
#external
pub type QueueMessageBatch

///|
pub fn QueueMessageBatch::as_any(self : QueueMessageBatch) -> @core.Any = "%identity"

///|
pub fn QueueMessageBatch::messages(
  self : QueueMessageBatch,
) -> Array[QueueMessage] {
  self.as_any()["messages"].cast()
}

///|
pub fn QueueMessageBatch::queue(self : QueueMessageBatch) -> String {
  self.as_any()["queue"].cast()
}

///|
pub fn QueueMessageBatch::retry_all(
  self : QueueMessageBatch,
  options? : QueueRetryOptions,
) -> Unit {
  match options {
    Some(value) => self.as_any()._call("retryAll", [value.to_js()]) |> ignore
    None => self.as_any()._call("retryAll", []) |> ignore
  }
}

///|
pub fn QueueMessageBatch::ack_all(self : QueueMessageBatch) -> Unit {
  self.as_any()._call("ackAll", []) |> ignore
}

///|
#external
pub type QueueEvent

///|
pub fn QueueEvent::as_any(self : QueueEvent) -> @core.Any = "%identity"

///|
pub fn QueueEvent::messages(self : QueueEvent) -> Array[QueueMessage] {
  self.as_any()["messages"].cast()
}

///|
pub fn QueueEvent::queue(self : QueueEvent) -> String {
  self.as_any()["queue"].cast()
}

///|
pub fn QueueEvent::retry_all(
  self : QueueEvent,
  options? : QueueRetryOptions,
) -> Unit {
  match options {
    Some(value) => self.as_any()._call("retryAll", [value.to_js()]) |> ignore
    None => self.as_any()._call("retryAll", []) |> ignore
  }
}

///|
pub fn QueueEvent::ack_all(self : QueueEvent) -> Unit {
  self.as_any()._call("ackAll", []) |> ignore
}
