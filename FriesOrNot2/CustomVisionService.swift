//
//  CustomVisionService.swift
//  FriesOrNot2
//
//  Created by Madoka CHIYODA on 2017/08/02.
//  Copyright © 2017 Madoka Chiyoda. All rights reserved.
//

import Foundation

class CustomVisionService {
    var preductionUrl = ""
    var predictionKey = ""
    var contentType = "application/octet-stream"
    
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func predict(image: Data, completion: @escaping (CustomVisionResult?, Error?) -> Void) {
        
        // Create URL Request
        var urlRequest = URLRequest(url: URL(string: preductionUrl)!)
        urlRequest.addValue(predictionKey, forHTTPHeaderField: "Prediction-Key")
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        // Cancel existing dataTask if active
        dataTask?.cancel()
        
        // Create new dataTask to upload image
        dataTask = defaultSession.uploadTask(with: urlRequest, from: image) { data, response, error in
            defer { self.dataTask = nil }
            
            if let error = error {
                completion(nil, error)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let result = try? CustomVisionResult(json: json!) {
                    completion(result, nil)
                }
            }
        }
        
        // Start the new dataTask
        dataTask?.resume()
    }
}
