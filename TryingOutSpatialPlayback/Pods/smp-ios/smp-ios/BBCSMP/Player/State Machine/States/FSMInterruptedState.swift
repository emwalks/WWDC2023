//
//  FSMStateInterrupted.swift
//  SMP
//
//  Created by Tim Condon on 24/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMInterruptedState: FSMState {

    let resumeWhenReady: Bool

    init(_ fsm: FSM?, resumeWhenReady: Bool) {
        self.resumeWhenReady = resumeWhenReady
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .paused()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        fsm?.periodicExecutor.start()
    }

    override func decoderReady() {
        if resumeWhenReady && fsm?.interruptionEndedBehaviour == .autoresume {
            self.fsm?.decoder?.play()
        }
    }

    override func progressListenerAdded() {
        fsm?.updateProgress()
    }

    override func didResignActive() {
        fsm?.periodicExecutor.stop()
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
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFinished() {
        fsm?.transition(to: FSMEndedState(fsm))
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) {[weak fsm] (retryItemState: FSMState) in
            fsm?.transition(to: retryItemState)
        })
    }
    
}
