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
            let identityToken = appleIDCredential.identityToken
            let authorizationCode = appleIDCredential.authorizationCode
            
            let authorizationCodeString = String(data: authorizationCode!, encoding: .utf8) ?? ""
            // Сохраните userId, если нужно
            UserDefaultsManager.shared.saveAppleId(userId)
            
            // Теперь отправьте identityTokenString на ваш сервер
            sendToServer(authorizationCode: authorizationCodeString)
        }
    }
    
    private func sendToServer(authorizationCode: String) {
        // Create an instance of the enum with the authorization code
        let postDataCase = PostDataCase.authorizationCode(authorizationCode)
        NetworkManager.shared.postData(for: postDataCase)
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

