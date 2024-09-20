//
//  NetworkManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func sendRequest<T: Decodable>(
        to urlString: String,
        method: HTTPMethod = .GET,
        headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue
        ],
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let request = RequestBuilder.buildRequest(urlString: urlString, method: method, headers: headers, body: body) else {
            completion(.failure(.invalidURL))
            return
        }
        print(request.description)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let result = ResponseHandler.handleResponse(data, response: response, error: error, responseType: responseType)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
}

//protocol Postable: Encodable {}
//protocol ResponseHandler {
//    associatedtype Response: Decodable
//    func handleResponse(_ response: Response)
//}
//
//enum PostDataCase {
//    case user(User)
//    case contacts(SaveContactRequest)
//    case likes(LikeRequest)
//    case authorizationCode(String)
//    
//    var urlString: String {
//        switch self {
//        case .user:
//            return K.API.userApiUrl
//        case .contacts:
//            return K.API.contactsApiUrl
//        case .likes:
//            return K.API.likesApiUrl
//        case .authorizationCode:
//            return K.API.authCodeApiUrl
//        }
//    }
//    
//    var data: Postable {
//        switch self {
//        case .user(let user):
//            return user
//        case .contacts(var contacts):
//            contacts.contacts = contacts.contacts.map { contact in
//                var encryptedContact = contact
////                let hashedPhones = contact.phones.map { PhoneNumberManager.hashPhoneNumber($0) }
////                encryptedContact.phones = hashedPhones
//                return encryptedContact
//            }
//            return contacts
//        case .likes(let likes):
//            return likes
//        case .authorizationCode(let code):
//            return AuthorizationCodeRequest(authorizationCode: code)
//        }
//    }
//    
//    func handleResponse(_ data: Data) {
//        switch self {
//        case .user:
//            if let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
//                print("User ID saved: \(userResponse.message)")
//            }
//        case .contacts:
//            if let contactsResponse = try? JSONDecoder().decode(ContactsResponse.self, from: data) {
//                print("Contacts saved.")
//                print(contactsResponse)
//            }
//        case .likes:
//            if let likesResponse = try? JSONDecoder().decode(LikeResponse.self, from: data) {
//                print("Likes saved.")
//            }
//        case .authorizationCode:
//            if let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
//                UserDefaultsManager.shared.saveRefreshToken(authResponse.refreshToken)
//                print("Refresh Token saved in UserDefaults: \(String(describing: UserDefaultsManager.shared.getRefreshToken()))")
//            } else {
//                print("Failed to decode AuthResponse.")
//            }
//        }
//    }
//}
//
//final class NetworkManager {
//    static let shared = NetworkManager()
//    
//    private init() {}
//    
//    func postData(for caseType: PostDataCase) {
//        guard let url = URL(string: caseType.urlString) else {
//            print("Invalid URL.")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("*/*", forHTTPHeaderField: "accept")
//        
//        if let refreshToken = UserDefaultsManager.shared.getRefreshToken(), !refreshToken.isEmpty {
//            print("Using method with refresh token")
//            request.setValue(refreshToken, forHTTPHeaderField: "Authorization")
//            do {
//                let jsonData = try JSONEncoder().encode(caseType.data)
//                request.httpBody = jsonData
//                print(jsonData)
//            } catch {
//                print("Ошибка кодирования JSON: \(error.localizedDescription)")
//                return
//            }
//        } else {
//            print("Refresh token is not found.")
//        }
//    
//        if case let .authorizationCode(code) = caseType {
//            if let appleIdUser = UserDefaultsManager().getAppleId() {
//                request.httpBody = appleIdUser.data(using: .utf8)
//                let authHeader = "\(code)"
//                request.setValue(authHeader, forHTTPHeaderField: "Authorization")
//                print("Authorization Code: \(code)")
//            } else {
//                print("Apple ID не найден, требуется повторный вход в систему.")
//                return
//            }
//        }
//        
//        do {
//            let jsonData = try JSONEncoder().encode(caseType.data)
//            print("Encoded JSON: \(String(data: jsonData, encoding: .utf8) ?? "N/A")")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Error sending data:", error)
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    if let data = data {
//                        caseType.handleResponse(data)
//                    } else {
//                        print("No data received.")
//                    }
//                } else {
//                    print(response ?? "No data")
//                }
//            }
//            
//            task.resume()
//        } catch {
//            print("Error encoding JSON:", error)
//        }
//    }
//}
