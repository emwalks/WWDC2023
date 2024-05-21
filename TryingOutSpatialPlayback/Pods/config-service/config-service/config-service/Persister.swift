//
//  Persister.swift
//  config-service
//
//  Created by Sabrina Tardio on 26/10/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

protocol Persister {
    func read<T>(key:String) -> T?
    func save<T>(key:String, object: T)
}
