//
//  PaletteEditor.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/18/22.
//

import SwiftUI

struct PaletteEditor: View {
    @EnvironmentObject var paletteStore: PaletteStore
    @Binding var paletteToEdit: PaletteStore.Palette
    
    @State var emojisWaitToInsert: String = ""
    
    var body: some View {
        List{
            Text(paletteToEdit.name)
            TextField("Insert New Emojis", text: $emojisWaitToInsert)
            //emojis is the latest one of emojisWaitToInsert
                .onChange(of: emojisWaitToInsert, perform: { emojis in
                    addEmojis(emojis)
                })
            Section(content: {Text(paletteToEdit.emojis)}, header: {Text("emojis")})
        }
        .frame(minWidth: 300, minHeight: 350)

    }
    
    func addEmojis(_ emojis: String) {
        paletteStore.addEmojis(emojis, to: paletteToEdit)
    }
    
}


