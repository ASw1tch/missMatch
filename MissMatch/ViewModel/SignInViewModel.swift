//
//  SignInViewModel.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 20.9.24..
//

import Foundation
import SwiftUI

class SignInViewModel: ObservableObject {
    
    @EnvironmentObject var coordinator: AppCoordinator
    
    @Published var contacts: [ContactList] = []
    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    @Published var shouldNavigate = false
    @Published var navigateToStart = false
    
    private var retryCount = 0
    private let maxRetryCount = 2
    
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
        defer {
            retryCount = 0
        }
        switch error {
        case .badRequest:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .invalidToken, .userNotFound:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            self.navigateToStart = true
            
        case .internalServerError:
            if retryCount < maxRetryCount {
                retryCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendToServer(authorizationCode: authorizationCode)
                }
            } else {
                self.errorMessage = "Error. Please contact support."
                self.showErrorPopup = true
            }
        case .tokenRevokeFailed:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .phonesCannotBeEmpty, .phoneAlreadyAssigned:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .customError(let message):
            self.errorMessage = message
            self.showErrorPopup = true
        }
    }
}
