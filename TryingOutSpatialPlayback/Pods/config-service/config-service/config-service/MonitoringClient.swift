//
//  MonitoringClient.swift
//  config-service
//
//  Created by Sabrina Tardio on 11/01/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

class MonitoringClient: Monitoring {
    let networking: Networking
    
    init(networking: Networking = URLSessionNetworking()) {
        self.networking = networking
    }
    
    func configError(baseURL: String, version: String, errorReason: String) {
        self.sendStat(baseURL: baseURL, version: version, errorReason: errorReason)
    }
    
    func configSuccess(baseURL: String, version: String) {
        self.sendStat(baseURL: baseURL, version: version, errorReason: nil)
    }
    
    
    private func sendStat(baseURL: String, version: String, errorReason: String?) {
        var urlString = "\(baseURL)/configservice/ios/\(CONFIG_SERVICE_VERSION)/"
        if let error = errorReason {
            urlString.append("e/\(error)/")
        } else {
            urlString.append("s/")
        }
        urlString.append(version)
        if let url = URL(string: urlString) {
            networking.get(url) { (_) in}
        }
    }
    
}
