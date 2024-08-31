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
    private let contactIdsKey = "UserDefaultsManager.contactIdsKey"
    
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
    
    func saveContactIds(_ contactIds: [String: Int]) {
        UserDefaults.standard.set(contactIds, forKey: contactIdsKey)
    }
    
    func getContactIds() -> [String: Int]? {
        return UserDefaults.standard.dictionary(forKey: contactIdsKey) as? [String: Int]
    }
}
