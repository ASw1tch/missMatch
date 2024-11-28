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
    @State private var animateHearts = false
    
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
        .cornerRadius(14)
        .overlay(content: {
            contactFrame
        })
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
        .foregroundStyle(contact.itsMatch ? .pink : .gray)
        .opacity(contact.itsMatch ? 0.7 : 0.8)
    }
    
    private var likeButton: some View {
        Button(action: handleButtonAction) {
            Image(systemName: heartImage)
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(heartColor)
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
    
    private var heartColor: LinearGradient {
        switch heartState {
        case .standBy:
            return LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.6), .gray]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .liked:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#fff1ff"), Color(hex: "#ffa7ff")]),
                startPoint: .bottom,
                endPoint: .topLeading
                )
        case .matched:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#00ff7f"), Color(hex: "#32cd32")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var contactFrame: some View {
        switch heartState {
        case .standBy:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#484848"), lineWidth: 1)
        case .liked:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#ffa7ff"), lineWidth: 1)
        case .matched:
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#ffa7ff"), lineWidth: 1)
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
            Color(colorScheme == .dark ? Color(hex: "#1e1e1e") : Color(hex: "#FEFEFA"))
        }
    }
    
    @ViewBuilder
    private var heartsOverlay: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#ffa7ff"), Color(hex: "#fff1ff")],
                           startPoint: .leading,
                           endPoint: .trailing)
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.pink.opacity(0.6))
                    .position(
                        x: animateHearts ? CGFloat.random(in: 10...300) : CGFloat.random(in: 10...300),
                        y: animateHearts ? CGFloat.random(in: 10...50) : CGFloat.random(in: 10...50)
                    )
                    .opacity(0.2)
                    .animation(
                        Animation.snappy(duration: 10)
                            .repeatForever(autoreverses: true),
                        value: animateHearts
                    )
            }
        }
        HStack(spacing: 4){
            Spacer()
            Text("Message")
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 8, height: 12)
                .opacity(0.4)
                
        }
        .padding()
        .opacity(0.4)
        .foregroundStyle(.pink)
        .onAppear {
            animateHearts.toggle()
        }
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.5)
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
