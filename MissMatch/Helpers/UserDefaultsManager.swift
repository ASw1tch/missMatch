//
//  UserDefaultsManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.8.24..
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let userIdKey = "UserDefaultsManager.userIdKey"
    private let appleIdKey = "UserDefaultsManager.appleIdKey"
    private let contactsKey = "UserDefaultsManager.contactsKey"
    private let refreshTokenKey = "UserDefaultsManager.refreshTokenKey"
    
    
    func saveUserId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: userIdKey)
    }
    
    func getUserId() -> Int? {
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        return id != 0 ? id : nil
    }
    
    func saveAppleId(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: appleIdKey)
    }
    
    func getAppleId() -> String? {
        return UserDefaults.standard.string(forKey: appleIdKey)
    }
    
    func saveContactPhones(for identifier: String, phoneNumbers: [String]) {
        var savedContacts = UserDefaults.standard.dictionary(forKey: contactsKey) as? [String: [String]] ?? [:]
        savedContacts[identifier] = phoneNumbers
        UserDefaults.standard.set(savedContacts, forKey: contactsKey)
    }
    
    func getContactPhones(for identifier: String) -> [String]? {
        let savedContacts = UserDefaults.standard.dictionary(forKey: contactsKey) as? [String: [String]]
        return savedContacts?[identifier]
    }
    
    func removeContact(for identifier: String) {
        var savedContacts = getAllContacts()
        savedContacts.removeValue(forKey: identifier)
        
        saveAllContacts(savedContacts)
    }
    
    func saveAllContacts(_ contacts: [String: [String]]) {
        UserDefaults.standard.set(contacts, forKey: "contacts")
    }
    
    func getAllContacts() -> [String: [String]] {
        return UserDefaults.standard.dictionary(forKey: contactsKey) as? [String: [String]] ?? [:]
    }
    
    func saveRefreshToken(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
}
