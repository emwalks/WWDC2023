//
//  PersistenceManager.swift
//  config-service
//
//  Created by Sabrina Tardio on 25/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

protocol PersistenceManager {
    func read(key: String) -> Data
    func save(key: String, config: Data) -> Bool
}
