import SpriteKit

/// BRAND NEW - Minimal working game scene
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    weak var gameManager: GameManager?
    private var player: SKSpriteNode!
    var isGameActive: Bool = false
    
    // Button states
    var leftButtonPressed: Bool = false
    var rightButtonPressed: Bool = false
    
    
    // Progressive wave system - FAST AND CHAOTIC
    private var isCountingDown = false
    private var countdownLabel: SKLabelNode?
    
    // Game state
    private var gameStartTime: TimeInterval = 0
    private var lastWaveTime: TimeInterval = 0
    private var wavesSpawned = 0
    
    // NEW: Skill-based progression tracking
    private var asteroidsRetired = 0  // How many finished their 3-bounce cycle
    private var asteroidsSpawned = 0  // Total spawned (for initial pattern)
    
    // Red flash overlay
    private var redFlashNode: SKSpriteNode?
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        // Deep space gradient background
        backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        
        // Create dynamic starfield with multiple layers
        createDynamicStarfield()
        
        // Setup camera for shake effects
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(cameraNode)
        camera = cameraNode
        
        // Physics
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        // Boundaries (invisible walls)
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction = 0
        physicsBody = border
        
        // Create player only if it doesn't exist
        if player == nil {
            setupPlayer()
        }
        
        // Setup screen edges for bouncing
        let edgeRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: edgeRect)
        physicsBody?.categoryBitMask = 4 // Edge category
        physicsBody?.collisionBitMask = 2 // Collides with asteroids
        physicsBody?.contactTestBitMask = 0
        physicsBody?.friction = 0
        physicsBody?.restitution = 0.8 // Bouncy edges
        
        print("✅ GameScene setup complete. Size: \(size)")
    }
    
    
    private func handleAsteroidBounce(_ asteroid: SKSpriteNode?) {
        guard let asteroid = asteroid else { return }
        guard let bounces = asteroid.userData?["bounces"] as? Int,
              let vx = asteroid.userData?["velocityX"] as? CGFloat,
              let vy = asteroid.userData?["velocityY"] as? CGFloat else { return }
        
        // Reflect velocity based on which edge was hit
        var newVX = vx
        var newVY = vy
        
        // Detect which edge and reflect
        if asteroid.position.x <= 0 || asteroid.position.x >= frame.width {
            newVX = -vx * 0.9 // Horizontal reflection with energy loss
        }
        if asteroid.position.y <= 0 || asteroid.position.y >= frame.height {
            newVY = -vy * 0.9 // Vertical reflection with energy loss
        }
        
        // Update velocity in userData
        asteroid.userData?["velocityX"] = newVX
        asteroid.userData?["velocityY"] = newVY
        
        let newBounces = bounces + 1
        asteroid.userData?["bounces"] = newBounces
        
        print("⚡ Bounced! New velocity: (\(newVX), \(newVY)), Count: \(newBounces)")
        
        // Mark as expired after 2 bounces
        if newBounces >= 2 {
            asteroid.userData?["expired"] = true
            print("⏳ Expired after 2 bounces")
        }
    }
    
    private func createDynamicStarfield() {
        // Layer 1: Far stars (small, slow)
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: 1.0)
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.zPosition = -100
            star.alpha = CGFloat.random(in: 0.3...0.6)
            
            // Twinkling effect
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1.0...2.0)),
                SKAction.fadeAlpha(to: 0.6, duration: Double.random(in: 1.0...2.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            
            addChild(star)
        }
        
        // Layer 2: Mid stars (medium, medium speed)
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: 1.5)
            star.fillColor = UIColor(white: 1.0, alpha: 0.9)
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.zPosition = -50
            star.alpha = CGFloat.random(in: 0.5...0.8)
            
            // Pulsing effect
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 0.8...1.5)),
                SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 0.8...1.5))
            ])
            star.run(SKAction.repeatForever(pulse))
            
            addChild(star)
        }
        
        // Layer 3: Close stars (large, brighter)
        for _ in 0..<20 {
            let star = SKShapeNode(circleOfRadius: 2.0)
            star.fillColor = .white
            star.strokeColor = UIColor(white: 1.0, alpha: 0.3)
            star.lineWidth = 1.0
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            star.zPosition = -20
            star.alpha = CGFloat.random(in: 0.7...1.0)
            
            // Bright twinkle
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: Double.random(in: 0.5...1.0)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.5...1.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            
            addChild(star)
        }
    }
    
    
    private func setupPlayer() {
        // Try to load spaceship sprite
        let shipTexture = SKTexture(imageNamed: "player_ship")
        
        if shipTexture.size().width > 0 {
            // Use pixel art spaceship
            player = SKSpriteNode(texture: shipTexture)
            player.size = CGSize(width: 50, height: 50)
            print("✅ Using pixel art spaceship")
        } else {
            // Fallback to yellow square
            player = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
            print("⚠️ Using yellow fallback")
        }
        
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.zPosition = 10
        player.name = "player"
        
        // MUCH SMALLER HITBOX for fairness (circle = tighter than rectangle)
        let hitboxRadius = min(player.size.width, player.size.height) * 0.35 // Only 35% of size!
        player.physicsBody = SKPhysicsBody(circleOfRadius: hitboxRadius)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = 1 // Player
        player.physicsBody?.contactTestBitMask = 2 // Detect asteroids
        player.physicsBody?.collisionBitMask = 4 // COLLIDE WITH EDGES to stay on screen!
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.3 // Slight bounce off edges
        player.physicsBody?.friction = 0.5
        
        addChild(player)
        print("✅ Player created at: \(player.position)")
    }
    
    // MARK: - Game Control
    func startGame() {
        isGameActive = true
        
        // Reset player position and state
        if player == nil {
            setupPlayer()
        }
        
        // AGGRESSIVE CLEANUP - Remove EVERYTHING!
        removeAllActions()
        
        // Remove ALL stars first (prevents multiplication!)
        children.forEach { node in
            if node is SKShapeNode && node.zPosition < 0 {
                node.removeFromParent()
            }
        }
        
        enumerateChildNodes(withName: "asteroid") { node, _ in
            node.removeAllActions()
            node.removeFromParent()
        }
        enumerateChildNodes(withName: "explosion") { node, _ in
            node.removeFromParent()
        }
        
        // Remove any lingering labels or overlays (but NOT the player!)
        children.forEach { node in
            if node is SKLabelNode && node != player {
                node.removeFromParent()
            }
        }
        
        // Recreate starfield fresh
        createDynamicStarfield()
        
        // Ensure player is in scene and visible
        if player.parent == nil {
            addChild(player)
        }
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.alpha = 1.0
        player.isHidden = false
        player.zPosition = 20
        player.zRotation = 0
        
        // CRITICAL: RECREATE physics body entirely!
        player.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
        player.physicsBody?.collisionBitMask = 4  // Collide with edges to stay on screen!
        player.physicsBody?.affectedByGravity = true  // MUST be true!
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.3
        player.physicsBody?.restitution = 0
        player.physicsBody?.velocity = CGVector.zero
        
        print("🚀 Player FULLY reset with new physics body!")
        
        // Re-setup physics
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction = 0
        physicsBody = border
        
        // Reset all game state BEFORE countdown
        isGameActive = false
        isCountingDown = false  // Important!
        leftButtonPressed = false
        rightButtonPressed = false
        gameStartTime = 0
        lastWaveTime = 0
        wavesSpawned = 0
        
        // Reset progression tracking
        asteroidsRetired = 0
        asteroidsSpawned = 0
        
        // Remove any old countdown label
        countdownLabel?.removeAllActions()
        countdownLabel?.removeFromParent()
        countdownLabel = nil
        
        print("🔄 Complete game reset! Starting countdown...")
        
        // Start countdown
        startCountdown()
    }
    
    private func startCountdown() {
        // SAFETY: Don't start if already counting down!
        guard !isCountingDown else {
            print("⚠️ Already counting down, ignoring duplicate call")
            return
        }
        
        // CRITICAL: Clean up any existing countdown!
        countdownLabel?.removeAllActions()
        countdownLabel?.removeFromParent()
        countdownLabel = nil
        
        isCountingDown = true
        
        // FREEZE PLAYER during countdown
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.velocity = CGVector.zero
        
        // Create countdown label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 72
        label.fontColor = .white
        label.zPosition = 100
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
        countdownLabel = label
        
        // Countdown sequence: 3, 2, 1, GO!
        let countdown = SKAction.sequence([
            SKAction.run {
                label.text = "3"
                label.setScale(0.5)
                label.run(SKAction.scale(to: 1.0, duration: 0.3))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                label.text = "2"
                label.setScale(0.5)
                label.run(SKAction.scale(to: 1.0, duration: 0.3))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                label.text = "1"
                label.setScale(0.5)
                label.run(SKAction.scale(to: 1.0, duration: 0.3))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                label.text = "GO!"
                label.fontColor = .green
                label.setScale(0.5)
                label.run(SKAction.scale(to: 1.2, duration: 0.2))
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                label.removeFromParent()
                self?.countdownLabel = nil
                self?.isCountingDown = false
                self?.isGameActive = true
                
                // RE-ENABLE GRAVITY after countdown
                self?.player.physicsBody?.affectedByGravity = true
                
                print("🎮 Countdown finished! Game started!")
            }
        ])
        
        // RUN ON LABEL instead of scene to avoid conflicts!
        label.run(countdown)
        print("🎮 Countdown started!")
    }
    
    func stopGame() {
        isGameActive = false
    }
    
    // MARK: - Button Controls
    func setLeftButton(pressed: Bool) {
        leftButtonPressed = pressed
    }
    
    func setRightButton(pressed: Bool) {
        rightButtonPressed = pressed
    }
    
    // MARK: - Controls
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        guard isGameActive else { return }
        
        switch event.keyCode {
        case 123: // Left arrow
            player.physicsBody?.applyImpulse(CGVector(dx: -50, dy: 0))
        case 124: // Right arrow
            player.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 0))
        case 126: // Up arrow
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        default:
            break
        }
    }
    #endif
    
    // MARK: - Asteroid Spawning (FIXED - Spawn INSIDE Screen!)
    private func spawnAsteroid() {
        let size: CGFloat = CGFloat([30, 40, 50].randomElement()!)
        
        // Use actual asteroid sprite
        let asteroidTexture = SKTexture(imageNamed: "asteroid")
        let asteroid: SKSpriteNode
        
        if asteroidTexture.size().width > 0 {
            asteroid = SKSpriteNode(texture: asteroidTexture)
            asteroid.size = CGSize(width: size, height: size)
        } else {
            asteroid = SKSpriteNode(color: .red, size: CGSize(width: size, height: size))
        }
        
        asteroid.zPosition = 10
        asteroid.name = "asteroid"
        
        // SPAWN AT ACTUAL EDGES (not middle!)
        let edge = Int.random(in: 0...3)
        switch edge {
        case 0: // Top edge
            asteroid.position = CGPoint(x: CGFloat.random(in: 60...frame.width-60), y: frame.height - 60)
        case 1: // Bottom edge
            asteroid.position = CGPoint(x: CGFloat.random(in: 60...frame.width-60), y: 60)
        case 2: // Left edge
            asteroid.position = CGPoint(x: 60, y: CGFloat.random(in: 60...frame.height-60))
        default: // Right edge
            asteroid.position = CGPoint(x: frame.width - 60, y: CGFloat.random(in: 60...frame.height-60))
        }
        
        // Physics
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.4)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = 2
        asteroid.physicsBody?.contactTestBitMask = 1 | 4
        asteroid.physicsBody?.collisionBitMask = 4
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.restitution = 0.7
        asteroid.physicsBody?.friction = 0
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.allowsRotation = true
        
        addChild(asteroid)
        
        // GENTLE impulse towards center (not too strong!)
        let centerX = frame.midX - asteroid.position.x
        let centerY = frame.midY - asteroid.position.y
        let distance = sqrt(centerX * centerX + centerY * centerY)
        
        let impulseStrength: CGFloat = 3.0  // Much gentler!
        let impulseX = (centerX / distance) * impulseStrength
        let impulseY = (centerY / distance) * impulseStrength
        
        asteroid.physicsBody?.applyImpulse(CGVector(dx: impulseX, dy: impulseY))
        
        print("✅ Spawned asteroid at \(asteroid.position)")
    }
    
    // Helper to make circular texture
    private func makeCircleTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let img = renderer.image { ctx in
            color.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        return SKTexture(image: img)
    }
    
    private func addAsteroidTrail(to asteroid: SKSpriteNode, duration: TimeInterval) {
        // Create trailing particle effect
        let createParticle = SKAction.run { [weak self, weak asteroid] in
            guard let self = self, let asteroid = asteroid, asteroid.parent != nil else { return }
            
            let particle = SKSpriteNode(color: .orange, size: CGSize(width: 4, height: 4))  // Bigger!
            particle.position = asteroid.position
            particle.zPosition = 5
            particle.alpha = 0.8  // More visible!
            
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            particle.run(SKAction.sequence([fade, remove]))
            
            self.addChild(particle)
        }
        
        let wait = SKAction.wait(forDuration: 0.05)
        let sequence = SKAction.sequence([createParticle, wait])
        let repeatAction = SKAction.repeat(sequence, count: Int(duration / 0.05))
        
        asteroid.run(repeatAction, withKey: "trail")
    }
    
    
    // MARK: - Wave-Based Asteroid Spawning    
    private func spawnAsteroidWave() {
        // Progressive difficulty - gets MUCH harder over time!
        let gameTime = lastWaveTime - gameStartTime
        let waveLevel = Int(gameTime / 10)  // Level up every 10 seconds
        
        // Start with 4-6, increase with level, cap at 15
        let minAsteroids = 4 + waveLevel
        let maxAsteroids = min(15, 6 + waveLevel * 2)
        let asteroidCount = Int.random(in: minAsteroids...maxAsteroids)
        
        print("🌊 Wave #\(wavesSpawned + 1): Spawning \(asteroidCount) asteroids (Level \(waveLevel))")
        
        for _ in 0..<asteroidCount {
            spawnAsteroid()
        }
        
        wavesSpawned += 1
    }

    
    // MARK: - Collision
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Track asteroid bounces off edges!
        if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 4) ||
           (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 2) {
            let asteroid = bodyA.categoryBitMask == 2 ? bodyA.node as? SKSpriteNode : bodyB.node as? SKSpriteNode
            
            if let asteroid = asteroid,
               let bounces = asteroid.userData?["bounces"] as? Int,
               let expired = asteroid.userData?["expired"] as? Bool {
                
                // If already expired, ignore further collisions
                if expired {
                    return
                }
                
                let newBounces = bounces + 1
                asteroid.userData?["bounces"] = newBounces
                
                print("🏐 Bounce #\(newBounces)")
                
                // After 3rd bounce, STOP colliding with edges (fly off!)
                if newBounces >= 3 {
                    asteroid.userData?["expired"] = true
                    asteroid.physicsBody?.collisionBitMask = 2  // Only collide with other asteroids now
                    print("⏭️ 3 bounces! Removing edge collision - will fly off screen.")
                }
            }
            return
        }
        
        // Player death
        guard isGameActive else { return }
        
        let collision = bodyA.categoryBitMask | bodyB.categoryBitMask
        if collision == 3 { // Player (1) + Asteroid (2)
            isGameActive = false
            // EXPLOSION
            let explosion = SKEmitterNode(fileNamed: "PlayerExplosion.sks") ?? SKEmitterNode()
            explosion.position = player.position
            addChild(explosion)
            
            // Calculate game stats
            let survivalTime = CFAbsoluteTimeGetCurrent() - gameStartTime
            let finalScore = gameManager?.score ?? 0
            
            // Update player stats
            var stats = PlayerStats.load()
            stats.recordGameEnd(
                score: finalScore,
                survivalTime: survivalTime,
                asteroidsRetired: asteroidsRetired,
                boostsUsed: 0  // Track this if you add boost counting
            )
            stats.save()
            print("📊 Stats updated: Score \(finalScore), Time \(survivalTime)s, Retired \(asteroidsRetired)")
            
            // Submit to Game Center
            let leaderboard = LeaderboardManager()
            leaderboard.submitScore(finalScore)
            
            // End game
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.gameManager?.currentState = .gameOver
            }
            print("💥 Game Over!")
        }
    }
    
    private func handleAsteroidCollision(_ asteroidA: SKSpriteNode?, _ asteroidB: SKSpriteNode?) {
        guard let a = asteroidA, let b = asteroidB else { return }
        
        print("💥 Asteroid-Asteroid collision!")
        
        // Simple bounce - reverse x velocity for both (stored in userData)
        if let vxA = a.userData?["velocityX"] as? CGFloat {
            a.userData?["velocityX"] = -vxA * 0.8
        }
        
        if let vxB = b.userData?["velocityX"] as? CGFloat {
            b.userData?["velocityX"] = -vxB * 0.8
        }
    }
    
    private func flashRedScreen() {
        // Create red overlay
        let flash = SKSpriteNode(color: .red, size: frame.size)
        flash.position = CGPoint(x: frame.midX, y: frame.midY)
        flash.zPosition = 200
        flash.alpha = 0
        addChild(flash)
        redFlashNode = flash
        
        // Flash sequence
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeIn, fadeOut, remove]))
    }
    
    private func spinOutPlayer() {
        guard let player = player else { return }
        
        // Disable physics
        player.physicsBody?.isDynamic = false
        
        // Spin and fly off screen
        let randomDirection = CGFloat.random(in: 0...1) > 0.5 ? 1.0 : -1.0
        let spin = SKAction.rotate(byAngle: CGFloat.pi * 4 * randomDirection, duration: 1.0)
        
        // Fly off in random direction
        let offScreenX = randomDirection > 0 ? frame.width + 100 : -100
        let offScreenY = CGFloat.random(in: -100...frame.height + 100)
        let flyOff = SKAction.move(to: CGPoint(x: offScreenX, y: offScreenY), duration: 1.0)
        
        let group = SKAction.group([spin, flyOff])
        player.run(group)
    }
    
    // MARK: - Effects
    private func createExplosion(at position: CGPoint) {
        // Create explosion particles
        for _ in 0..<20 {
            let particle = SKSpriteNode(color: .orange, size: CGSize(width: 4, height: 4))
            particle.position = position
            particle.zPosition = 15
            
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: -200...200)
            
            let move = SKAction.moveBy(x: randomX, y: randomY, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([SKAction.group([move, fade]), remove])
            
            particle.run(sequence)
            addChild(particle)
        }
    }
    
    private func createThrustParticle(dx: CGFloat, dy: CGFloat) {
        guard let player = player else { return }
        
        let particle = SKSpriteNode(color: .orange, size: CGSize(width: 3, height: 3))
        particle.position = player.position
        particle.zPosition = 5
        particle.alpha = 0.8
        
        let randomOffset = CGFloat.random(in: -5...5)
        let move = SKAction.moveBy(x: -dx * 0.5 + randomOffset, y: -dy * 0.5 + randomOffset, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([SKAction.group([move, fade]), remove])
        
        particle.run(sequence)
        addChild(particle)
    }
    
    private func shakeCamera() {
        // Shake the entire scene slightly for boost feedback
        let shakeAmount: CGFloat = 3
        let shake1 = SKAction.moveBy(x: shakeAmount, y: -shakeAmount, duration: 0.05)
        let shake2 = SKAction.moveBy(x: -shakeAmount * 2, y: shakeAmount * 2, duration: 0.05)
        let shake3 = SKAction.moveBy(x: shakeAmount, y: -shakeAmount, duration: 0.05)
        let sequence = SKAction.sequence([shake1, shake2, shake3])
        
        camera?.run(sequence)
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }
        
        // Initialize game start time
        if gameStartTime == 0 {
            gameStartTime = currentTime
            lastWaveTime = currentTime
        }
        
        let gameTime = currentTime - gameStartTime
        
        // SKILL-BASED SPEED: 15% increase every 5 retired asteroids!
        let speedLevel = asteroidsRetired / 5  // Integer division (0, 1, 2, 3...)
        let speedMultiplier = 1.0 + (Double(speedLevel) * 0.15)  // 1.0x, 1.15x, 1.3x...
        
        if speedLevel > 0 && Int(currentTime * 10).isMultiple(of: 50) {
            print("⚡ Speed Level: \(speedLevel), Multiplier: \(speedMultiplier)x")
        }
        
        // Apply thrust based on button states
        if leftButtonPressed && rightButtonPressed {
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: 60))
            if Int(currentTime * 60).isMultiple(of: 3) {
                createThrustParticle(dx: 0, dy: 50)
            }
            if Int(currentTime * 60).isMultiple(of: 10) {
                shakeCamera()
                SoundManager.shared.playThrust()
            }
        } else if leftButtonPressed {
            player.physicsBody?.applyForce(CGVector(dx: -35, dy: 0))
            if Int(currentTime * 60).isMultiple(of: 5) {
                createThrustParticle(dx: -30, dy: 0)
            }
        } else if rightButtonPressed {
            player.physicsBody?.applyForce(CGVector(dx: 35, dy: 0))
            if Int(currentTime * 60).isMultiple(of: 5) {
                createThrustParticle(dx: 30, dy: 0)
            }
        }
        
        // ALWAYS MAINTAIN 5 ASTEROIDS!
        var asteroidCount = 0
        enumerateChildNodes(withName: "asteroid") { _, _ in
            asteroidCount += 1
        }
        
        // IMPORTANT: For initial 5, spawn with DELAY!
        if asteroidsSpawned < 5 {
            // Only spawn if it's "time" for this asteroid
            let spawnDelay: TimeInterval = 2.0  // 2 seconds between each
            let expectedSpawnTime = gameStartTime + (Double(asteroidsSpawned) * spawnDelay)
            
            if currentTime >= expectedSpawnTime && asteroidCount < (asteroidsSpawned + 1) {
                spawnAsteroidWithSpeed(speedMultiplier)
                print("⏰ Delayed spawn #\(asteroidsSpawned + 1)")
            }
        } else {
            // After initial 5, spawn immediately to maintain 5
            while asteroidCount < 5 {
                spawnAsteroidWithSpeed(speedMultiplier)
                asteroidCount += 1
            }
        }
        
        // Track bounces and remove after 2
        enumerateChildNodes(withName: "asteroid") { node, _ in
            guard let asteroid = node as? SKSpriteNode else { return }
            
            // UNSTICK LOGIC: If asteroid is moving too slowly, push it!
            if let velocity = asteroid.physicsBody?.velocity {
                let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
                if speed < 50 {  // Too slow, probably stuck!
                    let pushX = self.frame.midX - asteroid.position.x
                    let pushY = self.frame.midY - asteroid.position.y
                    let pushDist = sqrt(pushX * pushX + pushY * pushY)
                    let pushForce: CGFloat = 200
                    asteroid.physicsBody?.applyImpulse(CGVector(
                        dx: (pushX / pushDist) * pushForce,
                        dy: (pushY / pushDist) * pushForce
                    ))
                    print("🔧 Unstuck asteroid at \(asteroid.position)")
                }
            }
            
            // Check if off-screen (means it left after 3 bounces - RETIRED!)
            let buffer: CGFloat = 100
            if asteroid.position.x < -buffer || asteroid.position.x > self.frame.width + buffer ||
               asteroid.position.y < -buffer || asteroid.position.y > self.frame.height + buffer {
                asteroid.removeFromParent()
                self.asteroidsRetired += 1  // Track retirement for speed increase!
                print("🪦 Asteroid retired! Total: \(self.asteroidsRetired), Speed level: \(self.asteroidsRetired / 5)")
            }
        }
        
        // Score = time survived
        gameManager?.score = Int(gameTime)
    }
}

