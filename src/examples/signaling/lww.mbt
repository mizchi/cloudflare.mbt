// Inlined Last-Writer-Wins EphemeralStore for signaling relay
// Simplified version: all values stored as @core.Any for JS interop

///|
pub(all) struct LwwEntry {
  value : @core.Any
  timestamp : Double
  peer : String
}

///|
pub(all) struct LwwStore {
  data : Map[String, Map[String, LwwEntry]]
}

///|
pub fn LwwStore::new() -> LwwStore {
  { data: Map::new() }
}

///|
fn LwwStore::get_or_create_ns(
  self : LwwStore,
  ns : String,
) -> Map[String, LwwEntry] {
  match self.data.get(ns) {
    Some(m) => m
    None => {
      let m : Map[String, LwwEntry] = Map::new()
      self.data[ns] = m
      m
    }
  }
}

///|
pub fn LwwStore::set(
  self : LwwStore,
  ns : String,
  key : String,
  value : @core.Any,
  timestamp : Double,
  peer : String,
) -> Unit {
  let ns_map = self.get_or_create_ns(ns)
  ns_map[key] = { value, timestamp, peer }
}

///|
/// LWW merge: higher timestamp wins, ties by lexicographic peer
/// Returns true if remote entry was accepted
pub fn LwwStore::merge_entry(
  self : LwwStore,
  ns : String,
  key : String,
  remote : LwwEntry,
) -> Bool {
  let ns_map = self.get_or_create_ns(ns)
  match ns_map.get(key) {
    None => {
      ns_map[key] = remote
      true
    }
    Some(current) =>
      if remote.timestamp > current.timestamp {
        ns_map[key] = remote
        true
      } else if remote.timestamp == current.timestamp &&
        remote.peer > current.peer {
        ns_map[key] = remote
        true
      } else {
        false
      }
  }
}

///|
/// Merge entries from JSON. Returns changed entries as JS object.
/// Input format: { ns: { key: { value, timestamp, peer } } }
pub fn LwwStore::merge_json(
  self : LwwStore,
  entries_js : @core.Any,
) -> @core.Any {
  let changed = @core.new_object()
  let ns_keys = @core.object_keys(entries_js)
  for ns in ns_keys {
    let ns_obj = entries_js[ns]
    let key_names = @core.object_keys(ns_obj)
    for key in key_names {
      let entry_js = ns_obj[key]
      let remote : LwwEntry = {
        value: entry_js["value"],
        timestamp: entry_js["timestamp"].cast(),
        peer: entry_js["peer"].cast(),
      }
      if self.merge_entry(ns, key, remote) {
        // Add to changed
        let ns_changed = if @core.typeof_(changed[ns]) == "undefined" {
          let obj = @core.new_object()
          changed[ns] = obj
          obj
        } else {
          changed[ns]
        }
        ns_changed[key] = entry_js
      }
    }
  }
  changed
}

///|
/// Get snapshot of specified namespaces as JS object
pub fn LwwStore::snapshot(
  self : LwwStore,
  namespaces : Array[String],
) -> @core.Any {
  let result = @core.new_object()
  for ns in namespaces {
    match self.data.get(ns) {
      Some(ns_map) => {
        let ns_obj = @core.new_object()
        let mut has_entries = false
        for key, entry in ns_map {
          let entry_obj = @core.new_object()
          entry_obj["key"] = @core.any(key)
          entry_obj["value"] = entry.value
          entry_obj["timestamp"] = @core.any(entry.timestamp)
          entry_obj["peer"] = @core.any(entry.peer)
          ns_obj[key] = entry_obj
          has_entries = true
        }
        if has_entries {
          result[ns] = ns_obj
        }
      }
      None => ()
    }
  }
  result
}
