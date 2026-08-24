# Lynk Webhook Edge Function Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate buyer onboarding by creating a webhook endpoint that verifies Lynk.id payment signatures and inserts buyer emails into `allowed_emails`, plus normalize email input in the existing `generate-license` function.

**Architecture:** Two changes: (1) modify `generate-license/index.ts` to normalize email input via `trim().toLowerCase()`, and (2) create a new Edge Function `lynk-webhook/index.ts` that receives Lynk.id payment webhooks, verifies HMAC-SHA256 signatures, and upserts buyer emails. No database schema changes needed.

**Tech Stack:** Deno, TypeScript, Supabase Edge Functions (std@0.177.0), @supabase/supabase-js@2, Web Crypto API (SHA-256), Telegram Bot API.

## Global Constraints

- Deno runtime, std@0.177.0, @supabase/supabase-js@2 (same as existing functions).
- CORS headers: `Access-Control-Allow-Origin: *`, methods `POST, OPTIONS`.
- Database tables: `allowed_emails (email PK, is_used, created_at)`, `licenses (serial_number, email, device_id, is_active, created_at)`.
- Env vars: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (auto-available), `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` (existing), `LYNK_MERCHANT_KEY` (new).
- Signature formula: `SHA256_hex(String(grandTotal) + refId + message_id + merchantKey)` — no separators.
- Email normalization: `trim().toLowerCase()` applied at both webhook insert and generate-license lookup.

---

### Task 1: Normalize email input in generate-license

**Files:**
- Modify: `supabase/functions/generate-license/index.ts:44-46`

**Interfaces:**
- Consumes: Raw email from `req.json()`.
- Produces: Normalized email string used in all subsequent DB lookups and inserts.

- [ ] **Step 1: Read the current file to confirm line numbers**

Open `supabase/functions/generate-license/index.ts` and verify line 44 reads `const { email, device_id } = await req.json();`.

- [ ] **Step 2: Rename destructured variable and add normalization**

Replace line 44:

```typescript
// Before:
const { email, device_id } = await req.json();

// After:
const { email: rawEmail, device_id } = await req.json();
const email = rawEmail?.trim().toLowerCase();
```

- [ ] **Step 3: Verify downstream usage still works**

Confirm that `email` (now normalized) is used at:
- Line 46: `isValidEmail(email)` — validation check
- Line 108: `.eq("email", email)` — allowed_emails lookup
- Line 141: `email: email` — licenses insert
- Line 234: `.eq("email", email)` — allowed_emails is_used update

All these references use the variable `email` which is now the normalized version. No other changes needed.

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/generate-license/index.ts
git commit -m "fix: normalize email input in generate-license (trim+lowercase)"
```

---

### Task 2: Create lynk-webhook Edge Function scaffold

**Files:**
- Create: `supabase/functions/lynk-webhook/index.ts`

**Interfaces:**
- Consumes: Lynk.id webhook POST payload (JSON) + `X-Lynk-Signature` header.
- Produces: HTTP 200/401/405/500 responses; inserts into `allowed_emails` table.

- [ ] **Step 1: Create the directory**

```bash
mkdir -p supabase/functions/lynk-webhook
```

- [ ] **Step 2: Write the imports and CORS headers**

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-lynk-signature",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
```

- [ ] **Step 3: Write the handler skeleton with OPTIONS and method check**

```typescript
serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/lynk-webhook/index.ts
git commit -m "feat: scaffold lynk-webhook with CORS and method check"
```

---

### Task 3: Implement signature verification

**Files:**
- Modify: `supabase/functions/lynk-webhook/index.ts`

**Interfaces:**
- Consumes: Raw request body text, `X-Lynk-Signature` header, `LYNK_MERCHANT_KEY` env var.
- Produces: Passes verification or returns 401.

- [ ] **Step 1: Read raw body and signature header**

Add after the method check, inside the try block:

```typescript
    const rawBody = await req.text();
    const signature = req.headers.get("X-Lynk-Signature");
```

- [ ] **Step 2: Parse JSON and validate LYNK_MERCHANT_KEY**

