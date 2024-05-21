//
//  ConfigPersister.swift
//  config-service
//
//  Created by Sabrina Tardio on 26/10/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation


class UserDefaultsPersister: Persister {
    
    let userDefaults = UserDefaults.standard

    func read<T>(key: String) -> T? {
        return userDefaults.object(forKey: key) as? T
    }
    
    func save<T>(key: String, object: T) {
        userDefaults.setValue(object, forKey: key)
    }
    
}
