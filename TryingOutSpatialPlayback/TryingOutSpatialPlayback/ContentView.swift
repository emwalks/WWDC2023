//
//  ContentView.swift
//  TryingOutSpatialPlayback
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/07/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationLink("AV Player VC") {
                // AVPlayerViewControllerView
            }
                .padding()
            //default padding is useful as it will be platform specific - eg watch etc
                .padding()
                .navigationTitle("Spatial Playback")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
