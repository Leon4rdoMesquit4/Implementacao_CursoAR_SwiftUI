//
//  ChangeObjectStateView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import SwiftUI
import RealityKit

struct ChangeObjectStateView : View {
    var body: some View {
        ChangeObjectState().edgesIgnoringSafeArea(.all)
    }
}

struct ChangeObjectState: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))

        context.coordinator.view = arView
        
        return arView
        
    }
    
    func makeCoordinator() -> ChangeStateCoordinator {
        ChangeStateCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class ChangeStateCoordinator: NSObject{
    
    weak var view: ARView?
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
            
        let tapLocation = recognizer.location(in: view)
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let anchorEntity = AnchorEntity(raycastResult: result)
            
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: 0.3))
            modelEntity.generateCollisionShapes(recursive: true)
            
            modelEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
            anchorEntity.addChild(modelEntity)
            view.scene.addAnchor(anchorEntity)
            
            view.installGestures(.all, for: modelEntity)
        }
        
    }
}
