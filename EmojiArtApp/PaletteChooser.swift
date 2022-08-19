//
//  PaletteChooser.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/18/22.
//

import SwiftUI

struct PaletteChooser: View {
    @State var chosenIndexOfPalettes: Int = 0
    @State var paletteToEdit: PaletteStore.Palette?
    @EnvironmentObject var paletteStore: PaletteStore
    var body: some View {
        HStack {
            menuButtonForEdit
            body(of: paletteStore.palettes[chosenIndexOfPalettes])
        }
    }
    func body(of palette: PaletteStore.Palette) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(paletteStore.palettes[chosenIndexOfPalettes].emojis.map({String($0)}), id: \.self) { emojiString in
                    Text(emojiString)
                        .onDrag{NSItemProvider(object: emojiString as NSString)}
                }
            }
            .popover(item: $paletteToEdit, content: { palette in
                PaletteEditor(paletteToEdit: $paletteStore.palettes.first(where: {
                $0.id == palette.id})! )} )
        }
    }
    
    var menuButtonForEdit: some View {
        Button(action: {chosenIndexOfPalettes = (chosenIndexOfPalettes+1) % paletteStore.palettes.count} , label: {Image(systemName: "paintpalette") })
            .contextMenu(menuItems: {multiButtons})
            
    }
    
    @ViewBuilder
    var multiButtons: some View {
        AnimatedActionButton(title: "Edit", systemImageName: "pencil") {
            paletteToEdit = paletteStore.palettes[chosenIndexOfPalettes]
        }
        AnimatedActionButton(title: "Delete", systemImageName: "minus.circle") {
            paletteToEdit = paletteStore.palettes[chosenIndexOfPalettes]
        }
        AnimatedActionButton(title: "New", systemImageName: "plus") {
            paletteToEdit = paletteStore.palettes[chosenIndexOfPalettes]
        }
    }
}

