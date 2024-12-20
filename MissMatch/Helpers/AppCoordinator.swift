//
//  AppCoordinator.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 10.10.24..
//

import Foundation

class AppCoordinator: ObservableObject {

    @Published var currentView: AppView = .splashScreen
    @Published var matchesQueue: [Contact] = []
    @Published var matchedContact: Contact? = nil
    
    func showSplash() {
        currentView = .splashScreen
    }
    
    func showSignIn() {
        currentView = .signIn
    }
    
    func showMatchScreen(for contact: Contact) {
        DispatchQueue.main.async {
            self.matchesQueue.append(contact)
            self.processNextMatch()
        }
    }
    
    func processNextMatch() {
        if let nextMatch = self.matchesQueue.first {
            self.matchedContact = nextMatch
            self.currentView = .itsAMatch
        }
    }
    
    func dismissMatchScreen() {
        if !self.matchesQueue.isEmpty {
            self.matchesQueue.removeFirst()
        }
        self.matchedContact = nil
        self.currentView = .contactList
        
        if !self.matchesQueue.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.processNextMatch()
            }
        }
    }
    
    func signOutAndReturnToStart() {
        UserDefaultsManager.shared.resetAllValues()
        LogOutViewModel().logOut()
        showSignIn()
    }
}

enum AppView {
    case splashScreen
    case contactPermisson
    case signIn
    case myNumber
    case contactList
    case itsAMatch
}
