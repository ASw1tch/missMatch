//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..

import Foundation
import Contacts
import Combine
import SwiftUI
import UserNotifications

class ContactListViewModel: ObservableObject {
    @EnvironmentObject var coordinator: AppCoordinator
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    @Published var navigateToStart = false
    @Published var showMatchView: Bool = false

    private var retryCount = 0
    var maxRetryContactListCount = 3
    var maxRetryMatchesCount = 3
    private let maxRetryCount = 2
    
    init() {
        maxRetryContactListCount = 0
        maxRetryContactListCount = 0
    }
    
    
    func fetchContacts(completion: @escaping (ContactList) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    DispatchQueue.main.async {
                        self.showErrorPopup = true
                        self.errorMessage = "Access to contacts was not granted."
                    }
                    return
                }
                
                var contacts = [Contact]()
                let keys = [CNContactGivenNameKey,
                            CNContactPhoneNumbersKey,
                            CNContactFamilyNameKey,
                            CNContactIdentifierKey] as [CNKeyDescriptor]
                let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    try store.enumerateContacts(with: fetchRequest) { (cnContact, stop) in
                        let phoneNumbers = cnContact.phoneNumbers.map { $0.value.stringValue }
                        let normalizedPhoneNumbers = PhoneNumberManager.normalizePhoneNumbers(phoneNumbers)
                        
                        let likedContacts = UserDefaultsManager.shared.getLikes()
                        let matchedContacts = UserDefaultsManager.shared.getMatches()
                        
                        
                        let contact = Contact(
                            identifier: cnContact.identifier,
                            givenName: cnContact.givenName,
                            familyName: cnContact.familyName,
                            phoneNumbers: normalizedPhoneNumbers,
                            iLiked: likedContacts.contains(cnContact.identifier),
                            itsMatch: matchedContacts.contains(cnContact.identifier)
                        )
                        contacts.append(contact)
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = contacts
                        self.saveContactsToUD(contacts)
                        self.isLoading = false
                        
                        let contactList = self.sortContactsForServer(userID: UserDefaultsManager.shared.getAppleId() ?? "No Apple Id", contacts: contacts)
                        
                        completion(contactList)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showErrorPopup = true
                        self.errorMessage = "Failed to fetch contacts."
                    }
                }
            }
        }
    }
    
    func sendContactsToServer(contactList: ContactList) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            showErrorPopup = true
            errorMessage = "Apple ID is not found."
            return
        }
        
        guard let requestBody = try? JSONEncoder().encode(contactList) else {
            showErrorPopup = true
            errorMessage = "Can't convert contact data to JSON."
            return
        }
        
        isLoading = true
        let headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue,
            .accept: HTTPHeaderValue.acceptAll.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: API.contactsApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: ContactsResponse.self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if response.isSuccessful {
                        self.errorMessage = response.message
                        UserDefaultsManager.shared.removeAllContacts()
                        for contact in response.contacts {
                            UserDefaultsManager.shared.saveContactPhones(for: contact.contactId, phoneNumbers: contact.phones)
                        }
                    }
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    self.handleUserSendingError(error: error, contactList: contactList)
                }
            }
        }
    }
    
    private func handleUserSendingError(error: NetworkError, contactList: ContactList) {
        switch error {
        case .badRequest:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .invalidToken, .userNotFound:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            self.navigateToStart = true
            
        case .tokenRevokeFailed:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .phonesCannotBeEmpty, .phoneAlreadyAssigned:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .internalServerError:
            if retryCount < maxRetryContactListCount {
                retryCount += 1
                print("Rertying Contacts")
                self.errorMessage = "Rertying Contacts"
                self.showErrorPopup = true
                // Логика для повторного запроса через 1 секунду
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendContactsToServer(contactList: contactList)
                }
            } else {
                // Ошибка после 3 попыток
                self.errorMessage = "Something goes wrong. Try Again later."
                self.showErrorPopup = true
            }
            
        case .customError:
            if retryCount < maxRetryContactListCount {
                retryCount += 1
                print("Rertying Contacts")
                self.errorMessage = "Rertying Contacts"
                self.showErrorPopup = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendContactsToServer(contactList: contactList)
                }
            } else {
                print("Custom Error")
                self.errorMessage = "Something goes wrong! Try Again later!"
                self.showErrorPopup = true
            }
        }
    }
    
    func sortContactsForServer(userID: String, contacts: [Contact]) -> ContactList {
        var toAdd = [To]()
        var toUpdate = [To]()
        var toRemove = [String]()
        
        toUpdate.removeAll()
        toAdd.removeAll()
        toRemove.removeAll()
        
        let savedContacts = UserDefaultsManager.shared.getAllContacts()
        
        for contact in contacts {
            let hashedPhoneNumbers = PhoneNumberManager.hashPhoneNumders(contact.phoneNumbers)
            
            if let savedPhones = UserDefaultsManager.shared.getContactPhones(for: contact.identifier) {
                let sortedSavedPhones = savedPhones.sorted()
                let sortedCurrentPhones = hashedPhoneNumbers.sorted()

                if sortedSavedPhones != sortedCurrentPhones {
                    let toUpdateContact = To(contactID: contact.identifier, phones: hashedPhoneNumbers)
                    toUpdate.append(toUpdateContact)
                }
            } else {
                let toAddContact = To(contactID: contact.identifier, phones: hashedPhoneNumbers)
                toAdd.append(toAddContact)
            }
        }
        
        // To Remove
        for savedContactID in savedContacts.keys {
            if !contacts.contains(where: { $0.identifier == savedContactID }) {
                toRemove.append(savedContactID)
                UserDefaultsManager.shared.removeContact(for: savedContactID)
            }
        }
        
        return ContactList(
            userID: userID,
            toAdd: toAdd,
            toUpdate: toUpdate,
            toRemove: toRemove
        )
    }
    
    func mapDTOToContact(contactDTOs: [ContactDTO], localContacts: [Contact]) -> [Contact] {
        return contactDTOs.compactMap { dto in
            if let matchingLocalContact = localContacts.first(where: { $0.identifier == dto.contactId }) {
                // Если найден локальный контакт по идентификатору, используем его имена
                return Contact(
                    identifier: dto.contactId,
                    givenName: matchingLocalContact.givenName,
                    familyName: matchingLocalContact.familyName,
                    phoneNumbers: dto.phones
                )
            } else {
                // Если не найден локальный контакт, просто возвращаем данные с сервера
                return Contact(
                    identifier: dto.contactId,
                    givenName: nil,
                    familyName: nil,
                    phoneNumbers: dto.phones
                )
            }
        }
    }
    
    func getMatches(completion: @escaping (String?) -> Void) {
        let headers: [HTTPHeaderField: String] = [:]
        
        NetworkManager.shared.sendRequest(
            to: API.matchApiUrl,
            method: .GET,
            headers: headers,
            body: nil,
            responseType: MatchResponse.self
        ) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let response):
                    print("Matches received from server: \(response.contactIDS)")
                    completion(response.contactIDS.first)
                case .failure(let error):
                    self.handleUserSendingMatchesError(error: error) {
                        self.getMatches(completion: completion)
                    }
                }
            }
        }
    }

    private func handleUserSendingMatchesError(error: NetworkError, retryAction: @escaping () -> Void) {
        
        switch error {
        case .badRequest:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .invalidToken, .userNotFound:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            self.navigateToStart = true
            
        case .tokenRevokeFailed:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .phonesCannotBeEmpty, .phoneAlreadyAssigned:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .internalServerError:
            if retryCount < maxRetryMatchesCount {
                retryCount += 1
                print("Rertying Matches")
                self.errorMessage = "Rertying Matches"
                self.showErrorPopup = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    retryAction()
                }
            } else {
                self.errorMessage = "Matches currently unavailable"
                self.showErrorPopup = true
            }
            
        case .customError:
            if retryCount < maxRetryMatchesCount {
                retryCount += 1
                print("Rertying Matches")
                self.errorMessage = "Rertying Matches"
                self.showErrorPopup = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    retryAction()
                }
            } else {
                print("Custom Error")
                self.errorMessage = "Something goes wrong! Try Again later!"
                self.showErrorPopup = true
            }
        }
    }

    var timer: Timer?
    
    func startRegularUpdates(interval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkAndShowMatchScreen()
            self?.checkExistingMatches()
           //self?.checkAndSendLikeDifferences()
        }
    }
    
    func checkAndShowMatchScreen() {
        // Получаем новые матчи и обновляем контакты
        self.getMatches { [self] newMatchID in
            guard let matchID = newMatchID else { return }
            
            // Обновляем статус матчей у контактов
            for index in  self.contacts.indices {
                if self.contacts[index].identifier == matchID {
                    self.contacts[index].itsMatch = true
                
                    let matchResponse = MatchResponse(contactIDS: [matchID])
                    UserDefaultsManager.shared.saveMatches(matchResponse)
                }
            }
            saveContactsToUD(self.contacts)
            
            // Ищем контакт, чтобы показать матч
            if UIApplication.shared.applicationState == .active {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.showMatchView = true
                    }
                }
            } else {
                // Если приложение не активно, показываем локальное уведомление
                if let matchedContact = self.contacts.first(where: { $0.identifier == matchID }) {
                    self.scheduleLocalNotification(contact: matchedContact)
                }
            }
        }
    }
    
    func checkExistingMatches() {
        if let matchedContact = self.contacts.first(where: { $0.itsMatch }) {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.showMatchView = true
                }
            }
        }
    }
    
    func scheduleLocalNotification(contact: Contact) {
        let content = UNMutableNotificationContent()
        content.title = "It's a Match!"
        content.body = "You and \(contact.givenName ?? "") \(contact.familyName ?? "") have matched!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "matchNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func stopRegularUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    func sendLikeServerDifferenceRequest(toContactIDs: [String]) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            return
        }
        let likeArrayRequest = LikeArray(fromUserID: appleIdUser, toContactIDs: toContactIDs)
        guard let requestBody = try? JSONEncoder().encode(likeArrayRequest) else {
            return
        }
        let headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue,
            .accept: HTTPHeaderValue.acceptAll.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: API.likeArrayApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: LikeArrayResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        UserDefaultsManager.shared.removeAllServerLikes()
                        UserDefaultsManager.shared.saveServerLike(contactIDs: response.likes)
                        print("Server likes: \(UserDefaultsManager.shared.getServerLikes())")
                        print("Phone likes: \(UserDefaultsManager.shared.getLikes())")
                    } else {
                        print("Server error: \(response.message)")
                    }
                case .failure(let error):
                    print("Request failed: \(error)")
                }
            }
        }
    }
    
    func logOut() {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            showErrorPopup = true
            errorMessage = "Apple ID is not found."
            return
        }
        
        guard let requestBody = appleIdUser.data(using: .utf8) else {
            showErrorPopup = true
            errorMessage = "Can't convert Apple ID to Data."
            return
        }
        
        isLoading = true
        let headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue
        ]
        
        NetworkManager.shared.sendRequest(
            to: API.logOutApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: String.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    print("Response: \(response)")
                    self?.showErrorPopup = true
                    self?.errorMessage = "User logged out successfully: \(response)"
                    UserDefaultsManager.shared.resetAllValues()
                    self?.navigateToStart = true
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    self?.handleUserSendingError(error: error)
                }
            }
        }
    }
    
    private func handleUserSendingError(error: NetworkError) {
        defer {
            retryCount = 0
        }
        switch error {
        case .badRequest:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .invalidToken, .userNotFound:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            self.navigateToStart = true
            
        case .tokenRevokeFailed:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .phonesCannotBeEmpty, .phoneAlreadyAssigned:
            self.errorMessage = error.localizedDescription
            self.showErrorPopup = true
            
        case .internalServerError:
            if retryCount < maxRetryCount {
                retryCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.logOut()
                }
            } else {
                self.errorMessage = "Error. Please try again later."
                self.showErrorPopup = true
            }
            
        case .customError(let message):
            print("Custom Error")
            self.errorMessage = message
            self.showErrorPopup = true
        }
    }
    
    func checkLikesDifferences() -> [String]? {
        let onPhone = UserDefaultsManager.shared.getLikes()
        print(onPhone)
        let onServer = UserDefaultsManager.shared.getServerLikes()
        print(onServer)
        let differences = Set(onPhone).symmetricDifference(Set(onServer))
        return differences.isEmpty ? nil : Array(differences)
    }
    
    func checkAndSendLikeDifferences() {
        if let differences = checkLikesDifferences() {
            print("Likes are different, sending difference.")
            sendLikeServerDifferenceRequest(toContactIDs: differences)
        } else {
            print("Likes is up to date.")
        }
    }
    
    func saveContactsToUD(_ contacts: [Contact]) {
        resetSavedContacts()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: "savedContacts")
        }
        let matchedContacts = contacts.filter { $0.itsMatch }.map { $0.identifier }
        UserDefaults.standard.set(matchedContacts, forKey: "matchedContacts")
    }

    func loadContactsFromUD() -> [Contact]? {
        if let savedContactsData = UserDefaults.standard.data(forKey: "savedContacts") {
            let decoder = JSONDecoder()
            if var loadedContacts = try? decoder.decode([Contact].self, from: savedContactsData) {
                let matchedContacts = UserDefaults.standard.stringArray(forKey: "matchedContacts") ?? []
                print("Loaded contacts: \(loadedContacts)")
                for index in loadedContacts.indices {
                    if matchedContacts.contains(loadedContacts[index].identifier) {
                        loadedContacts[index].itsMatch = true
                    }
                }
                return loadedContacts
            } else {
                print("Failed to decode saved contacts.")
            }
        } else {
            print("No contacts found in UserDefaults.")
        }
        return nil
    }
    
    func loadContactsToUI() {
        if let loadedContacts = loadContactsFromUD() {
            self.contacts = loadedContacts
            print("Contacts loaded into UI: \(self.contacts)")
        } else {
            print("No contacts to load into UI.")
        }
    }
    
    func resetSavedContacts() {
        UserDefaults.standard.removeObject(forKey: "savedContacts")
    }
}

