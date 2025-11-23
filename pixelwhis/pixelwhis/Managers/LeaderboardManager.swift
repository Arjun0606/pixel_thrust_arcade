import Foundation
import GameKit

@Observable
class LeaderboardManager: NSObject {
    var isAuthenticated = false
    var localPlayer: GKLocalPlayer?
    var leaderboardEntries: [GKLeaderboard.Entry] = []
    var playerRank: Int?
    
    private let leaderboardID = "com.pixelthrust.highscore"  // Change to your actual ID
    
    override init() {
        super.init()
        authenticatePlayer()
    }
    
    // MARK: - Authentication
    func authenticatePlayer() {
        localPlayer = GKLocalPlayer.local
        
        guard let localPlayer = localPlayer else { return }
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // Present the Game Center login view
                // NOTE: In real app, present this from your root ViewController
                print("🎮 Game Center: Need to present sign-in")
                return
            }
            
            if let error = error {
                print("❌ Game Center authentication failed: \(error.localizedDescription)")
                self?.isAuthenticated = false
                return
            }
            
            // Successfully authenticated
            if localPlayer.isAuthenticated {
                print("✅ Game Center: Authenticated as \(localPlayer.displayName)")
                self?.isAuthenticated = true
                Task {
                    await self?.loadPlayerRank()
                }
            } else {
                print("⚠️ Game Center: Not authenticated")
                self?.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Submit Score
    func submitScore(_ score: Int) {
        guard isAuthenticated else {
            print("⚠️ Cannot submit score - not authenticated")
            return
        }
        
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardID]
                )
                print("✅ Score submitted: \(score)")
                
                // Reload rank after submission
                await loadPlayerRank()
            } catch {
                print("❌ Failed to submit score: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Load Player Rank
    func loadPlayerRank() async {
        guard isAuthenticated else { return }
        
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return }
            
            let (localPlayerEntry, topEntries) = try await leaderboard.loadEntries(
                for: [GKLocalPlayer.local],
                timeScope: .allTime
            )
            
            if let entry = localPlayerEntry {
                playerRank = entry.rank
                print("🏆 Player rank: \(entry.rank)")
            }
        } catch {
            print("❌ Failed to load rank: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Top Scores
    func loadTopScores(limit: Int = 100) async {
        guard isAuthenticated else { return }
        
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return }
            
            let (_, topEntries, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: limit)
            )
            
            leaderboardEntries = topEntries
            print("✅ Loaded \(topEntries.count) leaderboard entries")
        } catch {
            print("❌ Failed to load leaderboard: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Show Game Center UI
    func showGameCenterDashboard() {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with Game Center")
            return
        }
        
        let viewController = GKGameCenterViewController(state: .leaderboards)
        viewController.gameCenterDelegate = self
        
        // NOTE: In real app, present from your root ViewController
        print("🎮 Would show Game Center dashboard")
    }
}

// MARK: - Game Center Delegate
extension LeaderboardManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
