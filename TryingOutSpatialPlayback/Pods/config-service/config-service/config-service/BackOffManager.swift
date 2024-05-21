//
//  BackOffManager.swift
//  config-service
//
//  Created by Sabrina Tardio on 01/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

protocol BackOffManager {
    func isBackOff() -> Bool
    func startBackOff()
}
