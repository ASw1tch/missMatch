import Foundation
import Contacts
import CoreTelephony

class ContactListViewModel: ObservableObject {
    @Published var contacts: [ContactList] = []
    @Published var likedContact = false
    @Published var matched = false
    
    @Published var heartCount = 0
    
    let maxFreeHearts = 3
    
    init() {
        fetchAllContacts()
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
        // Request access to the Contacts Store
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            
            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    // Handle access denied
                    return
                }
                
                // Specify which data keys we want to fetch
                let keys = [CNContactGivenNameKey,
                            CNContactPhoneNumbersKey,
                            CNContactFamilyNameKey,
                            CNContactJobTitleKey,
                            CNContactEmailAddressesKey] as [CNKeyDescriptor]
                
                // Create fetch request
                let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    var fetchedContacts: [ContactList] = []
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        // Extract all phone numbers for the contact
                        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                        
                        let contact = ContactList(
                            name: contact.givenName,
                            surname: contact.familyName,
                            phoneNumber: phoneNumbers
                        )
                        fetchedContacts.append(contact)
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                    }
                } catch {
                    // Handle error
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
                        name: contact.givenName,
                        surname: contact.familyName,
                        phoneNumber: phoneNumbers
                    )
                    contactsArray.append(contactItem)
                }
                
                // Переходим на главный поток для работы с UI
                DispatchQueue.main.async {
                    let hasher = PhoneNumberHasher()
                    var counter = 0
                    for contact in contactsArray {
//                        print("Name: \(contact.name) \(contact.surname)")
//                        counter += 1
//                        print(counter)
                        for number in contact.phoneNumber {
                            let hashedNumber = PhoneNumberHasher.hashPhoneNumber(number)
//                            print("Hashed phone number: \(hashedNumber)")
                        }
                    }
                }
            } catch {
                print("Failed to fetch contacts, error: \(error)")
            }
        }
    }
    
    func fetchMyPhoneNumbers() {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        store.requestAccess(for: .contacts) { (granted, error) in
            guard granted else {
                print("Access to contacts not granted")
                return
            }
            
            do {
                // Получаем контейнеры контактов
                let containers = try store.containers(matching: nil)
                
                // Ищем контейнер с "meIdentifier"
                for container in containers {
                    if let meIdentifier = container.value(forKey: "meIdentifier") as? String {
                        print("Me Identifier:", meIdentifier)
                        
                        // Получаем контакт "Me"
                        let predicate = CNContact.predicateForContacts(withIdentifiers: [meIdentifier])
                        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                        
                        
                        if let meContact = contacts.first {
                            for phoneNumber in meContact.phoneNumbers {
                                let number = phoneNumber.value.stringValue
                                let hashedNumber = PhoneNumberHasher.hashPhoneNumber(number)
                                print("My hashed phone number: \(number)")
                                
                            }
                            
                        } else {
                            print("No 'Me' contact found")
                        }
                        
                    }
                }
            } catch {
                print("Failed to fetch contacts, error: \(error)")
            }
        }
    }
    
    
    func toggleMiss(contact: ContactList) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            if contacts[index].iLiked {
                contacts[index].iLiked.toggle()
                heartCount -= 1
                contacts[index].itsMatch = false
            } else if heartCount < maxFreeHearts {
                contacts[index].iLiked.toggle()
                heartCount += 1
                matched = .random()
                matched ? contacts[index].itsMatch.toggle() : nil
            } else {
                print("Превышен лимит бесплатных сердечек")
            }
            // Здесь можно добавить логику для сохранения изменений в базу данных
        }
    }
}