```typescript
    const payload = JSON.parse(rawBody);

    const merchantKey = Deno.env.get("LYNK_MERCHANT_KEY");
    if (!merchantKey) {
      console.error("LYNK_MERCHANT_KEY env var not set");
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
```

- [ ] **Step 3: Compute and compare signature**

```typescript
    if (!signature) {
      return new Response(
        JSON.stringify({ error: "Missing signature" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const messageData = payload.data?.message_data;
    const grandTotal = messageData?.totals?.grandTotal;
    const refId = messageData?.refId;
    const messageId = payload.data?.message_id;

    const dataString = String(grandTotal) + refId + messageId + merchantKey;

    const encoder = new TextEncoder();
    const data = encoder.encode(dataString);
    const hashBuffer = await crypto.subtle.digest("SHA-256", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const computedSignature = hashArray
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    if (computedSignature !== signature) {
      console.error("Signature mismatch:", {
        computed: computedSignature,
        received: signature,
      });
      return new Response(
        JSON.stringify({ error: "Invalid signature" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/lynk-webhook/index.ts
git commit -m "feat: add signature verification to lynk-webhook"
```

---

### Task 4: Implement event filtering and email extraction

**Files:**
- Modify: `supabase/functions/lynk-webhook/index.ts`

**Interfaces:**
- Consumes: Verified payload object.
- Produces: Normalized email string or early return.

- [ ] **Step 1: Filter for payment.received + SUCCESS**

Add after signature verification:

```typescript
    const event = payload.event;
    const messageAction = payload.data?.message_action;

    if (event !== "payment.received" || messageAction !== "SUCCESS") {
      return new Response(
        JSON.stringify({ received: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
```

- [ ] **Step 2: Extract and normalize email**

```typescript
    const rawEmail = messageData?.customer?.email;
    const email = rawEmail?.trim().toLowerCase();

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      console.error("Invalid or missing email in webhook payload:", rawEmail);
      // Send Telegram warning but don't fail the webhook
      try {
        const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
        const chatId = Deno.env.get("TELEGRAM_CHAT_ID");
        if (botToken && chatId) {
          await fetch(
            `https://api.telegram.org/bot${botToken}/sendMessage`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                chat_id: chatId,
                text: `⚠️ Lynk webhook: invalid email received: "${rawEmail}"`,
              }),
            }
          );
        }
      } catch (telegramErr) {
        console.error("Telegram warning failed:", telegramErr);
      }
      return new Response(
        JSON.stringify({ received: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
```

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/lynk-webhook/index.ts
git commit -m "feat: add event filtering and email extraction to lynk-webhook"
```

---

### Task 5: Implement DB upsert and Telegram notification

**Files:**
- Modify: `supabase/functions/lynk-webhook/index.ts`

**Interfaces:**
- Consumes: Normalized email, Supabase client, Telegram env vars.
- Produces: Row in `allowed_emails` (if new), Telegram notification, 200 response.

- [ ] **Step 1: Create Supabase client**

Add after env var reads:

```typescript
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
```

- [ ] **Step 2: Upsert allowed_emails with ignoreDuplicates**

```typescript
    const { data: upserted, error: upsertError } = await supabase
      .from("allowed_emails")
      .upsert({ email }, { onConflict: "email", ignoreDuplicates: true })
      .select();

    if (upsertError) {
      console.error("Database upsert error:", upsertError);
      return new Response(
        JSON.stringify({ error: "Database error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
```

- [ ] **Step 3: Send Telegram notification for new emails only**

```typescript
    // upserted is non-empty only when a new row was inserted (ignoreDuplicates skips existing)
    if (upserted && upserted.length > 0) {
      try {
        const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
        const chatId = Deno.env.get("TELEGRAM_CHAT_ID");
        if (botToken && chatId) {
          const customerName = messageData?.customer?.name || "N/A";
          const grandTotal = messageData?.totals?.grandTotal || 0;
          const refId = messageData?.refId || "N/A";
          const timestamp = new Date().toLocaleString("id-ID", {
            timeZone: "Asia/Jakarta",
          });

          const telegramMessage =
            `🛒 *Pembeli Baru kelasFun*\n\n` +
            `📧 Email: ${email}\n` +
            `👤 Nama: ${customerName}\n` +
            `💰 Total: Rp${grandTotal.toLocaleString("id-ID")}\n` +
            `🔗 Ref: \`${refId}\`\n` +
            `🕐 Waktu: ${timestamp}`;

          const telegramResponse = await fetch(
            `https://api.telegram.org/bot${botToken}/sendMessage`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                chat_id: chatId,
                text: telegramMessage,
                parse_mode: "Markdown",
              }),
            }
          );

          if (!telegramResponse.ok) {
            console.error(
              "Telegram send failed:",
              await telegramResponse.text()
            );
          }
        }
      } catch (telegramErr) {
        console.error("Telegram notification error:", telegramErr);
      }
    }
