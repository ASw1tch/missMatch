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
                var myNumbers = [String]()
                var myInputNumber = selectedCountry!.code + phoneNumber
                myNumbers.append(myInputNumber)
                viewModel.findContactPhoneNumbers(for: myInputNumber) { phoneNumbers in
                    myNumbers.append(contentsOf: phoneNumbers)
                    print("All phone numbers for the contact:", myNumbers)
                }
                print(myNumbers)
                let rawPhoneNumbers = normalizePhoneNumbers(myNumbers)
                let user = User(appleId: String(Int.random(in: 100000...999999)), phones: rawPhoneNumbers)
                NetworkManager.shared.postData(for: .user(user))
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
    
    func normalizePhoneNumbers(_ phoneNumbers: [String]) -> [String] {
        var seenNumbers = Set<String>()
        
        let normalizedNumbers = phoneNumbers.compactMap { phoneNumber -> String? in
            let filtered = phoneNumber.filter { "+0123456789".contains($0) }
            if seenNumbers.contains(filtered) {
                return nil
            } else {
                seenNumbers.insert(filtered)
                return filtered
            }
        }
        return normalizedNumbers
    }
}


#Preview {
    MyOwnNumberView(viewModel: ContactListViewModel(), phoneNumber: "89923123312")
}


