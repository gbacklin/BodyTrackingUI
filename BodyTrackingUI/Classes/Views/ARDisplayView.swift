//
//  ARDisplayView.swift
//  RealityUI
//
//  Created by Gene Backlin on 5/28/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARDisplayView: View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        ARDataModel.shared.arView.session.delegate = context.coordinator
        return ARDataModel.shared.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(self, anchor: ARDataModel.shared.characterAnchor, model: "character/apple_robot")
    }
}

#if DEBUG
struct ARDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ARDisplayView()
    }
}
#endif

