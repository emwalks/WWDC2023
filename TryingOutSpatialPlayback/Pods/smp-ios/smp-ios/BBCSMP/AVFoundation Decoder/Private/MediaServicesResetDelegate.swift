//
//  MediaServicesListener.swift
//  SMP
//
//  Created by Chris Winstanley on 05/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

import Foundation
import AVKit

@objc(BBCSMPMediaServicesResetDelegate)
public protocol MediaServicesResetDelegate {
    func resetMediaPipelines(completionHandler: @escaping () -> Void)
}
