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
    
    @State var matchedContact: Contact?
    @State var testId = ""
    @State private var isShowingMatchView = false
    @State private var isLoading = false
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    @State private var isFirstAppear = true
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return viewModel.contacts
        } else {
            return viewModel.contacts.filter { contact in
                contact.givenName?.lowercased().contains(searchText.lowercased()) ?? false ||
                contact.familyName?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
    
    var likedContacts: [Contact] {
        filteredContacts.filter { $0.iLiked }
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
                                    Section(/*header: Text(letter)*/
                                        /*.font(.headline)*/) {
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
                                viewModel.checkAndShowMatchScreen()
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.contacts = viewModel.loadContactsFromUD() ?? []
            }
            .onDisappear {
                viewModel.saveContactsToUD(viewModel.contacts)
            }
            .onChange(of: viewModel.showMatchView) {
                if viewModel.showMatchView {
                    isShowingMatchView.toggle()
                    if let matchedContact = viewModel.contacts.first(where: { $0.itsMatch }) {
                        coordinator.showMatchScreen(for: matchedContact)
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        //viewModel.logout()
                    }) {
                        withAnimation(Animation.easeIn(duration: 3)) {
                                Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .resizable()
                                .frame(width: 20, height: 25)
                                .bold()
                                .tint(Color(.black ))
                        }
                        
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
    
    func reloadContacts() {
        viewModel.isLoading = true
        viewModel.fetchContacts { contactList in
            viewModel.sendContactsToServer(contactList: contactList)
        }
        viewModel.isLoading.toggle()
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContactListView()
}
