//
//  RequestBuilder.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import Foundation

struct RequestBuilder {
    
    static func buildRequest(
        urlString: String,
        method: HTTPMethod = .GET,
        headers: [HTTPHeaderField: String] = [:],
        body: Data? = nil
    ) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        var updatedHeaders = headers.mapValues { $0 }
        
        if let refreshToken = UserDefaultsManager.shared.getRefreshToken(), !refreshToken.isEmpty {
            updatedHeaders[.authorization] = "\(refreshToken)"
        }
        
        request.allHTTPHeaderFields = updatedHeaders.mapKeys { $0.rawValue }
        request.httpBody = body
        
        print("Request URL: \(urlString)")
        print("HTTP Method: \(method.rawValue)")
        print("Headers: \(updatedHeaders)")
        if let body = body {
            print("Request Body: \(String(data: body, encoding: .utf8) ?? "Unable to encode body to string")")
        } else {
            print("Request Body: None")
        }
        
        return request
    }
}

// Utility extension to map keys in dictionaries
extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        return Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
