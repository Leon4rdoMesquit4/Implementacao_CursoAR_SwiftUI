//
//  CreateABoxView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import ARKit
import RealityKit
import SwiftUI

//struct CreateABoxView : View {
//    
//    @State var state: GameState
//    @State var nodeSoundType: SoundTypes
//    
//    var body: some View {
//        ARViewContainer(state: $state, nodeSoundType: $nodeSoundType).edgesIgnoringSafeArea(.all)
//    }
//}

struct CreateABox: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))

        context.coordinator.view = arView
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    func makeCoordinator() -> BoxCoordinator {
        BoxCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}


class BoxCoordinator: NSObject, ARSessionDelegate{
    
    weak var view: ARView?
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
            
        let tapLocation = recognizer.location(in: view)
        
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            let anchor = ARAnchor(name: "Plane Anchor", transform: result.worldTransform)
            view.session.add(anchor: anchor)
            
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: 0.3))
            modelEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(modelEntity)
            
            view.scene.addAnchor(anchorEntity)
            
        }
        
    }
}
