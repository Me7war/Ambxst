import QtQuick
import "../AiModel.qml"

ApiStrategy {
    function getEndpoint(modelObj, apiKey) {
        return modelObj.endpoint + "/chat/completions";
    }

    function getHeaders(apiKey) {
        return [
            "Content-Type: application/json",
            "Authorization: Bearer " + apiKey
        ];
    }

    function getBody(messages, model, tools) {
        return {
            model: model.model,
            messages: messages,
            temperature: 0.7
        };
    }
    
    function parseResponse(response) {
        try {
            let json = JSON.parse(response);
            if (json.choices && json.choices.length > 0) {
                return json.choices[0].message.content;
            }
            return "Error: No content";
        } catch (e) {
            return "Error parsing response";
        }
    }
}
