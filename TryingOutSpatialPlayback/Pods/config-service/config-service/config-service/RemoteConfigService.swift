//
//  ConfigService.swift
//  config-service
//
//  Created by Sam Rowley on 24/08/2020.
//  Copyright © 2020 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import Foundation

class RemoteConfigService: ConfigService {
    private let configURL: URL
    private let networking: Networking
    private let persistenceManager: PersistenceManager
    private let backOffManager: BackOffManager
    private let monitoring: Monitoring
    private let monitoringHostName: String
    private var key = "ConfigData"
    
    init(networking: Networking, persistenceManager: PersistenceManager,  url: URL, backOffManager: BackOffManager, monitoring: Monitoring, monitoringHostName: String) {
        self.networking = networking
        self.persistenceManager = persistenceManager
        self.configURL = url
        self.backOffManager = backOffManager
        self.monitoring = monitoring
        self.monitoringHostName = monitoringHostName
    }
    
    func newConfigData() -> Data {
        updateConfig()
        return persistenceManager.read(key: key)
    }
    
    private func updateConfig() {
        print("updating")
        guard !backOffManager.isBackOff() else {return}
        key = "ConfigDataV" + (getVersionFrom(url: configURL) ?? "ersionUnknown")
        networking.get(configURL) { (result) in
            switch result {
            case .success(let data):
                let isPersisted = self.persistenceManager.save(key: self.key, config: data)
                if isPersisted {
                    self.monitorSuccess()
                } else {
                    self.monitorError(reason: ConfigErrorDescription.JsonError)
                }
            case .failure(_):
                self.backOffManager.startBackOff()
                self.monitorError(reason: ConfigErrorDescription.NetworkingError)
            }
        }
    }
    
    private func monitorError(reason: ConfigErrorDescription) {
        self.monitoring.configError(baseURL: monitoringHostName, version: getVersionFrom(url: configURL) ?? "-", errorReason: reason.rawValue)
    }
    
    private func monitorSuccess() {
        self.monitoring.configSuccess(baseURL: monitoringHostName, version: getVersionFrom(url: configURL) ?? "-")
    }

    private func getVersionFrom(url:URL) -> String? {
        var version = ""
        let urlString = url.absoluteString
        let stringArray = urlString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        for item in stringArray {
            if let number = Int(item) {
                version.append(String(number))
                break
            }
        }
        return version == "" ? nil : version
    }
}


enum ConfigErrorDescription: String {
    case NetworkingError = "NetworkingError"
    case JsonError = "JsonNotSerializable"
}
