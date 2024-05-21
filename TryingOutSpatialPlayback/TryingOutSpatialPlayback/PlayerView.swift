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
// https://stackoverflow.com/questions/58034049/swiftui-how-to-properly-present-avplayerviewcontroller-modally
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-a-full-screen-modal-view-using-fullscreencover

struct PlayerView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AVPlayerViewController {

        let sampleHLSstream = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")

        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        let playerItem = AVPlayerItem(url: sampleHLSstream!)
        controller.player = AVPlayer()
        controller.player?.replaceCurrentItem(with: playerItem)
        controller.player?.play()
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
