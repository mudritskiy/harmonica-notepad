//
//  WrappedTextListView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import SwiftUI

struct WrappedTextListView: View {
    struct Item {
        let text: String
        let action: Action
    }

    let items: [Item]
    let rowsCount: Int
    let minimumRowCount: Int
    let rowSpacing: CGFloat
    let elementSpacing: CGFloat
    let itemProps: WrappedTextListItemViewProps

    // MARK: - Init
    init(
        items: [Item],
        itemProps: WrappedTextListItemViewProps,
        rowsCount: Int = 3,
        minimumRowCount: Int = 3,
        rowSpacing: CGFloat = 8,
        elementSpacing: CGFloat = 8
    ) {
        let minimumRowCount = min(items.count, minimumRowCount)
        self.items = items
        self.itemProps = itemProps
        self.rowsCount = max(rowsCount, minimumRowCount)
        self.minimumRowCount = minimumRowCount
        self.rowSpacing = rowSpacing
        self.elementSpacing = elementSpacing
    }

    // MARK: - Render
    public var body: some View {
        HorizontalGeometryReader { width in
            VStack(alignment: .leading, spacing: rowSpacing) {
                ForEach(_calculateRows(for: items, in: width), id: \.self) { row in
                    HStack(spacing: elementSpacing) {
                        ForEach(row, id: \.self) { index in
                            let item = items[index]
                            WrappedTextListItemView(
                                item: item,
                                props: itemProps
                            )
                            .id(item.text)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func _calculateRows(for items: [Item], in availableWidth: CGFloat) -> [[Int]] {
        var rows: [[Int]] = [[]]
        var currentRow = 0
        var currentWidth: CGFloat = 0

        let label = UILabel()
        label.font = itemProps.font.uiFont

        for (index, item) in items.enumerated() {
            label.text = item.text
            var phraseWidth = label.intrinsicContentSize.width
            + elementSpacing * 2
            + itemProps.insets.leading * 2
            phraseWidth = min(phraseWidth, availableWidth)

            if currentWidth + phraseWidth > availableWidth {
                if currentRow >= (rowsCount - 1) { break }
                currentRow += 1
                rows.append([])
                currentWidth = 0
            }

            rows[currentRow].append(index)
            currentWidth += phraseWidth
        }

        return rows
    }
}

// MARK: - WrappedTextListItemView
struct WrappedTextListItemViewProps {
    let itemLineLimit: Int
    let font: FontToken
    let color: ColorToken
    let backgroundColor: ColorToken
    let borderColor: ColorToken?
    let cornerRadius: CGFloat
    let insets: EdgeInsets

    init(
        itemLineLimit: Int = 1,
        font: FontToken = .body2,
        color: ColorToken = Theme.colors.text.primary,
        backgroundColor: ColorToken = Theme.colors.background.secondary,
        borderColor: ColorToken? = nil,
        cornerRadius: CGFloat = 24,
        insets: EdgeInsets
    ) {
        self.itemLineLimit = itemLineLimit
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.insets = insets
    }
}

public  struct WrappedTextListItemView: View {
    let item: WrappedTextListView.Item
    let props: WrappedTextListItemViewProps

    public var body: some View {
        _element()
    }

    private func _element() -> some View {
        Button(action: item.action) {
            if let borderColor = props.borderColor {
                _elementInnerContent()
                    .overlay {
                        RoundedRectangle(cornerRadius: props.cornerRadius)
                            .strokeBorder(
                                borderColor.color,
                                lineWidth: 1
                            )
                    }
            } else {
                _elementInnerContent()
            }
        }
    }

    private func _elementInnerContent() -> some View {
        Text(item.text)
            .font(props.font.value)
            .foregroundStyle(props.color.color)
            .lineLimit(props.itemLineLimit)
            .padding(props.insets)
            .background(props.backgroundColor.color)
            .cornerRadius(props.cornerRadius)
    }
}
