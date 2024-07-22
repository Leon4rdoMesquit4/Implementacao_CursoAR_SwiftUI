//
//  CoachingImplementation.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 22/07/24.
//

import ARKit
import RealityKit

extension ARView: ARCoachingOverlayViewDelegate{
    
    func addCoachingOverlay(){
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        self.addSubview(coachingOverlay)
    }
    
    private func addVirtualObjects() {
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [SimpleMaterial(color: .green, isMetallic: true)])
        
        guard let anchor = self.scene.anchors.first(where: { $0.name == "Plane Anchor"}) else { return }
        
        anchor.addChild(box)
        
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        addVirtualObjects()
    }
    
}
