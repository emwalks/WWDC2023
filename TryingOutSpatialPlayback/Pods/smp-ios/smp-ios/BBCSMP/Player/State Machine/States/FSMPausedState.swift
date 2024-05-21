//
//  FSMPausedState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMPausedState: FSMState {
    
    override var publicState: SMPPublicState {
        .paused()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.fsm?.periodicExecutor.start()
        self.fsm?.suspendMechanism.evaluateSuspendRule()
        fsm?.pendingSeek()
    }

    override func didResignActive() {
        self.fsm?.suspendMechanism.cancelPendingSuspendTransition()
        self.fsm?.periodicExecutor.stop()
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.transition(to: FSMPausedSeekingState(fsm))
        fsm?.decoder?.scrub(toAbsoluteTime: time)
    }

    override func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        let timeToReturnToWhenReady = player.time
        fsm?.autoplay = false
        weak var weakReferenceToPlayer = player
        fsm?.actionWhenReady = {
            self.fsm?.pause()
            guard let storedTime = timeToReturnToWhenReady else {return}
            weakReferenceToPlayer?.scrub(to: storedTime.seconds)
        }
    }

    override func decoderInterrupted() {
        fsm?.transition(to: FSMInterruptedState(fsm, resumeWhenReady: false))
    }

    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMPausedRetryItemLoadingState(fsm, error) { (_) in })
    }

    override func progressListenerAdded() {
        fsm?.updateProgress()
    }
    
    override func prepareToPlay() {
        fsm?.transition(to: FSMPreparingToPlayState(fsm))
    }
    
    override func play() {
        fsm?.transition(to: FSMPlayingState(fsm))
        fsm?.decoder?.play()
        fsm?.applyTargetRateOntoDecoder()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func suspend(player: BBCSMP) {
        self.fsm?.formulateStateRestorationWhenRecovered(player: player)
        self.fsm?.transition(to: FSMSuspendedState(fsm))
    }
    
    override func decoderPlaying() {
        fsm?.transition(to: FSMPlayingState(fsm))
    }
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
}
