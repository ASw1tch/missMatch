//
//  MyOwnNumberViewModel.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 20.9.24..
//

import Foundation
import Contacts

class MyOwnNumderViewModel: ObservableObject {
    
    @Published var contacts: [ContactList] = []
    @Published var isLoading = false
    @Published var showErrorPopup = false
    @Published var errorMessage = ""
    @Published var shouldNavigate = false
    
    init() {}
    
    func findContactPhoneNumbers(for phoneNumber: String, completion: @escaping ([String]) -> Void) {
        
        let store = CNContactStore()
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let keysToFetch = [CNContactPhoneNumbersKey as CNKeyDescriptor]
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            var phoneNumbers: [String] = []
            
            for contact in contacts {
                for phoneNumber in contact.phoneNumbers {
                    let number = phoneNumber.value.stringValue
                    let normalizedPhoneNumbers = PhoneNumberManager.normalizePhoneNumbers(phoneNumbers)
                    phoneNumbers.append(number)
                }
            }
            completion(phoneNumbers)
        } catch {
            print("Failed to fetch contact, error: \(error)")
            completion([])
        }
    }

    
    func handleContinueAction(selectedCountryCode: String?, phoneNumber: String) {
        
        guard let selectedCountryCode = selectedCountryCode else {
            print("Country code is missing")
            return
        }
        
        var myNumbers = [String]()
        let myInputNumber = selectedCountryCode + phoneNumber
        myNumbers.append(myInputNumber)
        
        findContactPhoneNumbers(for: myInputNumber) { phoneNumbers in
            if phoneNumbers.isEmpty {
                myNumbers.append(myInputNumber)
            } else {
                myNumbers.append(contentsOf: phoneNumbers)
            }
            print("All phone numbers for the contact:", myNumbers)
            let rawPhoneNumbers = PhoneNumberManager.normalizePhoneNumbers(myNumbers)
            let user = User(userId: UserDefaultsManager.shared.getAppleId() ?? "No Apple ID", phones: rawPhoneNumbers)
            print(user)
            self.sendUserToServer(user: user)
        }
        
    }
    private func sendUserToServer(user: User) {
        guard let appleIdUser = UserDefaultsManager.shared.getAppleId(), !appleIdUser.isEmpty else {
            showErrorPopup = true
            errorMessage = "Apple ID is not found."
            return
        }
        
        guard let requestBody = try? JSONEncoder().encode(user) else {
            showErrorPopup = true
            errorMessage = "Can't convert user data to JSON."
            return
        }
        isLoading = true
        let headers: [HTTPHeaderField: String] = [
            .contentType: HTTPHeaderValue.json.rawValue,
            .accept: HTTPHeaderValue.acceptAll.rawValue
        ]
        print(headers)
        NetworkManager.shared.sendRequest(
            to: K.API.userApiUrl,
            method: .POST,
            headers: headers,
            body: requestBody,
            responseType: String.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.showErrorPopup = true
                    self?.errorMessage = response.description
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.shouldNavigate = true
                    }
                case .failure(let error):
                    self?.showErrorPopup = true
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
