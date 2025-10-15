//
//  ItemView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 26.
//

import SwiftUI

struct ItemView: View {
    @State private var item: Item;
    @State private var isDeleted: Bool = false
    
    var listId: String
    
    init(item: Item, listId: String){
        self.item = item
        self.listId = listId
    }
    
    @EnvironmentObject var listManager: ListManager
    
    var body: some View {
        if(!isDeleted){
            Text(item.text)
                .strikethrough(item.done)
                .swipeActions(edge: .trailing) {
                    Button {
                        if(!item.done){
                            item.done = true
                            listManager.doneItemInList(listId: listId, itemId: item.id)
                        }
                        else{
                            item.done = false
                            listManager.unDoneItemInList(listId: listId, itemId: item.id)
                        }
                    } label: {
                        Image(systemName: item.done ? "arrow.clockwise" : "checkmark")
                    }
                    .tint(item.done ? .yellow : .green)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        isDeleted = true;
                        listManager.deleteItemFromList(listId: listId, itemId: item.id)
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
