// Cloudflare D1 Database bindings

///| D1 Error type for database operations
pub suberror D1Error {
  D1Error(String)
} derive(Show)

///|
#external
pub type D1Database

///|
pub fn D1Database::as_any(self : D1Database) -> @core.Any = "%identity"

///|
/// Prepare a SQL statement
pub fn D1Database::prepare(self : Self, query : String) -> D1PreparedStatement {
  self.as_any()._call("prepare", [@core.any(query)]).cast()
}

///|
/// Execute a SQL statement directly (for statements that don't return data)
pub async fn D1Database::exec(self : Self, query : String) -> D1ExecResult raise D1Error {
  let promise = self.as_any()._call("exec", [@core.any(query)])
  await_d1_exec_result(promise).unwrap_or_raise()
}

///|
/// Batch execute multiple prepared statements in a transaction
pub async fn D1Database::batch(
  self : Self,
  statements : Array[D1PreparedStatement],
) -> Array[D1Result] raise D1Error {
  let stmts_js = @core.new_array()
  let mut i = 0
  while i < statements.length() {
    @core.any(stmts_js)._call("push", [@core.any(statements[i])]) |> ignore
    i = i + 1
  }
  let promise = self.as_any()._call("batch", [@core.any(stmts_js)])
  await_d1_result_array(promise).unwrap_or_raise()
}

///|
/// Dump the entire database (returns ArrayBuffer as Bytes)
pub async fn D1Database::dump(self : Self) -> Bytes raise D1Error {
  let promise = self.as_any()._call("dump", [])
  await_bytes(promise).unwrap_or_raise()
}

///|
/// Prepared statement type
#external
pub type D1PreparedStatement

///|
pub fn D1PreparedStatement::as_any(self : D1PreparedStatement) -> @core.Any = "%identity"

///|
/// Bind parameters to a prepared statement
/// Note: This wraps parameters in an array and spreads them to match Cloudflare's API
pub fn D1PreparedStatement::bind(
  self : Self,
  params : Array[@core.Any],
) -> Self {
  // Cloudflare's bind() expects variadic arguments, not an array
  // We need to spread the array when calling bind
  let stmt_js = self.as_any()
  let bind_fn = stmt_js["bind"]

  // Convert MoonBit array to JavaScript array
  let params_js = @core.new_array()
  let mut i = 0
  while i < params.length() {
    @core.any(params_js)._call("push", [@core.any(params[i])]) |> ignore
    i = i + 1
  }

  // Use apply to spread the array as individual arguments
  bind_fn._call("apply", [stmt_js, @core.any(params_js)]).cast()
}

///|
/// Bind a single parameter
pub fn D1PreparedStatement::bind1(self : Self, param : @core.Any) -> Self {
  self.bind([param])
}

///|
/// Bind two parameters
pub fn D1PreparedStatement::bind2(
  self : Self,
  p1 : @core.Any,
  p2 : @core.Any,
) -> Self {
  self.bind([p1, p2])
}

///|
/// Bind three parameters
pub fn D1PreparedStatement::bind3(
  self : Self,
  p1 : @core.Any,
  p2 : @core.Any,
  p3 : @core.Any,
) -> Self {
  self.bind([p1, p2, p3])
}

///|
/// Execute the statement and return first row
pub async fn D1PreparedStatement::first(self : Self) -> @core.Any? raise D1Error {
  let promise = self.as_any()._call("first", [])
  await_any_option(promise).unwrap_or_raise()
}

///|
/// Execute the statement and return first column value
pub async fn D1PreparedStatement::first_col(
  self : Self,
  col_name : String,
) -> @core.Any? raise D1Error {
  let promise = self.as_any()._call("first", [@core.any(col_name)])
  await_any_option(promise).unwrap_or_raise()
}

///|
/// Execute the statement and return all rows
pub async fn D1PreparedStatement::all(self : Self) -> D1Result raise D1Error {
  let promise = self.as_any()._call("all", [])
  await_d1_result(promise).unwrap_or_raise()
}

///|
/// Execute the statement (for INSERT, UPDATE, DELETE)
pub async fn D1PreparedStatement::run(self : Self) -> D1Result raise D1Error {
  let promise = self.as_any()._call("run", [])
  await_d1_result(promise).unwrap_or_raise()
}

