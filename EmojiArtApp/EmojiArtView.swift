//
//  ContentView.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import SwiftUI

struct EmojiArtView: View {
    let emojiChoices: String = "😲😮‍💨👿👻🤖😻🤝👨‍🦱🧑‍🦱🧔🍏🍎🍉🍒🥝🥬🥕🫒🥐🧀🧇🦴🌯🍕"
    @State private var zoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
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
                Color.orange.overlay(OptionalImageView(uiImage: document.backgroundImage)
                                        .scaleEffect(zoomScale)
                                        .position(convertFromEmojiCoordinates((0,0), in: geometry)))
                    .gesture(doubleTapToZoom(in: geometry.size))
                
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(shiftedPosition(for: emoji, in: geometry, shift: dynamicTotalOffset))
                        .gesture(tapToSelectEmoji(emoji: emoji))
                        .opacity(emoji == document.selectedEmoji ? 0.5 : 1 )
                }
            }
            .onDrop(of:[.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            //don't use two gestures chaining together
            .gesture(zoomGesture().simultaneously(with: dragGestureToShift()))
        }

    }
    
    private func tapToSelectEmoji(emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                document.selectedEmoji = emoji
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded({
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            })
    }
    
    private func zoomToFit(_ image: UIImage?, in size:CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hzoom = size.width / image.size.width
            let vzoom = size.height / image.size.height
            zoomScale = min(hzoom, vzoom)
            
        }
    }
    
    //MARK: -shift
    @State private var steadyOffset: CGSize = CGSize.zero
    // kind of a read only var
    @GestureState private var gestureOffset: CGSize = .zero
    //
    private var dynamicTotalOffset: CGSize {
        CGSize(width: steadyOffset.width + gestureOffset.width, height: steadyOffset.height + gestureOffset.height)
    }
    
    private func dragGestureToShift() -> some Gesture {
        DragGesture()
            .updating($gestureOffset) { latestGestureOffset, gestureOffset, _ in
                gestureOffset = latestGestureOffset.translation
            }
            .onEnded { finalGestureOffset in
                steadyOffset.height += finalGestureOffset.translation.height
                steadyOffset.width += finalGestureOffset.translation.width
            }
    }
    
    
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            })
            .onEnded({gestureScaleAtEnd in
                zoomScale *= gestureScaleAtEnd
            })
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
    
    private func shiftedPosition(for emoji: EmojiArt.Emoji, in geometry: GeometryProxy, shift offset: CGSize) -> CGPoint {
        let originalPoint = position(for: emoji, in: geometry)
        return CGPoint(x: originalPoint.x + offset.width, y: originalPoint.y + offset.height)
    }
    //EmojiCoordinate has geometry.frame(in: .local).center as origin
    // x axis is pointing to right
    // y axis is pointing downwards
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x  - center.x - dynamicTotalOffset.width) / zoomScale,
            y: (location.y  - center.y - dynamicTotalOffset.height / zoomScale)
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
                    return CGPoint(x:center.x + CGFloat(location.x)*zoomScale + dynamicTotalOffset.width, y: center.y + CGFloat(location.y)*zoomScale + dynamicTotalOffset.height)
    }
    
    
    func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size * Int(zoomScale))
    }
}

struct ContentView_Previews: PreviewProvider {
    static let  document: EmojiArtViewModel = EmojiArtViewModel()
    static var previews: some View {
        EmojiArtView(document: document)
    }
}
