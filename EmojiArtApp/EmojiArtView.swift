//
//  ContentView.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import SwiftUI

struct EmojiArtView: View {
    let emojiChoices: String = "😲😮‍💨👿👻🤖😻🤝👨‍🦱🧑‍🦱🧔🍏🍎🍉🍒🥝🥬🥕🫒🥐🧀🧇🦴🌯🍕"
    var zoomScale: CGFloat = 2
    let defaultEmojiFontSize: CGFloat = 40
    
    @ObservedObject var document: EmojiArtViewModel

    var body: some View {
        VStack {
            emojisCanvas
            pallete
        }
    }
    
    var emojisCanvas: some View {
        GeometryReader { geometry in
            ZStack{
                Color.orange.overlay(OptionalImageView(uiImage: document.backgroundImage))
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
            .onDrop(of:[.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
        }

    }
    
    private func drop(providers:[NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self, using: {url in
            document.setBackground(.url(url.imageURL))
        })
        if !found {
            found = providers.loadObjects(ofType: UIImage.self, using: {image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            })
        }
        if !found {
            found = providers.loadObjects(ofType: String.self, using: { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: defaultEmojiFontSize)
                }
            })
        }
        return found
//        return providers.loadObjects(ofType: String.self) { string in
//            if let emoji = string.first, emoji.isEmoji {
//                document.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: 32)
//            }
//        }
    }
    
    var pallete: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojiChoices.map({String($0)}), id: \.self) { emojiString in
                    Text(emojiString)
                        .onDrag{NSItemProvider(object: emojiString as NSString)}
                }
            }
        }
    }
    
    private func position(for emoji:EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    //EmojiCoordinate has geometry.frame(in: .local).center as origin
    // x axis is pointing to right
    // y axis is pointing downwards
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x  - center.x),
            y: (location.y  - center.y)
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) ->CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x:center.x + CGFloat(location.x), y: center.y + CGFloat(location.y))
    }
    
    
    func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let  document: EmojiArtViewModel = EmojiArtViewModel()
    static var previews: some View {
        EmojiArtView(document: document)
    }
}
