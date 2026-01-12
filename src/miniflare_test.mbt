///|
async test {
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
