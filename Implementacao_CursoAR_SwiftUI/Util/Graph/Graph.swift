//
//  Graph.swift
//  BubbleSound
//
//  Created by Luca Lacerda on 24/07/24.
//

import Foundation
import RealityKit
import SwiftUI

class Graph {
    
    //MARK: - Atributos do grafo
    var nodes: [Node] = []
    var paths: [Edge] = []
    
    var sceneAnchor: AnchorEntity?
    
    //MARK: - Funções do grafo
    
    //Devolve os paths de um node
    private func getPaths(node: Node) -> [Edge]? {
        let edges = paths.filter({$0.firstNode == node || $0.secondNode == node})
        if !edges.isEmpty {
            return edges
        } else {
            return nil
        }
    }
    
    private func addEdgeToSceneAnchor(edge: Edge) {
        guard let anchor = sceneAnchor else { return }
        
        anchor.addChild(edge)
    }
    
    private func addNodeToSceneAnchor(node: Node) {
        guard let anchor = sceneAnchor else { return }
        
        anchor.addChild(node)
    }
    
    private func removeEdgeToSceneAnchor(edge: Edge) {
        guard let anchor = sceneAnchor else { return }
        
        if anchor.children.contains(edge) {
            anchor.removeChild(edge)
        }
    }
    
    //MARK: - Primeira interação
    //Adicionar primeiro node do grafo
    func addFirstNode(id: UUID, type: SoundTypes, position: SIMD3<Float>) {
        if nodes.isEmpty {
            let node = Node(id: id, type: type)
            node.position = position
            nodes.append(node)
            addNodeToSceneAnchor(node: node)
            
        } else {
            print("not first node")
        }
    }
    
    //Pesquisa um node no grafo
    private func getNode(id: UUID) -> Node?{
        if let node = nodes.first(where: {$0.nodeId == id}) {
            return node
        } else {
            return nil
        }
    }
    
    //Retorna nodes desse tipo
    private func getNodes(type: SoundTypes) -> [Node]? {
        let nodes = nodes.filter({$0.type == type})
        if !nodes.isEmpty{
            return nodes
        } else {
            return nil
        }
    }
    
    //Verifica conexão
    private func verifyConnection(firstId: UUID, secondId: UUID) -> Bool{
        if self.paths.contains(where: {$0.firstNode.nodeId == firstId && $0.secondNode.nodeId == secondId}) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Adicionar node para o cena
    //Adicionar node no grafo
    func addNodeToGraph(idToAdd: UUID, idToConnect: UUID, typeToAdd: SoundTypes, position: SIMD3<Float>) -> Bool {
        if let nodeConnect = self.getNode(id: idToConnect){
            
            if let existence = self.getNode(id: idToAdd){
                
                return false
                
            } else {
                
                if nodeConnect.canConnect(){
                    
                    let nodeAdd = Node(id: idToAdd, type: typeToAdd)
                    nodeAdd.position = position
                    
                    addNodeToSceneAnchor(node: nodeAdd)
                    
                    let edge = Edge(firstNode: nodeConnect, secondNode: nodeAdd)
                    let edgeBack = Edge(firstNode: nodeAdd, secondNode: nodeConnect)
                    
                    addEdgeToSceneAnchor(edge: edge)
                    
                    paths.append(edge)
                    paths.append(edgeBack)
                    
                    nodes.append(nodeAdd)
                    
                    nodeConnect.removeConnection()
                    nodeAdd.removeConnection()
                    
                    return true
                    
                } else {
                    
                    return false
                    
                }
                
            }
            
            
        } else {
            
            return false
            
        }
        
    }
    
    //Adiciona uma conexão ao grafo
    func addConnection(idFirstNode: UUID, idSecondNode: UUID) -> Bool {
        
        guard idFirstNode != idSecondNode else { return false }
        guard let firstNode = self.getNode(id: idFirstNode) else { print("first node not found"); return false }
        guard let secondNode = self.getNode(id: idSecondNode) else { print("second node not found"); return false }
        
        if firstNode.canConnect() && secondNode.canConnect() && !self.verifyConnection(firstId: idFirstNode, secondId: idSecondNode) {
            
            let edge = Edge(firstNode: firstNode, secondNode: secondNode)
            let edgeBack = Edge(firstNode: secondNode, secondNode: firstNode)
            
            addEdgeToSceneAnchor(edge: edge)
            
            paths.append(edge)
            paths.append(edgeBack)
            
            firstNode.removeConnection()
            secondNode.removeConnection()
            
            return true
        }
        
        return false
        
    }
    
    //Remove uma conexão do grafo
    func removeConnection(idFirstNode: UUID, idSecondNode: UUID) -> Bool {
        
        guard let firstNode = self.getNode(id: idFirstNode) else { print("first node not found"); return false }
        guard let secondNode = self.getNode(id: idSecondNode) else { print("second node not found"); return false }
        
        if firstNode.connections != 2 && secondNode.connections != 2 {
            
            if let edge = paths.first(where: {($0.firstNode == firstNode && $0.secondNode == secondNode) || ($0.firstNode == secondNode && $0.secondNode == firstNode)}){
                removeEdgeToSceneAnchor(edge: edge)
            }
            if let edgeBack = paths.last(where: {($0.firstNode == firstNode && $0.secondNode == secondNode) || ($0.firstNode == secondNode && $0.secondNode == firstNode)}){
                removeEdgeToSceneAnchor(edge: edgeBack)
            }
            
            paths.removeAll(where: {($0.firstNode == firstNode && $0.secondNode == secondNode) || ($0.firstNode == secondNode && $0.secondNode == firstNode)})
            
            firstNode.addConnection()
            secondNode.addConnection()
            
            return true
        }
        
        return false
    }
    
    //Pega o próximo node da sequencia
    private func searchNext(actualNode: Node, sequence: [SoundTypes], sequenceIndex: Int, visitedNodes: [Node] ) -> [Node]? {
        
        if sequenceIndex >= sequence.count {
            return [actualNode]
        }
        
        guard var edges = self.getPaths(node: actualNode) else { return nil }
        edges = edges.filter({ $0.firstNode == actualNode && $0.secondNode.type == sequence[sequenceIndex]})
        var visited = visitedNodes
        visited.append(actualNode)
        
        if !edges.isEmpty {
            for edge in edges {
                if !visitedNodes.contains(where: {$0 == edge.secondNode}){
                    if var funcReturn = self.searchNext(actualNode: edge.secondNode, sequence: sequence, sequenceIndex: sequenceIndex + 1, visitedNodes: visited ) {
                        funcReturn.append(actualNode)
                        return funcReturn.reversed()
                    }
                }
            }
        }
        
        return nil
    }
    
    //Busca a sequencia
    func search(objectiveSequence: [SoundTypes]) -> [Node]? {
        
        guard let nodesToStart = self.getNodes(type: objectiveSequence.first!) else { return nil }
        
        for node in nodesToStart {
            if let sequence = self.searchNext(actualNode: node, sequence: objectiveSequence, sequenceIndex: 1, visitedNodes: []) {
                return sequence
            }
        }
        
        return nil
    }
    
    //printa o grafo
    func printGraph(){
        print("nodes\n")
        for node in self.nodes {
            print("\(node.type)")
        }
        
        print("\nPaths\n")
        for path in self.paths {
            print("\(path.firstNode.type) conectado a \(path.secondNode.type)")
        }
    }
}
