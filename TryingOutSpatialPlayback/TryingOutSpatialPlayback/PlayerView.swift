//
//  PlayerView.swift
//  TryingOutSpatialPlayback
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/07/2023.
//

import SwiftUI
import AVFoundation
import AVKit

// https://developer.apple.com/videos/play/wwdc2023/10070/

struct PlayerView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AVPlayerViewController {

        let sampleHLSstream = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")

        let controller = AVPlayerViewController()
        let playerItem = AVPlayerItem(url: sampleHLSstream!)
        controller.player = AVPlayer()
        controller.player?.replaceCurrentItem(with: playerItem)
        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
