import WidgetKit
import SwiftUI
import AppIntents
import AppIntents
import SwiftData

struct PixelPetEntry: TimelineEntry {
    let date: Date
    let pet: Pet?
}

struct PixelPetProvider: TimelineProvider {
    // NOTE: In a real app, use a shared ModelContainer with App Groups.
    // For this MVP, we attempt to read from the default container, which might fail if not shared.
    // User must ensure App Groups are enabled and passed to modelContainer.
    
    @MainActor
    func placeholder(in context: Context) -> PixelPetEntry {
        PixelPetEntry(date: Date(), pet: Pet(name: "Preview"))
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (PixelPetEntry) -> ()) {
        let pet = fetchPet()
        let entry = PixelPetEntry(date: Date(), pet: pet)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<PixelPetEntry>) -> ()) {
        let pet = fetchPet()
        
        // Create a timeline that refreshes every 15 minutes to update stats
        var entries: [PixelPetEntry] = []
        let currentDate = Date()
        
        for offset in 0 ..< 4 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: offset * 15, to: currentDate)!
            // Note: We can't mutate the pet here effectively for the timeline without persistent updates.
            // So we just pass the current state. The 'PetManager.updateStats' should be called on app open or background task.
            // For the widget, we just show what we have.
            entries.append(PixelPetEntry(date: entryDate, pet: pet))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    @MainActor
    private func fetchPet() -> Pet? {
        // This is a hacky way to get the context in a Widget without full dependency injection setup
        // In production, use a shared ModelContainer initialization.
        try? ModelContext(PetManager.shared.container).fetch(FetchDescriptor<Pet>()).first
    }
}

struct PixelPetWidgetEntryView : View {
    var entry: PixelPetProvider.Entry

    var body: some View {
        VStack {
            if let pet = entry.pet {
                if pet.isRunaway {
                    VStack {
                        Image(systemName: "figure.run")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text("Come back!")
                            .font(.caption)
                            .bold()
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(pet.name)
                                .font(.headline)
                            Text("Hunger: \(pet.hunger)%")
                                .font(.caption2)
                                .foregroundStyle(pet.hunger < 30 ? .red : .primary)
                        }
                        Spacer()
                        Image(systemName: "globe") // Placeholder for Pixel Art
                            .font(.largeTitle)
                    }
                    
                    HStack {
                        Button(intent: FeedIntent()) {
                            Image(systemName: "fork.knife")
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        
                        Button(intent: CleanIntent()) {
                            Image(systemName: "soap")
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
            } else {
                Text("No Pet")
                Text("Open App")
                    .font(.caption)
            }
        }
        .containerBackground(for: .widget) {
            Color.black.opacity(0.8)
        }
    }
}

struct PixelPetWidget: Widget {
    let kind: String = "PixelPetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PixelPetProvider()) { entry in
            PixelPetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pixel Pet")
        .description("Your pixel companion.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
