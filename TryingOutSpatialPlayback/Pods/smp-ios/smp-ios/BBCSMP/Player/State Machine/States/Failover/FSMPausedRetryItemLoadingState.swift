//
//  FSMRetryItemLoadingState.swift
//  SMP
//
//  Created by Shahnaz Hameed on 28/06/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMPausedRetryItemLoadingState: FSMState {

    let error: BBCSMPError
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, _ error: BBCSMPError, actionOnPause: @escaping (_ state: FSMState) -> Void) {
        self.error = error
        self.actionOnPause = actionOnPause
        
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .paused()
    }

    override func itemLoaded(item: BBCSMPItem) {
        error.recovered = true
        fsm?.announceError(error)
        fsm?.transition(to: FSMPausedRetryItemLoadedState(fsm, item: item, actionOnPause: actionOnPause))
    }
        
    override func play() {
        self.fsm?.autoplay = true
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error, actionOnPause: actionOnPause))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
}
