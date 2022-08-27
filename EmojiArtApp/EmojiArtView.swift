//
//  ContentView.swift
//  EmojiArtApp
//
//  Created by Gaoyuan Jiang on 8/12/22.
//

import SwiftUI

struct EmojiArtView: View {
    let emojiChoices: String = "😲😮‍💨👿👻🤖😻🤝👨‍🦱🧑‍🦱🧔🍏🍎🍉🍒🥝🥬🥕🫒🥐🧀🧇🦴🌯🍕"
    @SceneStorage("EmojiArtView.steadyZoomScale")
    private var steadyZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    private var dynamicZoomScale:CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    let defaultEmojiFontSize: CGFloat = 40
    //a reference to an observableObject
    // a reference to a source of truth
    // never assign it sth
    @ObservedObject var document: EmojiArtViewModel
    
    @Environment(\.undoManager) var undoManager

    var body: some View {
        VStack {
            emojisCanvas
            buttonToDeselectAndDisplayedInfoOfSelected
            PaletteChooser()
        }
    }
    
    var buttonToDeselectAndDisplayedInfoOfSelected: some View {
        VStack{
            if document.selectedEmoji != nil {
//                let selected = document.selectedEmoji
                Button("Deselect Emoji") {
                    document.selectedEmoji = nil
                }
//                Text(selected.text + " x:" + selected.x + "y:" + selected.y)
            } else {
                Text("selecte any emoji and then drag to move and pinch to zoom")
            }
        }
    }
    
