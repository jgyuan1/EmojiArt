//
//  UtilityViews.swift
//  EmojiArtApp
//
//  Created by CHENGLONG HAO on 8/15/22.
//

import SwiftUI

struct OptionalImageView: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}
