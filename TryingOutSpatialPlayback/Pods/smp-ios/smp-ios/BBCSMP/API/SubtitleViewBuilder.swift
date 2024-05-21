//
//  SubtitleViewBuilder.swift
//  SMP
//
//  Created by Andrew Wilson-Jones on 21/07/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPSubtitleViewBuilder)
public class SubtitleViewBuilder: NSObject {
    
    private let player: BBCSMPPlayerObservable
    private var configuration: SubtitlesUIConfiguration
    
    @objc
    public func with(configuration: SubtitlesUIConfiguration) -> SubtitleViewBuilder {
        self.configuration = configuration
        return self
    }
    
    @objc
    public init(player: BBCSMPPlayerObservable) {
        self.configuration = DefaultSubtitlesConfiguration()
        self.player = player
    }

    @objc(createSubtitleView)
    public func makeSubtitleView() -> UIView {
        let subtitleView = BBCSMPSubtitleView(frame: .zero)
        player.add(observer: subtitleView)
        subtitleView.configuration = configuration
        return subtitleView
    }
    
    private class DefaultSubtitlesConfiguration: NSObject, SubtitlesUIConfiguration {
        
        func minimumSubtitlesSize() -> Float {
            return 11
        }
        
    }
    
}
