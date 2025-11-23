import Foundation

extension GeminiManager {
    func interpretDNA(from description: String) async throws -> PetDNA {
        let prompt = """
        The user wants to create a unique digital pet/companion. They described it as:
        "\(description)"
        
        Parse this into structured DNA data. Return ONLY valid JSON with this exact structure:
        {
          "primaryTheme": "dragon/robot/plant/cosmic/etc",
          "colorPalette": ["hex1", "hex2", "hex3"],
          "personality": "playful/wise/mysterious/etc",
          "specialTraits": ["wings", "glowing eyes", etc],
          "suggestedName": "cute name based on description"
        }
        
        Be creative but consistent with the user's vision. Use vivid colors.
        """
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "topP": 0.95
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        // Parse JSON from Gemini response
        let cleanedText = text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        guard let dnaData = cleanedText.data(using: .utf8),
              let dnaJson = try? JSONSerialization.jsonObject(with: dnaData) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        
        let dna = PetDNA(description: description)
        dna.primaryTheme = dnaJson["primaryTheme"] as? String ?? "creature"
        dna.colorPalette = dnaJson["colorPalette"] as? [String] ?? ["#FF6B6B"]
        dna.personality = dnaJson["personality"] as? String ?? "friendly"
        dna.specialTraits = dnaJson["specialTraits"] as? [String] ?? []
        
        return dna
    }
}
