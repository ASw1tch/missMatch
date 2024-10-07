//
//  Like.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 28.9.24..
//

import Foundation

struct Like: Codable {
    let fromUserID: String
    let toContactID: String
    
    enum CodingKeys: String, CodingKey {
        case fromUserID = "fromUserId"
        case toContactID = "toContactId"
    }
}

struct LikeResponse: Codable {
    let success: Bool
    let message: String
    let likes: [String]
}

struct LikeArray: Codable {
    let fromUserID: String
    let toContactIDs: [String]
    
    enum CodingKeys: String, CodingKey {
        case fromUserID = "fromUserId"
        case toContactIDs = "toContactIds"
    }
}

struct LikeArrayResponse: Codable {
    let success: Bool
    let message: String
    let likes: [String]
}
