import AppIntents
import SwiftData
import WidgetKit

struct FeedIntent: AppIntent {
    static var title: LocalizedStringResource = "Feed Pet"
    
    func perform() async throws -> some IntentResult {
        // We need to access the shared model container
        // Since PetManager isn't fully set up for shared context in this MVP snippet,
        // we assume PetManager.shared has access or we create a context.
        
        let context = ModelContext(PetManager.shared.container)
        
        if let pet = try? context.fetch(FetchDescriptor<Pet>()).first,
           let wallet = try? context.fetch(FetchDescriptor<PlayerWallet>()).first {
            await MainActor.run {
                _ = PetManager.shared.feed(pet: pet, wallet: wallet)
            }
        }
        
        return .result()
    }
}

struct CleanIntent: AppIntent {
    static var title: LocalizedStringResource = "Clean Pet"
    
    func perform() async throws -> some IntentResult {
        let context = ModelContext(PetManager.shared.container)
        
        if let pet = try? context.fetch(FetchDescriptor<Pet>()).first,
           let wallet = try? context.fetch(FetchDescriptor<PlayerWallet>()).first {
            await MainActor.run {
                _ = PetManager.shared.clean(pet: pet, wallet: wallet)
            }
        }
        return .result()
    }
}
