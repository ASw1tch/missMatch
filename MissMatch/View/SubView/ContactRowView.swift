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
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ContactListViewModel
    @State private var showAlert = false
    @State private var showMatchView = false
    @State private var showPaywall = false
    
    private let likesRepository = LikesRepository()
    @State var contact: Contact
    
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
        .sheet(isPresented: $showMatchView) {
            ItsAMatchView(contact: contact)
        }
    }
    
    // Contact info section
    private var contactInfo: some View {
        HStack {
            Text(contact.givenName ?? "Undefined name").bold()
            Text(contact.familyName ?? "Undefined surname")
        }
    }
    
    // Like button with state
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
        if contact.iLiked {
            // Удаляем лайк
            removeLike(contactID: contact.id)
        } else {
            // Проверяем, можно ли поставить лайк
            if !likesRepository.canLike() {
                showAlert = true
                return
            }
            // Добавляем лайк
            sendLikeRequest(contactID: contact.id, remove: false)
        }
        
    }
    // Функция для отправки лайка на сервер
    func sendLikeRequest(contactID: String, remove: Bool) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
//            showErrorPopup = true
//            errorMessage = "Apple ID is not found."
            return
        }
        let likeRequest = Like(fromUserID: appleIdUser, toContactID: contactID)
        // Преобразуем ContactList в JSON Data
        guard let requestBody = try? JSONEncoder().encode(likeRequest) else {
//            showErrorPopup = true
//            errorMessage = "Can't convert contact data to JSON."
            return
        }
        

//        isLoading = true
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
//                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.success {
                        print("Response: \(response.likes)")
                        
                        // 1. Очистить все лайки
                        UserDefaultsManager.shared.removeAllLikes()
                        
                        // 2. Сохранить новые лайки
                        let newLikes = response.likes // это массив contactId, который ты получаешь от сервера
                        
                        for contactID in newLikes {
                            UserDefaultsManager.shared.saveLike(contactID: contactID)
                        }
                
                        if remove {
                            contact.iLiked = false
                        } else {
                            contact.iLiked = newLikes.contains(contact.id)
                        }
                        
                        print(UserDefaultsManager.shared.getLikes()) // Проверить, что лайки сохранились
                    } else {
//                        self.showErrorPopup = true
//                        self.errorMessage = "Server responded with an error: \(response.message)"
                        print("Server error: \(response.message)")
                    }
                case .failure(let error):
//                    self.showErrorPopup = true
//                    self.errorMessage = "Error: \(error.localizedDescription)"
                    print("Request failed: \(error)")
                }
            }
        }
    }
    
    // Функция для удаления лайка
    private func removeLike(contactID: String) {
        sendLikeRequest(contactID: contactID, remove: true)
    }
    
    
    // Heart image based on state
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
    
    // Heart color based on state
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
    
    // Heart state based on contact properties
    private var heartState: HeartState {
        if contact.itsMatch {
            return .matched
        } else if contact.iLiked {
            return .liked
        } else {
            return .standBy
        }
    }
    
    // Background for matched contacts
    @ViewBuilder
    private var contactBackground: some View {
        if contact.itsMatch {
            heartsOverlay
        } else {
            Color(UIColor.systemBackground)
        }
    }
    
    // Hearts overlay for matched contacts
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
    
    // Shadow color based on color scheme
    private var shadowColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray
    }
    
    // Alert view for paywall
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
            let sampleContact = Contact(identifier: "22", givenName: "Mary", familyName: "Smith", phoneNumbers: ["+79332231312"])
            let viewModel = ContactListViewModel()
            viewModel.contacts = [sampleContact]
            
            return ContactRowView(viewModel: viewModel, contact: sampleContact)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
