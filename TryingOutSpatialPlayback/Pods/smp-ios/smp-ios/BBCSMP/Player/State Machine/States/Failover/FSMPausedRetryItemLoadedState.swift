//
//  FSMRetryItemPausedLoadedState.swift
//  SMP
//
//  Created by Shahnaz Hameed on 09/07/2019.
//  Copyright © 2019 BBC. All rights reserved.
//

import Foundation

class FSMPausedRetryItemLoadedState: FSMState {
    
    let item: BBCSMPItem
    let actionOnPause: (_ state: FSMState) -> Void

    init(_ fsm: FSM?, item: BBCSMPItem, actionOnPause: @escaping (_ states: FSMState) -> Void) {
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
        fsm?.transition(to: FSMPausedRetryPreparingToPlayState(fsm, actionOnPause: actionOnPause))
    }

    override func seek(to time: TimeInterval, on player: BBCSMP) {
        fsm?.actionWhenReady = {
            self.fsm?.decoder?.scrub(toAbsoluteTime: time)
        }
    }
    
}