///|
/// Execute and return raw results
pub async fn D1PreparedStatement::raw(
  self : Self,
  columnNames? : Bool,
) -> Array[@core.Any] raise D1Error {
  let promise = if columnNames is None {
    self.as_any()._call("raw", [])
  } else {
    let entries : Array[(String, @core.Any)] = []
    if columnNames is Some(v) {
      entries.push(("columnNames", @core.any(v)))
    }
    let opts = @core.from_entries(entries)
    self.as_any()._call("raw", [opts])
  }
  await_any_array(promise).unwrap_or_raise()
}

///|
/// Result of a D1 query (external type to properly handle JS object properties)
#external
pub type D1Result

///|
pub fn D1Result::as_any(self : D1Result) -> @core.Any = "%identity"

///|
/// Check if the query was successful
pub fn D1Result::success(self : D1Result) -> Bool {
  self.as_any()["success"].cast()
}

///|
/// Get the error message if any
pub fn D1Result::error(self : D1Result) -> String? {
  let err = self.as_any()["error"]
  if @core.typeof_(err) == "undefined" || @core.is_null(err) {
    None
  } else {
    Some(err.cast())
  }
}

///|
/// Get the query metadata
pub fn D1Result::meta(self : D1Result) -> D1Meta? {
  let meta = self.as_any()["meta"]
  if @core.typeof_(meta) == "undefined" || @core.is_null(meta) {
    None
  } else {
    Some(meta.cast())
  }
}

///|
/// Get results from D1Result as a raw JS array
pub fn D1Result::results_raw(self : D1Result) -> @core.Any {
  let results = self.as_any()["results"]
  if @core.typeof_(results) == "undefined" || @core.is_null(results) {
    @core.new_array()
  } else {
    results
  }
}

///|
/// Get results from D1Result
///
/// Note: The returned array is a snapshot and should be treated as immutable.
pub fn D1Result::get_results(self : D1Result) -> Array[@core.Any] {
  self.results_raw().cast()
}

///|
/// Metadata about query execution (external type)
#external
pub type D1Meta

///|
pub fn D1Meta::as_any(self : D1Meta) -> @core.Any = "%identity"

