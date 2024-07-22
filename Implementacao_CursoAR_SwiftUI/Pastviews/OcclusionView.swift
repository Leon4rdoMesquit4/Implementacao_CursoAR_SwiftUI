//
//  OcclusionView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 19/07/24.
//

import SwiftUI
import RealityKit
import Combine

struct OcclusionView : View {
    var body: some View {
        Occlusion().edgesIgnoringSafeArea(.all)
    }
}

struct Occlusion: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        context.coordinator.arView = arView
        context.coordinator.setup()
        
        return arView
        
    }
    
    func makeCoordinator() -> OcclusionCoordinator {
        OcclusionCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class OcclusionCoordinator: NSObject {
    
    weak var arView: ARView?
    var cancellable: AnyCancellable?
    
    func setup() {
        
        guard let arView = arView else {
            return
        }
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [OcclusionMaterial()])
        box.generateCollisionShapes(recursive: true)
        arView.installGestures(.all, for: box)
        
        cancellable = ModelEntity.loadAsync(named: "fender_stratocaster")
            .sink { [weak self] completion in
                
                if case let .failure(error) = completion {
                    fatalError("Unable to load model \(error)")
                }
                
                self?.cancellable?.cancel()
                
            } receiveValue: { entity in
                anchor.addChild(entity)
            }
        
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
        
    }
    
}



#Preview {
    ContentView()
}
