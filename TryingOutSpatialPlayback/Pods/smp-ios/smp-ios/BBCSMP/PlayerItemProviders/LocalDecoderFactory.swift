//
//  LocalItemDecoderFactory.swift
//  BBCSMPTests
//
//  Created by Marc Jowett on 01/07/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

import Foundation

/// A type that produces a compatible ``Decoder`` for content obtained locally.
///
/// This factory will attempt to play any local URL.
/// See ADR-025 for further details about how this type will change in the future.
@objc(BBCSMPLocalDecoderFactory)
public protocol LocalDecoderFactory: NSObjectProtocol {
    
    /// Constructs an appropriate ``Decoder`` for decoding the contents of media at the local URL.
    ///
    /// The implementation of this method need only construct the resultant ``Decoder``. SMP will coordinate when the
    /// media will actually be played.
    ///
    /// - Parameters:
    ///   - url: The location of the local media resource to play.
    ///   - videoTrackSubscriber: A type that will consume `VideoTrack`s for rendering the visual output of the loaded
    ///                           media. Specify `nil` when the visual output is undesired or unnecessary (e.g. audio
    ///                           only content).
    ///
    /// - Returns: A ``Decoder`` that will be used by SMP for playback.
    func createDecoderForContent(atLocalURL url: URL, videoTrackSubscriber: VideoTrackSubscriber?) -> BBCSMPDecoder
    
}
