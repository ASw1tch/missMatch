//
//  AppConstants.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 18.8.24..
//

import Foundation

struct K {
    struct API { // better to choose enum
        static let userApiUrl = "https://gen05.com/api/v1/users/add"
        static let contactsApiUrl = "https://gen05.com/api/v1/contacts/save"
        static let likesApiUrl = "https://gen05.com/api/v1/like/addAll"
        static let authCodeApiUrl = "https://gen05.com/api/v1/users/create"
    }
}
