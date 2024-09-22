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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("I miss...")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    ForEach(viewModel.contacts
                        .filter { contact in
                            !contact.givenName.isEmpty || !contact.familyName.isEmpty
                        }
                        .sorted { $0.givenName < $1.givenName }) { contact in
                            ContactRowView(viewModel: viewModel, contact: contact)
                        }
                }
                .padding()
            }
            .scrollIndicators(.never)
        }
        .onAppear {
            viewModel.fetchContacts { contactList in
                viewModel.sendContactsToServer(contactList: contactList)
            }
        }
    }
}

#Preview {
    ContactListView()
}


