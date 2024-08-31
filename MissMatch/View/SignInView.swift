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
        .onAppear{
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    return
                }
            }
        }
    }
    
    private func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            UserDefaultsManager.shared.saveAppleId(userId)
        }
    }
}
#Preview {
    SignInView()
}

