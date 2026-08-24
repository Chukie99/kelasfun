import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import nodemailer from "npm:nodemailer@6";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function generateSerialNumber(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const bytes = new Uint8Array(8);
  crypto.getRandomValues(bytes);
  let result = "KF-";
  for (let i = 0; i < 8; i++) {
    result += chars[bytes[i] % chars.length];
    if (i === 3) result += "-";
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

    const { email: rawEmail, device_id } = await req.json();
    const email = rawEmail?.trim().toLowerCase();

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
    const gmailUser = Deno.env.get("GMAIL_USER");
    const gmailAppPassword = Deno.env.get("GMAIL_APP_PASSWORD");
    const telegramBotToken = Deno.env.get("TELEGRAM_BOT_TOKEN");
    const telegramChatId = Deno.env.get("TELEGRAM_CHAT_ID");

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Rate limit sederhana: maks 5 permintaan per device per jam
    // (anon key ada di APK publik, tanpa ini endpoint bisa dipakai spam email)
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count: recentCount, error: rateErr } = await supabase
      .from("licenses")
      .select("*", { count: "exact", head: true })
      .eq("device_id", device_id)
      .gte("created_at", oneHourAgo);
    if (rateErr) {
      console.error("Rate limit check error:", rateErr);
    } else if ((recentCount ?? 0) >= 5) {
      return new Response(
        JSON.stringify({ success: false, error: "Terlalu banyak permintaan. Coba lagi dalam satu jam." }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ---- Pembelian: email HARUS terdaftar di allowed_emails ----
    const { data: allowedRow } = await supabase
      .from("allowed_emails")
      .select("email, is_used")
      .eq("email", email)
      .maybeSingle();

    if (!allowedRow) {
      return new Response(
        JSON.stringify({ success: false, error: "Email belum terdaftar sebagai pembeli" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (allowedRow.is_used) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Email ini sudah pernah menerbitkan serial number. Hubungi admin jika lisensi hilang.",
        }),
        {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    let serialNumber: string;
    let insertError: any;
    const MAX_RETRIES = 3;
    for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
      serialNumber = generateSerialNumber();
      const { error } = await supabase.from("licenses").insert({
        serial_number: serialNumber,
        email: email,
        device_id: device_id,
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

    if (insertError) {
      console.error("Database insert error:", insertError);
      if (insertError.code === "23505") {
        // Tabrakan unique: email/device sudah punya baris lisensi lain
        return new Response(
          JSON.stringify({
            success: false,
            error: "Email atau device ini sudah terdaftar dengan lisensi lain.",
          }),
          {
            status: 409,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
      return new Response(
        JSON.stringify({ error: "Failed to create license" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (gmailUser && gmailAppPassword) {
      const emailHtml = `
          <h2>Terima kasih telah membeli kelasFun!</h2>
          <p>Serial Number Anda:</p>
          <h1 style="font-size: 32px; letter-spacing: 4px; color: #2D3436;">${serialNumber}</h1>
          <p>Masukkan serial number ini di aplikasi untuk mengaktifkan lisensi.</p>
          <p><strong>Penting:</strong> Serial number ini hanya berlaku untuk 1 perangkat.</p>
        `;

      try {
        const transporter = nodemailer.createTransport({
          host: "smtp.gmail.com",
          port: 587,
          secure: false,
          requireTLS: true,
          auth: {
            user: gmailUser,
            pass: gmailAppPassword,
          },
        });

        await transporter.sendMail({
          from: gmailUser,
          to: email,
          subject: "Serial Number kelasFun Anda",
          html: emailHtml,
        });
      } catch (error) {
        console.error("Gagal kirim email SMTP:", error);
        // Hapus row yang barusan dibuat agar retry user tidak menumpuk
        // serial yatim (row dibuat sebelum pengiriman email).
        const { error: deleteErr } = await supabase
          .from("licenses")
          .delete()
          .eq("serial_number", serialNumber);
        if (deleteErr) {
          console.error("Gagal menghapus lisensi yatim:", deleteErr);
        }
        const message = error instanceof Error ? error.message : String(error);
        return new Response(
          JSON.stringify({ success: false, error: message }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    // Email sukses terkirim -> tandai email agar 1 email = 1 serial selamanya.
    // (Ditandai SETELAH kirim berhasil; jika kirim gagal, row lisensi sudah
    // dihapus dan email boleh dicoba lagi.)
    const { error: markErr } = await supabase
      .from("allowed_emails")
      .update({ is_used: true })
      .eq("email", email);
    if (markErr) {
      console.error("Gagal menandai allowed_emails.is_used:", markErr);
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
          message: "Serial number dikirim ke email Anda",
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


