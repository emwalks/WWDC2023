//
//  NetworkSensitiveConnectionResolver.swift
//  SMP
//
//  Created by Rory Clear on 29/11/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

public class NetworkSensitiveConnectionResolver: NSObject, BBCSMPMediaSelectorConnectionResolver {
    
    private var networkAvailability: SMPNetworkAvailability
    private var isNetworkAvailable = false
    private var failoverCallback: (() -> Void)?
    
    public init(networkAvailability: SMPNetworkAvailability) {
        self.networkAvailability = networkAvailability
        super.init()
        
        let networkCallback = BlockBasedNetworkAvailabilityCallback(onNetworkAvailable: { [weak self] in
            self?.isNetworkAvailable = true
            self?.failoverCallback?()
        }, onNetworkUnavailable: { [weak self] in
            self?.isNetworkAvailable = false
            self?.failoverCallback = nil
        })
        
        networkAvailability.registerNetworkAvailabilityCallback(networkCallback)
    }
    
    public func resolvePlayerItem(
        _ playerItem: BBCSMPItem,
        usingPlayerItemCallback callback: @escaping (BBCSMPItem) -> Void
    ) {
        self.failoverCallback = {
            callback(playerItem)
        }
        
        if self.isNetworkAvailable {
            callback(playerItem)
        }
    }
    
    private struct BlockBasedNetworkAvailabilityCallback: NetworkAvailabilityCallback {
        
        let onNetworkAvailable: () -> Void
        let onNetworkUnavailable: () -> Void
        
        func networkAvailable() {
            onNetworkAvailable()
        }
        
        func networkUnavailable() {
            onNetworkUnavailable()
        }
        
    }
    
}
