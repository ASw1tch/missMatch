//
//  PhoneNumberManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 27.8.24..
//

import Foundation
import CryptoKit
import Contacts

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
    
    static func findContactName(for phoneNumber: String, completion: @escaping (String?) -> Void) {
        let contactStore = CNContactStore()
        let normalizedPhoneNumber = normalizePhoneNumbers([phoneNumber]).first ?? phoneNumber
        
        DispatchQueue.global(qos: .userInitiated).async {
            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: normalizedPhoneNumber))
            let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor]
            
            do {
                let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                
                if let contact = contacts.first {
                    let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    DispatchQueue.main.async {
                        completion(fullName.isEmpty ? nil : fullName)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil) // Контакт не найден
                    }
                }
            } catch {
                print("Ошибка при поиске контакта: \(error)")
                DispatchQueue.main.async {
                    completion(nil) // Ошибка при поиске
                }
            }
        }
    }
    
}
