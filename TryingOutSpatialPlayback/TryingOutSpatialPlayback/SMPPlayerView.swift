//
//  SMPPlayerView.swift
//  TryingOutSpatialPlayback
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 07/07/2023.
//

import SwiftUI
import AVFoundation
import AVKit
import SMP

struct SMPPlayerView: UIViewControllerRepresentable {
    
    var player = BBCSMPPlayerBuilder().build()
    
    func makeUIViewController(context: Context) -> UIViewController {
    
        let playerViewController: VideoTrackSubscriber! = player.buildUserInterface().buildViewController()
        
        let playerItemProvider = MediaSelectorItemProviderBuilder(
            VPID: "bbc_one_hd",
            mediaSet: "mobile-phone-main",
            AVType: .video,
            streamType: .simulcast,
            avStatisticsConsumer: AVStatisticsConsumer()
        ).withVideoTrackSubscriber(playerViewController)
            .buildItemProvider()
        
        player.playerItemProvider = playerItemProvider

    
        return playerViewController as! UIViewController
    }
    
    func updateUIViewController(_ playerController: UIViewController, context: Context) { }
    
    
    
}

struct SMPPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SMPPlayerView()
    }
}

