//
//  Likes.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation

struct Likes: Codable, Postable {
    let success: Bool 
    let message: String
    let likes: [LikeElement]
}

struct LikeElement: Codable, Postable {
    let id, fromPhoneId, toPhoneId: Int
    let created, expired: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromPhoneId
        case toPhoneId
        case created, expired
    }
}
