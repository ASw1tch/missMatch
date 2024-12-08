//
//  ContactPermissionView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.8.24..
//

import SwiftUI
import Contacts
import UserNotifications

struct ContactPermissonView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isNotGranted = false
    @State private var showNextView = false
    @State private var buttonTapped = false
    @State private var showAlert = false
    @State private var isUserNotAgree = false
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white)
            
            if isNotGranted {
                VStack {
                    Text("Without contacts access, the app won't work🥺 Also, for the best User Experience turn on notifications.")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(20)
                    
                    Button(action: {
                        openAppSettings()
                    }) {
                        Text("Ok, take me to settings")
                            .bold()
                            .padding()
                            .foregroundStyle(.cyan)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                }
            } else if isUserNotAgree {
                VStack {
                    Text("We can't proceed without your consent to process your contacts securely☹️ Please grant permission to continue.")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(20)
                    
                    Button(action: {
                        showAlert.toggle()
                        withAnimation {
                            buttonTapped = true
                        }
                    }) {
                        Text("Grant Permission")
                            .bold()
                            .padding()
                            .foregroundStyle(.cyan)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://asw1tch.github.io/umissme-privacy-policy.html") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("View Privacy Policy")
                            .bold()
                            .padding()
                            .foregroundStyle(.cyan)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                }
                .blur(radius: buttonTapped ? 7 : 0)
                .alert("Consent Required", isPresented: $showAlert) {
                    Button("Agree") {
                        requestContactAccess()
                        withAnimation {
                            buttonTapped = true
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isUserNotAgree = true
                        buttonTapped = false
                    }
                } message: {
                    Text("By continuing, you agree that we will process your contacts securely by encrypted phone numbers and using them to find matches. No other details, like names, will be shared or uploaded.")
                }
            } else {
                VStack {
                    Text("Firstly, we need your permission to access your contacts and send notifications. To ensure your data is secure, we only use encrypted phone numbers, not names or other details. Your privacy is our priority.")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding()
                    
                    Button(action: {
                        showAlert = true
                        withAnimation {
                            buttonTapped = true
                        }
                    }) {
                        Text("Sounds good, Let’s Go")
                            .bold()
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .foregroundStyle(Color(hex: "3AD60F"))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }
                }
                .animation(.easeInOut(duration: 1), value: buttonTapped)
                .blur(radius: buttonTapped ? 7 : 0)
                .fullScreenCover(isPresented: $showNextView) {
                    SignInView(signInVM: SignInViewModel())
                }
                .alert("Consent Required", isPresented: $showAlert) {
                    Button("Agree") {
                        requestContactAccess()
                        withAnimation {
                            buttonTapped = true
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isUserNotAgree = true
                        buttonTapped = false
                    }
                } message: {
                    Text("By continuing, you agree that we will process your contacts securely by encrypted phone numbers and using them to find matches. No other details, like names, will be shared or uploaded.")
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func requestContactAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    isUserNotAgree = false
                    requestNotificationPermission()
                } else {
                    isNotGranted = true
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                showNextView = true
                print("Notification permission granted")
            } else {
                isNotGranted = true
                print("Notification permission not granted")
            }
        }
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    ContactPermissonView()
}

