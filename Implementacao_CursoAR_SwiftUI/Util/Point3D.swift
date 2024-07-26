//
//  Point3D.swift
//  Implementacao_CursoAR_SwiftUI
//
//  Created by Leonardo Mesquita Alves on 26/07/24.
//

import Foundation
import simd

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
