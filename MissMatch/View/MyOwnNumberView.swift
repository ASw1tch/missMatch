//
//  MyOwnNumberView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 3.8.24..
//

import SwiftUI


struct MyOwnNumberView: View {
    
    @ObservedObject var viewModel: ContactListViewModel
    @State private var selectedCountry: Country?
    @State var phoneNumber: String
    private let countryCodes = CountryCodes().sortedCountryCodes()
    
    var body: some View {
        VStack {
            Text("Firstly choose your phone number")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .bold()
                .padding()
            HStack {
                Picker("Select Country", selection: $selectedCountry) {
                    ForEach(countryCodes, id: \.code) { country in
                        Text("\(country.flag) \(country.code)")
                            .tag(country as Country?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.black)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding()
            
            Button(action: {
                let fullPhoneNumber = selectedCountry!.code + phoneNumber
                viewModel.findContactPhoneNumbers(for: fullPhoneNumber) { phoneNumbers in
                    let user = User(appleId: String(Int.random(in: 100000...999999)), phones: phoneNumbers)
                    print(user)
                    viewModel.postUserData(user)
                }
                print(selectedCountry!.code + phoneNumber)
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
    MyOwnNumberView(viewModel: ContactListViewModel(), phoneNumber: "89923123312")
}


