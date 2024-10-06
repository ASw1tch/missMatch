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
    private let savedLikesKey = "UserDefaultsManager.savedLikesKey"
    
    // MARK: - USER ID
    func saveUserId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: userIdKey)
    }
    
    func getUserId() -> Int? {
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        return id != 0 ? id : nil
    }
    
    // MARK: - APPLE ID
    func saveAppleId(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: appleIdKey)
    }
    
    func getAppleId() -> String? {
        return UserDefaults.standard.string(forKey: appleIdKey)
    }
    
    // MARK: - CONTACTS
    func saveContactPhones(for identifier: String, phoneNumbers: [String]) {
        var savedContacts = getAllContacts()
        savedContacts[identifier] = phoneNumbers
        saveAllContacts(savedContacts)
    }
    
    func getContactPhones(for identifier: String) -> [String]? {
        return getAllContacts()[identifier]
    }
    
    func removeContact(for identifier: String) {
        var savedContacts = getAllContacts()
        savedContacts.removeValue(forKey: identifier)
        saveAllContacts(savedContacts)
    }
    
    func removeAllContacts() {
        UserDefaults.standard.removeObject(forKey: contactsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAllContacts() -> [String: [String]] {
        return UserDefaults.standard.dictionary(forKey: contactsKey) as? [String: [String]] ?? [:]
    }
    
    private func saveAllContacts(_ contacts: [String: [String]]) {
        UserDefaults.standard.set(contacts, forKey: contactsKey)
    }
    
    // MARK: - REFRESH TOKEN
    func saveRefreshToken(_ appleId: String) {
        UserDefaults.standard.set(appleId, forKey: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    // MARK: - LIKES
    // Сохранение лайка для контакта
    func saveLike(contactID: String) {
        var savedLikes = getLikes()
        savedLikes.append(contactID)
        saveLikes(savedLikes)
    }
    
    // Удаление лайка для контакта
    func removeLike(contactID: String) {
        var savedLikes = getLikes()
        if let index = savedLikes.firstIndex(of: contactID) {
            savedLikes.remove(at: index)
        }
        saveLikes(savedLikes)
        
    }
    
    // Получение всех лайков
    func getLikes() -> [String] {
        return UserDefaults.standard.array(forKey: savedLikesKey) as? [String] ?? []
    }
    
    // Приватный метод для сохранения всех лайков
    private func saveLikes(_ likes: [String]) {
        UserDefaults.standard.set(likes, forKey: savedLikesKey)
    }
    
    func removeAllLikes() {
        UserDefaults.standard.removeObject(forKey: savedLikesKey)
        UserDefaults.standard.synchronize()
    }
}


