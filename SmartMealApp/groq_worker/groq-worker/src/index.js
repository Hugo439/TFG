export default {
  async fetch(request, env) {
    try {
      const { GROQ_API_KEY } = env;

      if (!GROQ_API_KEY) {
        return new Response("ERROR: Falta GROQ_API_KEY en las variables del Worker", { status: 500 });
      }

      if (request.method !== "POST") {
        return new Response(
          "Este endpoint solo acepta POST con JSON. Ejemplo: { \"prompt\": \"texto\" }",
          { status: 400 }
        );
      }

      let body;
      try {
        body = await request.json();
      } catch (err) {
        return new Response("ERROR: El cuerpo de la petición no es JSON válido", { status: 400 });
      }

      // Adaptar para aceptar tanto 'prompt' como 'messages'
      let messages;
      if (body.messages) {
        messages = body.messages;
      } else if (body.prompt) {
        messages = [
          { role: "system", content: "Eres un nutricionista profesional que crea recetas saludables. Siempre respondes con JSON válido." },
          { role: "user", content: body.prompt }
        ];
      } else {
        return new Response("ERROR: Debes enviar 'prompt' o 'messages' en el cuerpo", { status: 400 });
      }

      const groqRes = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${GROQ_API_KEY}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          model: "llama-3.3-70b-versatile",
          messages: messages
        })
      });

      const data = await groqRes.json();

      return new Response(JSON.stringify(data), {
        status: 200,
        headers: { "Content-Type": "application/json" }
      });

    } catch (err) {
      return new Response("Worker Error: " + err.message, { status: 500 });
    }
  }
};

