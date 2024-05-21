//
//  PersistenceManagerAdapter.swift
//  config-service
//
//  Created by Sabrina Tardio on 25/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

class PersistenceManagerAdapter: PersistenceManager {
    
    private let persister: Persister

    init(persister: Persister = UserDefaultsPersister()) {
        self.persister = persister
    }
    
    func save(key: String, config: Data) -> Bool {
        do {
            try JSONSerialization.jsonObject(with: config, options: .allowFragments)
            persister.save(key:key, object:config)
            return true
        } catch {
            print("saveJsonData: invalid json")
            return false
        }
    }
    
    func read(key: String) -> Data {
        guard let configData: Data = persister.read(key: key) else {return Data()}
        return configData
    }
    
}


