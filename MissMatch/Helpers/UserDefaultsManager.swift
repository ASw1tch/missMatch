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
    
    func saveUserId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: userIdKey)
    }
    
    func getUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: userIdKey)
    }
}
