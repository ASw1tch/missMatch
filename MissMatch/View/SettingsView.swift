//
//  SettingsView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 12.12.24..
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel = ContactListViewModel()
    
    @State private var showLogoutAlert = false
    @State private var randomEmoji: String = ""
    
    let emojis = ["😏", "🙂‍↕️", "😗", "🙃", "🤨", "🫨", "😬", "😩", "🤪", "🥳", "😎", "☺️", "😮‍💨", "🤤", "🥹", "🥺"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .bold()
                    .padding()
                
                Circle()
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.7) : Color.blue.opacity(0.4))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(randomEmoji)
                            .font(.largeTitle)
                            .bold()
                    )
                    .padding(.bottom, 10)
               
                Text(UserDefaultsManager.shared.getUserDisplayName() ?? "Unknown User")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(UserDefaultsManager.shared.getUserDisplayPhone() ?? "")
                Button(action: {
                    showLogoutAlert = true
                })
                {
                    Text("Delete account")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                }
                .padding()
                Spacer()
            }
            .onAppear {
                randomEmoji = emojis.randomElement() ?? "❓"
            }
            .onChange(of: viewModel.navigateToStart) { oldValue, newValue in
                if newValue {
                    coordinator.signOutAndReturnToStart()
                }
            }
            .onChange(of: viewModel.matchesToShow) {oldValue, matches in
                guard !matches.isEmpty else { return }
                    dismiss()
            }
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Log out and Delete account"),
                    message: Text("By submitting this action you will log out and delete this account, and delete all data associated with this application from this device and server. Do you want to proceed?"),
                    primaryButton: .destructive(Text("Yes, I do")) {
                            viewModel.logOut()
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

