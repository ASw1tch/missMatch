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
                    Text("Without contacts access, the app won't work🥺. Pick up at least one contact")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(20)
                    
                    Button(action: {
                        openAppSettings()
                        isNotGranted = false
                        buttonTapped = false
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .bold()
                            .foregroundStyle(.green)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }.padding(20)
                    
                    Button(action: {
                        if let url = URL(string: "https://asw1tch.github.io/umissme-privacy-policy.html") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Text("View Privacy Policy")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.cyan)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }.padding(.horizontal, 20)
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
                    Text("Firstly, we need your permission to access your contacts. To ensure your data is secure, we only use encrypted phone numbers, not names or other details. Your privacy is our priority.")
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
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemBackground))
                            .foregroundStyle(Color(hex: "3AD60F"))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }.padding(20)
                }
                .animation(.easeInOut(duration: 1), value: buttonTapped)
                .blur(radius: buttonTapped ? 7 : 0)
                .fullScreenCover(isPresented: $showNextView) {
                    SignInView(signInVM: SignInViewModel())
                }
                .alert("Access Contacts", isPresented: $showAlert) {
                    Button("Continue") {
                        requestContactAccess()
                        withAnimation {
                            buttonTapped = true
                        }
                    }
                    Button(action: {
                        if let url = URL(string: "https://asw1tch.github.io/umissme-privacy-policy.html") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            buttonTapped = false
                        }
                    }) {
                        Text("View Privacy Policy")
                    }
                } message: {
                    Text("We use your encrypted phone numbers contacts to match you with your friends on the platform. No other details will be shared or uploaded. For more information visit our privacy policy.")
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func checkIfContactsExist(completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let contactStore = CNContactStore()
            let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor])
            var contactExists = false
            
            do {
                try contactStore.enumerateContacts(with: fetchRequest) { _, stop in
                    contactExists = true
                    stop.pointee = true
                }
            } catch {
                print("Ошибка при проверке доступности контактов: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(contactExists)
            }
        }
    }
    private func requestContactAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
                    if #available(iOS 18.0, *) {
                        if authorizationStatus == .limited || authorizationStatus == .authorized {
                            checkIfContactsExist { exists in
                                if exists {
                                    print("Contacts exist")
                                    isNotGranted = false
                                    requestNotificationPermission()
                                } else {
                                    print("No contacts available")
                                    isNotGranted = true
                                }
                            }
                        }
                    } else {
                        // < iOS 18
                        isNotGranted = false
                        requestNotificationPermission()
                    }
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
                showNextView = true
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

