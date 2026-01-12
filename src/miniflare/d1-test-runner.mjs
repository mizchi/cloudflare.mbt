#!/usr/bin/env node
// Miniflare D1 Test Runner for MoonBit
// Provides D1 database in a local testing environment

import { Miniflare } from "miniflare";
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";

/**
 * Run D1 integration tests with miniflare
 * @param {Object} options
 * @param {string} options.rootDir - Root directory of the MoonBit project
 * @param {string} options.schemaPath - Path to the SQL schema file
 * @param {string} options.modulePath - Path to the built MoonBit JS module
 * @param {string} [options.buildCommand] - Command to build MoonBit (default: "moon build --target js")
 */
export async function runD1Tests(options) {
  const {
    rootDir,
    schemaPath,
    modulePath,
    buildCommand = "moon build --target js",
  } = options;

  console.log("🚀 Starting miniflare D1 test harness...\n");

  // Build MoonBit first
  console.log("📦 Building MoonBit...");
  try {
    execSync(buildCommand, {
      cwd: rootDir,
      stdio: "pipe",
    });
  } catch (e) {
    console.error("❌ Failed to build");
    throw e;
  }
  console.log("✅ Build complete\n");

  // Create Miniflare instance with D1
  const mf = new Miniflare({
    modules: true,
    script: `export default { fetch() { return new Response("ok"); } }`,
    d1Databases: {
      DB: "test-db",
    },
  });

  // Get D1 database instance
  const db = await mf.getD1Database("DB");
  console.log("✅ D1 database initialized");

  // Apply schema migration
  const schema = readFileSync(schemaPath, "utf-8");

  // Remove comments and split by semicolons
  const cleanedSchema = schema
    .split("\n")
    .map((line) => {
      const commentIdx = line.indexOf("--");
      return commentIdx >= 0 ? line.slice(0, commentIdx) : line;
    })
    .join("\n");

  const statements = cleanedSchema
    .split(";")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  for (const stmt of statements) {
    await db.prepare(stmt).run();
  }
  console.log("✅ Schema applied (" + statements.length + " statements)\n");

  // Expose D1 to globalThis for MoonBit tests
  globalThis.__MINIFLARE_D1__ = db;

  console.log("🧪 Running MoonBit D1 tests...\n");

  // Import the module - tests auto-run via init function
  await import("file://" + modulePath);

  // Wait for event loop to process all pending async operations
  console.log("\n⏳ Waiting for async operations...");

  // Use a timer-based approach to wait for promises to settle
  for (let i = 0; i < 10; i++) {
    await new Promise((resolve) => setImmediate(resolve));
    await new Promise((resolve) => setTimeout(resolve, 200));
  }

  console.log("\n✅ Tests completed!");

  await mf.dispose();
}

/**
 * Create a D1 test environment without running tests
 * Useful for custom test scenarios
 * @param {Object} options
 * @param {string} options.schemaPath - Path to the SQL schema file
 * @returns {Promise<{db: D1Database, dispose: () => Promise<void>}>}
 */
export async function createD1TestEnv(options) {
  const { schemaPath } = options;

  // Create Miniflare instance with D1
  const mf = new Miniflare({
    modules: true,
    script: `export default { fetch() { return new Response("ok"); } }`,
    d1Databases: {
      DB: "test-db",
    },
  });

  // Get D1 database instance
  const db = await mf.getD1Database("DB");

  // Apply schema migration if provided
  if (schemaPath) {
    const schema = readFileSync(schemaPath, "utf-8");
    const cleanedSchema = schema
      .split("\n")
      .map((line) => {
        const commentIdx = line.indexOf("--");
        return commentIdx >= 0 ? line.slice(0, commentIdx) : line;
      })
      .join("\n");

    const statements = cleanedSchema
      .split(";")
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    for (const stmt of statements) {
      await db.prepare(stmt).run();
    }
  }

  // Expose D1 to globalThis for MoonBit
  globalThis.__MINIFLARE_D1__ = db;

  return {
    db,
    dispose: () => mf.dispose(),
  };
}