extension GameScene {
    private func spawnAsteroidWithSpeed(_ speedMultiplier: Double) {
        let size: CGFloat = CGFloat([30, 40, 50].randomElement()!)
        
        let asteroidTexture = SKTexture(imageNamed: "asteroid")
        let asteroid: SKSpriteNode
        
        if asteroidTexture.size().width > 0 {
            asteroid = SKSpriteNode(texture: asteroidTexture)
            asteroid.size = CGSize(width: size, height: size)
        } else {
            asteroid = SKSpriteNode(color: .red, size: CGSize(width: size, height: size))
        }
        
        asteroid.zPosition = 10
        asteroid.name = "asteroid"
        
        // INITIAL PATTERN: First 5 asteroids from specific edges!
        let edge: Int
        if asteroidsSpawned < 5 {
            // Pattern: Top, Right, Left, Left, Right
            let initialPattern = [0, 3, 2, 2, 3]  // 0=top, 1=bottom, 2=left, 3=right
            edge = initialPattern[asteroidsSpawned]
            print("🎯 Initial spawn #\(asteroidsSpawned + 1) from edge: \(["top", "bottom", "left", "right"][edge])")
        } else {
            // After initial 5, spawn randomly from any edge
            edge = Int.random(in: 0...3)
        }
        
        asteroidsSpawned += 1  // Track total spawned
        
        // Spawn CLOSER to walls (30px from edges)
        switch edge {
        case 0: // Top edge
            asteroid.position = CGPoint(x: CGFloat.random(in: 60...frame.width-60), y: frame.height - 30)
        case 1: // Bottom edge
            asteroid.position = CGPoint(x: CGFloat.random(in: 60...frame.width-60), y: 30)
        case 2: // Left edge
            asteroid.position = CGPoint(x: 30, y: CGFloat.random(in: 60...frame.height-60))
        default: // Right edge
            asteroid.position = CGPoint(x: frame.width - 30, y: CGFloat.random(in: 60...frame.height-60))
        }
        
        // Physics with 2-bounce tracking
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.4)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = 2
        asteroid.physicsBody?.contactTestBitMask = 1 | 4  // Detect player + edges
        asteroid.physicsBody?.collisionBitMask = 2 | 4  // BOUNCE off asteroids + edges!
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.restitution = 0.7  // Bouncy
        asteroid.physicsBody?.friction = 0
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.allowsRotation = true
        asteroid.physicsBody?.fieldBitMask = 0  // NO gravity fields!
        asteroid.physicsBody?.mass = 1.0  // Consistent mass for all sizes
        
