import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var creatureDescription = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.95, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // Title
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .symbolEffect(.bounce, options: .repeat(3))
                        
                        Text("Describe Your Dream Companion")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Use your imagination - dragons, robots, cosmic beings, plants... anything!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Input Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Vision")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Examples: \"A mystical dragon with purple scales\" or \"A friendly plant robot\"")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $creatureDescription)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(.white.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.red)
                            .padding()
                            .background(.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Create Button
                    Button(action: createCreature) {
                        HStack(spacing: 12) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                                    .font(.title2)
                            }
                            Text(isGenerating ? "Creating Your Companion..." : "Bring Them to Life")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: isGenerating ? [.gray, .gray.opacity(0.8)] : [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(creatureDescription.count < 10 || isGenerating)
                    .opacity(creatureDescription.count < 10 ? 0.6 : 1.0)
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
    
    func createCreature() {
        guard !creatureDescription.isEmpty else { return }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                // Step 1: Interpret DNA via Gemini
                let dna = try await GeminiManager.shared.interpretDNA(from: creatureDescription)
                
                // Step 2: Create Pet with DNA
                let pet = Pet(name: "Pixel", dna: dna)
                
                // Step 3: Generate initial sprite (Pro users only)
                if StoreManager.shared.isPro {
                    let spriteURL = try await PixelLabManager.shared.generateDynamicSprite(for: pet, stage: .egg)
                    pet.currentSpriteURL = spriteURL
                }
                
                await MainActor.run {
                    modelContext.insert(pet)
                    isGenerating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong. Try simplifying your description."
                    isGenerating = false
                }
            }
        }
    }
}
