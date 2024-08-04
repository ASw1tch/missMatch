//
//  PhoneNumberHasher.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 3.8.24..
//

import Foundation
import CryptoKit

struct PhoneNumberHasher {
    static func hashPhoneNumber(_ phoneNumber: String) -> String {
        let data = Data(phoneNumber.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

