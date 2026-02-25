// Cloudflare Browser Rendering bindings

///|
#external
pub type BrowserFetcher

///|
pub fn BrowserFetcher::as_any(self : BrowserFetcher) -> @core.Any = "%identity"

///|
pub async fn BrowserFetcher::fetch(
  self : BrowserFetcher,
  input : @core.Any,
  init? : @core.Any,
) -> @http.Response {
  let promise : @core.Promise[@http.Response] = match init {
    Some(value) => self.as_any()._call("fetch", [input, value]).cast()
    None => self.as_any()._call("fetch", [input]).cast()
  }
  promise.wait()
}

///|
pub async fn BrowserFetcher::fetch_url(
  self : BrowserFetcher,
  url : String,
  init? : @core.Any,
) -> @http.Response {
  match init {
    Some(value) => self.fetch(@core.any(url), init=value)
    None => self.fetch(@core.any(url))
  }
}

///|
pub async fn BrowserFetcher::fetch_request(
  self : BrowserFetcher,
  request : @http.Request,
  init? : @core.Any,
) -> @http.Response {
  match init {
    Some(value) => self.fetch(@core.any(request), init=value)
    None => self.fetch(@core.any(request))
  }
}

///|
pub fn BrowserFetcher::connect(
  self : BrowserFetcher,
  address : String,
  options? : @core.Any,
) -> @core.Any {
  match options {
    Some(value) => self.as_any()._call("connect", [@core.any(address), value])
    None => self.as_any()._call("connect", [@core.any(address)])
  }
}
