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
    @State var managing:Bool = false
    @EnvironmentObject var paletteStore: PaletteStore
    var body: some View {
        HStack {
            menuButtonForEdit
            body(of: paletteStore.palettes[chosenIndexOfPalettes])
            
        }
    }
    func body(of palette: PaletteStore.Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(paletteStore.palettes[chosenIndexOfPalettes].emojis.map({String($0)}), id: \.self) { emojiString in
                        Text(emojiString)
                            .onDrag{NSItemProvider(object: emojiString as NSString)}
                    }
                }
            }
        }
        .id(palette.id)
        .transition(AnyTransition.scale)
        .popover(item: $paletteToEdit, content: { palette in
            PaletteEditor(paletteToEdit: $paletteStore.palettes.first(where: {
            $0.id == palette.id})! )} )
        .sheet(isPresented: $managing, content: {PaletteManager()})

    }
    
    var menuButtonForEdit: some View {
        Button(action: {
            withAnimation {
                chosenIndexOfPalettes = (chosenIndexOfPalettes+1) % paletteStore.palettes.count
            }
        } , label: {
            Image(systemName: "paintpalette")
        })
            .contextMenu(menuItems: {multiButtons})
    }
    
    @ViewBuilder
    var multiButtons: some View {
        AnimatedActionButton(title: "Edit", systemImageName: "pencil") {
            paletteToEdit = paletteStore.palettes[chosenIndexOfPalettes]
        }
        AnimatedActionButton(title: "Delete", systemImageName: "minus.circle") {
            paletteStore.deletePaletteAt(chosenIndexOfPalettes)
        }
        AnimatedActionButton(title: "New", systemImageName: "plus") {
            paletteStore.insertPalette(named: "New", emojis: "")
        }
        AnimatedActionButton(title: "Manager", systemImageName: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        //Menu has a greater than sign on the left
        Menu {
            ForEach (paletteStore.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = paletteStore.palettes.index(matching: palette) {
                        chosenIndexOfPalettes = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
}

