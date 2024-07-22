//
//  LoadModelsView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
//

import SwiftUI
import RealityKit
import Combine

class LoadModelsCoordinator: NSObject {
    
    weak var view: ARView?
    var cancellable: AnyCancellable?
    
    @objc func handletap(_ recognizer: UITapGestureRecognizer){
        guard let view = self.view else { return }
        
        guard view.scene.anchors.first(where: { $0.name == "LunarRoverAnchor"}) == nil else { return }
            
        let tapLocation = recognizer.location(in: view)
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
           
            let anchor = AnchorEntity(raycastResult: result)
            
//            guard let entity = try? ModelEntity.load(named: "gramophone") else {
//                fatalError("Gramophone model was not loaded!")
//            }
            
            cancellable = ModelEntity.loadAsync(named: "gramophone")
                .append(ModelEntity.loadAsync(named: "fender_stratocaster"))
                .collect()
                .sink { loadCompletion in
                    if case let .failure(error) = loadCompletion {
                        print("Unable to load model \(error)")
                    }
                    
                    self.cancellable?.cancel()
                } receiveValue: { entities in
                    
                    var x: Float = 0.0
                    
                    entities.forEach { entity in
                        
                        entity.position = simd_make_float3(x, 0, 0)
                        anchor.addChild(entity)
                        x += 0.5
                    }
                }
            
            
//            cancellable = ModelEntity.loadAsync(named: "hab")
//                .sink { loadCompletion in
//                    if case let .failure(error) = loadCompletion {
//                        print("Unable to load model \(error)")
//                    }
//
//                    self.cancellable?.cancel()
//
//                } receiveValue: { entity in
//
//                    anchor.name = "LunarRoverAnchor"
//                    anchor.addChild(entity)
//                }
            
            
            view.scene.addAnchor(anchor)
            
        }
        
    }
}

struct LoadModelsView : View {
    var body: some View {
        LoadModels().edgesIgnoringSafeArea(.all)
    }
}

struct LoadModels: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handletap)))

        context.coordinator.view = arView
        
        return arView
        
    }
    
    func makeCoordinator() -> LoadModelsCoordinator {
        LoadModelsCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}


