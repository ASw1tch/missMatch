//
//  ItsAMatchView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 27.7.24..
//

import SwiftUI

struct ItsAMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var contact: Contact
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(UIColor.systemBackground)
            LottieView(name: "Confetti", loopMode: .loop)
                .frame(width: 600, height: 1000)
            VStack(spacing: 20) {
                LottieView(name: "con3", loopMode: .loop)
                    .offset(x: 40)
                    .frame(width: 400, height: 400)
                Text("You’re both a match!")
                    .font(.largeTitle)
                    .bold()
                Text("It's time to text \(contact.name)")
                    .font(.body)
                    .bold()
                Button {
                    presentationMode.wrappedValue.dismiss()
                    print("Wow")
                } label: {
                    Text("Awesome!")
                }.buttonStyle(.borderedProminent)
            }
            
            
        }
    }
}

#Preview {
    ItsAMatchView(contact: Contact(name: "Mary", surname: "Smith", phoneNumber: ["+79312444263"]))
}
