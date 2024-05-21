//
//  FSMEndedState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMEndedState: FSMState {
    
    override var publicState: SMPPublicState {
        .ended()
    }
    
    override func play() {
        fsm?.methodsNotMigratedToFSM?.stop()
        fsm?.play()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }

}
