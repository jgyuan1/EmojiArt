//
//  EmojiArt.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import Foundation
import SwiftUI
struct EmojiArt {
    var emojis:[Emoji] = []
    var background: Background = Background.blank
    
    private var uniqueId = 0
    
    init() {}
    
    
    mutating func addEmoji(_ text: String, at location:(x: Int, y: Int), size: Int) {
        uniqueId += 1
        emojis.append(Emoji(text: text, x:location.x, y: location.y, size: size, id:uniqueId))
    }
    
    mutating func setBackground(_ background: Background){
        self.background = background
    }
    

    
    struct Emoji: Identifiable, Hashable {
        var text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text:String, x: Int, y: Int, size: Int, id:Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
        mutating func changeSize(_ size: Int) {
            self.size = size
        }
        mutating func shiftLocationBy(_ offset:(x: Int, y: Int)){
            self.x += offset.x
            self.y += offset.y
        }

    }
}
