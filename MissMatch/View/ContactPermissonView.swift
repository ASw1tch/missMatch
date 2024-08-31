//
//  ContactPermissonView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.8.24..
//

import SwiftUI
import Contacts

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
                        Text("Firstly give us permission to use your contacts")
                            .font(.title)
                            .foregroundStyle(.secondary)
                            .position(x: geometry.size.width / 2.2 , y: geometry.size.height / 4)
                            .bold()
                            .padding()
                        VStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 5)
                                .background(Color(UIColor.systemBackground))
                                .frame(width: 320, height: 230)
                                .cornerRadius(10)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + geometry.size.height * 0.011)
                        }
                    }
                }
                .fullScreenCover(isPresented: $showNextView) {
                    SignInView()
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
                    showNextView = true
                } else {
                    isNotGranted = true
                }
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

