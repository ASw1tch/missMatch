//
//  Likes.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation

struct LikeRequest: Postable {
    let fromUserId: Int
    let contactIds: [Int]
}

struct LikeResponse: Decodable {
    let success: Bool
    let message: String
    let likes: [Like]
}

struct Like: Decodable {
    let id: Int
    let fromPhoneId: Int
    let toPhoneId: Int
    let created: String
    let expired: String
}
