//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

struct ContactListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coordinator: AppCoordinator
    
    @ObservedObject var viewModel = ContactListViewModel()
    @State var showMatchView = false
    @State var matchedContact: Contact?
    @State var testId = ""
    @State private var isLoading = false
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    VStack {
                        ProgressView("Loading contacts...")
                            .padding()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("I miss...")
                                .font(.largeTitle)
                                .bold()
                                .padding()
            
                            Button("Go to Match Screen") {
                                coordinator.showMatchScreen(for: Contact(identifier: "1", givenName: "Test", familyName: "User", phoneNumbers: []))
                            }
                            
                            ForEach($viewModel.contacts.sorted(by: {
                                ($0.givenName.wrappedValue ?? "") < ($1.givenName.wrappedValue ?? "")
                            })) { $contact in
                                ContactRowView(contact: $contact, viewModel: viewModel)
                            }
                            .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                        }
                        .padding()
                    }
                    .scrollIndicators(.never)
                }
            }.background(Color(UIColor.systemBackground))
        }
        .onAppear {
            print("OnAppear")
            reloadContacts()
            startTimer()
            checkAndShowMatchScreen()
        }
        .onDisappear {
            viewModel.stopRegularUpdates()
            viewModel.maxRetryContactListCount = 0
            viewModel.maxRetryMatchesCount = 0
        }
    }
    
    func reloadContacts() {
        viewModel.isLoading = true
        showErrorPopup = false
        errorMessage = ""
        viewModel.fetchContacts { contactList in
            viewModel.sendContactsToServer(contactList: contactList)
        }
        viewModel.isLoading.toggle()
    }
    
    func startTimer() {
        viewModel.startRegularUpdates(interval: 10)
    }
    
    func checkAndShowMatchScreen() {
        print("Application state: \(UIApplication.shared.applicationState)")
        viewModel.getMatches { newMatchID in
            guard let matchID = newMatchID else { return }
            
            if let matchedContact = viewModel.contacts.first(where: { $0.identifier == matchID }) {
                
                if UIApplication.shared.applicationState == .active {
                    print("App is active, showing match view.")
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            coordinator.showMatchScreen(for: matchedContact)
                        }
                    }
                } else {
                    
                    viewModel.scheduleLocalNotification(contact: matchedContact)
                }
            }
        }
    }
}

#Preview {
    ContactListView()
}
