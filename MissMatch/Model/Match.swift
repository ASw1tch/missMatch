//
//  Match.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 28.9.24..
//

import Foundation

struct MatchResponse: Codable {
    let contactIDS: [String]
    
    enum CodingKeys: String, CodingKey {
        case contactIDS = "contactIds"
    }
}
