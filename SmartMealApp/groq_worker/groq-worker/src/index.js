export default {
  async fetch(request, env) {
    try {
      const url = new URL(request.url);
      const pathname = url.pathname;
      const method = request.method;

      // Ruta GET /macros para obtener nutrientes (USDA)
      if (pathname === "/macros" && method === "GET") {
        return handleMacrosRequest(request, env);
      }

      // Ruta POST /gemini para generar menús (Gemini)
      if (pathname === "/gemini" && method === "POST") {
        return handleGeminiRequest(request, env);
      }

      // Ruta no encontrada
      return new Response(
        JSON.stringify({ error: "Ruta no encontrada. Usa GET /macros o POST /gemini" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );

    } catch (err) {
      return new Response(
        JSON.stringify({ error: "Worker Error: " + err.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }
};

async function handleMacrosRequest(request, env) {
  try {
    const { USDA_API_KEY } = env;

    if (!USDA_API_KEY) {
      return new Response(
        JSON.stringify({ error: "ERROR: Falta USDA_API_KEY en el Worker" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const url = new URL(request.url);
    const query = url.searchParams.get("query");

    if (!query) {
      return new Response(
        JSON.stringify({ error: "Parámetro 'query' requerido" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const usdaUrl = new URL("https://api.nal.usda.gov/fdc/v1/foods/search");
    usdaUrl.searchParams.set("query", query);
    usdaUrl.searchParams.set("pageSize", "1");
    usdaUrl.searchParams.set("api_key", USDA_API_KEY);

    const usdaRes = await fetch(usdaUrl.toString(), {
      method: "GET",
      headers: { "Accept": "application/json" }
    });

    const usdaData = await usdaRes.json();

    if (!usdaRes.ok) {
      return new Response(
        JSON.stringify({ error: "Error USDA", details: usdaData }),
        { status: usdaRes.status, headers: { "Content-Type": "application/json" } }
      );
    }

    const foods = usdaData.foods || [];
    if (foods.length === 0) {
      return new Response(
        JSON.stringify({ protein: 0, carbs: 0, fat: 0 }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    const nutrients = foods[0].foodNutrients || [];
    let protein = 0, carbs = 0, fat = 0;

    for (const n of nutrients) {
      const nutrientName = (n.nutrientName || "").toLowerCase();
      const unitName = (n.unitName || "").toLowerCase();
      const value = parseFloat(n.value) || 0;

      if (nutrientName.includes("protein") && unitName === "g") protein = value;
      if (nutrientName.includes("carbohydrate") && unitName === "g") carbs = value;
      if ((nutrientName.includes("lipid") || nutrientName.includes("fat")) && unitName === "g") fat = value;
    }

    return new Response(
      JSON.stringify({ protein, carbs, fat }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Macros Worker Error: " + err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
}

async function handleGeminiRequest(request, env) {
  try {
    const { GEMINI_API_KEY } = env;

    if (!GEMINI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "ERROR: Falta GEMINI_API_KEY en el Worker" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    let body;
    try {
      body = await request.json();
    } catch (err) {
      return new Response(
        JSON.stringify({ error: "El cuerpo de la petición no es JSON válido" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    if (!body.prompt) {
      return new Response(
        JSON.stringify({ error: "Debes enviar 'prompt' en el body" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Intenta primero con Gemini 2.5 Flash, fallback a 2.0 Flash si da 503
    const models = ['gemini-2.5-flash', 'gemini-2.0-flash'];
    let geminiRes;
    let data;
    let lastError;

    for (const model of models) {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`;
      
      geminiRes = await fetch(geminiUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { text: body.prompt }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 24000,
          }
        })
      });

      data = await geminiRes.json();

      // Si es 503 (overloaded) y no es el último modelo, prueba el siguiente
      if (geminiRes.status === 503 && model !== models[models.length - 1]) {
        lastError = data;
        console.log(`⚠️ ${model} sobrecargado, probando ${models[models.indexOf(model) + 1]}...`);
        await new Promise(r => setTimeout(r, 1000)); // Espera 1s entre intentos
        continue;
      }

      // Si no es 503 o es el último modelo, sale del loop
      break;
    }

    // Si ninguno funcionó
    if (!geminiRes.ok) {
      return new Response(
        JSON.stringify({
          error: data.error?.message || "Error desconocido de Gemini",
          details: data
        }),
        {
          status: geminiRes.status,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Extraer el texto de la respuesta de Gemini
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
    
    if (!text) {
      return new Response(
        JSON.stringify({ error: "Gemini no devolvió texto válido", raw: data }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // Devolver en formato compatible con el datasource
    return new Response(
      JSON.stringify({ content: text }),
      { 
        status: 200, 
        headers: { "Content-Type": "application/json" } 
      }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Worker Error: " + err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
}


