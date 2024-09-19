//
//  HTTPConstants.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
    case HEAD
    case OPTIONS
}

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case accept = "Accept"
    case authorization = "Authorization"
    case userAgent = "User-Agent"
}

enum HTTPHeaderValue: String {
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case acceptAll = "*/*"
}
