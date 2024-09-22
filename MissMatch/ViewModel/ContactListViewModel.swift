//
//  ContactListView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..

import Foundation
import Contacts

class ContactListViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    
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
                        
                        let contact = Contact(
                            identifier: cnContact.identifier,
                            givenName: cnContact.givenName,
                            familyName: cnContact.familyName,
                            phoneNumbers: normalizedPhoneNumbers
                        )
                        contacts.append(contact)
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = contacts
                        self.isLoading = false
                        
                        // Создание ContactList для отправки
                        let contactList = self.sortContactsForServer(userID: UserDefaultsManager.shared.getAppleId() ?? "No Apple Id", contacts: contacts)
                        completion(contactList) // Передача готового списка в completion
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
        
        // Преобразуем ContactList в JSON Data
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
                        print("Successfully received contacts: \(response.contacts)")
                        
                        for contact in response.contacts {
                            UserDefaultsManager.shared.saveContactPhones(for: contact.identifier, phoneNumbers: contact.phoneNumbers)
                        }
                        
                    } else {
                        self.showErrorPopup = true
                        self.errorMessage = "Server responded with an error: \(response.message)"
                    }
                case .failure(let error):
                    self.showErrorPopup = true
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func sortContactsForServer(userID: String, contacts: [Contact]) -> ContactList {
        var toAdd = [To]()
        var toUpdate = [To]()
        var toRemove = [String]()
        
        let savedContacts = UserDefaultsManager.shared.getAllContacts()
        
        for contact in contacts {
            if let savedPhones = UserDefaultsManager.shared.getContactPhones(for: contact.identifier) {
                if savedPhones != contact.phoneNumbers {
                    let toUpdateContact = To(contactID: contact.identifier, phones: contact.phoneNumbers)
                    toUpdate.append(toUpdateContact)
                }
            } else {
                let toAddContact = To(contactID: contact.identifier, phones: contact.phoneNumbers)
                toAdd.append(toAddContact)
            }
        }
        
        for savedContactID in savedContacts.keys {
            if !contacts.contains(where: { $0.identifier == savedContactID }) {
                toRemove.append(savedContactID)
            }
        }
        
        return ContactList(
            userID: userID,
            toAdd: toAdd,
            toUpdate: toUpdate,
            toRemove: toRemove
        )
    }

    func toggleMiss(contact: Contact) {
    }
    
    func loadLikes() {
        
    }
}
