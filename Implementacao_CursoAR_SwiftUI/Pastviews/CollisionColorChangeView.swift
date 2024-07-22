//
//  CollisionColorChangeView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 21/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation

struct CollisionColorChange: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))
        
        
        let floorAnchor = AnchorEntity(plane: .horizontal)
        let floor = ModelEntity(mesh: MeshResource.generateBox(size: [1000, 0, 1000]), materials: [OcclusionMaterial()])
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(), mode: .static)
        floor.generateCollisionShapes(recursive: true)
        
        floorAnchor.addChild(floor)
        arView.scene.anchors.append(floorAnchor)
        
        context.coordinator.view = arView
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    func makeCoordinator() -> CollisionColorChangeCoordinator {
        CollisionColorChangeCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class CollisionColorChangeCoordinator: NSObject, ARSessionDelegate{
    
    weak var view: ARView?
    var collisionSubscription = [Cancellable]()
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
            
        let tapLocation = recognizer.location(in: view)
        
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            let anchor = AnchorEntity(raycastResult: result)
            let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.2), materials: [SimpleMaterial(color: .green, isMetallic: true)])
            box.position.y = 0.3
            box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(), mode: .dynamic)
            box.generateCollisionShapes(recursive: true)
                        
            box.collision = CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])], mode: .trigger, filter: .sensor)
            
            collisionSubscription.append(view.scene.subscribe(to: CollisionEvents.Began.self) { event in
                box.model?.materials = [SimpleMaterial(color: .purple, isMetallic: true)]
            })
            
            collisionSubscription.append(view.scene.subscribe(to: CollisionEvents.Ended.self) { event in
                box.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
            })
            
            anchor.addChild(box)
            view.scene.addAnchor(anchor)
        }
        
    }
}

struct CollisionColorChangeView : View {
    var body: some View {
        CollisionColorChange().edgesIgnoringSafeArea(.all)
    }
}

struct CollisionColorChange2: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.view = arView
        context.coordinator.buildEnvironment()
        
        return arView
        
    }
    
    func makeCoordinator() -> CollisionColorChange2Coordinator {
        CollisionColorChange2Coordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class CollisionColorChange2Coordinator: NSObject, ARSessionDelegate {
    
    weak var view: ARView?
    var collisionSubscription = [Cancellable]()
    
    let boxGroup = CollisionGroup(rawValue: 1 << 0)
    let sphereGroup = CollisionGroup(rawValue: 1 << 1)
    
    func buildEnvironment() {
        guard let view = view else { return }
        
        let boxMask = CollisionGroup.all.subtracting(sphereGroup)
        let sphereMask = CollisionGroup.all.subtracting(boxGroup)
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let box1 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box1.generateCollisionShapes(recursive: true)
        box1.collision = CollisionComponent(
            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
            mode: .trigger,
            filter: .init(
                group: boxGroup,
                mask: boxMask
            )
        )
        
        let box2 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box2.generateCollisionShapes(recursive: true)
        box2.collision = CollisionComponent(
            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
            mode: .trigger,
            filter: .init(
                group: boxGroup,
                mask: boxMask
            )
        )
        box2.position.z = 0.3
        
        let sphere1 = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        sphere1.generateCollisionShapes(recursive: true)
        sphere1.collision = CollisionComponent(
            shapes: [.generateSphere(radius: 0.2)],
            mode: .trigger,
            filter: .init(
                group: sphereGroup,
                mask: sphereMask
            )
        )
        sphere1.position.x += 0.3
        
        let sphere2 = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        sphere2.generateCollisionShapes(recursive: true)
        sphere2.collision = CollisionComponent(
            shapes: [.generateSphere(radius: 0.2)],
            mode: .trigger,
            filter: .init(
                group: sphereGroup,
                mask: sphereMask
            )
        )
        sphere2.position.x -= 0.3
        
        anchor.addChild(box1)
        anchor.addChild(box2)
        anchor.addChild(sphere1)
        anchor.addChild(sphere2)
        
        view.scene.addAnchor(anchor)
        view.installGestures(.all, for: box1)
        view.installGestures(.all, for: box2)
        view.installGestures(.all, for: sphere1)
        view.installGestures(.all, for: sphere2)
        
        
        collisionSubscription.append(view.scene.subscribe(to: CollisionEvents.Began.self) { event in
            guard let entityA = event.entityA as? ModelEntity,
                  let entityB = event.entityB as? ModelEntity else { return }
            
            entityA.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
            entityB.model?.materials = [SimpleMaterial(color: .green, isMetallic: true)]
            
        })
        
        collisionSubscription.append(view.scene.subscribe(to: CollisionEvents.Ended.self) { event in
            guard let entityA = event.entityA as? ModelEntity,
                  let entityB = event.entityB as? ModelEntity else { return }
            
            entityA.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]
            entityB.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]
        })
    }
    
}

struct CollisionColorChange2View : View {
    var body: some View {
        CollisionColorChange2().edgesIgnoringSafeArea(.all)
    }
}


struct CollisionChange: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.view = arView
        context.coordinator.buildEnvironment()
        
        return arView
        
    }
    
    func makeCoordinator() -> CollisionChangeCoordinator {
        CollisionChangeCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class CollisionChangeCoordinator: NSObject, ARSessionDelegate, UIGestureRecognizerDelegate{
    
    weak var view: ARView?
    var collisionSubscription = [Cancellable]()
    
    let boxGroup = CollisionGroup(rawValue: 1 << 0)
    let sphereGroup = CollisionGroup(rawValue: 1 << 1)
    
    var movableEntities = [ModelEntity]()
    
    func buildEnvironment() {
        guard let view = view else { return }
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let floor = ModelEntity(mesh: MeshResource.generatePlane(width: 0.9, depth: 0.9), materials: [SimpleMaterial(color: .green, isMetallic: true)])
        floor.generateCollisionShapes(recursive: true)
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        
        let box1 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box1.generateCollisionShapes(recursive: true)
        box1.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        box1.collision = CollisionComponent(
            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
            mode: .trigger,
            filter: .sensor
        )
        box1.position.y = 0.3
        
        let box2 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box2.generateCollisionShapes(recursive: true)
        box2.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        box2.collision = CollisionComponent(
            shapes: [.generateBox(size: [0.2, 0.2, 0.2])],
            mode: .trigger,
            filter: .sensor
        )
        box2.position.z = 0.3
        box2.position.y = 0.3
        
        let sphere1 = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        sphere1.generateCollisionShapes(recursive: true)
        sphere1.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        sphere1.collision = CollisionComponent(
            shapes: [.generateSphere(radius: 0.2)],
            mode: .trigger,
            filter: .sensor
        )
        sphere1.position.x += 0.3
        sphere1.position.y = 0.3
        
        let sphere2 = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        sphere2.generateCollisionShapes(recursive: true)
        sphere2.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        sphere2.collision = CollisionComponent(
            shapes: [.generateSphere(radius: 0.2)],
            mode: .trigger,
            filter: .sensor
        )
        sphere2.position.x -= 0.3
        sphere2.position.y = 0.3
        
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
              let entity = translationGesture.entity as? ModelEntity else {
            return true
        }
        
        entity.physicsBody?.mode = .kinematic
        return true
    }
}

struct CollisionChangeView : View {
    var body: some View {
        CollisionChange().edgesIgnoringSafeArea(.all)
    }
}
