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
        emojiArt.addEmoji("🍎", at: (200, 100), size: 80)
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
    
    //MARK: - Select Emoji
    
    @Published var selectedEmoji: EmojiArt.Emoji? 
    
    
    
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
}
