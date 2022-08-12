//
//  EmojiArtViewModel.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import Foundation
import SwiftUI

class EmojiArtViewModel: ObservableObject{
    @Published var emojiArt:EmojiArt
    
    init() {
        emojiArt = EmojiArt()
        emojiArt.addEmoji("🍏", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🍎", at: (200, 100), size: 80)
        emojiArt.addEmoji("🫐", at: (0, 0), size: 80)
    }

    
    var emojis:[EmojiArt.Emoji] {
        emojiArt.emojis
    }
    //get{} set{}????????
    var background: Background {
        emojiArt.background
    }
//    
//    init(emojiChoices: String) {
//        emojiChoices.map({String($0)})
//    }
    //some intent
    func addEmoji(text: String, at location: (x:Int, y: Int), size: Int){
        emojiArt.addEmoji(text, at: location, size: size)
    }
    
    func changeBackground(_ background: Background) {
        emojiArt.changeBackground(background)
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        //Cannot use mutating member on immutable value: 'emoji' is a 'let' constant
        // !!!!emoji.changeSize(size)
        //change the one in the model
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
