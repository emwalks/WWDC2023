//
//  ProgressObserver.swift
//  SMP
//
//  Created by Matt Mould on 05/05/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

/**
 Class which received the progress updates.
 The progress callbacks are currently invoked on the main thread as when the
 periodic time observer is added to AVPlayer we specify that callbacks are made
 to the main queue.
*/
@objc(BBCSMPProgressObserver)
public protocol ProgressObserver {
    @objc(progress:)
    func progress(mediaProgress: MediaProgress)
}

/**
- For a VOD asset when the user is 20 minutes into a 45 minute asset this would be defined as start: 0, end: 45 minutes, position 20 minutes.
- For a live asset when it is 4pm and the user has rewound ten minutes and where the live rewind window is two hours it would be start: 14:00 (as time since 1970), end: 16:00 (as time since 1970), and position 15:50 (as time since 1970).
*/
@objc(BBCSMPMediaProgress)
public class MediaProgress: NSObject {
    @objc public let mediaPosition: MediaPosition
    @objc public let startPosition: MediaPosition
    @objc public let endPosition: MediaPosition

    @objc public init(startPosition: MediaPosition, endPosition: MediaPosition, mediaPosition: MediaPosition) {
        self.mediaPosition = mediaPosition
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
}

@objc(BBCSMPMediaPosition)
public class MediaPosition: NSObject {
    @objc public let seconds: TimeInterval

    @objc public init(seconds: TimeInterval) {
        self.seconds = seconds
    }
}
