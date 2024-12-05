//
//  UserDefaultsManager.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.8.24..
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    func resetAllValues() {
        let keys = [
            userIdKey,
            appleIdKey,
            contactsKey,
            refreshTokenKey,
            savedLikesKey,
            matchesKey,
            likeServerKey,
            userNameKey,
            deviceTokenKey,
            isMyPhoneInputtedKey,
            shownMatches
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    private let userIdKey = "UserDefaultsManager.userIdKey"
    private let appleIdKey = "UserDefaultsManager.appleIdKey"
    private let contactsKey = "UserDefaultsManager.contactsKey"
    private let refreshTokenKey = "UserDefaultsManager.refreshTokenKey"
    private let savedLikesKey = "UserDefaultsManager.savedLikesKey"
    private let matchesKey = "UserDefaultsManager.matchesKey"
    private let likeServerKey = "UserDefaultsManager.likeServerKey"
    private let userNameKey = "UserDefaultsManager.userNameKey"
    private let deviceTokenKey = "UserDefaultsManager.deviceTokenKey"
    private let isMyPhoneInputtedKey = "UserDefaultsManager.isMyPhoneInputtedKey"
    private let alreadyShownMatchesKey = "UserDefaultsManager.alreadyShownMatches"
    private let shownMatches = "shownMatches"
    
    
    
    
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
    func saveLike(contactID: String) {
        var savedLikes = getLikes()
        savedLikes.append(contactID)
        saveLikes(savedLikes)
    }
    
    func removeLike(contactID: String) {
        var savedLikes = getLikes()
        if let index = savedLikes.firstIndex(of: contactID) {
            savedLikes.remove(at: index)
        }
        saveLikes(savedLikes)
        
    }
    
    func getLikes() -> [String] {
        return UserDefaults.standard.array(forKey: savedLikesKey) as? [String] ?? []
    }
    
    private func saveLikes(_ likes: [String]) {
        UserDefaults.standard.set(likes, forKey: savedLikesKey)
    }
    
    func removeAllLikes() {
        UserDefaults.standard.removeObject(forKey: savedLikesKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - MATCHES
    func getMatches() -> [String] {
        return UserDefaults.standard.array(forKey: matchesKey) as? [String] ?? []
    }
    
    func saveMatches(_ matchResponse: MatchResponse) {
        var currentMatches = getMatches()
        currentMatches.append(contentsOf: matchResponse.contactIDS)
        UserDefaults.standard.set(currentMatches, forKey: matchesKey)
    }
    
    func removeMatches(_ matchResponse: MatchResponse) {
        var currentMatches = getMatches()
        for contactID in matchResponse.contactIDS {
            if let index = currentMatches.firstIndex(of: contactID) {
                currentMatches.remove(at: index)
            }
        }
        UserDefaults.standard.set(currentMatches, forKey: matchesKey)
    }
    
    func removeAllMatches() {
        UserDefaults.standard.removeObject(forKey: matchesKey)
    }
    
    func addShownMatches(_ matchID: String) {
        var alreadyShownMatches = getShownMatches()
        alreadyShownMatches.append(matchID)
        UserDefaults.standard.set(alreadyShownMatches, forKey: alreadyShownMatchesKey)
    }
    
    func getShownMatches() -> [String] {
        return UserDefaults.standard.stringArray(forKey: alreadyShownMatchesKey) ?? []
    }
    
    // MARK: - Array Likes (For sending after back from offline)
    
    func getServerLikes() -> [String] {
        return UserDefaults.standard.array(forKey: likeServerKey) as? [String] ?? []
    }
    
    func saveServerLike(contactIDs: [String]) {
        var savedServerLikes = getServerLikes()
        savedServerLikes.append(contentsOf: contactIDs)
        saveArrayLikes(savedServerLikes)
    }
    
    private func saveArrayLikes(_ likes: [String]) {
        UserDefaults.standard.set(likes, forKey: likeServerKey)
    }
    
    func removeAllServerLikes() {
        UserDefaults.standard.removeObject(forKey: likeServerKey)
    }
    
    // MARK: - User Name
    
    func saveUserName(_ userName: String) {
        UserDefaults.standard.set(userName, forKey: userNameKey)
    }
    
    func getUserName() -> String? {
        return UserDefaults.standard.string(forKey: userNameKey)
    }
    
    func removeUserName() {
        UserDefaults.standard.removeObject(forKey: userNameKey)
    }
    
    // MARK: - Device token
    
    func saveDeviceToken(_ deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: deviceTokenKey)
    }
    
    func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: deviceTokenKey)
    }
    
    func removeDeviceToken() {
        UserDefaults.standard.removeObject(forKey: deviceTokenKey)
    }
    
    // MARK: - User used his number
    func setMyPhoneInputted(value: Bool) {
        UserDefaults.standard.set(value, forKey: isMyPhoneInputtedKey)
    }
    
    func hasUserInputtedPhone() -> Bool {
        return UserDefaults.standard.bool(forKey: isMyPhoneInputtedKey)
    }
}

