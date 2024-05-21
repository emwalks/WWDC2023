//
//  Rate.swift
//  SMP
//
//  Created by Connor Ford on 28/04/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPRate)
public class Rate: NSObject {
    let floatValue: Float

    @objc(initWithFloat:)
    public init(_ floatValue: Float) {
        self.floatValue = floatValue
    }
}
