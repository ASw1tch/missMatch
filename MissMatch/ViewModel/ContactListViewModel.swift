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
                    var savedContacts: [SavedContact] = [] // Массив для сохраненных контактов
                    
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                        let normalizedPhoneNumbers = PhoneNumberManager.normalizePhoneNumbers(phoneNumbers)
                        let uniqueKey = "\(contact.givenName)\(contact.familyName)\(normalizedPhoneNumbers.joined())"
                        
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
                            phoneNumber: normalizedPhoneNumbers
                        )
                        fetchedContacts.append(contact)
                        
                        // Создаем объект SavedContact для каждого контакта
                        let savedContact = SavedContact(id: contactID, phones: normalizedPhoneNumbers)
                        savedContacts.append(savedContact)
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                        self.loadLikes()
                        
                        // Отправляем контакты на сервер
                        self.sendContactsToServer(savedContacts: savedContacts)
                    }
                    
                } catch {
                    print("Failed to fetch contacts: \(error)")
                }
            }
        }
    }
    
    func sendContactsToServer(savedContacts: [SavedContact]) {
        // Получаем userId, который нужно передать в запросе
        guard let userId = UserDefaultsManager.shared.getAppleId() else {
            print("User ID not found")
            return
        }
        
        // Создаем объект SaveContactRequest
        let saveContactRequest = SaveContactRequest(userId: userId, contacts: savedContacts)
        
        // Отправляем данные через NetworkManager
        
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
                    let normalizedPhoneNumbers = PhoneNumberManager.normalizePhoneNumbers(phoneNumbers)
                    
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
            //let likeRequest = LikeRequest(fromUserId: userId, contactIds: contactIds)
            //NetworkManager.shared.postData(for: .likes(likeRequest))
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

