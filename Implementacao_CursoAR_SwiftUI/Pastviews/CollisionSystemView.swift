//
//  CollisionSystemView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 22/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation

struct CollisionSystem: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.view = arView
        context.coordinator.buildEnvironment()
        
        return arView
        
    }
    
    func makeCoordinator() -> CollisionSystemCoordinator {
        CollisionSystemCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class CollisionSystemCoordinator: NSObject, ARSessionDelegate, UIGestureRecognizerDelegate{
    
    weak var view: ARView?
    
    var movableEntities = [CollisionSystemMovableEntity]()
    
    func buildEnvironment() {
        guard let view = view else { return }
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let floor = ModelEntity(mesh: MeshResource.generatePlane(width: 0.9, depth: 0.9), materials: [SimpleMaterial(color: .green, isMetallic: true)])
        floor.generateCollisionShapes(recursive: true)
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        
        let box1 = CollisionSystemMovableEntity(size: 0.3, color: .purple, shape: .box)
        let box2 = CollisionSystemMovableEntity(size: 0.3, color: .blue, shape: .box)
        let sphere1 = CollisionSystemMovableEntity(size: 0.3, color: .systemPink, shape: .sphere)
        let sphere2 = CollisionSystemMovableEntity(size: 0.3, color: .orange, shape: .sphere)
        
        anchor.addChild(floor)
        anchor.addChild(box1)
        anchor.addChild(box2)
        anchor.addChild(sphere1)
        anchor.addChild(sphere2)
        
        movableEntities.append(box1)
        movableEntities.append(box2)
        movableEntities.append(sphere1)
        movableEntities.append(sphere2)
        
        view.scene.addAnchor(anchor)
        
        movableEntities.forEach {
            view.installGestures(.all, for: $0).forEach {
                $0.delegate = self
            }
        }
        
        setUpGestures()
        
    }
    
    fileprivate func setUpGestures() {
        
        guard let view = view else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .ended, .cancelled, .failed:
            movableEntities.compactMap{ $0 }.forEach {
                $0.physicsBody?.mode = .dynamic
            }
        default:
            return
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let translationGesture = gestureRecognizer as? EntityTranslationGestureRecognizer,
              let entity = translationGesture.entity as? CollisionSystemMovableEntity else {
            return true
        }
        
        entity.physicsBody?.mode = .kinematic
        return true
    }
}

struct CollisionSystemView : View {
    var body: some View {
        CollisionSystem().edgesIgnoringSafeArea(.all)
    }
}

enum CollisionSystemShape{
    case box
    case sphere
}

class CollisionSystemMovableEntity: Entity, HasModel, HasPhysics, HasCollision {
    var size: Float!
    var color: UIColor!
    var shape: CollisionSystemShape = .box
    
    init(size: Float!, color: UIColor!, shape: CollisionSystemShape) {
        super.init()
        self.size = size
        self.color = color
        self.shape = shape
        
        let mesh = generateMeshResource()
        let materials = [generateMaterial()]
        model = ModelComponent(mesh: mesh, materials: materials)
        
        physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        collision = CollisionComponent(shapes: [generateShapeResource()], mode: .trigger, filter: .sensor)
        
        generateCollisionShapes(recursive: true)
    }
    
    private func generateMaterial() -> RealityKit.Material {
        SimpleMaterial(color: color, isMetallic: true)
    }
    
    private func generateMeshResource() -> MeshResource{
        switch shape {
        case .box:
            return MeshResource.generateBox(size: size)
        case .sphere:
            return MeshResource.generateSphere(radius: size)
        }
    }
    
    private func generateShapeResource() -> ShapeResource{
        switch shape {
        case .box:
            return ShapeResource.generateBox(size: [self.size, self.size, self.size])
        case .sphere:
            return ShapeResource.generateSphere(radius: size)
        }
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}
