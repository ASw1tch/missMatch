//
//  ResponseHandler.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import Foundation

struct ResponseHandler {
    
    static func handleResponse<T: Decodable>(_ data: Data?, response: URLResponse?, error: Error?, responseType: T.Type) -> Result<T, NetworkError> {
        if let error = error {
            return .failure(.custom(error: error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.noData)
        }
        
        guard httpResponse.statusCode == 200 else {
            return .failure(.serverError(statusCode: httpResponse.statusCode))
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        if responseType == String.self, let responseString = String(data: data, encoding: .utf8) {
            return .success(responseString as! T)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(.decodingError)
        }
    }
}
