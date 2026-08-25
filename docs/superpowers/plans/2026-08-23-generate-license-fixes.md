# Generate-License Edge Function Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix three issues in the generate-license Edge Function: add missing device_id, add retry loop for serial collision, and validate environment variables.

**Architecture:** Modify the existing Edge Function in `supabase/functions/generate-license/index.ts`. Add environment variable validation at handler start, wrap generate+insert in retry loop, and include device_id in insert.

**Tech Stack:** Deno, TypeScript, Supabase Edge Functions, Supabase JS client.

## Global Constraints

- Environment variables: `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` must be set.
- Database table `licenses` has columns: `license_key`, `user_email`, `device_id`, `status`, `created_at`.
- Unique constraint on `license_key`.
- Retry limit: 3 attempts.
- Error code for unique violation: `'23505'`.

---

### Task 1: Add environment variable validation

**Files:**
- Modify: `supabase/functions/generate-license/index.ts:66-67`

**Interfaces:**
- Consumes: None (standalone fix)
- Produces: Early return with 500 error if env vars missing.

- [ ] **Step 1: Read current file to locate lines 66-67**

Read the file to see the exact lines with non-null assertions.

- [ ] **Step 2: Replace non-null assertions with validation**

Replace lines 66-67 with:

```typescript
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
if (!supabaseUrl || !supabaseServiceKey) {
  return new Response(
    JSON.stringify({ error: "Missing required environment variables" }),
    {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    }
  );
}
```

- [ ] **Step 3: Verify the change**

Check that the validation is placed after request validation and before Supabase client creation.

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/generate-license/index.ts
git commit -m "fix: validate environment variables in generate-license"
```

### Task 2: Add device_id to insert and retry loop

**Files:**
- Modify: `supabase/functions/generate-license/index.ts:75-81`

**Interfaces:**
- Consumes: `supabaseUrl`, `supabaseServiceKey` from Task 1.
- Produces: Updated insert logic with device_id and retry loop.

- [ ] **Step 1: Read current file to locate lines 75-81**

Identify the generate serial and insert block.

- [ ] **Step 2: Replace generate+insert block with retry loop**

Replace lines 75-81 with:

```typescript
let serialNumber: string;
let insertError: any;
const MAX_RETRIES = 3;
for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
  serialNumber = generateSerialNumber();
  const { error } = await supabase.from("licenses").insert({
    license_key: serialNumber,
    user_email: email,
    device_id: device_id,
    status: "unused",
  });
  if (!error) {
    insertError = null;
    break;
  }
  insertError = error;
  if (error.code !== "23505") {
    // Non-unique violation, break early
    break;
  }
}
```

- [ ] **Step 3: Ensure `serialNumber` is declared before loop**

Add `let serialNumber: string;` before the loop.

- [ ] **Step 4: Verify the change**

Check that `device_id` is included, loop runs up to 3 times, and breaks on non-unique error.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/generate-license/index.ts
git commit -m "fix: add device_id and retry loop for serial collision"
```

### Task 3: Verify fixes and test

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: Completed fixes from Tasks 1 and 2.
- Produces: Confirmation that fixes work.

- [ ] **Step 1: Review the final file**

Read the entire file to ensure no syntax errors and all changes are integrated.

- [ ] **Step 2: Test environment variable validation**

Temporarily remove `SUPABASE_URL` from environment (or mock) and call the function. Should return 500 with clear message.

- [ ] **Step 3: Test normal flow**

Call function with valid email and device_id. Should succeed and store device_id in database.

- [ ] **Step 4: Test retry loop**

Temporarily modify `generateSerialNumber` to always return the same value (simulate collision). Should retry and succeed on second attempt (if database has unique constraint).

- [ ] **Step 5: Commit final verification**

```bash
git add supabase/functions/generate-license/index.ts
git commit -m "fix: verify all three fixes in generate-license"
```

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-23-generate-license-fixes.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?