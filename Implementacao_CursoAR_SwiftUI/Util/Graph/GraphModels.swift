//
//  GraphModels.swift
//  BubbleSound
//
//  Created by Luca Lacerda on 24/07/24.
//

import RealityKit
import Foundation

//Tipos de sons
enum SoundTypes {
    case square
    case triangle
    case star
    case moon
}

//Struct base que representa o node
class Node: Entity, HasModel {
    
    var nodeId: UUID
    var type: SoundTypes
    var connections = 3
    
    init(id: UUID, type: SoundTypes, connections: Int = 3) {
        self.nodeId = id
        self.type = type
        self.connections = connections
        super.init()
    }
    
    required init() {
        self.nodeId = .init()
        self.type = .moon
        self.connections = 3
        super.init()
        self.createArNode()
    }
    
    func createArNode(){
        let sphere1 = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        self.model = sphere1
    }
    
    func removeConnection() {
        self.connections = self.connections - 1
    }
    
    func addConnection() {
        self.connections = self.connections + 1
    }
    
    func canConnect() -> Bool {
        if self.connections > 0 {
            return true
        } else {
            return false
        }
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        if lhs.nodeId == rhs.nodeId {
            return true
        } else {
            return false
        }
    }
}

//Struct base que representa a conexão entre nodes
class Edge: Entity, HasModel {
    var firstNode:Node
    var secondNode:Node
    
    init(firstNode: Node, secondNode: Node) {
        self.firstNode = firstNode
        self.secondNode = secondNode
        
        super.init()        
    }
    
    init(firstNode: Node, secondNode: Node, distance: Float) {
        self.firstNode = firstNode
        self.secondNode = secondNode
        
        super.init()
        
        createArNode(distance: distance)
    }
    
    func createArNode(distance: Float){
        let connectionLinkModel = ModelComponent(mesh: MeshResource.generateBox(width: 0.02, height: 0.02, depth: 0, cornerRadius: 15), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
        self.model = connectionLinkModel
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}
