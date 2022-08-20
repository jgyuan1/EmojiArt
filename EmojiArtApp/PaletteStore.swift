//
//  PalletStore.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/17/22.
//

import Foundation



class PaletteStore: ObservableObject {
    let name: String
    @Published var palettes:Array<Palette> = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    
    
    init(name: String) {
        self.name = name
        if let restoredPallets = restoreFromUserDefaults() {
            palettes = restoredPallets
        }
        if palettes.isEmpty {
            insertPalette(named: "Vehicles", emojis: "🚙🚗🚘🚕🚖🏎🚚🛻🚛🚐🚓🚔🚑🚒🚀✈️🛫🛬🛩🚁🛸🚲🏍🛶⛵️🚤🛥🛳⛴🚢🚂🚝🚅🚆🚊🚉🚇🛺🚜")
            insertPalette(named: "Sports", emojis: "🏈⚾️🏀⚽️🎾🏐🥏🏓⛳️🥅🥌🏂⛷🎳")
            insertPalette(named: "Music", emojis: "🎼🎤🎹🪘🥁🎺🪗🪕🎻")
            insertPalette(named: "Animals", emojis: "🐥🐣🐂🐄🐎🐖🐏🐑🐓🐁🐀🐒🦆🦅🦉🦇🐢🐍🦎🦖🦕🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🦙🐐🦌🐕🐩🦮🐈🦤🦢🦩🕊🦝🦨🦡🦫🦦🦥🐿🦔")
            insertPalette(named: "Animal Faces", emojis: "🐵🙈🙊🙉🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐲")
            insertPalette(named: "Flora", emojis: "🌲🌴🌿☘️🍀🍁🍄🌾💐🌷🌹🥀🌺🌸🌼🌻")
            insertPalette(named: "Weather", emojis: "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️💨☔️💧💦🌊☂️🌫🌪")
            insertPalette(named: "COVID", emojis: "💉🦠😷🤧🤒")
            insertPalette(named: "Faces", emojis: "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤯😳🥶😥😓🤗🤔🤭🤫🤥😬🙄😯😧🥱😴🤮😷🤧🤒🤠")
        }
    }
    
    var userDefaultsKeys:String {
        "PalletStore:" + name
    }
    
    func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(palettes) {
            UserDefaults.standard.set(data, forKey: userDefaultsKeys)
        }
    }
    
    func restoreFromUserDefaults() -> [Palette]?{
        if let data = UserDefaults.standard.data(forKey: userDefaultsKeys) {
            if let restoredPallets = try? JSONDecoder().decode(Array<Palette>.self, from: data) {
                return restoredPallets
            }
        }
        return nil
    }
    
    //MARK: -- Intent to delete or add a new palette
    private var uniqueIdForPallet:Int = 0
    
    func insertPalette(named name: String, emojis: String) {
        uniqueIdForPallet += 1
        palettes.append(Palette(name: name, emojis: emojis, id: uniqueIdForPallet))
    }
    
    func deletePaletteAt(_ index: Int) {
        palettes.remove(at: index)
    }
    
    
    
    //MARK: -- Intent
    
    func addEmojis(_ emojis: String, to palette: Palette) {
        var chosenPalette = palettes.first(where: {$0.id == palette.id})
        if chosenPalette != nil {
            chosenPalette!.emojis = ("" + emojis + palette.emojis).filter({$0.isEmoji}).removingDuplicateCharacters
            print("palette " + palette.name + ":" + chosenPalette!.emojis + "ADD")
        }
    }
    
    func deleteEmoji(_ emoji: String, from palette: Palette) {
        var chosenPalette = palettes.first(where: {$0.id == palette.id})
        // Palette is a struct, it's immutable, it will get a new copy of itself when something in it changes
        // ViewModel is the only source of true, and always mutate things within it
//        chosenPalette!.deleteEmoji(emoji)
        if chosenPalette != nil {
            chosenPalette!.emojis = palette.emojis.filter({String($0) != emoji})
            print("palette " + palette.name + ":" + chosenPalette!.emojis + "DELETE")
        }
    }
    
    struct Palette: Identifiable, Codable, Hashable {
        var name:String
        var emojis:String
        let id:Int
        init(name: String, emojis: String, id: Int) {
            self.name = name
            self.emojis = emojis
            self.id = id
        }
        
        mutating func addEmojis(_ emojisToAdd: String) {

            emojis = ("" + emojisToAdd + emojis).filter({$0.isEmoji}).removingDuplicateCharacters
        }

        //when binding a palette to PaletteEditor, you actually need to CRUD palette directly by these mutating method
        mutating func deleteEmoji(_ emoji: String) {
            emojis = emojis.filter({String($0) != emoji})
            print("delete emoji" + emoji + "from PaletteStore")
        }
    }


}
