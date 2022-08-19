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


struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImageName: String? = nil
    var action: () -> Void
    var body: some View {
        //_ body: () throws -> Result) rethrows -> Result
        //
        Button(action: withAnimation {action}, label: {
            // don't use return keyword in a ViewBuilder
            if title != nil && systemImageName != nil {
                Label(title!, systemImage: systemImageName!)
            } else if title != nil {
                Text(title!)
            } else {
                Image(systemName: systemImageName!)
            }
        })
        
    }
}
