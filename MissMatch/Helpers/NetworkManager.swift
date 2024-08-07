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
            return "http://51.250.55.29:8084/api/v1/users/add"
        case .contacts:
            return "http://51.250.55.29:8084/api/v1/contacts/save"
        case .likes:
            return "http://51.250.55.29:8084/api/v1/like/addAll"
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
                //normalizedContact.phones = normalizedPhones.map { PhoneNumberHasher.hashPhoneNumber($0) }
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
                    print(response, error, data ?? "No data")
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

//enum PostDataCase {
//    case user
//    case contacts
//    case likes
//    
//    var urlString: String {
//        switch self {
//        case .user:
//            return "http://51.250.55.29:8084/api/v1/users/add"
//        case .contacts:
//            return "http://51.250.55.29:8084/api/v1/contacts/save"
//        case .likes:
//            return "http://51.250.55.29:8084/api/v1/like/addAll"
//        }
//    }
//}
//
//final class NetworkManager {
//    static let shared = NetworkManager()
//    
//    private init() {}
//    
//    func postData<T: Encodable>(_ data: T, for caseType: PostDataCase) {
//        guard let url = URL(string: caseType.urlString) else {
//            print("Invalid URL.")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("*/*", forHTTPHeaderField: "accept")
//        do {
//            let jsonData = try JSONEncoder().encode(data)
//            print(data)
//            request.httpBody = jsonData
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error sending data:", error)
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    
//                    print("Data sent successfully.")
//                } else {
//                    print(response, error, data ?? "No data")
//                }
//            }
//            
//            task.resume()
//        } catch {
//            print("Error encoding JSON:", error)
//        }
//    }
//    
//    func postSaveContactRequest(_ user: SaveContactRequest) {
//        guard let url = URL(string: "http://51.250.55.29:8084/api/v1/contacts/save") else {
//            print("Invalid URL.")
//            return
//        }
//        print(user)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("*/*", forHTTPHeaderField: "accept")
//        
//        do {
//            let jsonData = try JSONEncoder().encode(user)
//            request.httpBody = jsonData
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("JSON Output:")
//                print(jsonString)
//            }
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error sending data:", error)
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    print("Data sent successfully.")
//                    
//                } else {
//                    print(response, error, data)
//                }
//               
//            }
//            
//            task.resume()
//        } catch {
//            print("Error encoding JSON:", error)
//        }
//    }
//}
