//
//  ConfigServiceFactory.swift
//  config-service
//
//  Created by Sabrina Tardio on 25/11/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

public protocol ConfigServiceFactory {
    func create(with configURL: URL) -> ConfigService
}
