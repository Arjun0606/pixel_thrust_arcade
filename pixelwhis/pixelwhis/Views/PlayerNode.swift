import SpriteKit

class PlayerNode: SKSpriteNode {
    
    // Thruster States
    var isThrustingLeft: Bool = false
    var isThrustingRight: Bool = false
    var isThrustingUp: Bool = false
    
    // Physics Constants
    let sideThrustForce: CGFloat = 40.0 // Horizontal push
    let upThrustForce: CGFloat = 80.0   // Vertical push
    let maxVelocity: CGFloat = 400.0    // Speed limit
    let rotationSpeed: CGFloat = 0.1    // Tilt speed
    
    init() {
        // Try to load player_ship texture
        let texture = SKTexture(imageNamed: "player_ship")
        
        // Make player LARGE and BRIGHT for visibility
        if texture.size().width > 0 && texture.size().height > 0 {
            super.init(texture: texture, color: .white, size: CGSize(width: 80, height: 80))
            print("✅ Player: Using player_ship texture (80x80)")
        } else {
            // BRIGHT YELLOW fallback - impossible to miss
            super.init(texture: nil, color: .yellow, size: CGSize(width: 80, height: 80))
            print("⚠️ Player: Using YELLOW fallback (80x80)")
        }
        
        setupPhysics()
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        // Triangle Physics Body
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 20))
        path.addLine(to: CGPoint(x: 20, y: -20))
        path.addLine(to: CGPoint(x: -20, y: -20))
        path.closeSubpath()
        
        physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody?.mass = 0.5
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.4 // Bouncy
        physicsBody?.linearDamping = 0.5 // Air resistance (drag)
        physicsBody?.angularDamping = 2.0 // Stabilize rotation
        
        physicsBody?.categoryBitMask = 1 // Player
        physicsBody?.collisionBitMask = 2 // Wall
        physicsBody?.contactTestBitMask = 2 | 4 // Wall | Hazard
        
        // Lock rotation slightly so we don't spin out of control
        physicsBody?.allowsRotation = true
    }
    
    private var leftThruster: SKEmitterNode?
    private var rightThruster: SKEmitterNode?
    private var mainThruster: SKEmitterNode?
    
    private func setupVisuals() {
        // Cockpit
        let cockpit = SKShapeNode(circleOfRadius: 5)
        cockpit.fillColor = .cyan
        cockpit.position = CGPoint(x: 0, y: 5)
        addChild(cockpit)
        
        // Setup Emitters (Programmatic for now, ideally load from .sks)
        leftThruster = createThruster()
        leftThruster?.position = CGPoint(x: -15, y: -15)
        leftThruster?.zRotation = 0.5
        addChild(leftThruster!)
        
        rightThruster = createThruster()
        rightThruster?.position = CGPoint(x: 15, y: -15)
        rightThruster?.zRotation = -0.5
        addChild(rightThruster!)
        
        mainThruster = createThruster()
        mainThruster?.position = CGPoint(x: 0, y: -20)
        addChild(mainThruster!)
    }
    
    private func createThruster() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 0
        emitter.particleLifetime = 0.2
        emitter.particlePositionRange = CGVector(dx: 2, dy: 2)
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = -CGFloat.pi / 2
        emitter.emissionAngleRange = CGFloat.pi / 4
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -4.0
        emitter.particleScale = 0.1
        emitter.particleScaleSpeed = -0.1
        emitter.particleColor = .orange
        emitter.particleColorBlendFactor = 1.0
        return emitter
    }
    
    func update(deltaTime: TimeInterval) {
        guard let body = physicsBody else { return }
        
        // Reset Emitters
        leftThruster?.particleBirthRate = 0
        rightThruster?.particleBirthRate = 0
        mainThruster?.particleBirthRate = 0
        
        if isThrustingUp {
            let force = CGVector(dx: 0, dy: upThrustForce * 2)
            body.applyForce(force)
            mainThruster?.particleBirthRate = 100
            SoundManager.shared.playThrust()
        } else {
            if isThrustingLeft {
                let force = CGVector(dx: sideThrustForce, dy: upThrustForce * 0.5)
                body.applyForce(force)
                zRotation = max(zRotation - rotationSpeed, -0.5)
                rightThruster?.particleBirthRate = 50 // Right thruster pushes Left
                SoundManager.shared.playThrust()
            }
            
            if isThrustingRight {
                let force = CGVector(dx: -sideThrustForce, dy: upThrustForce * 0.5)
                body.applyForce(force)
                zRotation = min(zRotation + rotationSpeed, 0.5)
                leftThruster?.particleBirthRate = 50 // Left thruster pushes Right
                SoundManager.shared.playThrust()
            }
        }
        
        // Stabilize Rotation (Return to 0 if no input)
        if !isThrustingLeft && !isThrustingRight {
            let targetRotation: CGFloat = 0
            let currentRotation = zRotation
            zRotation = currentRotation + (targetRotation - currentRotation) * 0.1
        }
        
        // Clamp Velocity
        let dx = body.velocity.dx
        let dy = body.velocity.dy
        body.velocity = CGVector(dx: max(min(dx, maxVelocity), -maxVelocity),
                                 dy: max(min(dy, maxVelocity), -maxVelocity))
    }
}
