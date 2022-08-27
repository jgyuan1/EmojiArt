//
//  PaletteEditor.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/18/22.
//

import SwiftUI

struct PaletteEditor: View {
//    @EnvironmentObject var paletteStore: PaletteStore
    //!!!always use the binding var to make changes
    // if you look up in the EnvironmentObject which is kind of ViewModel
    // and you change the found one
    // you can not update the views
    // because in this view, the found palette is bound to paletteToEdit
    // since paletteToEdit doesn't change, you will not have views updated
    
    //!!!!This view is bound to paletteToEdit 
    
    @Binding var paletteToEdit: PaletteStore.Palette
    
    @State var emojisWaitToInsert: String = ""
    
    var body: some View {
        List{
            nameSection
            addEmojisSection
            deleteEmojiSection
        }
        .frame(minWidth: 300, minHeight: 350)

    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $paletteToEdit.name)
        }
    }
    
    var addEmojisSection: some View {
        Section(header: Text("Name")) {
            TextField("Insert New Emojis", text:  $emojisWaitToInsert)
                .onChange(of: emojisWaitToInsert, perform: { emojis in
                    addEmojis(emojis)
                })
        }
        
    }
    
    var deleteEmojiSection: some View {
        Section(header: Text("double tap to delete")) {
            LazyVGrid(columns:[GridItem(.adaptive(minimum: 40))]) {
                ForEach(paletteToEdit.emojis.map({String($0)}), id:\.self){ emoji in
                    Text(emoji)
                        .onTapGesture(count: 2) {
                            deleteEmoji(emoji)
                        }
                }
            }
        }
    }
    
    func addEmojis(_ emojis: String) {
        paletteToEdit.addEmojis(emojis)
    }
    
    func deleteEmoji(_ emoji: String) {
        paletteToEdit.deleteEmoji(emoji)
        print("delete emoji" + emoji)
    }
    
}


