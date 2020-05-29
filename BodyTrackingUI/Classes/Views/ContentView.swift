//
//  ContentView.swift
//  RealityUI
//
//  Created by Gene Backlin on 5/28/20.
//  Copyright © 2020 Gene Backlin. All rights reserved.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @EnvironmentObject var data: ARDataModel
    var body: some View {
        ARDisplayView()
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
