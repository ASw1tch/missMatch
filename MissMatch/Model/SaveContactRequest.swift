//
//  SaveContactRequest.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 6.8.24..
//

import Foundation

struct SaveContactRequest: Codable, Postable {
    let userId: Int
    var contacts: [Contact]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case contacts
    }
}

struct Contact: Codable, Postable {
    var phones: [String]
}
