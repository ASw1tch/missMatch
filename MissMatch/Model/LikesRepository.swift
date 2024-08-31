//
//  LikesRepository.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 21.8.24..
//

import Foundation

class LikesRepository {
    
    private let userDefaultsKey = "savedLikes"
    private let maxFreeHearts = 3
    
    func saveLike(contactID: Int) {
        var savedLikes = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
        savedLikes.append(contactID)
        UserDefaults.standard.set(savedLikes, forKey: userDefaultsKey)
    }
    
    func removeLike(contactID: Int) {
        var savedLikes = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
        if let index = savedLikes.firstIndex(of: contactID) {
            savedLikes.remove(at: index)
            UserDefaults.standard.set(savedLikes, forKey: userDefaultsKey)
        }
    }
    
    func loadLikes() -> [Int] {
        return UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
    }
    
    func heartCount() -> Int {
        return loadLikes().count
    }
    
    func canLike() -> Bool {
        return heartCount() < maxFreeHearts
    }
}
