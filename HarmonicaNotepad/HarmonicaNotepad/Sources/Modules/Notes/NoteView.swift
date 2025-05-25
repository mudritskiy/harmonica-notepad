//
//  BarLineView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 25.05.2025.
//

import SwiftUI

struct NoteView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("4")
                .font(.caption)
                .fontWeight(.bold)
                .padding(6)
                .background(Circle().fill(Color.white).shadow(radius: 2))
                .overlay(Circle().stroke(Color.black, lineWidth: 1))

            ZStack {
                NoteStaffView()
                EighthNoteView()
                BarLineView()
            }
        }
    }
}

struct NoteStaffView: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { _ in
                Rectangle()
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
            }
        }
        .frame(height: 50)
    }
}

struct BarLineView: View {
    var body: some View {
        Rectangle()
            .frame(width: 2, height: 50)
            .foregroundColor(.black)
            .offset(x: 80)
    }
}

// MARK: - EighthNoteView
struct EighthNoteView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Нота (голівка)
                Ellipse()
                    .rotation(.degrees(-20))
                    .frame(width: 16, height: 10)
                    .foregroundColor(.black)
                    .position(x: geometry.size.width / 2 - 10, y: geometry.size.height / 2)

                // Стебло (вертикальна лінія)
                Rectangle()
                    .frame(width: 1.5, height: 30)
                    .foregroundColor(.black)
                    .position(x: geometry.size.width / 2 - 2, y: geometry.size.height / 2 - 5)

                // Хвостик
                Path { path in
                    let startPoint = CGPoint(x: geometry.size.width / 2 - 2, y: geometry.size.height / 2 - 20)
                    path.move(to: startPoint)
                    path.addQuadCurve(
                        to: CGPoint(x: startPoint.x + 10, y: startPoint.y + 6),
                        control: CGPoint(x: startPoint.x + 8, y: startPoint.y - 2)
                    )
                }
                .stroke(Color.black, lineWidth: 1.5)
            }
        }
        .frame(width: 40, height: 50)
        .offset(y: 9)
    }
}
