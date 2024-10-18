//
//  PopupViewModifier.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import SwiftUI

struct PopupViewModifier: ViewModifier {
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = -200
    
    var message: String
    var isError: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(Color(hex: "FFEB00"))
                            .imageScale(.large)
                        Text(message)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(10)
                    .shadow(radius: 3, x: 2, y: 2)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .offset(y: offset)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                        offset = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            offset = -200
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isShowing = false
                        }
                    }
                }
                .animation(.easeInOut, value: isShowing)
            }
        }
    }
}

extension View {
    func popup(isShowing: Binding<Bool>, message: String, isError: Bool = true) -> some View {
        self.modifier(PopupViewModifier(isShowing: isShowing, message: message, isError: isError))
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct PopupViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        PopupViewPreviewContainer()
    }
}

struct PopupViewPreviewContainer: View {
    @State private var isShowingPopup = true
    
    var body: some View {
        VStack {
            Text("Main Content Content Content Content  ")
                .padding()
            Button(action: {
                isShowingPopup.toggle()
            }) {
                Text("Toggle Popup")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .popup(isShowing: $isShowingPopup, message: "This is popUp.", isError: false)
    }
}
