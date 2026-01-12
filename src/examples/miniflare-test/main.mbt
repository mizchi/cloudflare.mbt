///|
/// Setup miniflare module (must be called from JS with miniflare import)
pub fn setup_miniflare(mod : @core.Any) -> Unit {
  @cloudflare.setup_miniflare(mod)
}

///|
/// Test D1 database operations
pub async fn test_d1() -> @core.Any {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    d1Databases: Some(["TEST_DB"]),
  })
  mf.ready()
  let d1 = mf.get_d1_database("TEST_DB")

  // Create table
  let _ = d1.exec(
    "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL)",
  )

  // Insert data
  let insert_result = d1
    .prepare("INSERT INTO users (name, email) VALUES (?, ?)")
    .bind2(@core.any("Alice"), @core.any("alice@example.com"))
    .run()
  let last_id : Int? = insert_result.meta().map(fn(m) {
    m.last_row_id().unwrap_or(0)
  })

  // Query data
  let row : @core.Any? = d1
    .prepare("SELECT * FROM users WHERE name = ?")
    .bind1(@core.any("Alice"))
    .first()
  let name : String = row.map(fn(r : @core.Any) { r["name"].cast() }).unwrap_or(
    "",
  )
  let email : String = row
    .map(fn(r : @core.Any) { r["email"].cast() })
    .unwrap_or("")

  // Count
  let count_row : @core.Any? = d1
    .prepare("SELECT COUNT(*) as count FROM users")
    .first()
  let count : Int = count_row
    .map(fn(r : @core.Any) { @cloudflare.js_number_to_int(r["count"]) })
    .unwrap_or(0)

  mf.dispose()

  @core.from_entries([
    ("success", @core.any(true)),
    ("lastId", @core.any(last_id)),
    ("name", @core.any(name)),
    ("email", @core.any(email)),
    ("count", @core.any(count)),
  ])
}

///|
/// Test R2 bucket operations
pub async fn test_r2() -> @core.Any {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    r2Buckets: Some(["TEST_R2"]),
  })
  mf.ready()
  let r2 = mf.get_r2_bucket("TEST_R2")

  // Put object
  let _ = r2.put("test-key", @core.any("Hello, R2!"))

  // Get object
  let obj = r2.get("test-key")
  let text = match obj {
    Some(o) => o.text()
    None => ""
  }

  // Put with metadata
  let custom_meta = @core.from_entries([
    ("author", @core.any("moonbit")),
    ("version", @core.any("1.0")),
  ])
  let http_meta : @cloudflare.R2HttpMetadata = {
    contentType: Some("text/plain"),
    contentLanguage: None,
    contentDisposition: None,
    contentEncoding: None,
    cacheControl: None,
    cacheExpiry: None,
  }
  let _ = r2.put(
    "with-meta",
    @core.any("content"),
    httpMetadata=http_meta,
    customMetadata=custom_meta,
  )

  // List objects
  let list = r2.list()
  let count = list.objects().length()

  // Delete object
  r2.delete("test-key")

  mf.dispose()

  @core.from_entries([
    ("success", @core.any(true)),
    ("text", @core.any(text)),
    ("objectCount", @core.any(count)),
  ])
}

///|
/// Test KV namespace operations
pub async fn test_kv() -> @core.Any {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    kvNamespaces: Some(["TEST_KV"]),
  })
  mf.ready()
  let kv = mf.get_kv_namespace("TEST_KV")

  // Put value
  kv.put("hello", "world")

  // Get value
  let value = kv.get("hello")

  // Put JSON
  let json_data = @core.from_entries([
    ("name", @core.any("test")),
    ("count", @core.any(42)),
  ])
  kv.put("json-key", @core.json_stringify(json_data))

  // Get JSON
  let json_value = kv.get_json("json-key")

  // List keys
  kv.put("list:a", "1")
  kv.put("list:b", "2")
  kv.put("list:c", "3")
  let list_result = kv.list(prefix="list:")
  let key_count = list_result.keys.length()

  // Delete
  kv.delete("hello")
  let deleted = kv.get("hello")

  mf.dispose()

  @core.from_entries([
    ("success", @core.any(true)),
    ("value", @core.any(value)),
    ("jsonValue", json_value.unwrap_or(@core.any(()))),
    ("keyCount", @core.any(key_count)),
    ("deletedIsNull", @core.any(deleted is None)),
  ])
}

///|
fn main {
  ()
}
