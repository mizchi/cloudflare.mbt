// Cloudflare Workers Analytics Engine bindings

///|
fn analytics_to_js_array(values : Array[@core.Any]) -> @core.Any {
  let out = @core.new_array()
  let mut i = 0
  while i < values.length() {
    @core.any(out)._call("push", [values[i]]) |> ignore
    i = i + 1
  }
  out
}

///|
fn analytics_to_js_double_array(values : Array[Double]) -> @core.Any {
  let out = @core.new_array()
  let mut i = 0
  while i < values.length() {
    @core.any(out)._call("push", [@core.any(values[i])]) |> ignore
    i = i + 1
  }
  out
}

///|
#external
pub type AnalyticsEngineDataset

///|
pub fn AnalyticsEngineDataset::as_any(
  self : AnalyticsEngineDataset,
) -> @core.Any = "%identity"

///|
pub(all) struct AnalyticsEngineDataPoint {
  indexes : Array[@core.Any]?
  doubles : Array[Double]?
  blobs : Array[@core.Any]?
}

///|
pub fn AnalyticsEngineDataPoint::to_js(
  self : AnalyticsEngineDataPoint,
) -> @core.Any {
  let obj = @core.new_object()
  if self.indexes is Some(values) {
    obj["indexes"] = analytics_to_js_array(values)
  }
  if self.doubles is Some(values) {
    obj["doubles"] = analytics_to_js_double_array(values)
  }
  if self.blobs is Some(values) {
    obj["blobs"] = analytics_to_js_array(values)
  }
  obj
}

///|
pub fn AnalyticsEngineDataPoint::default() -> AnalyticsEngineDataPoint {
  { indexes: None, doubles: None, blobs: None }
}

///|
pub fn AnalyticsEngineDataset::write_data_point(
  self : AnalyticsEngineDataset,
  event? : AnalyticsEngineDataPoint,
) -> Unit {
  match event {
    Some(value) =>
      self.as_any()._call("writeDataPoint", [value.to_js()]) |> ignore
    None => self.as_any()._call("writeDataPoint", []) |> ignore
  }
}
