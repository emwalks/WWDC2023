//
//  DecoderRate.swift
//  SMP
//
//  Created by Matt Mould on 08/06/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPDecoderRate)
public class DecoderRate: NSObject {
    @objc public let floatValue: Float

    @objc(initWithFloat:)
    public init(_ floatValue: Float) {
        self.floatValue = floatValue
    }
}
