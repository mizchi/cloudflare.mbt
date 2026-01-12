///|
async test "D1 basic operations" {
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
  let last_id : Int? = insert_result
    .meta()
    .map(fn(m) { m.last_row_id().unwrap_or(0) })
  assert_true(last_id is Some(_))

  // Query data
  let row : @core.Any? = d1
    .prepare("SELECT * FROM users WHERE name = ?")
    .bind1(@core.any("Alice"))
    .first()
  let name : String = row
    .map(fn(r : @core.Any) { r["name"].cast() })
    .unwrap_or("")
  let email : String = row
    .map(fn(r : @core.Any) { r["email"].cast() })
    .unwrap_or("")
  assert_eq(name, "Alice")
  assert_eq(email, "alice@example.com")

  // Count
  let count_row : @core.Any? = d1
    .prepare("SELECT COUNT(*) as count FROM users")
    .first()
  let count : Int = count_row
    .map(fn(r : @core.Any) { @cloudflare.js_number_to_int(r["count"]) })
    .unwrap_or(0)
  assert_eq(count, 1)
  mf.dispose()
}

///|
async test "KV basic operations" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    kvNamespaces: Some(["TEST_KV"]),
  })
  mf.ready()
  let kv = mf.get_kv_namespace("TEST_KV")

  // Put and get string value
  kv.put("key1", "value1")
  let value1 = kv.get("key1")
  assert_eq(value1, Some("value1"))

  // Get non-existent key
  let missing = kv.get("nonexistent")
  assert_eq(missing, None)

  // Update existing key
  kv.put("key1", "updated_value")
  let updated = kv.get("key1")
  assert_eq(updated, Some("updated_value"))

  // Delete key
  kv.delete("key1")
  let deleted = kv.get("key1")
  assert_eq(deleted, None)
  mf.dispose()
}

///|
async test "KV JSON operations" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    kvNamespaces: Some(["TEST_KV"]),
  })
  mf.ready()
  let kv = mf.get_kv_namespace("TEST_KV")

  // Store JSON as string
  kv.put("json_key", "{\"name\":\"test\",\"count\":42}")

  // Get as JSON
  let json_value = kv.get_json("json_key")
  match json_value {
    Some(obj) => {
      let name : String = obj["name"].cast()
      let count : Int = @cloudflare.js_number_to_int(obj["count"])
      assert_eq(name, "test")
      assert_eq(count, 42)
    }
    None => assert_true(false) // Should not reach here
  }

  // Get non-existent key as JSON should return None
  let missing = kv.get_json("nonexistent")
  assert_true(missing is None)

  mf.dispose()
}

///|
async test "KV list operations" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    kvNamespaces: Some(["TEST_KV"]),
  })
  mf.ready()
  let kv = mf.get_kv_namespace("TEST_KV")

  // Put multiple keys
  kv.put("prefix:a", "value_a")
  kv.put("prefix:b", "value_b")
  kv.put("other:c", "value_c")

  // List all keys
  let all_result = kv.list()
  assert_eq(all_result.keys.length(), 3)

  // List with prefix
  let prefix_result = kv.list(prefix="prefix:")
  assert_eq(prefix_result.keys.length(), 2)

  // List with limit
  let limited_result = kv.list(limit=1)
  assert_eq(limited_result.keys.length(), 1)
  mf.dispose()
}

///|
async test "R2 basic operations" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    r2Buckets: Some(["TEST_BUCKET"]),
  })
  mf.ready()
  let r2 = mf.get_r2_bucket("TEST_BUCKET")

  // Put and get object
  let _ = r2.put("test.txt", @core.any("Hello, R2!"))
  let obj = r2.get("test.txt")
  assert_true(obj is Some(_))
  let r2_obj = obj.unwrap()
  let content = r2_obj.text()
  assert_eq(content, "Hello, R2!")
  assert_eq(r2_obj.key(), "test.txt")

  // Get non-existent object
  let missing = r2.get("nonexistent.txt")
  assert_true(missing is None)

  // Delete object
  r2.delete("test.txt")
  let deleted = r2.get("test.txt")
  assert_true(deleted is None)
  mf.dispose()
}

///|
async test "R2 object metadata" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    r2Buckets: Some(["TEST_BUCKET"]),
  })
  mf.ready()
  let r2 = mf.get_r2_bucket("TEST_BUCKET")

  // Put with HTTP metadata
  let metadata : @cloudflare.R2HttpMetadata = {
    contentType: Some("text/plain"),
    contentLanguage: None,
    contentDisposition: None,
    contentEncoding: None,
    cacheControl: Some("max-age=3600"),
    cacheExpiry: None,
  }
  let _ = r2.put("meta.txt", @core.any("content"), httpMetadata=metadata)

  // Head to get metadata only
  let head_result = r2.head("meta.txt")
  assert_true(head_result is Some(_))
  let head_obj = head_result.unwrap()
  assert_eq(head_obj.key(), "meta.txt")
  mf.dispose()
}

///|
async test "R2 list operations" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    r2Buckets: Some(["TEST_BUCKET"]),
  })
  mf.ready()
  let r2 = mf.get_r2_bucket("TEST_BUCKET")

  // Put multiple objects
  let _ = r2.put("folder/file1.txt", @core.any("content1"))
  let _ = r2.put("folder/file2.txt", @core.any("content2"))
  let _ = r2.put("other/file3.txt", @core.any("content3"))

  // List all
  let all_result = r2.list()
  assert_eq(all_result.objects().length(), 3)

  // List with prefix
  let prefix_result = r2.list(prefix="folder/")
  assert_eq(prefix_result.objects().length(), 2)

  // List with limit
  let limited_result = r2.list(limit=1)
  assert_eq(limited_result.objects().length(), 1)
  assert_eq(limited_result.truncated(), true)
  mf.dispose()
}

///|
async test "R2 delete multiple" {
  let mf = @cloudflare.Miniflare::new({
    ..@cloudflare.MiniflareOptions::default(),
    r2Buckets: Some(["TEST_BUCKET"]),
  })
  mf.ready()
  let r2 = mf.get_r2_bucket("TEST_BUCKET")

  // Put multiple objects
  let _ = r2.put("del1.txt", @core.any("content1"))
  let _ = r2.put("del2.txt", @core.any("content2"))
  let _ = r2.put("del3.txt", @core.any("content3"))

  // Delete multiple
  r2.delete_multiple(["del1.txt", "del2.txt"])

  // Verify deletions
  let del1 = r2.get("del1.txt")
  let del2 = r2.get("del2.txt")
  let del3 = r2.get("del3.txt")
  assert_true(del1 is None)
  assert_true(del2 is None)
  assert_true(del3 is Some(_))
  mf.dispose()
}
