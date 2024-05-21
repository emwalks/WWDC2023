//
//  FSMRetryItemLoadedState.swift
//  SMP
//
//  Created by Matt Mould on 26/06/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMRetryItemLoadedState: FSMState {
    
    let item: BBCSMPItem
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, item: BBCSMPItem, actionOnPause: @escaping (_ state: FSMState) -> Void) {
        self.item = item
        self.actionOnPause = actionOnPause
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
        fsm?.transition(to: FSMRetryPreparingToPlayState(fsm, actionOnPause: actionOnPause))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = {
            self.fsm?.decoder?.scrub(toAbsoluteTime: time)
        }
    }
    
}
