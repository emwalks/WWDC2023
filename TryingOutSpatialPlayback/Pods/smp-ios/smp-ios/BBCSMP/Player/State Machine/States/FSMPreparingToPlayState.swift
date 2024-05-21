//
//  FSMPreparingToPlayState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMPreparingToPlayState: FSMState {
    
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

    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) {[weak fsm] (_ state: FSMState) in
             fsm?.methodsNotMigratedToFSM?.stop()
        })
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = { [unowned player] in
            player.scrub(to: time)
        }
    }
    
    override func play() {
        self.fsm?.autoplay = true
    }
    
    override func pause() {
        fsm?.methodsNotMigratedToFSM?.stop()
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
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
}
