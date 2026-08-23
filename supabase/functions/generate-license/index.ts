import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function generateSerialNumber(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let result = "KF-";
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  result += "-";
  for (let i = 0; i < 4; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        {
          status: 405,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const { email, device_id } = await req.json();

    if (!email || !isValidEmail(email)) {
      return new Response(
        JSON.stringify({ error: "Invalid or missing email" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!device_id || device_id.trim() === "") {
      return new Response(
        JSON.stringify({ error: "Missing device_id" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

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
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const resendFromEmail = Deno.env.get("RESEND_FROM_EMAIL");
    const telegramBotToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
    const telegramChatId = Deno.env.get("TELEGRAM_CHAT_ID");

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const serialNumber = generateSerialNumber();

    const { error: insertError } = await supabase.from("licenses").insert({
      license_key: serialNumber,
      user_email: email,
      status: "unused",
    });

    if (insertError) {
      console.error("Database insert error:", insertError);
      return new Response(
        JSON.stringify({ error: "Failed to create license" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (resendApiKey && resendFromEmail) {
      try {
        const emailHtml = `
          <h2>Terima kasih telah membeli kelasFun!</h2>
          <p>Serial Number Anda:</p>
          <h1 style="font-size: 32px; letter-spacing: 4px; color: #2D3436;">${serialNumber}</h1>
          <p>Masukkan serial number ini di aplikasi untuk mengaktifkan lisensi.</p>
          <p><strong>Penting:</strong> Serial number ini hanya berlaku untuk 1 perangkat.</p>
        `;

        const emailResponse = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            Authorization: `Bearer ${resendApiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: resendFromEmail,
            to: email,
            subject: "Serial Number kelasFun Anda",
            html: emailHtml,
          }),
        });

        if (!emailResponse.ok) {
          console.error("Email send failed:", await emailResponse.text());
        }
      } catch (emailErr) {
        console.error("Email error:", emailErr);
      }
    }

    if (telegramBotToken && telegramChatId) {
      try {
        const timestamp = new Date().toLocaleString("id-ID", {
          timeZone: "Asia/Jakarta",
        });
        const telegramMessage =
          `🔔 *License Baru kelasFun*\n\n` +
          `📧 Email: ${email}\n` +
          `🔑 Serial: \`${serialNumber}\`\n` +
          `📱 Device: \`${device_id}\`\n` +
          `🕐 Waktu: ${timestamp}`;

        const telegramResponse = await fetch(
          `https://api.telegram.org/bot${telegramBotToken}/sendMessage`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              chat_id: telegramChatId,
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
      } catch (telegramErr) {
        console.error("Telegram error:", telegramErr);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        serial_number: serialNumber,
        message: "License created successfully",
      }),
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
