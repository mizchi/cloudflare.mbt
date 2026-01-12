import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    testTimeout: 30000,
    include: ["e2e/**/*.test.ts"],
    exclude: [
      "node_modules",
      ".mooncakes",
      // cloudflare:test requires @cloudflare/vitest-pool-workers setup
      "e2e/cloudflare/**",
    ],
  },
});