        // Track bounces
        asteroid.userData = NSMutableDictionary()
        asteroid.userData?["bounces"] = 0
        asteroid.userData?["expired"] = false  // Important!
        asteroid.userData?["spawnEdge"] = edge  // Remember where it came from
        
        // ROTATION: Make asteroids spin continuously!
        let rotationSpeed = Double.random(in: 2.0...4.0)
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotationSpeed)
        asteroid.run(SKAction.repeatForever(rotateAction))
        
        addChild(asteroid)
        
        // CONSISTENT SPEED: Same magnitude for all asteroids!
        let centerX = frame.midX - asteroid.position.x
        let centerY = frame.midY - asteroid.position.y
        let distance = sqrt(centerX * centerX + centerY * centerY)
        
        // Normalize direction, then apply SAME speed to all
        let dirX = centerX / distance
        let dirY = centerY / distance
        
        // USE VELOCITY DIRECTLY FOR GUARANTEED SPEED!
        let baseSpeed: CGFloat = 150.0  // Direct velocity (much faster than impulse!)
        let finalSpeed = baseSpeed * CGFloat(speedMultiplier)
        
        // Set velocity DIRECTLY instead of using impulse
        asteroid.physicsBody?.velocity = CGVector(dx: dirX * finalSpeed, dy: dirY * finalSpeed)
        
        print("🪨 Spawned asteroid #\(asteroidsSpawned), size: \(size), velocity: \(finalSpeed)")
    }
}
