//
//  AppConstants.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 18.8.24..
//

import Foundation

enum API {
    static let userApiUrl = "https://gen05.com/api/v1/users/addPhones"
    static let contactsApiUrl = "https://gen05.com/api/v1/contacts/update"
    static let likesApiUrl = "https://gen05.com/api/v1/like/add"
    static let removeLikeApiUrl = "https://gen05.com/api/v1/like/remove"
    static let authCodeApiUrl = "https://gen05.com/api/v1/users/create"
    static let matchApiUrl = "https://gen05.com/api/v1/match/all?userId=\(String(describing: UserDefaultsManager.shared.getAppleId()!))"
}
