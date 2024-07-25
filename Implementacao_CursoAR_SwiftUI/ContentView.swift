//
//  ContentView.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 18/07/24.
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
//        context.coordinator.setUpUI()
        context.coordinator.setUpUI2()
        
        return arView
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class Coordinator {
    var arView: ARView?
    
    @objc func handleTap(){
        
    }
    
    //Horizontal X
    //Cima Y
    //Vertical Z
    
    func setUpUI2() {
        
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "0ww74zrj0y5fzwcktjrejhcar"))

        let sphere1 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        sphere1.position.x = -0.2
        sphere1.position.y = 0.2
        sphere1.position.z = -0.2
        
        
        let sphere2 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        
        let point3DSphere1 = Point3D(position: sphere1.position)
        let point3DSphere2 = Point3D(position: sphere2.position)
        
        let distance = simd_distance(sphere1.position, sphere2.position)
        
        let connectingBox = ModelEntity(mesh: MeshResource.generateBox(width: 0.02, height: 0.02, depth: distance, cornerRadius: 15), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
        
        connectingBox.position = midpoint(pointA: point3DSphere1, pointB: point3DSphere2).position
        
        connectingBox.look(at: sphere1.position, from: connectingBox.position, relativeTo: nil)
        
        anchor.addChild(sphere1)
        anchor.addChild(sphere2)
        anchor.addChild(connectingBox)
        arView?.scene.addAnchor(anchor)

    }
    
    func setUpUI() {
        
        let anchor = AnchorEntity(.image(group: "AR Resources", name: "0ww74zrj0y5fzwcktjrejhcar"))
        
        let sphere1 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        sphere1.position.x = -0.2
        sphere1.position.y = 0.2
        sphere1.position.z = -0.2
        
        let point3DSphere1 = Point3D(position: sphere1.position)
        
        let sphere2 = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .systemPink, roughness: 0.1, isMetallic: false)])
        sphere2.position.x = 0
        sphere2.position.y = 0
        sphere2.position.z = 0
        
        let point3DSphere2 = Point3D(position: sphere2.position)
        
        let sphere1Position = sphere1.position(relativeTo: nil)
        let sphere2Position = sphere2.position(relativeTo: nil)
        
        let distance = simd_distance(sphere1Position, sphere2Position)
        print(distance)
        
        let connectingBox = ModelEntity(mesh: MeshResource.generateBox(width: distance, height: 0.02, depth: 0.02, cornerRadius: 15), materials: [SimpleMaterial(color: .cyan, isMetallic: true)])
        
        connectingBox.position = midpoint(pointA: point3DSphere1, pointB: point3DSphere2).position
        print(connectingBox.transform.matrix)

        /*
         0.34641016
         simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [-0.1, 0.1, -0.1, 1.0]])
         simd_float4x4([[0.7071068, 0.0, 0.70710677, 0.0], [-0.0, 1.0, 0.0, 0.0], [-0.70710677, -0.0, 0.7071069, 0.0], [-0.1, 0.1, -0.1, 1.0]])
         */
        
        //EIXO HORIZONTAL
//        connectingBox.setOrientation(simd_quatf(angle: (45*(Float.pi)) / 180, axis: [0, -1, 0]), relativeTo: nil)
        connectingBox.setOrientation(simd_quatf(angle: (45*(Float.pi)) / 180, axis: [0, 0, 1]), relativeTo: nil)
        print(connectingBox.transform.matrix)

        
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
