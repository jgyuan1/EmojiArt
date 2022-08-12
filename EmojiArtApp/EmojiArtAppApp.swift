//
//  EmojiArtAppApp.swift
//  EmojiArtApp
//
//  Created by Gaoyuan Jiang on 8/12/22.
//

import SwiftUI

@main
struct EmojiArtAppApp: App {
    let  document: EmojiArtViewModel = EmojiArtViewModel()
    var body: some Scene {
        WindowGroup {
            EmojiArtView(document: document)
        }
    }
}
