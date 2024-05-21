//
//  HTTPClientNetworkAvailability.swift
//  SMP
//
//  Created by Jonas Atta Boateng on 30/11/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

public class HTTPClientNetworkAvailability: SMPNetworkAvailability {
    
    private var networkAvailable: Bool = true {
        didSet {
            if oldValue != networkAvailable {
                self.notifyAvailability()
            }
        }
    }
    
    private var reachability: HTTPClient.Reachability?
    private var networkAvailabilityCallback: NetworkAvailabilityCallback?
    
    deinit {
        reachability?.stopNotifier()
    }
    
    public convenience init() {
        self.init(reachability: .forInternetConnection)
    }
    
    public init(reachability: HTTPClient.Reachability?) {
        self.reachability = reachability
        reachability?.startNotifier()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NSNotification.Name.ReachabilityChanged,
                                               object: nil)
    }
    
    public func registerNetworkAvailabilityCallback(_ callback: NetworkAvailabilityCallback) {
        networkAvailabilityCallback = callback
        notifyAvailability()
    }
    
    @objc private func reachabilityChanged() {
        networkAvailable = (reachability?.currentReachabilityStatus != .notReachable)
    }
    
    private func notifyAvailability() {
        if networkAvailable {
            networkAvailabilityCallback?.networkAvailable()
        } else {
            networkAvailabilityCallback?.networkUnavailable()
        }
    }
    
}
