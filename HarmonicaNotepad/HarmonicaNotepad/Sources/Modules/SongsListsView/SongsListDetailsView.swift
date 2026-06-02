//
//  SongsListDetailsView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftData
import SwiftUI

struct SongsListDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // For editing existing list
    @Bindable var songsList: SongsList
    let isNewSongsList: Bool

    // For creating new list
//    init(songsList: SongsList? = nil) {
//        self.songsList = songsList
//    }


    init(songsList: SongsList) {
        self.songsList = songsList
        isNewSongsList = false
    }

    init() {
        self.songsList = SongsList(name: .empty)   // creating new one
        isNewSongsList = true
    }

    // Local state – only committed on Apply
    @State private var name: String = ""
    @State private var color: Color = Color(hex: "FF5733")
    @State private var comment: String = ""
    @State private var isDefault: Bool = false

    private var isEditing: Bool { !songsList.name.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("List Name") {
                    TextField("e.g. Blues Classics, Fast Songs", text: $name)
                        .font(.title3)
                        .bold()
                }

                Section("Color") {
                    HStack {
                        ColorPicker("Pick color", selection: $color, supportsOpacity: false)
                            .labelsHidden()

                        Spacer()

                        Circle()
                            .fill(color)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(isDefault ? Color.blue : Color.clear, lineWidth: 3)
                            )
                            .shadow(radius: 2)
                    }
                }

                Section("Comment") {
                    TextField("Optional note", text: $comment, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Set as default list", isOn: $isDefault)
                }
            }
            .navigationTitle(isEditing ? "Edit List" : "New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Close button (cross)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .tint(.primary)
                }

                // Apply button (checkmark)
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveAndDismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .tint(name.isEmpty ? .secondary : .primary)
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if !isNewSongsList {
                    name = songsList.name
                    color = Color(hex: songsList.color)
                    comment = songsList.comment
                    isDefault = songsList.isDefault
                }
            }
        }
    }

    private func saveAndDismiss() {
        let finalColorHex = color.hex

//        if !isNewSongsList {
            // Edit existing
            songsList.name = name
            songsList.color = finalColorHex
            songsList.comment = comment

            // Handle default list logic
            if isDefault && !songsList.isDefault {
                resetOtherDefaults(except: songsList.id)
            }
            songsList.isDefault = isDefault

//        } else {
//            // Create new
//            let newList = SongsList(
//                name: name,
//                color: finalColorHex,
//                comment: comment,
//                isDefault: isDefault
//            )
//
//            if isDefault {
//                resetOtherDefaults(except: newList.id)
//            }
        if isNewSongsList {
            modelContext.insert(songsList)
        }
//        }

        try? modelContext.save()
        dismiss()
    }

    private func resetOtherDefaults(except excludedId: SongsListId) {
        let fetch = FetchDescriptor<SongsList>(
            predicate: #Predicate { $0.id != excludedId && $0.isDefault }
        )
        if let others = try? modelContext.fetch(fetch) {
            for other in others {
                other.isDefault = false
            }
        }
    }
}
