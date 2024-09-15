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
            viewModel.getAllContacts()
        }
    }
}

#Preview {
    ContactListView()
}


