//
//  AuthorizationCode.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 1.9.24..
//

import Foundation

struct AuthorizationCodeRequest: Postable {
    let authorizationCode: String
}

struct AuthResponse: Decodable {
    let success: Bool
}
