# Build and test commands for cloudflare.mbt

# Run all tests (MoonBit + vitest e2e)
test: build
    moon test --target js
    npx vitest run --config vitest.cf-config.ts
    npx vitest run --config vitest.do-config.ts

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
    moon check

# Format MoonBit code
fmt:
    moon fmt

# Update MoonBit interface files
info:
    moon info
