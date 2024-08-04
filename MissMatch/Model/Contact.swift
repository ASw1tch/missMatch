//
//  Contact.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation
import CryptoKit

struct Contact: Identifiable {
    var id = UUID()
    var name: String
    var surname: String
    var phoneNumber: [String]
    var hashedPhoneNumbers: [String] {
        return phoneNumber.map { PhoneNumberHasher.hashPhoneNumber($0) }
    }
    
    var iLiked: Bool = false
    var itsMatch: Bool = false
    
}
