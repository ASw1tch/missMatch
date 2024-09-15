//
//  SaveContactRequest.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 6.8.24..
//

import Foundation

struct SaveContactRequest: Codable, Postable {
    let userId: String
    var contacts: [SavedContact]
    
    enum CodingKeys: String, CodingKey {
        case userId
        case contacts
    }
    init(userId: String, contacts: [SavedContact]) {
        self.userId = userId
        self.contacts = contacts
    }
}

struct SaveContactResponse: Codable {
    let isSuccessful: Bool
    let message: String
    let contacts: [SavedContact]
}

struct SavedContact: Codable {
    let id: Int
    let phones: [String]
}

