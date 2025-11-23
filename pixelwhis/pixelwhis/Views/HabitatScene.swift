import SpriteKit
import SwiftUI
import CoreMotion
import Combine

class HabitatScene: SKScene {
    // Nodes
    private var petNode: SKSpriteNode!
    private var backgroundNode: SKNode!
    private var midgroundNode: SKNode!
    private var foregroundNode: SKNode!
    private var lightNode: SKLightNode!
    private var cameraNode: SKCameraNode!
    
    // Motion
    #if os(iOS)
    private let motionManager = CMMotionManager()
    #endif
    
    // Pet Data
    var pet: Pet?
    
    override func didMove(to view: SKView) {
        setupScene()
        setupLayers()
        setupLighting()
        setupPet()
        setupCamera()
        startMotionUpdates()
        
        // Atmospheric particles
        addParticles()
    }
    
    private func setupScene() {
        backgroundColor = .black // Will be covered by sky
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    private func setupLayers() {
        // 1. Sky (Far back)
        let sky = SKSpriteNode(color: UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0), size: size)
        sky.zPosition = -100
        addChild(sky)
        
        // 2. Background (Mountains)
        backgroundNode = SKNode()
        backgroundNode.zPosition = -50
        addChild(backgroundNode)
        // Add dummy mountains
        for i in 0...2 {
            let mountain = SKSpriteNode(color: .darkGray, size: CGSize(width: 300, height: 400))
            mountain.position = CGPoint(x: CGFloat(i) * 200 - 200, y: 0)
            mountain.zRotation = .pi / 4
            backgroundNode.addChild(mountain)
        }
        
        // 3. Midground (Trees/Hills)
        midgroundNode = SKNode()
        midgroundNode.zPosition = -20
        addChild(midgroundNode)
        
        // 4. Foreground (Grass)
        foregroundNode = SKNode()
        foregroundNode.zPosition = 50
        addChild(foregroundNode)
    }
    
    private func setupLighting() {
        lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.falloff = 1
        lightNode.ambientColor = UIColor.white.withAlphaComponent(0.5)
        lightNode.lightColor = .white
        lightNode.shadowColor = .black.withAlphaComponent(0.5)
        lightNode.position = CGPoint(x: 0, y: 200)
        addChild(lightNode)
    }
    
    private func setupPet() {
        guard let pet = pet else { return }
        
        // Load texture using AssetManager
        let assetName = AssetManager.shared.asset(for: pet)
        petNode = SKSpriteNode(imageNamed: assetName)
        
        // If asset not found, fallback to a shape for debugging
        if petNode.texture == nil {
             petNode = SKSpriteNode(color: .white, size: CGSize(width: 64, height: 64))
        }
        
        petNode.size = CGSize(width: 100, height: 100) // Slightly larger for 2.5D
        petNode.position = CGPoint(x: 0, y: -50)
        petNode.zPosition = 0
        
        // Physics
        petNode.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        petNode.physicsBody?.isDynamic = true
        petNode.physicsBody?.allowsRotation = false
        petNode.physicsBody?.restitution = 0.4 // Bouncy
        petNode.physicsBody?.mass = 1.0
        
        // Lighting
        petNode.shadowCastBitMask = 1
        petNode.lightingBitMask = 1
        
        addChild(petNode)
        
        // Floor physics
        let floor = SKNode()
        floor.position = CGPoint(x: 0, y: -100)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 20))
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }
    
    
    private func startMotionUpdates() {
        #if os(iOS)
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, let self = self else { return }
            
            // Parallax effect based on tilt
            let roll = CGFloat(data.attitude.roll)
            let pitch = CGFloat(data.attitude.pitch)
            
            self.updateParallax(roll: roll, pitch: pitch)
        }
        #endif
    }
    
    private func updateParallax(roll: CGFloat, pitch: CGFloat) {
        // Move layers based on tilt to create depth
        let sensitivity: CGFloat = 50.0
        
        backgroundNode.position.x = roll * sensitivity * 0.2
        midgroundNode.position.x = roll * sensitivity * 0.5
        foregroundNode.position.x = roll * sensitivity * 1.2
        
        // Subtle camera sway
        cameraNode.position.x = roll * 10
        cameraNode.position.y = pitch * 10
    }
    
    private func addParticles() {
        // Fireflies / Dust motes
        let particle = SKEmitterNode()
        particle.particleTexture = SKTexture(imageNamed: "sparkle") // Will fallback to default if missing
        particle.particleBirthRate = 2
        particle.particleLifetime = 10
        particle.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        particle.position = CGPoint(x: 0, y: 0)
        particle.particleSpeed = 10
        particle.particleSpeedRange = 5
        particle.particleAlpha = 0.5
        particle.particleAlphaRange = 0.2
        particle.particleScale = 0.1
        particle.particleScaleRange = 0.05
        particle.particleColor = .yellow
        particle.particleColorBlendFactor = 1.0
        particle.zPosition = 10
        addChild(particle)
        
        // Weather effects could go here (rain, snow)
    }
    
    // Interaction
    func petTapped() {
        // Bounce animation
        petNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        
        // Heart particles
        // ...
    }
}

// SwiftUI Wrapper
struct HabitatView: View {
    let pet: Pet
    @StateObject private var sceneStore = SceneStore()
    
    var body: some View {
        SpriteView(scene: sceneStore.scene, options: [.allowsTransparency])
            .ignoresSafeArea()
            .onAppear {
                sceneStore.setup(with: pet)
            }
    }
}

class SceneStore: ObservableObject {
    @Published var scene: HabitatScene
    
    init() {
        scene = HabitatScene()
        scene.scaleMode = .resizeFill
    }
    
    func setup(with pet: Pet) {
        scene.pet = pet
    }
}
