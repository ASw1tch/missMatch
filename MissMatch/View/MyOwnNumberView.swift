//
//  MyOwnNumberView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 3.8.24..
//

import SwiftUI

struct MyOwnNumberView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: ContactListViewModel
    @ObservedObject var myOwnNumberVM: MyOwnNumderViewModel
    
    @State var selectedCountry: Country
    @State var phoneNumber: String
    
    let countryCodes = countryCodesInstance.sortedCountryCodes()
    
    var body: some View {
        VStack {
            Text("Now choose your phone number, to identitify you for likes and matches.")
                .font(.largeTitle)
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
                
                TextField("Phone", text: $phoneNumber)
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
            }) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray, radius: 3, x: 0, y: 2)
                
            }
                .padding()
                .disabled(phoneNumber.isEmpty)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .padding()
        .loading(isLoading: $myOwnNumberVM.isLoading)
        .popup(isShowing: $myOwnNumberVM.showErrorPopup, message: myOwnNumberVM.errorMessage)
        .fullScreenCover(isPresented: $myOwnNumberVM.shouldNavigate) {
            ContactListView(viewModel: viewModel)
        }
    }
}

#Preview {
    MyOwnNumberView(viewModel: ContactListViewModel(), myOwnNumberVM: MyOwnNumderViewModel(), selectedCountry: Country(flag: "🇹🇻", code: "+688", name: "Tuvalu"), phoneNumber: "89923123312")
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