    var emojisCanvas: some View {
        GeometryReader { geometry in
            ZStack{
                Color.orange.overlay(OptionalImageView(uiImage: document.backgroundImage)
                                        .scaleEffect(dynamicZoomScale)
                                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                                        .gesture(doubleTapToZoom(in: geometry))
                )
                    
                
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .scaleEffect(dynamicZoomScale)
                        .position( position(for: emoji, in: geometry))
                        .gesture( tapToSelectEmoji(emoji: emoji))
                        .opacity( setOpacityForEmoji(emoji) )
                    // when shifting the emoji, its loacation will get updatting
                    // compare them based on their ids.
//                        .opacity(((emoji.id) == (document.selectedEmoji.id)) ? 0.5 : 1 )
                }
            }
            .clipped()
            .onDrop(of:[.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            //don't use two gestures chaining together
            .gesture(zoomGesture().simultaneously(with: dragGestureToShift()))
//            .simultaneousGesture(doubleTapToZoom(in: geometry))
            .toolbar {
                UndoButton(
                    undo: undoManager?.optionalUndoMenuItemTitle,
                    redo: undoManager?.optionalRedoMenuItemTitle
                )
            }
        }

    }
    //MARK: select emoji then you can zoom and shift
    private func tapToSelectEmoji(emoji: EmojiArt.Emoji) -> some Gesture {
        //Can not tap for a second time to deselect an emoji？
        TapGesture()
            .onEnded {
                document.selectedEmoji = emoji
//                print("tap gesture just ended")
//                if let selected = document.selectedEmoji {
//                    if selected.id != emoji.id {
//                        document.selectedEmoji = emoji
//                    } else {
//                        document.selectedEmoji = nil
//                    }
////                    print("select emoji \(emoji)" )
//                } else {
//                    document.selectedEmoji = emoji
//                }
            }
    }
    
//    private func singleTapToDeselect() -> some Gesture {
//        TapGesture(count: 1)
//            .onEnded {
//                document.selectedEmoji = nil
//                print("deselect emoji")
//            }
//    }
    
    private func setOpacityForEmoji(_ emoji: EmojiArt.Emoji) -> Double {
        if let selected = document.selectedEmoji {
            if selected.id == emoji.id {
                return 0.5
            } else {
                return 1.0
            }
        } else {
            return 1.0
        }
    }
    
    
    
    private func doubleTapToZoom(in geometry: GeometryProxy) -> some Gesture {
        // doubleTap to zoom all the things with screen
        TapGesture(count: 2)
            .onEnded({
                document.selectedEmoji = nil
                withAnimation {
                    zoomToFit(document.backgroundImage, in: geometry)
                }
            })
    }
    
    private func zoomToFit(_ image: UIImage?, in geometry:GeometryProxy) {
        if let image = image, image.size.width > 0, image.size.height > 0, geometry.size.width > 0, geometry.size.height > 0 {
            steadyOffset = CGSize.zero
            print("image size is \(image.size)")
            print("maxLocation is \(document.maxLocationOfAllEmojis)")
            let maxX: CGFloat = max(image.size.width, CGFloat(document.maxLocationOfAllEmojis.x)*2)
            let maxY: CGFloat = max(image.size.height, CGFloat(document.maxLocationOfAllEmojis.y)*2)
            let hzoom = geometry.size.width / maxX
            let vzoom = geometry.size.height / maxY
            print("hzoom is \(hzoom) and vzoom is \(vzoom)")
            print("geometry size is \(geometry.size)")
            steadyZoomScale = min(hzoom, vzoom)
            print("steadyZoomScale is \(steadyZoomScale)")
            print("dynamicZoomScale is \(dynamicZoomScale)")
        }
    }
    
    //MARK: -shift
    // in the non-scaleEffect mode what CGSize backgroundImage has shifted
    // SceneStorage must implement RawPresentation
    @SceneStorage("EmojiArtView.steadyOffset")
    private var steadyOffset: CGSize = CGSize.zero
    // kind of a read only var
    @GestureState private var gestureOffset: CGSize = .zero
    @GestureState private var gestureOffsetForEmoji: CGSize = .zero
    //
    private var dynamicTotalOffset: CGSize {
        CGSize(width: steadyOffset.width * dynamicZoomScale + gestureOffset.width, height: steadyOffset.height * dynamicZoomScale
               + gestureOffset.height)
    }
    
    private func dragGestureToShift() -> some Gesture {
        if let emoji = document.selectedEmoji {
            return DragGesture()
                .updating($gestureOffsetForEmoji) { latestGestureOffset, gestureOffsetForEmoji, _ in
                    gestureOffsetForEmoji = latestGestureOffset.translation
                }
                .onEnded { finalGestureOffset in
                    document.shiftLocationForEmoji(emoji, by: finalGestureOffset.translation, scale: steadyZoomScale, with: undoManager)
//                    steadyOffset.height += finalGestureOffset.translation.height
//                    steadyOffset.width += finalGestureOffset.translation.width
                }
        } else {
            return DragGesture()
                .updating($gestureOffset) { latestGestureOffset, gestureOffset, _ in
                    gestureOffset = latestGestureOffset.translation
                }
                .onEnded { finalGestureOffset in
                    steadyOffset.height += finalGestureOffset.translation.height/steadyZoomScale
                    steadyOffset.width += finalGestureOffset.translation.width/steadyZoomScale
                }
        }

    }
    
    
    @GestureState private var gestureZoomScaleForEmoji:CGFloat = 1
    
    private func zoomGesture() -> some Gesture {
        if let emoji = document.selectedEmoji {
            return MagnificationGesture()
                .updating($gestureZoomScaleForEmoji, body: { latestGestureScale, gestureZoomScaleForEmoji, _ in
                    gestureZoomScaleForEmoji = latestGestureScale
                })
                .onEnded({gestureScaleAtEnd in
                    document.scaleEmoji(emoji, by: gestureScaleAtEnd, with: undoManager)
                })
        } else {
            return MagnificationGesture()
                .updating($gestureZoomScale, body: { latestGestureScale, gestureZoomScale, _ in
                    gestureZoomScale = latestGestureScale
                })
                .onEnded({gestureScaleAtEnd in
                    steadyZoomScale *= gestureScaleAtEnd
                })
        }
    }
    
    private func drop(providers:[NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self, using: {url in
            document.setBackground(.url(url.imageURL), with: undoManager)
        })
        if !found {
            found = providers.loadObjects(ofType: UIImage.self, using: {image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data), with: undoManager)
                }
            })
        }
        if !found {
            found = providers.loadObjects(ofType: String.self, using: { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(location, in: geometry), size: defaultEmojiFontSize, with: undoManager)
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

    
        
    private func position(for emoji:EmojiArt.Emoji, in geometry: GeometryProxy) -> CGPoint {
        if let selected = document.selectedEmoji, emoji.id == selected.id {
            let originOfDynamicShift = convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
            let x = originOfDynamicShift.x + gestureOffsetForEmoji.width
            let y = originOfDynamicShift.y + gestureOffsetForEmoji.height
            return CGPoint(x: x, y: y)
        } else {
            return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
        }
    }
    
    //EmojiCoordinate has geometry.frame(in: .local).center as origin
    // x axis is pointing to right
    // y axis is pointing downwards
    // this is the one in the model
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x  - center.x - dynamicTotalOffset.width) / dynamicZoomScale,
            y: (location.y  - center.y - dynamicTotalOffset.height / dynamicZoomScale)
        )
        return (Int(location.x), Int(location.y))
    }
    // this one is on the screen
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
                    return CGPoint(x:center.x + CGFloat(location.x)*dynamicZoomScale + dynamicTotalOffset.width, y: center.y + CGFloat(location.y)*dynamicZoomScale + dynamicTotalOffset.height)
    }
    
    
    func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        if let selected = document.selectedEmoji, emoji.id == selected.id {
            return CGFloat(emoji.size ) * gestureZoomScaleForEmoji
        } else {
            return CGFloat(emoji.size)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static let  document: EmojiArtViewModel = EmojiArtViewModel()
    static var previews: some View {
        EmojiArtView(document: document)
    }
}
