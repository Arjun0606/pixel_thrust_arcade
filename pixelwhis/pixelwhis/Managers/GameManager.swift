import SwiftUI
import Combine

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

class GameManager: ObservableObject {
    @Published var currentState: GameState = .menu
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var lastScore: Int = 0
    
    // Game Settings
    @Published var isSoundEnabled: Bool = true
    @Published var isHapticsEnabled: Bool = true
    
    // Difficulty Management
    private var gameTime: TimeInterval = 0
    
    init() {
        self.highScore = UserDefaults.standard.integer(forKey: "HighScore")
    }
    
    func startGame() {
        score = 0
        gameTime = 0
        currentState = .playing
    }
    
    func gameOver(finalScore: Int) {
        lastScore = finalScore
        if finalScore > highScore {
            highScore = finalScore
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
        currentState = .gameOver
    }
    
    func pauseGame() {
        currentState = .paused
    }
    
    func resumeGame() {
        currentState = .playing
    }
    
    func resetGame() {
        score = 0
        gameTime = 0
        currentState = .playing
    }
    
    func returnToMenu() {
        currentState = .menu
    }
    
    // MARK: - Difficulty System
    
    func updateDifficulty(currentTime: TimeInterval) {
        gameTime = currentTime
    }
    
    /// Spawn interval decreases over time (faster spawning)
    /// Starts at 2.0s, decreases to 0.8s over 60 seconds
    func getSpawnInterval() -> TimeInterval {
        return max(0.8, 2.0 - (gameTime / 60.0) * 1.2)
    }
    
    /// Max hazards on screen increases over time
    /// Starts with 2-3, caps at 6-8
    func getMaxHazards() -> Int {
        return min(8, 2 + Int(gameTime / 10))
    }
    
    /// UFO spawn chance increases over time
    /// 20% early game → 40% late game
    func shouldSpawnUFO() -> Bool {
        let ufoChance = min(0.4, 0.2 + (gameTime / 120.0) * 0.2)
        return Double.random(in: 0...1) < ufoChance
    }
}
