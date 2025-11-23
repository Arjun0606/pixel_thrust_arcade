import SwiftUI
import SpriteKit

/// BRAND NEW - Minimal working game view
struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var scene: GameScene?
    
    var body: some View {
        ZStack {
            // MAIN MENU
            if gameManager.currentState == .menu {
                MainMenuView(
                    onStartGame: {
                        gameManager.startGame()
                        scene?.startGame()
                    },
                    highScore: gameManager.highScore
                )
                .transition(.opacity.combined(with: .scale))
            }
            
            // PAUSE MENU (overlay on game)
            if gameManager.currentState == .paused {
                // Show game in background (frozen)
                gamePlayView
                    .blur(radius: 5)
                
                PauseMenuView(
                    onResume: {
                        gameManager.resumeGame()
                    },
                    onRestart: {
                        gameManager.resetGame()
                        scene?.startGame()
                    },
                    score: gameManager.score
                )
                .transition(.opacity.combined(with: .scale))
            }
            
            // GAME OVER SCREEN
            else if gameManager.currentState == .gameOver {
                // Show game in background
                gamePlayView
                    .blur(radius: 8)
                
                ZStack {
                    // Dark overlay
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // Title
                        PixelText("GAME OVER", size: 32, color: .warningRed, glow: true)
                            .padding(.top, 60)
                        
                        // Score display
                        
                        VStack(spacing: 12) {
                            PixelText("FINAL SCORE", size: 14, color: .starWhite)
                            PixelText("\(gameManager.score)", size: 48, color: .scoreGreen, glow: true)
                        }
                        .padding(.vertical, 20)
                        
                        // High score
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.pauseYellow)
                            PixelText("HIGH: \(gameManager.highScore)", size: 16, color: .pauseYellow)
                        }
                        .padding(.bottom, 40)
                        
                        // Buttons
                        VStack(spacing: 16) {
                            RetroButton("▶ PLAY AGAIN", color: .electricCyan) {
                                withAnimation {
                                    gameManager.resetGame()
                                    scene?.startGame()
                                }
                            }
                            
                            RetroButton("⌂ MAIN MENU", color: .neonMagenta) {
                                withAnimation {
                                    gameManager.currentState = .menu
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 320)
                    .padding(30)
                }
                .transition(.opacity.combined(with: .scale))
            }
            
            // PLAYING GAME
            else if gameManager.currentState == .playing {
                gamePlayView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.currentState)
        .scanlineEffect() // CRT effect overlay
        .onAppear {
            setupScene()
        }
    }
    
    // MARK: - Game Play View (extracted for reuse)
    private var gamePlayView: some View {
        ZStack {
            // Space background
            LinearGradient(
                colors: [Color.deepSpace, Color.spaceBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // HUD - Top bar
                HStack {
                    PixelText("HI: \(gameManager.highScore)", size: 14, color: .starWhite)
                    Spacer()
                    PixelText("SCORE: \(gameManager.score)", size: 16, color: .scoreGreen, glow: true)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            gameManager.pauseGame()
                        }
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.pauseYellow)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // GAME VIEWPORT with pixel border
                if let scene = scene {
                    SpriteView(scene: scene, options: [.allowsTransparency, .ignoresSiblingOrder])
                        .frame(width: 350, height: 500)
                        .background(Color.black)
                        .pixelBorder(color: .electricCyan, width: 4)
                        .shadow(color: .electricCyan.opacity(0.3), radius: 12, x: 0, y: 0)
                        .onAppear {
                            // Force scene to not cull nodes
                            scene.view?.allowsTransparency = false
                            scene.view?.ignoresSiblingOrder = false
                            scene.view?.shouldCullNonVisibleNodes = false
                            print("🎬 SpriteView configured")
                        }
                }
                
                Spacer()
                
                // CONTROL BUTTONS
                HStack(spacing: 20) {  // Closer together for thumb reach!
                    // LEFT BUTTON
                    if let scene = scene {
                        PixelButton(
                            image: "left_button",
                            tintColor: (scene.leftButtonPressed && scene.rightButtonPressed) ? .red : .white
                        ) {
                            scene.setLeftButton(pressed: true)
                        } onRelease: {
                            scene.setLeftButton(pressed: false)
                        }
                        .frame(width: 245, height: 203)  // 75% bigger!
                    }
                    
                    // RIGHT BUTTON
                    if let scene = scene {
                        PixelButton(
                            image: "left_button",
                            isFlipped: true,
                            tintColor: (scene.leftButtonPressed && scene.rightButtonPressed) ? .red : .white
                        ) {
                            scene.setRightButton(pressed: true)
                        } onRelease: {
                            scene.setRightButton(pressed: false)
                        }
                        .frame(width: 245, height: 203)  // 75% bigger!
                    }
                }
                .padding(.bottom, 40)
                
                // BOOST INSTRUCTION
                Text("Hold both to BOOST ↑")
                    .font(.custom("PixelFont", size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 30)
            }
        }
    }
    
    private func setupScene() {
        let newScene = GameScene()
        newScene.size = CGSize(width: 350, height: 500)
        newScene.scaleMode = .fill // Changed from .aspectFill for exact mapping
        newScene.gameManager = gameManager
        self.scene = newScene
        print("✅ Scene created: \(newScene.size)")
    }
}
