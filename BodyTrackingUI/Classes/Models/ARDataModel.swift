//
//  ARDataModel.swift
//  RealityUI
//
//  Created by Gene Backlin on 5/28/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import ARKit
import RealityKit
import Combine

public final class ARDataModel: ObservableObject {
    static var shared = ARDataModel()
    
    @Published var arView: ARView!
    
    var character: BodyTrackedEntity?
    var characterOffset: SIMD3<Float> = [0, 0, 0]
    
    var arVC: ARViewContainer!
    var characterAnchor = AnchorEntity()
    
    init() {
        arView = ARView(frame: .zero)
    }
    
    func loadSkeleton(model: String) {
        initBodyTracking(view: arView)
        loadModel(model: model)
    }
    
    func initBodyTracking(view: ARView) {
        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        view.environment.lighting.intensityExponent = 2.15
        view.session.run(configuration)
        view.scene.addAnchor(characterAnchor)
    }
    
    func loadModel(model: String) {
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: model).sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
}

class ARDelegateHandler: NSObject, ARSessionDelegate {
    var isInitialUpdate = true
    
    init(_ control: ARViewContainer, anchor: AnchorEntity, model: String) {
        super.init()
        
        ARDataModel.shared.arVC = control
        ARDataModel.shared.characterAnchor = anchor
        ARDataModel.shared.characterOffset = [0, 0, 0]
        ARDataModel.shared.loadSkeleton(model: model)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if isInitialUpdate {
            isInitialUpdate = false
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        }
        
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            ARDataModel.shared.characterAnchor.position = bodyPosition + ARDataModel.shared.characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            ARDataModel.shared.characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
            if let character = ARDataModel.shared.character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                ARDataModel.shared.characterAnchor.addChild(character)
            }
        }
    }
}
