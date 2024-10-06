//
//  ContactRowView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

struct ContactRowView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var contact: Contact
    @ObservedObject var viewModel: ContactListViewModel
    
    @State private var showAlert = false
    @State private var showMatchView = false
    @State private var showPaywall = false
    
    private let likesRepository = LikesRepository()
    
    enum HeartState {
        case standBy
        case liked
        case matched
    }
    
    var body: some View {
        HStack {
            contactInfo
            Spacer()
            likeButton
        }
        .padding()
        .background(contactBackground)
        .cornerRadius(8)
        .shadow(color: shadowColor, radius: 3, x: 0, y: 2)
        .onAppear {
        }
    }
    
    private var contactInfo: some View {
        HStack {
            Text(contact.givenName ?? "Undefined name").bold()
            Text(contact.familyName ?? "Undefined surname")
        }
    }
    
    private var likeButton: some View {
        Button(action: handleButtonAction) {
            Image(systemName: heartImage)
                .foregroundColor(heartColor)
        }
        .disabled(contact.itsMatch)
        .alert(isPresented: $showAlert) {
            alertView
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PayWallView()
        }
    }
    
    private func handleButtonAction() {
        print("Contact is liked: \(contact.iLiked)")
        contact.iLiked.toggle()
        if contact.iLiked {
            if !likesRepository.canLike() {
                showAlert = true
                return
            } else {
                print("Contact is liked")
                UserDefaultsManager.shared.saveLike(contactID: contact.id)
                sendLikeRequest(contactID: contact.id, remove: false)
            }
        } else {
            print("Contact is unliked")
            UserDefaultsManager.shared.removeLike(contactID: contact.id)
            sendLikeRequest(contactID: contact.id, remove: true)
        }
    }
    
    func sendLikeRequest(contactID: String, remove: Bool) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            return
        }
        let likeRequest = Like(fromUserID: appleIdUser, toContactID: contactID)
        guard let requestBody = try? JSONEncoder().encode(likeRequest) else {
            return
        }
        let headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue,
            .accept: HTTPHeaderValue.acceptAll.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: remove ? API.removeLikeApiUrl : API.likesApiUrl,
            method: remove ? .DELETE : .POST,
            headers: headers,
            body: requestBody,
            responseType: LikeResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("Response: \(response.likes)")
                        print(UserDefaultsManager.shared.getLikes())
                    } else {
                        print("Server error: \(response.message)")
                    }
                case .failure(let error):
                    print("Request failed: \(error)")
                }
            }
        }
    }
    
    private var heartImage: String {
        switch heartState {
        case .standBy:
            return "heart"
        case .liked:
            return "heart.fill"
        case .matched:
            return "checkmark.message.fill"
        }
    }
    
    private var heartColor: Color {
        switch heartState {
        case .standBy:
            return .gray
        case .liked:
            return .red
        case .matched:
            return .green
        }
    }
    
    private var heartState: HeartState {
        if contact.itsMatch {
            return .matched
        } else if contact.iLiked {
            return .liked
        } else {
            return .standBy
        }
    }
    
    @ViewBuilder
    private var contactBackground: some View {
        if contact.itsMatch {
            heartsOverlay
        } else {
            Color(UIColor.systemBackground)
        }
    }
    
    @ViewBuilder
    private var heartsOverlay: some View {
        ZStack {
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
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray
    }
    
    private var alertView: Alert {
        Alert(
            title: Text("Limit Reached"),
            message: Text("You have reached the maximum number of free hearts. Please upgrade to premium to add more."),
            primaryButton: .default(Text("Extend quota for $1.99 for 5 more")) {
                showPaywall = true
            },
            secondaryButton: .cancel()
        )
    }
}
