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
    None => abort("D1 test database not available. Run tests with miniflare harness.")
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
/// Create a new Miniflare instance
pub fn Miniflare::new(options : MiniflareOptions) -> Miniflare {
  miniflare_new_ffi(options)
}

///|
extern "js" fn miniflare_new_ffi(options : MiniflareOptions) -> Miniflare =
  #| (options) => {
  #|   const Miniflare = globalThis.__miniflare_module__.Miniflare;
  #|   // Helper to unwrap MoonBit Option type: {$tag: 0} = None, {$tag: 1, _0: value} = Some
  #|   const unwrapOption = (opt) => opt && opt.$tag === 1 ? opt._0 : undefined;
  #|   const opts = {
  #|     modules: options.modules,
  #|     script: unwrapOption(options.script) || 'export default { async fetch() { return new Response("OK"); } }',
  #|   };
  #|   const d1 = unwrapOption(options.d1Databases);
  #|   const r2 = unwrapOption(options.r2Buckets);
  #|   const kv = unwrapOption(options.kvNamespaces);
  #|   if (d1) opts.d1Databases = d1;
  #|   if (r2) opts.r2Buckets = r2;
  #|   if (kv) opts.kvNamespaces = kv;
  #|   return new Miniflare(opts);
  #| }

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

///|
/// Setup Miniflare module before use
/// Call this with the miniflare module import
pub fn setup_miniflare(miniflare_module : @core.Any) -> Unit {
  setup_miniflare_ffi(miniflare_module)
}

///|
extern "js" fn setup_miniflare_ffi(miniflare_module : @core.Any) -> Unit =
  #| (mod) => { globalThis.__miniflare_module__ = mod; }
