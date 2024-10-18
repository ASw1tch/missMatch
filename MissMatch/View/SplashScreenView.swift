//
//  SplashScreenView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 30.7.24..
//

import SwiftUI
import Contacts

struct SplashScreenView: View {
    
    @State private var isActive = false
    @State private var shouldPresentSignIn = false
    let userID = UserDefaultsManager.shared.getAppleId()
    
    var body: some View {
        ZStack {
            Color(hex: "#f8dcdc")
                .ignoresSafeArea()
            VStack {
                if isActive {
                    if shouldPresentSignIn {
                        ContactPermissonView()
                    } else {
                        if userID != nil {
                            ContactListView()
                        } else {
                            ContactPermissonView()
                        }
                    }
                } else {
                    ZStack {
                        VStack {
                            Image("uLogo")
                                .resizable()
                                .frame(width: 150, height: 150)
                            Spacer()
                            
                            Text("Safely find out who's")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold() +
                            Text(" missing you")
                                .foregroundStyle(.red)
                                .font(.title3)
                                .italic()
                                .bold()
                        }
                        .padding(30)
                        
                        VStack {
                            LottieView(name: "intro", loopMode: .playOnce)
                                .frame(width: 500, height: 600)
                                .mask {
                                    RadialGradient(
                                        gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                                        center: .center,
                                        startRadius: 150,
                                        endRadius: 300
                                    )
                                }
                        }
                        .transition(.opacity)
                    }
                }
            }
            .onAppear {
                checkContactAuthorization()
            }
        }
    }
    
    private func checkContactAuthorization() {
        _ = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            proceedToNextView()
        case .notDetermined:
            self.shouldPresentSignIn = true
            proceedToNextView()
            
        default:
            self.shouldPresentSignIn = true
            proceedToNextView()
        }
    }
    
    private func proceedToNextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 1, dampingFraction: 0.5, blendDuration: 1.5)) {
                self.isActive = true
            }
        }
    }
}
#Preview {
    SplashScreenView()
}
