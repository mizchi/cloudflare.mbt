// Cloudflare Access helper bindings

///|
fn access_is_js_nullish(value : @core.Any) -> Bool {
  @core.typeof_(value) == "undefined" || @core.is_null(value)
}

///|
fn access_header_value(headers : @http.Headers, name : String) -> String? {
  headers.as_any()._call("get", [@core.any(name)]) |> @core.identity_option
}

///|
pub fn access_jwt_assertion_from_headers(headers : @http.Headers) -> String? {
  access_header_value(headers, "cf-access-jwt-assertion")
}

///|
pub fn access_authenticated_user_email_from_headers(
  headers : @http.Headers,
) -> String? {
  access_header_value(headers, "cf-access-authenticated-user-email")
}

///|
pub fn access_authenticated_user_id_from_headers(
  headers : @http.Headers,
) -> String? {
  access_header_value(headers, "cf-access-authenticated-user-id")
}

///|
pub fn CloudflareRequest::access_jwt_assertion(
  self : CloudflareRequest,
) -> String? {
  access_jwt_assertion_from_headers(self.headers())
}

///|
pub fn CloudflareRequest::access_authenticated_user_email(
  self : CloudflareRequest,
) -> String? {
  access_authenticated_user_email_from_headers(self.headers())
}

///|
pub fn CloudflareRequest::access_authenticated_user_id(
  self : CloudflareRequest,
) -> String? {
  access_authenticated_user_id_from_headers(self.headers())
}

///|
pub fn CloudflareRequest::tls_client_auth(
  self : CloudflareRequest,
) -> @core.Any? {
  let cf = self.as_any()["cf"]
  if access_is_js_nullish(cf) {
    None
  } else {
    let tls_client_auth = cf["tlsClientAuth"]
    if access_is_js_nullish(tls_client_auth) {
      None
    } else {
      Some(tls_client_auth)
    }
  }
}
