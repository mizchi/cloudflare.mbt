// Cloudflare Hyperdrive bindings

///|
#external
pub type Hyperdrive

///|
pub fn Hyperdrive::as_any(self : Hyperdrive) -> @core.Any = "%identity"

///|
pub fn Hyperdrive::connect(self : Hyperdrive) -> @core.Any {
  self.as_any()._call("connect", []).cast()
}

///|
pub fn Hyperdrive::connection_string(self : Hyperdrive) -> String {
  self.as_any()["connectionString"].cast()
}

///|
pub fn Hyperdrive::host(self : Hyperdrive) -> String {
  self.as_any()["host"].cast()
}

///|
pub fn Hyperdrive::port(self : Hyperdrive) -> Int {
  self.as_any()["port"].cast()
}

///|
pub fn Hyperdrive::user(self : Hyperdrive) -> String {
  self.as_any()["user"].cast()
}

///|
pub fn Hyperdrive::password(self : Hyperdrive) -> String {
  self.as_any()["password"].cast()
}

///|
pub fn Hyperdrive::database(self : Hyperdrive) -> String {
  self.as_any()["database"].cast()
}
