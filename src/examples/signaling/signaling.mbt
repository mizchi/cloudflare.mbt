// Signaling Relay example using Durable Object bindings
//
// Demonstrates Star Relay + Gossip topology patterns.
// Exports a fetch handler and stateless merge functions.
//
// Protocol:
//   Client -> Server: { type: "state", entries: NsEntries }
//   Client -> Server: { type: "gossip_relay", entries, msgId }
//   Server -> Client: { type: "snapshot", mode, entries }
//   Server -> Client: { type: "diff", entries }
//   Server -> Client: { type: "gossip_diff", entries, msgId }

///|
using @js {promisify3}

///|
using @http {type Response}

///|
using @url {type URL}

///|
let default_namespaces : Array[String] = ["state"]

///|
extern "js" fn get_timestamp() -> Double =
  #| () => Date.now()

// --- Relay state (singleton per DO instance) ---

///|
let relay_store : LwwStore = LwwStore::new()

///|
let seen_messages : Map[String, Double] = Map::new()

///|
let seen_ttl_ms : Double = 30000.0

// --- Exported handler ---

///|
pub fn get_signaling_handler() -> @cloudflare.CloudflareFetchHandler {
  let async_handler = async fn(
    req : @cloudflare.CloudflareRequest,
    env : @cloudflare.CloudflareEnv,
    _ctx : @cloudflare.CloudflareContext
  ) -> Response {
    let url = URL::new(req.url)
    let pathname = url.pathname
    if pathname == "/" {
      Response::html(
        "<h1>Signaling Relay</h1><p>Connect via WebSocket at /ws</p>",
        200,
      )
    } else if pathname == "/api/info" {
      let data = @core.new_object()
      data["mode"] = @core.any("star")
      data["service"] = @core.any("signaling-relay")
      let options = @core.new_object()
      options["status"] = @core.any(200)
      Response::json_(data, options~)
    } else if pathname == "/api/snapshot" {
      let snap = relay_store.snapshot(default_namespaces)
      let result = @core.new_object()
      result["entries"] = snap
      let options = @core.new_object()
      options["status"] = @core.any(200)
      Response::json_(result, options~)
    } else if pathname == "/ws" {
      let room = match url.searchParams().get("room") {
        Some(r) => r
        None => "main"
      }
      let do_ns : @cloudflare.DurableObjectNamespace = env
        .as_any()["SIGNALING_RELAY"]
        .cast()
      let stub = do_ns.get_by_name(room)
      let response = stub.fetch(@core.any(req))
      response.cast()
    } else {
      let data = @core.new_object()
      data["error"] = @core.any("Not Found")
      let options = @core.new_object()
      options["status"] = @core.any(404)
      Response::json_(data, options~)
    }
  }
  promisify3(async_handler)
}

// --- Star mode merge ---

///|
/// Merge entries using LWW. Returns changed entries as JS object.
pub fn star_merge(entries_js : @core.Any) -> @core.Any {
  relay_store.merge_json(entries_js)
}

// --- Gossip mode merge with deduplication ---

///|
/// Returns changed entries if msgId not seen, None otherwise.
pub fn gossip_merge(
  entries_js : @core.Any,
  msg_id : String
) -> @core.Any? {
  let now = get_timestamp()
  // Check dedup
  match seen_messages.get(msg_id) {
    Some(expiry) => {
      if expiry > now {
        return None
      }
      ignore(seen_messages.remove(msg_id))
    }
    None => ()
  }
  // Mark seen
  seen_messages[msg_id] = now + seen_ttl_ms
  // Cleanup if too many
  if seen_messages.length() > 1000 {
    cleanup_seen(now)
  }
  // Merge
  let changed = relay_store.merge_json(entries_js)
  let has_changes = @core.object_keys(changed).length() > 0
  if has_changes { Some(changed) } else { None }
}

///|
fn cleanup_seen(now : Double) -> Unit {
  let to_remove : Array[String] = []
  for id, expiry in seen_messages {
    if now > expiry {
      to_remove.push(id)
    }
  }
  for id in to_remove {
    ignore(seen_messages.remove(id))
  }
}

///|
/// Get snapshot for a newly connected client
pub fn get_snapshot_json() -> @core.Any {
  relay_store.snapshot(default_namespaces)
}

///|
/// Get filtered snapshot for specific namespaces (for Topic-filtered Star).
/// namespaces_js is a JS Array of namespace strings.
pub fn get_filtered_snapshot_json(namespaces_js : @core.Any) -> @core.Any {
  let len : Int = namespaces_js["length"].cast()
  let namespaces : Array[String] = []
  for i in 0..<len {
    let ns : String = namespaces_js[i.to_string()].cast()
    namespaces.push(ns)
  }
  relay_store.snapshot(namespaces)
}
