//
//  FSMRetryPausedPreparingToPlayState.swift
//  SMP
//
//  Created by Shahnaz Hameed on 09/07/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMPausedRetryPreparingToPlayState: FSMState {
    
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, actionOnPause: @escaping (_ states: FSMState) -> Void) {
        self.actionOnPause = actionOnPause
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .paused()
    }

    override func decoderReady() {
        fsm?.announceDurationChange()
        fsm?.transition(to: FSMPlayerReadyState(fsm))
    }

    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMPausedRetryItemLoadingState(fsm, error, actionOnPause: actionOnPause))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = {
            self.fsm?.decoder?.scrub(toAbsoluteTime: time)
        }
    }

    override func play() {
        self.fsm?.autoplay = true
        fsm?.transition(to: FSMRetryPreparingToPlayState(fsm, actionOnPause: actionOnPause))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
}
