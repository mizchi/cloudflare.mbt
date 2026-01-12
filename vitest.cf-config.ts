// For Cloudflare Workers testing with Vitest and vitest-pool-workers
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  test: {
    testTimeout: 30000, // Increase timeout to 30 seconds
    include: ["e2e/cloudflare/**/*.test.ts"],
    exclude: [
      "node_modules",
      ".mooncakes",
      "_build",
      "e2e/cloudflare/durable-objects.test.ts", // Requires separate config (vitest.do-config.ts)
      "e2e/cloudflare/r2.test.ts", // Isolated storage issues
    ],
    poolOptions: {
      workers: {
        miniflare: {
          kvNamespaces: ["TEST_KV", "MY_KV"],
          d1Databases: ["TEST_DB", "CMS_DB"],
          r2Buckets: ["TEST_R2", "CMS_R2"],
        },
      },
    },
  },
});
