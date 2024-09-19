//
//  PopupViewModifier.swift
//  MissMatch
//
//  Created by Anatoliy Petrov on 19.9.24..
//

import SwiftUI

struct PopupViewModifier: ViewModifier {
    @Binding var isShowing: Bool
    var message: String
    var isError: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isShowing {
                VStack {
                    Text(message)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            VisualEffectBlur(blurStyle: .systemMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isError ? Color.red : Color.green, lineWidth: 2)
                        )
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            isShowing = false
                        }
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.height < 0 {
                                    isShowing = false
                                }
                            }
                        )
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.6), value: isShowing)
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
            Text("Main Content")
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
        .popup(isShowing: $isShowingPopup, message: "This is a glass popup!", isError: false)
    }
}
