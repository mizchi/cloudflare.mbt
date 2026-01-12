/**
 * Standalone Miniflare test - without vitest-pool-workers
 * Uses Miniflare API directly to test D1 and R2
 */
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { Miniflare } from "miniflare";

describe("Standalone Miniflare - D1", () => {
  let mf: Miniflare;
  let d1: D1Database;

  beforeAll(async () => {
    mf = new Miniflare({
      modules: true,
      script: `
        export default {
          async fetch(request, env) {
            return new Response("OK");
          }
        }
      `,
      d1Databases: ["TEST_DB"],
    });
    await mf.ready;
    d1 = await mf.getD1Database("TEST_DB");
  });

  afterAll(async () => {
    await mf.dispose();
  });

  it("should execute D1 queries", async () => {
    // Create table
    await d1.exec(
      "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL)"
    );

    // Insert data
    const insertResult = await d1
      .prepare("INSERT INTO users (name, email) VALUES (?, ?)")
      .bind("Alice", "alice@example.com")
      .run();

    expect(insertResult.success).toBe(true);
    expect(insertResult.meta.last_row_id).toBeGreaterThan(0);

    // Query data
    const selectResult = await d1
      .prepare("SELECT * FROM users WHERE name = ?")
      .bind("Alice")
      .first();

    expect(selectResult).toBeDefined();
    expect(selectResult?.name).toBe("Alice");
    expect(selectResult?.email).toBe("alice@example.com");
  });

  it("should handle D1 batch operations", async () => {
    // Create fresh table
    await d1.exec("DROP TABLE IF EXISTS batch_test");
    await d1.exec(
      "CREATE TABLE batch_test (id INTEGER PRIMARY KEY AUTOINCREMENT, value TEXT)"
    );

    // Batch insert
    const batchResults = await d1.batch([
      d1.prepare("INSERT INTO batch_test (value) VALUES (?)").bind("one"),
      d1.prepare("INSERT INTO batch_test (value) VALUES (?)").bind("two"),
      d1.prepare("INSERT INTO batch_test (value) VALUES (?)").bind("three"),
    ]);

    expect(batchResults).toHaveLength(3);
    batchResults.forEach((result) => {
      expect(result.success).toBe(true);
    });

    // Verify count
    const countResult = await d1
      .prepare("SELECT COUNT(*) as count FROM batch_test")
      .first();
    expect(countResult?.count).toBe(3);
  });
});

describe("Standalone Miniflare - R2", () => {
  let mf: Miniflare;
  let r2: R2Bucket;

  beforeAll(async () => {
    mf = new Miniflare({
      modules: true,
      script: `
        export default {
          async fetch(request, env) {
            return new Response("OK");
          }
        }
      `,
      r2Buckets: ["TEST_R2"],
    });
    await mf.ready;
    r2 = await mf.getR2Bucket("TEST_R2");
  });

  afterAll(async () => {
    await mf.dispose();
  });

  it("should put and get objects", async () => {
    await r2.put("test-key", "Hello, R2!");

    const obj = await r2.get("test-key");
    expect(obj).not.toBeNull();
    expect(await obj?.text()).toBe("Hello, R2!");
  });

  it("should handle binary data", async () => {
    const binaryData = new Uint8Array([0x00, 0x01, 0x02, 0xff]);
    await r2.put("binary-key", binaryData);

    const obj = await r2.get("binary-key");
    expect(obj).not.toBeNull();

    const retrieved = new Uint8Array(await obj!.arrayBuffer());
    expect(retrieved).toEqual(binaryData);
  });

  it("should list objects", async () => {
    // Clean up first
    const existing = await r2.list();
    for (const obj of existing.objects) {
      await r2.delete(obj.key);
    }

    // Put multiple objects
    await r2.put("list/a.txt", "A");
    await r2.put("list/b.txt", "B");
    await r2.put("list/c.txt", "C");

    const list = await r2.list({ prefix: "list/" });
    expect(list.objects).toHaveLength(3);
    expect(list.objects.map((o) => o.key).sort()).toEqual([
      "list/a.txt",
      "list/b.txt",
      "list/c.txt",
    ]);
  });

  it("should delete objects", async () => {
    await r2.put("to-delete", "temporary");

    let obj = await r2.get("to-delete");
    expect(obj).not.toBeNull();

    await r2.delete("to-delete");

    obj = await r2.get("to-delete");
    expect(obj).toBeNull();
  });

  it("should handle object metadata", async () => {
    await r2.put("with-meta", "content", {
      customMetadata: {
        author: "test",
        version: "1.0",
      },
      httpMetadata: {
        contentType: "text/plain",
      },
    });

    const obj = await r2.get("with-meta");
    expect(obj).not.toBeNull();
    expect(obj?.customMetadata).toEqual({
      author: "test",
      version: "1.0",
    });
    expect(obj?.httpMetadata?.contentType).toBe("text/plain");
  });
});

describe("Standalone Miniflare - KV", () => {
  let mf: Miniflare;
  let kv: KVNamespace;

  beforeAll(async () => {
    mf = new Miniflare({
      modules: true,
      script: `
        export default {
          async fetch(request, env) {
            return new Response("OK");
          }
        }
      `,
      kvNamespaces: ["TEST_KV"],
    });
    await mf.ready;
    kv = await mf.getKVNamespace("TEST_KV");
  });

  afterAll(async () => {
    await mf.dispose();
  });

  it("should put and get values", async () => {
    await kv.put("hello", "world");
    const value = await kv.get("hello");
    expect(value).toBe("world");
  });

  it("should handle JSON values", async () => {
    const data = { name: "test", count: 42 };
    await kv.put("json-key", JSON.stringify(data));

    const value = await kv.get("json-key", { type: "json" });
    expect(value).toEqual(data);
  });

  it("should return null for missing keys", async () => {
    const value = await kv.get("non-existent-key");
    expect(value).toBeNull();
  });

  it("should delete values", async () => {
    await kv.put("to-delete", "value");
    expect(await kv.get("to-delete")).toBe("value");

    await kv.delete("to-delete");
    expect(await kv.get("to-delete")).toBeNull();
  });

  it("should list keys", async () => {
    await kv.put("list:a", "1");
    await kv.put("list:b", "2");
    await kv.put("list:c", "3");

    const list = await kv.list({ prefix: "list:" });
    expect(list.keys.map((k) => k.name).sort()).toEqual([
      "list:a",
      "list:b",
      "list:c",
    ]);
  });
});
