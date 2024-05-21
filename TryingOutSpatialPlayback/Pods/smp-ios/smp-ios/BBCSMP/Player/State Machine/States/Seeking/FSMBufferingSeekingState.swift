//
//  FSMBufferingSeekingState.swift
//  SMP
//
//  Created by Matt Mould on 13/03/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMBufferingSeekingState: FSMState {

    override var publicState: SMPPublicState {
        .buffering()
    }

    override func decoderPlaying() {
        fsm?.transition(to: FSMPlayingState(fsm))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.pendingSeek = { [weak player, weak fsm] in
            player?.scrub(to: time)
            fsm?.pendingSeek = {}
        }

    }

    override func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        let timeToReturnToWhenReady = player.time
        fsm?.actionWhenReady = {[weak player] in
            guard let storedTime = timeToReturnToWhenReady else {return}
            player?.scrub(to: storedTime.seconds)
        }
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func decoderBuffering(_ isBuffering: Bool) {
        if isBuffering {
            fsm?.transition(to: FSMBufferingState(fsm))
        }
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) { (_) in })
    }
    
}
