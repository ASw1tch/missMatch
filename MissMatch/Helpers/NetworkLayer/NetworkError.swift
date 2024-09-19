//
//  NetworkError.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case custom(error: Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received."
        case .decodingError:
            return "Failed to decode the response."
        case .serverError(let statusCode):
            return "Server returned error with status code: \(statusCode)."
        case .custom(let error):
            return error.localizedDescription
        }
    }
}
