//
//  TextureView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 20/07/24.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation

struct TextureView : View {
    var body: some View {
        TextureContainer().edgesIgnoringSafeArea(.all)
    }
}

struct TextureContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.arView = arView
        context.coordinator.setUpVariousImages()
        
        return arView
        
    }
    
    func makeCoordinator() -> TextureContainerCoordinator {
        TextureContainerCoordinator()
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}


class TextureContainerCoordinator: NSObject, ARSessionDelegate{
    
    var arView: ARView?
    var cancellable: AnyCancellable?
    
    func setUpOneImage(){
        guard let arView = arView else {
            return
        }
        
        let anchor = AnchorEntity(plane: .horizontal)
        let mesh = MeshResource.generateBox(size: 0.3)
        let box = ModelEntity(mesh: mesh)
        
        let texture = try? TextureResource.load(named: "Gabigol")
        
        if let texture = texture {
            var material = UnlitMaterial()
            material.color = .init(tint: .white, texture: .init(texture))
            box.model?.materials = [material]
        }
        
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
        
    }
    
    func setUpVariousImages(){
        guard let arView = arView else {
            return
        }
        
        let anchor = AnchorEntity(plane: .horizontal)
        let mesh = MeshResource.generateBox(width: 0.3, height: 0.3, depth: 0.3, cornerRadius: 0, splitFaces: true)
        let box = ModelEntity(mesh: mesh)
        
        cancellable = TextureResource.loadAsync(named: "Arrascaeta")
            .append(TextureResource.loadAsync(named: "Gabigol"))
            .append(TextureResource.loadAsync(named: "Pedro"))
            .append(TextureResource.loadAsync(named: "Gabigol"))
            .append(TextureResource.loadAsync(named: "Pedro"))
            .append(TextureResource.loadAsync(named: "Arrascaeta"))
            .collect()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    fatalError("Unable to load texture \(error)")
                }
                
                self?.cancellable?.cancel()
            }, receiveValue: { textures in
                
                var materials = [UnlitMaterial]()
                
                textures.forEach { texture in
                    var material = UnlitMaterial()
                    material.color = .init(tint: .white, texture: .init(texture))
                    materials.append(material)
                }
                
                box.model?.materials = materials
                
                
            })
        
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
    }
}
