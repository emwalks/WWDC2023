//
//  FSMState.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

class FSMState {
    
    private(set) weak var fsm: FSM?
    
    init(_ fsm: FSM?) {
        self.fsm = fsm
    }
    
    func didBecomeActive() {
        fsm?.playbackStateAnnoucer.stateChanged(self)
    }
    
    func didResignActive() {
        
    }
    
    func notifyErrorObserver(_ observer: BBCSMPErrorObserver) {
        
    }
    
    func progressListenerAdded() {
        
    }
    
    func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        
    }
    
    var publicState: SMPPublicState {
        fatalError("\(#function) must be overridden in a derived class")
    }
    
    func attemptFailover(from error: BBCSMPError) {
        
    }
    
    func prepareToPlay() {
        
    }
    
    func loadPlayerItem() {
        
    }
    
    func itemProviderDidFailToLoadItem(_ error: BBCSMPError) {
        
    }
    
    func loadPlayerItemMetadataFailed(_ error: BBCSMPError) {
        
    }
    
    func itemLoaded(item: BBCSMPItem) {
        
    }
    
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func stop() {
        
    }
    
    func error(_ error: BBCSMPError) {
        
    }
    
    func suspend(player: BBCSMP) {
        
    }
    
    func seek(to time: TimeInterval, on player: BBCSMP) {
        
    }
    
    func set(targetRate: Rate) {
        
    }
    
    func decoderReady() {
        
    }
    
    func decoderPlaying() {
        
    }
    
    func decoderPaused() {
        
    }
    
    func decoderBuffering(_ isBuffering: Bool) {
        
    }
    
    func decoderDidProgress(to position: DecoderCurrentPosition) {
        
    }
    
    func decoderFailed() {
        
    }
    
    func decoderFinished() {
        
    }
    
    func decoderInterrupted() {
        
    }
    
}
