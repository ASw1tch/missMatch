//
//  User.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation
import CryptoKit

struct User: Codable, Postable {
    var appleId: String
    var phones: [String]
}

struct UserResponse: Decodable {
    let id: Int
    let appleId: String
    let created: String
}
