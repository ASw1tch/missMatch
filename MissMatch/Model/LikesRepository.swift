//
//  LikesRepository.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 21.8.24..
//

import Foundation

class LikesRepository {

    private let maxFreeHearts = 1000000
        
    func loadLikes() -> [String] {
        return UserDefaultsManager.shared.getLikes()
    }
    
    func heartCount() -> Int {
        return loadLikes().count
    }
    
    func canLike() -> Bool {
        return heartCount() < maxFreeHearts
    }
}
