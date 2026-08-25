import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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

    const { serial_number, device_id } = await req.json();

    if (!serial_number || serial_number.trim() === "") {
      return new Response(
        JSON.stringify({ valid: false, message: "Serial number tidak valid" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!/^KF-[A-Z0-9]{4}-[A-Z0-9]{4}$/.test(serial_number)) {
      return new Response(
        JSON.stringify({ valid: false, message: "Serial number tidak valid" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!device_id || device_id.trim() === "") {
      return new Response(
        JSON.stringify({ valid: false, message: "Device ID tidak valid" }),
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
        JSON.stringify({ valid: false, message: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: license, error: queryError } = await supabase
      .from("licenses")
      .select("serial_number, email, device_id, device_id_2, is_active")
      .eq("serial_number", serial_number)
      .single();

    if (queryError || !license) {
      return new Response(
        JSON.stringify({ valid: false, message: "Serial number tidak valid" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ---- KILL SWITCH PEMBELIAN ----
    // Email pembeli HARUS masih terdaftar di allowed_emails.
    // Refund / pembelian dibatalkan -> admin hapus email di Table Editor
    // -> semua device pemilik serial ini ditolak saat aktivasi/revalidasi.
    const { data: allowed } = await supabase
      .from("allowed_emails")
      .select("email")
      .eq("email", license.email)
      .maybeSingle();

    if (!allowed) {
      return new Response(
        JSON.stringify({
          valid: false,
          message:
            "Lisensi tidak lagi aktif. Hubungi admin/customer service.",
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ---- AKTIVASI PERTAMA (slot 1) ----
    if (!license.is_active) {
      // Update atomik dengan guard is_active=false agar dua device yang
      // memverifikasi serial yang sama bersamaan tidak keduanya lolos.
      const { data: updatedRows, error: updateError } = await supabase
        .from("licenses")
        .update({ device_id, is_active: true })
        .eq("serial_number", serial_number)
        .eq("is_active", false)
        .select();

      if (updateError) {
        console.error("Update error:", updateError);
        return new Response(
          JSON.stringify({ valid: false, message: "Gagal mengaktifkan lisensi" }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      if (!updatedRows || updatedRows.length === 0) {
        // Serial baru saja diaktifkan device lain di antara baca & update;
        // jatuh ke pengecekan slot di bawah.
      } else {
        return new Response(
          JSON.stringify({ valid: true }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    // ---- SUDAH AKTIF: cek apakah device ini salah satu slot yang sah ----
    if (license.device_id === device_id || license.device_id_2 === device_id) {
      return new Response(
        JSON.stringify({ valid: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ---- SLOT 1 KOSONG (kasus langka) -> klaim atomik ----
    if (!license.device_id) {
      const { data: s1 } = await supabase
        .from("licenses")
        .update({ device_id })
        .eq("serial_number", serial_number)
        .is("device_id", null)
        .select();
      if (s1 && s1.length > 0) {
        return new Response(JSON.stringify({ valid: true }), {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // ---- SLOT 2 KOSONG -> klaim atomik (bundle: device kedua, mis. HP) ----
    if (!license.device_id_2) {
      const { data: s2, error: s2err } = await supabase
        .from("licenses")
        .update({ device_id_2: device_id })
        .eq("serial_number", serial_number)
        .is("device_id_2", null)
        .neq("device_id", device_id)
        .select();

      if (s2err) {
        console.error("Claim slot2 error:", s2err);
        return new Response(
          JSON.stringify({ valid: false, message: "Gagal mengaktifkan lisensi" }),
          {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
      if (s2 && s2.length > 0) {
        return new Response(JSON.stringify({ valid: true }), {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    // Kedua slot terisi oleh device lain.
    return new Response(
      JSON.stringify({
        valid: false,
        message:
          "Serial sudah dipakai di 2 perangkat (Android + Windows). Hubungi admin jika ingin reset device.",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ valid: false, message: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
