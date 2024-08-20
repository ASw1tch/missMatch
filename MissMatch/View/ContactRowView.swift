//
//  ContactRowView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

struct ContactRowView: View {
    
    enum HeartState {
        case standBy
        case liked
        case matched
    }
    
    enum LikeButtonState {
        case ready
        case pushed
        case inactive
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ContactListViewModel
    @State private var showAlert = false
    @State private var showMatchView = false
    @State private var showPaywall = false
    
    var contact: ContactList
    
    var heartState: HeartState {
        if contact.itsMatch {
            return .matched
        } else if contact.iLiked {
            return .liked
        } else {
            return .standBy
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                Text(contact.name).bold()
                Text(contact.surname)
                Spacer()
                
                Button(action: handleButtonAction) {
                    Image(systemName: {
                        switch heartState {
                        case .standBy:
                            return "heart"
                        case .liked:
                            return "heart.fill"
                        case .matched:
                            return "checkmark.message.fill"
                        }
                    }())
                    .foregroundColor({
                        switch heartState {
                        case .standBy:
                            return .gray
                        case .liked:
                            return .red
                        case .matched:
                            return .green
                        }
                    }())
                }.disabled(contact.itsMatch)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Limit Reached"),
                            message: Text("You have reached the maximum number of free hearts. Please upgrade to premium to add more."),
                            primaryButton: .default(Text("Extend quota for $1.99 for 5 more")) {
                                showPaywall = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .fullScreenCover(isPresented: $showPaywall) {
                        PayWallView() // Ваш экран с оплатой
                    }
            }
        }
        .padding()
        .background(content: {
            self.contact.itsMatch ? hearts() : nil
        })
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
        .sheet(isPresented: $showMatchView) {
            ItsAMatchView(contact: contact)
        }
    }
    
    private func handleButtonAction() {
        guard !contact.iLiked else {
            viewModel.toggleMiss(contact: contact)
            return
        }
        guard viewModel.heartCount < viewModel.maxFreeHearts else {
            showAlert = true
            return
        }
        viewModel.toggleMiss(contact: contact)
        if viewModel.matched {
            viewModel.matched.toggle()
            showMatchView = true
        }
    }
}

@ViewBuilder
func hearts() -> some View {
    Image(systemName: "heart.fill")
        .resizable()
        .foregroundStyle(Color(hex: "FFC7ED"))
        .frame(width: 60, height: 60)
        .position(x: 190, y: 35)
        .rotationEffect(.degrees(-15))
        .blur(radius: 1.5)
    
    Image(systemName: "heart")
        .resizable()
        .foregroundStyle(Color(hex: "7D8ABC"))
        .frame(width: 30, height: 30)
        .position(x: 210, y: 30)
        .rotationEffect(.degrees(20))
        .shadow(radius: 10)
}
struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleContact = ContactList(id: 22, name: "Mary", surname: "Smith", phoneNumber: ["+79332231312"])
        let viewModel = ContactListViewModel()
        viewModel.contacts = [sampleContact]
        
        return ContactRowView(viewModel: viewModel, contact: sampleContact)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}



