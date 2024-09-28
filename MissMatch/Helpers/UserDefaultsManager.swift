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
    
    // MARK: USER ID
    func saveUserId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: userIdKey)
    }
    
    func getUserId() -> Int? {
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        return id != 0 ? id : nil
    }
    
    // MARK: APPLE ID
    func saveAppleId(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: appleIdKey)
    }
    
    func getAppleId() -> String? {
        return UserDefaults.standard.string(forKey: appleIdKey)
    }
    
    // MARK: CONTACTS
    // Сохранение номеров телефонов контакта
    func saveContactPhones(for identifier: String, phoneNumbers: [String]) {
        var savedContacts = getAllContacts()
        savedContacts[identifier] = phoneNumbers
        saveAllContacts(savedContacts)
    }
    
    // Получение номеров телефонов контакта
    func getContactPhones(for identifier: String) -> [String]? {
        return getAllContacts()[identifier]
    }
    
    // Удаление контакта
    func removeContact(for identifier: String) {
        var savedContacts = getAllContacts()
        savedContacts.removeValue(forKey: identifier)
        saveAllContacts(savedContacts)
    }
    
    // Удаление всех контактов
    func removeAllContacts() {
        UserDefaults.standard.removeObject(forKey: contactsKey)
        UserDefaults.standard.synchronize()
    }
    
    // Приватный метод для получения всех контактов
    func getAllContacts() -> [String: [String]] {
        return UserDefaults.standard.dictionary(forKey: contactsKey) as? [String: [String]] ?? [:]
    }
    
    // Приватный метод для сохранения всех контактов
    private func saveAllContacts(_ contacts: [String: [String]]) {
        UserDefaults.standard.set(contacts, forKey: contactsKey)
    }
    
    // MARK: REFRESH TOKEN
    func saveRefreshToken(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
}
