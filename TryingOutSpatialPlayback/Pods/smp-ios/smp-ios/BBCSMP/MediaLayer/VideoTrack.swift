//
//  VideoTrack.swift
//  SMP
//
//  Created by Peter Bloxidge on 09/09/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import QuartzCore

/// Represents the visual component of a presentation.
///
/// Your app receives a `VideoTrack` by providing a `VideoTrackSubscriber` to an item provider that supports visual
/// content. The track may then be used to insert the visual portion of the media presentation into a view.
@objc(BBCSMPVideoTrack)
public protocol VideoTrack: NSObjectProtocol {
    
    /// The layer in which the visual buffer of the video will be written to.
    ///
    /// Clients may insert this layer into their visual tree in order to present the video track of the presentation.
    /// The layer can be scaled, transformed, and animated as desired.
    var outputLayer: CALayer { get }
    
    /// Specifies how the contents of the `outputLayer` are rendered relative to the bounds of the layer.
    var videoScale: VideoTrackScale { get set }
    
    /// Registers a closure to be invoked when the frame of the video within the `outputLayer` changes.
    ///
    /// The frame of the video is a subset of the bounds of the `outputLayer`, representing the area in which the
    /// video is being presented. This frame should be used to position content that is relative to the video itself,
    /// such as positional subtitles.
    ///
    /// The `changeHandler` will be invoked exactly once at registration time with the current frame of the video. It
    /// will then be invoked zero or more times as the frame changes during the presentation.
    ///
    /// - Important:
    /// The frame of the video should not be assumed to be the same as the bounds of the `outputLayer`, as there may
    /// be some pillar or letter boxing to accomodate for different screen sizes.
    ///
    /// - Parameter changeHandler: A closure that will consume the frame of the video.
    func observeVideoFrame(changeHandler: @escaping (CGRect) -> Void)
    
}
