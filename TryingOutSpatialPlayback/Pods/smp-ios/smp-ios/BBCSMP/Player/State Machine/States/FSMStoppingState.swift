//
//  FSMStoppingState.swift
//  SMP
//
//  Created by Matt Mould on 20/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMStoppingState: FSMState {
    
    override var publicState: SMPPublicState {
        .stopping()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        fsm?.transition(to: FSMIdleState(fsm))
    }
    
}
