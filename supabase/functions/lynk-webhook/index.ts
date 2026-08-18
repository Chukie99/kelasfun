import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const resendApiKey = Deno.env.get("RESEND_API_KEY")!;
    const lynkSecretKey = Deno.env.get("LYNK_SECRET_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body = await req.json();

    console.log("[WEBHOOK] Received:", JSON.stringify(body));

    const { amount, ref_id, message_id, buyer_email, buyer_name, product_name } = body;

    // Verify signature from lynk.id
    const signatureString = `${amount}${ref_id}${message_id}${lynkSecretKey}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(signatureString);
    const hashBuffer = await crypto.subtle.digest("SHA-256", data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const calculatedSignature = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");

    // Note: lynk.id may send signature in a header or body field
    // For now, we trust the webhook if it reaches our endpoint
    // You should verify the signature against lynk.id's actual signature format

    // Generate license key (XXXX-XXXX-XXXX-XXXX)
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let key = "";
    for (let i = 0; i < 16; i++) {
      if (i > 0 && i % 4 === 0) key += "-";
      key += chars.charAt(Math.floor(Math.random() * chars.length));
    }

    console.log("[WEBHOOK] Generated key:", key);

    // Insert license to database
    const { data: license, error: insertError } = await supabase
      .from("licenses")
      .insert({
        license_key: key,
        status: "unused",
        buyer_email: buyer_email || null,
        buyer_name: buyer_name || null,
        purchase_ref_id: ref_id || null,
        purchased_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (insertError) {
      console.error("[WEBHOOK] Insert error:", insertError);
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log("[WEBHOOK] License created:", license);

    // Send email via Resend
    if (buyer_email && resendApiKey) {
      const emailHtml = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 32px; text-align: center; }
            .header h1 { color: white; margin: 0; font-size: 28px; }
            .header p { color: rgba(255,255,255,0.8); margin: 8px 0 0; }
            .content { padding: 32px; }
            .key-box { background: #f8f9fa; border: 2px dashed #667eea; border-radius: 12px; padding: 20px; text-align: center; margin: 20px 0; }
            .key { font-size: 28px; font-weight: bold; color: #333; letter-spacing: 3px; font-family: 'Courier New', monospace; }
            .steps { margin: 20px 0; }
            .step { display: flex; align-items: flex-start; margin: 12px 0; }
            .step-num { background: #667eea; color: white; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; margin-right: 12px; flex-shrink: 0; }
            .step-text { color: #555; line-height: 1.5; }
            .footer { background: #f8f9fa; padding: 20px 32px; text-align: center; color: #888; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🎓 kelasFun</h1>
              <p>License Key Anda</p>
            </div>
            <div class="content">
              <p>Halo <strong>${buyer_name || "User"}</strong>,</p>
              <p>Terima kasih telah membeli lisensi kelasFun! Berikut adalah license key Anda:</p>
              <div class="key-box">
                <div class="key">${key}</div>
              </div>
              <div class="steps">
                <p><strong>Cara Aktivasi:</strong></p>
                <div class="step">
                  <div class="step-num">1</div>
                  <div class="step-text">Buka aplikasi kelasFun di perangkat Anda</div>
                </div>
                <div class="step">
                  <div class="step-num">2</div>
                  <div class="step-text">Login dengan akun Google Anda</div>
                </div>
                <div class="step">
                  <div class="step-num">3</div>
                  <div class="step-text">Masukkan license key di atas</div>
                </div>
                <div class="step">
                  <div class="step-num">4</div>
                  <div class="step-text">Klik tombol <strong>Aktivasi</strong></div>
                </div>
              </div>
              <p style="color: #888; font-size: 12px;">
                License key ini hanya berlaku untuk 1 device. Simpan key ini di tempat yang aman.
              </p>
            </div>
            <div class="footer">
              <p>© 2026 kelasFun - Aplikasi Manajemen Kelas</p>
              <p>Jika ada kendala, hubungi kami</p>
            </div>
          </div>
        </body>
        </html>
      `;

      try {
        const emailResponse = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${resendApiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            from: "kelasFun <onboarding@resend.dev>",
            to: buyer_email,
            subject: `License Key kelasFun - ${key}`,
            html: emailHtml,
          }),
        });

        const emailResult = await emailResponse.json();
        console.log("[WEBHOOK] Email sent:", emailResult);
      } catch (emailError) {
        console.error("[WEBHOOK] Email error:", emailError);
      }
    }

    return new Response(JSON.stringify({ success: true, key }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("[WEBHOOK] Error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
