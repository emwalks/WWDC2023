//
//  PlaybackConfigServiceAdapter.swift
//  SMP
//
//  Created by Sabrina Tardio on 25/11/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation
import ConfigService

class PlaybackConfigServiceAdapter: PlaybackConfigAdapter {
    private let configService: ConfigService
    private let standardConfig: PlaybackConfig

    init(configEndpoint: URL = URL(string: "https://emp.bbc.co.uk/msmp/ios/0.0.1/smpSpikeConfig.json")!,
         configServiceFactory: ConfigServiceFactory = RemoteConfigServiceFactory(),
         standardConfig: PlaybackConfig = PlaybackConfig()) {
        self.configService = configServiceFactory.create(with: configEndpoint)
        self.standardConfig = standardConfig
    }

    func config() -> PlaybackConfig {
        print("playbackConfigServiceAdapter asked to read the config")
        guard let config = try? JSONDecoder().decode(PlaybackConfig.self, from: configService.newConfigData()) else {
            print("will return standard config \(standardConfig)")
            return standardConfig
        }
        print("will return server config \(config)")
        return config
    }
}
