
import Foundation

extension PixelLabManager {
    func generateDynamicSprite(for pet: Pet, stage: PetStage) async throws -> String {
        guard let dna = pet.dna else {
            throw NSError(domain: "PixelLab", code: -1, userInfo: [NSLocalizedDescriptionKey: "No DNA found"])
        }
        
        // Build dynamic prompt based on DNA
        let stageDescription = getStageDescription(stage)
        let traitsString = dna.specialTraits.joined(separator: ", ")
        let colors = dna.colorPalette.prefix(2).joined(separator: " and ")
        
        let prompt = """
        A pixel art \(dna.primaryTheme) in its \(stageDescription) stage. \
        Personality: \(dna.personality). \
        Colors: \(colors). \
        Special features: \(traitsString). \
        Style: cute, 32x32 pixel art, detailed, white background
        """
        
        // Check cache first
        if let cachedPrompt = dna.generationPrompts[stage.rawValue],
           cachedPrompt == prompt,
           let cachedURL = pet.currentSpriteURL {
            return cachedURL
        }
        
        // Generate new sprite
        let imageURL = try await generateAsset(prompt: prompt)
        
        // Cache the prompt
        dna.generationPrompts[stage.rawValue] = prompt
        pet.currentSpriteURL = imageURL
        
        return imageURL
    }
    
    private func getStageDescription(_ stage: PetStage) -> String {
        switch stage {
        case .egg: return "egg/seed form, mysterious and glowing"
        case .baby: return "newborn/hatchling, small and adorable"
        case .child: return "young/juvenile, playful and energetic"
        case .teen: return "adolescent, developing unique features"
        case .adult: return "fully grown, majestic and powerful"
        case .elder: return "ancient/wise, mystical aura"
        }
    }
}
