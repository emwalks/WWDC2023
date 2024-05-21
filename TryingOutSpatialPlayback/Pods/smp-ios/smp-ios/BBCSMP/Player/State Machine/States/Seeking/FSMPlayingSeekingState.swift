//
//  FSMPlayingSeeingState.swift
//  SMP
//
//  Created by Matt Mould on 08/03/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMPlayingSeekingState: FSMState {

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
        weak var weakReferenceToPlayer = player
        fsm?.actionWhenReady = {
            self.fsm?.play()
            guard let storedTime = timeToReturnToWhenReady else {return}
            weakReferenceToPlayer?.scrub(to: storedTime.seconds)
        }
    }
    
    override func pause() {
        fsm?.decoder?.pause()
        fsm?.transition(to: FSMPausedSeekingState(fsm))
    }
    
    override func stop() {
        fsm?.transition(to: FSMStoppingState(fsm))
    }
    
    override func decoderBuffering(_ isBuffering: Bool) {
        if isBuffering {
            fsm?.transition(to: FSMBufferingState(fsm))
        }
    }
    
    override func decoderFinished() {
        fsm?.decoder?.pause()
        fsm?.transition(to: FSMEndedState(fsm))
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) { (_) in })
    }
    
}
