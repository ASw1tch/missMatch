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
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white)
            if isNotGranted {
                VStack {
                    Text("Without contacts access, the app won't work. :(")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(20)
                    
                    Button(action: {
                        openAppSettings()
                    }) {
                        Text("Go to Settings")
                            .bold()
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                    }
                    .padding(.top, 10)
                }
            } else {
                GeometryReader { geometry in
                    ZStack {
                        Text("Firstly give us permission to use your contacts and notifications")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .position(x: geometry.size.width / 2.2 , y: geometry.size.height / 4)
                            .bold()
                            .padding()
                    }
                }
                .fullScreenCover(isPresented: $showNextView) {
                    SignInView(signInVM: SignInViewModel())
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        requestContactAccess()
                    }
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
                showNextView = true
                print("Notification permission granted")
            } else {
                isNotGranted = true
                print("Notification permission denied")
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

