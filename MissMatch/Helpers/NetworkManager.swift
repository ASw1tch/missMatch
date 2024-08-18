//
//  NetworkManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import Foundation

protocol Postable: Encodable {}

enum PostDataCase {
    case user(User)
    case contacts(SaveContactRequest)
    case likes(Likes)
    
    var urlString: String {
        switch self {
        case .user:
            return K.API.userApiUrl
        case .contacts:
            return K.API.contactsApiUrl
        case .likes:
            return K.API.likesApiUrl
        }
    }
    
    var data: Postable {
        switch self {
        case .user(let user):
            return user
        case .contacts(var contacts):
            contacts.contacts = contacts.contacts.map { contact in
                var normalizedContact = contact
                let normalizedPhones = NetworkManager.shared.normalizePhoneNumbers(contact.phones)
                #if DEBUG
                normalizedContact.phones = normalizedPhones.map { PhoneNumberHasher.hashPhoneNumber($0) }
                #endif
                return normalizedContact
            }
            return contacts
        case .likes(let likes):
            return likes
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func postData(for caseType: PostDataCase) {
        guard let url = URL(string: caseType.urlString) else {
            print("Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        do {
            let jsonData = try JSONEncoder().encode(caseType.data)
            print("Encoded JSON: \(String(data: jsonData, encoding: .utf8) ?? "N/A")")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending data:", error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Data sent successfully.")
                } else {
                    print(response ?? "No data")
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding JSON:", error)
        }
    }
    
    func normalizePhoneNumbers(_ phoneNumbers: [String]) -> [String] {
        var seenNumbers = Set<String>()
        
        let normalizedNumbers = phoneNumbers.compactMap { phoneNumber -> String? in
            let filtered = phoneNumber.filter { "+0123456789".contains($0) }
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
