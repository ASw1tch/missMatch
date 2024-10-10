//
//  MissMatchApp.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                switch coordinator.currentView {
                case .splashScreen:
                    SplashScreenView()
                case .signIn:
                    SignInView(signInVM: SignInViewModel())
                case .contactPermisson:
                    ContactPermissonView()
                case .myNumber:
                    MyOwnNumberView(
                        viewModel: ContactListViewModel(),
                        myOwnNumberVM: MyOwnNumderViewModel(),
                        selectedCountry: Country(flag: "🇹🇻", code: "+688", name: "Tuvalu"),
                        phoneNumber: "9312444263"
                    )
                case .contactList:
                    ContactListView()
                }
            }
            .environmentObject(coordinator)
        }
    }
}
