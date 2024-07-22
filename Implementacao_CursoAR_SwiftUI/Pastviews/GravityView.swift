//
//  GravityView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 21/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation

struct Gravity: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        
        let planeAnchorEntity = AnchorEntity(plane: .horizontal)
        let plane = ModelEntity(mesh: MeshResource.generatePlane(width: 1, depth: 1), materials: [SimpleMaterial(color: .orange, isMetallic: true)])
        plane.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(), mode: .static)
        plane.generateCollisionShapes(recursive: true)
        
        planeAnchorEntity.addChild(plane)
        arView.scene.anchors.append(planeAnchorEntity)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))
        context.coordinator.view = arView
        
        return arView
        
    }
    
    func makeCoordinator() -> GravityCoordinator {
        GravityCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class GravityCoordinator{
    
    weak var view: ARView?
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
            
        let tapLocation = recognizer.location(in: view)
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            let anchorEntity = AnchorEntity(raycastResult: result)
            let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .green, isMetallic: true)])
            box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(), mode: .dynamic)
            box.generateCollisionShapes(recursive: true)
            
            box.position = simd_make_float3(0, 0.7, 0)
            
            anchorEntity.addChild(box)
            view.scene.anchors.append(anchorEntity)
        }
        
    }
}

struct GravityView : View {
    var body: some View {
        Gravity().edgesIgnoringSafeArea(.all)
    }
}
