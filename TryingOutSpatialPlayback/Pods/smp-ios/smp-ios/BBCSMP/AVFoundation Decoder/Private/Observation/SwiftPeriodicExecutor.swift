//
//  SwiftPeriodicExecutor.swift
//  BBCSMP
//
//  Created by Matt Mould on 08/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPSwiftPeriodicExecutor)
public protocol SwiftPeriodicExecutor {
    func start()
    func stop()
}

@objc(BBCSMPSwiftPeriodicExecutorFactory)
public protocol SwiftPeriodicExecutorFactory {
    func create(period: TimeInterval, block: @escaping () -> Void) -> SwiftPeriodicExecutor
}

@objc(BBCSMPSwiftTimerBasedPeriodicExecutorFactory)
public class SwiftTimerBasedPeriodicExecutorFactory: NSObject, SwiftPeriodicExecutorFactory {
    public func create(period: TimeInterval, block: @escaping () -> Void) -> SwiftPeriodicExecutor {
        SwiftTimerBasedPeriodicExecutor(period: period, block: block)
    }
}

@objc(BBCSMPTimerBasedPeriodicExecutor)
public class SwiftTimerBasedPeriodicExecutor: NSObject, SwiftPeriodicExecutor {
    private var timer: Timer?
    private let block:() -> Void
    private let period: TimeInterval

    @objc
    public init(period: TimeInterval, block: @escaping () -> Void) {
        self.block = block
        self.period = period
        super.init()

    }

    public func start() {
        stop()
        invoke()
        timer = Timer.scheduledTimer(timeInterval: period, target: self, selector: (#selector((invoke))), userInfo: nil, repeats: true)    }

    public func stop() {
        timer?.invalidate()
    }

    @objc
    private func invoke() {
        block()
    }
}
