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

struct UndoButton: View {
    
    @Environment(\.undoManager) var undoManager
    var undo: String?
    var redo: String?
    
    var body: some View {
        let canUndo = undoManager?.canUndo ?? false
        let canRedo = undoManager?.canRedo ?? false
        if canUndo || canRedo {
            Button {
                if canUndo {
                    undoManager?.undo()
                } else {
                    undoManager?.redo()
                }
            } label: {
                if canUndo  {
                    Image(systemName: "arrow.uturn.backward.circle")
                } else {
                    Image(systemName: "arrow.uturn.forward.circle")
                }
            }
            .contextMenu(menuItems: {
                if canUndo {
                    Button {
                        undoManager?.undo()
                    } label: {
                        Label(undo ?? "Undo", systemImage: "arrow.uturn.backward")
                    }
                }
                if canRedo {
                    Button {
                        undoManager?.redo()
                    } label: {
                        Label(redo ?? "Redo", systemImage: "arrow.uturn.forward")
                    }

                }
            })
        }
    }
}

extension UndoManager {
    var optionalUndoMenuItemTitle: String? {
        canUndo ? undoMenuItemTitle : nil
    }
    var optionalRedoMenuItemTitle: String? {
        canRedo ? redoMenuItemTitle : nil
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
