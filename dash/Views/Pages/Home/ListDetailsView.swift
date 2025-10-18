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
                        guard let listIndex = listManager.lists.firstIndex(where: { $0.id == listId }) else { return }

                        // Update the actual list in listManager for immediate UI feedback
                        listManager.lists[listIndex].items.move(fromOffsets: from, toOffset: moveTo)

                        // Update order for each item individually in Firestore
                        for (index, item) in listManager.lists[listIndex].items.enumerated() {
                            listManager.updateItemOrder(listId: listId, itemId: item.id, newOrder: index)
                        }
                    }
                }
                .preferredColorScheme(.light)
                .navigationTitle(list?.name ?? "")
                // add item
                HStack {
                    // add item input - liquid glass style
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color("purple"))
                            .font(.system(size: 16, weight: .semibold))
                        TextField("Item Name", text: $newItem)
                            .font(.system(size: 16, weight: .medium))

                        Spacer()

                        if !newItem.isEmpty {
                            Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isValidInput ? .green : .red)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.leading)

                    // add item button - liquid glass style
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
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color("purple"), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .frame(maxWidth: 100)
                        }
                    )
                    .disabled(!isValidInput)
                    .opacity(isValidInput ? 1.0 : 0.5)
                    .padding(.trailing)
                }.frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.bottom, 8)
            }
        }
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
                                activityItems: [listId], applicationActivities: nil
                            )
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController
                            {
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
                    }
                )
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
