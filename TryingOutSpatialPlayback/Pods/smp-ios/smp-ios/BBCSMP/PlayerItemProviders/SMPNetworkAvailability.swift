//
//  NetworkAvailability.swift
//  SMP
//
//  Created by Rory Clear on 29/11/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

public protocol SMPNetworkAvailability {
    func registerNetworkAvailabilityCallback(_ callback: NetworkAvailabilityCallback)
}

public protocol NetworkAvailabilityCallback {
    
    func networkAvailable()
    func networkUnavailable()
}
