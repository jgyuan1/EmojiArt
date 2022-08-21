//
//  PalletManager.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/17/22.
//

import Foundation
import SwiftUI

struct PaletteManager: View {
    @Environment(\.isPresented) private var isPresented
    //dismiss is a handler to dismiss a presentation
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var store: PaletteStore
    
    @State private var editMode: EditMode = .inactive
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink {
                        PaletteEditor(paletteToEdit: $store.palettes.first(where: {$0.id == palette.id})! )
                            .environment(\.colorScheme, .dark)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                        .gesture(editMode == .active ? tap : nil)
                    }


                }
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                // teach the ForEach how to move items
                // at the indices in indexSet to a newOffset in its array
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    if isPresented, UIDevice.current.userInterfaceIdiom != .pad  {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    var tap: some Gesture {
        TapGesture().onEnded{}
    }
    
    
    
    
    
}
