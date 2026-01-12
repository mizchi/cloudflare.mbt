import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    testTimeout: 30000,
    include: ["e2e/**/*.test.ts"],
    exclude: ["node_modules", ".mooncakes"],
  },
});
