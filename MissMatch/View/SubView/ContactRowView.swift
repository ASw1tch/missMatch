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
        .onTapGesture {
            if heartState == .matched {
                openMessagesApp()
            }
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
    
    private func openMessagesApp() {
        if let phoneNumber = contact.phoneNumbers.first, let url = URL(string: "sms:\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func handleButtonAction() {
        print("Contact is liked: \(contact.iLiked)")
        if !contact.iLiked {
            if !likesRepository.canLike() {
                showAlert = true
                return
            } else {
                print("Contact is liked")
                UserDefaultsManager.shared.saveLike(contactID: contact.id)
                sendLikeRequest(contactID: contact.id, remove: false)
                contact.iLiked.toggle()
            }
        } else {
            print("Contact is unliked")
            UserDefaultsManager.shared.removeLike(contactID: contact.id)
            sendLikeRequest(contactID: contact.id, remove: true)
            contact.iLiked.toggle()
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
                        print("Likes on server: \(response.likes)")
                        print("Likes on phone: \(UserDefaultsManager.shared.getLikes())")
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
            return " "
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
                .frame(width: 50, height: 50)
                .position(x: 330, y: 63)
                .rotationEffect(.degrees(-15))
                .blur(radius: 1.5)
            Text("Press to text")
                .font(.caption)
                .foregroundStyle(.gray)
                .opacity(0.5)
            Image(systemName: "heart")
                .resizable()
                .foregroundStyle(Color(hex: "7D8ABC"))
                .frame(width: 30, height: 30)
                .position(x: 350, y: -25)
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

struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContactRowView(
            contact: .constant(Contact(
                identifier: "1",
                givenName: "John",
                familyName: "Doe",
                phoneNumbers: ["+123456789"],
                iLiked: true,
                itsMatch: true
            )),
            viewModel: ContactListViewModel()
        )
        .previewLayout(.sizeThatFits)
    }
}
