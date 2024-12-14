//
//  LogOutViewModel.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 13.12.24..
//
import Foundation
import Combine

final class LogOutViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    @Published var shouldNavigate = false
    @Published var navigateToStart = false
    
    private var retryCount = 0
    private let maxRetryCount = 2
    
    init() {
        retryCount = 0
    }
    
    func logOut() {
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
            .contentType: HTTPHeaderValue.json.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: API.logOutApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: String.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    print("Response: \(response)")
                    self?.showErrorPopup = true
                    self?.errorMessage = "User logged out successfully: \(response)"
                    UserDefaultsManager.shared.resetAllValues()
                    self?.navigateToStart = true
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    self?.handleUserSendingError(error: error)
                }
            }
        }
    }
    
    private func handleUserSendingError(error: NetworkError) {
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
            
        case .tokenRevokeFailed:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .phonesCannotBeEmpty, .phoneAlreadyAssigned:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .internalServerError:
            if retryCount < maxRetryCount {
                retryCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.logOut()
                }
            } else {
                self.errorMessage = "Error. Please try again later."
                self.showErrorPopup = true
            }
            
        case .customError(let message):
            print("Custom Error")
            self.errorMessage = message
            self.showErrorPopup = true
        }
    }
}

