//
//  FSMItemLoadedState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMItemLoadedState: FSMState {
    let item: BBCSMPItem

    init(_ fsm: FSM?, item: BBCSMPItem) {
        self.item = item
        super.init(fsm)
    }
    
    override var publicState: SMPPublicState {
        .itemLoaded()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.fsm?.methodsNotMigratedToFSM?.itemProviderDidLoadItem(self.item)
    }

    override func prepareToPlay() {
        fsm?.transition(to: FSMPreparingToPlayState(fsm))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = {
            self.fsm?.decoder?.scrub(toAbsoluteTime: time)
        }
    }
    
}
