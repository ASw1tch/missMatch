//
//  UserModel.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 31.7.24..
//

import Foundation

struct User {
    var id: String              // Уникальный идентификатор пользователя (UUID)
    var name: String            // Имя пользователя
    var email: String           // Электронная почта
    var hashedPhoneNumbers: [String]  // Список хэшированных номеров телефонов
    var likedContacts: [LikedContact] // Список контактов, которым поставлен лайк
}
