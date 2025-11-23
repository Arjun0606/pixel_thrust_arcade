import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stats = PlayerStats.load()
    
    var body: some View {
        ZStack {
            // Retro space background
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.02, blue: 0.08), Color(red: 0.05, green: 0.0, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    PixelText("PLAYER STATS", size: 24, color: .cyan, glow: true)
                    
                    if let lastPlayed = stats.lastPlayedDate {
                        PixelText("Last Played: \(formatDate(lastPlayed))", size: 10, color: .white.opacity(0.7))
                    }
                }
                .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // High Score Card
                        StatCard(title: "HIGH SCORE", value: "\(stats.highestScore)", color: .yellow)
                        
                        // Deaths & Games
                        HStack(spacing: 12) {
                            StatCard(title: "TOTAL DEATHS", value: "\(stats.totalDeaths)", color: .red, compact: true)
                            StatCard(title: "GAMES PLAYED", value: "\(stats.totalGamesPlayed)", color: .blue, compact: true)
                        }
                        
                        // Time Stats
                        HStack(spacing: 12) {
                            StatCard(title: "PLAYTIME", value: stats.formattedTotalPlayTime, color: .purple, compact: true)
                            StatCard(title: "BEST RUN", value: stats.formattedBestSurvival, color: .green, compact: true)
                        }
                        
                        // Performance Stats
                        StatCard(title: "AVERAGE SCORE", value: String(format: "%.0f", stats.averageScore), color: .orange)
                        
                        HStack(spacing: 12) {
                            StatCard(title: "ASTEROIDS\nRETIRED", value: "\(stats.asteroidsDestroyed)", color: .cyan, compact: true)
                            StatCard(title: "BOOSTS\nUSED", value: "\(stats.totalBoosts)", color: .pink, compact: true)
                        }
                        
                        StatCard(title: "LONGEST STREAK", value: "\(stats.longestStreak)", color: .mint)
                        
                        // Achievements
                        VStack(alignment: .leading, spacing: 12) {
                            PixelText("ACHIEVEMENTS", size: 16, color: .yellow)
                                .padding(.horizontal)
                            
                            AchievementRow(
                                title: "Speed Demon I",
                                description: "Survive 25+ asteroids",
                                unlocked: stats.speedLevel5Reached
                            )
                            
                            AchievementRow(
                                title: "Speed Demon II",
                                description: "Survive 50+ asteroids",
                                unlocked: stats.speedLevel10Reached
                            )
                            
                            AchievementRow(
                                title: "Perfect 10",
                                description: "Retire 10+ without dying",
                                unlocked: stats.perfect10Game
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
                
                // Close Button
                Button(action: { dismiss() }) {
                    PixelText("BACK", size: 18, color: .white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    var compact: Bool = false
    
    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            PixelText(title, size: compact ? 10 : 12, color: .white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            PixelText(value, size: compact ? 20 : 28, color: color, glow: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 12 : 16)
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.6), lineWidth: 2)
        )
    }
}

// MARK: - Achievement Row
struct AchievementRow: View {
    let title: String
    let description: String
    let unlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: unlocked ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(unlocked ? .yellow : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                PixelText(title, size: 14, color: unlocked ? .white : .gray)
                PixelText(description, size: 10, color: .white.opacity(unlocked ? 0.7 : 0.4))
            }
            
            Spacer()
            
            if unlocked {
                PixelText("✓", size: 16, color: .green)
            }
        }
        .padding()
        .background(Color.white.opacity(unlocked ? 0.1 : 0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(unlocked ? Color.yellow.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
