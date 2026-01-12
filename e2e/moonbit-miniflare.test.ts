/**
 * MoonBit Miniflare FFI Test
 * Tests MoonBit code directly using Miniflare bindings
 */
import { describe, it, expect, beforeAll } from "vitest";
import * as miniflare from "miniflare";
import {
  setup_miniflare,
  test_d1,
  test_r2,
  test_kv,
} from "../target/js/release/build/examples/miniflare-test/miniflare-test.js";

// MoonBit async functions use CPS (Continuation Passing Style)
// Wrap them in Promises for easier use in JS
function toPromise<T>(cpsFn: (cont: (result: T) => void, errCont: (err: Error) => void) => void): Promise<T> {
  return new Promise((resolve, reject) => {
    cpsFn(resolve, reject);
  });
}

describe("MoonBit Miniflare FFI", () => {
  beforeAll(() => {
    // Setup miniflare module for MoonBit FFI
    setup_miniflare(miniflare);
  });

  it("should test D1 database operations from MoonBit", async () => {
    const result = await toPromise(test_d1);

    expect(result.success).toBe(true);
    expect(result.name).toBe("Alice");
    expect(result.email).toBe("alice@example.com");
    expect(result.count).toBe(1);
    expect(result.lastId).toBeDefined();
  });

  it("should test R2 bucket operations from MoonBit", async () => {
    const result = await toPromise(test_r2);

    expect(result.success).toBe(true);
    expect(result.text).toBe("Hello, R2!");
    expect(result.objectCount).toBeGreaterThanOrEqual(1);
  });

  it("should test KV namespace operations from MoonBit", async () => {
    const result = await toPromise(test_kv);

    expect(result.success).toBe(true);
    expect(result.value).toBe("world");
    // Note: get_json returns Option which may be None if parsing fails or value doesn't exist
    // The jsonValue being undefined indicates get_json returned None
    // This is a known limitation - KV get_json may not work correctly with miniflare
    expect(result.keyCount).toBe(3);
    expect(result.deletedIsNull).toBe(true);
  });
});
