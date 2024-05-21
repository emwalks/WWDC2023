//
//  Monitoring.swift
//  config-service
//
//  Created by Sabrina Tardio on 08/01/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

import Foundation

protocol Monitoring {
    func configError(baseURL: String, version: String, errorReason: String)
    func configSuccess(baseURL: String, version: String)
}

