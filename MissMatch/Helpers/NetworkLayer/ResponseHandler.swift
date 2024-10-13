//
//  ResponseHandler.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import Foundation

struct ResponseHandler {
    
    static func handleResponse<T: Decodable>(
        _ data: Data?,
        response: URLResponse?,
        error: Error?,
        responseType: T.Type
    ) -> Result<T, NetworkError> {
        
        if let error = error {
            return .failure(.customError(error.localizedDescription))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.customError("No response received from server."))
        }
        
        let statusCode = httpResponse.statusCode
        
        switch statusCode {
        case 200...299:
            guard let data = data else {
                return .failure(.customError("No data received."))
            }
            do {
                if T.self == String.self {
                    if let responseString = String(data: data, encoding: .utf8) as? T {
                        return .success(responseString)
                    } else {
                        return .failure(.customError("Failed to convert response to String."))
                    }
                } else {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    return .success(decodedData)
                }
            } catch {
                return .failure(.customError("Failed to decode response."))
            }
            
        case 400:
            if let data = data, let message = String(data: data, encoding: .utf8) {
                if message.contains("Phones cannot be empty") {
                    return .failure(.phonesCannotBeEmpty)
                } else {
                    return .failure(.badRequest)
                }
            }
            return .failure(.badRequest)
            
        case 401:
            if let data = data, let message = String(data: data, encoding: .utf8), message.contains("Token Revoke Failed") {
                return .failure(.tokenRevokeFailed)
            } else {
                return .failure(.invalidToken)
            }
            
        case 404:
            return .failure(.userNotFound)
            
        case 409:
            if let data = data, let message = String(data: data, encoding: .utf8) {
                return .failure(.phoneAlreadyAssigned(message))
            }
            return .failure(.customError("Phone conflict."))
            
        case 500:
            return .failure(.internalServerError)
            
        default:
            return .failure(.customError("Unknown error occurred. Status code: \(statusCode)"))
        }
    }
}
