//
//  EmojiArtViewModel.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/12/22.
//

import Foundation
import SwiftUI
import Combine //
import UniformTypeIdentifiers // framework for UTType and identifier

extension UTType {
    public static let emojiart = UTType(exportedAs:"CS193p2022jgyProject2.EmojiArtApp")
}

class EmojiArtViewModel: ReferenceFileDocument{
    
    // MARK: - ReferenceFileDocument
    static var readableContentTypes: [UTType] = [UTType.emojiart]
    static var writableContentTypes: [UTType] = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
            fetchBackgroundImageDataIfNecessary()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    

    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: snapshot)
    }
    
    
    
    
    
    @Published private(set) var emojiArt:EmojiArt {
        didSet {
//            autosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArt()
    }
    
//    func autosave() {
//        if let url = Autosave.url {
//            save(to: url)
//        }
//    }
    
    //save to documentDirectory
    //the path to it is a URL
    
//    private struct Autosave {
//        static let filename = "Autosaved.emojiart"
//        static var url: URL? {
//            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//            return documentDirectory?.appendingPathComponent(filename)
//        }
//        static let coalescingInterval = 5.0
//    }
//
//    private func save(to url: URL){
//        let thisfunction = "\(String(describing: self)).\(#function)"
//        do {
//                let data = try emojiArt.json()
//                print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
//                try data.write(to: url)
//        } catch let encodingError where encodingError is EncodingError {
//            print("encodingError happens \(encodingError)")
//        } catch {
//            print("error happens during save")
//        }
//    }
    
//    init() {
//        if let url = Autosave.url, let emojiArtFromURL = try? EmojiArt(url: url) {
//            emojiArt = emojiArtFromURL
//            fetchBackgroundImageDataIfNecessary()
//        } else {
//            emojiArt = EmojiArt()
//            emojiArt.addEmoji("🍏", at: (-200, -100), size: 80)
//            emojiArt.addEmoji("🍎", at: (300, 150), size: 80)
//            emojiArt.addEmoji("🫐", at: (0, 0), size: 80)
//        }
//    }

    
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
        case failed(URL)
    }
    // use URLSession to rewrite
    //
    var cancellableOfURLFectch: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        cancellableOfURLFectch?.cancel()
        let session = URLSession.shared
        switch emojiArt.background {
        case .url( let url ):
            backgroundImageFetchStatus = .fetching
            let publisher = session.dataTaskPublisher(for: url)
                .map{(data, urlResponse) in UIImage(data: data)}
                .replaceError(with: nil)
            // make changes back to the main queue
                .receive(on: DispatchQueue.main)
            
            cancellableOfURLFectch = publisher
                .sink(receiveValue: { [weak self] uiImage in
                    if let uiImage = uiImage {
                        self?.backgroundImage = uiImage
                    }
                    self?.backgroundImageFetchStatus = (uiImage == nil) ? .failed(url) : .idle
                })
        case .blank:
            break
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        }
       
    }
    
    
//    private func fetchBackgroundImageDataIfNecessary() {
//        backgroundImage = nil
//        switch emojiArt.background {
//        case .url(let url):
//            backgroundImageFetchStatus = .fetching
//            DispatchQueue.global(qos: .userInitiated).async {
//                let imageData = try? Data(contentsOf: url)
//                DispatchQueue.main.async { [weak self] in
//                    if self?.emojiArt.background == EmojiArt.Background.url(url) {
//                        self?.backgroundImageFetchStatus = .idle
//                        if imageData != nil {
//                            self?.backgroundImage = UIImage(data: imageData!)
//                        }
//                    }
//
//                }
//            }
//        case .blank:
//            break
//        case .imageData(let data):
//            backgroundImage = UIImage(data: data)
//        }
//    }
    
    func addEmoji(text: String, at location: (x:Int, y: Int), size: CGFloat, with undoManager: UndoManager?){
        undoablyPerform(operation: "addEmoji", with: undoManager) {
            emojiArt.addEmoji(text, at: location, size: Int(size))
        }
        
    }
    
    func setBackground(_ background: EmojiArt.Background, with undoManager: UndoManager?) {
        undoablyPerform(operation: "setBackground", with: undoManager) {
            emojiArt.setBackground(background)
            print("background changed to \(background)")
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat, with undoManager: UndoManager?) {
        //Cannot use mutating member on immutable value: 'emoji' is a 'let' constant
        // !!!!emoji.changeSize(size)
        //change the one in the model
        undoablyPerform(operation: "scaleEmoji", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
            }
        }
        
    }
    
    func shiftLocationForEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize, scale steadyZoomScale: CGFloat, with undoManager: UndoManager?) {
        undoablyPerform(operation: "moveEmoji", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].shiftLocationBy((Int(offset.width/steadyZoomScale), Int(offset.height/steadyZoomScale)))
            }
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
    
    // MARK: -Undo
    
    private func undoablyPerform(operation: String, with undoManager:UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self, handler: { myself in
            myself.undoablyPerform(operation: operation, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        })
        undoManager?.setActionName(operation)
    }
}
