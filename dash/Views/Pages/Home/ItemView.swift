//
//  ItemView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 26.
//

import SwiftUI

struct ItemView: View {
    let item: Item
    let listId: String
    
    @EnvironmentObject var listManager: ListManager
    
    private var currentItem: Item? {
        listManager.lists
            .first(where: { $0.id == listId })?
            .items
            .first(where: { $0.id == item.id })
    }
    
    var body: some View {
        if let currentItem = currentItem {
            Text(currentItem.text)
                .strikethrough(currentItem.done)
                .swipeActions(edge: .trailing) {
                    Button {
                        if currentItem.done {
                            listManager.unDoneItemInList(listId: listId, itemId: currentItem.id)
                        } else {
                            listManager.doneItemInList(listId: listId, itemId: currentItem.id)
                        }
                    } label: {
                        Image(systemName: currentItem.done ? "arrow.clockwise" : "checkmark")
                    }
                    .tint(currentItem.done ? .yellow : .green)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        listManager.deleteItemFromList(listId: listId, itemId: currentItem.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
                .transition(.scale)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: Item(id: "1", text: "rama margarin", done: false), listId: "alma")
    }
}
