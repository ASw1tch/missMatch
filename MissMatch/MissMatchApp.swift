//
//  MissMatchApp.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 25.7.24..
//
import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var contactListVM = ContactListViewModel()
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ZStack {
                    switch coordinator.currentView {
                    case .splashScreen:
                        SplashScreenView()
                            .transition(.opacity)
                    case .signIn:
                        SignInView(signInVM: SignInViewModel())
                            .transition(.slide)
                    case .contactPermisson:
                        ContactPermissonView()
                            .transition(.slide)
                    case .myNumber:
                        MyOwnNumberView(
                            viewModel: ContactListViewModel(),
                            myOwnNumberVM: MyOwnNumderViewModel(),
                            selectedCountry: Country(flag: "🇷🇸", code: "+381", name: "Serbia"),
                            phoneNumber: "9312444263"
                        )
                        .transition(.slide)
                    case .contactList:
                        ContactListView()
                            .transition(.slide)
                    case .itsAMatch:
                        if let contact = coordinator.matchedContact {
                            ItsAMatchView(contact: contact)
                                .transition(.slide)
                        }
                    }
                }
                .animation(.easeInOut, value: coordinator.currentView)
            }
            .environmentObject(coordinator)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                //startTimer()
                //contactListVM.checkAndShowMatchScreen()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                contactListVM.saveContactsToUD(contactListVM.contacts)
            }
        }
    }
    
    func reloadContacts() {
        contactListVM.isLoading = true
        contactListVM.fetchContacts { contactList in
            contactListVM.sendContactsToServer(contactList: contactList)
        }
        contactListVM.isLoading.toggle()
    }
    
    func startTimer() {
        contactListVM.startRegularUpdates(interval: 10)
    }
}
