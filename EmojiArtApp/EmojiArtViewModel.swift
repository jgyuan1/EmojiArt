//
//  EmojiArtViewModel.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import Foundation
import SwiftUI

class EmojiArtViewModel: ObservableObject{
    @Published private(set) var emojiArt:EmojiArt {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArt()
        emojiArt.addEmoji("🍏", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🍎", at: (300, 150), size: 80)
        emojiArt.addEmoji("🫐", at: (0, 0), size: 80)
    }

    
    var emojis:[EmojiArt.Emoji] {
        emojiArt.emojis
    }
    //get{} set{}????????
    var background: EmojiArt.Background {
        emojiArt.background
    }
//    
//    init(emojiChoices: String) {
//        emojiChoices.map({String($0)})
//    }
    //some intent
    
    
    var maxLocationOfAllEmojis: (x: Int, y: Int) {
        var x:Int = 0
        var y:Int = 0
        for emoji in emojis {
            if abs(emoji.x) > abs(x) {
                x = emoji.x
            }
            if abs(emoji.y) > abs(y) {
                y = emoji.y
            }
        }
        return (abs(x), abs(y))
    }
    
    //MARK: - Select Emoji
    
    @Published var selectedEmoji: EmojiArt.Emoji? = nil
    
    
    
    // MARK: - Background
    @Published var backgroundImage: UIImage?
    var backgroundImageFetchStatus:BackgroundImageFetchStatus = .idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArt.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                    
                }
            }
        case .blank:
            break
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        }
    }
    
    func addEmoji(text: String, at location: (x:Int, y: Int), size: CGFloat){
        emojiArt.addEmoji(text, at: location, size: Int(size))
    }
    
    func setBackground(_ background: EmojiArt.Background) {
        emojiArt.setBackground(background)
        print("background changed to \(background)")
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        //Cannot use mutating member on immutable value: 'emoji' is a 'let' constant
        // !!!!emoji.changeSize(size)
        //change the one in the model
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    func shiftLocationForEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize, scale steadyZoomScale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].shiftLocationBy((Int(offset.width/steadyZoomScale), Int(offset.height/steadyZoomScale)))
        }
    }
    // ????? why can't we use id to compare 
    func isSameEmoji(_ emoji1: EmojiArt.Emoji, and emoji2: EmojiArt.Emoji) -> Bool {
        if let index1 = emojiArt.emojis.index(matching: emoji1) {
            if let index2 = emojiArt.emojis.index(matching: emoji2) {
                if index1 == index2 {
                   return true
                }
            }
        }
        return false
    }
}
