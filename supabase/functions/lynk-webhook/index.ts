import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-lynk-signature",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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

  try {
    const rawBody = await req.text();
    const signature = req.headers.get("X-Lynk-Signature");

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

    const rawEmail = messageData?.customer?.email;
    const email = rawEmail?.trim().toLowerCase();

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      console.error("Invalid or missing email in webhook payload:", rawEmail);
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

    if (upserted && upserted.length > 0) {
      try {
        const botToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
        const chatId = Deno.env.get("TELEGRAM_CHAT_ID");
        if (botToken && chatId) {
          const customerName = messageData?.customer?.name || "N/A";
          const totalAmount = messageData?.totals?.grandTotal || 0;
          const ref = messageData?.refId || "N/A";
          const timestamp = new Date().toLocaleString("id-ID", {
            timeZone: "Asia/Jakarta",
          });

          const telegramMessage =
            `🛒 *Pembeli Baru kelasFun*\n\n` +
            `📧 Email: ${email}\n` +
            `👤 Nama: ${customerName}\n` +
            `💰 Total: Rp${totalAmount.toLocaleString("id-ID")}\n` +
            `🔗 Ref: \`${ref}\`\n` +
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

    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
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