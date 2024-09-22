//
//  ContactList.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation
import CryptoKit

struct ContactList: Identifiable, Equatable {
    var id: Int
    var name: String
    var surname: String
    var phoneNumber: [String]
    var hashedPhoneNumbers: [String] {
        return phoneNumber.map { PhoneNumberManager.hashPhoneNumber($0) }
    }
    
    var iLiked: Bool = false
    var itsMatch: Bool = false
    
}

struct ContactsResponse: Decodable {
    let isSuccessful: Bool
    let message: String
    let contacts: [Contacts]
}

struct Contacts: Decodable {
    let id: Int
    let phones: [String]
}
