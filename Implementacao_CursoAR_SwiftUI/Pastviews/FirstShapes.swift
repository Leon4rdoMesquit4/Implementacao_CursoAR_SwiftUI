//
//  FirstShapes.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import SwiftUI
import RealityKit

struct FirstShapes : View {
    var body: some View {
        FirstShapesRepresentable().edgesIgnoringSafeArea(.all)
    }
}

struct FirstShapesRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        let anchor = AnchorEntity(plane: .horizontal)
        
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [material])
        
        let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.3), materials: [SimpleMaterial(color: .yellow, isMetallic: true)])
        sphere.position = simd_make_float3(0, 0.4, 0)
        
        let plane = ModelEntity(mesh: MeshResource.generatePlane(width: 0.5, depth: 0.3), materials: [SimpleMaterial(color: .red, isMetallic: true)])
        plane.position = simd_make_float3(0, 0.7, 0)
        
//        let text = ModelEntity(
//            mesh: MeshResource.generateText(
//                "Samuca is gay",
//                extrusionDepth: 0.003,
//                font: .systemFont(ofSize: 0.2),
//                containerFrame: .zero,
//                alignment: .center,
//                lineBreakMode: .byCharWrapping
//            ), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
//
//        anchor.addChild(text)
        
        anchor.addChild(box)
        anchor.addChild(sphere)
        anchor.addChild(plane)
        
        arView.scene.anchors.append(anchor)
        return arView
        
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}
