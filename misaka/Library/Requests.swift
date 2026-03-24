//
//  Requests.swift
//  misaka
//
//  Created by straight-tamago⭐️ on 2023/09/09.
//

import Foundation

struct RequestsType {
    var Method: String
    var URL: String
    var Params: [String: Any]? = nil
    var Json: [String: Any]? = nil
    var Data: Data? = nil
    var Headers: [String: String]? = nil
}

func Requests(_ RT: RequestsType, completion: @escaping (Data?) -> Void) {
    var RT = RT
    guard let url = URL(string: RT.URL) else {
        completion(nil)
        return
    }
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.cachePolicy = .reloadIgnoringCacheData
    if RT.Method == "Post" {
        request.httpMethod = "post"
        if RT.Json != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: RT.Json as Any, options: [])
        }
        if RT.Data != nil {
            request.httpBody = RT.Data
        }
        if RT.Params != nil {
            let parameterString = (RT.Params ?? [:]).map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            if let bodyData = parameterString.data(using: .utf8) {
                request.httpBody = bodyData
            }
        }
    }
    
    for (key, value) in RT.Headers ?? [:] {
        request.addValue(value, forHTTPHeaderField: key)
    }
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if error == nil, let data = data, let response = response as? HTTPURLResponse {
            completion(data)
            return
        }else{
            completion(nil)
        }
    }.resume()
}

