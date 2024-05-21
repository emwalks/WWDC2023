//
//  FSMPlayerReadyState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMPlayerReadyState: FSMState {
    
    override var publicState: SMPPublicState {
        .playerReady()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        let localActionWhenReady = fsm?.actionWhenReady
        fsm?.actionWhenReady = {}
        localActionWhenReady?()
        fsm?.periodicExecutor.start()
    }

    override func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        let timeToReturnToWhenReady = player.time
        weak var weakReferenceToPlayer = player
        fsm?.actionWhenReady = {
            guard let storedTime = timeToReturnToWhenReady else {return}
            weakReferenceToPlayer?.scrub(to: storedTime.seconds)
        }
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.transition(to: FSMReadySeekingState(fsm))
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
    
    override func play() {
        self.fsm?.decoder?.play()
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
