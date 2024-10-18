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
        headers: [HTTPHeaderField: String] = [:],
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let request = RequestBuilder.buildRequest(urlString: urlString, method: method, headers: headers, body: body) else {
            completion(.failure(.badRequest))
            print("Invalid URL")
            return
        }
        print("Sending request: \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let result = ResponseHandler.handleResponse(data, response: response, error: error, responseType: responseType)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
}
