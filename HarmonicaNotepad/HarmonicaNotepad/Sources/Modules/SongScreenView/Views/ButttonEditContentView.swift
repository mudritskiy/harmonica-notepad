//
//  ButttonEditContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.10.2025.
//

import SwiftUI

struct ButttonEditContentView: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .foregroundStyle(.white)
            .frame(width: 16, height: 16, alignment: .center)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.75))
                    .frame(width: 32, height: 32, alignment: .center)
                    .padding(.trailing, 2)
                    .padding(.top, 2)
            }
    }
}

struct ButttonEditContentViewV2: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .foregroundStyle(.black)
            .font(.callout)
            .fontWeight(.light)
            .frame(width: 20, height: 20, alignment: .center)
    }
}

#Preview {
    VStack(spacing: 16) {
        ButttonEditContentView()
        ButttonEditContentViewV2()
    }
}
