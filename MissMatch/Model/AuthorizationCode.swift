//
//  AuthorizationCode.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 1.9.24..
//

import Foundation

struct AuthorizationCodeRequest: Codable {
    let authorizationCode: String?
}

struct AuthResponse: Codable {
    let userID, refreshToken, message: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case refreshToken, message
    }
}
