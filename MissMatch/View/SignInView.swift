//
//  SignInView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 10.8.24..
//

import SwiftUI

struct SignInView: View {
    @State private var isProceed = false
    
    var body: some View {
        VStack {

            Text("Apple Sing in page")
            Button(action: {
                isProceed.toggle()
            }, label: {
                Text("Proceed")
            })
        }.fullScreenCover(isPresented: $isProceed) {
            MyOwnNumberView(viewModel: ContactListViewModel(),
                            selectedCountry: Country(flag: "🇷🇸", code: "+381", name: "Serbia"),
                            phoneNumber: "")
    }
        }
}

#Preview {
    SignInView()
}
