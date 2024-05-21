//
//  FSMPlayingState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMPlayingState: FSMState {
    
    override var publicState: SMPPublicState {
        .playing()
    }

    override func decoderPaused() {
        fsm?.transition(to: FSMPausedState(fsm))
    }

    override func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        let timeToReturnToWhenReady = player.time
        fsm?.actionWhenReady = { [unowned player] in
            guard let storedTime = timeToReturnToWhenReady else {return}
            player.scrub(to: storedTime.seconds)
        }
    }

    override func didBecomeActive() {
        fsm?.announceDurationChange()
        fsm?.pendingSeek()
        fsm?.periodicExecutor.start()
        fsm?.applyTargetRateOntoDecoder()
        
        super.didBecomeActive()
    }

    override func didResignActive() {
        fsm?.periodicExecutor.stop()
    }

    override func decoderBuffering(_ isBuffering: Bool) {
        if isBuffering {
            fsm?.autoplay = true
            fsm?.transition(to: FSMBufferingState(fsm))
        }
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.transition(to: FSMPlayingSeekingState(fsm))
        fsm?.decoder?.scrub(toAbsoluteTime: time)
    }

    override func progressListenerAdded() {
        fsm?.updateProgress()
    }
    
    override func prepareToPlay() {
        fsm?.transition(to: FSMPreparingToPlayState(fsm))
    }
    
    override func pause() {
        fsm?.decoder?.pause()
        fsm?.transition(to: FSMPausedState(fsm))
    }

    override func set(targetRate: Rate) {
        fsm?.applyTargetRateOntoDecoder()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func decoderFinished() {
        fsm?.decoder?.pause()
        fsm?.transition(to: FSMEndedState(fsm))
    }
    
    override func decoderInterrupted() {
        fsm?.transition(to: FSMInterruptedState(fsm, resumeWhenReady: true))
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) {[weak fsm] (retryItemState: FSMState) in
            fsm?.autoplay = false
            fsm?.transition(to: retryItemState)
        })
    }
    
}
