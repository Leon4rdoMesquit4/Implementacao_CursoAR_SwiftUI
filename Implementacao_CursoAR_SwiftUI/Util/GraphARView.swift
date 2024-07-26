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
        context.coordinator.setUpUI()
        
        return arView
        
    }
    
    func makeCoordinator() -> ArCoordinator {
        ArCoordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class ArCoordinator {
    var arView: ARView?
    
    var graph: Graph = Graph()
    
    @MainActor func setUpUI() {
        
        //        let anchor = AnchorEntity(.image(group: "AR Resources", name: "0ww74zrj0y5fzwcktjrejhcar"))
        let anchor = AnchorEntity(plane: .horizontal)
        
        let sphere1 = Node()
        sphere1.position.x = -0.1
        sphere1.position.y = 0.5
        sphere1.position.z = -0.1
        
        let sphere2 = Node()
        
        let point3DSphere1 = Point3D(position: sphere1.position)
        let point3DSphere2 = Point3D(position: sphere2.position)
        
        let distance = simd_distance(sphere1.position, sphere2.position)
        
        let connectingBox = Edge(firstNode: sphere1, secondNode: sphere2, distance: distance)
        
        connectingBox.position = midpoint(pointA: point3DSphere1, pointB: point3DSphere2).position
        
        connectingBox.look(at: sphere1.position, from: connectingBox.position, relativeTo: nil)
        
        anchor.addChild(sphere1)
        anchor.addChild(sphere2)
        anchor.addChild(connectingBox)
        arView?.scene.addAnchor(anchor)
        
    }
    
    func midpoint(pointA: Point3D, pointB: Point3D) -> Point3D {
        let midX = (pointA.x + pointB.x) / 2
        let midY = (pointA.y + pointB.y) / 2
        let midZ = (pointA.z + pointB.z) / 2
        return Point3D(x: midX, y: midY, z: midZ)
    }
    
    func quaternionForRotation(from vector: SIMD3<Float>) -> simd_quatf {
        // Normaliza o vetor de entrada
        let normalizedVector = normalize(vector)
        
        // Define o vetor z unitário (direção inicial)
        let zAxis = SIMD3<Float>(0, 0, 1)
        
        // Calcula o ângulo entre o vetor z e o vetor normalizado
        let dotProduct = dot(zAxis, normalizedVector)
        let angle = acos(dotProduct)
        
        // Calcula o eixo de rotação
        let rotationAxis = normalize(cross(zAxis, normalizedVector))
        
        // Cria o quaternion a partir do eixo de rotação e do ângulo
        return simd_quatf(angle: angle, axis: rotationAxis)
    }
    
}

struct Point3D {
    var x: Float
    var y: Float
    var z: Float
    
    init(position: SIMD3<Float>) {
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    init(x: Float, y: Float, z: Float){
        self.x = x
        self.y = y
        self.z = z
    }
    
    var position: SIMD3<Float> {
        get {
            simd_float3(x, y, z)
        }
    }
    
}
