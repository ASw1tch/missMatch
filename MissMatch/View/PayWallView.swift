//
//  PayWallView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 30.7.24..
//

import SwiftUI

struct PayWallView: View {
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .center) {
            Color(UIColor.systemBackground)
            VStack(spacing: 20) {
                Text("PLOTI")
                    .font(.largeTitle)
                    .bold()
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .frame(width: 100, height: 80)
                Button {
                    presentationMode.wrappedValue.dismiss()
                    print("Dismiss paywall")
                } label: {
                    Text("Later")
                }.buttonStyle(.borderedProminent)
            }
            
            
        }
    }
}

#Preview {
    PayWallView()
}
