//
//  TimeBasedBackOffManager.swift
//  config-service
//
//  Created by Sabrina Tardio on 01/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

class TimeBasedBackOffManager: BackOffManager {
    private let persister: Persister
    private let clock: Clock
    private let backOffTimeInterval: TimeInterval
    private let key: String
    
    init(with persister: Persister = UserDefaultsPersister(),
         backOffTimeInterval: TimeInterval = 300,
         clock: Clock = DateClock(),
         key: String = "BackOff") {
        self.persister = persister
        self.backOffTimeInterval = backOffTimeInterval
        self.clock = clock
        self.key = key
    }
    
    func isBackOff() -> Bool {
        guard let startTime: Double = persister.read(key: key) else { return false }
        //remove magc number inject
        return clock.timeIntervalSince1970 <= (startTime + backOffTimeInterval)
    }
    
    func startBackOff(){
        persister.save(key:key, object:clock.timeIntervalSince1970)
    }
}

protocol Clock {
    var timeIntervalSince1970: TimeInterval { get }
}

class DateClock: Clock {
    var timeIntervalSince1970: TimeInterval = Date().timeIntervalSince1970
}
