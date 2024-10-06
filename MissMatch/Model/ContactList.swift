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
    let contacts: [ContactDTO]
}

struct Contact: Identifiable, Decodable {
    let identifier: String
    var givenName: String? = nil
    var familyName: String? = nil
    let phoneNumbers: [String]
    
    var iLiked: Bool = false
    var itsMatch: Bool = false
    
    var id: String {
        return identifier
    }
    
    mutating func toggleLike() {
        iLiked.toggle()
    }
    
    mutating func toggleMatch() {
        itsMatch.toggle()
    }
}

struct ContactDTO: Identifiable, Decodable {
    let contactId: String
    let phones: [String]
    
    var iLiked: Bool = false
    var itsMatch: Bool = false
    
    var id: String {
        return contactId
    }
    
    enum CodingKeys: String, CodingKey {
        case contactId = "contactId"
        case phones = "phones"
    }
}
