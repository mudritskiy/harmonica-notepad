//
//  ServiceKeyboardViews.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 25.03.2026.
//

import SwiftUI

enum ServiceKeyboardEvent {
    case addNewLine
    case addSpace
    case removeLast
    case showSettings
}

struct ServiceKeyboardProps: Equatable {
    let cornerRadius: CGFloat
    let keySize: CGSize
    let font: FontToken
    let fontColor: Color
    let backgroundColor: Color
    let borderColor: Color

    let events: EventStream<ServiceKeyboardEvent>

    static func == (lhs: ServiceKeyboardProps, rhs: ServiceKeyboardProps) -> Bool {
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.keySize == rhs.keySize &&
        lhs.font == rhs.font &&
        lhs.fontColor == rhs.fontColor &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.borderColor == rhs.borderColor
    }
}

struct ServiceKeyboardView: View {
    let props: ServiceKeyboardProps

    // MARK: - Render
    var body: some View {
        _serviceKeys()
            .font(props.font.value)
            .foregroundColor(props.fontColor)
            .shadow(
                color: Theme.colors.background.shadow.color,
                radius: 1,
                x: 0,
                y: 0
            )
    }

    private func _serviceKeys() -> some View {
        VStack(
            alignment: .trailing,
            spacing: 0
        ) {
            _removeKey()
                .padding(2)
            HStack(
                alignment: .center,
                spacing: 4
            ) {
                _settingsKey()
                _spaceKey()
                _newLineKey()
            }
            .padding(2)
        }
    }

    private func _removeKey() -> some View {
        Button {
            props.events.send(.removeLast)
        } label: {
            Image(systemName: "delete.left.fill")
                .frame(
                    width: props.keySize.width * 1.5,
                    height: props.keySize.height
                )
                .serviceKeyboardKeyStyle(props: props)
        }
    }

    private func _settingsKey() -> some View {
        Button {
            props.events.send(.showSettings)
        } label: {
            Image(systemName: "gearshape.fill")
                .frame(
                    width: props.keySize.width,
                    height: props.keySize.height
                )
                .serviceKeyboardKeyStyle(props: props)
        }
    }

    private func _spaceKey() -> some View {
        Button {
            props.events.send(.addSpace)
        } label: {
            Text("space")
                .frame(
                    width: props.keySize.width * 5,
                    height: props.keySize.height
                )
                .serviceKeyboardKeyStyle(props: props)
        }
    }

    private func _newLineKey() -> some View {
        Button {
            props.events.send(.addNewLine)
        } label: {
            Image(systemName: "return")
                .frame(
                    width: props.keySize.width * 2,
                    height: props.keySize.height
                )
                .serviceKeyboardKeyStyle(props: props)
        }
    }
}

// MARK: - Key Style
extension View {
    func serviceKeyboardKeyStyle(props: ServiceKeyboardProps) -> some View {
        self
            .background(props.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: props.cornerRadius)
                    .stroke(props.borderColor, lineWidth: 1)
            )
            .cornerRadius(props.cornerRadius)
    }
}
