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

enum GameplayError {
    case addConnection
    case removeConnection
    case limitOfNodes
    case limitOfSpace
}

enum GameState {
    case removingEdges
    case addNodes
    case connectNodes
}

enum GameStatus {
    case playing
    case winner
    case loser
}

struct ContentView : View {
    
    @State var gameState: GameState = .addNodes
    @State var nodeSoundType: SoundTypes = .moon
    @State var mySequence: [SoundTypes] = []
    @State var gameStatus: GameStatus = .playing
    
    var body: some View {
        ZStack {
            
            
            ARViewContainer(
                state: $gameState,
                nodeSoundType: $nodeSoundType,
                mySequence: $mySequence,
                gameStatus: $gameStatus
            ).edgesIgnoringSafeArea(.all)
            
            VStack{
                VStack{
                    Text("Sequência:")
                        .font(.headline)
                        .lineLimit(1)
                        
                    HStack{
                        ForEach(mySequence, id: \SoundTypes.id) { node in
                            soundNode(sound: node)
                        }
                    }
                }.padding()
                Spacer()
                
                if gameState == .addNodes {
                    HStack{
                        buttonCustomForSound(sound: .moon)
                        buttonCustomForSound(sound: .star)
                        buttonCustomForSound(sound: .triangle)
                        buttonCustomForSound(sound: .square)
                    }
                }
                
                HStack {
                    buttonCustom(text: "Add", state: .addNodes)
                    buttonCustom(text: "Remove", state: .removingEdges)
                    buttonCustom(text: "Connect", state: .connectNodes)
                }
            }
            
            if gameStatus == .winner {
                ZStack{
                    Color.white
                        .ignoresSafeArea()
                    Text("WINNER")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.purple)
                    
                        
                }
            }
            
        }
        .onAppear {
            mySequence = randomElement()
        }
    }
    
    func verifyColor(state: GameState) -> Color {
        if gameState == state {
            return Color.orange
        } else {
            return Color.gray
        }
    }
    
    @ViewBuilder func buttonCustom(text: String, state: GameState) -> some View {
        Button{
            gameState = state
        } label: {
            Text(text)
                .foregroundStyle(.white)
                .padding()
                .background(verifyColor(state: state))
                .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder func buttonCustomForSound(sound type: SoundTypes) -> some View {
        Button{
            nodeSoundType = type
        } label: {
            Image(systemName: type.image)
                .foregroundStyle(.white)
                .padding()
                .background{
                    Circle()
                        .foregroundStyle(type.color)
                }
                .opacity(nodeSoundType == type ? 1: 0.5)
        }
    }
    
    @ViewBuilder func soundNode(sound type: SoundTypes) -> some View {
        
        Image(systemName: type.image)
            .foregroundStyle(.white)
            .padding()
            .background{
                Circle()
                    .foregroundStyle(type.color)
            }
//            .saturation(0)
    }
    
    func randomElement() -> [SoundTypes] {
        var array = [SoundTypes]()
        for _ in 0..<5 {
            guard let randomSoundType = SoundTypes.allCases.randomElement() else { return [] }
            array.append(randomSoundType)
        }
        return array
    }
    
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var state: GameState
    @Binding var nodeSoundType: SoundTypes
    @Binding var mySequence: [SoundTypes]
    @Binding var gameStatus: GameStatus
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        context.coordinator.arView = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(ArCoordinator.createNewNode)))
        context.coordinator.setUpUI()
        arView.session.delegate = context.coordinator
        
        return arView
        
    }
    
    func makeCoordinator() -> ArCoordinator {
        ArCoordinator(
            state: $state,
            nodeSoundType: $nodeSoundType,
            mySequence: $mySequence,
            gameStatus: $gameStatus
        )
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

class ArCoordinator: NSObject, ARSessionDelegate {
    
    @Binding var state: GameState
    @Binding var nodeSoundType: SoundTypes
    @Binding var mySequence: [SoundTypes]
    @Binding var gameStatus: GameStatus
    
    var nodesToConnect = [Node]()
    
    init(
        state: Binding<GameState>,
        nodeSoundType: Binding<SoundTypes>,
        mySequence: Binding<[SoundTypes]>,
        gameStatus: Binding<GameStatus>
    ) {
        self._state = state
        self._nodeSoundType = nodeSoundType
        self._mySequence = mySequence
        self._gameStatus = gameStatus
    }
    
    var arView: ARView?
    
    var graph: Graph = Graph()
    var pastPositions = [simd_double3]()
    var minDistance = 0.3
    var movementCompleted: Bool = false {
        willSet{
            if newValue == true {
                print("Value changed")
                executeEndOfRoundActions()
            }
        }
    }
    
    @objc func createNewNode(_ recognizer: UITapGestureRecognizer){
        guard let view = self.arView else { return }
        
        let tapLocation = recognizer.location(in: view)
        
        switch state {
        case .removingEdges:
            if let entity = view.entity(at: tapLocation) as? Edge {
                movementCompleted = graph.removeConnection(
                    idFirstNode: entity.firstNode.nodeId,
                    idSecondNode: entity.secondNode.nodeId
                )
            }
        case .addNodes:
            if let entity = view.entity(at: tapLocation) as? Node {
                
                let currentPosition = entity.position
                var newPosition: SIMD3<Double>
                var validPosition: Bool = false
                var repeatCases: Int = 0
                
                repeat {
                    newPosition = SIMD3<Double>(
                        x: Double(currentPosition.x) + Double.random(in: -0.3...0.3),
                        y: Double(currentPosition.y) + [0.3, -0.3].randomElement()!,
                        z: Double(currentPosition.z) + Double.random(in: -0.3...0.3)
                    )
                    
                    if repeatCases > 250 {
                        return
                    }
                    
                    if newPosition.y > 0 {
                        validPosition = pastPositions.allSatisfy { simd_distance($0, newPosition) > minDistance }
                    }
                    repeatCases += 1
                    
                } while !validPosition
                
                pastPositions.append(newPosition)
                
                movementCompleted = graph.addNodeToGraph(
                    idToAdd: .init(),
                    idToConnect: entity.nodeId,
                    typeToAdd: nodeSoundType,
                    position: .init(Float(newPosition.x), Float(newPosition.y), Float(newPosition.z))
                )
            }
        case .connectNodes:
            if let entity = view.entity(at: tapLocation) as? Node {
                entity.model?.materials = [SimpleMaterial(color: .gray, isMetallic: false)]
                nodesToConnect.append(entity)
                
                if nodesToConnect.count == 2 {
                    movementCompleted = graph.addConnection(
                        idFirstNode: nodesToConnect[0].nodeId,
                        idSecondNode: nodesToConnect[1].nodeId
                    )
                    
                    nodesToConnect.forEach { node in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                            node.model?.materials = [SimpleMaterial(color: node.type.uicolor, roughness: 0.1, isMetallic: false)]
                        }
                    }
                    nodesToConnect.removeAll()
                }
            }
        }
        
    }
    
    func setUpUI() {
        let anchor = AnchorEntity(plane: .horizontal)
        
        graph.sceneAnchor = anchor
        
        let nodeID = UUID.init()
        
        graph.addFirstNode(
            id: nodeID,
            type: nodeSoundType,
            position: .zero
        )
        
        pastPositions.append(.zero)
        arView?.scene.addAnchor(anchor)
        
    }
    
    func executeEndOfRoundActions(){
        
        guard let _ = graph.search(objectiveSequence: mySequence) else { return }
        
        gameStatus = .winner
    }
    
}

