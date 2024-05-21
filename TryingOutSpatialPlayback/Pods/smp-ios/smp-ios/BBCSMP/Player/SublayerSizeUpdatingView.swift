//
//  SublayerSizeUpdatingView.swift
//  SMP
//
//  Created by Matt Mould on 10/11/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import UIKit

@objc(BBCSMPSublayerSizeUpdatingView)
public class SublayerSizeUpdatingView: UIView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { layer in
            layer.frame = bounds
        }
    }
}
