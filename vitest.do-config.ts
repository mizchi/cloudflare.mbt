// For Durable Objects testing with Vitest and vitest-pool-workers
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  test: {
    testTimeout: 30000,
    include: ["e2e/cloudflare/durable-objects.test.ts"],
    poolOptions: {
      workers: {
        singleWorker: true,
        isolatedStorage: false,
        main: "./e2e/cloudflare/durable-objects.test.ts",
        miniflare: {
          durableObjects: {
            TEST_DO: "TestDurableObject",
          },
        },
      },
    },
  },
});
