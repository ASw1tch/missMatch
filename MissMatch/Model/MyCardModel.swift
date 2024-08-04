//
//  MissModel.swift
//  MyCardModel
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import Foundation

struct MyCard {
    
}



struct Contact {
    var name: String
    var surname: String
    var company: String
    var phoneNumber: String      // Номер телефона контакта
    var hashedPhoneNumber: String { // Хэшированный номер телефона
        return hashPhoneNumber(phoneNumber)
    }
}

struct MyCard {
    
}

struct LikedContact {
    var userId: String           // UUID пользователя, который поставил лайк
    var likedContactHash: String // Хэшированный номер телефона контакта, которому поставлен лайк
}
