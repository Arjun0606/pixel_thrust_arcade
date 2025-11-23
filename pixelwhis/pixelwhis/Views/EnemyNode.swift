import SpriteKit

class EnemyNode: SKSpriteNode {
    
    enum EnemyType {
        case basic // Refills dashes
        case hazard // Kills you (Spike Mine)
    }
    
    var type: EnemyType = .basic
    
    init(type: EnemyType = .basic) {
        self.type = type
        let color: UIColor = type == .basic ? .yellow : .red
        let size = CGSize(width: 30, height: 30)
        
        super.init(texture: nil, color: color, size: size)
        
        setupPhysics()
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false // Static or moved by actions
        physicsBody?.categoryBitMask = 4 // Enemy
        physicsBody?.contactTestBitMask = 1 // Player
        physicsBody?.collisionBitMask = 0 // Don't bounce off them
    }
    
    private func setupVisuals() {
        if type == .hazard {
            // Spikes
            let spike = SKShapeNode(rectOf: CGSize(width: 40, height: 5))
            spike.fillColor = .red
            addChild(spike)
            let spike2 = SKShapeNode(rectOf: CGSize(width: 5, height: 40))
            spike2.fillColor = .red
            addChild(spike2)
        } else {
            // Glow
            let glow = SKShapeNode(circleOfRadius: 20)
            glow.fillColor = .clear
            glow.strokeColor = .yellow
            glow.alpha = 0.5
            addChild(glow)
            glow.run(.repeatForever(.sequence([
                .scale(to: 1.2, duration: 0.5),
                .scale(to: 1.0, duration: 0.5)
            ])))
        }
    }
    
    func die() {
        // Particle effect would go here
        removeAllActions()
        run(.sequence([
            .scale(to: 1.5, duration: 0.1),
            .fadeOut(withDuration: 0.1),
            .removeFromParent()
        ]))
    }
}
