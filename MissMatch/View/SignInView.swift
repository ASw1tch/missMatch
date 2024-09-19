//
//  SignInView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 10.8.24..
//

import SwiftUI
import Contacts
import AuthenticationServices
import CryptoKit

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentNonce: String?
    @State private var isProceed = false
    @State private var isLoading = false
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var body: some View {
            VStack {
                SecureTextAnimationView()
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            handleAuthorization(authResults)
                            isProceed.toggle()
                        case .failure(let error):
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                )
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.5) : Color.gray, radius: 3, x: 0, y: 2)
                .signInWithAppleButtonStyle(
                    colorScheme == .dark ? .white : .black
                )
                .loading(isLoading: $isLoading)
                .popup(isShowing: $showErrorPopup, message: errorMessage)
                .fullScreenCover(isPresented: $isProceed) {
                    MyOwnNumberView(viewModel: ContactListViewModel(),
                                    selectedCountry: Country(flag: "🇷🇸", code: "+381", name: "Serbia"),
                                    phoneNumber: "")
                }
                .frame(height: 45)
                .padding()
        }
    }
    
    private func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let authorizationCode = appleIDCredential.authorizationCode
            let authorizationCodeString = String(data: authorizationCode!, encoding: .utf8) ?? ""
            
            UserDefaultsManager.shared.saveAppleId(userId)
            
            sendToServer(authorizationCode: authorizationCodeString)
        }
    }
    
    private func sendToServer(authorizationCode: String) {
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
                self.isLoading = false  // Выключаем лоадер
                switch result {
                case .success(let response):
                    UserDefaultsManager.shared.saveRefreshToken(response.refreshToken)
                    // Переход на другой экран или обновление UI
                    showErrorPopup = true
                    errorMessage = "ПОЛУЧИЛОСЬ"
                case .failure(let error):
                    self.showErrorPopup = true
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct SecureTextAnimationView: View {
    @State private var text: String = "We use AppleID to provide "
    @State private var secureText: String = "secure"
    @State private var displayText: String = ""
    @State private var isAnimating: Bool = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        Text(text + displayText + " authentication and easy access to your likes and matches.")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
            .bold()
            .padding()
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        isAnimating = true
        var currentIndex = 0
        displayText = "" 
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            if currentIndex < secureText.count {
                let index = secureText.index(secureText.startIndex, offsetBy: currentIndex)
                displayText.append(secureText[index])
            } else if currentIndex < secureText.count * 2 {
                displayText.replaceSubrange(displayText.index(displayText.startIndex, offsetBy: currentIndex - secureText.count)...displayText.index(displayText.startIndex, offsetBy: currentIndex - secureText.count), with: "•")
            } else {
                timer?.invalidate()
                isAnimating = false
                currentIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    startAnimation()
                }
            }
            currentIndex += 1
        }
    }
}

#Preview {
    SignInView()
}

