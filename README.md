# cloudflare.mbt

MoonBit bindings for Cloudflare Workers APIs

## Features

- **KV (Workers KV)**: Key-value storage
- **D1**: Serverless SQL database
- **R2**: Object storage
- **Durable Objects**: Stateful serverless objects
- **Queues**: Message queues
- **Workers AI / AI SDK**: Model inference and SDK wrapper
- **Analytics Engine**: Analytics data points
- **Hyperdrive**: Database acceleration binding
- **Email Workers**: Send/forward/reply email APIs
- **Browser Rendering**: Fetcher/connect binding
- **Access Helpers**: Access headers and TLS client auth helpers
- **Turnstile**: Siteverify helper

## Installation

Add the Cloudflare bindings and the JavaScript modules your code imports to `moon.mod`:

```moonbit
import {
  "mizchi/cloudflare@0.1.12",
  "mizchi/js_core@0.13.0",
  "mizchi/js_web@0.13.0",
}
```

JavaScript bindings use the split `mizchi/js_*` modules introduced in 0.13.0.
For example, import `"mizchi/js_core" @core` and `"mizchi/js_web/http"`
in `moon.pkg` instead of `mizchi/js/core` and `mizchi/js/web/http`.

## Usage

See examples in `examples/cfw/` directory.

## Development

```bash
# Install dependencies
pnpm install

# Run development server
pnpm dev

# Run tests
pnpm test
```

## Testing

Tests are located in `e2e/cloudflare/` and use Vitest with `@cloudflare/vitest-pool-workers`.

## License

MIT
