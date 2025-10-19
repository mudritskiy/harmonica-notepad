//
//  View+AlertInfoModifier.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 19.10.2025.
//

import SwiftUI

// MARK: - AlertInfo
struct AlertInfo {
    var title: String
    var message: String?
    var buttons: [AlertButton]
}

extension AlertInfo {
    static func empty() -> AlertInfo {
        AlertInfo(title: "", message: nil, buttons: [])
    }
}

// MARK: - AlertButton
struct AlertButton {
    var title: String
    var role: ButtonRole?
    var action: () -> Void

    init(
        _ title: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.role = role
        self.action = action
    }
}

// MARK: - AlertInfoModifier
struct AlertInfoModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alert: AlertInfo

    func body(content: Content) -> some View {
        content.alert(alert.title, isPresented: $isPresented) {
            ForEach(0..<alert.buttons.count, id: \.self) { index in
                let button = alert.buttons[index]
                Button(button.title, role: button.role, action: button.action)
            }
        } message: {
            if let message = alert.message {
                Text(message)
            }
        }
    }
}

// MARK: - View
extension View {
    func alertInfo(isPresented: Binding<Bool>, _ alert: AlertInfo) -> some View {
        self.modifier(
            AlertInfoModifier(
                isPresented: isPresented,
                alert: alert
            )
        )
    }
}
