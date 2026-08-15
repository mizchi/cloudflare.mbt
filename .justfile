# Build and test commands for cloudflare.mbt

# Run all tests (MoonBit packages + Miniflare e2e)
test: build
    moon test --target js -p mizchi/cloudflare/agents -p mizchi/cloudflare/ai -p mizchi/cloudflare/containers -p mizchi/cloudflare/sandbox -p mizchi/cloudflare/services
    moon test --target js src/ai_workflow_env_test.mbt
    pnpm test

# Build MoonBit project
build:
    moon build --target js

# Run only MoonBit tests
test-mbt:
    moon test --target js

# Run only vitest e2e tests
test-e2e:
    npx vitest run --config vitest.cf-config.ts
    npx vitest run --config vitest.do-config.ts

# Run only Durable Objects tests
test-do:
    npx vitest run --config vitest.do-config.ts

# Check MoonBit code
check:
    moon check --deny-warn --target js

# Format MoonBit code
fmt:
    moon fmt

# Update MoonBit interface files
info:
    moon info

# Pre-release verification
release-check: fmt info check test
