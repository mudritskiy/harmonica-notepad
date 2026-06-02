//
//  AutoSizingBottomSheetModifier.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 17.03.2026.
//

import SwiftUI

// MARK: - Properties
struct AutoSizingBottomSheetProps {
    let title: String
    let titleFont: FontToken = .title3
    let titleColor: ColorToken = Theme.colors.text.secondary
    let backgroundColor: ColorToken
    let cornerRadius: CGFloat = 24
    let dragIndicatorVisibility: Visibility

    init(
        title: String = .empty,
        backgroundColor: ColorToken = Theme.colors.background.primary,
        dragIndicatorVisibility: Visibility = .visible
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.dragIndicatorVisibility = dragIndicatorVisibility
    }
}

// MARK: - Content Wrapper
private struct AutoSizingBottomSheetWrapper<Content: View>: View {
    let props: AutoSizingBottomSheetProps
    @ViewBuilder private let content: () -> Content

    // MARK: - Init
    init(
        props: AutoSizingBottomSheetProps,
        content: @escaping () -> Content
    ) {
        self.props = props
        self.content = content
    }

    // MARK: - Render
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            if !props.title.isEmpty {
                navigationBar
                    .padding(.vertical, 16)
                    .padding(.top, 4)
                CustomDivider
                    .horizontal()
            }
            content()
        }
        .frame(maxWidth: .infinity)
        .background(props.backgroundColor.color)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var navigationBar: some View {
        Text(props.title)
            .font(props.titleFont.value)
            .foregroundStyle(props.titleColor.color)
    }
}

// MARK: - View Modifier
struct AutoSizingBottomSheetModifier<SheetContent: View>: ViewModifier {
    @State private var adaptiveHeight: CGFloat = 0
    @Binding var isPresented: Bool

    let props: AutoSizingBottomSheetProps
    let sheetContent: SheetContent
    @State var isAdaptiveHeightChanged: Bool = false

    // MARK: - Init
    init(
        isPresented: Binding<Bool>,
        props: AutoSizingBottomSheetProps,
        @ViewBuilder _ sheetContent: () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.props = props
        self.sheetContent = sheetContent()
    }

    // MARK: - Render
    func body(content: Content) -> some View {
        ZStack {
            _contentBackgroundView(content: content)
            if isPresented {
                _backgroundBlurView
                    .transition(
                        .opacity.animation(
                            .easeInOut(duration: 0.1)
                        )
                    )
            }
        }
        .sheet(isPresented: $isPresented) {
            contentWrapperView
                .presentationDetents([.height(adaptiveHeight)])
                .presentationDragIndicator(props.dragIndicatorVisibility)
                .presentationBackground(props.backgroundColor.color)
                .presentationCornerRadius(props.cornerRadius)
        }
        .animation(.easeInOut(duration: 0.1), value: isPresented)
        .id(adaptiveHeight)
    }

    private var _backgroundBlurView: some View {
        Color.black
            .opacity(0.3)
            .blur(radius: 0)
            .ignoresSafeArea()
    }

    private func _contentBackgroundView(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                contentWrapperView
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .task(id: proxy.size.height) {
                                    adaptiveHeight = proxy.size.height
                                }
                        }
                    }
                    .hidden()
            }
    }

    private var contentWrapperView: some View {
        AutoSizingBottomSheetWrapper(props: props) {
            sheetContent
        }
    }
}

// MARK: - View Extension
extension View {
    func autoSizingBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        props: AutoSizingBottomSheetProps,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            AutoSizingBottomSheetModifier(
                isPresented: isPresented,
                props: props,
                content
            )
        )
    }
}
