import Foundation

class PixelLabManager {
    static let shared = PixelLabManager()
    
    private let apiKey = "2bb9a190-295c-4af7-b69e-c02199081068"
    private let baseURL = "https://api.pixellab.ai/v2"
    
    func generateAsset(prompt: String) async throws -> String {
        let url = URL(string: "\(baseURL)/create-image-pixflux")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "description": prompt,
            "image_size": ["width": 128, "height": 128],
            "no_background": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 429 {
            throw URLError(.callIsActive) // Rate limit
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataDict = json["data"] as? [String: Any],
           let images = dataDict["images"] as? [[String: Any]],
           let firstImage = images.first,
           let imageUrl = firstImage["url"] as? String {
            return imageUrl
        }
        
        throw URLError(.cannotParseResponse)
    }
}
