import Foundation

struct PlayerStats: Codable {
    // MARK: - Core Stats
    var highestScore: Int = 0
    var totalGamesPlayed: Int = 0
    var totalDeaths: Int = 0
    
    // MARK: - Time Stats
    var totalPlayTime: TimeInterval = 0  // Total seconds played
    var bestSurvivalTime: TimeInterval = 0  // Longest single game
    var lastPlayedDate: Date?
    
    // MARK: - Performance Stats
    var averageScore: Double = 0
    var asteroidsDestroyed: Int = 0  // Just retirements count
    var totalBoosts: Int = 0
    var longestStreak: Int = 0  // Most asteroids dodged without dying
    
    // MARK: - Achievements
    var speedLevel5Reached: Bool = false  // Survived to 25+ retired asteroids
    var speedLevel10Reached: Bool = false  // Survived to 50+ retired asteroids
    var perfect10Game: Bool = false  // 10 asteroids retired without dying
    
    // MARK: - Computed Properties
    var averagePlayTime: TimeInterval {
        guard totalGamesPlayed > 0 else { return 0 }
        return totalPlayTime / Double(totalGamesPlayed)
    }
    
    var survivalRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return (Double(totalGamesPlayed) / Double(totalDeaths)) * 100
    }
    
    var formattedTotalPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = (Int(totalPlayTime) % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    var formattedBestSurvival: String {
        let minutes = Int(bestSurvivalTime) / 60
        let seconds = Int(bestSurvivalTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Update Methods
    mutating func recordGameEnd(score: Int, survivalTime: TimeInterval, asteroidsRetired: Int, boostsUsed: Int) {
        // Update counts
        totalGamesPlayed += 1
        totalDeaths += 1
        totalPlayTime += survivalTime
        asteroidsDestroyed += asteroidsRetired
        totalBoosts += boostsUsed
        lastPlayedDate = Date()
        
        // Update records
        if score > highestScore {
            highestScore = score
        }
        
        if survivalTime > bestSurvivalTime {
            bestSurvivalTime = survivalTime
        }
        
        if asteroidsRetired > longestStreak {
            longestStreak = asteroidsRetired
        }
        
        // Update average
        averageScore = (averageScore * Double(totalGamesPlayed - 1) + Double(score)) / Double(totalGamesPlayed)
        
        // Check achievements
        if asteroidsRetired >= 25 {
            speedLevel5Reached = true
        }
        if asteroidsRetired >= 50 {
            speedLevel10Reached = true
        }
        if asteroidsRetired >= 10 {
            perfect10Game = true
        }
    }
    
    // MARK: - Persistence Keys
    static let saveKey = "pixelthrust_player_stats"
    
    static func load() -> PlayerStats {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let stats = try? JSONDecoder().decode(PlayerStats.self, from: data) else {
            return PlayerStats()
        }
        return stats
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: PlayerStats.saveKey)
        }
    }
}
