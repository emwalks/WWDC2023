//
//  URLSessionNetworking.swift
//  config-service
//
//  Created by Sabrina Tardio on 21/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

import Foundation

class URLSessionNetworking: Networking {
    
    func get(_ path: URL, completion: @escaping (NetworkingResult) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .useProtocolCachePolicy
        let session = URLSession.init(configuration: sessionConfig)
        let task: URLSessionDataTask!
        task = session.dataTask(with: path) {(data, response, error) in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 || response.statusCode == 304,
                  error == nil else {
                completion(NetworkingResult.failure(NSError(domain: "", code: 032, userInfo: nil)))
                return
            }
            if data == nil {
                completion(NetworkingResult.failure(NSError(domain: "", code: 032, userInfo: nil)))
                return
            }
            completion(NetworkingResult.success(data!))
        }
        task.resume()
    }

}

typealias NetworkingResult = Result<Data, Error>


