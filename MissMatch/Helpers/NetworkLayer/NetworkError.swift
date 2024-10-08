//
//  NetworkError.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

enum NetworkError: Error {
    case badRequest
    case invalidToken
    case tokenRevokeFailed
    case userNotFound
    case phonesCannotBeEmpty
    case phoneAlreadyAssigned(String)
    case internalServerError
    case customError(String)
    
    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "Bad request. Please check your input."
        case .invalidToken:
            return "Invalid token. Please log in again."
        case .tokenRevokeFailed:
            return "Error. Please contact support."
        case .userNotFound:
            return "User not found. Please log in again."
        case .phonesCannotBeEmpty:
            return "Phone number cannot be empty."
        case .phoneAlreadyAssigned(let phone):
            return "Phone \(phone) is already assigned to another user."
        case .internalServerError:
            return "Internal server error. Please try again later."
        case .customError(let message):
            return message
        }
    }
}
