//
//  StockUIBackgroundManager.swift
//  BBCSMP
//
//  Created by Matt Mould on 23/11/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPStockUIBackgroundManager)
public class StockUIBackgroundManager: NSObject {

    private weak var smpControllable: BBCSMPControllable?
    private weak var smpObservable: BBCSMPPlayerObservable?
    private weak var backgroundStateProvider: BBCSMPBackgroundStateProvider?
    private var airplayActivationState: Bool?
    private var pipActivationState: Bool?
    private var currentAVType: BBCSMPAVType?
    private var currentPlaybackState: PlaybackState?

    @objc
    public init(smpControllable: BBCSMPControllable,
                smpObservable: BBCSMPPlayerObservable,
                backgroundStateProvider: BBCSMPBackgroundStateProvider) {
        self.smpControllable = smpControllable
        self.smpObservable = smpObservable
        self.backgroundStateProvider = backgroundStateProvider

        super.init()

        self.smpObservable?.add(observer: self)
        self.smpObservable?.add(pictureInPictureObserver: self)
        self.backgroundStateProvider?.add(observer: self)
        self.smpObservable?.add(stateObserver: self)
    }

    private func isLoadingOrPlaying(currentState: PlaybackState?) -> Bool {
        return
            (currentPlaybackState as? PlaybackStatePlaying != nil) || (currentPlaybackState as? PlaybackStateLoading != nil)
    }

}

extension StockUIBackgroundManager: BBCSMPItemObserver {
    public func itemUpdated(_ playerItem: BBCSMPItem) {
        currentAVType = playerItem.metadata().avType
    }
}

extension StockUIBackgroundManager: BBCSMPAirplayObserver {
    public func airplayAvailabilityChanged(_ available: NSNumber) {}

    public func airplayActivationChanged(_ active: NSNumber) {
        airplayActivationState = active.boolValue
    }
}

extension StockUIBackgroundManager: PictureInPictureObserver {
    public func didStartPictureInPicture() {
        pipActivationState = true
    }

    public func didStopPictureInPicture() {
        pipActivationState = false
    }
}

extension StockUIBackgroundManager: BBCSMPBackgroundObserver {
    public func playerEnteredBackgroundState() {
        guard let pipActivationState = pipActivationState,
              let airplayActivationState = airplayActivationState,
              let currentAVType = currentAVType else {
            return
        }
        if isLoadingOrPlaying(currentState: currentPlaybackState) &&
            !pipActivationState &&
            !airplayActivationState &&
            currentAVType == BBCSMPAVType.video {
            smpControllable?.pause()
        }
    }

    public func playerWillResignActive() {

    }

    public func playerEnteredForegroundState() {

    }

}

extension StockUIBackgroundManager: PlaybackStateObserver {
    public func state(_ state: PlaybackState) {
        currentPlaybackState = state
    }
}
