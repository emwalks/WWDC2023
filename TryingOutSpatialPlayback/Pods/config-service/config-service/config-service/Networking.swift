//
//  Networking.swift
//  config-service
//
//  Created by Sabrina Tardio on 21/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

protocol Networking {
    func get(_ path: URL, completion: @escaping (NetworkingResult) -> Void)
}
