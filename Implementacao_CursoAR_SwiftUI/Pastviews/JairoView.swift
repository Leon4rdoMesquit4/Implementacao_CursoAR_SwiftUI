//
//  JairoView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 19/07/24.
//

import SwiftUI
import RealityKit
import Combine
import AVFoundation

struct JairoView : View {
    var body: some View {
        Jairo().edgesIgnoringSafeArea(.all)
    }
}

struct Jairo: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        guard let url = Bundle.main.url(forResource: "IMG_2497", withExtension: "MOV") else {
            fatalError("Video file was not found")
        }
        
        let player = AVPlayer(url: url)
        
        let material = VideoMaterial(avPlayer: player)
        
        material.controller.audioInputMode = .spatial
        
        let modelEntity = ModelEntity(mesh: MeshResource.generatePlane(width: 0.5, depth: 0.5), materials: [material])
        
        player.play()
        anchor.addChild(modelEntity)
        arView.scene.addAnchor(anchor)
        
        return arView
        
    }
    
    func makeCoordinator() -> JairoCoordinator {
        JairoCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class JairoCoordinator: NSObject {
    
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
    
    @objc func handleTap(){
        
    }
    
}

struct SemLuz: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.3), materials: [UnlitMaterial(color: .red)])
        
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

#Preview {
    ContentView()
}
