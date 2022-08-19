//
//  PalletStore.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/17/22.
//

import Foundation



class PaletteStore: ObservableObject {
    var name: String
    var palettes:Array<Palette> = []
    
    init(name: String) {
        self.name = name
        if let restoredPallets = restoreFromUserDefaults() {
            palettes = restoredPallets
        }
        if palettes.isEmpty {
            insertPalette(named: "Vehicles", emojis: "🚙🚗🚘🚕🚖🏎🚚🛻🚛🚐🚓🚔🚑🚒🚀✈️🛫🛬🛩🚁🛸🚲🏍🛶⛵️🚤🛥🛳⛴🚢🚂🚝🚅🚆🚊🚉🚇🛺🚜")
            insertPalette(named: "Sports", emojis: "🏈⚾️🏀⚽️🎾🏐🥏🏓⛳️🥅🥌🏂⛷🎳")
            insertPalette(named: "Music", emojis: "🎼🎤🎹🪘🥁🎺🪗🪕🎻")
            insertPalette(named: "Animals", emojis: "🐥🐣🐂🐄🐎🐖🐏🐑🦙🐐🐓🐁🐀🐒🦆🦅🦉🦇🐢🐍🦎🦖🦕🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🦙🐐🦌🐕🐩🦮🐈🦤🦢🦩🕊🦝🦨🦡🦫🦦🦥🐿🦔")
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
    
    
    private var uniqueIdForPallet:Int = 0
    
    func insertPalette(named name: String, emojis: String) {
        uniqueIdForPallet += 1
        palettes.append(Palette(name: name, emojis: emojis, id: uniqueIdForPallet))
    }
    
    //MARK: -- Intent
    
    func addEmojis(_ emojis: String, to palette: Palette) {
        var chosenPalette = palettes.first(where: {$0.id == palette.id})
        if chosenPalette != nil {
            chosenPalette!.addEmojis(emojis)
        }
    }
    
    struct Palette: Identifiable, Codable {
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
    }


}
