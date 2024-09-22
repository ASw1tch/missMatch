//
//  ContactList.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation

struct ContactList: Codable {
    let userID: String
    let toAdd, toUpdate: [To]
    let toRemove: [String]
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case toAdd, toUpdate, toRemove
    }
}

struct To: Codable {
    let contactID: String
    let phones: [String]
    
    enum CodingKeys: String, CodingKey {
        case contactID = "contactId"
        case phones
    }
}

struct ContactsResponse: Decodable {
    let isSuccessful: Bool
    let message: String
    let contacts: [Contact]
}

struct Contact: Identifiable, Decodable {
    let identifier: String
    let givenName: String
    let familyName: String
    let phoneNumbers: [String]
    
    var iLiked: Bool = false
    var itsMatch: Bool = false
    
    var id: String {
        return identifier
    }
}
