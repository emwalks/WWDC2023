//
//  FSMRetryItemLoadingState.swift
//  SMP
//
//  Created by Shahnaz Hameed on 28/06/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMRetryItemLoadingState: FSMState {

    let error: BBCSMPError
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, _ error: BBCSMPError, actionOnPause: @escaping (_ state: FSMState) -> Void) {
        self.error = error
        self.actionOnPause = actionOnPause
        
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .buffering()
    }

    override func itemLoaded(item: BBCSMPItem) {
        error.recovered = true
        fsm?.announceError(error)
        fsm?.transition(to: FSMRetryItemLoadedState(fsm, item: item, actionOnPause: actionOnPause))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = { [unowned player] in
            player.scrub(to: time)
        }
    }
    
    override func pause() {
        actionOnPause(FSMPausedRetryItemLoadingState(fsm, error, actionOnPause: actionOnPause))
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
}
