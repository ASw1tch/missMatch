//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

struct ContactListView: View {
    @StateObject var viewModel = ContactListViewModel()
    @State private var selectedContact: ContactList? = nil
    @State var showMatchView = false
    @State var testId = ""
    
    
    var body: some View {
        NavigationStack {
    
            HStack {
            TextField("ID", text: $testId)
                .keyboardType(.phonePad)
                .bold()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                Button(action: {
                    let contactArray: [Contact] = viewModel.contacts
                        .map { Contact(phones: $0.phoneNumber) }
                    
                    let contactRequest = SaveContactRequest(userId: Int(testId) ?? 16, contacts: contactArray)
//                    print(contactRequest)
                    
                    NetworkManager.shared.postData(for: .contacts(contactRequest))
                }) {
                    Text("SendData")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                .disabled(testId.isEmpty)
        }
        .padding()
        .foregroundColor(Color.primary)
        
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("I miss...")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                    ForEach(viewModel.contacts
                        .filter { contact in
                            !contact.name.isEmpty ||
                            !contact.surname.isEmpty
                        }
                        .sorted { $0.name < $1.name }) { contact in
                            ContactRowView(viewModel: viewModel, contact: contact)
                        }.scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                }
                .padding()
            }
            .scrollIndicators(.never)
        }.onAppear {
            viewModel.fetchAllContacts()
            viewModel.getAllContacts()
            viewModel.fetchMyPhoneNumbers()
        }
    }
}

#Preview {
    ContactListView()
}


