export default {
  async fetch(request, env) {
    try {
      const { GEMINI_API_KEY } = env;

      if (!GEMINI_API_KEY) {
        return new Response(
          JSON.stringify({ error: "ERROR: Falta GEMINI_API_KEY en el Worker" }), 
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }

      if (request.method !== "POST") {
        return new Response(
          JSON.stringify({ error: "Este endpoint solo acepta POST con JSON. Ejemplo: { \"prompt\": \"texto\" }" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
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

      // Llamada a Gemini 2.5 Flash - ¡LA MEJOR OPCIÓN!
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
      
      const geminiRes = await fetch(geminiUrl, {
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
            maxOutputTokens: 65536, // Aprovechar todo el límite
          }
        })
      });

      const data = await geminiRes.json();

      // Si Gemini devuelve error
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
};


