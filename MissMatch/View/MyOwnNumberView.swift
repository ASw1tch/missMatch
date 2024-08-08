//
//  MyOwnNumberView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 3.8.24..
//

import SwiftUI


struct MyOwnNumberView: View {
    
    @ObservedObject var viewModel: ContactListViewModel
    @State var selectedCountry: Country
    @State var phoneNumber: String
    
    let countryCodes = countryCodesInstance.sortedCountryCodes()
    
    var body: some View {
        VStack {
            Text("Firstly choose your phone number")
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
                viewModel.handleContinueAction(
                    selectedCountryCode: selectedCountry.code,
                    phoneNumber: phoneNumber
                )
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(phoneNumber.isEmpty)
        }
        .padding()
    }
}


#Preview {
    MyOwnNumberView(viewModel: ContactListViewModel(), selectedCountry: Country(flag: "🇹🇻", code: "+688", name: "Tuvalu"), phoneNumber: "89923123312")
}


