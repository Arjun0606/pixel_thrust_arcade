import SpriteKit

enum HazardType {
    case asteroid
    case ufo
}

class HazardNode: SKSpriteNode {
    
    let type: HazardType
    
    // UFO Chase Properties
    private var chaseStartTime: TimeInterval = 0
    private var isChasing: Bool = false
    private let chaseDuration: TimeInterval
    private let chaseSpeed: CGFloat = 50.0 // ~60% of player max speed (80)
    private let turnSmoothing: CGFloat = 0.05 // Poor turning (0-1, lower = slower turns)
    
    init(type: HazardType) {
        self.type = type
        
        // Random chase duration between 3-5 seconds
        self.chaseDuration = TimeInterval.random(in: 3.0...5.0)
        
        let texture: SKTexture
        let color: UIColor
        let size: CGSize
        
        switch type {
        case .asteroid:
            let t = SKTexture(imageNamed: "asteroid")
            if t.size().width == 0 {
                texture = SKTexture() // Empty
                color = .gray
            } else {
                texture = t
                color = .white
            }
            size = CGSize(width: 40, height: 40)
        case .ufo:
            let t = SKTexture(imageNamed: "ufo")
            if t.size().width == 0 {
                texture = SKTexture() // Empty
                color = .green
            } else {
                texture = t
                color = .white
            }
            size = CGSize(width: 40, height: 30)
        }
        
        super.init(texture: texture.size().width > 0 ? texture : nil, color: color, size: size)
        
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        var body: SKPhysicsBody
        
        if type == .asteroid {
            // Circle for Asteroid
            body = SKPhysicsBody(circleOfRadius: size.width / 2)
            body.restitution = 1.0 // Perfectly bouncy
            body.friction = 0.0
            body.linearDamping = 0.0
            body.angularDamping = 0.0
            body.mass = 1.0
            
            body.categoryBitMask = 4 // Hazard
            body.collisionBitMask = 2 | 4 // Wall | Other Hazards
            body.contactTestBitMask = 1 | 4 // Player | Other Hazards
        } else {
            // Oval/Rect for UFO
            body = SKPhysicsBody(rectangleOf: size)
            body.restitution = 0.2
            body.friction = 0.5
            body.mass = 0.5
            body.affectedByGravity = false // UFOs float
            
            body.categoryBitMask = 4 // Hazard
            body.collisionBitMask = 2 // Wall only (can pass through asteroids)
            body.contactTestBitMask = 1 | 4 // Player | Asteroids (for destruction)
        }
        
        physicsBody = body
    }
    
    func update(playerPos: CGPoint, currentTime: TimeInterval) {
        guard type == .ufo, let body = physicsBody else { return }
        
        // Start chase timer on first update
        if !isChasing {
            chaseStartTime = currentTime
            isChasing = true
        }
        
        // Check if chase duration expired
        let timeChasing = currentTime - chaseStartTime
        if timeChasing > chaseDuration {
            // Despawn UFO after chase ends
            removeFromParent()
            return
        }
        
        // UFO Tracking Logic with Poor Turning
        let dx = playerPos.x - position.x
        let dy = playerPos.y - position.y
        
        // Calculate target direction
        let distance = sqrt(dx*dx + dy*dy)
        if distance > 0 {
            let targetVelocity = CGVector(
                dx: (dx/distance) * chaseSpeed,
                dy: (dy/distance) * chaseSpeed
            )
            
            // Smooth interpolation towards target (creates poor turning)
            let currentVelocity = body.velocity
            body.velocity = CGVector(
                dx: currentVelocity.dx + (targetVelocity.dx - currentVelocity.dx) * turnSmoothing,
                dy: currentVelocity.dy + (targetVelocity.dy - currentVelocity.dy) * turnSmoothing
            )
        }
    }
    
    // Called when UFO collides with asteroid
    func destroyedByAsteroid() {
        // Explosion effect
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([SKAction.group([fadeOut, scaleUp]), remove]))
        
        SoundManager.shared.playExplosion()
    }
}
