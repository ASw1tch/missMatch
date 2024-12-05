//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//
import SwiftUI

struct ContactListView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel = ContactListViewModel()
    
    @State var matchedContact: Contact?
    @State var testId = ""
    @State private var isShowingMatchView = false
    @State private var isLoading = false
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    @State private var isFirstAppear = true
    @State private var showLogoutAlert = false
    
    var filteredContacts: [Contact] {
        let filtered = searchText.isEmpty
        ? viewModel.contacts
        : viewModel.contacts.filter { contact in
            contact.givenName?.lowercased().contains(searchText.lowercased()) ?? false ||
            contact.familyName?.lowercased().contains(searchText.lowercased()) ?? false
        }
        
        return filtered.sorted { contact1, contact2 in
            let isContact1Empty = (contact1.givenName?.isEmpty ?? true) && (contact1.familyName?.isEmpty ?? true)
            let isContact2Empty = (contact2.givenName?.isEmpty ?? true) && (contact2.familyName?.isEmpty ?? true)
            
            if isContact1Empty != isContact2Empty {
                return !isContact1Empty
            }
            return false
        }
    }
    
    var likedContacts: [Contact] {
        filteredContacts.filter { $0.iLiked && !$0.itsMatch}
    }
    
    var matchedContacts: [Contact] {
        filteredContacts.filter { $0.itsMatch }
    }
    
    var groupedContacts: [String: [Contact]] {
            Dictionary(grouping: filteredContacts) { contact in
            String(contact.givenName!.prefix(1)).uppercased()
        }
    }
    
    var sectionTitles: [String] {
        groupedContacts.keys.sorted()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? Color(hex: "#1e1e1e") : Color(hex: "#FEFEFA")).ignoresSafeArea()
                VStack {
                    if viewModel.isLoading {
                        VStack {
                            ProgressView("Loading contacts...")
                                .padding()
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    TextField("Search", text: $searchText)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .gray)
                                }
                                .padding(10)
                                .background(colorScheme == .dark ? Color(hex: "#303030") : Color(hex: "#f0f0f0"))
                                .cornerRadius(10)
                                
                                Section(header: Text("Matches")
                                    .font(.headline)) {
                                        ForEach(matchedContacts) { contact in
                                            ContactRowView(contact: Binding(
                                                get: { contact },
                                                set: { updatedContact in
                                                    if let index = viewModel.contacts.firstIndex(where: { $0.identifier == updatedContact.identifier }) {
                                                        viewModel.contacts[index] = updatedContact
                                                    }
                                                }), viewModel: viewModel)
                                        }
                                    }
                                
                                Section(header: Text("Liked Contacts")
                                    .font(.headline)) {
                                        ForEach(likedContacts) { contact in
                                            ContactRowView(contact: Binding(
                                                get: { contact },
                                                set: { updatedContact in
                                                    if let index = viewModel.contacts.firstIndex(where: { $0.identifier == updatedContact.identifier }) {
                                                        viewModel.contacts[index] = updatedContact
                                                    }
                                                }), viewModel: viewModel)
                                        }
                                    }
                                
                                Section(header: Text("Your Contacts")
                                    .font(.headline)) {
                                        ForEach(groupedContacts.keys.sorted(), id: \.self) { letter in
                                            Section() {
                                                ForEach(groupedContacts[letter] ?? []) { contact in
                                                    ContactRowView(contact: Binding(
                                                        get: { contact },
                                                        set: { updatedContact in
                                                            if let index = viewModel.contacts.firstIndex(where: { $0.identifier == updatedContact.identifier }) {
                                                                viewModel.contacts[index] = updatedContact
                                                            }
                                                        }), viewModel: viewModel)
                                                }
                                            }
                                        }
                                        .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0.5)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                                .blur(radius: phase.isIdentity ? 0 : 2)
                                        }
                                    }
                            }
                            .onTapGesture {
                                dismissKeyboard()
                            }
                            .padding()
                        }
                        .scrollIndicators(.visible)
                        .refreshable {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                viewModel.reloadContacts()
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.startRegularUpdates(interval: 15)
            }
            .onChange(of: viewModel.matchesToShow) {oldValue, matches in
                guard !matches.isEmpty else { return }
                for matchID in matches {
                    if let matchedContact = viewModel.contacts.first(where: { $0.identifier == matchID }) {
                        coordinator.showMatchScreen(for: matchedContact)
                        DispatchQueue.main.async {
                            viewModel.matchesToShow.remove(matchID)
                            UserDefaultsManager.shared.addShownMatches(matchID)
                        }
                    }
                }
            }
            .onChange(of: viewModel.navigateToStart) { oldValue, newValue in
                if newValue {
                    coordinator.signOutAndReturnToStart()
                }
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                switch newValue {
                case .active:
                    viewModel.processPendingMatches()
                    if viewModel.contacts.isEmpty && UserDefaultsManager.shared.hasUserInputtedPhone() {
                        viewModel.reloadContacts()
                    }
                case .inactive:
                    if !viewModel.contacts.isEmpty {
                        viewModel.saveContactsToUD(viewModel.contacts)
                    }
                case .background:
                    print("App is in background")
                default:
                    break
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        withAnimation(Animation.easeIn(duration: 3)) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .resizable()
                                .frame(width: 22, height: 25)
                                .bold()
                                .tint(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Log out and start over"),
                            message: Text("By submitting this action you will logout from this account and delete all data associated with this application from this device and server. Do you want to proceed?"),
                            primaryButton: .destructive(Text("Yes, Log me out")) {
                                viewModel.logOut()
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("I miss")
                        .font(.largeTitle)
                        .bold()
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContactListView()
}
