//
//  DefaultConfigServiceFactory.swift
//  config-service
//
//  Created by Sabrina Tardio on 25/11/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

public class RemoteConfigServiceFactory: ConfigServiceFactory {
    
    private let networking: Networking
    private let persistenceManager: PersistenceManager
    private let backOffManager: BackOffManager
    private let monitoring: Monitoring
    private let monitoringHostName: String
    
    public convenience init() {
        self.init(networking: URLSessionNetworking(), persistenceManager: PersistenceManagerAdapter(), backOffManager: TimeBasedBackOffManager(), monitoring: MonitoringClient(), monitoringHostName: "https://r.bbci.co.uk/i/mobileplatform")
    }
    
    init(networking: Networking, persistenceManager: PersistenceManager, backOffManager: BackOffManager, monitoring: Monitoring, monitoringHostName: String) {
        self.networking = networking
        self.persistenceManager = persistenceManager
        self.backOffManager = backOffManager
        self.monitoring = monitoring
        self.monitoringHostName = monitoringHostName
    }
    
    public func create(with configURL: URL) -> ConfigService {
        return RemoteConfigService(networking: networking, persistenceManager: persistenceManager, url: configURL, backOffManager: backOffManager, monitoring: monitoring, monitoringHostName: monitoringHostName)
    }
}
