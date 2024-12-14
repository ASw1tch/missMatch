//
//  SplashScreenView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 30.7.24..
//

import SwiftUI
import Contacts

struct SplashScreenView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var contactListVM = ContactListViewModel()
    
    @State private var isActive = false
    let userID = UserDefaultsManager.shared.getAppleId()
    
    var body: some View {
        ZStack {
            Color(hex: "#f8dcdc")
                .ignoresSafeArea()
            VStack {
                if isActive {
                    switch coordinator.currentView {
                    case .signIn:
                        ContactPermissonView()
                    case .contactList:
                        ContactListView()
                    default:
                        ContactPermissonView()
                    }
                } else {
                    ZStack {
                        VStack {
                            Image("uLogo")
                                .resizable()
                                .frame(width: 150, height: 150)
                            Spacer()
                            
                            Text("Safely find out who's")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold() +
                            Text(" missing you")
                                .foregroundStyle(.red)
                                .font(.title3)
                                .italic()
                                .bold()
                        }
                        .padding(30)
                        
                        VStack {
                            LottieView(name: "intro", loopMode: .playOnce)
                                .frame(width: 500, height: 600)
                                .mask {
                                    RadialGradient(
                                        gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                                        center: .center,
                                        startRadius: 150,
                                        endRadius: 300
                                    )
                                }
                        }
                        .transition(.opacity)
                    }
                }
            }
            .onAppear {
                triggerIncreasingHapticFeedback()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    checkFullAuthorizationProccess()
                }
            }
        }
    }
    
    private func checkFullAuthorizationProccess() {
        _ = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            checkAppleLogged()
        case .notDetermined, .denied:
            coordinator.currentView = .contactPermisson
        case .limited :
            if UserDefaultsManager.shared.hasUserInputtedPhone() {
                coordinator.currentView = .contactList
            } else {
                checkAppleLogged()
            }
            
        default:
            coordinator.currentView = .signIn
        }
        proceedToNextView()
    }
    
    private func checkAppleLogged() {
        if UserDefaultsManager.shared.getAppleId() != nil {
            checkMyNumberLogged()
        } else {
            coordinator.currentView = .signIn
        }
    }
    
    private func checkMyNumberLogged() {
        let inputtedMyNumber = UserDefaultsManager.shared.hasUserInputtedPhone()
        if inputtedMyNumber == true {
            contactListVM.fetchContacts { contactList in
                contactListVM.sendContactsToServer(contactList: contactList)
            }
            coordinator.currentView = .contactList
        } else {
            coordinator.currentView = .myNumber
        }
    }
    
    private func proceedToNextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.spring(response: 1, dampingFraction: 0.5, blendDuration: 1.5)) {
                self.isActive = true
            }
        }
    }
    
    private func triggerIncreasingHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        
        let intervals = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 3.1, 3.2]
        
        for (index, delay) in intervals.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                generator.impactOccurred(intensity: CGFloat(index + 1) * 0.2)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}


