//
//  MissMatchApp.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//

import SwiftUI

@main
struct MissMatchApp: App {
    var body: some Scene {
        WindowGroup {
//            SplashScreenView()
            MyOwnNumberView(viewModel: ContactListViewModel(), selectedCountry: Country(flag: "🇷🇸", code: "+381", name: "Serbia"), phoneNumber: "")
//            ContactListView()
        }
    }
}
