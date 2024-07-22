//
//  MeasureView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 22/07/24.
//

import SwiftUI
import RealityKit
import ARKit

struct MeasureView : View {
    var body: some View {
        MeasureViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct MeasureViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(MeasureCoordinator.handleTap)))
        context.coordinator.arView = arView
        context.coordinator.setUpUI()
        
        arView.addCoachingOverlay()
        
        return arView
        
    }
    
    func makeCoordinator() -> MeasureCoordinator {
        MeasureCoordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}
