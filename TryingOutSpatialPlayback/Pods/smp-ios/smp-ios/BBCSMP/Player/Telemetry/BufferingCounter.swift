//
//  BufferingCounter.swift
//  SMP
//
//  Created by Sabrina Tardio on 09/04/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPBufferingCounter)
public class BufferingCounter: NSObject {
    private weak var delegate: BufferingCounterDelegate?
    fileprivate var state: BufferingStates = NotWaitingForBuffering()
    
    @objc
    public init(delegate: BufferingCounterDelegate) {
        self.delegate = delegate
    }
    
    @objc
    public func changeState(stateSMP: BBCSMPStateEnumeration) {
        switch stateSMP {
        case .playing, .paused, .stopping:
            state.bufferingEnded()
            self.state = WaitingForBuffering(counterDelegate: delegate!, bufferingCounter: self)
        case .buffering:
            self.state.bufferingStarted()
        default:
            break
        }
    }
    
    @objc
    public func seeking() {
        state.seeking()
    }
}

private protocol BufferingStates {
    func bufferingStarted()
    func bufferingEnded()
    func seeking()
}

private struct NotWaitingForBuffering: BufferingStates {
    func bufferingEnded() {}
    func bufferingStarted() {}
    func seeking() {}
}

private struct WaitingForBuffering: BufferingStates {
    weak var counterDelegate: BufferingCounterDelegate?
    let bufferingCounter: BufferingCounter
    
    init(counterDelegate: BufferingCounterDelegate, bufferingCounter: BufferingCounter) {
        self.counterDelegate = counterDelegate
        self.bufferingCounter = bufferingCounter
    }
    func bufferingStarted() {
        counterDelegate?.bufferingStarted()
        bufferingCounter.state = Buffering(counterDelegate: counterDelegate!, bufferingCounter: bufferingCounter)
    }
    func bufferingEnded() {}
    func seeking() {
        self.bufferingCounter.state = NotWaitingForBuffering()
    }

}

private struct Buffering: BufferingStates {
    weak var counterDelegate: BufferingCounterDelegate?
    let bufferingCounter: BufferingCounter
    
    init(counterDelegate: BufferingCounterDelegate, bufferingCounter: BufferingCounter) {
        self.counterDelegate = counterDelegate
        self.bufferingCounter = bufferingCounter
    }
    
    func bufferingStarted() {}
    func bufferingEnded() {
        counterDelegate?.bufferingEnded()
    }
    func seeking() {
        counterDelegate?.bufferingEnded()
        bufferingCounter.state = NotWaitingForBuffering()
    }

}

@objc(BBCSMPBufferingCounterDelegate)
public protocol BufferingCounterDelegate: AnyObject {
    func bufferingStarted()
    func bufferingEnded()
}
