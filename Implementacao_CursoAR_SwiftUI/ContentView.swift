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
    
    func setUpUI() {
        
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "0ww74zrj0y5fzwcktjrejhcar"))
        
        let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.1), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        
        anchor.addChild(sphere)
        arView?.scene.addAnchor(anchor)
        
    }
}
