//
//  LucasView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 22/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation

struct LucasView : View {
    var body: some View {
        LucasViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct LucasViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.arView = arView
        context.coordinator.setUpUI()
        
//        arView.addCoachingOverlay()
        
        return arView
        
    }
    
    func makeCoordinator() -> LucasViewCoordinator {
        LucasViewCoordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class LucasViewCoordinator {
    var arView: ARView?
    var cancellable: AnyCancellable?
    
    func setUpUI(){
        
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "0ww74zrj0y5fzwcktjrejhcar"))
        
        cancellable = ModelEntity.loadAsync(named: "gramophone").sink { completion in
            if case let .failure(error) = completion {
                print("Unable to load model \(error)")
            }
        } receiveValue: { entity in
            entity.scale = [0.005, 0.005, 0.005]
            anchor.addChild(entity)
            self.arView?.scene.addAnchor(anchor)
        }

    }
    
    func setUpUI2(){
        
        guard let videoURL = Bundle.main.url(forResource: "0a72ab1b-afcf-442b-9d35-d95c18dc8099", withExtension: "mov") else {
            fatalError("Unable")
        }
        
        let player = AVPlayer(url: videoURL)
        
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "Lucas2"))
        let plane = ModelEntity(mesh: MeshResource.generatePlane(width: 15, depth: 23), materials: [videoMaterial])
        
//        plane.orientation = simd_quatf(angle: .pi/2, axis: [1,0,0])
        anchor.addChild(plane)
        arView?.scene.addAnchor(anchor)
        player.play()
        }
}