///|
/// Query duration in milliseconds
pub fn D1Meta::duration(self : D1Meta) -> Double? {
  let v = self.as_any()["duration"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Number of rows read
pub fn D1Meta::rows_read(self : D1Meta) -> Int? {
  let v = self.as_any()["rows_read"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Number of rows written
pub fn D1Meta::rows_written(self : D1Meta) -> Int? {
  let v = self.as_any()["rows_written"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Last inserted row ID
pub fn D1Meta::last_row_id(self : D1Meta) -> Int? {
  let v = self.as_any()["last_row_id"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Whether database was changed
pub fn D1Meta::changed_db(self : D1Meta) -> Bool? {
  let v = self.as_any()["changed_db"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Number of rows changed
pub fn D1Meta::changes(self : D1Meta) -> Int? {
  let v = self.as_any()["changes"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Database size after query
pub fn D1Meta::size_after(self : D1Meta) -> Int? {
  let v = self.as_any()["size_after"]
  if @core.typeof_(v) == "undefined" || @core.is_null(v) {
    None
  } else {
    Some(v.cast())
  }
}

///|
/// Result of exec operation (external type)
#external
pub type D1ExecResult

///|
pub fn D1ExecResult::as_any(self : D1ExecResult) -> @core.Any = "%identity"

///|
/// Number of statements executed
pub fn D1ExecResult::count(self : D1ExecResult) -> Int {
  self.as_any()["count"].cast()
}

///|
/// Total duration in milliseconds
pub fn D1ExecResult::duration(self : D1ExecResult) -> Double {
  self.as_any()["duration"].cast()
}

///|
/// Legacy type alias for compatibility
pub type D1ResultSet = D1Result

// ============================================================================
// Type conversion utilities for D1 row data
// ============================================================================

///|
/// Convert a JavaScript number from D1 result to MoonBit Int64
/// D1 returns SQLite INTEGER as JavaScript numbers, but MoonBit Int64
/// uses { hi, lo } representation in JS target.
pub fn js_number_to_int64(value : @core.Any) -> Int64 {
  js_number_to_int64_ffi(value)
}

///|
extern "js" fn js_number_to_int64_ffi(value : @core.Any) -> Int64 =
  #| (n) => {
  #|   // JavaScript number to MoonBit Int64 ({hi, lo} representation)
  #|   if (typeof n !== 'number') n = Number(n);
  #|   // Handle negative numbers correctly
  #|   if (n < 0) {
  #|     // Two's complement for negative numbers
  #|     const abs = Math.abs(n);
  #|     const lo = (~(abs >>> 0) + 1) >>> 0;
  #|     const hi = (~Math.floor(abs / 0x100000000) + (lo === 0 ? 1 : 0)) >>> 0;
  #|     return { hi, lo };
  #|   }
  #|   return { hi: Math.floor(n / 0x100000000) >>> 0, lo: (n >>> 0) };
  #| }

///|
/// Convert a JavaScript number from D1 result to MoonBit Int (32-bit)
pub fn js_number_to_int(value : @core.Any) -> Int {
  js_number_to_int_ffi(value)
}

///|
extern "js" fn js_number_to_int_ffi(value : @core.Any) -> Int =
  #| (n) => (typeof n === 'number' ? n : Number(n)) | 0

// ============================================================================
// Error handling utilities for D1 async operations
// ============================================================================

///| Result type for D1Result async operations
priv struct D1ResultAsync {
  ok : D1Result?
  err : String?
}

///|
fn D1ResultAsync::unwrap_or_raise(self : D1ResultAsync) -> D1Result raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => match self.ok {
      Some(v) => v
      None => raise D1Error("D1 operation returned null")
    }
  }
}

///| Result type for D1ExecResult async operations
priv struct D1ExecResultAsync {
  ok : D1ExecResult?
  err : String?
}

///|
fn D1ExecResultAsync::unwrap_or_raise(self : D1ExecResultAsync) -> D1ExecResult raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => match self.ok {
      Some(v) => v
      None => raise D1Error("D1 operation returned null")
    }
  }
}

///| Result type for Bytes async operations
priv struct BytesAsync {
  ok : Bytes?
  err : String?
}

///|
fn BytesAsync::unwrap_or_raise(self : BytesAsync) -> Bytes raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => match self.ok {
      Some(v) => v
      None => raise D1Error("D1 operation returned null")
    }
  }
}

///| Result type for @core.Any? async operations
priv struct AnyOptionAsync {
  ok : @core.Any?
  err : String?
  is_null : Bool
}

///|
fn AnyOptionAsync::unwrap_or_raise(self : AnyOptionAsync) -> @core.Any? raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => if self.is_null { None } else { self.ok }
  }
}

///| Result type for Array[D1Result] async operations
priv struct D1ResultArrayAsync {
  ok : Array[D1Result]?
  err : String?
}

///|
fn D1ResultArrayAsync::unwrap_or_raise(self : D1ResultArrayAsync) -> Array[D1Result] raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => match self.ok {
      Some(v) => v
      None => raise D1Error("D1 operation returned null")
    }
  }
}

///| Result type for Array[@core.Any] async operations
priv struct AnyArrayAsync {
  ok : Array[@core.Any]?
  err : String?
}

///|
fn AnyArrayAsync::unwrap_or_raise(self : AnyArrayAsync) -> Array[@core.Any] raise D1Error {
  match self.err {
    Some(msg) => raise D1Error(msg)
    None => match self.ok {
      Some(v) => v
      None => raise D1Error("D1 operation returned null")
    }
  }
}

// FFI functions for awaiting with error handling

///|
extern "js" fn await_d1_result(promise : @core.Any) -> D1ResultAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     return { ok: result, err: undefined };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e) };
  #|   }
  #| }

///|
extern "js" fn await_d1_exec_result(promise : @core.Any) -> D1ExecResultAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     return { ok: result, err: undefined };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e) };
  #|   }
  #| }

///|
extern "js" fn await_bytes(promise : @core.Any) -> BytesAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     return { ok: result, err: undefined };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e) };
  #|   }
  #| }

///|
extern "js" fn await_any_option(promise : @core.Any) -> AnyOptionAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     const isNull = result === null || result === undefined;
  #|     return { ok: isNull ? undefined : result, err: undefined, is_null: isNull };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e), is_null: false };
  #|   }
  #| }

///|
extern "js" fn await_d1_result_array(promise : @core.Any) -> D1ResultArrayAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     return { ok: result, err: undefined };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e) };
  #|   }
  #| }

///|
extern "js" fn await_any_array(promise : @core.Any) -> AnyArrayAsync =
  #| async (p) => {
  #|   try {
  #|     const result = await p;
  #|     return { ok: result, err: undefined };
  #|   } catch (e) {
  #|     return { ok: undefined, err: e?.message ?? String(e) };
  #|   }
  #| }
