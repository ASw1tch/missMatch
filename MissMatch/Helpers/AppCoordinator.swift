//
//  AppCoordinator.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 10.10.24..
//

import Foundation

class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .splashScreen
    
    func showSplash() {
        currentView = .splashScreen
    }
    
    func showSignIn() {
        currentView = .signIn
    }
    
    func handleFailure() {
        UserDefaultsManager.shared.resetAllValues()
        showSignIn()
    }
}

enum AppView {
    case splashScreen
    case contactPermisson
    case signIn
    case myNumber
    case contactList
}
