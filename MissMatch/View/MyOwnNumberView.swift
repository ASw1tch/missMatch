//
//  MyOwnNumberView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 3.8.24..
//

import SwiftUI

struct MyOwnNumberView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coordinator: AppCoordinator
    
    @ObservedObject var viewModel: ContactListViewModel
    @ObservedObject var myOwnNumberVM: MyOwnNumderViewModel
    
    @State var selectedCountry: Country
    @State var phoneNumber: String
    @State private var showPreparingView = false
    @State private var shouldNavigateToContacts = false
    
    
    let countryCodes = countryCodesInstance.sortedCountryCodes()
    
    var body: some View {
        
        VStack {
            Text(attributedText)
                .font(.title)
                .foregroundStyle(.secondary)
                .bold()
                .padding()
            HStack {
                Picker("Select Country", selection: $selectedCountry) {
                    ForEach(countryCodes, id: \.self) { country in
                        Text("\(country.flag) \(country.code)")
                            .tag(country as Country?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .tint(Color.primary)
                
                TextField("(999)123-45-67", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .bold()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding()
            .foregroundColor(Color.primary)
            
            Button(action: {
                myOwnNumberVM.handleContinueAction(
                    selectedCountryCode: selectedCountry.code,
                    phoneNumber: phoneNumber
                )
                hideKeyboard()
                
            })
            {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
            }
            .padding()
            .disabled(phoneNumber.isEmpty)
            Text("Make sure number is correct, as this ensures you don’t miss any matches. Confirmation by number coming up.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .bold()
                .padding(.horizontal, 5)
            .onReceive(myOwnNumberVM.$shouldNavigate) { shouldNavigate in
                if shouldNavigate {
                    viewModel.fetchContacts { contactList in
                        viewModel.sendContactsToServer(contactList: contactList)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        coordinator.currentView = .contactList
                    }
                }
            }
            .onReceive(myOwnNumberVM.$navigateToStart) { navigateToStart in
                if navigateToStart {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.logOut()
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .padding()
        .loading(isLoading: $myOwnNumberVM.isLoading)
        .popup(isShowing: $myOwnNumberVM.showErrorPopup, message: myOwnNumberVM.errorMessage)
    }
    private var attributedText: AttributedString {
        var string = AttributedString("Now choose your phone number to identify yourself for likes and matches. Once again: your number is hashed and securely stored – we prioritize your privacy.")
        if let range = string.range(of: "your privacy") {
            string[range].foregroundColor = .gray.opacity(0.2)       }
        return string
    }
}

#Preview {
    MyOwnNumberView(
        viewModel: ContactListViewModel(),
        myOwnNumberVM: MyOwnNumderViewModel(),
        selectedCountry: Country(flag: "🇹🇻", code: "+688", name: "Tuvalu"),
        phoneNumber: "89923123312"
    )
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
