//
//  ContentView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap)))
//
        context.coordinator.arView = arView
        context.coordinator.setUpUI()
        
        return arView
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class Coordinator {
    var arView: ARView?
    var cancellable: AnyCancellable?
    
    func setUpUI(){
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let box1 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [UnlitMaterial(
                color: .red)])
        
        let box2 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box2.position.z = 0.3
        
        let box3 = ModelEntity(
            mesh: MeshResource.generateBox(size: 0.2),
            materials: [SimpleMaterial(
                color: .red,
                isMetallic: true
            )])
        box3.position.x = 0.3
        
        anchor.addChild(box1)
        anchor.addChild(box2)
        anchor.addChild(box3)
        arView?.scene.addAnchor(anchor)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        guard let arView = arView else { return }
        
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let anchor = AnchorEntity(raycastResult: result)
            
            let lightEntity = PointLight()
            lightEntity.light.color = .yellow
            lightEntity.light.intensity = 1000
            lightEntity.light.attenuationRadius = 0.5
            lightEntity.look(at: [0,0,0], from: [0,0,0.1], relativeTo: anchor)
            
            anchor.addChild(lightEntity)
            arView.scene.addAnchor(anchor)
            
        }
    }
}
