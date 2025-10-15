//
//  ListDetailsView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 19.
//

import SwiftUI

struct ListDetailsView: View {
    @State private var newItem: String = ""
    
    @State var list: Listy
    
    @EnvironmentObject var listManager: ListManager
    
    var body: some View {
        ZStack{
            VStack{
                List {
                    ForEach(self.list.items) { item in
                        ItemView(item: item, listId: list.id)
                    }
                    .onMove { from, to in
                        list.items.move(fromOffsets: from, toOffset: to)
                        for (index, item) in list.items.enumerated() {
                            list.items[index].order = index
                        }
                        listManager.updateItemsInList(listId: self.list.id, items: list.items)
                    }
                }.navigationTitle(self.list.name)
                //add item
                HStack{
                    //add item input
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color("purple"))
                        TextField("Item Name", text: $newItem)
                        
                        Spacer()
                        
                        if(newItem.count != 0){
                            Image(systemName: newItem.count > 1 && newItem.count < 33 ? "checkmark" : "xmark")
                                .fontWeight(.bold)
                                .foregroundColor(newItem.count > 1 && newItem.count < 33 ? .green : .red)
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(Color("purple"))
                    )
                    .padding()
                    
                    //add item button
                    Button(action: {
                        let item = Item(id: UUID().uuidString, text: newItem, order: self.list.items.count)
                        self.list.items.append(item)
                        listManager.addItemToList(listId: self.list.id, item: item)
                        newItem = ""
                    })
                    {
                        Text("Add")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.linearGradient(colors: [Color("purple").opacity(1), Color("purple").opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .frame(maxWidth: 100)
                            .padding(.trailing)
                    }
                }.frame(maxWidth: .infinity, alignment: .bottom)
            }
        }.preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    EditButton()
                }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Menu(content: {
                             Button(action: {
                                 let pasteboard = UIPasteboard.general
                                 pasteboard.string = self.list.id
                             }){
                                 Image(systemName: "doc.on.doc")
                                 Text("Copy code")
                             }
                         
                            Button(action: {
                                let activityVC = UIActivityViewController(activityItems: [self.list.id], applicationActivities: nil)
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityVC, animated: true, completion: nil)
                                }
                             }){
                                 Image(systemName: "square.and.arrow.up")
                                 Text("Share")
                             }
                    
              
                             Button(action: {
                             listManager.deleteList(listId: self.list.id)
                         }){
                             Image(systemName: "trash")
                             Text("Delete")
                         }
                     }, label: {Image(systemName: "gearshape.fill")})
                  }
              }
    }
}

struct ListDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var list: Listy = Listy(id: "2", name: "asd", items: [], users: ["asd"])
        ListDetailsView(list: list)
            .environmentObject(ListManager(userId: "asd"))
    }
}
