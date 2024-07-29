//
//  GraphModels.swift
//  BubbleSound
//
//  Created by Luca Lacerda on 24/07/24.
//

import RealityKit
import SwiftUI

//Tipos de sons
enum SoundTypes: CaseIterable {
    case square  
    case triangle
    case star
    case moon

    //APENAS PARA TESTES
    var color: Color{
        switch self {
        case .square:
            .purple
        case .triangle:
            .green
        case .star:
            .red
        case .moon:
            .blue
        }
    }
    
    //APENAS PARA TESTES
    var uicolor: UIColor {
        switch self {
        case .square:
            .purple
        case .triangle:
            .green
        case .star:
            .red
        case .moon:
            .blue
        }
    }
    
    //APENAS PARA TESTES
    var image: String {
        switch self {
        case .square:
            "square.fill"
        case .triangle:
            "triangleshape.fill"
        case .star:
            "star.fill"
        case .moon:
            "moon.fill"
        }
    }
    
    var id: UUID{
        return UUID()
    }
}

//Struct base que representa o node
class Node: Entity, HasModel, HasCollision {
    
    var nodeId: UUID
    var type: SoundTypes
    var connections = 3
    var point: Point3D {
        get {
            Point3D(position: position)
        }
    }
    
    init(id: UUID, type: SoundTypes, connections: Int = 3) {
        self.nodeId = id
        self.type = type
        self.connections = connections
        super.init()
        self.createArNode()
        generateCollisionShapes(recursive: true)
    }
    
    //Alterar o init
    required init() {
        self.nodeId = .init()
        self.type = .moon
        self.connections = 3
        super.init()
        self.createArNode()
    }
    
    func createArNode(){
        let sphere1 = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.1), materials: [SimpleMaterial(color: type.uicolor, roughness: 0.1, isMetallic: false)])
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
class Edge: Entity, HasModel, HasCollision {
    var firstNode:Node {
        didSet{
            changeDirectionAndRotation()
        }
    }
    var secondNode:Node {
        didSet{
            changeDirectionAndRotation()
        }
    }
    var point: Point3D {
        get {
            Point3D(position: position)
        }
    }
    
    init(firstNode: Node, secondNode: Node) {
        self.firstNode = firstNode
        self.secondNode = secondNode
        
        super.init()   
        
        let distance = simd_distance(firstNode.position, secondNode.position)
        
        createArNode(distance: distance)
        changeDirectionAndRotation()
        generateCollisionShapes(recursive: true)
    }
    
    func createArNode(distance: Float){
        let connectionLinkModel = ModelComponent(mesh: MeshResource.generateBox(width: 0.05, height: 0.05, depth: distance, cornerRadius: 15), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
        self.model = connectionLinkModel
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    func changeDirectionAndRotation(){
        self.position = midpoint(pointA: firstNode.point, pointB: secondNode.point).position
        self.look(at: firstNode.position, from: position, relativeTo: nil)
    }
    
    func midpoint(pointA: Point3D, pointB: Point3D) -> Point3D {
        let midX = (pointA.x + pointB.x) / 2
        let midY = (pointA.y + pointB.y) / 2
        let midZ = (pointA.z + pointB.z) / 2
        return Point3D(x: midX, y: midY, z: midZ)
    }
}
