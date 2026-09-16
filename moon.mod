name = "mizchi/cloudflare"

version = "0.1.12"

import {
  "mizchi/js_builtin@0.13.0",
  "mizchi/js_core@0.13.0",
  "mizchi/js_web@0.13.0",
  "moonbitlang/async@0.20.5",
  "mizchi/js@0.13.0",
}

readme = "README.md"

repository = "https://github.com/mizchi/cloudflare.mbt"

license = "MIT"

keywords = [ "cloudflare", "workers", "kv", "d1", "r2", "durable-objects" ]

description = "MoonBit bindings for Cloudflare Workers APIs (KV, D1, R2, Durable Objects, etc.)"

source = "src"

warnings = "-29-53"

preferred_target = "js"
