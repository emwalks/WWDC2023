//
//  FSMIdleState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMIdleState: FSMState {

    let error: BBCSMPError?
    
    override var publicState: SMPPublicState {
        .idle()
    }

    init(_ fsm: FSM?, error: BBCSMPError?=nil) {
        self.error = error
        super.init(fsm)
    }

    override func loadPlayerItem() {
         fsm?.transition(to: FSMItemLoadingState(self.fsm))
    }

    override func loadPlayerItemMetadataFailed(_ error: BBCSMPError) {
        fsm?.announceError(error)
        fsm?.transition(to: FSMIdleState(fsm, error: error))
    }

    override func notifyErrorObserver(_ observer: BBCSMPErrorObserver) {
        guard let error = self.error else {return}
        fsm?.announceError(error)
    }

    override func prepareToPlay() {
        loadPlayerItem()
    }
    
    override func play() {
        self.fsm?.autoplay = true
        loadPlayerItem()
    }
    
    override func decoderDidProgress(to position: DecoderCurrentPosition) {
        fsm?.methodsNotMigratedToFSM?.setTimeOnPlayerContext(position)
    }
    
    override func decoderFailed() {
        fsm?.decoder?.pause()
        fsm?.decoder?.teardown()
    }
    
    override func attemptFailover(from error: BBCSMPError) {
        fsm?.transition(to: FSMRetryItemLoadingState(fsm, error) { (_) in })
    }
    
}
