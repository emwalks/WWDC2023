//
//  FSMSuspendedState.swift
//  SMP
//
//  Created by Matt Mould on 18/01/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMSuspendedState: FSMState {
    
    override var publicState: SMPPublicState {
        .paused()
    }

    override func didResignActive() {
        self.fsm?.suspendMechanism.cancelPendingSuspendTransition()
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = { [unowned player] in
            player.scrub(to: time)
        }
    }
    
    override func play() {
        self.fsm?.stop()
        self.fsm?.autoplay = true
        self.fsm?.prepareToPlay()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
}
