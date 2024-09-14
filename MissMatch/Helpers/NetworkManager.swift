//
//  NetworkManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import Foundation

protocol Postable: Encodable {}
protocol ResponseHandler {
    associatedtype Response: Decodable
    func handleResponse(_ response: Response)
}

enum PostDataCase {
    case user(User)
    case contacts(SaveContactRequest)
    case likes(LikeRequest)
    case authorizationCode(String)
    
    var urlString: String {
        switch self {
        case .user:
            return K.API.userApiUrl
        case .contacts:
            return K.API.contactsApiUrl
        case .likes:
            return K.API.likesApiUrl
        case .authorizationCode:
            return K.API.authCodeApiUrl
        }
    }
    
    
    var data: Postable {
        switch self {
        case .user(let user):
            return user
        case .contacts(var contacts):
            contacts.contacts = contacts.contacts.map { contact in
                var encryptedContact = contact
                //let hashedPhones = contact.phones.map { PhoneNumberManager.hashPhoneNumber($0) }
                //encryptedContact.phones = hashedPhones
                return encryptedContact
            }
            return contacts
        case .likes(let likes):
            return likes
        case .authorizationCode(let code):
            return AuthorizationCodeRequest(authorizationCode: code)
        }
    }
    
    func handleResponse(_ data: Data) {
        switch self {
        case .user:
            if let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
                UserDefaultsManager.shared.saveUserId(userResponse.id)
                print("User ID saved: \(userResponse.id)")
            }
        case .contacts:
            if let contactsResponse = try? JSONDecoder().decode(ContactsResponse.self, from: data) {
                print("Contacts saved.")
                print(contactsResponse)
            }
        case .likes:
            if let likesResponse = try? JSONDecoder().decode(LikeResponse.self, from: data) {
                print("Likes saved.")
            }
        case .authorizationCode:
            if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                UserDefaultsManager.shared.saveRefreshToken(authResponse.refreshToken)
                    print("Authorization successful.")
                    print("Message: \(authResponse.message)")
                    print("UserID: \(authResponse.userID)")
                print("Refresh Token saved in UserDefaults: \(String(describing: UserDefaultsManager.shared.getRefreshToken()))")
            } else {
                print("Failed to decode AuthResponse.")
            }
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
        if case let .authorizationCode(code) = caseType {
            // Добавляем authorizationCode в заголовок
            let authHeader = "\(code)"
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            
            // Получаем appleID из UserDefaults
            if let appleIdUser = UserDefaultsManager().getAppleId() {
                // Устанавливаем appleID как тело запроса напрямую (без JSON-обработки)
                request.httpBody = appleIdUser.data(using: .utf8)
                
                // Для отладки выводим authorizationCode и appleID
                print("Authorization Code: \(code)")
                print("Тело запроса (appleID): \(appleIdUser)")
            } else {
                print("AppleID не найден в UserDefaults.")
            }
        }
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
                    if let data = data {
                        caseType.handleResponse(data)
                    } else {
                        print("No data received.")
                    }
                } else {
                    print(response ?? "No data")
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding JSON:", error)
        }
    }
}
