import QtQuick
import "../AiModel.qml"

ApiStrategy {
    function getEndpoint(modelObj, apiKey) {
        return modelObj.endpoint + modelObj.model + ":generateContent?key=" + apiKey;
    }

    function getHeaders(apiKey) {
        return ["Content-Type: application/json"];
    }

    function getBody(messages, model, tools) {
        // Convert messages to Gemini format
        // Gemini expects { role: "user"|"model", parts: [{ text: "..." }] }
        let contents = messages.map(msg => {
            return {
                role: msg.role === "assistant" ? "model" : "user",
                parts: [{ text: msg.content }]
            };
        });
        
        // Add system instruction if present (Gemini 1.5 Pro/Flash supports it)
        // For now, let's just prepend it to the first message or use systemInstruction field if supported
        // But the simplest way is to prepend to history or use systemInstruction
        
        let body = {
            contents: contents,
            generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 2048
            }
        };

        return body;
    }
    
    function parseResponse(response) {
        try {
            if (!response || response.trim() === "") return "Error: Empty response from API";
            
            let json = JSON.parse(response);
            
            if (json.error) {
                return "API Error (" + json.error.code + "): " + json.error.message;
            }
            
            if (json.candidates && json.candidates.length > 0) {
                let content = json.candidates[0].content;
                if (content && content.parts && content.parts.length > 0) {
                    return content.parts[0].text;
                }
                // Handle case where content is present but parts are missing or blocked
                if (json.candidates[0].finishReason) {
                    return "Response finished with reason: " + json.candidates[0].finishReason;
                }
            }
            
            return "Error: Unexpected response format. Raw: " + response;
        } catch (e) {
            return "Error parsing response: " + e.message + ". Raw: " + response;
        }
    }
}