```

- [ ] **Step 4: Return success response**

```typescript
    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
```

- [ ] **Step 5: Add top-level error handler**

Close the try block and add catch:

```typescript
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
```

- [ ] **Step 6: Commit**

```bash
git add supabase/functions/lynk-webhook/index.ts
git commit -m "feat: add DB upsert and Telegram notification to lynk-webhook"
```

---

### Task 6: Deploy and set secrets

**Files:**
- None (deployment only)

**Interfaces:**
- Consumes: Completed `lynk-webhook/index.ts`.
- Produces: Live endpoint at `https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook`.

- [ ] **Step 1: Deploy the new function**

```bash
supabase functions deploy lynk-webhook --no-verify-jwt
```

- [ ] **Step 2: Set the LYNK_MERCHANT_KEY secret**

```bash
supabase secrets set LYNK_MERCHANT_KEY=<merchant_key_from_lynk_dashboard>
```

- [ ] **Step 3: Verify the endpoint is reachable**

```bash
curl -X OPTIONS https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook
```

Expected: HTTP 200 with CORS headers.

- [ ] **Step 4: Test with invalid signature (should return 401)**

```bash
curl -X POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook \
  -H "Content-Type: application/json" \
  -H "X-Lynk-Signature: invalidsignature" \
  -d '{"event":"payment.received","data":{"message_action":"SUCCESS","message_data":{"customer":{"email":"test@example.com"},"totals":{"grandTotal":72000},"refId":"abc123"},"message_id":"msg001"}}'
```

Expected: HTTP 401.

- [ ] **Step 5: Commit (no-op, deployment artifacts only)**

No commit needed for this task.

---

### Task 7: End-to-end verification

**Files:**
- None (verification only)

**Interfaces:**
- Consumes: Live endpoint + valid merchant key.
- Produces: Confirmation that flow works end-to-end.

- [ ] **Step 1: Test with valid payload and correct signature**

Compute signature locally: `SHA256_hex("72000" + "abc123" + "msg001" + <merchant_key>)`, then:

```bash
curl -X POST https://cdgnqhdmsnrlzylgoecz.supabase.co/functions/v1/lynk-webhook \
  -H "Content-Type: application/json" \
  -H "X-Lynk-Signature: <computed_signature>" \
  -d '{"event":"payment.received","data":{"message_action":"SUCCESS","message_data":{"customer":{"email":"testbuyer@example.com","name":"Test Buyer"},"totals":{"grandTotal":72000},"refId":"abc123"},"message_id":"msg001"}}'
```

Expected: HTTP 200 `{"received": true}` + row in `allowed_emails` + Telegram notification.

- [ ] **Step 2: Test idempotency (send same payload twice)**

Send the exact same request again. Expected: HTTP 200, no new Telegram notification, still 1 row in `allowed_emails`.

- [ ] **Step 3: Test generate-license with normalized email**

Open the Flutter app, enter `TestBuyer@Example.com` (mixed case). Expected: serial number issued successfully (email matches the lowercase `testbuyer@example.com` in `allowed_emails`).

- [ ] **Step 4: Review final files**

Read both `generate-license/index.ts` and `lynk-webhook/index.ts` to confirm no syntax errors and all changes are integrated correctly.

- [ ] **Step 5: Commit (no-op, verification only)**

No commit needed for this task.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-24-lynk-webhook.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
