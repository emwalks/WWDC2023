//
//  FSMErrorState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMErrorState: FSMState {

    let error: BBCSMPError

    init(_ fsm: FSM?, _ error: BBCSMPError) {
        self.error = error
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .error()
    }

    override func notifyErrorObserver(_ observer: BBCSMPErrorObserver) {
        observer.errorOccurred(error)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.fsm?.announceError(error)
    }

    override func prepareToPlay() {
        self.fsm?.loadPlayerItem()
    }

    override func loadPlayerItem() {
        fsm?.transition(to: FSMItemLoadingState(self.fsm))
    }
    
    override func play() {
        self.fsm?.autoplay = true
        self.fsm?.loadPlayerItem()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func error(_ error: BBCSMPError) {
        fsm?.transition(to: FSMErrorState(fsm, error))
    }
    
}
