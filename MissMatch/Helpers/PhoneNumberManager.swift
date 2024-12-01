//
//  PhoneNumberManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 27.8.24..
//

import Foundation
import CryptoKit

struct PhoneNumberManager {
    
    static func hashPhoneNumber(_ phoneNumber: String) -> String {
        let data = Data(phoneNumber.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    static func hashPhoneNumders(_ phoneNumbers: [String]) -> [String] {
        return phoneNumbers.map { hashPhoneNumber($0) }
    }
    
    static func normalizePhoneNumbers(_ phoneNumbers: [String]) -> [String] {
        var seenNumbers = Set<String>()
        let normalizedNumbers = phoneNumbers.compactMap { phoneNumber -> String? in
            var filtered = phoneNumber.filter { "+0123456789".contains($0) }
            filtered = filtered.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "-", with: "")
            
            if filtered.hasPrefix("8") && filtered.count == 11 {
                filtered = "+7" + filtered.dropFirst()
            }
            
            if seenNumbers.contains(filtered) {
                return nil
            } else {
                seenNumbers.insert(filtered)
                return filtered
            }
        }
        return normalizedNumbers
    }
}
