//
//  LoadingViewModifier.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import SwiftUI

struct LoadingViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(colorScheme == .dark ? Color.white : Color.black)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(3)
                    .background(Color.clear.edgesIgnoringSafeArea(.all))
                    .offset(y: 100)
            }
        }
    }
}

extension View {
    func loading(isLoading: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isLoading: isLoading))
    }
}

struct LoadingViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        LoadingViewPreviewContainer()
    }
}

struct LoadingViewPreviewContainer: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text("Content goes here")
                .padding()
            
            Button(action: {
                isLoading.toggle()
            }) {
                Text("Toggle Loading")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .loading(isLoading: $isLoading)
    }
}
