//
//  FSMBufferingState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMBufferingState: FSMState {
    
    override var publicState: SMPPublicState {
        .buffering()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        fsm?.pendingSeek()
        fsm?.periodicExecutor.start()
    }

    override func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        let timeToReturnToWhenReady = player.time
        self.fsm?.autoplay = true
        fsm?.actionWhenReady = {[unowned player] in
            guard let storedTime = timeToReturnToWhenReady else {return}
            player.scrub(to: storedTime.seconds)
        }
    }

    override func decoderPaused() {
        fsm?.transition(to: FSMPausedState(fsm))
    }

    override func decoderReady() {
        fsm?.announceDurationChange()
        if fsm?.autoplay ?? false {
            fsm?.decoder?.play()
        }
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.transition(to: FSMBufferingSeekingState(fsm))
        fsm?.decoder?.scrub(toAbsoluteTime: time)
    }

    override func progressListenerAdded() {
        fsm?.updateProgress()
    }

    override func didResignActive() {
        fsm?.periodicExecutor.stop()
    }
    
    override func prepareToPlay() {
        fsm?.transition(to: FSMPreparingToPlayState(fsm))
    }
    
    override func pause() {
        fsm?.decoder?.pause()
        fsm?.transition(to: FSMPausedState(fsm))
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func decoderPlaying() {
        fsm?.transition(to: FSMPlayingState(fsm))
    }
    
    override func decoderBuffering(_ isBuffering: Bool) {
        if isBuffering {
            fsm?.transition(to: FSMBufferingState(fsm))
        }
    }
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) {[weak fsm] (retryItemState: FSMState) in
            fsm?.autoplay = false
            fsm?.transition(to: retryItemState)
        })
    }
    
}
