import Foundation
import Contacts
import CoreTelephony

class ContactListViewModel: ObservableObject {
    
    @Published var contacts: [ContactList] = []
    @Published var likedContact = false
    @Published var matched = false
    @Published var heartCount = 0
    
    private let likesRepository = LikesRepository()
    
    init() {
        self.fetchAllContacts()
    }
    
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
                    phoneNumbers.append(number)
                }
            }
            completion(phoneNumbers)
        } catch {
            print("Failed to fetch contact, error: \(error)")
            completion([])
        }
    }
    
    func fetchAllContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    return
                }
                let keys = [CNContactGivenNameKey,
                            CNContactPhoneNumbersKey,
                            CNContactFamilyNameKey,
                            CNContactJobTitleKey,
                            CNContactEmailAddressesKey] as [CNKeyDescriptor]
                let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    var fetchedContacts: [ContactList] = []
                    var savedContactIDs = UserDefaults.standard.dictionary(forKey: "savedContactIDs") as? [String: Int] ?? [:]
                    
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                        let uniqueKey = "\(contact.givenName)\(contact.familyName)\(phoneNumbers.joined())"
                        
                        let contactID: Int
                        if let savedID = savedContactIDs[uniqueKey] {
                            contactID = savedID
                        } else {
                            contactID = Int.random(in: 1000...900000)
                            savedContactIDs[uniqueKey] = contactID
                            UserDefaults.standard.set(savedContactIDs, forKey: "savedContactIDs")
                        }
                        
                        let contact = ContactList(
                            id: contactID,
                            name: contact.givenName,
                            surname: contact.familyName,
                            phoneNumber: phoneNumbers
                        )
                        fetchedContacts.append(contact)
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                        self.loadLikes()
                    }
                    
                } catch {
                    print("Failed to fetch contacts: \(error)")
                }
            }
        }
    }
    
    func getAllContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            var contactsArray = [ContactList]()
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                    let contactItem = ContactList(
                        id: Int.random(in: 1000...9000),
                        name: contact.givenName,
                        surname: contact.familyName,
                        phoneNumber: phoneNumbers
                    )
                    contactsArray.append(contactItem)
                }
            } catch {
                print("Failed to fetch contacts, error: \(error)")
            }
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
            let rawPhoneNumbers = self.normalizePhoneNumbers(myNumbers)
            let user = User(appleId: String(Int.random(in: 100000...999999)), phones: rawPhoneNumbers)
            NetworkManager.shared.postData(for: .user(user))
        }
    }
    
    private func normalizePhoneNumbers(_ phoneNumbers: [String]) -> [String] {
        var seenNumbers = Set<String>()
        let normalizedNumbers = phoneNumbers.compactMap { phoneNumber -> String? in
            let filtered = phoneNumber.filter { "+0123456789".contains($0) }
            if seenNumbers.contains(filtered) {
                return nil
            } else {
                seenNumbers.insert(filtered)
                return filtered
            }
        }
        return normalizedNumbers
    }
    
    func toggleMiss(contact: ContactList) {
        guard let userId = UserDefaultsManager.shared.getUserId() else {
            print("User ID not found.")
            return
        }
        
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            if contacts[index].iLiked {
                contacts[index].iLiked.toggle()
                contacts[index].itsMatch = false
                likesRepository.removeLike(contactID: contact.id)
            } else if likesRepository.canLike() {
                contacts[index].iLiked.toggle()
                likesRepository.saveLike(contactID: contact.id)
            } else {
                print("Like limit reached")
            }
            loadLikes()
            
            let contactIds = contacts.filter { $0.iLiked }.map { $0.id }
            let likeRequest = LikeRequest(fromUserId: userId, contactIds: contactIds)
            NetworkManager.shared.postData(for: .likes(likeRequest))
        }
    }
    
    func loadLikes() {
        let savedLikes = likesRepository.loadLikes()
        heartCount = savedLikes.count
        for i in 0..<contacts.count {
            if savedLikes.contains(contacts[i].id) {
                contacts[i].iLiked = true
            }
        }
    }
}

