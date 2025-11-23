import Foundation

class GeminiManager {
    static let shared = GeminiManager()
    
    // WARNING: In a real app, NEVER hardcode API keys. Use a proxy server or secure storage.
    // For this prototype, replace "YOUR_API_KEY" with your actual key.
    let apiKey = "AIzaSyD0g-C1VuHDXO0iPipIhMSWOkntBfc2oGg"
    let model = "gemini-1.5-flash"
    
    func generateResponse(for pet: Pet, userMessage: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return "Error: Invalid URL" }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the prompt based on Pet's personality/state
        let systemPrompt = """
        You are a \(pet.stage.rawValue) pixel art pet named \(pet.name).
        Your current stats are: Hunger: \(pet.hunger)%, Happiness: \(pet.happiness)%.
        Your state is: \(pet.state.rawValue).
        
        Personality: Cute, needy, but lovable. Speak in short, pixel-game style sentences.
        If you are hungry, complain about food. If you are happy, use emojis.
        If you are a 'runaway', you are sad and missing your owner.
        
        User says: "\(userMessage)"
        """
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemPrompt]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let content = candidates.first?["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {
            return text
        }
        
        return "..." // Fallback
    }
}
