//
//  VideoTrackSubscriber.swift
//  SMP
//
//  Created by Peter Bloxidge on 09/09/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

/// A recipient of a `VideoTrack`.
///
/// This protocol formulates the core communication method of the Media Layer bridge. You provide a type that conforms
/// to this protocol to an item provider that supports visual content, and later receive a `VideoTrack` to consume.
@objc(BBCSMPVideoTrackSubscriber)
public protocol VideoTrackSubscriber: NSObjectProtocol {
    
    /// Tells the receiver a new `VideoTrack` is available for consumption.
    ///
    /// The subscriber should expect to receive this message some time in the future as the presentation is being
    /// prepared. It may then receive new `VideoTrack`s for other presentations, such as playing multiple items
    /// sequentially. The implementation of this method should ensure the output layer is correctly positioned on-screen
    /// to present the media.
    ///
    /// - Important:
    /// Re-entrant calls into this method may produce different `VideoTrack`s which contain the same `outputLayer` as an
    /// optimisation based on the type of media being decoded. Your app should ensure that when receiving a new layer,
    /// the previous layer is removed from the visual tree before inserting the new layer. Your app does not need to
    /// remove and re-insert the same layer.
    ///
    /// - Note:
    /// Your app may retain the provided `VideoTrack` until the next call to `videoTrackAvailable(_:)` in order to
    /// utilise other behaviour on the track (e.g. scaling adjustment).
    ///
    /// - Parameter videoTrack: The `VideoTrack` containing the output buffer for the current visual track.
    func videoTrackAvailable(_ videoTrack: VideoTrack)
    
}
