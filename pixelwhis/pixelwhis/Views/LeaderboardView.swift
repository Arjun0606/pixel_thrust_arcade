import SwiftUI
import GameKit

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var leaderboardManager = LeaderboardManager()
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Retro space background
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.02, blue: 0.08), Color(red: 0.05, green: 0.0, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    PixelText("LEADERBOARD", size: 24, color: .yellow, glow: true)
                    
                    if let rank = leaderboardManager.playerRank {
                        PixelText("YOUR RANK: #\(rank)", size: 12, color: .cyan)
                    }
                }
                .padding(.top, 40)
                
                if !leaderboardManager.isAuthenticated {
                    // Not signed in
                    VStack(spacing: 16) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        PixelText("Sign in to Game Center", size: 14, color: .white.opacity(0.7))
                        PixelText("to view leaderboards", size: 12, color: .white.opacity(0.5))
                    }
                    .frame(maxHeight: .infinity)
                    
                } else if isLoading {
                    // Loading
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.cyan)
                        .frame(maxHeight: .infinity)
                    
                } else if leaderboardManager.leaderboardEntries.isEmpty {
                    // No scores yet
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.5))
                        
                        PixelText("No scores yet!", size: 14, color: .white.opacity(0.7))
                        PixelText("Be the first to play", size: 12, color: .white.opacity(0.5))
                    }
                    .frame(maxHeight: .infinity)
                    
                } else {
                    // Leaderboard list
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(leaderboardManager.leaderboardEntries.enumerated()), id: \.element.player.gamePlayerID) { index, entry in
                                LeaderboardRow(
                                    rank: entry.rank,
                                    playerName: entry.player.displayName,
                                    score: entry.score,
                                    isCurrentPlayer: entry.player.gamePlayerID == GKLocalPlayer.local.gamePlayerID
                                )
                            }
                        }
                        .padding()
                    }
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
        .task {
            if leaderboardManager.isAuthenticated {
                await leaderboardManager.loadTopScores(limit: 100)
                isLoading = false
            } else {
                isLoading = false
            }
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let playerName: String
    let score: Int
    let isCurrentPlayer: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.custom("PixelFont", size: 18))
                .foregroundColor(rankColor)
                .frame(width: 40, alignment: .trailing)
            
            // Trophy for top 3
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .foregroundColor(rankColor)
            }
            
            // Player name
            Text(playerName)
                .font(.custom("PixelFont", size: 14))
                .foregroundColor(isCurrentPlayer ? .cyan : .white)
                .lineLimit(1)
            
            Spacer()
            
            // Score
            Text("\(score)")
                .font(.custom("PixelFont", size: 16))
                .foregroundColor(isCurrentPlayer ? .yellow : .white.opacity(0.9))
        }
        .padding()
        .background(isCurrentPlayer ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isCurrentPlayer ? Color.cyan.opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: isCurrentPlayer ? 2 : 1
                )
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .white.opacity(0.6)
        }
    }
}
