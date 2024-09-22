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
            to: K.API.authCodeApiUrl,
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
                    print(UserDefaultsManager.shared.getRefreshToken() ?? "No token")
                    self.showErrorPopup = true
                    self.errorMessage = "ПОЛУЧИЛОСЬ"
                case .failure(let error):
                    self.showErrorPopup = true
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
