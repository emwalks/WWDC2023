//
//  FSMPausedSeekingState.swift
//  SMP
//
//  Created by Matt Mould on 08/03/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMReadySeekingState: FSMState {

    override var publicState: SMPPublicState {
        .playerReady()
    }

    override func decoderPlaying() {
        fsm?.transition(to: FSMPlayingState(fsm))
    }

    override func decoderPaused() {
        fsm?.transition(to: FSMPlayerReadyState(fsm))
    }
    
    override func play() {
        fsm?.decoder?.play()
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
}
