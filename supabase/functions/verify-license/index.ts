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
      .select("serial_number, device_id, is_active")
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

    if (!license.is_active) {
      const { error: updateError } = await supabase
        .from("licenses")
        .update({ device_id, is_active: true })
        .eq("serial_number", serial_number);

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

      return new Response(
        JSON.stringify({ valid: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (license.device_id === device_id) {
      return new Response(
        JSON.stringify({ valid: true }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({
        valid: false,
        message: "Serial sudah dipakai device lain. Silakan beli lisensi baru.",
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
