//
//  SignInViewModel.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 20.9.24..
//

import Foundation

class SignInViewModel: ObservableObject {
    
    @Published var contacts: [ContactList] = []
    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    @Published var shouldNavigate = false
    
    private var retryCount = 0
    private let maxRetryCount = 1
    
    init() {}
    
    func sendToServer(authorizationCode: String) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            showErrorPopup = true
            errorMessage = "Apple ID is not found."
            return
        }
        
        guard let requestBody = appleIdUser.data(using: .utf8) else {
            showErrorPopup = true
            errorMessage = "Can't convert Apple ID to Data."
            return
        }
        
        isLoading = true
        let headers: [HTTPHeaderField: String] = [
            .authorization: authorizationCode,
            .contentType: HTTPHeaderValue.json.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: API.authCodeApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: AuthResponse.self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    UserDefaultsManager.shared.saveRefreshToken(response.refreshToken)
                    self.errorMessage = "Welcome!"
                    self.showErrorPopup = true
                    self.shouldNavigate = true
                case .failure(let error):
                    self.handleError(error: error, authorizationCode: authorizationCode)
                }
            }
        }
    }
    
    private func handleError(error: NetworkError, authorizationCode: String) {
        switch error {
        case .clientError(let statusCode):
            self.errorMessage = "Authorization failed. Check your credentials. (Error \(statusCode))"
            self.showErrorPopup = true
        case .serverError(let statusCode):
            if self.retryCount < self.maxRetryCount {
                showErrorPopup = true
                errorMessage = "Retrying Authorization"
                self.retryCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendToServer(authorizationCode: authorizationCode)
                }
            } else {
                self.errorMessage = "Server not responding. Try again later. (Error \(statusCode))"
                self.showErrorPopup = true
            }
        case .custom(let error):
            self.errorMessage = "Network error: \(error.localizedDescription)"
            self.showErrorPopup = true
        default:
            self.errorMessage = "Unknown error occurred."
            self.showErrorPopup = true
        }
    }
}
