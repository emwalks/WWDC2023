//
//  MediaSelectorDecoderFactory.swift
//  SMP
//
//  Created by Marc Jowett on 22/06/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

import Foundation

/// A type that produces a compatible ``Decoder`` for content mediated through Media Selector.
///
/// For an interim period, this factory will function for both HTTP Live Streaming media and progressive MP4 streaming.
/// See ADR-025 for further details about how this type will change in the future.
@objc(BBCSMPMediaSelectorDecoderFactory)
public protocol MediaSelectorDecoderFactory: NSObjectProtocol {
    
    /// Constructs an appropriate ``Decoder`` for decoding the contents of media at the remote URL.
    ///
    /// The implementation of this method need only construct the resultant ``Decoder``. SMP will coordinate when the
    /// media will actually be played.
    ///
    /// - Parameters:
    ///   - url: The location of the remote media resource to play. This typically designates a HTTP Live Streaming
    ///          playlist (.m3u8).
    ///   - videoTrackSubscriber: A type that will consume `VideoTrack`s for rendering the visual output of the loaded
    ///                           media. Specify `nil` when the visual output is undesired or unnecessary (e.g. audio
    ///                           only content).
    ///
    /// - Returns: A ``Decoder`` that will be used by SMP for playback.
    func createDecoderForPlaylist(atURL url: URL, videoTrackSubscriber: VideoTrackSubscriber?) -> BBCSMPDecoder
    
}
