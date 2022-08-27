//
//  EmojiArtAppApp.swift
//  EmojiArtApp
//
//  Created by Gaoyuan Jiang on 8/12/22.
//

import SwiftUI

@main
struct EmojiArtAppApp: App {
//    @StateObject var document: EmojiArtViewModel = EmojiArtViewModel()
    @StateObject var paletteStore: PaletteStore = PaletteStore(name: "default")
    var body: some Scene {
//        WindowGroup {
//            EmojiArtView(document: document)
//                .environmentObject(paletteStore)
//        }
        DocumentGroup(newDocument: {EmojiArtViewModel()}, editor: {config in
            EmojiArtView(document: config.document)
                            .environmentObject(paletteStore)
        })
    }
}
