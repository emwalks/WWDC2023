//
//  FSMItemLoadingState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMItemLoadingState: FSMState {

    override var publicState: SMPPublicState {
        .loadingItem()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        guard let unwrappedPlayerItemProvider = fsm?.playerItemProvider else {return}
        fsm?.playerItemRequester.requestItem(itemProvider: unwrappedPlayerItemProvider,
                                                    success: { (item) in
            guard let resolvedItem = item else {
                let error = NSError(domain: "smp-ios", code: 0, userInfo: nil)
                self.fsm?.itemProviderDidFailToLoadItem(BBCSMPError(error, reason: .initialLoadFailed))
                return
            }
            self.fsm?.itemLoaded(item: resolvedItem)
        }, failure: { (error) in
            var errorReason = BBCSMPErrorEnumeration.mediaResolutionFailed
            let networkParseFailureErrorCode = 3840
            if error?._domain == NSCocoaErrorDomain && error?._code == networkParseFailureErrorCode {
                errorReason = BBCSMPErrorEnumeration.initialLoadFailed
            }
            if error?._code == 1073 {
                errorReason = BBCSMPErrorEnumeration.mediaResolutionFailedWithToken
            }
            let errorForSMP: Error
            if let itemProviderError = error {
                errorForSMP = itemProviderError
            } else {
                errorForSMP = NSError(domain: "smp-ios", code: 0, userInfo: nil)
            }
            self.fsm?.itemProviderDidFailToLoadItem(BBCSMPError(errorForSMP, reason: errorReason))
        })
    }

    override func itemLoaded(item: BBCSMPItem) {
        fsm?.transition(to: FSMItemLoadedState(fsm, item: item))
    }

    override func itemProviderDidFailToLoadItem(_ error: BBCSMPError) {
        fsm?.transition(to: FSMIdleState(fsm, error: error))
        fsm?.announceError(error)
        fsm?.methodsNotMigratedToFSM?.itemProviderDidFailToLoadItemWithError(error.error)
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
    
}
