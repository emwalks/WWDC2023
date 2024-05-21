//
//  FSMRetryPreparingToPlayState.swift
//  SMP
//
//  Created by Matt Mould on 26/06/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMRetryPreparingToPlayState: FSMState {
    
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, actionOnPause: @escaping (_ state: FSMState) -> Void) {
        self.actionOnPause = actionOnPause
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .preparingToPlay()
    }

    override func decoderReady() {
        fsm?.announceDurationChange()
        fsm?.transition(to: FSMPlayerReadyState(fsm))
        if fsm?.autoplay ?? false {
            fsm?.decoder?.play()
        }
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = {
            self.fsm?.decoder?.scrub(toAbsoluteTime: time)
        }
    }
    
    override func play() {
        self.fsm?.autoplay = true
    }
    
    override func pause() {
        actionOnPause(FSMPausedRetryPreparingToPlayState(fsm, actionOnPause: actionOnPause))
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
    override func decoderPlaying() {
        fsm?.transition(to: FSMPlayingState(fsm))
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) { (_) in })
    }
    
}
