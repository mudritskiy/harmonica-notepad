//
//  SongsListRowView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftUI

struct SongsListRowView: View {
    let songsList: SongsList

    private var lastAddedDate: Date {
        songsList.songsData.max(by: { $0.addedDate < $1.addedDate })?.addedDate ?? songsList.createdDate
    }

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: songsList.color))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.3), lineWidth: songsList.isDefault ? 3 : 0)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(songsList.name)
                    .font(.headline)
                    .foregroundStyle(songsList.isDefault ? .blue : .primary)

                HStack {
                    Text("\(songsList.songsData.count) songs")
                    Text("•")
                    Text(lastAddedDate, style: .relative)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
//
//            Image(systemName: "chevron.right")
//                .foregroundStyle(.secondary)
//                .font(.caption)
        }
        .stretching()
        .padding(.vertical, 4)
    }
}
