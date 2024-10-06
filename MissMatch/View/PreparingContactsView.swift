//
//  PreparingContactsView.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 22.9.24..
//

import Foundation
import SwiftUI

struct PreparingContactsView: View {
    
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            Text("Preparing all the contacts for list...")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
