//
//  ChangeBoxColor.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ChangeBoxColorView : View {
    var body: some View {
        ChangeBoxColor().edgesIgnoringSafeArea(.all)
    }
}

struct ChangeBoxColor: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))

        context.coordinator.view = arView
        arView.session.delegate = context.coordinator
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .random(), isMetallic: true)])
        
        box.generateCollisionShapes(recursive: true)
        
        anchor.addChild(box)
        arView.scene.anchors.append(anchor)
        
        return arView
        
    }
    
    func makeCoordinator() -> CoordinatorColor {
        CoordinatorColor()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class CoordinatorColor: NSObject, ARSessionDelegate{
    
    weak var view: ARView?
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
            
        let tapLocation = recognizer.location(in: view)
        
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            let material = SimpleMaterial(color: .random(), isMetallic: true)
            entity.model?.materials = [material]
        }
        
    }
}


extension UIColor {
    
    static func random() -> UIColor {
        UIColor(displayP3Red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1), alpha: 1)
    }
    
}
