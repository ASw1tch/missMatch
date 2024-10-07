//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

struct ContactListView: View {
    
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
                } else if viewModel.showErrorPopup {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                        Button(action: {
                            reloadContacts()
                        }) {
                            Text("Retry")
                        }
                        .padding()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("I miss...")
                                .font(.largeTitle)
                                .bold()
                                .padding()
                            
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
            }
        }
        .onAppear {
            reloadContacts()
            startTimer()
            checkAndShowMatchScreen()
            viewModel.checkAndSendLikeDifferences()
        }
        .fullScreenCover(item: $matchedContact) { contact in
            ItsAMatchView(contact: contact)
        }
        .onDisappear {
            viewModel.stopRegularUpdates()
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
        viewModel.getMatches { newMatchID in
            guard let matchID = newMatchID else { return }
            
            if let matchedContact = viewModel.contacts.first(where: { $0.identifier == matchID }) {
                // Показ экрана мэтча
                self.matchedContact = matchedContact
                self.showMatchView = true
                
                // Отправка уведомления
                viewModel.scheduleLocalNotification(contact: matchedContact)
                
                // Обновление показанных мэтчей
                var shownMatches = UserDefaults.standard.array(forKey: "shownMatches") as? [String] ?? []
                shownMatches.append(matchID)
                UserDefaults.standard.set(shownMatches, forKey: "shownMatches")
            }
        }
    }
}

#Preview {
    ContactListView()
}
