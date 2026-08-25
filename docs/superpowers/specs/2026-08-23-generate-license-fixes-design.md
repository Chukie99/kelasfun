# Design Spec: Fixes for generate-license Edge Function

## Overview

Three issues found in code review of `supabase/functions/generate-license/index.ts` need to be fixed:
1. Missing `device_id` in database insert
2. No retry on serial number collision
3. Non-null assertion on environment variables without validation

## Fixes

### Fix 1: Add device_id to insert

The `licenses` table includes a `device_id` column (see `setup.sql`). The current insert omits it. Add `device_id: device_id` to the insert object.

### Fix 2: Retry loop for serial collision

If `generateSerialNumber()` produces a duplicate, the UNIQUE constraint rejects the insert. Add a retry loop (3 attempts) around the generate+insert cycle. On each attempt:
1. Generate serial number
2. Attempt insert
3. If insert succeeds, break
4. If insert fails with UNIQUE violation (error code `'23505'`), retry
5. If all attempts fail, return 500 with clear error message

### Fix 3: Validate environment variables

Replace non-null assertions (`!`) with validation at top of handler. If `SUPABASE_URL` or `SUPABASE_SERVICE_ROLE_KEY` are missing, return 500 with error message `"Missing required environment variables"`.

## Implementation Details

### Location
`supabase/functions/generate-license/index.ts`

### Changes
1. After request validation (lines 46-64), add env var validation:
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

2. Replace lines 66-67 with the above validation (remove `!` assertions).

3. Wrap lines 75-81 (generate serial + insert) in a retry loop:
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

4. After loop, check `insertError` as before.

### Error Handling
- If env vars missing: return 500 with `"Missing required environment variables"`
- If insert fails after retries: return 500 with `"Failed to create license"`
- If insert fails with non-unique error: return 500 with `"Failed to create license"`

## Testing

- Manually test with missing env vars (should return 500 with clear message)
- Test normal flow (should succeed)
- Test duplicate serial (should retry and succeed on next attempt)

## Verification

- Ensure `device_id` is stored in database
- Ensure retry loop works (can simulate by temporarily making `generateSerialNumber` deterministic)
- Ensure env var validation works (set missing vars and test)

## Commit

- Commit message: "fix: add device_id, retry loop, and env validation to generate-license"
- Files changed: `supabase/functions/generate-license/index.ts`