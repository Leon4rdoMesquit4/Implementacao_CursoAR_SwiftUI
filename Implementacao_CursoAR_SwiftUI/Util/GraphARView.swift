//
//  GraphARView.swift
//  BubbleSound
//
//  Created by Leonardo Mesquita Alves on 25/07/24.
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
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(ArCoordinator.createNewNode)))
        context.coordinator.setUpUI()
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    func makeCoordinator() -> ArCoordinator {
        ArCoordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class ArCoordinator: NSObject, ARSessionDelegate {
    var arView: ARView?
    
    var graph: Graph = Graph()
    
    @objc func createNewNode(_ recognizer: UITapGestureRecognizer){
        guard let view = self.arView else { return }
        
        let tapLocation = recognizer.location(in: view)
        print("OLHA")
        
        if let entity = view.entity(at: tapLocation) as? Node {
            
            let range: [Float] = [-0.3, 0.3, 0.4, -0.4]
            
            let positionX = entity.position.x - range.randomElement()!
            let positionY = entity.position.y - range.randomElement()!
            let positionZ = entity.position.z - range.randomElement()!
            
            _ = graph.addNodeToGraph(idToAdd: .init(), idToConnect: entity.nodeId, typeToAdd: .star, position: .init(positionX, positionY, positionZ))
        }
    }
    
    func setUpUI() {
        let anchor = AnchorEntity(plane: .horizontal)
        
        graph.sceneAnchor = anchor
        
        let nodeID = UUID.init()
        
        graph.addFirstNode(id: nodeID, type: .moon, position: .zero)
        arView?.scene.addAnchor(anchor)
        
    }
    
}

