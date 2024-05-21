//
//  MediaSelectorParser+Refinements.swift
//  BBCMediaSelectorClient
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 08/11/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

import Foundation

public extension MediaSelectorParser {
    
    @objc class var numberFormatter: NumberFormatter {
        return __createNumberFormatter
    }
    
    @objc class var dateFormatter: DateFormatter {
        return __createDateFormatter
    }
    
}
