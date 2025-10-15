//
//  ListDetailsView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 19.
//

import SwiftUI

struct ListDetailsView: View {
  @State private var newItem: String = ""

  let listId: String

  @EnvironmentObject var listManager: ListManager

  // Computed property to get the current list from ListManager
  private var list: Listy? {
    listManager.lists.first(where: { $0.id == listId })
  }

  private var isValidInput: Bool {
    if case .success = InputValidator.validateItemName(newItem) {
      return true
    }
    return false
  }

  var body: some View {
    ZStack {
      VStack {
        List {
          ForEach(list?.items ?? []) { item in
            ItemView(item: item, listId: listId)
          }
          .onMove { from, moveTo in
            guard var currentList = list else { return }
            currentList.items.move(fromOffsets: from, toOffset: moveTo)
            for (index, item) in currentList.items.enumerated() {
              currentList.items[index].order = index
            }
            listManager.updateItemsInList(listId: listId, items: currentList.items)
          }
        }.navigationTitle(list?.name ?? "")
        // add item
        HStack {
          // add item input
          HStack {
            Image(systemName: "square.and.pencil")
              .foregroundColor(Color("purple"))
            TextField("Item Name", text: $newItem)

            Spacer()

            if !newItem.isEmpty {
              Image(systemName: isValidInput ? "checkmark" : "xmark")
                .fontWeight(.bold)
                .foregroundColor(isValidInput ? .green : .red)
            }
          }
          .padding()
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(lineWidth: 2)
              .foregroundColor(Color("purple"))
          )
          .padding()

          // add item button
          Button(
            action: {
              guard let currentList = list else { return }
              let item = Item(id: UUID().uuidString, text: newItem, order: currentList.items.count)
              listManager.addItemToList(listId: listId, item: item)
              newItem = ""
            },
            label: {
              Text("Add")
                .foregroundColor(.white)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                  .linearGradient(
                    colors: [Color("purple").opacity(1), Color("purple").opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(maxWidth: 100)
                .padding(.trailing)
            }
          )
          .disabled(!isValidInput)
          .opacity(isValidInput ? 1.0 : 0.6)
        }.frame(maxWidth: .infinity, alignment: .bottom)
      }
    }.preferredColorScheme(.light)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu(
            content: {
              Button(action: {
                let pasteboard = UIPasteboard.general
                pasteboard.string = listId
              }) {
                Image(systemName: "doc.on.doc")
                Text("Copy code")
              }

              Button(action: {
                let activityVC = UIActivityViewController(
                  activityItems: [listId], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController {
                  rootViewController.present(activityVC, animated: true, completion: nil)
                }
              }, label: {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
              })

              Button(action: {
                listManager.deleteList(listId: listId)
              }, label: {
                Image(systemName: "trash")
                Text("Delete")
              })
            }, label: {
              Image(systemName: "gearshape.fill")
            })
        }
      }
  }
}

struct ListDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    ListDetailsView(listId: "2")
      .environmentObject(ListManager(userId: "asd"))
  }
}
