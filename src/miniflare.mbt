// Testing utilities for Cloudflare Workers with miniflare
// Usage: Set globalThis.__MINIFLARE_D1__ before running tests

///|
/// Get D1 database from global test environment (set by miniflare test harness)
pub fn get_test_d1() -> D1Database? {
  let global = get_global_this()
  let db = global["__MINIFLARE_D1__"]
  if @core.typeof_(db) == "undefined" || @core.is_null(db) {
    None
  } else {
    Some(db.cast())
  }
}

///|
/// Get D1 database from global test environment, panic if not available
pub fn get_test_d1_exn() -> D1Database {
  match get_test_d1() {
    Some(db) => db
    None =>
      abort("D1 test database not available. Run tests with miniflare harness.")
  }
}

///|
extern "js" fn get_global_this() -> @core.Any =
  #| () => globalThis

// ============================================================================
// Miniflare bindings for direct testing
// ============================================================================

///|
/// Miniflare instance type
#external
pub type Miniflare

///|
pub fn Miniflare::as_any(self : Miniflare) -> @core.Any = "%identity"

///|
/// Miniflare options for creating a new instance
pub(all) struct MiniflareOptions {
  script : String?
  modules : Bool
  d1Databases : Array[String]?
  r2Buckets : Array[String]?
  kvNamespaces : Array[String]?
}

///|
/// Create default MiniflareOptions
pub fn MiniflareOptions::default() -> MiniflareOptions {
  {
    script: None,
    modules: true,
    d1Databases: None,
    r2Buckets: None,
    kvNamespaces: None,
  }
}

///|
/// Dynamic import for miniflare package (ESM)
extern "js" fn import_miniflare() -> @core.Promise[@core.Any] =
  #|() => import("miniflare")

///|
/// Create a new Miniflare instance (async due to ESM dynamic import)
pub async fn Miniflare::new(options : MiniflareOptions) -> Miniflare {
  let mod = import_miniflare().wait()
  let klass : @core.Any = mod["Miniflare"]
  let opts = miniflare_options_to_js(options)
  @core.new(klass, [opts]).cast()
}

///|
/// Convert MiniflareOptions to JS object
fn miniflare_options_to_js(options : MiniflareOptions) -> @core.Any {
  let entries : Array[(String, @core.Any)] = []
  entries.push(("modules", @core.any(options.modules)))
  match options.script {
    Some(s) => entries.push(("script", @core.any(s)))
    None =>
      entries.push(
        (
          "script",
          @core.any(
            "export default { async fetch() { return new Response(\"OK\"); } }",
          ),
        ),
      )
  }
  match options.d1Databases {
    Some(dbs) => entries.push(("d1Databases", @core.any(dbs)))
    None => ()
  }
  match options.r2Buckets {
    Some(buckets) => entries.push(("r2Buckets", @core.any(buckets)))
    None => ()
  }
  match options.kvNamespaces {
    Some(ns) => entries.push(("kvNamespaces", @core.any(ns)))
    None => ()
  }
  @core.from_entries(entries)
}

///|
/// Wait for Miniflare to be ready
pub async fn Miniflare::ready(self : Miniflare) -> Unit {
  let promise : @core.Promise[Unit] = self.as_any()["ready"].cast()
  promise.wait()
}

///|
/// Dispose of Miniflare instance
pub async fn Miniflare::dispose(self : Miniflare) -> Unit {
  let promise : @core.Promise[Unit] = self.as_any()._call("dispose", []).cast()
  promise.wait()
}

///|
/// Get D1 database from Miniflare instance
pub async fn Miniflare::get_d1_database(
  self : Miniflare,
  binding_name : String,
) -> D1Database {
  let promise : @core.Promise[D1Database] = self
    .as_any()
    ._call("getD1Database", [@core.any(binding_name)])
    .cast()
  promise.wait()
}

///|
/// Get R2 bucket from Miniflare instance
pub async fn Miniflare::get_r2_bucket(
  self : Miniflare,
  binding_name : String,
) -> R2Bucket {
  let promise : @core.Promise[R2Bucket] = self
    .as_any()
    ._call("getR2Bucket", [@core.any(binding_name)])
    .cast()
  promise.wait()
}

///|
/// Get KV namespace from Miniflare instance
pub async fn Miniflare::get_kv_namespace(
  self : Miniflare,
  binding_name : String,
) -> KVNamespace {
  let promise : @core.Promise[KVNamespace] = self
    .as_any()
    ._call("getKVNamespace", [@core.any(binding_name)])
    .cast()
  promise.wait()
}
